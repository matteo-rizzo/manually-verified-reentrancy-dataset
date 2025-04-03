pragma solidity ^0.4.4;
/**
 * @title Contract for object that have an owner
 */


/**
 * @title Contract for objects that can be morder
 */
contract Mortal is Owned {
    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can kill me
     */
    function kill() onlyOwner
    { suicide(owner); }
}


contract Comission is Mortal {
    address public ledger;
    bytes32 public taxman;
    uint    public taxPerc;

    /**
     * @dev Comission contract constructor
     * @param _ledger Processing ledger contract
     * @param _taxman Tax receiver account
     * @param _taxPerc Processing tax in percent
     */
    function Comission(address _ledger, bytes32 _taxman, uint _taxPerc) {
        ledger  = _ledger;
        taxman  = _taxman;
        taxPerc = _taxPerc;
    }

    /**
     * @dev Refill ledger with comission
     * @param _destination Destination account
     */
    function process(bytes32 _destination) payable returns (bool) {
        // Handle value below 100 isn't possible
        if (msg.value < 100) throw;

        var tax = msg.value * taxPerc / 100; 
        var refill = bytes4(sha3("refill(bytes32)")); 
        if ( !ledger.call.value(tax)(refill, taxman)
          || !ledger.call.value(msg.value - tax)(refill, _destination)
           ) throw;
        return true;
    }
}

contract Invoice is Mortal {
    address   public signer;
    uint      public closeBlock;

    Comission public comission;
    string    public description;
    bytes32   public beneficiary;
    uint      public value;

    /**
     * @dev Offer type contract
     * @param _comission Comission handler address
     * @param _description Deal description
     * @param _beneficiary Beneficiary account
     * @param _value Deal value
     */
    function Invoice(address _comission,
                     string  _description,
                     bytes32 _beneficiary,
                     uint    _value) {
        comission   = Comission(_comission);
        description = _description;
        beneficiary = _beneficiary;
        value       = _value;
    }

    /**
     * @dev Call me to withdraw money
     */
    function withdraw() onlyOwner {
        if (closeBlock != 0) {
            if (!comission.process.value(value)(beneficiary)) throw;
        }
    }

    /**
     * @dev Payment fallback function
     */
    function () payable {
        // Condition check
        if (msg.value != value
           || closeBlock != 0) throw;

        // Store block when closed
        closeBlock = block.number;
        signer = msg.sender;
        PaymentReceived();
    }
    
    /**
     * @dev Payment notification
     */
    event PaymentReceived();
}

