# Dockerfile

# Start from the official N8n image (Alpine based)
FROM n8nio/n8n:latest 

# Switch to root user
USER root

# Install Alpine packages: python3, pip, build tools, AND Playwright dependencies
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    python3-dev \
    # --- Playwright System Dependencies for Alpine ---
    udev \
    ttf-freefont \
    freetype \
    harfbuzz \
    libstdc++ \
    cairo \
    xvfb \
    noto-fonts-emoji \
    chromium # <--- Add browser if you want system version, OR let playwright install below

# --- Check Versions ---
RUN python3 --version && pip3 --version

# --- Create virtual environment ---
RUN mkdir /opt/venv && chown node:node /opt/venv
USER node 
RUN python3 -m venv /opt/venv
USER root 
COPY requirements.txt /tmp/requirements.txt

# --- Install packages into the virtual environment ---
RUN /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt # <-- This is the line that failed

# --- Install Playwright Browsers (AFTER pip install) ---
# Use --with-deps to try and auto-install any missing OS dependencies
RUN /opt/venv/bin/playwright install --with-deps 

# --- Clean up ---
RUN rm /tmp/requirements.txt

# Switch back to standard N8n user
USER node