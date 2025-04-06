# Use an official Node.js Alpine base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ curl

# Install Medusa CLI
RUN npm install -g @medusajs/medusa-cli@latest

# Copy package files and install only production deps
COPY package*.json ./
RUN npm install --production && npm cache clean --force

# Copy the full source code
COPY . .

# Environment setup
ENV NODE_ENV=production
ENV PORT=9000

# Expose the app port
EXPOSE 9000

# Healthcheck for ECS (Medusa store endpoint)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -f http://localhost:9000/store/products || exit 1

# Copy and set entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
