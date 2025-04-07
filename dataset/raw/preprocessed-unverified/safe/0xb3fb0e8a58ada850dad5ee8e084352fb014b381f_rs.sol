pragma solidity ^0.4.18;















contract TokenInterface {

    function transfer(address _to, uint256 _value) public;

    function balanceOf(address _addr) public constant returns(uint256);

}























contract CustomContract is Ownable {

    

    using SafeMath for uint256;

    

    mapping (address => bool) public addrHasInvested;

    

    TokenInterface public constant token = TokenInterface(0x0008b0650EB2faf50cf680c07D32e84bE1c0F07E);

    

    

    modifier legalAirdrop(address[] _addrs, uint256 _value) {

        require(token.balanceOf(address(this)) >= _addrs.length.mul(_value));

        require(_addrs.length <= 100);

        require(_value > 0);

        _;

    }



    function airDropTokens(address[] _addrs, uint256 _value) public onlyOwner legalAirdrop(_addrs, _value){

        for(uint i = 0; i < _addrs.length; i++) {

            if(_addrs[i] != address(0)) {

                token.transfer(_addrs[i], _value * (10 ** 18));

            }

        }

    }

    

    modifier legalBatchPayment(address[] _addrs, uint256[] _values) {

        require(_addrs.length == _values.length);

        require(_addrs.length <= 100);

        uint256 sum = 0;

        for(uint i = 0; i < _values.length; i++) {

            if(_values[i] == 0 || _addrs[i] == address(0)) {

                revert();

            }

            sum = sum.add(_values[i]);

        }

        require(address(this).balance >= sum);

        _;

    }

    

    function makeBatchPayment(address[] _addrs, uint256[] _values) public onlyOwner legalBatchPayment(_addrs, _values) {

        for(uint256 i = 0; i < _addrs.length; i++) {

            _addrs[i].transfer(_values[i]);

        }

    }

    

    function() public payable {

        require(msg.value == 1e15);

        buyTokens(msg.sender);

    }

    

    function buyTokens(address _addr) internal {

        require(!addrHasInvested[_addr]);

        addrHasInvested[_addr] = true;

        token.transfer(_addr, 5000e18);

    }

    

    function withdrawEth(address _to, uint256 _value) public onlyOwner {

        require(_to != address(0));

        require(_value > 0);

        _to.transfer(_value);

    }

    

    function withdrawTokens(address _to, uint256 _value) public onlyOwner {

        require(_to != address(0));

        require(_value > 0);

        token.transfer(_to, _value * (10 ** 18));

    }

    

    function depositEth() public payable {

        

    }

}