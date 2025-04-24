# Dockerfile

# Start from the official N8n image (Alpine based)
FROM n8nio/n8n:latest 

# Switch to root user
USER root

# Install Alpine packages: python3, pip, build tools, AND Playwright dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \   # Add backslash
    libnss3 \           # Add backslash
    libnspr4 \          # Add backslash
    libdbus-1-3 \       # Add backslash
    libatk1.0-0 \       # Add backslash
    libatk-bridge2.0-0 \ # Add backslash
    libcups2 \          # Add backslash
    libdrm2 \           # Add backslash
    libexpat1 \         # Add backslash
    libxcb1 \           # Add backslash
    libxkbcommon0 \     # Add backslash
    libxrandr2 \        # Add backslash
    libgbm1 \           # Add backslash
    libasound2 \        # Add backslash
    libxshmfence1 \     # Add backslash
    libgles2 \          # Add backslash
    fonts-liberation \       # Add backslash
    fonts-noto-color-emoji \ # Add backslash
    xvfb                # NO backslash - this is the last package
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- Check Versions (Optional but helpful) ---
RUN python3 --version && pip3 --version

# --- Create virtual environment ---
RUN mkdir /opt/venv && chown node:node /opt/venv
USER node
RUN python3 -m venv /opt/venv
USER root
COPY requirements.txt /tmp/requirements.txt

# --- Install packages into the virtual environment ---
RUN /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

# --- Install Playwright Browsers (AFTER pip install) ---
RUN /opt/venv/bin/playwright install --with-deps

# --- Clean up ---
RUN rm /tmp/requirements.txt

# 4. IMPORTANT: Switch back to the standard N8n user
USER node

# How N8n will run Python now (if using venv):
# In Execute Command node, use: /opt/venv/bin/python3 your_script.py