#!/bin/bash
set -e

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Debug info
echo "PATH=$PATH"
echo "HOME=$HOME"
echo "PWD=$(pwd)"
echo "USER=$(whoami)"
echo "Checking rusk-wallet location:"
which rusk-wallet
ls -la $(which rusk-wallet)
ls -la /opt/dusk/bin/rusk-wallet

# Setup wallet if mnemonic exists
if [ -f "/config/mnemonic" ]; then
    echo "Restoring wallet from mnemonic..."
    mkdir -p $HOME/.dusk/rusk-wallet
    WALLET_PASSWORD=$(cat /config/wallet-password)
    {
        cat /config/mnemonic
        echo "${WALLET_PASSWORD}"
        echo "${WALLET_PASSWORD}"
    } | rusk-wallet restore || handle_error "Failed to restore wallet"
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
    } | rusk-wallet export -d /opt/dusk/conf -n consensus.keys || handle_error "Failed to export consensus keys"
    echo "Consensus keys exported successfully"

    # Set up consensus password as environment variable
    echo "Setting up consensus password environment variable..."
    echo "${CONSENSUS_KEY_PASSWORD}" | sh /opt/dusk/bin/setup_consensus_pwd.sh || handle_error "Failed to set consensus password"
    echo "Consensus password environment variable set successfully"
fi

# Start Rusk node
echo "Starting Rusk node..."
exec /opt/dusk/bin/rusk
