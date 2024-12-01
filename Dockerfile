FROM dusknetwork/node:latest

USER root

# Install required dependencies for building rusk-wallet
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone and build rusk-wallet
RUN git clone https://github.com/dusk-network/rusk.git /tmp/rusk && \
    cd /tmp/rusk && \
    cargo build --release --bin rusk-wallet && \
    mv target/release/rusk-wallet /opt/dusk/bin/ && \
    chmod +x /opt/dusk/bin/rusk-wallet && \
    rm -rf /tmp/rusk

# Create setup_consensus_pwd.sh script
RUN echo '#!/bin/bash\nread pwd\necho "CONSENSUS_KEYS_PASS=$pwd" > /opt/dusk/services/dusk.conf' > /opt/dusk/bin/setup_consensus_pwd.sh && \
    chmod +x /opt/dusk/bin/setup_consensus_pwd.sh

# Switch back to dusk user
USER 1000:1000