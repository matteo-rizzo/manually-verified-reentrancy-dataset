/**

 *Submitted for verification at Etherscan.io on 2019-02-27

*/



/**

 *  Liven crowdsale contract.

 *

 *  There is no ETH hard cap in this contract due to the fact that Liven are

 *  collecting funds in more than one currency. This contract is a single

 *  component of a wider sale. The hard cap for the entire sale is USD $28m.

 *

 *  This sale has a six week time limit which can be extended by the owner. It

 *  can be stopped at any time by the owner.

 *

 *  More information is available on https://livenpay.io.

 *

 *  Minimum contribution: 0.1 ETH

 *  Maximum contribution: 1000 ETH

 *  Minimum duration: 6 weeks from deployment

 *

 */



pragma solidity 0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract LivenSale is Ownable {



    using SafeMath for uint256;



    uint256 public maximumContribution = 1000 ether;

    uint256 public minimumContribution = 100 finney;

    uint256 public totalWeiRaised;

    uint256 public endTimestamp;

    uint256 public constant SIX_WEEKS_IN_SECONDS = 86400 * 7 * 6;



    bool public saleEnded = false;

    address public proceedsAddress;



    mapping (address => uint256) public weiContributed;



    constructor (address _proceedsAddress) public {

        proceedsAddress = _proceedsAddress;

        endTimestamp = block.timestamp + SIX_WEEKS_IN_SECONDS;

    }



    function () public payable {

        buyTokens();

    }



    function buyTokens () public payable {

        require(!saleEnded && block.timestamp < endTimestamp, "Campaign has ended. No more contributions possible.");

        require(msg.value >= minimumContribution, "No contributions below 0.1 ETH.");

        require(weiContributed[msg.sender] < maximumContribution, "Contribution cap already reached.");



        uint purchaseAmount = msg.value;

        uint weiToReturn;

        

        // Check max contribution

        uint remainingContributorAllowance = maximumContribution.sub(weiContributed[msg.sender]);

        if (remainingContributorAllowance < purchaseAmount) {

            purchaseAmount = remainingContributorAllowance;

            weiToReturn = msg.value.sub(purchaseAmount);

        }



        // Store allocation

        weiContributed[msg.sender] = weiContributed[msg.sender].add(purchaseAmount);

        totalWeiRaised = totalWeiRaised.add(purchaseAmount);



        // Forward ETH immediately to the multisig

        proceedsAddress.transfer(purchaseAmount);



        // Return excess ETH

        if (weiToReturn > 0) {

            address(msg.sender).transfer(weiToReturn);

        }

    }



    function extendSale (uint256 _seconds) public onlyOwner {

        endTimestamp += _seconds;

    }



    function endSale () public onlyOwner {

        saleEnded = true;

    }

}