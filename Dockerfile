FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++ curl

# Install Medusa CLI with version pinning
RUN npm install -g @medusajs/medusa-cli@latest

COPY package*.json ./
RUN npm install --production && npm cache clean --force

COPY . .

ENV NODE_ENV=production
ENV PORT=9000

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:9000/health || exit 1

# Startup script with error handling and delays
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
