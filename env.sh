#!/usr/bin/env bash

# Stop execution on any errors and undefined variables
set -euo pipefail

# Directory of the scripts
SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")"
BUILD_DIR="$(cd "$SCRIPTS_DIR/../build" &> /dev/null && pwd)"
NETWORK_DIR="$(cd "$SCRIPTS_DIR/../network" &> /dev/null && pwd)"

# Ensure the required directories exist
mkdir -p "$BUILD_DIR"
mkdir -p "$NETWORK_DIR"

# Check Python version and install if necessary
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
else
    echo "Python 3 is already installed."
fi

# Verify Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
REQUIRED_PYTHON="3.6"

if [ "$(printf '%s\n' "$REQUIRED_PYTHON" "$PYTHON_VERSION" | sort -V | head -n1)" = "$REQUIRED_PYTHON" ]; then 
    echo "Python version $PYTHON_VERSION is installed."
else
    echo "Python version is lower than required. Please update Python to at least $REQUIRED_PYTHON."
    exit 1
fi

# Set up a Python virtual environment
VENV_DIR="$BUILD_DIR/venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"
echo "Python virtual environment activated."

# Install dependencies for Nimbus if not already installed
if ! command -v make &> /dev/null; then
    echo "Installing build dependencies..."
    sudo apt-get install -y build-essential libssl-dev curl git
fi

# Clone Nimbus repository if it doesn't exist
NIMBUS_DIR="$BUILD_DIR/nimbus-eth2"
if [ ! -d "$NIMBUS_DIR" ]; then
    echo "Cloning Nimbus repository..."
    git clone https://github.com/status-im/nimbus-eth2 "$NIMBUS_DIR"
fi

# Build Nimbus
cd "$NIMBUS_DIR"
make update
make nimbus_beacon_node

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
echo "SCRIPTS_DIR=$SCRIPTS_DIR"
echo "BUILD_DIR=$BUILD_DIR"
echo "NETWORK_DIR=$NETWORK_DIR"
echo "DATA_DIR=$(data_dir_for_network)"
echo "JWT_SECRET_FILE=$JWT_SECRET_FILE"
echo "Python version: $PYTHON_VERSION"
echo "Nimbus directory: $NIMBUS_DIR"
