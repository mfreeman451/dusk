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
    unzip \
    jq \
    net-tools \
    dnsutils \
    ufw \
    clang \
    git \
    build-essential \
    libssl-dev \
    pkg-config

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh -s -- -y

# Add cargo to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Create dusk user and directories
RUN useradd -m -d /opt/dusk dusk && \
    mkdir -p /opt/dusk/conf /opt/dusk/bin /opt/dusk/state /opt/dusk/services /var/log/dusk && \
    chown -R dusk:dusk /opt/dusk /var/log/dusk

# Switch to dusk user
USER dusk
WORKDIR /home/dusk

# Clone Rusk repository
RUN git clone https://github.com/dusk-network/rusk.git

# Build the node and wallet
USER root
RUN cd rusk && \
    make keys && \
    make wasm && \
    cargo build --release -p rusk && \
    cargo build --release -p rusk-wallet

USER dusk

# Copy the binaries to /opt/dusk/bin
RUN cp /home/dusk/rusk/target/release/rusk /opt/dusk/bin/ && \
    cp /home/dusk/rusk/target/release/rusk-wallet /opt/dusk/bin/ && \
    chown dusk:dusk /opt/dusk/bin/* && \
    chmod +x /opt/dusk/bin/*

# Copy the installer scripts and configurations
RUN mkdir -p /opt/dusk/installer && \
    curl -so /opt/dusk/installer/installer.tar.gz -L "https://github.com/dusk-network/node-installer/archive/refs/tags/v0.3.5.tar.gz" && \
    tar xf /opt/dusk/installer/installer.tar.gz --strip-components 1 --directory /opt/dusk/installer && \
    mv -f /opt/dusk/installer/bin/* /opt/dusk/bin/ && \
    mv /opt/dusk/installer/conf/* /opt/dusk/conf/ && \
    mv -n /opt/dusk/installer/services/* /opt/dusk/services/ && \
    mv -f /opt/dusk/conf/wallet.toml /home/dusk/.dusk/rusk-wallet/config.toml && \
    chown -R dusk:dusk /opt/dusk /home/dusk/.dusk && \
    chmod +x /opt/dusk/bin/*

# Set permissions
RUN chown -R dusk:dusk /opt/dusk /var/log/dusk /home/dusk/.dusk && \
    chmod -R 755 /opt/dusk && \
    chmod 644 /var/log/rusk.log

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chown dusk:dusk /usr/local/bin/entrypoint.sh

# Switch back to dusk user
USER dusk
WORKDIR /opt/dusk

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
