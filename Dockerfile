# Dockerfile

# Start from the official N8n image (Alpine based)
FROM n8nio/n8n:latest 

# Switch to root user
USER root

# Install Alpine packages: python3, pip, build tools, AND Playwright dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \      # venv package for Debian
    build-essential \   # Standard build tools
    # --- Playwright System Dependencies for Debian ---
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libexpat1 \
    libxcb1 \
    libxkbcommon0 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libxshmfence1 \
    libgles2 \
    # --- Fonts (including emoji) ---
    fonts-liberation \
    fonts-noto-color-emoji \ # <--- Correct package name for Debian/Ubuntu
    # --- Other tools ---
    xvfb \
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