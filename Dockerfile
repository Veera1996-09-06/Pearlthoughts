# Use official Node.js 18 image
FROM node:18

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Medusa CLI globally
RUN npm install -g @medusajs/medusa-cli

# Copy package files
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy all files
COPY . .

# Set environment variables (override these in ECS task definition)
ENV NODE_ENV=production
ENV PORT=9000
ENV DATABASE_URL=postgres://medusa:medusa_pass@localhost:5432/medusa_db
ENV REDIS_URL=redis://localhost:6379

# Build the application (if needed)
# RUN npm run build

# Expose the Medusa port
EXPOSE 9000

# Run migrations and start the server
CMD ["sh", "-c", "npx medusa migrations run && medusa start"]
