FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++ curl

RUN npm install -g @medusajs/medusa-cli@latest

COPY package*.json ./
RUN npm install --production && npm cache clean --force

COPY . .

ENV NODE_ENV=production
ENV PORT=9000

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -f http://localhost:9000/store/products || exit 1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
