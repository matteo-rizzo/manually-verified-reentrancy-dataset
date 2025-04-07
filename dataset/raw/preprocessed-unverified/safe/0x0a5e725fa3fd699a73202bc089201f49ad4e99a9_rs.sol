pragma solidity ^0.4.19;

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


// File: contracts/SkillChainContributions.sol

contract SkillChainContributions is Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public tokenBalances;
    address[] public addresses;

    function SkillChainContributions() public {}

    function addBalance(address _address, uint256 _tokenAmount) onlyOwner public {
        require(_tokenAmount > 0);

        if (tokenBalances[_address] == 0) {
            addresses.push(_address);
        }
        tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);
    }

    function getContributorsLength() view public returns (uint) {
        return addresses.length;
    }
}