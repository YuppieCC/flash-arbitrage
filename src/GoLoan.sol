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

    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

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
        uint beforeWMATIC =  IERC20(WMATIC).balanceOf(address(this));

        quickswapRouter = IUniswapV2Router01(UniswapV2Router02);
        address[] memory path = new address[](2);
        path[0] = asset;
        path[1] = WMATIC;
        IERC20(asset).approve(address(quickswapRouter), amount);
        uint[] memory amounts = quickswapRouter.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint afterWMATIC = IERC20(WMATIC).balanceOf(address(this));
        uint diffWMATIC = afterWMATIC - beforeWMATIC;
        console.log("beforeWMATIC", beforeWMATIC);
        console.log("afterWMATIC", afterWMATIC);
        console.log("diffWMATIC", diffWMATIC);
        uniswapRouter = ISwapRouter(SwapRouter);
        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: WMATIC,
            tokenOut: asset,
            fee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: diffWMATIC,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        IERC20(WMATIC).approve(address(uniswapRouter), diffWMATIC);
        uint finalAmounts = uniswapRouter.exactInputSingle(swapParams);
        console.log("swap final amount: ", finalAmounts);

        // approve the repay assets 
        IERC20(asset).approve(address(POOL), approveNum);
        ExecuteOperationEvent(asset, amount, premium, initiator, params);
        return true;
  }

    function flashLoanSimple(address _asset, uint amount) public onlyOwner {
        bytes memory data = "";
        POOL.flashLoanSimple(address(this), _asset, amount, data, defaultReferralCode);
    }

    event ExecuteOperationEvent(address asset, uint256 amount, uint256 premium, address initiator, bytes params);
     
}
