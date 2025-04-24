# Dockerfile

# Start from the official n8n base image (use a specific version for stability)
FROM n8nio/n8n:latest

# Switch to root user to install packages
USER root

# Update package lists and install Python, pip
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip

# Copy your requirements file into the image
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies using pip
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Clean up the requirements file (optional)
RUN rm /tmp/requirements.txt

# IMPORTANT: Switch back to the non-root n8n user
USER node

# The base image's CMD or ENTRYPOINT will run n8n automatically