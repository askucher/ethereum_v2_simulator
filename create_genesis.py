
import json

# Path to genesis.json and config.toml
genesis_json_path = 'network/genesis.json'
config_toml_path = 'network/config.toml'

# Example function to update genesis.json
def update_genesis_json():
    with open(genesis_json_path, 'r+') as file:
        genesis_data = json.load(file)
        # Ensure Chain ID is consistent
        genesis_data['config']['chainId'] = 1337
        file.seek(0)
        json.dump(genesis_data, file, indent=4)
        file.truncate()

# Example function to update config.toml
def update_config_toml():
    with open(config_toml_path, 'r+') as file:
        lines = file.readlines()
        for i, line in enumerate(lines):
            if 'chainId' in line:
                lines[i] = 'chainId = 1337
'
        with open(config_toml_path, 'w') as f:
            f.writelines(lines)

# Update both files
update_genesis_json()
update_config_toml()
