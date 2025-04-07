pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
}



contract GexCryptoIco is owned {

    uint public saleStart;
    uint public saleEnd;
    uint256 public minInvestment;

    function GexCryptoIco() {
        saleStart = 1517301413;
        saleEnd = 1519862400;
        minInvestment = (1/10) * (10 ** 18);
    }

    event EtherTransfer(address indexed _from,address indexed _to,uint256 _value);

    function changeMinInvestment(uint256 _minInvestment) onlyOwner {
        minInvestment = _minInvestment;
    }

    function withdrawEther(address _account) onlyOwner payable returns (bool success) {
        require(_account.send(this.balance));

        EtherTransfer(this, _account, this.balance);
        return true;
    }

    function destroyContract() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    function () payable {
        if (saleStart < now && saleEnd > now) {
            require(msg.value >= minInvestment);
        } else {
            revert();
        }
    }

}