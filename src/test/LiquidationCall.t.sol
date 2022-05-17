// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "ds-test/cheatcodes.sol";
import "ds-test/console.sol";
import "ds-test/test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/IPool.sol";
import {ILendingPool} from "../interfaces/ILendingPool.sol";
import {ILendingPoolAddressesProvider} from "../interfaces/ILendingPoolAddressesProvider.sol";

contract LiquidationCallTest is DSTest {
    IPool pool;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address public sam = 0x6F82E3cc2a3d6b7A6d98e7941BCadd7f52919D53;
    address public AavePool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;  // USDC

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

    function testDeposit() public {
        address asset = USDC;
        uint256 amount = 5e6;
        address onBehalfOf = sam;
        uint16 referralCode = 0;
        
        uint beforeBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("beforeBalance", beforeBalance);

        cheats.prank(sam);
        IERC20(USDC).approve(address(pool), amount);

        cheats.prank(sam);
        pool.deposit(asset, amount, onBehalfOf, referralCode);

        uint afterBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("afterBalance", afterBalance);
    }

    function testBorrow() public {
        address asset = USDC;
        uint256 amount = 1e5;
        uint256 interestRateMode = 2;
        address onBehalfOf = sam;
        uint16 referralCode = 0;
        
        uint beforeBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("beforeBalance", beforeBalance);

        cheats.prank(sam);
        pool.borrow(asset, amount, interestRateMode, referralCode, onBehalfOf);

        uint afterBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("afterBalance", afterBalance);
    }

    function testWithdraw() public {
        address asset = USDC;
        uint256 amount = 1e6;
        address to = sam;

         uint beforeBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("beforeBalance", beforeBalance);

        cheats.prank(sam);
        pool.withdraw(asset, amount, to);

        uint afterBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("afterBalance", afterBalance);
    }

    function testRepay() public {
        address asset = USDC;
        uint256 amount = 1e5;
        uint256 interestRateMode = 2;
        address onBehalfOf = sam;
        uint16 referralCode = 0;
        
        uint beforeBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("beforeBalance", beforeBalance);

        cheats.prank(sam);
        pool.borrow(asset, amount, interestRateMode, referralCode, onBehalfOf);

        uint afterBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("afterBalance", afterBalance);

        // cheats.prank(sam);
        // IERC20(asset).approve(address(pool), amount);

        cheats.prank(sam);
        uint res = pool.repay(asset, amount, interestRateMode, onBehalfOf);
        console.log("res", res);

        uint afterRepayBalance = IERC20(USDC).balanceOf(address(sam));
        console.log("afterRepayBalance", afterRepayBalance);

    }
}
