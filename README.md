# Concentrated-CoW-AMM

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

All contracts in this repo can be deployed and verified on the block explorer as follows:

```sh
export ETHERSCAN_API_KEY='your API key here'
PK='the private key of the deployer'
ETH_RPC_URL='https://rpc.node.url.here.example.com'
forge script 'script/DeployAllContracts.s.sol:DeployAllContracts' -vvvv --rpc-url "$ETH_RPC_URL" --private-key "$PK" --verify --broadcast
```

### Deployment addresses

The file [`networks.json`](./networks.json) lists all official deployments of the contracts in this repository by chain id.

The deployment address file is generated with:
```sh
bash dev/generate-networks-file.sh > networks.json
```
