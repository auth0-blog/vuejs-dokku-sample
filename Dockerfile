# Use Node 10
FROM node:10-slim AS build

# Create a folder for our app
RUN mkdir /app

# Set up the working directory
WORKDIR /app

# Copy our package.json file first, then run `npm install`.
# This is an optimization we can make, as this layer will be
# cached, meaning that if we don't change the package.json file,
# this step doesn't need to be performed again
COPY package.json .

# Note that we're installing all dependencies, unlike the buildpack
RUN npm install

# Copy the rest of the application
COPY . .

# Build the Vue.js application. It will output static files
# Into the /dist folder
RUN npm run build

# ---------------

# Create a second-stage which copies the /dist folder
# and uses http-server to host the application
FROM node:10-slim

# Create an app folder
RUN mkdir /app

# Set /app as the working directory
WORKDIR /app

# Initialize a new node app and
# install http-server
RUN npm init -y && \
  npm install http-server

# Copy the built artifacts from the build stage
COPY --from=build /app/dist /app

# Expose port
EXPOSE 8080

# Set the startup command
CMD ["./node_modules/.bin/http-server"]
