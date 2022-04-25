// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/console.sol";
import "ds-test/test.sol";
import "ds-test/cheatcodes.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IUniswapV2Router01} from "../interfaces/IUniswapV2Router01.sol";
import {ISwapRouter} from "../interfaces/ISwapRouter.sol";

contract UniswapRouterTest is DSTest {
    ISwapRouter uniswapRouter;
    IUniswapV2Router01 quickswapRouter;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address public SY = 0xAF838230fc2E832798ae88fa107C465F7F6Cfd13;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    // Uniswap
    address public SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public SwapRouter02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    // Quickswap
    address public UniswapV2Router02 = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    function setUp() public {
        uniswapRouter = ISwapRouter(SwapRouter);
        quickswapRouter = IUniswapV2Router01(UniswapV2Router02);
    }
    
    function testExample() public {
        assertTrue(true);
    }

    function testUniSwap() public {
        console.log("Last balance", IERC20(WETH).balanceOf(SY));

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: USDC,
            tokenOut: WETH,
            fee: 500,
            recipient: address(SY),
            deadline: block.timestamp+1000,
            amountIn: 1e6,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        
        cheats.prank(address(SY));
        IERC20(USDC).approve(address(uniswapRouter), 1e6);

        cheats.prank(address(SY));
        uint amounts = uniswapRouter.exactInputSingle(params);
        console.log("Get amounts", amounts);
        console.log("Now balance", IERC20(WETH).balanceOf(SY));
    }

    function testQuickSwap() public {
        console.log("before", IERC20(WMATIC).balanceOf(SY));
        uint amountIn = 1e6;
        address[] memory path = new address[](2);
        path[0] = address(USDC);
        path[1] = address(WMATIC);

        cheats.prank(address(SY));
        IERC20(USDC).approve(address(quickswapRouter), amountIn);

        cheats.prank(address(SY));
        uint[] memory amounts = quickswapRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(SY),
            block.timestamp
        );
        console.log("res", IERC20(WMATIC).balanceOf(SY));
    }
}
