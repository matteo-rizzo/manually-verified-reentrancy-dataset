/**
 *Submitted for verification at Etherscan.io on 2021-07-31
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;









interface WethLike is ERC20Like {
    function deposit() external payable;
}





contract Arb {
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant LUSD = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;    
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    UniswapLens constant LENS = UniswapLens(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    UniswapRouter constant ROUTER = UniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    UniswapReserve constant USDCETH = UniswapReserve(0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8);
    uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
    CurveLike constant CURV = CurveLike(0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA);

    constructor() public {
        ERC20Like(USDC).approve(address(CURV), uint(-1));
    }

    function approve(address bamm) external {
        ERC20Like(LUSD).approve(address(bamm), uint(-1));
    }

    function getPrice(uint wethQty) external returns(uint) {
        return LENS.quoteExactInputSingle(WETH, USDC, 3000, wethQty, 0);
    }

    function swap(uint ethQty, address bamm) external payable returns(uint) {
        bytes memory data = abi.encode(bamm);
        USDCETH.swap(address(this), false, int256(ethQty), MAX_SQRT_RATIO - 1, data);

        uint retVal = address(this).balance;
        msg.sender.transfer(retVal);

        return retVal;
     }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        require(msg.sender == address(USDCETH), "uniswapV3SwapCallback: invalid sender");
        // swap USDC to LUSD
        uint USDCAmount = uint(-1 * amount0Delta);
        uint LUSDReturn = CURV.exchange_underlying(2, 0, USDCAmount, 1);

        address bamm = abi.decode(data, (address));
        BAMMLike(bamm).swap(LUSDReturn, 1, address(this));

        if(amount1Delta > 0) {
            WethLike(WETH).deposit{value: uint(amount1Delta)}();
            if(amount1Delta > 0) WethLike(WETH).transfer(msg.sender, uint(amount1Delta));            
        }
    }

    receive() external payable {}
}

contract ArbChecker {
    Arb immutable public arb;
    constructor(Arb _arb) public {
        arb = _arb;
    }

    function checkProfitableArb(uint ethQty, uint minProfit, address bamm) public { // revert on failure
        uint balanceBefore = address(this).balance;
        arb.swap(ethQty, bamm);
        uint balanceAfter = address(this).balance;
        require((balanceAfter - balanceBefore) >= minProfit, "min profit was not reached");
    }

    receive() external payable {}       
}