/**
 *  Relay.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Notary Platform
 */

pragma solidity ^0.4.16;

// Used for accepting small contributions without whitelist


contract Pausable is Ownable {
  
  event Pause(bool indexed state);

  bool private paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev return the current state of contract
   */
  function Paused() external constant returns(bool){ return paused; }

  /**
   * @dev called by the owner to pause or unpause, triggers stopped state
   * on first call and returns to normal state on second call
   */
  function tweakState() external onlyOwner {
    paused = !paused;
    Pause(paused);
  }

}

contract Relay is Pausable{
  
    address private crowdfunding;
    
    function Relay() 
        Ownable(0x0587e235a5906ed8143d026de530d77ad82f8a92){
        crowdfunding = 0x34a3DeB32b4705018F1e543A5867cF01AFf3F15B;
    }
    
    function () payable isMinimum whenNotPaused{
        crowdfunding.transfer(msg.value);
    }
    
    /** Modifier allowing execution only if received value is greater than zero */
    modifier isMinimum(){
        require(msg.value <= 2 ether);
        _;
    }
}