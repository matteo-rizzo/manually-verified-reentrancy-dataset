pragma solidity ^0.4.11;

/**
 * @title Owned contract with safe ownership pass.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn&#39;t happen yet.
 */


contract ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);
    string public symbol;

    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned {
    /**
    *  Common result code. Means everything is fine.
    */
    uint constant OK = 1;
    uint constant OWNED_ACCESS_DENIED_ONLY_CONTRACT_OWNER = 8;

    function withdrawnTokens(address[] tokens, address _to) onlyContractOwner returns(uint) {
        for(uint i=0;i<tokens.length;i++) {
            address token = tokens[i];
            uint balance = ERC20Interface(token).balanceOf(this);
            if(balance != 0)
                ERC20Interface(token).transfer(_to,balance);
        }
        return OK;
    }

    function checkOnlyContractOwner() internal constant returns(uint) {
        if (contractOwner == msg.sender) {
            return OK;
        }

        return OWNED_ACCESS_DENIED_ONLY_CONTRACT_OWNER;
    }
}


/**
 * @title Events History universal multi contract.
 *
 * Contract serves as an Events storage for any type of contracts.
 * Events appear on this contract address but their definitions provided by calling contracts.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn&#39;t happen yet.
 */
contract MultiEventsHistory is Object {
    // Authorized calling contracts.
    mapping(address => bool) public isAuthorized;

    /**
     * Authorize new caller contract.
     *
     * @param _caller address of the new caller.
     *
     * @return success.
     */
    function authorize(address _caller) onlyContractOwner() returns(bool) {
        if (isAuthorized[_caller]) {
            return false;
        }
        isAuthorized[_caller] = true;
        return true;
    }

    /**
     * Reject access.
     *
     * @param _caller address of the caller.
     */
    function reject(address _caller) onlyContractOwner() {
        delete isAuthorized[_caller];
    }

    /**
     * Event emitting fallback.
     *
     * Can be and only called by authorized caller.
     * Delegate calls back with provided msg.data to emit an event.
     *
     * Throws if call failed.
     */
    function () {
        if (!isAuthorized[msg.sender]) {
            return;
        }
        // Internal Out Of Gas/Throw: revert this transaction too;
        // Recursive Call: safe, all changes already made.
        if (!msg.sender.delegatecall(msg.data)) {
            throw;
        }
    }
}