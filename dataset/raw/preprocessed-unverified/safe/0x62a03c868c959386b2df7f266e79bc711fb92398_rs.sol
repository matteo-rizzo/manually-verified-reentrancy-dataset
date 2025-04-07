pragma solidity ^0.4.18;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract BatchTransfer is Ownable {
    using SafeMath for uint256;
    event TransferToken(address indexed from, address indexed to, uint256 value);
    Token public standardToken;
    // List of admins
    mapping (address => bool) public contractAdmins;
    mapping (address => bool) public userTransfered;
    uint256 public totalUserTransfered;

    function BatchTransfer(address _owner) public {
        require(_owner != address(0));
        owner = _owner;
        owner = msg.sender; //for test
    }

    function setContractToken (address _addressContract) public onlyOwner {
        require(_addressContract != address(0));
        standardToken = Token(_addressContract);
        totalUserTransfered = 0;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return standardToken.balanceOf(_owner);
    }

    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner || contractAdmins[msg.sender]);
        _;
    }

    /**
    * @dev Add an contract admin
    */
    function setContractAdmin(address _admin, bool _isAdmin) public onlyOwner {
        contractAdmins[_admin] = _isAdmin;
    }

    /* Batch token transfer. Used by contract creator to distribute initial tokens to holders */
    function batchTransfer(address[] _recipients, uint256[] _values) external onlyOwnerOrAdmin returns (bool) {
        require( _recipients.length > 0 && _recipients.length == _values.length);
        uint256 total = 0;
        for(uint i = 0; i < _values.length; i++){
            total = total.add(_values[i]);
        }
        require(total <= standardToken.balanceOf(msg.sender));
        for(uint j = 0; j < _recipients.length; j++){
            standardToken.transfer(_recipients[j], _values[j]);
            totalUserTransfered = totalUserTransfered.add(1);
            userTransfered[_recipients[j]] = true;
            TransferToken(msg.sender, _recipients[j], _values[j]);
        }
        return true;
    }
}