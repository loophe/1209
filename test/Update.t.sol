// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../src/IERC20.sol";
interface IKashi {
    function updateExchangeRate() external returns (bool updated, uint256 rate) ;
    function totalBorrow() external returns (uint256 elastic, uint256 base);
}
interface IBox {
    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);
}

contract Update {

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public NMR = 0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671;

    address constant public Kashi = 0x7BEe2161AfA1aEe4466E77BED826a41D5A28DB46;//NMR
    // address constant public Kashi = 0x0d2606158fA76b38C5d58dB94B223C3BdCBbf57C;
    address constant public Box = 0xF5BCE5077908a1b7370B9ae04AdC565EBd643966;
    IKashi kashi;
    IBox box;
    function setUp() public {
        kashi = IKashi(Kashi);
        box = IBox(Box);
    }

    function testUpdate () public {
        kashi.updateExchangeRate();// 15175352
    }

    function testTotalBorrow () public {
        kashi.totalBorrow();//
    }

    function testAmount () public view {
        IERC20 token = IERC20(USDC);
        uint256 share = 155_994_466_100 * 1e13 * 75000;
        box.toAmount(token, share, false);
    }

}