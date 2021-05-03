#!/bin/bash
# Adapted from the official chia repository https://github.com/Chia-Network/chia-docker/

chia init

if [[ ${CHIA_MODE} == "harvester" ]]; then
    if [[ -z ${CHIA_FARMER_CA} ]]; then
        echo "A farmer CA is required. Set CHIA_FARMER_CA environmental variable"
        exit
    else
        if [[ -z "$(ls -A ${CHIA_FARMER_CA})" ]]; then
            echo "CA directory is empty. Provide the correct directory in CHIA_FARMER_CA"
            exit
        else
            chia init -c ${CHIA_FARMER_CA}
        fi
    fi
fi

# IPv6 bug for https://github.com/Chia-Network/chia-blockchain/issues/2265
sed -i 's/localhost/127.0.0.1/g' ~/.chia/mainnet/config/config.yaml

# Generate or recover the chia keys
if [[ ${CHIA_KEYS} == "generate" ]]; then
  chia keys generate
elif [[ ${CHIA_KEYS} == "keyring" ]]; then
    echo "Mount your Python keyring: -v ~/.local/share/python_keyring/:/root/.local/share/python_keyring/"
else
  chia keys add -f ${CHIA_KEYS}
  echo "Chia keys from the following directory added: ${CHIA_KEYS}"
fi

# Add plots
if [[ ! "$(ls -A /plots)" ]]; then
  echo "Plots directory appears to be empty and you have not specified another, try mounting a plot directory with the docker -v command "
fi

for i in $(echo ${CHIA_PLOTS} | sed "s/,/ /g")
do
    chia plots add -d $i
done

# Set log level
if [[ ${CHIA_LOGLEVEL} != "WARNING" ]]; then
    chia configure --set-log-level ${CHIA_LOGLEVEL}
    echo "Log level changed to ${CHIA_LOGLEVEL}"
else
    echo "Log level is ${CHIA_LOGLEVEL}"
fi

# Set operation mode
if [[ ${CHIA_MODE} == "farmer" ]]; then
    chia start farmer
elif [[ ${CHIA_MODE} == "harvester" ]]; then
    if [[ -z ${CHIA_FARMER_ADDRESS} || -z ${CHIA_FARMER_PORT} ]]; then
        echo "A farmer peer address and port are required"
        exit
    else
        chia configure --set-farmer-peer ${CHIA_FARMER_ADDRESS}:${CHIA_FARMER_PORT}
        chia start harvester
    fi
else
    echo "Choose an operation mode"
    exit
fi

exec "$@"