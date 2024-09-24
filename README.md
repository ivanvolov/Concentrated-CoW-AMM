# Concentrated-CoW-AMM

To support CoW DAO’s mission of protecting Ethereum users from MEV, we implemented a modification to the CoW AMM, which will help protect liquidity providers from MEV more efficiently.

## How it works

[Here is the article about the AMM](https://forum.cow.fi/t/introducing-concentrated-cow-amm-maximizing-capital-efficiency-and-returns-for-liquidity-providers/2571)

The last version works without oracle and relies on the helper function to generate orders.

[Here is the code for the oracle version which was described in the article](https://github.com/ivanvolov/Concentrated-CoW-AMM/tree/e075f9a4032fb9b2fd1b9e120b8bca7b76188083)

## Build

```shell
$ forge build
```

## Test

```shell
$ forge test
```

## Format

```shell
$ forge fmt
```