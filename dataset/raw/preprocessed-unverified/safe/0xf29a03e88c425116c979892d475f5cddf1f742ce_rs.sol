pragma solidity ^0.4.18;



/*
 * SafeMath - Math operations with safety checks that throw on error
 */


contract Crowdsale {
    using SafeMath for uint256;

    address public owner;
    uint256 public amountRaised;
    uint256 public amountRaisedPhase;
    uint256 public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /*
    * Throws if called by any account other than the owner
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /*
     * Constrctor function - setup the owner
     */
    function Crowdsale(
        address ownerAddress,
        uint256 weiCostPerToken,
        address rewardTokenAddress
    ) public {
        owner = ownerAddress;
        price = weiCostPerToken;
        tokenReward = token(rewardTokenAddress);
    }

    /*
     * Fallback function - called when funds are sent to the contract
     */
    function () public payable {
        uint256 amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        amountRaisedPhase = amountRaisedPhase.add(amount);
        tokenReward.transfer(msg.sender, amount.mul(10**4).div(price));
        FundTransfer(msg.sender, amount, true);
    }

    /*
     * Withdraw the funds safely
     */
    function safeWithdrawal() public onlyOwner {
        uint256 withdraw = amountRaisedPhase;
        amountRaisedPhase = 0;
        FundTransfer(owner, withdraw, false);
        owner.transfer(withdraw);
    }

    /*
     * Transfers the current balance to the owner and terminates the contract
     */
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
    function destroyAndSend(address _recipient) public onlyOwner {
        selfdestruct(_recipient);
    }
}