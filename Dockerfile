# Dockerfile

# Start from the official n8n base image (use a specific version for stability)
FROM n8nio/n8n:latest

# Switch to root user to install packages
USER root

# Update package lists and install Python, pip
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    python3-dev

# --- Create and activate virtual environment ---
# Create a directory for the venv owned by the node user
RUN mkdir /opt/venv && chown node:node /opt/venv

# Switch to node user TEMPORARILY to create venv correctly
USER node 
RUN python3 -m venv /opt/venv

# Copy requirements file (owned by root, but that's okay for copying)
USER root 
COPY requirements.txt /tmp/requirements.txt

# --- Install packages into the virtual environment ---
# Use the pip from the venv to install packages
# We run this as root because apk ran as root, but install into the venv
RUN /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

# Clean up requirements file
RUN rm /tmp/requirements.txt

# IMPORTANT: Switch back to the standard N8n user for running n8n
USER node

# How N8n will run Python now:
# In Execute Command node, use: /opt/venv/bin/python3 your_script.py