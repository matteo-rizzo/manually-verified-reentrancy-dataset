/**

 *Submitted for verification at Etherscan.io on 2018-09-03

*/



pragma solidity ^0.4.19;





















contract TokenInterface {

    function transfer(address to, uint256 value) public returns (bool);

}







contract ICO is Ownable {

    

    using SafeMath for uint256;

    

    uint256 public rate;

    uint256 public bonus; 

    

    TokenInterface public constant MEC = TokenInterface(0x064037ed6359c5d49a4ab6353345f46b687bbdd1);

    

    function ICO() public {

        rate = 2e7;

        bonus = 50;

    }

    

    function changeRate(uint256 _newRate) public onlyOwner {

        require(_newRate > 0 && rate != _newRate);

        rate = _newRate;

    }

    

    function changeBonus(uint256 _newBonus) public onlyOwner {

        require(_newBonus > 0 &&  bonus != _newBonus);

        bonus = _newBonus;

    }

    

    event TokenPurchase(address indexed investor, uint256 tokensPurchased);

    

    function buyTokens(address _investor) public payable {

        uint256 exchangeRate = rate;

        if(msg.value >= 1e17) {

            exchangeRate = rate.mul(bonus).div(100).add(rate);

        }

        MEC.transfer(_investor, msg.value.mul(exchangeRate));

        TokenPurchase(_investor, msg.value.mul(exchangeRate));

        owner.transfer(msg.value);

    }

    

    function() public payable {

        buyTokens(msg.sender);

    }

    

    event TokensWithdrawn(uint256 totalMEC);

    

    function withdrawMEC(uint256 _value) public onlyOwner {

        MEC.transfer(owner, _value);

        TokensWithdrawn(_value);

    }

}