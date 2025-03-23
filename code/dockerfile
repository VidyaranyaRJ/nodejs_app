# Use official Node.js image as base
FROM node:16

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app's files into the container
COPY . .

# Expose port 3000 to the outside world
EXPOSE 3000

# Run the application
CMD ["node", "index.js"]
