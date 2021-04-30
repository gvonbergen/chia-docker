# Chia Docker Container
This docker container provides a Chia farmer or harvester to deploy on a dedicated machine. It is an adaption from the official repository:
https://github.com/Chia-Network/chia-docker

## Basic Startup

### Farmer
Easiest set-up is to write your 24 word seed phrase into a file and give access to the docker container.

```bash
docker run -d \
    --name chia-farmer \
    -v /path/to/plots:/plots \
    -v /path/to/keyfile:/root/keyfile \
    -e CHIA_KEYS="/root/keyfile" \
    gvonbergen/chia-docker:latest
```
The path to the keyfile is "/path/to/keyfile" which has to be replaced by your actual storage location

Other option is to give access within the docker container to your python keyring. This you can use in cases where chia was already running on a machine and you have copied the file under ".local/share/python_keyring/" to your local machine.

```bash
docker run -d \
    --name chia-farmer \
    -v /path/to/plots:/plots \
    -v /path/to/python_keyring:/root/.local/share/python_keyring/ \
    -e CHIA_KEYS="keyring" \
    gvonbergen/chia-docker:latest
```

If you do not no provide the seed phrase or mount the keyring CHIA_KEYS="generate" is used and generates keys on the first run. You will see then your seed phrase and the corresponding public key fingerprint within the docker logs (docker logs chia-farmer)

```
No keys are present in the keychain. Generate them with 'chia keys generate'

To see your keys, run 'chia keys show'
Generating private key
Added private key with public key fingerprint 294601230 and mnemonic
parrot chase artwork acoustic select bronze sibling analyst found punch fruit pear ring guilt duck change cliff say dutch case ice color economy long
Setting the xch destination address for coinbase fees reward to xch1wp9zgjdrpujt7tpgyrg5fz0srgp5flsw9q0y8gejhvnep2cphnnqd4vcg5
Setting the xch destination address for coinbase reward to xch1wp9zgjdrpujt7tpgyrg5fz0srgp5flsw9q0y8gejhvnep2cphnnqd4vcg5
```

### Harvester

The harvester can be used if you have multiple machines where your plots are saved. Only one node needs to have the full farming set-up (node, farmer, harvester & wallet). Additional benefit is that you do not need the private keys on multiple machines.

Precondition is that:
- On the farmer port 8447 is opened and accessible
- The CA files from the farmer are copied to a local directory where the harvester will be running. They are available under "~/.chia/mainnet/config/ssl/ca"

```bash
docker run -d \
    --name chia-harvester \
    -v /path/to/plots:/plots \
    -v /path/to/ca:/root/ca \
    -e CHIA_MODE="harvester" \
    -e CHIA_FARMER_ADDRESS="192.168.1.5" \
    -e CHIA_FARMER_PORT="8774" \
    -e CHIA_FARMER_CA="/root/ca" \
    gvonbergen/chia-docker:latest
```

Here it is fine when the private key is generate during every run as it is not used for the harvester node anyway.

## Additional Configuration Options

If you need to incrase the log level (defalt is WARNING) then you can do this with the environment variable CHIA_LOGLEVEL.

Options are: CRITICAL|ERROR|WARNING|INFO|DEBUG|NOTSET

Within the container the logfile is situated under the configuration folder:
/config/mainnet/log/debug.log

## Manual Checks

The actual chia version
docker exec -it chia-farmer chia version

farming statistics
docker exec -it chia-farmer chia farm summary

Tail the logs:
docker exec -it chia-farmer tail -f /config/mainnet/log/debug.log

## Further Questions

For further questions consult the good resources from Chia itself:

The wiki: https://github.com/Chia-Network/chia-blockchain/wiki
An unofficial forum: https://chiaforum.com/