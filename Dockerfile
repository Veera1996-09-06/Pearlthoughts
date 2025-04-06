# Use Node.js 20 Alpine image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install required packages (for node-gyp, etc.)
RUN apk add --no-cache python3 make g++ curl

# Install Medusa CLI globally
RUN npm install -g @medusajs/medusa-cli@latest

# Copy only package files first for better caching
COPY package*.json ./

# Install only production dependencies
RUN npm install --production && npm cache clean --force

# Copy the rest of the code
COPY . .

# Set environment variables
ENV NODE_ENV=production
ENV PORT=9000

# Expose Medusa port
EXPOSE 9000

# Add health check (important for ECS)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -f http://localhost:9000/health || exit 1

# Copy entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint to start the app
ENTRYPOINT ["/entrypoint.sh"]
