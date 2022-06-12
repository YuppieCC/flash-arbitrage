pragma solidity ^0.8.0;

import {Ownable} from "./library/Ownable.sol";
import {SafeMath} from "./library/SafeMath.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IUniswapV3SwapRouter} from "./interfaces/IUniswapV3SwapRouter.sol";
import {BaseWrapper} from './BaseWrapper.sol';

contract UniswapWrapper is BaseWrapper {
    uint24 public fee = 500;
    IUniswapV3SwapRouter uniswapRouter;
    using SafeMath for uint;

    function setFee(uint24 _fee) external onlyOwner {
        fee = _fee;
    }

    function setRouter(address _router) external override onlyOwner {
        router = _router;
        uniswapRouter = IUniswapV3SwapRouter(_router);
    }

    function swap(address swapIn, address swapOut, uint amount) external override onlyLoanOwner returns (uint) {
        IUniswapV3SwapRouter.ExactInputSingleParams memory swapParams = IUniswapV3SwapRouter.ExactInputSingleParams({
            tokenIn: swapIn,
            tokenOut: swapOut,
            fee: fee,
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

        IERC20(swapIn).transfer(msg.sender, IERC20(swapIn).balanceOf(address(this)));
        IERC20(swapOut).transfer(msg.sender, swapAmount);
        require(swapAmount > 0, "Uniswap trade failed");
        emit Swap(swapIn, swapOut, swapAmount);
        return swapAmount;
    }

}