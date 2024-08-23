#!/usr/bin/env bash

# Stop execution on any errors and undefined variables
set -euo pipefail

# Set the working directory to the current directory
CURRENT_DIR=$(pwd)
BUILD_DIR="$CURRENT_DIR/build"
NETWORK_DIR="$CURRENT_DIR/network"

# Ensure the required directories exist
mkdir -p "$BUILD_DIR"
mkdir -p "$NETWORK_DIR"

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found, installing it..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Node.js if not already installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found, installing it..."
    brew install node
fi

# Install Git if not already installed
if ! command -v git &> /dev/null; then
    echo "Git not found, installing it..."
    brew install git
fi

# Install pm2 if not already installed
if ! command -v pm2 &> /dev/null; then
    echo "pm2 not found, installing it..."
    npm install -g pm2
fi

# Install Python 3 if not already installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Installing..."
    brew install python
fi

# Install CMake if not already installed
if ! command -v cmake &> /dev/null; then
    echo "CMake not installed. Installing..."
    brew install cmake
else
    echo "CMake is already installed."
fi

# Check if Nimbus Beacon Node binary already exists
NIMBUS_DIR="$BUILD_DIR/nimbus-eth2"
BEACON_NODE_BINARY="$NIMBUS_DIR/build/nimbus_beacon_node"

if [ ! -f "$BEACON_NODE_BINARY" ]; then
    echo "Nimbus Beacon Node binary not found, building Nimbus..."
    
    # Clone Nimbus repository if it doesn't exist
    if [ ! -d "$NIMBUS_DIR" ]; then
        echo "Cloning Nimbus repository..."
        git clone https://github.com/status-im/nimbus-eth2 "$NIMBUS_DIR"
    fi
    
    # Build Nimbus
    cd "$NIMBUS_DIR"
    make update
    make nimbus_beacon_node
else
    echo "Nimbus Beacon Node binary found, skipping build."
fi

# Function to manage data directories for the network
data_dir_for_network() {
  NETWORK_ID=$(cat "$NETWORK_DIR/genesis.json" | jq '.config.chainId')
  echo "$BUILD_DIR/data/$NETWORK_ID"
}

create_data_dir_for_network() {
  NETWORK_PATH=$(data_dir_for_network)
  mkdir -p "$NETWORK_PATH"
  echo "$NETWORK_PATH"
}

# Create the data directory if it doesn't exist
create_data_dir_for_network

# Function to create a JWT token if it doesn't exist
create_jwt_token() {
  JWT_FILE="$1"
  if [ ! -f "$JWT_FILE" ]; then
    openssl rand -hex 32 | tr -d "\n" > "$JWT_FILE"
    echo "JWT token created at $JWT_FILE"
  else
    echo "JWT token already exists at $JWT_FILE"
  fi
}

# Set up the JWT secret file
JWT_SECRET_FILE="$BUILD_DIR/jwtsecret"
create_jwt_token "$JWT_SECRET_FILE"

# Print out environment setup for confirmation
echo "CURRENT_DIR=$CURRENT_DIR"
echo "BUILD_DIR=$BUILD_DIR"
echo "NETWORK_DIR=$NETWORK_DIR"
echo "DATA_DIR=$(data_dir_for_network)"
echo "JWT_SECRET_FILE=$JWT_SECRET_FILE"
echo "Nimbus directory: $NIMBUS_DIR"
echo "Beacon Node Binary: $BEACON_NODE_BINARY"
