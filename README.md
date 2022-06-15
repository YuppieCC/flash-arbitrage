# Flash Arbitrage

## Overview

To reduce the cost and risk of arbitrage, I use FlashLoan for cross-protocol arbitrage so that I only need to pay the fees of FlashLoan to complete a series of transactions. It calls the `flashloansimple()` method from Aave's pool,  trades between the two platforms, and finally repays the fund to the pool. The entire operation is done within one transaction.


[![XozXKP.png](https://s1.ax1x.com/2022/06/15/XozXKP.png)](https://imgtu.com/i/XozXKP)

## Execute
When all contracts have been deployed, you can stake some assets to the contract, and call the `execute()` method to initiate transactions.

```solidity
flashArbitrage.deploy(USDC, 5e6);  # remember to approve assets
flashArbitrage.execute(
    'uniswap',     # buy WMATIC on Uniswap (using USDC)
    'sushiswap',   # sell WMATIC on Sushiswap (receive USDC)
    USDC,          # borrow USDC ( from AAVE )
    WMATIC,        # trade WMATIC
    100e6           # borrow amount, all-in one trade.
);
```

## Contracts

Name | Code | Address | Network
------------ | ------------- | ------------- | -------------
FlashArbitrage |[GitHub](https://github.com/YuppieCC/flash-arbitrage/blob/main/src/FlashArbitrage.sol)|[0x77F9E9036151B01eFB80B4D812a29504d674ad1C](https://polygonscan.com/address/0x77F9E9036151B01eFB80B4D812a29504d674ad1C) | Polygon
SushiswapWrapper |[GitHub](https://github.com/YuppieCC/flash-arbitrage/blob/main/src/SushiswapWrapper.sol)|[0xDB76397c6534DB87AFD5A40969076D49E2B703d0](https://polygonscan.com/address/0xDB76397c6534DB87AFD5A40969076D49E2B703d0) | Polygon
UniswapWrapper |[GitHub](https://github.com/YuppieCC/flash-arbitrage/blob/main/src/UniswapWrapper.sol)|[0xeee45d451eDaC60dAA703514deF979F3a1D3120B](https://polygonscan.com/address/0xeee45d451eDaC60dAA703514deF979F3a1D3120B) | Polygon
QuickswapWrapper |[GitHub](https://github.com/YuppieCC/flash-arbitrage/blob/main/src/QuickswapWrapper.sol)|[0xF22FEbD79Cd2b986d00549eBE91A836b686d2f65](https://polygonscan.com/address/0xF22FEbD79Cd2b986d00549eBE91A836b686d2f65) | Polygon

## Usage

```Shell

# Apply an ETHERSCAN_KEY: https://polygonscan.com/apis
# PRIVATE_KEY: Export from your Wallet
cp .env.example .env
make test

# if tests all passed, deploy all contracts.
# scripting is a way to declaratively deploy contracts using Solidity
# instead of using the more limiting and less user friendly `forge create`.
make scripting

# if scripting isn't ok, you can deploy a single contract at once time.
make deploy-contract DEPLOY_CONTRACT={DEPLOY_CONTRACT} CONSTRUCTOR_ARGS={CONSTRUCTOR_ARGS}
```
## Gas Reports

```
╭─────────────────────────┬─────────────────┬────────┬────────┬────────┬─────────╮
│ FlashArbitrage contract ┆                 ┆        ┆        ┆        ┆         │
╞═════════════════════════╪═════════════════╪════════╪════════╪════════╪═════════╡
│ Deployment Cost         ┆ Deployment Size ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ 1062691                 ┆ 5595            ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ Function Name           ┆ min             ┆ avg    ┆ median ┆ max    ┆ # calls │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ deploy                  ┆ 15509           ┆ 29741  ┆ 34486  ┆ 34486  ┆ 4       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ execute                 ┆ 456312          ┆ 456312 ┆ 456312 ┆ 456312 ┆ 1       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ executeOperation        ┆ 334736          ┆ 334736 ┆ 334736 ┆ 334736 ┆ 1       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setWrapperMap           ┆ 23434           ┆ 23434  ┆ 23434  ┆ 23434  ┆ 9       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ withdraw                ┆ 9881            ┆ 9881   ┆ 9881   ┆ 9881   ┆ 1       │
╰─────────────────────────┴─────────────────┴────────┴────────┴────────┴─────────╯
```
```
╭───────────────────────────┬─────────────────┬────────┬────────┬────────┬─────────╮
│ QuickswapWrapper contract ┆                 ┆        ┆        ┆        ┆         │
╞═══════════════════════════╪═════════════════╪════════╪════════╪════════╪═════════╡
│ Deployment Cost           ┆ Deployment Size ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ 634013                    ┆ 3185            ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ Function Name             ┆ min             ┆ avg    ┆ median ┆ max    ┆ # calls │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setRouter                 ┆ 44889           ┆ 44889  ┆ 44889  ┆ 44889  ┆ 5       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setSwapCaller             ┆ 22701           ┆ 22701  ┆ 22701  ┆ 22701  ┆ 5       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ swap                      ┆ 142884          ┆ 142884 ┆ 142884 ┆ 142884 ┆ 1       │
╰───────────────────────────┴─────────────────┴────────┴────────┴────────┴─────────╯
```
```
╭───────────────────────────┬─────────────────┬────────┬────────┬────────┬─────────╮
│ SushiswapWrapper contract ┆                 ┆        ┆        ┆        ┆         │
╞═══════════════════════════╪═════════════════╪════════╪════════╪════════╪═════════╡
│ Deployment Cost           ┆ Deployment Size ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ 719608                    ┆ 3771            ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ Function Name             ┆ min             ┆ avg    ┆ median ┆ max    ┆ # calls │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setRouter                 ┆ 44822           ┆ 44822  ┆ 44822  ┆ 44822  ┆ 5       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setSwapCaller             ┆ 22723           ┆ 22723  ┆ 22723  ┆ 22723  ┆ 5       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ swap                      ┆ 115224          ┆ 129438 ┆ 129438 ┆ 143653 ┆ 2       │
╰───────────────────────────┴─────────────────┴────────┴────────┴────────┴─────────╯
```
```
╭─────────────────────────┬─────────────────┬────────┬────────┬────────┬─────────╮
│ UniswapWrapper contract ┆                 ┆        ┆        ┆        ┆         │
╞═════════════════════════╪═════════════════╪════════╪════════╪════════╪═════════╡
│ Deployment Cost         ┆ Deployment Size ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ 641936                  ┆ 3135            ┆        ┆        ┆        ┆         │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ Function Name           ┆ min             ┆ avg    ┆ median ┆ max    ┆ # calls │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setRouter               ┆ 22989           ┆ 22989  ┆ 22989  ┆ 22989  ┆ 5       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ setSwapCaller           ┆ 22790           ┆ 22790  ┆ 22790  ┆ 22790  ┆ 5       │
├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌┤
│ swap                    ┆ 142378          ┆ 143241 ┆ 143241 ┆ 144104 ┆ 2       │
╰─────────────────────────┴─────────────────┴────────┴────────┴────────┴─────────╯
```


