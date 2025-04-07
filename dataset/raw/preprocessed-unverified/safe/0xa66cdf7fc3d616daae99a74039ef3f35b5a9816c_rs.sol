pragma solidity ^0.4.23;

/**
 * CoinCrowd Multi Send Contract. More info www.coincrowd.me
 */
 

 
contract tokenInterface {
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract MultiSendCoinCrowd is Ownable {
	tokenInterface public tokenContract;
	
	function updateTokenContract(address _tokenAddress) public onlyOwner {
        tokenContract = tokenInterface(_tokenAddress);
    }
	
    function multisend(address[] _dests, uint256[] _values) public onlyOwner returns(uint256) {
        require(_dests.length == _values.length, "_dests.length == _values.length");
        uint256 i = 0;
        while (i < _dests.length) {
           tokenContract.transfer(_dests[i], _values[i]);
           i += 1;
        }
        return(i);
    }
	
	function airdrop( uint256 _value, address[] _dests ) public onlyOwner returns(uint256) {
        uint256 i = 0;
        while (i < _dests.length) {
            tokenContract.transfer(_dests[i], _value);
           i += 1;
        }
        return(i);
    }
	
	function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
}