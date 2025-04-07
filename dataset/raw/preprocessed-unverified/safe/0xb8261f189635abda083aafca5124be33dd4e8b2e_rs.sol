pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */






contract Airdrop is Ownable {
    using SafeMath for uint;

    address public tokenAddr;

    event EtherTransfer(address beneficiary, uint amount);

    constructor(address _tokenAddr) public {
        tokenAddr = _tokenAddr;
    }

    function dropTokens(address[] _recipients, uint256[] _amount) public onlyOwner returns (bool) {
        require(_recipients.length == _amount.length);

        for (uint i = 0; i < _recipients.length; i++) {
            uint256 toSend = _amount[i] * 10**6;
            require(_recipients[i] != address(0));
            require(Token(tokenAddr).transfer(_recipients[i], toSend));
        }

        return true;
    }

    function updateTokenAddress(address newTokenAddr) public onlyOwner {
        tokenAddr = newTokenAddr;
    }

    function withdrawTokens(address beneficiary) public onlyOwner {
        require(Token(tokenAddr).transfer(beneficiary, Token(tokenAddr).balanceOf(this)));
    }

    function withdrawEther(address beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
  

}