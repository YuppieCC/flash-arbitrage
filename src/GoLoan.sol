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
    address public QuickswapRouter = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    // Uniswap
    address public SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    address public swapInToken;
    address public swapOutToken;
    bool public isPositiveSide = true;

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

    function quickswapTrade(address swapIn, address swapOut, uint amount) internal returns (uint){
        address[] memory path = new address[](2);
        path[0] = swapIn;
        path[1] = swapOut;

        IERC20(swapIn).approve(address(quickswapRouter), amount);
        uint beforeSwapBalance = IERC20(swapOut).balanceOf(address(this));
        uint[] memory amounts = quickswapRouter.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint afterSwapBalance = IERC20(swapOut).balanceOf(address(this));
        uint swapAmount = afterSwapBalance.sub(beforeSwapBalance);
        require(swapAmount > 0, "Quickswap trade failed");
        return swapAmount;
    }

    function uniswapTrade(address swapIn, address swapOut, uint amount) internal returns (uint){
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
        uint beforeSwapBalance = IERC20(swapOut).balanceOf(address(this));
        uint finalAmounts = uniswapRouter.exactInputSingle(swapParams);
        uint afterSwapBalance = IERC20(swapOut).balanceOf(address(this));
        uint swapAmount = afterSwapBalance.sub(beforeSwapBalance);
        require(swapAmount > 0, "Uniswap trade failed");
        return swapAmount;
    }

    function deploy(address token, uint256 amount) public onlyOwner {
        require(token != address(0), "address cannot be 0");
        require(amount > 0, "Cannot stake 0");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Not enough tokens");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Deploy(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) public onlyOwner {
        require(token != address(0), "address cannot be 0");
        require(amount > 0, "Cannot withdraw 0");
        require(IERC20(token).balanceOf(address(this)) >= amount, "Not enough tokens");
        IERC20(token).transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, token, amount);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(amount <= getBalanceInternal(asset), "Invalid balance");
    
        if (isPositiveSide) {
            uint quickswapTradeAmount = quickswapTrade(asset, swapOutToken, amount);
            uint uniswapTradeAmount = uniswapTrade(swapOutToken, asset, quickswapTradeAmount);
            console.log("quickswapTradeAmount: ", quickswapTradeAmount);
            console.log("uniswapTradeAmount: ", uniswapTradeAmount);        
        } else {
            uint uniswapTradeAmount = uniswapTrade(asset, swapOutToken, amount);   
            uint quickswapTradeAmount = quickswapTrade(swapOutToken, asset, uniswapTradeAmount);
            console.log("uniswapTradeAmount: ", uniswapTradeAmount);        
            console.log("quickswapTradeAmount: ", quickswapTradeAmount);
        }

        // approve the repay assets
        uint repayAmount =  premium.add(amount);
        IERC20(asset).approve(address(POOL), repayAmount);
        ExecuteOperationEvent(asset, amount, premium, initiator, params);
        return true;
  }

    function execute(address _swapInToken, address _swapOutToken, uint _swapInAmount) external onlyOwner {
        swapInToken = _swapInToken;
        swapOutToken = _swapOutToken;

        bytes memory data = "";
        POOL.flashLoanSimple(address(this), _swapInToken, _swapInAmount, data, defaultReferralCode);
    }

    event ExecuteOperationEvent(address asset, uint256 amount, uint256 premium, address initiator, bytes params);
    event SetQuickswapRouter(address newRouter);
    event SetUniswapRouter(address newRouter);
    event Deploy(address owner, address token, uint256 amount);
    event Withdrawn(address to, address token, uint256 amount);
}
