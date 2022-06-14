// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "ds-test/cheatcodes.sol";
import "ds-test/console.sol";
import "ds-test/test.sol";
import {FlashArbitrage} from "../FlashArbitrage.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPoolAddressesProvider} from '../interfaces/IPoolAddressesProvider.sol';
import {UniswapWrapper} from '../UniswapWrapper.sol';
import {QuickswapWrapper} from '../QuickswapWrapper.sol';
import {SushiswapWrapper} from '../SushiswapWrapper.sol';

contract FlashArbitrageTest is DSTest {
    UniswapWrapper uniswapWrapper;
    QuickswapWrapper quickswapWrapper;
    SushiswapWrapper sushiswapWrapper;
    FlashArbitrage flashArbitrage;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    
    uint public testAmount = 30e6;
    address public sam = 0xAF838230fc2E832798ae88fa107C465F7F6Cfd13;
    address public PoolAddressesProvider = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;

    address public UniswapV2Router02 = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address public SwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public amUSDC = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address public WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public WETH = 0x25788a1a171ec66Da6502f9975a15B609fF54CF6;
    address public DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address public LINK = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;

    // quickswap
    address public QuickswapRouter = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    // Uniswap
    address public UniwapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // Sushiswap
    address public SushiswapRouter = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    function setUp() public {
        uniswapWrapper = new UniswapWrapper();
        sushiswapWrapper = new SushiswapWrapper();
        quickswapWrapper = new QuickswapWrapper();
        uniswapWrapper.setRouter(UniwapRouter);
        quickswapWrapper.setRouter(QuickswapRouter);
        sushiswapWrapper.setRouter(SushiswapRouter);

        console.log("uniswapWrapper address", address(uniswapWrapper));
        console.log("quickswapWrapper address", address(quickswapWrapper));
        console.log("sushiswapWrapper address", address(sushiswapWrapper));

        flashArbitrage = new FlashArbitrage(PoolAddressesProvider);
        flashArbitrage.setWrapperMap("uniswap", address(uniswapWrapper));
        flashArbitrage.setWrapperMap("quickswap", address(quickswapWrapper));
        flashArbitrage.setWrapperMap("sushiswap", address(sushiswapWrapper));

        uniswapWrapper.setSwapCaller(address(flashArbitrage));
        quickswapWrapper.setSwapCaller(address(flashArbitrage));
        sushiswapWrapper.setSwapCaller(address(flashArbitrage));

        cheats.prank(address(sam));
        IERC20(USDC).approve(address(this), testAmount);
        cheats.prank(address(sam));
        IERC20(USDC).transfer(address(this), testAmount);

        IERC20(USDC).approve(address(flashArbitrage), testAmount);
        flashArbitrage.deploy(USDC, 10e6);
        console.log("FlashArbitrage USDC:", IERC20(USDC).balanceOf(address(flashArbitrage)));
    }

    function testDeployWithdraw() public {
        cheats.prank(address(sam));
        IERC20(USDC).approve(address(this), 1e6);
        cheats.prank(address(sam));
        IERC20(USDC).transfer(address(this), 1e6);

        IERC20(USDC).approve(address(flashArbitrage), 1e6);
        flashArbitrage.deploy(USDC, 1e6);

        flashArbitrage.withdraw(USDC, 1e6);
    }

    function testFlashArbitrage() public {
        uint lastBalance = IERC20(USDC).balanceOf(address(flashArbitrage));
        console.log("FlashArbitrage last Balance", lastBalance);
        flashArbitrage.execute(
            'uniswap',
            'sushiswap',
            USDC, 
            WMATIC, 
            20e6
        );
        uint NowBalance = IERC20(USDC).balanceOf(address(flashArbitrage));
        
        console.log("FlashArbitrage Now Balance", NowBalance);
    }
    
}
