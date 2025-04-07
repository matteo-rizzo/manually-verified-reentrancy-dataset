pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/BlockportAirdropper.sol

/**
 * @title Airdropper
 * @author C&B
 */
contract BlockportAirdropper is Ownable {
    using SafeMath for uint;

    ERC20Basic public token;
    uint public multiplier;

    /// @dev Constructor
    /// @param _tokenAddress Address of token contract
    function BlockportAirdropper(address _tokenAddress, uint decimals) public {
        setDecimals(decimals);

        token = ERC20Basic(_tokenAddress);
    }

    /// @dev Adjust multiplier
    /// @param decimals multiplier will be 10 raised to decimals
    function setDecimals(uint decimals) public onlyOwner {
        require(decimals <= 77);  // uint cap (10**77 < 2**256-1 < 10**78)

        multiplier = uint(10)**decimals;
    }

    /// @dev Airdrops some tokens to some accounts.
    /// @param dests List of account addresses.
    /// @param values List of token amounts.
    function airdrop(address[] dests, uint[] values) public onlyOwner {
        require(dests.length == values.length);

        for (uint256 i = 0; i < dests.length; i++) {
            token.transfer(dests[i], values[i].mul(multiplier));
        }
    }

    /// @dev Return all remaining tokens back to owner.
    function returnTokens() public onlyOwner {
        token.transfer(owner, token.balanceOf(this));
    }
}