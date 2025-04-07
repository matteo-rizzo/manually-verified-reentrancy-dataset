/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

pragma solidity ^0.5.10;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract Pausable is Ownable{
 
    bool private _paused = false;

  
  

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

    
contract TokenSwap is Ownable ,Pausable  {
    
    using SafeMath for uint256;
    ERC20 public oldToken;
    ERC20 public newToken;

    constructor (address _oldToken , address _newToken ) public {
        oldToken = ERC20(_oldToken);
        newToken = ERC20(_newToken);
    
    }
    

    
    function swapTokens() public whenNotPaused{
        uint tokenAllowance = oldToken.allowance(msg.sender, address(this));
        require(tokenAllowance>0 , "token allowence is");
        require(newToken.balanceOf(address(this)) > tokenAllowance , "not enough balance");
        oldToken.transferFrom(msg.sender, address(0), tokenAllowance);
        newToken.transfer(msg.sender, tokenAllowance);

    }
    

    function kill() public onlyOwner {
    selfdestruct(msg.sender);
  }
  
      /**
     * @dev Return all tokens back to owner, in case any were accidentally
     *   transferred to this contract.
     */
    function returnNewTokens() public onlyOwner whenNotPaused {
        newToken.transfer(owner, newToken.balanceOf(address(this)));
    }
    
       
    
      /**
     * @dev Return all tokens back to owner, in case any were accidentally
     *   transferred to this contract.
     */
    function returnOldTokens() public onlyOwner whenNotPaused {
        oldToken.transfer(owner, oldToken.balanceOf(address(this)));
    }
    
    
}