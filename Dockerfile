FROM ubuntu:22.04

# Prevent apt from prompting for input
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    openssl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create dusk user and directories
RUN useradd -m -d /opt/dusk dusk && \
    mkdir -p /opt/dusk/conf /opt/dusk/bin /var/log/dusk && \
    chown -R dusk:dusk /opt/dusk /var/log/dusk

# Configure sudo access for dusk user
RUN echo "dusk ALL=(ALL) NOPASSWD: /usr/sbin/service" > /etc/sudoers.d/dusk && \
    chmod 0440 /etc/sudoers.d/dusk

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