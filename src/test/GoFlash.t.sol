// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "ds-test/cheatcodes.sol";
import "ds-test/console.sol";
import "ds-test/test.sol";
import {GoLoan} from "../GoLoan.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPoolAddressesProvider} from '../interfaces/IPoolAddressesProvider.sol';

contract GoFlashTest is DSTest {
    GoLoan goLoan;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    
    uint public testAmount = 3e6;
    address public sam = 0x6F82E3cc2a3d6b7A6d98e7941BCadd7f52919D53;
    address public PoolAddressesProvider = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;

    address public UniswapV2Router02 = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address public SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public amUSDC = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public WETH = 0x25788a1a171ec66Da6502f9975a15B609fF54CF6;
    address public DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address public LINK = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;

    function setUp() public {
        goLoan = new GoLoan(IPoolAddressesProvider(PoolAddressesProvider));

        cheats.prank(address(sam));
        IERC20(USDC).approve(address(this), testAmount);
        cheats.prank(address(sam));
        IERC20(USDC).transfer(address(this), testAmount);

        IERC20(USDC).approve(address(goLoan), testAmount);
        goLoan.deploy(USDC, 1e6);
        console.log("goLoan USDC:", IERC20(USDC).balanceOf(address(goLoan)));
    }

    function testDeployWithdraw() public {
        cheats.prank(address(sam));
        IERC20(USDC).approve(address(this), testAmount);
        cheats.prank(address(sam));
        IERC20(USDC).transfer(address(this), testAmount);

        IERC20(USDC).approve(address(goLoan), testAmount);
        goLoan.deploy(USDC, 1e6);

        goLoan.withdraw(USDC, 1e6);
    }

    function testFlashLoan() public {
        uint lastBalance = IERC20(USDC).balanceOf(address(goLoan));
        console.log("GoLoan last Balance", lastBalance);
        goLoan.setQuickswapRouter(UniswapV2Router02);
        goLoan.setUniswapRouter(SwapRouter);
        goLoan.execute(USDC, WMATIC, 1e6);
        uint NowBalance = IERC20(USDC).balanceOf(address(goLoan));
        
        console.log("GoLoan Now Balance", NowBalance);
    }
    
}
