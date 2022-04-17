// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/console.sol";
import {Ownable} from "./library/Ownable.sol";
import {IFlashLoanSimpleReceiver} from './interfaces/IFlashLoanSimpleReceiver.sol';
import {IPoolAddressesProvider} from './interfaces/IPoolAddressesProvider.sol';
import {IPool} from './interfaces/IPool.sol';
import {IERC20} from "./interfaces/IERC20.sol";


contract GoLoan is IFlashLoanSimpleReceiver, Ownable{
    IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    IPool public immutable override POOL;
    uint16 public defaultReferralCode = 0;
    uint256 public defaultPremium = 0.09 * 1e18;

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
      uint approveNum =  getBalanceInternal(asset) + premium;
      IERC20(asset).approve(address(POOL), approveNum);
      // TODO

      return true;
  }

    function flashLoanSimple(address _asset, uint amount) public onlyOwner {
        bytes memory data = "";
        POOL.flashLoanSimple(address(this), _asset, amount, data, defaultReferralCode);
    }
     
}
