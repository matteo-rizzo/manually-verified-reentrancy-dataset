pragma solidity ^0.4.21;







contract KeplerTokenCrowdsale is Ownable {

  using SafeMath for uint256;

    uint256 public TokensPerETH;
    token public tokenReward;
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    function KeplerTokenCrowdsale(
        uint256 etherPrice,
        address addressOfTokenUsedAsReward
    ) public {
        TokensPerETH = etherPrice * 150 / 125;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    function () payable public {
    	require(msg.value != 0);
        uint256 amount = msg.value;
        tokenReward.transfer(msg.sender, amount * TokensPerETH);
        emit FundTransfer(msg.sender, amount, true);
    }

    function changeEtherPrice(uint256 newEtherPrice) onlyOwner public {
        TokensPerETH = newEtherPrice * 150 / 125 ;
    }

    function withdraw(uint256 value) onlyOwner public {
        uint256 amount = value * 1 ether / 100;
        owner.transfer(amount);
        emit FundTransfer(owner, amount, false);
    }

    function withdrawTokens(address otherTokenAddress, uint256 amount) onlyOwner public {
        token otherToken = token(otherTokenAddress);
        otherToken.transfer(owner, amount);
    }

    function destroy() onlyOwner public {
        selfdestruct(owner);
    }
}