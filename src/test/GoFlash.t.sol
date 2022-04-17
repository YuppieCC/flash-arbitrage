// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "ds-test/console.sol";
import "ds-test/test.sol";
import {GoLoan} from "../GoLoan.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract GoFlashTest is DSTest {
    GoLoan goLoan;
    address public LendingPoolAddressesProvider = 0xd05e3E715d945B59290df0ae8eF85c1BdB684744;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    function setUp() public {
        goLoan = new GoLoan(LendingPoolAddressesProvider);
    }

    function testExample() public {
        assertTrue(true);
    }

    function testFlashLoan() public {
        uint thisOldBalance =IERC20(USDC).balanceOf(address(this));
        console.log("thisOldBalance", thisOldBalance);
        goLoan.flashloan(USDC);
        uint thisNowBalance = IERC20(USDC).balanceOf(address(this));
        console.log("thisNowBalance", thisNowBalance);
    }
    
}
