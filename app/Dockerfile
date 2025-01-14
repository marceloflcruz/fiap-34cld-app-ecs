# Use the official Python 3.9 Alpine base image
FROM python:3.9-alpine

# Set the working directory in the container
WORKDIR /app

# Install required system dependencies and Python packages
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    docker \
    terraform \
    && pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .

# Set the default command to run the applica
