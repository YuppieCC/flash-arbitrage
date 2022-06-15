// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IPoolAddressesProvider} from 'src/interfaces/IPoolAddressesProvider.sol';
import {FlashArbitrage} from 'src/FlashArbitrage.sol';
import {QuickswapWrapper} from 'src/QuickswapWrapper.sol';
import {SushiswapWrapper} from 'src/SushiswapWrapper.sol';
import {UniswapWrapper} from 'src/UniswapWrapper.sol';
import 'forge-std/Script.sol';


contract DeployScript is Script {
    UniswapWrapper uniswapWrapper;
    QuickswapWrapper quickswapWrapper;
    SushiswapWrapper sushiswapWrapper;
    FlashArbitrage flashArbitrage;
    
    address public PoolAddressesProvider = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;

    // quickswap
    address public QuickswapRouter = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    // Uniswap
    address public UniwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // Sushiswap
    address public SushiswapRouter = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    function run() external {
        vm.startBroadcast();
        uniswapWrapper = new UniswapWrapper();
        sushiswapWrapper = new SushiswapWrapper();
        quickswapWrapper = new QuickswapWrapper();
        uniswapWrapper.setRouter(UniwapRouter);
        quickswapWrapper.setRouter(QuickswapRouter);
        sushiswapWrapper.setRouter(SushiswapRouter);

        flashArbitrage = new FlashArbitrage(PoolAddressesProvider);
        flashArbitrage.setWrapperMap("uniswap", address(uniswapWrapper));
        flashArbitrage.setWrapperMap("quickswap", address(quickswapWrapper));
        flashArbitrage.setWrapperMap("sushiswap", address(sushiswapWrapper));

        uniswapWrapper.setSwapCaller(address(flashArbitrage));
        quickswapWrapper.setSwapCaller(address(flashArbitrage));
        sushiswapWrapper.setSwapCaller(address(flashArbitrage));
    }
}
