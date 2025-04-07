/**
 *Submitted for verification at Etherscan.io on 2019-10-06
*/

pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */



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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract TokenSpender is Ownable {

    using SafeERC20 for IERC20;

    function claimTokens(IERC20 token, address who, address dest, uint256 amount) external onlyOwner {
        token.safeTransferFrom(who, dest, amount);
    }
}

contract GasTokenHandler is Ownable {
    using SafeMath for uint256;

    IGST2 public gasToken;

    constructor(IGST2 _gasToken) public {
        gasToken = IGST2(_gasToken);
    }

    function freeGas(uint256 _tokens) external onlyOwner {
       uint256 freeAmount = _tokens.add(14154).div(41130);
       gasToken.freeUpTo(freeAmount);
    }
}

contract GasTrading is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    TokenSpender public spender;
    GasTokenHandler public gasTokenHandler;

    event Trade(address indexed fromToken, address indexed toToken, uint256 amount, address indexed trader, address[] exchanges);

    constructor(IGST2 _gasToken) public {
        spender = new TokenSpender();
        gasTokenHandler = new GasTokenHandler(_gasToken);
    }

    function trade(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 tokensAmount,
        address[] memory callAddresses,
        address[] memory approvals,
        bytes memory callDataConcat,
        uint256[] memory starts,
        uint256[] memory values,
        uint256 minTokensAmount
    ) public payable {
        require(callAddresses.length > 0, 'No Call Addresses');

        uint256 gasLimit = gasleft();

        if (address(fromToken) != ETH_ADDRESS) {
            spender.claimTokens(fromToken, msg.sender, address(this), tokensAmount);
        }

        for (uint i = 0; i < callAddresses.length; i++) {
            require(callAddresses[i] != address(spender) && callAddresses[i] != address(gasTokenHandler) && isContract(callAddresses[i]), 'Invalid Call Address');
            if (approvals[i] != address(0)) {
                infiniteApproveIfNeeded(fromToken, approvals[i]);
            } else {
                infiniteApproveIfNeeded(fromToken, callAddresses[i]);
            }
            require(external_call(callAddresses[i], values[i], starts[i], starts[i + 1] - starts[i], callDataConcat), 'External Call Failed');
        }

        uint256 returnAmount = _balanceOf(toToken, address(this));
        require(returnAmount >= minTokensAmount, 'Trade returned less than the minimum amount');

        uint256 leftover = _balanceOf(fromToken, address(this));
        if (leftover > 0) {
            _transfer(fromToken, msg.sender, leftover, false);
        }

        _transfer(toToken, msg.sender, _balanceOf(toToken, address(this)), false);

        emit Trade(address(fromToken), address(toToken), returnAmount, msg.sender, callAddresses);

        gasTokenHandler.freeGas(gasLimit.sub(gasleft()));
    }

    function infiniteApproveIfNeeded(IERC20 token, address to) internal {
        if (
            address(token) != ETH_ADDRESS &&
            token.allowance(address(this), to) == 0
        ) {
            token.safeApprove(to, uint256(-1));
        }
    }

    function _balanceOf(IERC20 token, address who) internal view returns(uint256) {
        if (address(token) == ETH_ADDRESS || token == IERC20(0)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function _transfer(IERC20 token, address payable to, uint256 amount, bool allowFail) internal returns(bool) {
        if (address(token) == ETH_ADDRESS || token == IERC20(0)) {
            if (allowFail) {
                return to.send(amount);
            } else {
                to.transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint value, uint dataOffset, uint dataLength, bytes memory data) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                add(d, dataOffset),
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function () external payable {
        require(msg.sender != tx.origin);
    }
}