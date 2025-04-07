/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

/**
 * @title IERC1404 - Simple Restricted Token Standard 
 * @dev https://github.com/ethereum/eips/issues/1404
 */

    
    
/**
 * @title IERC1404Checks 
 * @dev Interface for all the checks for Restricted Transfer Contract 
 */




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title RestrictedMessages
 * @dev All the messages and code of transfer restriction
 */ 
contract RestrictedMessages {
    
    uint8 internal constant SUCCESS = 0;
    uint8 internal constant PAUSED_FAILURE = 1;
    uint8 internal constant WHITELIST_FAILURE = 2;
    uint8 internal constant TIMELOCK_FAILURE = 3;
    
    string internal constant SUCCESS_MSG = "SUCCESS";
    string internal constant PAUSED_FAILURE_MSG = "ERROR: All transfer is paused now";
    string internal constant WHITELIST_FAILURE_MSG = "ERROR: Wallet is not whitelisted";
    string internal constant TIMELOCK_FAILURE_MSG = "ERROR: Wallet is locked";
    string internal constant UNKNOWN = "ERROR: Unknown";
}


/**
 * @title ERC1404
 * @dev Simple Restricted Token Standard  
 */ 
contract ERC1404 is IERC1404, RestrictedMessages, Ownable {
    
    // Checkers contract address, basically RVW token contract address
    IERC1404Checks public checker;

    event UpdatedChecker(IERC1404Checks indexed _checker);
    
    // Update the token contract address
    function updateChecker(IERC1404Checks _checker) public onlyOwner{
        require(_checker != IERC1404Checks(0), "ERC1404: Address should not be zero.");
        checker = _checker;
        emit UpdatedChecker(_checker);
    }
    
    // All checks of transfer function
    // If contract paused, sender wallet locked and wallet not whitelisted then return error code else success
    // Note, Now there is no use of amount for restriction, but might be in the future
    function detectTransferRestriction (address from, address to, uint256 amount) public override view returns (uint8) {
        if(checker.paused()){ 
            return PAUSED_FAILURE; 
        }
        if(!checker.checkWhitelists(from, to)){ 
            return WHITELIST_FAILURE;
        }
        if(checker.isLocked(from)){ 
            return TIMELOCK_FAILURE;
        }
        return SUCCESS;
    }
    
    // Return the error message of error code
    function messageForTransferRestriction (uint8 code) public override pure returns (string memory){
        if (code == SUCCESS) {
            return SUCCESS_MSG;
        }
        if (code == PAUSED_FAILURE) {
            return PAUSED_FAILURE_MSG;
        }
        if (code == WHITELIST_FAILURE) {
            return WHITELIST_FAILURE_MSG;
        }
        if (code == TIMELOCK_FAILURE) {
            return TIMELOCK_FAILURE_MSG;
        }
        return UNKNOWN;
    }

}