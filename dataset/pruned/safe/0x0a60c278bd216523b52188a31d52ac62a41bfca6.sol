/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

contract Presale {

    IERC20 public MFI;
    // these aren't ether, we're just using this for unit conversion
    uint public constant presaleSupply = 4_000_000 ether;
    // how much the presale has already issued
    uint public presaleIssued = 0;
    address public treasury;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint public startDate;
    uint public lastVestedQuarter;
    // 1_500_000 / 8
    uint public constant vestingQuarterly = 187_500 ether;

    // check for reentrancy
    bool disbursing;

    // initial best-guess ETH price
    uint constant initialDollarsPerETH = 1400;
    // updatable ETH price
    uint public dollarsPerETH = initialDollarsPerETH;
    uint public constant tokensPerDollar = 4;

    uint public constant maxPerWallet = 10 ether * initialDollarsPerETH * tokensPerDollar;

    constructor(IERC20 tokenContract, uint _startDate, address _treasury) public {
        MFI = tokenContract;
        treasury = _treasury;
        startDate = _startDate;
    }

    receive() external payable {
        // rule out reentrancy
        require(!disbursing, "No re-entrancy");
        disbursing = true;

        // check time constraints
        // after start date
        require(block.timestamp >= startDate, "Presale hasn't started yet");
        uint endDate = startDate + 2 days;
        // before end date
        require(endDate >= block.timestamp, "Presale is over");

        // calculate price
        // no overflow because scarcity
        uint tokensPerETH = dollarsPerETH * tokensPerDollar;
        // no overflow, again because scarcity
        uint tokensRequested = msg.value * tokensPerETH;

        // calculate how much the sender actually gets
        uint tokensToTransfer = min(tokensRequested, // price
                                    sub(presaleSupply, presaleIssued), // don't exceed supply
                                    sub(maxPerWallet, MFI.balanceOf(msg.sender))); // don't exceed wallet max

        // any eth that needs to go back
        uint ethReturn = sub(tokensRequested, tokensToTransfer) / tokensPerETH;
        if (ethReturn > 0) {
            // send it back
            payable(msg.sender).transfer(ethReturn);
        }

        // send eth to treasury and tokens to buyer
        payable(treasury).transfer(sub(msg.value, ethReturn));
        MFI.transferFrom(treasury, msg.sender, tokensToTransfer);
        disbursing = false;
    }

    // can be called by anyone to update the current price
    function setDollarsPerETH() external {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDC;
        dollarsPerETH = UniRouter(uniRouter).getAmountsOut(1 ether, path)[1] / 1 ether;
    }

    function min(uint a, uint b, uint c) internal pure returns (uint result) {
        // if a is smallest
        result = a;
        // if be is smaller
        if (result > b) {
            result = b;
        }
        // if c is even smaller
        if (result > c) {
            result = c;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction underflow");
        uint256 c = a - b;

        return c;
    }

    // send vested tokens back to treasury
    function withdrawVested() external {
        uint timeDiff = block.timestamp - startDate;
        uint quarter = timeDiff / (90 days);
        if (quarter > lastVestedQuarter) {
            MFI.transfer(treasury, vestingQuarterly);
            lastVestedQuarter = quarter;
        }
    }
}

