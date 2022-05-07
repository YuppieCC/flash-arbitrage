// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "ds-test/cheatcodes.sol";
import "ds-test/console.sol";
import "ds-test/test.sol";
import {IPool} from "../interfaces/IPool.sol";
import {ILendingPool} from "../interfaces/ILendingPool.sol";
import {ILendingPoolAddressesProvider} from "../interfaces/ILendingPoolAddressesProvider.sol";

contract LiquidationCallTest is DSTest {
    IPool pool;

    address public sam = 0x6F82E3cc2a3d6b7A6d98e7941BCadd7f52919D53;
    address public AavePool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;

    function setUp() public {
        pool = IPool(AavePool);

    }

    function testExample() public {
        assertTrue(true);
    }

    function testGetUserAccountData() public {
        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = pool.getUserAccountData(sam);
        
        console.log("totalCollateralBase", totalCollateralBase);
        console.log("totalDebtBase", totalDebtBase);
        console.log("availableBorrowsBase", availableBorrowsBase);
        console.log("currentLiquidationThreshold", currentLiquidationThreshold);
        console.log("ltv", ltv);
        console.log("healthFactor", healthFactor);
    }
}
