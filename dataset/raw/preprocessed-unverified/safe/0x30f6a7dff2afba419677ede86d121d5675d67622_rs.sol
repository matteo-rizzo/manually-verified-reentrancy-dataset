/**

 *Submitted for verification at Etherscan.io on 2018-10-16

*/



pragma solidity ^0.4.24;











/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title ERC20 interface

 */

contract ERC20 {

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

}





contract Crowdsale is Ownable {

    using SafeMath for uint256;



    address public multisig;



    ERC20 public token;



    uint rate;

    uint priceETH;



    mapping (address => bool) whitelist;



    event Purchased(address indexed _addr, uint _amount);



    function getRateCentUsd() public view returns(uint) {

        if (block.timestamp >= 1539550800 && block.timestamp < 1541019600) {

            return(70);

        }

        if (block.timestamp >= 1541019600 && block.timestamp < 1545685200) {

            return(100);

        }

    }



    function setPriceETH(uint _newPriceETH) external onlyOwner {

        setRate(_newPriceETH);

    }



    function setRate(uint _priceETH) internal {

        require(_priceETH != 0);

        priceETH = _priceETH;

        rate = getRateCentUsd().mul(1 ether).div(100).div(_priceETH);

    }



    function addToWhitelist(address _newMember) external onlyOwner {

        require(_newMember != address(0));

        whitelist[_newMember] = true;

    }



    function removeFromWhitelist(address _member) external onlyOwner {

        require(_member != address(0));

        whitelist[_member] = false;

    }



    function addListToWhitelist(address[] _addresses) external onlyOwner {

        for (uint i = 0; i < _addresses.length; i++) {

            whitelist[_addresses[i]] = true;

        }

    }



    function removeListFromWhitelist(address[] _addresses) external onlyOwner {

        for (uint i = 0; i < _addresses.length; i++) {

            whitelist[_addresses[i]] = false;

        }

    }



    function getPriceETH() public view returns(uint) {

        return priceETH;

    }



    constructor(address _DNT, address _multisig, uint _priceETH) public {

        require(_DNT != 0 && _priceETH != 0);

        token = ERC20(_DNT);

        multisig = _multisig;

        setRate(_priceETH);

    }



    function() external payable {

        buyTokens();

    }



    function buyTokens() public payable {

        require(whitelist[msg.sender]);

        require(block.timestamp >= 1539550800 && block.timestamp < 1545685200);

        require(msg.value >= 1 ether * 100 / priceETH);



        uint256 amount = msg.value.div(rate);

        uint256 balance = token.balanceOf(this);



        if (amount > balance) {

            uint256 cash = balance.mul(rate);

            uint256 cashBack = msg.value.sub(cash);

            multisig.transfer(cash);

            msg.sender.transfer(cashBack);

            token.transfer(msg.sender, balance);

            emit Purchased(msg.sender, balance);

            return;

        }



        multisig.transfer(msg.value);

        token.transfer(msg.sender, amount);

        emit Purchased(msg.sender, amount);

    }



    function finalizeICO(address _owner) external onlyOwner {

        require(_owner != address(0));

        uint balance = token.balanceOf(this);

        token.transfer(_owner, balance);

    }



    function getMyBalanceDNT() external view returns(uint256) {

        return token.balanceOf(msg.sender);

    }

}