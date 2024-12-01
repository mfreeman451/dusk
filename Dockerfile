FROM ubuntu:22.04

# Prevent apt from prompting for input
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/dusk/bin:/usr/bin:/usr/local/bin:${PATH}"

# Install minimal required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    openssl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create dusk user and directories
RUN useradd -m -d /opt/dusk dusk && \
    mkdir -p /opt/dusk/conf /opt/dusk/bin /opt/dusk/state /opt/dusk/services /var/log/dusk && \
    chown -R dusk:dusk /opt/dusk /var/log/dusk

# Configure sudo access for dusk user
RUN echo "dusk ALL=(ALL) NOPASSWD: /usr/sbin/service" > /etc/sudoers.d/dusk && \
    chmod 0440 /etc/sudoers.d/dusk

# Install Dusk node
RUN curl --proto '=https' --tlsv1.2 -sSfL \
    https://github.com/dusk-network/node-installer/releases/download/v0.3.5/node-installer.sh \
    -o /tmp/installer.sh && \
    PREFIX=/opt/dusk bash -x /tmp/installer.sh && \
    rm /tmp/installer.sh && \
    chmod -R 755 /opt/dusk/bin && \
    chown -R dusk:dusk /opt/dusk /var/log/dusk


# Create rusk service file
RUN echo '[Unit]\n\
Description=Dusk Network Node\n\
After=network.target\n\
\n\
[Service]\n\
User=dusk\n\
Group=dusk\n\
Type=simple\n\
Environment="DUSK_CONSENSUS_KEYS_PASS=dummy"\n\
WorkingDirectory=/opt/dusk\n\
ExecStart=/opt/dusk/bin/rusk\n\
Restart=always\n\
RestartSec=5\n\
\n\
[Install]\n\
WantedBy=multi-user.target' > /opt/dusk/services/rusk.service && \
    chmod 644 /opt/dusk/services/rusk.service && \
    chown dusk:dusk /opt/dusk/services/rusk.service

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown dusk:dusk /usr/local/bin/entrypoint.sh

# Debug info
RUN ls -la /opt/dusk/bin/ && \
    ls -la /usr/bin/rusk* && \
    ls -la /opt/dusk/services && \
    echo "PATH=$PATH" && \
    which rusk-wallet

# Switch to non-root user
USER dusk
WORKDIR /opt/dusk

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]