FROM alpine:3.19

# Install required dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    openssl \
    systemd \
    sudo

# Create dusk user and directories
RUN adduser -D -h /opt/dusk dusk && \
    mkdir -p /opt/dusk/conf /opt/dusk/bin /var/log/dusk && \
    chown -R dusk:dusk /opt/dusk /var/log/dusk

# Install Dusk node
RUN curl --proto '=https' --tlsv1.2 -sSfL \
    https://github.com/dusk-network/node-installer/releases/download/v0.3.5/node-installer.sh \
    -o /tmp/installer.sh && \
    sh /tmp/installer.sh && \
    rm /tmp/installer.sh

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown dusk:dusk /usr/local/bin/entrypoint.sh

# Switch to non-root user
USER dusk
WORKDIR /opt/dusk

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]