#!/bin/bash
set -e

# Setup wallet if mnemonic exists
if [ -f "/config/mnemonic" ]; then
    echo "Restoring wallet from mnemonic..."
    rusk-wallet restore < /config/mnemonic
fi

# Export consensus keys if wallet password exists
if [ -f "/config/wallet-password" ]; then
    echo "Exporting consensus keys..."
    rusk-wallet export -d /opt/dusk/conf -n consensus.keys < /config/wallet-password
fi

# Set consensus password
if [ -f "/config/consensus-password" ]; then
    echo "Setting consensus password..."
    sh /opt/dusk/bin/setup_consensus_pwd.sh < /config/consensus-password
fi

# Start Rusk service using service command
sudo service rusk start

# Keep container running and output logs
exec tail -f /var/log/rusk.log