pragma solidity ^0.4.17;





contract ShizzleNizzle {
    function transfer(address _to, uint256 _amount) public returns(bool);
}

contract AirDropSHNZ is Ownable {

    using SafeMath for uint256;
    
    ShizzleNizzle public constant SHNZ = ShizzleNizzle(0x8b0C9f462C239c963d8760105CBC935C63D85680);

    uint256 public rate;

    function AirDropSHNZ() public {
        rate = 50000e8;
    }

    function() payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _addr) public payable returns(bool) {
        require(_addr != 0x0);
        SHNZ.transfer(msg.sender, msg.value.mul(rate).div(1e18));
        forwardFunds();
        return true;
    }

    function forwardFunds() internal {
        owner.transfer(this.balance);
    }

    function airDrop(address[] _addrs, uint256 _amount) public onlyOwner {
        require(_addrs.length > 0);
        for (uint i = 0; i < _addrs.length; i++) {
            if (_addrs[i] != 0x0) {
                SHNZ.transfer(_addrs[i], _amount.mul(100000000));
            }
        }
    }

    function issueTokens(address _beneficiary, uint256 _amount) public onlyOwner {
        require(_beneficiary != 0x0 && _amount > 0);
        SHNZ.transfer(_beneficiary, _amount.mul(100000000));
    }
}