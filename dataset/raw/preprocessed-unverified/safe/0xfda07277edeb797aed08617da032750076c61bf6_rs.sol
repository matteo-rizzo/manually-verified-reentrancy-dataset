pragma solidity ^0.4.19;

/**
 * Ownership interface
 *
 * Perminent ownership
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */



/**
 * Ownership
 *
 * Perminent ownership
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract Ownership is IOwnership {

    // Owner
    address internal owner;


    /**
     * The publisher is the inital owner
     */
    function Ownership() public {
        owner = msg.sender;
    }


    /**
     * Access is restricted to the current owner
     */
    modifier only_owner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public view returns (bool) {
        return _account == owner;
    }


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}


/**
 * ransferable ownership interface
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */



/**
 * Transferable ownership
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract TransferableOwnership is ITransferableOwnership, Ownership {

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) public only_owner {
        owner = _newOwner;
    }
}


/**
 * ERC20 compatible token interface
 *
 * - Implements ERC 20 Token standard
 * - Implements short address attack fix
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */



/**
 * @title Token retrieve interface
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public;
}


/**
 * @title Token retrieve
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 18/10/2017
 * #author Frank Bonnet
 */
contract TokenRetriever is ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public {
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(this);
        if (tokenBalance > 0) {
            tokenInstance.transfer(msg.sender, tokenBalance);
        }
    }
}


/**
 * IAirdropper
 *
 * #created 29/03/2018
 * #author Frank Bonnet
 */



/**
 * Airdropper 
 *
 * Transfer tokens to multiple accounts at once
 *
 * #created 29/03/2018
 * #author Frank Bonnet
 */
contract Airdropper is TransferableOwnership {

    /**
     * Airdrop tokens
     *
     * Transfers the appropriate `_token` value for each recipient 
     * found in `_recipients` and `_values` 
     *
     * @param _token Token contract to send from
     * @param _recipients Receivers of the tokens
     * @param _values Amounts of tokens that are transferred
     */
    function drop(IToken _token, address[] _recipients, uint[] _values) public only_owner {
        for (uint i = 0; i < _values.length; i++) {
            _token.transfer(_recipients[i], _values[i]);
        }
    }
}


/**
 * DCorp Airdropper 
 *
 * Transfer tokens to multiple accounts at once
 *
 * #created 27/03/2018
 * #author Frank Bonnet
 */
contract DCorpAirdropper is Airdropper, TokenRetriever {

    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens (other than DRPS and DRPU tokens) from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public only_owner {
        super.retrieveTokens(_tokenContract);
    }


    // Do not accept ether
    function () public payable {
        revert();
    }
}