#!/bin/bash
set -e

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Debug info
echo "PATH=$PATH"
echo "Checking rusk-wallet location:"
which rusk-wallet || echo "rusk-wallet not in PATH"
ls -la /opt/dusk/bin/rusk-wallet || echo "rusk-wallet not in /opt/dusk/bin"
ls -la /usr/bin/rusk-wallet || echo "rusk-wallet not in /usr/bin"

# Setup wallet if mnemonic exists
if [ -f "/config/mnemonic" ]; then
    echo "Restoring wallet from mnemonic..."
    WALLET_PASSWORD=$(cat /config/wallet-password)
    {
        cat /config/mnemonic
        echo "${WALLET_PASSWORD}"
        echo "${WALLET_PASSWORD}"
    } | /opt/dusk/bin/rusk-wallet restore || handle_error "Failed to restore wallet"
    echo "Wallet restored successfully"
fi

# Export consensus keys if wallet password exists
if [ -f "/config/consensus-key-password" ]; then
    echo "Exporting consensus keys..."
    CONSENSUS_KEY_PASSWORD=$(cat /config/consensus-key-password)
    {
        echo "${WALLET_PASSWORD}"        # Wallet password needed for export
        echo "${CONSENSUS_KEY_PASSWORD}" # New password for consensus key
        echo "${CONSENSUS_KEY_PASSWORD}" # Confirm new password
    } | /opt/dusk/bin/rusk-wallet export -d /opt/dusk/conf -n consensus.keys || handle_error "Failed to export consensus keys"
    echo "Consensus keys exported successfully"

    # Set up consensus password as environment variable
    echo "Setting up consensus password environment variable..."
    echo "${CONSENSUS_KEY_PASSWORD}" | sh /opt/dusk/bin/setup_consensus_pwd.sh || handle_error "Failed to set consensus password"
    echo "Consensus password environment variable set successfully"
fi

# Start Rusk service
echo "Starting Rusk service..."
sudo service rusk start

# Keep container running and output logs
exec tail -f /var/log/rusk.log