#!/usr/bin/env bash

# Load environment settings
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

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

echo "$ANVIL --fork-url https://eth-sepolia-public.unifra.io --port $L1_DEV_PORT --chain-id $L1_CHAIN_ID --genesis $GENESIS_FILE" > local-node.sh

chmod +x local-node.sh
pm2 start local-node.sh
echo "Anvil is running on port $L1_DEV_PORT with chain ID $L1_CHAIN_ID and genesis file $GENESIS_FILE."

# Run the Nimbus Beacon Node
BEACON_NODE_BINARY="./build/nimbus_beacon_node"
NETWORK_CONFIG="$DATA_DIR/config.yaml"

"$BEACON_NODE_BINARY" --config-file="$NETWORK_CONFIG" --genesis="$GENESIS_FILE" --jwt-secret="$JWT_TOKEN" &
echo "Beacon chain node is running with config file $NETWORK_CONFIG and genesis file $GENESIS_FILE."

# Monitor logs (example, can be customized)
pm2 logs local-node.sh
