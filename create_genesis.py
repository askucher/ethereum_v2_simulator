import json
import os

# Define the genesis block configuration
genesis = {
    "config": {
        "chainId": 1337,
        "homesteadBlock": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0,
        "constantinopleBlock": 0,
        "petersburgBlock": 0,
        "istanbulBlock": 0,
        "muirGlacierBlock": 0,
        "berlinBlock": 0,
        "londonBlock": 0,
        "clique": {
            "period": 15,
            "epoch": 30000
        }
    },
    "nonce": "0x0",
    "timestamp": "0x5ba9e85c",
    "extraData": "0x00",
    "gasLimit": "0x2fefd8",
    "difficulty": "0x1",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {},
    "number": "0x0",
    "gasUsed": "0x0",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}

# Get the path to the network directory
current_dir = os.path.dirname(os.path.abspath(__file__))
network_dir = os.path.join(current_dir, 'network')

# Ensure the network directory exists
os.makedirs(network_dir, exist_ok=True)

# Path to genesis.json in the network directory
genesis_file_path = os.path.join(network_dir, 'genesis.json')

# Write the genesis block to genesis.json
with open(genesis_file_path, 'w') as genesis_file:
    json.dump(genesis, genesis_file, indent=4)
    print(f"Genesis block written to {genesis_file_path}")
