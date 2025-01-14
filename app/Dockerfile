# Use the minimal Python 3.9 slim image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies (if any system-level packages are required)
# Note: Replace <package-name> with necessary system-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gcc \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the application code to the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set the entry point for the application
CMD ["python", "app.py"]
