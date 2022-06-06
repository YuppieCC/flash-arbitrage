// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/console.sol";
import {SafeMath} from "./library/SafeMath.sol";
import {Ownable} from "./library/Ownable.sol";
import {IFlashLoanSimpleReceiver} from './interfaces/IFlashLoanSimpleReceiver.sol';
import {IPoolAddressesProvider} from './interfaces/IPoolAddressesProvider.sol';
import {IPool} from './interfaces/IPool.sol';
import {IERC20} from "./interfaces/IERC20.sol";
import {IUniswapV2Router01} from "./interfaces/IUniswapV2Router01.sol";
import {ISwapRouter} from "./interfaces/ISwapRouter.sol";


contract GoLoan is IFlashLoanSimpleReceiver, Ownable{
    IUniswapV2Router01 quickswapRouter;
    ISwapRouter uniswapRouter;
    using SafeMath for uint;
    
    IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    IPool public immutable override POOL;
    uint16 public defaultReferralCode = 0;
    uint256 public defaultPremium = 0.09 * 1e18;

    // Quickswap
    // address public UniswapV2Router02 = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address public QuickswapRouter = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    // Uniswap
    address public SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    address public swapInToken;
    address public swapOutToken;

    constructor(IPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        POOL = IPool(provider.getPool());
    }

    function getBalanceInternal(address _reserve) internal view returns(uint256) {
        return IERC20(_reserve).balanceOf(address(this));
    }

    function setQuickswapRouter(address _router) public {
        quickswapRouter = IUniswapV2Router01(_router);
        emit SetQuickswapRouter(_router);
    }

    function setUniswapRouter(address _router) public {
        uniswapRouter = ISwapRouter(_router);
        emit SetUniswapRouter(_router);
    }

    function quickswapTrade(address swapIn, address swapOut, uint amount) internal {
        address[] memory path = new address[](2);
        path[0] = swapIn;
        path[1] = swapOut;
        IERC20(swapIn).approve(address(quickswapRouter), amount);
        uint[] memory amounts = quickswapRouter.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        require(amounts[1] > 0, "Quickswap trade failed");
    }

    function uniswapTrade(address swapIn, address swapOut, uint amount) internal {
        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: swapIn,
            tokenOut: swapOut,
            fee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
            
        IERC20(swapIn).approve(address(uniswapRouter), amount);
        uint finalAmounts = uniswapRouter.exactInputSingle(swapParams);
        require(finalAmounts > 0, "Uniswap trade failed");
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        console.log("GoLoanContract Balance: ", getBalanceInternal(asset));
        require(amount <= getBalanceInternal(asset), "Invalid balance");

        uint approveNum =  premium.add(amount);
        console.log("GoLoanContract approveNum: ", approveNum);

        uint beforeSwapOutTokenBalance =  IERC20(swapOutToken).balanceOf(address(this));
        quickswapTrade(asset, swapOutToken, amount);
        uint afterSwapOutTokenBalance = IERC20(swapOutToken).balanceOf(address(this));
        uint diffSwapOutTokenAmount = afterSwapOutTokenBalance.sub(beforeSwapOutTokenBalance);
        console.log("beforeSwapOutTokenBalance", beforeSwapOutTokenBalance);
        console.log("afterSwapOutTokenBalance", afterSwapOutTokenBalance);
        console.log("diffSwapOutTokenAmount", diffSwapOutTokenAmount);

        uniswapTrade(swapOutToken, asset, diffSwapOutTokenAmount);
        // approve the repay assets 
        IERC20(asset).approve(address(POOL), approveNum);
        ExecuteOperationEvent(asset, amount, premium, initiator, params);
        return true;
  }

    function execute(address _swapInToken, uint _swapInAmount, address _swapOutToken) public onlyOwner {
        swapInToken = _swapInToken;
        // swapInAmount = _swapInAmount;
        swapOutToken = _swapOutToken;

        bytes memory data = "";
        POOL.flashLoanSimple(address(this), _swapInToken, _swapInAmount, data, defaultReferralCode);
    }

    event ExecuteOperationEvent(address asset, uint256 amount, uint256 premium, address initiator, bytes params);
    event SetQuickswapRouter(address newRouter);
    event SetUniswapRouter(address newRouter);
}
