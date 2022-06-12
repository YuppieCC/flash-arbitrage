// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "ds-test/console.sol";
import "ds-test/test.sol";
import "ds-test/cheatcodes.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ISwapWrapper} from "../interfaces/ISwapWrapper.sol";
import {QuickwapWrapper} from "../QuickswapWrapper.sol";

contract QuickswapWrapperTest is DSTest {
    QuickwapWrapper swapWrapper;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address public SY = 0xAF838230fc2E832798ae88fa107C465F7F6Cfd13;
    address public sam = 0x6F82E3cc2a3d6b7A6d98e7941BCadd7f52919D53;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    // Quickswap
    address public router = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    function setUp() public {
        swapWrapper = new QuickwapWrapper();
        swapWrapper.setRouter(router);

        cheats.prank(address(sam));
        IERC20(USDC).approve(address(swapWrapper), 1e6);
        cheats.prank(address(sam));
        IERC20(USDC).transfer(address(swapWrapper), 1e6);
    }
    
    function testExample() public {
        assertTrue(true);
    }

    function testSwap() public {
        console.log("Last balance", IERC20(WMATIC).balanceOf(address(swapWrapper)));
        swapWrapper.swap(USDC, WMATIC, 1e6);
        console.log("Now balance", IERC20(WMATIC).balanceOf(address(swapWrapper)));
    }
}
