/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

pragma solidity ^0.5.10;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: eth-token-recover/contracts/TokenRecover.sol

/**
 * @title TokenRecover
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Allow to recover any ERC20 sent into the contract for error
 */
contract TokenRecover is Ownable {

    /**
     * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.
     * @param tokenAddress The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// File: contracts/access/roles/OperatorRole.sol

contract OperatorRole {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    constructor() internal {
        _addOperator(msg.sender);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function addOperator(address account) public onlyOperator {
        _addOperator(account);
    }

    function renounceOperator() public {
        _removeOperator(msg.sender);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

// File: contracts/utils/Contributions.sol

/**
 * @title Contributions
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Utility contract where to save any information about Crowdsale contributions
 */
contract Contributions is OperatorRole, TokenRecover {
    using SafeMath for uint256;

    struct Contributor {
        uint256 weiAmount;
        uint256 tokenAmount;
        bool exists;
    }

    // the number of sold tokens
    uint256 private _totalSoldTokens;

    // the number of wei raised
    uint256 private _totalWeiRaised;

    // list of addresses who contributed in crowdsales
    address[] private _addresses;

    // map of contributors
    mapping(address => Contributor) private _contributors;

    constructor() public {} // solhint-disable-line no-empty-blocks

    /**
     * @return the number of sold tokens
     */
    function totalSoldTokens() public view returns (uint256) {
        return _totalSoldTokens;
    }

    /**
     * @return the number of wei raised
     */
    function totalWeiRaised() public view returns (uint256) {
        return _totalWeiRaised;
    }

    /**
     * @return address of a contributor by list index
     */
    function getContributorAddress(uint256 index) public view returns (address) {
        return _addresses[index];
    }

    /**
     * @dev return the contributions length
     * @return uint representing contributors number
     */
    function getContributorsLength() public view returns (uint) {
        return _addresses.length;
    }

    /**
     * @dev get wei contribution for the given address
     * @param account Address has contributed
     * @return uint256
     */
    function weiContribution(address account) public view returns (uint256) {
        return _contributors[account].weiAmount;
    }

    /**
     * @dev get token balance for the given address
     * @param account Address has contributed
     * @return uint256
     */
    function tokenBalance(address account) public view returns (uint256) {
        return _contributors[account].tokenAmount;
    }

    /**
     * @dev check if a contributor exists
     * @param account The address to check
     * @return bool
     */
    function contributorExists(address account) public view returns (bool) {
        return _contributors[account].exists;
    }

    /**
     * @dev add contribution into the contributions array
     * @param account Address being contributing
     * @param weiAmount Amount of wei contributed
     * @param tokenAmount Amount of token received
     */
    function addBalance(address account, uint256 weiAmount, uint256 tokenAmount) public onlyOperator {
        if (!_contributors[account].exists) {
            _addresses.push(account);
            _contributors[account].exists = true;
        }

        _contributors[account].weiAmount = _contributors[account].weiAmount.add(weiAmount);
        _contributors[account].tokenAmount = _contributors[account].tokenAmount.add(tokenAmount);

        _totalWeiRaised = _totalWeiRaised.add(weiAmount);
        _totalSoldTokens = _totalSoldTokens.add(tokenAmount);
    }

    /**
     * @dev remove the `operator` role from address
     * @param account Address you want to remove role
     */
    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }
}