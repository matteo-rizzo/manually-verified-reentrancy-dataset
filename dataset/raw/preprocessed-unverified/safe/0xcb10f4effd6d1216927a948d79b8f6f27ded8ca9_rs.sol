/**
 *Submitted for verification at Etherscan.io on 2021-07-15
*/

// File: contracts/NFTMultiMint.sol

pragma solidity ^0.5.0;






contract NFTBANK1155 is Ownable{
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);
    using SafeMath for uint256;
         // id => (owner => balance)
    mapping (uint256 => mapping(address => uint256)) internal balances;

    mapping (uint256 => address) public _creator;

    // owner => (operator => approved)
    mapping (address => mapping(address => bool)) internal operatorApproval;
    mapping(uint256 => string) private _tokenURIs;

    mapping (uint256 => uint256) public _royal; 
    string public name;
    string public symbol;

     constructor(string memory _name, string memory _symbol) public{
        name = _name;
        symbol = _symbol;
    }
    function _transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        transferOwnership(newOwner);
       
    }
    function safeTransferFrom(address _from, address _to, uint256 _id,uint256  _value) public onlyOwner{
        require(_to != address(0x0), "_to must be non-zero.");
        require(_from == msg.sender || operatorApproval[_creator[_id]][owner()] == true, "Need operator approval for 3rd party transfers.");

        balances[_id][_from] = balances[_id][_from].sub(_value);
        balances[_id][_to]   = _value.add(balances[_id][_to]);

        // MUST emit event
        emit TransferSingle(msg.sender, _from, _to, _id, _value);

    }

    function balanceOf(address _owner, uint256 _id) public view returns (uint256) {
        // The balance of any account can be calculated from the Transfer events history.
        // However, since we need to keep the balances to validate transfer request,
        // there is no extra cost to also privide a querry function.
        return balances[_id][_owner];
    }

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address from, address _operator, bool _approved) public onlyOwner{
        operatorApproval[from][_operator] = _approved;
        emit ApprovalForAll(from, _operator, _approved);
    }

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the Tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApproval[_owner][_operator];
    }
    function mint(address from, uint256 _id, uint256 _supply, string memory _uri) public onlyOwner{
        require(_creator[_id] == address(0x0), "Token is already minted");
        require(_supply != 0, "Supply should be positive");
        require(bytes(_uri).length > 0, "uri should be set");

        _creator[_id] = from;
        balances[_id][from] = _supply;
        _setTokenURI(_id, _uri);
        emit TransferSingle(msg.sender, address(0x0), from, _id, _supply);
    }
      function _setTokenURI(uint256 tokenId, string memory uri) internal onlyOwner{
        _tokenURIs[tokenId] = uri;
        emit URI(uri, tokenId);
    }

    function burn(address from, address admin, uint256 _id, uint256 _value) public onlyOwner{
        require(balances[_id][from] <= _value || from == owner(), "Only Burn Allowed Token Owner or Admin or insuficient Token Balance");
        require(operatorApproval[_creator[_id]][admin] == true, "Need operator approval for 3rd party burns.");
        balances[_id][from] = balances[_id][from].sub(_value);
        // MUST emit event
        emit TransferSingle(from, from, address(0x0), _id, _value);
    }
}
contract NFTMultiMint is NFTBANK1155{
    string public name;
    string public symbol;

    mapping (uint256 => string) private _tokenURIs;

    constructor(string memory _name, string memory _symbol) NFTBANK1155(name, symbol) public{
        name = _name;
        symbol = _symbol;
    }
}