FROM --platform=linux/amd64 dusknetwork/node:latest

USER root

# Install required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of Rust (stable)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /tmp

# Download and extract a specific release version of rusk-wallet
RUN wget https://github.com/dusk-network/rusk/releases/download/rusk-wallet-0.6.1/rusk-wallet-linux-libssl3.tar.gz && \
    tar xzf rusk-wallet-linux-libssl3.tar.gz && \
    mv rusk-wallet /opt/dusk/bin/ && \
    chmod +x /opt/dusk/bin/rusk-wallet && \
    rm rusk-wallet-linux-libssl3.tar.gz

# Create setup_consensus_pwd.sh script
RUN mkdir -p /opt/dusk/services && \
    echo '#!/bin/bash\nread pwd\necho "CONSENSUS_KEYS_PASS=$pwd" > /opt/dusk/services/dusk.conf' > /opt/dusk/bin/setup_consensus_pwd.sh && \
    chmod +x /opt/dusk/bin/setup_consensus_pwd.sh

# Switch back to dusk user
USER 1000:1000

WORKDIR /opt/dusk