/**
 *Submitted for verification at Etherscan.io on 2021-01-30
*/

pragma solidity ^0.6.0;







contract ThirmLP {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswap;

    uint256 public lastTimeExecuted;
    uint256 private constant TIME_OFFSET = 864000;

    address public constant OWNER = 0x170902c0dE4FEc18Ca5a70AD690DfEb1d5314dF0;
    address public constant THIRM = 0xb526FD41360c98929006f3bDcBd16d55dE4b0069;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant UNISWAP_V2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor() public {
        uniswap = IUniswapV2Router02(UNISWAP_V2);
        lastTimeExecuted = block.timestamp - TIME_OFFSET;
    }

    function initApproval() public {
        ERC20(THIRM).approve(UNISWAP_V2, uint256(~0));
        ERC20(USDC).approve(UNISWAP_V2, uint256(~0));
    }
    
    function kill(address inputcontract) public {
       uint256 inputcontractbal = ERC20(inputcontract).balanceOf(address(this));
       ERC20(inputcontract).transfer(OWNER, inputcontractbal);
    }

    function thirmAllowance() public view returns (uint256) {
        return ERC20(THIRM).allowance(address(this), UNISWAP_V2);
    }

    function usdcAllowance() public view returns (uint256) {
        return ERC20(USDC).allowance(address(this), UNISWAP_V2);
    }

    function timeForNextExecution() public view returns (uint256) {
        return lastTimeExecuted.add(TIME_OFFSET);
    }

    function start() public {
        require(
            lastTimeExecuted.add(TIME_OFFSET) < block.timestamp,
            "Cannot execute the start function."
        );

        // update timestamp
        lastTimeExecuted = block.timestamp;

        // Mint Thirm
        uint256 thirmTotalSupply = ERC20(THIRM).totalSupply();
        uint256 minted = thirmTotalSupply.div(1000);
        ERC20(THIRM).mint(address(this), minted);

        // Swap half thirm to USDC
        uint256 thirmBal = ERC20(THIRM).balanceOf(address(this));
        uint256 halfBal = thirmBal.div(2);
        address[] memory path = new address[](2);
        path[0] = THIRM;
        path[1] = USDC;
        uint256[] memory amountOutMin = uniswap.getAmountsOut(halfBal, path);
        uniswap.swapExactTokensForTokens(
            halfBal,
            amountOutMin[1],
            path,
            address(this),
            block.timestamp + 100
        );

        // Add liquidity (THIRM, DAI)
        uint256 thirmBalance = ERC20(THIRM).balanceOf(address(this));
        uint256 usdcBalance = ERC20(USDC).balanceOf(address(this));
        uniswap.addLiquidity(
            THIRM,
            USDC,
            thirmBalance,
            usdcBalance,
            0,
            0,
            address(this),
            block.timestamp + 100
        );
    }
}