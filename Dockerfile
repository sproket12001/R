FROM n8nio/n8n:latest

USER root
RUN cp /etc/apk/repositories /etc/apk/repositories.orig

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> /etc/apk/repositories

RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    python3-dev \
    ca-certificates

RUN cp /etc/apk/repositories.orig /etc/apk/repositories && \
    rm /etc/apk/repositories.orig

RUN apk update && apk add --no-cache \
    udev \
    ttf-freefont \
    freetype \
    harfbuzz \
    libstdc++ \
    cairo \
    xvfb \
    chromium

RUN python3 -m pip install --upgrade pip

RUN echo "==== VERSION CHECK (EXPECTING PYTHON 3.10) ====" && \
    python3 --version && \
    pip3 --version && \
    echo "================================================"


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