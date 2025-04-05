# Use Node.js 20 Alpine as the base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package.json and lock file
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all other source code
COPY . .

# Expose the port Medusa runs on (default is 9000)
EXPOSE 9000

# Start the Medusa backend
CMD ["npm", "run", "start"]
