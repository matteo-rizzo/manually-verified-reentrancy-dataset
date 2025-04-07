/**

 *Submitted for verification at Etherscan.io on 2019-03-19

*/



pragma solidity 0.5.4;















/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Beneficiary is Ownable {



    address payable public beneficiary;



    constructor(address _secondary) public Ownable(_secondary) {

        beneficiary = msg.sender;

    }



    function setBeneficiary(address payable _beneficiary) public onlyOwner {

        beneficiary = _beneficiary;

    }



    function withdrawal(uint256 value) public onlyOwner {

        if (value > address(this).balance) {

            revert("Insufficient balance");

        }



        beneficiaryPayout(value);

    }



    function withdrawalAll() public onlyOwner {

        beneficiaryPayout(address(this).balance);

    }



    function withdrawERC20Token(address payable _erc20, uint value) public onlyOwner {

        require(IERC20(_erc20).transfer(beneficiary, value));

        emit BeneficiaryERC20Payout(_erc20, value);

    }



    function beneficiaryPayout(uint256 value) internal {

        beneficiary.transfer(value);

        emit BeneficiaryPayout(value);

    }



    function beneficiaryERC20Payout(IERC20 _erc20, uint256 value) internal {

        _erc20.transfer(beneficiary, value);

        emit BeneficiaryERC20Payout(address(_erc20), value);

    }



    event BeneficiaryPayout(uint256 value);

    event BeneficiaryERC20Payout(address tokenAddress, uint256 value);

}



contract Manageable is Beneficiary {



    uint256 DECIMALS = 10e8;



    bool maintenance = false;



    mapping(address => bool) public managers;



    modifier onlyManager() {



        require(managers[msg.sender] || msg.sender == address(this), "Only managers allowed");

        _;

    }



    modifier notOnMaintenance() {

        require(!maintenance);

        _;

    }



    constructor(address _secondary) public  Beneficiary(_secondary) {

        managers[msg.sender] = true;

    }



    function setMaintenanceStatus(bool _status) public onlyManager {

        maintenance = _status;

        emit Maintenance(_status);

    }



    function setManager(address _manager) public onlyOwnerOrSecondary {

        managers[_manager] = true;

    }



    function deleteManager(address _manager) public onlyOwnerOrSecondary {

        delete managers[_manager];

    }



    event Maintenance(bool status);



    event FailedPayout(address to, uint256 value);



}



contract LockableToken is Manageable {

    mapping(uint256 => bool) public locks;



    modifier onlyNotLocked(uint256 _tokenId) {

        require(!locks[_tokenId]);

        _;

    }



    function isLocked(uint256 _tokenId) public view returns (bool) {

        return locks[_tokenId];

    }



    function lockToken(uint256 _tokenId) public onlyManager {

        locks[_tokenId] = true;

    }



    function unlockToken(uint256 _tokenId) public onlyManager {

        locks[_tokenId] = false;

    }



    function _lockToken(uint256 _tokenId) internal {

        locks[_tokenId] = true;

    }



    function _unlockToken(uint256 _tokenId) internal {

        locks[_tokenId] = false;

    }



}



contract ERC721 is Manageable, LockableToken, IERC721 {



    using Strings for string;



    mapping(address => uint256) public balances;

    mapping(uint256 => address) public approved;

    mapping(address => mapping(address => bool)) private operators;

    mapping(uint256 => address) private tokenOwner;



    uint256 public totalSupply = 0;



    string private _tokenURI = "";



    modifier onlyTokenOwner(uint256 _tokenId) {

        require(msg.sender == tokenOwner[_tokenId]);

        _;

    }



    function setBaseTokenURI(string memory _newTokenURI) public onlyManager {

        _tokenURI = _newTokenURI;

    }



    function ownerOf(uint256 _tokenId) public view returns (address) {

        return tokenOwner[_tokenId];

    }



    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyNotLocked(_tokenId) {

        require(_isApprovedOrOwner(msg.sender, _tokenId));



        _transfer(_from, _to, _tokenId);

    }



    function approve(address _approved, uint256 _tokenId) public onlyNotLocked(_tokenId)  {

        address owner = ownerOf(_tokenId);

        require(_approved != owner);

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



        approved[_tokenId] = _approved;



        emit Approval(owner, _approved, _tokenId);

    }





    function setApprovalForAll(address _operator, bool _approved) public {

        require(_operator != msg.sender);



        operators[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);

    }



    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return operators[_owner][_operator];

    }



    function getApproved(uint256 _tokenId) public view returns (address) {

        return approved[_tokenId];

    }



    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];

    }





    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);

        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

    }



    function transfer(address  _from, address  _to, uint256 _tokenId) public onlyTokenOwner(_tokenId) onlyNotLocked(_tokenId) {

        _transfer(_from, _to, _tokenId);

    }



    function _transfer(address  _from, address  _to, uint256 _tokenId) internal {

        require(ownerOf(_tokenId) == _from);



        delete approved[_tokenId];



        if(_from != address(0)) {

            balances[_from]--;

        } else {

            totalSupply++;

        }



        if(_to != address(0)) {

            balances[_to]++;

        }



        tokenOwner[_tokenId] = _to;



        emit Transfer(_from, _to, _tokenId);

    }



    function _mint(uint256 _tokenId, address _owner) internal {

        _transfer(address(0), _owner, _tokenId);

    }



    function _burn(uint256 _tokenId) internal {

        _transfer(ownerOf(_tokenId), address(0), _tokenId);

    }





    function baseTokenURI() public view returns (string memory) {

        return _tokenURI;

    }



    function tokenURI(uint256 _tokenId) external view returns (string memory) {

        return Strings.strConcat(

            baseTokenURI(),

            Strings.uint2str(_tokenId)

        );

    }





    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);





}







contract Citizen is Manageable, ERC721 {



    struct Token {

        uint8[7] special;

        uint8 generation;

        bytes32 look;

    }



    Token[] public tokens;



    constructor(address _secondary) public Manageable(_secondary) {}



    function mint(address _owner, uint8[7] memory _special, uint8 _generation, bytes32 _look) public onlyManager returns (uint256){

        tokens.push(Token(_special, _generation, _look));

        _mint(tokens.length - 1, _owner);

        return tokens.length - 1;

    }



    function incSpecial(uint256 _tokenId, uint8 _specId) public onlyManager {

        require(_specId < 8 && tokens[_tokenId].special[_specId] < 12);



        emit SpecChanged(_tokenId, _specId, tokens[_tokenId].special[_specId]);

    }



    function decSpecial(uint256 _tokenId, uint8 _specId) public onlyManager {

        require(_specId < 8 && tokens[_tokenId].special[_specId] > 0);



        tokens[_tokenId].special[_specId]--;

        emit SpecChanged(_tokenId, _specId, tokens[_tokenId].special[_specId]);

    }



    function getSpecial(uint256 _tokenId) public view returns (uint8[7] memory) {

        return tokens[_tokenId].special;

    }



    function setLook(uint256 _tokenId, bytes32 _look) public onlyManager {

        tokens[_tokenId].look = _look;

    }



    function burn(uint256 _tokenId) public onlyManager {

        _burn(_tokenId);

    }





    event SpecChanged(uint256 _tokenId, uint8 _specId, uint8 _value);



}