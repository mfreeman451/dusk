# Using Ubuntu minimal as base since Dusk's installer is built for Ubuntu
FROM ubuntu:22.04-minimal

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    openssl \
    systemd \
    && rm -rf /var/lib/apt/lists/*

# Create dusk user and directories
RUN useradd -r -s /bin/false dusk \
    && mkdir -p /opt/dusk/conf /opt/dusk/bin /var/log/dusk \
    && chown -R dusk:dusk /opt/dusk /var/log/dusk

# Install Dusk node
RUN curl --proto '=https' --tlsv1.2 -sSfL \
    https://github.com/dusk-network/node-installer/releases/download/v0.3.5/node-installer.sh \
    -o /tmp/installer.sh \
    && sh /tmp/installer.sh \
    && rm /tmp/installer.sh

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to non-root user
USER dusk

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]