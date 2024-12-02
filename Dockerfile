FROM --platform=linux/amd64 dusknetwork/node:latest

USER root

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /opt/dusk/bin \
    /opt/dusk/conf \
    /opt/dusk/rusk \
    /opt/dusk/services \
    /opt/dusk/installer \
    /root/.dusk/rusk-wallet

# Download and extract installer package
RUN curl -so /opt/dusk/installer/installer.tar.gz -L "https://github.com/dusk-network/node-installer/tarball/main" && \
    tar xf /opt/dusk/installer/installer.tar.gz --strip-components 1 --directory /opt/dusk/installer && \
    mv -f /opt/dusk/installer/bin/* /opt/dusk/bin/ && \
    mv /opt/dusk/installer/conf/* /opt/dusk/conf/ && \
    mv -n /opt/dusk/installer/services/* /opt/dusk/services/ && \
    mv -f /opt/dusk/conf/wallet.toml /root/.dusk/rusk-wallet/config.toml

# Download verifier keys
RUN curl -so /opt/dusk/installer/rusk-vd-keys.zip -L "https://testnet.nodes.dusk.network/keys" && \
    unzip -d /opt/dusk/rusk/ -o /opt/dusk/installer/rusk-vd-keys.zip

# Make everything executable and set permissions
RUN chmod +x /opt/dusk/bin/* && \
    chown -R dusk:dusk /opt/dusk && \
    chown -R dusk:dusk /home/dusk/.dusk && \
    rm -rf /opt/dusk/installer

USER 1000:1000
WORKDIR /opt/dusk