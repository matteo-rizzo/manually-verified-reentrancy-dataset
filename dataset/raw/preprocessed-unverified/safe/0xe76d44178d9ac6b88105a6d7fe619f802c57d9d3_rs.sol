/**
 *Submitted for verification at Etherscan.io on 2019-07-10
*/

pragma solidity ^0.4.24;









contract ERC1404 is ERC20 {
    function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8);
    function messageForTransferRestriction (uint8 restrictionCode) public view returns (string);
}

contract NT1404 is ERC1404, Ownable {

    // ------------------------------- Variables -------------------------------

    using AdditiveMath for uint256;
    using AddressMap for AddressMap.Data;

    address constant internal ZERO_ADDRESS = address(0);
    string public constant name = "NEWTOUCH BCL LAB TEST";
    string public constant symbol = "NTBCLTEST";
    uint8 public constant decimals = 0;

    AddressMap.Data public shareholders;
    bool public issuingFinished = false;

    mapping(address => uint256) internal balances;
    uint256 internal totalSupplyTokens;
    
    uint8 public constant SUCCESS_CODE = 0;
    string public constant SUCCESS_MESSAGE = "SUCCESS";

    // ------------------------------- Modifiers -------------------------------

    modifier canIssue() {
        require(!issuingFinished, "Issuing is already finished");
        _;
    }

    modifier hasFunds(address addr, uint256 tokens) {
        require(tokens <= balances[addr], "Insufficient funds");
        _;
    }
    
    modifier notRestricted (address from, address to, uint256 value) {
        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(restrictionCode == SUCCESS_CODE, messageForTransferRestriction(restrictionCode));
        _;
    }

    // -------------------------------- Events ---------------------------------

    event Issue(address indexed to, uint256 tokens);
    event IssueFinished();
    event ShareholderAdded(address shareholder);
    event ShareholderRemoved(address shareholder);

    // -------------------------------------------------------------------------

    function detectTransferRestriction (address from, address to, uint256 value)
        public
        view
        returns (uint8 restrictionCode)
    {
        restrictionCode = SUCCESS_CODE;
    }
        
    function messageForTransferRestriction (uint8 restrictionCode)
        public
        view
        returns (string message)
    {
        if (restrictionCode == SUCCESS_CODE) {
            message = SUCCESS_MESSAGE;
        }
    }
    
    function transfer (address to, uint256 value)
        public
        hasFunds(msg.sender, value)
        notRestricted(msg.sender, to, value)
        returns (bool success)
    {
        transferTokens(msg.sender, to, value);
        success = true;
    }

    /**
     * (not used)
     */
    function transferFrom (address from, address to, uint256 value)
        public
        returns (bool success)
    {
        success = false;
    }

    function issueTokens(uint256 quantity)
    external
    onlyOwner
    canIssue
    returns (bool) {
        // Avoid doing any state changes for zero quantities
        if (quantity > 0) {
            totalSupplyTokens = totalSupplyTokens.add(quantity);
            balances[owner] = balances[owner].add(quantity);
            shareholders.append(owner);
        }
        emit Issue(owner, quantity);
        emit Transfer(ZERO_ADDRESS, owner, quantity);
        return true;
    }

    function finishIssuing()
    external
    onlyOwner
    canIssue
    returns (bool) {
        issuingFinished = true;
        emit IssueFinished();
        return issuingFinished;
    }

    /**
     * (not used)
     */
    function approve(address spender, uint256 tokens)
    external
    returns (bool) {
        return false;
    }

    // -------------------------------- Getters --------------------------------

    function totalSupply()
    external
    view
    returns (uint256) {
        return totalSupplyTokens;
    }

    function balanceOf(address addr)
    external
    view
    returns (uint256) {
        return balances[addr];
    }

    /**
     *  (not used)
     */
    function allowance(address addrOwner, address spender)
    external
    view
    returns (uint256) {
        return 0;
    }

    function holderAt(int256 index)
    external
    view
    returns (address){
        return shareholders.at(index);
    }

    function isHolder(address addr)
    external
    view
    returns (bool) {
        return shareholders.exists(addr);
    }


    // -------------------------------- Private --------------------------------

    function transferTokens(address from, address to, uint256 tokens)
    private {
        // Update balances
        balances[from] = balances[from].subtract(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);

        // Adds the shareholder if they don&#39;t already exist.
        if (balances[to] > 0 && shareholders.append(to)) {
            emit ShareholderAdded(to);
        }
        // Remove the shareholder if they no longer hold tokens.
        if (balances[from] == 0 && shareholders.remove(from)) {
            emit ShareholderRemoved(from);
        }
    }

}