pragma solidity ^0.8.0;

import {Ownable} from "./library/Ownable.sol";
import {SafeMath} from "./library/SafeMath.sol";
import {IERC20} from "./interfaces/IERC20.sol";

abstract contract BaseWrapper is Ownable {
    address public loanOwner;
    address public router;

    event Swap(address swapIn, address swapOut, uint amount);
    modifier onlyLoanOwner{
        require(msg.sender == loanOwner, "can not call this swap");
        _;
    }

    function setSwapCaller(address _loanOwner) external onlyOwner {
        loanOwner = _loanOwner;
    }
    
   
    function setRouter(address _router) external virtual;
    function swap(address swapIn, address swapOut, uint amount) external virtual returns (uint);

}