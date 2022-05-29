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
    address public UniswapV2Router02 = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

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

        quickswapRouter = IUniswapV2Router01(UniswapV2Router02);
        address[] memory path = new address[](2);
        path[0] = asset;
        path[1] = swapOutToken;
        IERC20(asset).approve(address(quickswapRouter), amount);
        uint[] memory amounts = quickswapRouter.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint afterSwapOutToken = IERC20(swapOutToken).balanceOf(address(this));
        // uint diffSwapOutToken = sub(afterSwapOutToken, beforeSwapOutTokenBalance);
        uint diffSwapOutToken= afterSwapOutToken.sub(beforeSwapOutTokenBalance);
        console.log("beforeSwapOutTokenBalance", beforeSwapOutTokenBalance);
        console.log("afterSwapOutToken", afterSwapOutToken);
        console.log("diffSwapOutToken", diffSwapOutToken);
        uniswapRouter = ISwapRouter(SwapRouter);
        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: swapOutToken,
            tokenOut: asset,
            fee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: diffSwapOutToken,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        IERC20(swapOutToken).approve(address(uniswapRouter), diffSwapOutToken);
        uint finalAmounts = uniswapRouter.exactInputSingle(swapParams);
        console.log("swap final amount: ", finalAmounts);

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
     
}
