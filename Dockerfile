# Use Node 20
FROM node:20

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install dependencies
RUN npm install

# Build if needed
# RUN npm run build

# Expose Medusa port
EXPOSE 9000

# Start Medusa
CMD ["npm", "run", "start"]

