/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-19
*/

pragma solidity ^0.6.0;

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
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
 
 
 

contract TimeLock {
    address public owner; //deployer
    uint256 currentDate;//private record of deployment date
    uint256 public nextDate; //public record of when tokens release
    address public receiver = 0x24dd6DE5dAF992eAf99Df9514efd0c63Bfc66CC9; //address to send tokens back to 
    constructor() public {
        currentDate = now; //block.timestamp
        nextDate = now + 90 days; //90 days = 3 months
        owner = msg.sender; //person deploying becomes owner of contract
    }
    
    
    function withDraw(IERC20 token) public{
        require(msg.sender == owner, "Only owner can call withdraw"); //person calling withdraw has to be the deployer of the contract
        if (now >= nextDate){ //make sure current time is greater than the 2 months since deployment
            uint256 balance = token.balanceOf(address(this)); //get total balance of all tokens the contract holds (token address entered when function called so it can support any token)
            token.transfer(receiver,balance); //send all tokens this contract holds back to the reciever address hard set above
        } else {
            revert(); //if the data isn't ready, don't execute
        }
    }
}