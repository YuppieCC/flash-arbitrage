pragma solidity ^0.8.0;

import {Ownable} from "./library/Ownable.sol";
import {SafeMath} from "./library/SafeMath.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IUniswapV2Router01} from "./interfaces/IUniswapV2Router01.sol";
import {BaseWrapper} from './BaseWrapper.sol';

contract SushiswapWrapper is BaseWrapper {
    using SafeMath for uint;
    IUniswapV2Router01 sushiswapRouter;

    function setRouter(address _router) external override onlyOwner {
        router = _router;
        sushiswapRouter = IUniswapV2Router01(_router);
    }

    function swap(address swapIn, address swapOut, uint amount) external override onlyLoanOwner returns (uint) {
        address[] memory path = new address[](2);
        path[0] = swapIn;
        path[1] = swapOut;

        IERC20(swapIn).approve(address(sushiswapRouter), amount);
        uint beforeSwapBalance = IERC20(swapOut).balanceOf(address(this));
        uint[] memory amounts = sushiswapRouter.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint afterSwapBalance = IERC20(swapOut).balanceOf(address(this));
        uint swapAmount = afterSwapBalance.sub(beforeSwapBalance);
        
        IERC20(swapIn).transfer(msg.sender, IERC20(swapIn).balanceOf(address(this)));
        IERC20(swapOut).transfer(msg.sender, swapAmount);
        require(swapAmount > 0, "Sushiswap trade failed");
        emit Swap(swapIn, swapOut, swapAmount);
        return swapAmount;
    }

}