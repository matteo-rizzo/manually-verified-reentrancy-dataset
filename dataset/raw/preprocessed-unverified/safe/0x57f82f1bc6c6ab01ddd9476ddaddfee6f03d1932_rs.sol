pragma solidity ^0.4.18;





contract Presale {
    using SafeMath for uint256;
    
    Token public tokenContract;

    address public beneficiaryAddress;
    uint256 public tokensPerEther;
    uint256 public minimumContribution;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public hardcapInEther;
    uint256 public fundsRaised;
    

    mapping (address => uint256) public contributionBy;
    
    event ContributionReceived(address contributer, uint256 amount, uint256 totalContributions,uint totalAmountRaised);
    event FundsWithdrawn(uint256 funds, address beneficiaryAddress);

    function Presale(
        address _beneficiaryAddress,
        uint256 _tokensPerEther,
        uint256 _minimumContributionInFinney,
        uint256 _startTime,
        uint256 _saleLengthinHours,
        address _tokenContractAddress,
        uint256 _hardcapInEther) {
        startTime = _startTime;
        endTime = startTime + (_saleLengthinHours * 1 hours);
        beneficiaryAddress = _beneficiaryAddress;
        tokensPerEther = _tokensPerEther;
        minimumContribution = _minimumContributionInFinney * 1 finney;
        tokenContract = Token(_tokenContractAddress);
        hardcapInEther = _hardcapInEther * 1 ether;
    }

    function () public payable {
        require(presaleOpen());
        require(msg.value >= minimumContribution);
        uint256 contribution = msg.value;
        uint256 refund;
        if(this.balance > hardcapInEther){
            refund = this.balance.sub(hardcapInEther);
            contribution = msg.value.sub(refund);
            msg.sender.transfer(refund);
        }
        fundsRaised = fundsRaised.add(contribution);
        contributionBy[msg.sender] = contributionBy[msg.sender].add(contribution);
        tokenContract.mintTokens(msg.sender, contribution.mul(tokensPerEther));
        ContributionReceived(msg.sender, contribution, contributionBy[msg.sender], this.balance);
    }


    function presaleOpen() public view returns(bool) {return(now >= startTime &&
                                                            now <= endTime &&
                                                            fundsRaised < hardcapInEther);} 

    function withdrawFunds() public {
        require(this.balance > 0);
        beneficiaryAddress.transfer(this.balance);
        FundsWithdrawn(this.balance, beneficiaryAddress);
    }
}