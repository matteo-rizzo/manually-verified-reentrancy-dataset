/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity ^0.5.10;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20 {
    function totalSupply() external returns (uint);
    function balanceOf(address tokenOwner) external returns (uint balance);
    function allowance(address tokenOwner, address spender) external returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Airdropper contract
// ----------------------------------------------------------------------------
contract Airdropper is Owned {
    using SafeMath for uint;

    ERC20 public token;

    /**
     * @dev Constructor.
     * @param tokenAddress Address of the token contract.
     */
    constructor(address tokenAddress) public {
        token = ERC20(tokenAddress);
    }
    
     /**
      * @dev Airdrop.
      * @ !important Before using, send needed token amount to this contract
      */
    function airdrop(address[] memory dests, uint[] memory values) public onlyOwner {
        // This simple validation will catch most mistakes without consuming
        // too much gas.
        require(dests.length == values.length);

        for (uint256 i = 0; i < dests.length; i++) {
            token.transfer(dests[i], values[i]);
        }
    }

    /**
     * @dev Return all tokens back to owner, in case any were accidentally
     *   transferred to this contract.
     */
    function returnTokens() public onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }

    /**
     * @dev Destroy this contract and recover any ether to the owner.
     */
    function destroy() public onlyOwner {
        selfdestruct(msg.sender);
    }
}