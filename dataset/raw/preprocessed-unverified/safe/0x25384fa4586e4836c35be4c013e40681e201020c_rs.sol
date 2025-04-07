pragma solidity ^0.4.13;





contract DemoUSDPricedCrowdsale is Ownable {

        using SafeMath for uint256;

        /* the number of tokens already sold through this contract*/
        uint256 public tokensSold = 0;

        /* How many wei of funding we have raised */
        uint256 public weiRaised = 0;
        uint256 public centsRaised = 0;

        uint256 public centsPerEther = 30400;
        uint256 public bonusPercent = 0;
        uint256 public centsPerToken = 30;
        uint256 public debugLatestPurchaseCentsValue;

        address public wallet;

        ERC20Basic tokenContract;

        event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

        event EventCentsPerEtherChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);
        event EventCentsPerTokenChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);
        event EventBonusPercentChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);
        event ChangeWallet(address _oldWallet, address _newWallet);


        function DemoUSDPricedCrowdsale(
                uint256 _centsPerEther,
                uint256 _centsPerToken,
                address _tokenContract,
                address _wallet
        ) {
                require(_centsPerEther > 0);
                require(_centsPerToken > 0);
                require(_tokenContract != 0x0);
                require(_wallet != 0x0);

                centsPerEther = _centsPerEther;
                centsPerToken = _centsPerToken;
                tokenContract = ERC20Basic(_tokenContract);
                wallet = _wallet;
        }

        function setCentsPerEther(uint256 _centsPerEther) onlyOwner {
                require(_centsPerEther > 0);
                uint256 oldCentsPerEther = centsPerEther;
                centsPerEther = _centsPerEther;
                EventCentsPerEtherChanged(oldCentsPerEther, centsPerEther);
        }

        function setCentsPerToken(uint256 _centsPerToken) onlyOwner {
                require(_centsPerToken > 0);
                uint256 oldCentsPerToken = centsPerToken;
                centsPerToken = _centsPerToken;
                EventCentsPerTokenChanged(oldCentsPerToken, centsPerToken);
        }

        function setBonusPercent(uint256 _bonusPercent) onlyOwner {
                require(_bonusPercent > 0);
                uint256 oldBonusPercent = _bonusPercent;
                bonusPercent = _bonusPercent;
                EventBonusPercentChanged(oldBonusPercent, bonusPercent);
        }

        function changeWallet(address _wallet) onlyOwner {
                require(_wallet != 0x0);
                address oldWallet = _wallet;
                wallet = _wallet;
                ChangeWallet(oldWallet, wallet);
        }

        // fallback function can be used to buy tokens
        function () payable {
                buyTokens(msg.sender);
        }

        // low level token purchase function
        function buyTokens(address beneficiary) payable {
                require(beneficiary != 0x0);
                require(msg.value != 0);

                uint256 weiAmount = msg.value;
                uint256 centsAmount = weiAmount.mul(centsPerEther).div(1E18);
                debugLatestPurchaseCentsValue = centsAmount;
                // calculate token amount to be created

                uint256 tokens = centsAmount.div(centsPerToken).mul(getBonusCoefficient()).div(100);

                // update state
                weiRaised = weiRaised.add(weiAmount);
                weiRaised = centsAmount.add(weiAmount);

                tokenContract.transfer(beneficiary, tokens);
                forwardFunds();
        }

        function getBonusCoefficient() constant returns (uint256) {
                return 100 + bonusPercent;
        }

        function forwardFunds() internal {
                wallet.transfer(msg.value);
        }

        function withdrawTokens(address where) onlyOwner {
                tokenContract.transfer(where, tokenContract.balanceOf(this));
        }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}