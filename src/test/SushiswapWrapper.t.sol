// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "ds-test/console.sol";
import "ds-test/test.sol";
import "ds-test/cheatcodes.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ISwapWrapper} from "../interfaces/ISwapWrapper.sol";
import {SushiswapWrapper} from "../SushiswapWrapper.sol";

contract SushiswapWrapperTest is DSTest {
    SushiswapWrapper swapWrapper;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address public sam = 0xAF838230fc2E832798ae88fa107C465F7F6Cfd13;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    // Sushiswap
    address public router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    function setUp() public {
        swapWrapper = new SushiswapWrapper();
        swapWrapper.setRouter(router);
        swapWrapper.setSwapCaller(address(this));

        cheats.prank(address(sam));
        IERC20(USDC).approve(address(swapWrapper), 1e6);
        cheats.prank(address(sam));
        IERC20(USDC).transfer(address(swapWrapper), 1e6);
    }
    
    function testExample() public {
        assertTrue(true);
    }

    function testSwap() public {
        uint beforeSwapBalance = IERC20(USDC).balanceOf(address(swapWrapper));
        swapWrapper.swap(USDC, WMATIC, 1e6);
        uint afterSwapBalance = IERC20(USDC).balanceOf(address(swapWrapper));
        assertGt(beforeSwapBalance, afterSwapBalance);
    }
}
