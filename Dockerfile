# Dockerfile

# Start from the official n8n base image (use a specific version for stability)
FROM n8nio/n8n:1.41.1

# Switch to root user to install packages
USER root

# Update package lists and install Python, pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    # Add build-essential python3-dev if needed for complex libraries
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy your requirements file into the image
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies using pip
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Clean up the requirements file (optional)
RUN rm /tmp/requirements.txt

# IMPORTANT: Switch back to the non-root n8n user
USER node

# The base image's CMD or ENTRYPOINT will run n8n automatically