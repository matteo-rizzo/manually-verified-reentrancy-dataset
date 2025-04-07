/**
 *Submitted for verification at Etherscan.io on 2019-06-22
*/

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
    using SafeMath for uint256;

    IERC20 public token;

    event Airdropped(address to, uint256 token);
    event TokenContractSet(IERC20 newToken);

    /**
    * @dev The Airdrop constructor sets the address of the token contract
    */
    constructor (IERC20 _tokenAddr) public {
        require(address(_tokenAddr) != address(0), "Zero address received");
        token = _tokenAddr;
        emit TokenContractSet(_tokenAddr);
    }

    /**
    * @dev Allows the tokens to be dropped to the respective beneficiaries
    * @param beneficiaries An array of beneficiary addresses that are to receive tokens
    * @param values An array of the amount of tokens to be dropped to respective beneficiaries
    * @return Returns true if airdrop is successful
    */
    function drop(address[] beneficiaries, uint256[] values)
        external
        onlyOwner
        returns (bool)
    {
        require(beneficiaries.length == values.length, "Array lengths of parameters unequal");

        for (uint i = 0; i < beneficiaries.length; i++) {
            require(beneficiaries[i] != address(0), "Zero address received");
            require(getBalance() >= values[i], "Insufficient token balance");

            token.transfer(beneficiaries[i], values[i]);

            emit Airdropped(beneficiaries[i], values[i]);
        }

        return true;
    }

    /**
    * @dev Used to check contract's token balance
    */
    function getBalance() public view returns (uint256 balance) {
        balance = token.balanceOf(address(this));
    }

    /**
    * @dev Sets the address of the token contract
    * @param newToken The address of the token contract
    */
    function setTokenAddress(IERC20 newToken) public onlyOwner {
        require(address(newToken) != address(0), "Zero address received");
        token = newToken;
        emit TokenContractSet(newToken);
    }

}