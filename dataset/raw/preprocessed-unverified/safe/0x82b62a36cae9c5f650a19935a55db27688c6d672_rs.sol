/**
 *Submitted for verification at Etherscan.io on 2019-09-10
*/

pragma solidity ^0.4.20;




/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();
    
    bool public paused = false;
    
    
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
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }
    
    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}


contract TokenTransferInterface {
    function transfer(address _to, uint256 _value) public;
}


contract SelfDropCYFM is Pausable {
    
    mapping (address => bool) public addrHasClaimedTokens;
    
    TokenTransferInterface public constant token = TokenTransferInterface(0x32b87fb81674aa79214e51ae42d571136e29d385);
    
    uint256 public tokensToSend = 5000e18;
    
    
    function changeTokensToSend(uint256 _value) public onlyOwner {
        require(_value != tokensToSend);
        require(_value > 0);
        tokensToSend = (_value * (10 ** 18));
    }
    
    
    function() public payable whenNotPaused {
        require(!addrHasClaimedTokens[msg.sender]);
        require(msg.value == 0);
        addrHasClaimedTokens[msg.sender] = true;
        token.transfer(msg.sender, tokensToSend);
    }
}