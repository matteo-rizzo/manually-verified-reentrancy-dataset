pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */






/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20BasicInterface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals;
}


contract BatchTransferWallet is Ownable {
    using SafeMath for uint256;

    event LogWithdrawal(address indexed receiver, uint amount);

    /**
    * @dev Send token to multiple address
    * @param _investors The addresses of EOA that can receive token from this contract.
    * @param _tokenAmounts The values of token are sent from this contract.
    */
    function batchTransfer(address _tokenAddress, address[] _investors, uint256[] _tokenAmounts) public {
        ERC20BasicInterface token = ERC20BasicInterface(_tokenAddress);
        require(_investors.length == _tokenAmounts.length && _investors.length != 0);

        uint decimalsForCalc = 10 ** uint256(token.decimals());

        for (uint i = 0; i < _investors.length; i++) {
            require(_tokenAmounts[i] > 0 && _investors[i] != 0x0);
            _tokenAmounts[i] = _tokenAmounts[i].mul(decimalsForCalc);
            require(token.transfer(_investors[i], _tokenAmounts[i]));
        }
    }

    /**
    * @dev Withdraw the amount of token that is remaining in this contract.
    * @param _address The address of EOA that can receive token from this contract.
    */
    function withdraw(address _tokenAddress,address _address) public onlyOwner {
        ERC20BasicInterface token = ERC20BasicInterface(_tokenAddress);
        uint tokenBalanceOfContract = token.balanceOf(this);

        require(_address != address(0) && tokenBalanceOfContract > 0);
        require(token.transfer(_address, tokenBalanceOfContract));
        emit LogWithdrawal(_address, tokenBalanceOfContract);
    }

    /**
    * @dev return token balance this contract has
    * @return _address token balance this contract has.
    */
    function balanceOfContract(address _tokenAddress,address _address) public view returns (uint) {
        ERC20BasicInterface token = ERC20BasicInterface(_tokenAddress);
        return token.balanceOf(_address);
    }
}