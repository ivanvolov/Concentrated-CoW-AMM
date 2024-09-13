# Concentrated-CoW-AMM

To support CoW DAO’s mission of protecting Ethereum users from MEV, we implemented a modification to the CoW AMM, which will help protect liquidity providers from MEV more efficiently.

## How it works

As we know the CoW AMM is a contract that stores reserves of two tokens and allows anyone to create orders between these two tokens on the CoW Protocol. It guarantees that despite the minimum viable order following the constant-product curve (xy = k) the surplus captured by the Protocol yields a better execution price and thus higher profits for liquidity providers.

But this version suffers from the same inefficiency as Uniswap V2, liquidity is distributed uniformly along the price curve between 0 and infinity. However, in many pools, the majority of the liquidity is never used because the price goes in some narrow range most of the time.

Consider stablecoin pairs, where the price of the two assets stays relatively constant. The liquidity outside the typical price range of a stablecoin pair is rarely touched. For example, the DAI/USDC pair utilizes ~0.50% of the total available capital for trading between $0.99 and $1.01.

With concentrated CoW AMM, liquidity providers may concentrate their capital to smaller price intervals than (0, ∞). In a stablecoin/stablecoin pair, for example, an LP may choose to allocate capital solely to the 0.99 - 1.01 range. As a result, traders are offered deeper liquidity around the mid-price, and LPs earn more trading fees with their capital.

## Active Liquidity

As the latest version of CoW AMM doesn't support pooling liquidity among different users at this point, the new Concentrated AMM is also not. So, it could be viewed as a single price range of concentrated liquidity for one user. And if the price is out of the range, the liquidity becomes inactive.

## Update Overview

If you are not familiar with classic CoW AMM design you should check out the docs [here](https://github.com/cowprotocol/cow-amm/blob/main/docs/amm.md), because next, I will only highlight the updates and not explain the design itself.

### Price boundaries
First of all, as now we are using concentrated liquidity, we added new parameters during the order creation:

- ```sqrtPriceUpper``` - the price upper bound of the AMM;
- ```sqrtPriceLower``` - the price lower bound of the AMM;
- ```sqrtPriceDeposit``` - the effective price of the liquidity provision, basically the last price of the  AMM during the initial liquidity provision.

> *Note*: It’s recommended to set ```sqrtPriceDeposit``` close to market price in order not to create an 
arbitrage opportunity. But the user can choose the deposit price and thus reserve proportion according to his own needs.

### Square root prices
As you can see we are not using relations-based price calculations based on price Denominator and price Numerator anymore. As we need to do concentrated liquidity math we need to deal with square root prices, so we will use them instead.

Also now the PriceOracle contract should return the sqrtPrice and not the price relations.

### New math library
We created a new library called Concentrated Math Library and put all mathematical functions related to the price, liquidity, and reserves calculations there in one place. It mostly utilizes thoroughly audited and battle-tested Uniswap V3 Tick Math library and Unsiwap V4 Liquidity Amounts library. You can find the code here.

### Order flow
As for solvers, Concentrated CoW AMM orders will also appear in the CoW Protocol orderbook automatically because we implemented ```getTradeableOrderWithSignature``` to return an order that can be traded in a way that tries to rebalance the AMM to align with the reference price of a price oracle. 

These orders are provided for convenience to CoW Swap solvers so that basic CoW AMM usage does not need any dedicated implementation to tap into its liquidity. More sophisticated solvers can create their own order to better suit the current market conditions.


### Post Hook
The important update is that now the solver also needs to call the ```postHook``` function after each swap. It will update the ```lastSqrtPrice``` and set it to the current trade price. This is crucial because now the reserves alone are not enough to determine the AMM condition and current liquidity, so we need to keep track of prices.

## Limitations and potential updates

As for now only Price Oracle based on the Uniswap V3 pool oracle is implemented. Also, you need to set up the AMM with tokens in order which is the same as the corresponding pool tokens order. We plan to implement Balancer and Chainlink-based oracles in the future. Although as mentioned above, the oracle should return the sqrt price, so the costly square root operation should be used in them.

The current setup doesn't support pooling liquidity among different users at this point. A new CCAMM instance needs to be deployed every time a user wants to provide liquidity for a pair. Also, one AMM could provide liquidity to only one price range, so the user needs to have a separate contract for every range.


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