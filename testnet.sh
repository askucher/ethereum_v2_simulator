
#!/usr/bin/env bash

# Enable debug output
set -x

# Load environment settings
CURRENT_DIR=$(pwd)
source "$CURRENT_DIR/env.sh"

# Clean up any previous pm2 sessions for Anvil
pm2 delete local-node
pm2 flush


#Function to create a JWT token if it doesn't exist
create_jwt_token() {
  JWT_FILE="$1"
  if [ ! -f "$JWT_FILE" ]; then
    openssl rand -hex 32 | tr -d "\n" > "$JWT_FILE"
    echo "JWT token created at $JWT_FILE"
  else
    echo "JWT token already exists at $JWT_FILE"
  fi
}

# Set up data directories
DATA_DIR="$CURRENT_DIR/build/data/shared_local_0"
JWT_TOKEN="$DATA_DIR/jwtsecret"
create_jwt_token "$JWT_TOKEN"

# Path to genesis.json
GENESIS_FILE="$NETWORK_DIR/genesis.json"

# Start Anvil node with genesis.json
ANVIL="anvil"
L1_DEV_PORT=8545
L1_CHAIN_ID=1337

# Start Anvil with the provided settings
echo "Starting Anvil with genesis.json..."
$ANVIL --init $GENESIS_FILE --port $L1_DEV_PORT --chain-id $L1_CHAIN_ID --block-time 10 > local-node.sh
chmod +x local-node.sh
pm2 start local-node.sh
echo "Anvil is running on port $L1_DEV_PORT with chain ID $L1_CHAIN_ID and genesis file $GENESIS_FILE."

# Allow Anvil to fully start before starting Nimbus
sleep 5

# Path to the prebuilt Nimbus binary
BEACON_NODE_BINARY="$CURRENT_DIR/build/nimbus_beacon_node"
NETWORK_CONFIG="$NETWORK_DIR/config.toml"
WEB3_URL="http://127.0.0.1:8545"

echo "Starting Nimbus Beacon Node attached to Anvil..."
$BEACON_NODE_BINARY --web3-url=$WEB3_URL --jwt-secret=$JWT_TOKEN --config-file=$NETWORK_CONFIG --data-dir=$DATA_DIR --tcp-port=9000 --udp-port=9000 --rest --rest-port=5052 --metrics &
echo "Nimbus Beacon Node is running and attached to Anvil."

# Monitor logs (example, can be customized)
pm2 logs local-node.sh
