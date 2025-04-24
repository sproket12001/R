# Dockerfile (Alpine Base)

# 1. Assume Railway provides an Alpine-based N8n image
#    We still include a FROM line as it's required Dockerfile syntax,
#    but accept the build environment might override it.
FROM n8nio/n8n:latest # Or n8nio/n8n:1.28.0 

# 2. Switch to root user
USER root

# 3. Install Alpine packages using apk
#    python3, pip, build tools, AND Playwright system deps
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \           # Installs pip for python3
    build-base \        # Alpine equivalent of build-essential
    python3-dev \       # Provides Python header files
    # --- Playwright System Dependencies for Alpine ---
    udev \
    ttf-freefont \
    freetype \
    harfbuzz \
    libstdc++ \
    cairo \
    xvfb \
    chromium            # NO backslash - last package in list

# --- Check Versions ---
RUN echo "==== VERSION CHECK ====" && \
    python3 --version && \
    pip3 --version && \
    echo "======================="

# 4. Copy requirements file
COPY requirements.txt /tmp/requirements.txt

# 5. Install Python dependencies using pip, breaking system packages protection
RUN pip3 install --no-cache-dir --break-system-packages -r /tmp/requirements.txt

# 6. Install Playwright Browsers (if playwright install succeeded)
#    This step might fail if pip install playwright failed
#    We add '|| true' so this step doesn't fail the whole build if playwright isn't there
RUN playwright install --with-deps || true

# 7. Clean up requirements file
RUN rm /tmp/requirements.txt

# 8. IMPORTANT: Switch back to the standard N8n user
USER node