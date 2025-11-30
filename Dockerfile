FROM n8nio/n8n:latest

USER root

# Install AWS CLI
RUN apk add --no-cache python3 py3-pip \
    && pip3 install --upgrade pip --break-system-packages \
    && pip3 install awscli --break-system-packages \
    && rm -rf /var/cache/apk/*

USER node
