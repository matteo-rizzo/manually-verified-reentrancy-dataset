/**
 *Submitted for verification at Etherscan.io on 2021-04-04
*/

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.6.11;

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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */



contract Bridge is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    // ----------------------- Smart Contract Variables -----------------------
    // Must be updated before live deployment.
    
    uint public dailyTokenWithdrawLimitPerAccount = 10_000e18;
    uint public constant CHAIN_ID = 1;
    uint public constant ONE_DAY = 24 hours;
    
    address public constant TRUSTED_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    address public verifyAddress = 0x072bc8750a0852C0eac038be3E7f2e7c7dAb1E94;
    
    // ----------------------- End Smart Contract Variables -----------------------
    
    event Deposit(address indexed account, uint amount, uint blocknumber, uint timestamp, uint id);
    event Withdraw(address indexed account, uint amount, uint id);
    
    mapping (address => uint) public lastUpdatedTokenWithdrawTimestamp;
    mapping (address => uint) public lastUpdatedTokenWithdrawAmount;

    
    // deposit index OF OTHER CHAIN => withdrawal in current chain
    mapping (uint => bool) public claimedWithdrawalsByOtherChainDepositId;
    
    // deposit index for current chain
    uint public lastDepositIndex;
    
    function setVerifyAddress(address newVerifyAddress) external noContractsAllowed onlyOwner {
        verifyAddress = newVerifyAddress;
    }
    function setDailyLimit(uint newDailyTokenWithdrawLimitPerAccount) external noContractsAllowed onlyOwner {
        dailyTokenWithdrawLimitPerAccount = newDailyTokenWithdrawLimitPerAccount;
    }
    
    function deposit(uint amount) external noContractsAllowed nonReentrant {
        require(amount <= dailyTokenWithdrawLimitPerAccount, "amount exceeds limit");
        
        lastDepositIndex = lastDepositIndex.add(1);
        IERC20(TRUSTED_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), amount);
        
        emit Deposit(msg.sender, amount, block.number, block.timestamp, lastDepositIndex);
    }
    function withdraw(uint amount, uint chainId, uint id, bytes calldata signature) external noContractsAllowed nonReentrant {
        require(chainId == CHAIN_ID, "invalid chainId!");
        require(!claimedWithdrawalsByOtherChainDepositId[id], "already withdrawn!");
        require(verify(msg.sender, amount, chainId, id, signature), "invalid signature!");
        require(canWithdraw(msg.sender, amount), "cannot withdraw, limit reached for current duration!");
        
        claimedWithdrawalsByOtherChainDepositId[id] = true;
        IERC20(TRUSTED_TOKEN_ADDRESS).safeTransfer(msg.sender, amount);
        
        emit Withdraw(msg.sender, amount, id);
    }
    
    function canWithdraw(address account, uint amount) private returns (bool) {
        if (block.timestamp.sub(lastUpdatedTokenWithdrawTimestamp[account]) >= ONE_DAY) {
            lastUpdatedTokenWithdrawAmount[account] = 0;
            lastUpdatedTokenWithdrawTimestamp[account] = block.timestamp;
        }
        lastUpdatedTokenWithdrawAmount[account] = lastUpdatedTokenWithdrawAmount[account].add(amount);
        return lastUpdatedTokenWithdrawAmount[account] <= dailyTokenWithdrawLimitPerAccount;
    }
    
    // the Bridge is a centralized service, allow admin to transfer any ERC20 token if required in case of emergencies
    function transferAnyERC20Token(address tokenAddress, address recipient, uint amount) external noContractsAllowed onlyOwner {
        IERC20(tokenAddress).safeTransfer(recipient, amount);
    }
    
    /// signature methods.
	function verify(
		address account, 
		uint amount,
		uint chainId,
		uint id,
		bytes calldata signature
	) 
		internal view returns(bool) 
	{
		bytes32 message = prefixed(keccak256(abi.encode(account, amount, chainId, id, address(this))));
        return (recoverSigner(message, signature) == verifyAddress);
	}
    
    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(sig, (uint8, bytes32, bytes32));

        return ecrecover(message, v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}