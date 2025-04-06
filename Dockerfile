# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Install dependencies (cached layer)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy all files needed for build
COPY . .

# Build the project if using TypeScript
RUN if [ -f tsconfig.json ]; then npm run build; fi

# Create empty dist directory if it doesn't exist
RUN mkdir -p dist

# Stage 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Install production dependencies and runtime tools
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 1001 -S medusa && \
    adduser -u 1001 -S medusa -G medusa

# Copy from builder
COPY --from=builder --chown=medusa:medusa /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=medusa:medusa /usr/src/app/package*.json ./

# Copy source files
COPY --from=builder --chown=medusa:medusa /usr/src/app/src ./src

# Copy dist directory (empty if not built)
COPY --from=builder --chown=medusa:medusa /usr/src/app/dist ./dist

# Copy config file if exists (using find + xargs pattern)
RUN find /usr/src/app -maxdepth 1 -name 'medusa-config*' -exec cp {} /app \; || true

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:9000/health || exit 1

# Runtime configuration
ENV NODE_ENV=production
ENV PORT=9000
EXPOSE 9000

USER medusa

# Smart entrypoint that works for both JS and TS projects
CMD ["sh", "-c", "if [ -f 'dist/index.js' ]; then node dist/index.js; else node src/index.js; fi"]
