// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TradingBot2.sol";
import "../src/IUniswapRouter.sol";
import "../src/IERC20.sol";
// import "../src/dYdX.sol";

contract TraderTest is Test {

    TradingBot2 public bot2;
    // DyDxFlashLoan public flashloan;

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public NMR = 0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671;

    address public routerV1 = 0x2Bf5A5bA29E60682fC56B2Fcf9cE07Bef4F6196f;

    IUniswapV1 swapV1 = IUniswapV1(routerV1);

    function setUp() public {
        bot2 = new TradingBot2();
        // flashloan = new DyDxFlashLoan();
    }

    function balanceOfThis(address _erc20TokenAddress) external view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        console.log("Executor final Token balance :", bal);
        return bal;   

    }

    function testTrader2() public {
        address b = address(bot2);
     
        console.log('bot address :',b);
    
        IFlashLoanRecipient bad = IFlashLoanRecipient(b);
        bytes memory data = hex"";
        
        // address multySig = 0x2632427EC9a89e28bc5E80D0b5aD31d486eC6956;
        // uint256 amount = 69 *10**22;
        // vm.prank(multySig);
        // IERC20(NMR).transfer(address(this), amount);
        // this.balanceOfThis(NMR);
        // uint theTime = block.timestamp + 8000;

        uint256 balanceBefore = address(this).balance;
        console.log('Before balance :', balanceBefore);

        // IERC20(NMR).approve(routerV1, uint256(2**256-1));
        // swapV1.tokenToEthSwapInput(uint(20 *10**20), uint(1 ether), theTime);
        // this.balanceOfThis(NMR);
        
        bot2.getFlashloan(bad, data);
        // uint256 balanceAfter = address(this).balance;
        // console.log('After balance :', balanceAfter);
    }

    receive()external payable {}

}