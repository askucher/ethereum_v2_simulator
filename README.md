# Ethereum 2.0 Testnet Setup with Anvil and Beacon Chain

## Overview

This repository contains scripts and tools to set up a local Ethereum 2.0 testnet using Anvil (from Foundry) and the Nimbus Beacon chain client. It includes:

- `testnet.sh`: The main script to launch Anvil and integrate it with the Nimbus Beacon chain.
- `local-node.sh`: A script generated by `testnet.sh` to start the Anvil node.
- `create_genesis.py`: A Python script to generate the genesis block from a list of Ethereum mainnet addresses.
- `genesis.json`: The genesis file created by `create_genesis.py`.

## Prerequisites

### Anvil (from Foundry)

Anvil is part of the Foundry toolchain, which is a fast and flexible Ethereum development environment. You can install it using the following commands:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

After installation, you can run `anvil` to start a local Ethereum testnet.

### Nimbus Beacon Chain Client

Nimbus is a Beacon chain client for Ethereum 2.0. Follow these steps to install and use Nimbus:

1. **Install Dependencies**:
   ```bash
   brew update
   brew install make openssl curl git
   ```

2. **Clone the Nimbus Repository**:
   ```bash
   git clone https://github.com/status-im/nimbus-eth2
   cd nimbus-eth2
   ```

3. **Build Nimbus**:
   ```bash
   make update
   make nimbus_beacon_node
   ```

4. **Create a Configuration File** (e.g., `config.toml`):
   ```toml
   [network]
     [network.eth1]
     enabled = true
     endpoints = ["http://localhost:8545"]

   log-level = "DEBUG"
   ```

5. **Run the Nimbus Beacon Node**:
   ```bash
   ./build/nimbus_beacon_node --config-file=config.toml --jwt-secret=path_to_jwt_secret_file
   ```

### Other Dependencies

- **Node.js** and **PM2**: Ensure Node.js and PM2 are installed on your system.
- **Python 3.x**: Required to run the `create_genesis.py` script.

## Usage

### 1. Generate the Genesis File

Replace the addresses in `create_genesis.py` with actual Ethereum mainnet addresses and run the script:

```bash
python3 create_genesis.py
```

This will generate a `genesis.json` file that will be used to launch your testnet.

### 2. Launch the Testnet

Run the `testnet.sh` script to start the Anvil node and the Nimbus Beacon chain:

```bash
bash testnet.sh
```

### 3. Monitoring and Logs

To view the logs of the Anvil node managed by PM2:

```bash
pm2 logs local-node.sh
```

### 4. Stopping the Services

To stop the Anvil node:

```bash
pm2 stop local-node.sh
```

## Customization

- **Chain ID and Ports**: Modify the `L1_CHAIN_ID` and `L1_DEV_PORT` variables in `testnet.sh` as per your requirements.
- **Beacon Chain Configuration**: Replace the placeholder command in `testnet.sh` with the actual command to start your Nimbus Beacon chain client.

## Troubleshooting

- **Anvil Not Starting**: Ensure that Foundry is correctly installed and that Anvil is available in your PATH.
- **Beacon Chain Issues**: Double-check the configuration and ensure the Beacon chain client is compatible with the setup.
