#!/bin/bash
url="http://127.0.0.1:8200"
export VAULT_ADDR=$url
export VAULT_TOKEN=
project_name=$1
project_env=$2
#env_file_path=$3


# Check if Vault server is reachable
if curl --output /dev/null --silent --head -m 5 --fail "$url"; then

    # Attempt to fetch YAML data from Vault, redirecting stderr to /dev/null
    yaml_data=$(vault kv get -mount="$project_name" -format=yaml "$project_env" 2> /dev/null )

    # Check if the command was successful
    if [ $? -eq 0 ]; then

        # Extract only the data section using yq
        data_section=$(echo "$yaml_data" | yq eval '.data.data')
        
        # Convert YAML data to key=value format using awk
        env_data=$(echo "$data_section" | awk -F': ' '{gsub(/"/, "", $2); print $1 "=" $2 "\n"}')
        echo "$env_data"
    else
        # Fallback to .env.vault file if it exists and is not empty >>> token invaild or  expired
        if [ -s .env.vault ]; then
            cp .env.vault .env
            exit 0
	fi
    fi		
else
    # Vault server is not reachable
    # Fallback to .env.vault file if it exists and is not empty 
    if [ -s .env.vault ];then
        cp .env.vault .env
        exit 0
    fi
fi
