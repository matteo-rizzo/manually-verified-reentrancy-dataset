/**
 *Submitted for verification at Etherscan.io on 2019-07-09
*/

pragma solidity ^0.5.10;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @dev Wrappers over Solidity&#39;s arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it&#39;s recommended to use it always.
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

// File: contracts/AirDrop.sol

/**
 * @title AirDrop
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Contract to distribute tokens by transferFrom function
 */
contract AirDrop is TokenRecover {
    using SafeMath for uint256;

    // the token to distribute
    IERC20 private _token;

    // the max token cap to distribute
    uint256 private _cap;

    // wallet where to transfer the tokens from
    address private _wallet;

    // the sum of distributed tokens
    uint256 private _distributedTokens;

    // map of address and received token amount
    mapping(address => uint256) private _receivedTokens;

    /**
     * @param token Address of the token being distributed
     * @param cap Max amount of token to be distributed
     * @param wallet Address where are tokens stored
     */
    constructor(IERC20 token, uint256 cap, address wallet) public {
        require(address(token) != address(0));
        require(cap > 0);
        require(wallet != address(0));

        _token = token;
        _cap = cap;
        _wallet = wallet;
    }

    /**
     * @return the token to distributed
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the max token cap to distribute
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @return wallet where to transfer the tokens from
     */
    function wallet() public view returns (address) {
        return _wallet;
    }

    /**
     * @return the sum of distributed tokens
     */
    function distributedTokens() public view returns (uint256) {
        return _distributedTokens;
    }

    /**
     * @param account The address to check
     * @return received token amount for the given address
     */
    function receivedTokens(address account) public view returns (uint256) {
        return _receivedTokens[account];
    }

    /**
     * @dev return the number of remaining tokens to distribute
     * @return uint256
     */
    function remainingTokens() public view returns (uint256) {
        return _cap.sub(_distributedTokens);
    }

    /**
     * @dev send tokens
     * @param accounts Array of addresses being distributing
     * @param amounts Array of amounts of token distributed
     */
    function multiSend(address[] memory accounts, uint256[] memory amounts) public onlyOwner {
        require(accounts.length > 0);
        require(amounts.length > 0);
        require(accounts.length == amounts.length);

        for (uint i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];

            if (_receivedTokens[account] == 0) {
                _receivedTokens[account] = _receivedTokens[account].add(amount);
                _distributedTokens = _distributedTokens.add(amount);

                require(_distributedTokens <= _cap);

                _distributeTokens(account, amount);
            }
        }
    }

    /**
     * @dev distribute tokens
     * @param account Address being distributing
     * @param amount Amount of token distributed
     */
    function _distributeTokens(address account, uint256 amount) internal {
        _token.transferFrom(_wallet, account, amount);
    }
}