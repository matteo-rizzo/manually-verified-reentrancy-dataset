/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

// SPDX-License-Identifier: MIT
/*
A bridge that connects AlphaHomora ibETH contracts to our STACK gauge contracts. 
This allows users to submit only one transaction to go from (supported ERC20 <-> AlphaHomora <-> STACK commit to VC fund)
They will be able to deposit & withdraw in both directions.
*/

pragma solidity ^0.6.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
abstract contract ReentrancyGuard {
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





contract VaultGaugeBridge is ReentrancyGuard {
	using SafeERC20 for IERC20;
	using Address for address;
    using SafeMath for uint256;

    address payable public constant AlphaHomora_ibETH = 0xeEa3311250FE4c3268F8E684f7C87A82fF183Ec1; // AlphaHomora ibETHv2 deposit/withdraw contract & ERC20 contract

    address payable public governance;
    address public gauge;

    constructor () public {
    	governance = msg.sender;
    }

    receive() external payable {
        if (msg.sender != AlphaHomora_ibETH){
            // if the fund is open, then hard commit to the fund, if it's not, then fallback to soft commit
            if (IGaugeD1(gauge).fundOpen()){
                depositBridgeETH(true); 
            }
            else {
                depositBridgeETH(false);
            } 
        }
    }

    function setGovernance(address payable _new) external {
        require(msg.sender == governance, "BRIDGE: !governance");
        governance = _new;
    }

    // set the gauge to bridge ibETH to
    function setGauge(address _gauge) external {
    	require(msg.sender == governance, "BRIDGE: !governance");
        require(gauge == address(0), "BRIDGE: gauge already set");

    	gauge = _gauge;
    }

    // deposit ETH into ETH vault. WETH can be done with normal depositBridge call.
    // public because of fallback function
    function depositBridgeETH(bool _commit) nonReentrant public payable {
    	require(gauge != address(0), "BRIDGE: !bridge"); // need to setup, fail

    	uint256 _beforeToken = IERC20(AlphaHomora_ibETH).balanceOf(address(this));
    	IAlphaHomora_ibETH(AlphaHomora_ibETH).deposit{value: msg.value}();
    	uint256 _afterToken = IERC20(AlphaHomora_ibETH).balanceOf(address(this));
    	uint256 _receivedToken = _afterToken.sub(_beforeToken);

    	_depositGauge(_receivedToken, _commit, msg.sender);
    }

    // withdraw as ETH from WETH vault. WETH withdraw can be from from depositBridge call.
    function withdrawBridgeETH(uint256 _amount) nonReentrant external {
        require(gauge != address(0), "BRIDGE: !bridge"); // need to setup, fail

        uint256 _receivedToken = _withdrawGauge(_amount, msg.sender);

        uint256 _before = address(this).balance;
        IAlphaHomora_ibETH(AlphaHomora_ibETH).withdraw(_receivedToken);
        uint256 _after = address(this).balance;
        uint256 _received = _after.sub(_before);

        msg.sender.transfer(_received);
    }

    function _withdrawGauge(uint256 _amount, address _user) internal returns (uint256){
        uint256 _beforeToken = IERC20(AlphaHomora_ibETH).balanceOf(address(this));
        IGaugeD1(gauge).withdraw(_amount, _user);
        uint256 _afterToken = IERC20(AlphaHomora_ibETH).balanceOf(address(this));

        return _afterToken.sub(_beforeToken);
    }

    function _depositGauge(uint256 _amount, bool _commit, address _user) internal {
		IERC20(AlphaHomora_ibETH).safeApprove(gauge, 0);
    	IERC20(AlphaHomora_ibETH).safeApprove(gauge, _amount);

    	if (_commit){
    		IGaugeD1(gauge).deposit(0, _amount, _user);
    	}
    	else {
    		IGaugeD1(gauge).deposit(_amount, 0, _user);
    	}
    }

    // decentralized rescue function for any stuck tokens, will return to governance
    function rescue(address _token, uint256 _amount) nonReentrant external {
        require(msg.sender == governance, "BRIDGE: !governance");

        if (_token != address(0)){
            IERC20(_token).safeTransfer(governance, _amount);
        }
        else { // if _tokenContract is 0x0, then escape ETH
            governance.transfer(_amount);
        }
    }
}