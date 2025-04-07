/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.5.4;















contract VeganCrowdsale is Owned {

    using SafeMath for uint256;

    

    // Sets the owner

    constructor() public {

        owner = 0xc0Eda767a948f22c9a2f14570aCFeb1397cab6Be;

    }

    

    // Contract Variables

    address public tokenAddress = 0xFADe17a07ba3B480aA1714c3724a52D4C57d410E;     // Contract address for token

    uint256 public tokenDecimals = 8;

    uint256 public tokenPrice = 0;      // Price in WEI per token

    uint256 public endOfStage = 0;      // If greater than present then is active

    uint256 public currentBonus = 0;    // Amount in percent

    uint256 public stageAmount = 0;     // Maximum amount of tokens to be sold in stage

    

    // Set token Price

    function setTokenPrice(uint256 PriceInWei) public onlyOwner {

        tokenPrice = PriceInWei;

    }

    

    // Create Selling Stage

    function setSellingStage(uint256 bonus, uint256 amount, uint256 endTimestamp) public onlyOwner {

        currentBonus = bonus;

        stageAmount = amount * 10 ** tokenDecimals;

        endOfStage = endTimestamp;

    }

    

    // End Stage

    function endSelling() public onlyOwner {

        endOfStage = 0;

    }

    

    // Fallback function for purchasing token

    function () external payable {

        require(stageAmount > 0 || endOfStage > now);

        uint256 affordAmount = msg.value.div(tokenPrice);

        uint256 affordWithBonus = (affordAmount.mul(100 + currentBonus)).div(100);

        if (affordWithBonus <= stageAmount && affordWithBonus.mul(10 ** tokenDecimals) <= IERC20(tokenAddress).balanceOf(owner) && affordWithBonus.mul(10 ** tokenDecimals) <= IERC20(tokenAddress).allowance(owner, address(this))) {

            stageAmount.sub(affordWithBonus);

            IERC20(tokenAddress).transferFrom(owner, msg.sender, affordWithBonus.mul(10 ** tokenDecimals));

            owner.transfer(msg.value);

        } else {

            revert();

        }

    }

}