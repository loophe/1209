pragma solidity ^0.8.0;


// import "./Struct.sol";
import "./IERC20.sol";

interface IFlashLoanRecipient {
    /**
     * @dev When `flashLoan` is called on the Vault, it invokes the `receiveFlashLoan` hook on the recipient.
     *
     * At the time of the call, the Vault will have transferred `amounts` for `tokens` to the recipient. Before this
     * call returns, the recipient must have transferred `amounts` plus `feeAmounts` for each token back to the
     * Vault, or else the entire flash loan will revert.
     *
     * `userData` is the same value passed in the `IVault.flashLoan` call.
     */
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}
interface BalancerPool {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}


abstract contract BalancerFlashLoan is IFlashLoanRecipient {

    BalancerPool pool = BalancerPool(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    // address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address public SAI = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    // address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // mapping(address => uint256) public currencies;

    // constructor() public {
    //     currencies[WETH] = 1;
    //     currencies[SAI] = 2;
    //     currencies[USDC] = 3;
    //     currencies[DAI] = 4;
    // }

    modifier onlyPool() {
        require(
            msg.sender == address(pool),
            "FlashLoan: could be called by DyDx pool only"
        );
        _;
    }

    // function tokenToMarketId(address token) public view returns (uint256) {
    //     uint256 marketId = currencies[token];
    //     require(marketId != 0, "FlashLoan: Unsupported token");
    //     return marketId - 1;
    // }
    // the DyDx will call `callFunction(address sender, Info memory accountInfo, bytes memory data) public` after during `operate` call
    function flashloan(IFlashLoanRecipient bad, IERC20[] memory assets, uint256[] memory amounts, bytes memory data)
        internal
    {
        // uint _amount = uint(0);
        // // the amount to be flashed for each asset
        // uint256[] memory amounts = new uint256[](1);
        // amounts[0] = _amount ;
        // IERC20 weth = IERC20(WETH);
        // IERC20[] memory assets = new IERC20[](1);
        // assets[0] = weth;
        pool.flashLoan(bad, assets, amounts, data);
    }
}