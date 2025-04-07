/**
 *Submitted for verification at Etherscan.io on 2021-08-23
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


contract SwapToken{
    
    using SafeERC20 for IERC20;
    
    IERC20 public oldToken;
    IERC20 public newToken;
    
    address public owner;
    
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    constructor(IERC20 _oldToken, IERC20 _newToken){
        owner = msg.sender;
        oldToken = _oldToken;
        newToken = _newToken;
    }
    
    modifier onlyOwner{
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }
    
    function claimToken(uint _amount) public{
        uint bal = oldTokenBalance(msg.sender);
        require(_amount <= bal, "Incorrect amount");
        require(oldToken.allowance(msg.sender, address(this)) >= _amount, "not approved");
        oldToken.safeTransferFrom(msg.sender, deadAddress, _amount);
        newToken.safeTransfer(msg.sender, _amount);
    }
    
    function oldTokenBalance(address userAddress) public view returns(uint){
        return oldToken.balanceOf(userAddress);
    }
    
    function newTokenBalance(address userAddress) public view returns(uint){
        return newToken.balanceOf(userAddress);
    }
    
    function oldTokenContractBalance() public view returns(uint){
        return oldToken.balanceOf(address(this));
    }
    
    function newTokenCntractBalance() public view returns(uint){
        return newToken.balanceOf(address(this));
    }

    
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out Staking Token from this smart contract
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }
    
}