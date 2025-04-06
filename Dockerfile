# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Install dependencies (cached layer)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy all files needed for build
COPY . .

# Build the project (if using TypeScript)
RUN if [ -f tsconfig.json ]; then npm run build; fi

# Stage 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Install production dependencies and runtime tools
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 1001 -S medusa && \
    adduser -u 1001 -S medusa -G medusa

# Copy from builder (with existence checks)
COPY --from=builder --chown=medusa:medusa /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=medusa:medusa /usr/src/app/package*.json ./

# Conditional copy for build output
RUN if [ -d "/usr/src/app/dist" ]; then \
      COPY --from=builder --chown=medusa:medusa /usr/src/app/dist ./dist; \
    fi

# Copy source files (if not using dist)
RUN if [ ! -d "/usr/src/app/dist" ]; then \
      COPY --from=builder --chown=medusa:medusa /usr/src/app/src ./src; \
    fi

# Conditionally copy config files
RUN if [ -f "/usr/src/app/medusa-config.js" ]; then \
      COPY --from=builder --chown=medusa:medusa /usr/src/app/medusa-config.js ./; \
    elif [ -f "/usr/src/app/medusa-config.ts" ]; then \
      COPY --from=builder --chown=medusa:medusa /usr/src/app/medusa-config.ts ./; \
    fi

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:9000/health || exit 1

# Runtime configuration
ENV NODE_ENV=production
ENV PORT=9000
EXPOSE 9000

USER medusa

CMD ["node", "dist/index.js"]  # or "src/index.js" if not using dist
