/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
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
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */



 contract UNLSplit  {
    using Address for address;
    using SafeMath for uint;
    address public newUNL;
    address public  oldUNL;
    address public owner;
    uint public ratio;

    constructor(address _newUNL,address _oldUNL,uint _ratio) public{
        owner = msg.sender;
        newUNL = _newUNL;
        oldUNL = _oldUNL;
        ratio = _ratio;
        
    }
    function changeConfig(address _newUNL,address _oldUNL,uint _ratio) public returns (uint){
        require(msg.sender == owner, ' You are not allowed to execute this function');
        newUNL = _newUNL;
        oldUNL = _oldUNL;
        ratio = _ratio;
    }
   

    function swap() public returns(uint){
        uint balance = IERC20(address(oldUNL)).balanceOf(msg.sender);
        IERC20(address(oldUNL)).transferFrom(msg.sender,address(this),balance);
        IERC20(address(newUNL)).transfer(msg.sender,balance.mul(ratio));
    }


  
    


    
}