FROM node:20

# Create app directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build (if needed)
# RUN npm run build

# Expose port (change if your app uses a different one)
EXPOSE 9000

# Start the app
CMD ["npm", "start"]
