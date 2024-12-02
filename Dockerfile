FROM dusknetwork/node:latest

USER root

# Install required tools
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/dusk/{bin,conf,rusk,services} ~/.dusk/rusk-wallet && \
    mkdir -p /opt/dusk/rusk/state

# Copy from base image
COPY --from=0 /opt/rusk/rusk /opt/dusk/bin/
COPY --from=0 /opt/rusk/state.toml /opt/dusk/conf/rusk.toml

# Download and setup verifier keys
RUN cd /tmp && \
    curl -so rusk-vd-keys.zip -L "https://testnet.nodes.dusk.network/keys" && \
    unzip -o rusk-vd-keys.zip -d /opt/dusk/rusk/ && \
    mv /opt/dusk/rusk/devnet-piecrust.crs /opt/dusk/rusk/dev-piecrust.crs && \
    rm rusk-vd-keys.zip

# Setup permissions
RUN chown -R 1000:1000 /opt/dusk ~/.dusk && \
    chmod -R 755 /opt/dusk/bin/* && \
    chmod 600 /opt/dusk/rusk/dev-piecrust.crs && \
    ln -sf /opt/dusk/bin/rusk /usr/bin/rusk

WORKDIR /opt/dusk/bin
USER 1000:1000

ENTRYPOINT ["./rusk"]
CMD ["--network-id", "2", "--kadcast-bootstrap", "188.166.70.129:9000,139.59.146.237:9000"]