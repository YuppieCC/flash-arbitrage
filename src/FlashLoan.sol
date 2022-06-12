// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/console.sol";
import {SafeMath} from "./library/SafeMath.sol";
import {Ownable} from "./library/Ownable.sol";
import {IFlashLoanSimpleReceiver} from './interfaces/IFlashLoanSimpleReceiver.sol';
import {IPoolAddressesProvider} from './interfaces/IPoolAddressesProvider.sol';
import {IPool} from './interfaces/IPool.sol';
import {IERC20} from "./interfaces/IERC20.sol";
import {ISwapWrapper} from './interfaces/ISwapWrapper.sol';


contract FlashLoan is IFlashLoanSimpleReceiver, Ownable{
    using SafeMath for uint;
    
    IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    IPool public immutable override POOL;
    uint16 public referralCode = 0;

    mapping(string => address) public wrapperMap;

    constructor(IPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        POOL = IPool(provider.getPool());
    }

    function getBalanceInternal(address _reserve) internal view returns(uint256) {
        return IERC20(_reserve).balanceOf(address(this));
    }

    function setWrapperMap(string memory name, address wrapper) external onlyOwner {
        wrapperMap[name] = wrapper;
    }

    function setReferralCode(uint8 _referralCode) external onlyOwner {
        referralCode = _referralCode;
        emit SetReferralCode(_referralCode);
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
        (   
            address swapInProtocol,
            address swapOutProtocol,
            address _swapOutToken
        ) = abi.decode(params, (address, address, address));
        IERC20(asset).transfer(swapInProtocol, amount);
        uint diffOutAmount = ISwapWrapper(swapInProtocol).swap(asset, _swapOutToken, amount);
        IERC20(_swapOutToken).transfer(swapOutProtocol, diffOutAmount);
        uint resOutAmount = ISwapWrapper(swapOutProtocol).swap(_swapOutToken, asset, diffOutAmount);
        // approve the repay assets
        uint repayAmount =  premium.add(amount);
        IERC20(asset).approve(address(POOL), repayAmount);
        ExecuteOperationEvent(asset, amount, premium, initiator, params);
        return true;
  }

    function execute(
        string memory swapInWrapper, 
        string memory swapOutWrapper, 
        address InToken, 
        address OutToken, 
        uint amount
    ) external onlyOwner {
        bytes memory data = abi.encode(
            wrapperMap[swapInWrapper],
            wrapperMap[swapOutWrapper],
            OutToken
        );
        POOL.flashLoanSimple(address(this), InToken, amount, data, referralCode);
    }

    event ExecuteOperationEvent(address asset, uint256 amount, uint256 premium, address initiator, bytes params);
    event SetReferralCode(uint8 newReferralCode);
    event Deploy(address owner, address token, uint256 amount);
    event Withdrawn(address to, address token, uint256 amount);
}
