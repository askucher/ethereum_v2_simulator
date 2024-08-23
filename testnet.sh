#!/usr/bin/env bash

# Enable debug output
set -x

# Load environment settings
CURRENT_DIR=$(pwd)
source "$CURRENT_DIR/env.sh"

# Set up data directories
DATA_DIR=$(create_data_dir_for_network)
JWT_TOKEN="$DATA_DIR/jwtsecret"
create_jwt_token "$JWT_TOKEN"

# Path to genesis.json
GENESIS_FILE="$NETWORK_DIR/genesis.json"

# Start Anvil node with genesis.json
ANVIL="anvil"
L1_DEV_PORT=8545
L1_CHAIN_ID=1337

# Debugging information
echo "Starting Anvil..."
echo "$ANVIL --fork-url http://localhost:8545 --port $L1_DEV_PORT --chain-id $L1_CHAIN_ID --init $GENESIS_FILE"

echo "$ANVIL --fork-url http://localhost:8545 --port $L1_DEV_PORT --chain-id $L1_CHAIN_ID --init $GENESIS_FILE" > local-node.sh

chmod +x local-node.sh
pm2 start local-node.sh
echo "Anvil is running on port $L1_DEV_PORT with chain ID $L1_CHAIN_ID and genesis file $GENESIS_FILE."

# Run the Nimbus Beacon Node
BEACON_NODE_BINARY="$BUILD_DIR/nimbus-eth2/build/nimbus_beacon_node"
NETWORK_CONFIG="$NETWORK_DIR/config.toml"

# Debugging information
echo "Starting Nimbus Beacon Node..."
echo "$BEACON_NODE_BINARY --config-file=$NETWORK_CONFIG --init=$GENESIS_FILE --jwt-secret=$JWT_TOKEN"

"$BEACON_NODE_BINARY" --config-file="$NETWORK_CONFIG" --init="$GENESIS_FILE" --jwt-secret="$JWT_TOKEN" &
echo "Beacon chain node is running with config file $NETWORK_CONFIG and genesis file $GENESIS_FILE."

# Monitor logs (example, can be customized)
pm2 logs local-node.sh
