/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// import "./IERC20.sol";
/////////////////////////////////////////////////////////////////////////////////

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */



//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// import "../Roles.sol";
/////////////////////////////////////////////////////////////////////////////////
pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */




//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// 
/////////////////////////////////////////////////////////////////////////////////


contract TrustedRole {
    using Roles for Roles.Role;

    event TrustedAdded(address indexed account);
    event TrustedRemoved(address indexed account);

    Roles.Role private _trusted;

    constructor () internal {
        _addTrusted(msg.sender);
    }

    modifier onlyTrusted() {
        require(isTrusted(msg.sender), "TrusRole: caller does not have the Minter role");
        _;
    }

    function isTrusted(address account) public view returns (bool) {
        return _trusted.has(account);
    }

    function addTrusted(address account) public onlyTrusted {
        _addTrusted(account);
    }

    function renounceMinter() public {
        _removeTrusted(msg.sender);
    }

    function _addTrusted(address account) internal {
        _trusted.add(account);
        emit TrustedAdded(account);
    }

    function _removeTrusted(address account) internal {
        _trusted.remove(account);
        emit TrustedRemoved(account);
    }
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// PiramidTemplate Interface
/////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// PiramidTemplate
/////////////////////////////////////////////////////////////////////////////////
contract PiramidV1Manadge is TrustedRole{
    
    event SetNewOwner(address Who, address What);
    
    address private _owner;
    mapping (string=>IPiramid) Piramids;
    bool private initComplite = false;
    
    constructor() public payable{
        _owner = msg.sender;
    }
    
    function () external payable {
        
        if(msg.value>0){
            address payable owner = address(uint160(_owner));
            owner.transfer(address(this).balance);
            //address(uint160(owner)).transfer(address(this).balance);
        }
    }
    
    modifier onlyOwner() {
        require(_owner!=msg.sender, "Piramid: caller not owner");
        _;
    }
    
    function addTrustedByOwner(address account) public onlyTrusted {
        _addTrusted(account);
    }
     
    function setOwner(address account) public onlyTrusted payable {
        emit SetNewOwner(msg.sender, account);
        _owner = address(account);
    }
    
    
    function initAll(address _pir1, address _pir2, address _pir3) public onlyTrusted payable{
        require(!initComplite, 'Already initialization!');
        
        string memory NamePir = 'beginner';
        Piramids[NamePir] = IPiramid(_pir1);
        pirSetTrustDoInit(NamePir, address(this));
        pirInitValue(NamePir, NamePir, 6, 5, _owner, _owner, _owner);
        pirSetSumLevel(NamePir, 0, uint(500000000000000));
        pirSetSumLevel(NamePir, 1, uint(750000000000000));
        pirSetSumLevel(NamePir, 2, uint(350000000000000));
        pirSetSumLevel(NamePir, 3, uint(500000000000000));
        pirSetSumLevel(NamePir, 4, uint(750000000000000));
        pirSetSumLevel(NamePir, 5, uint(900000000000000));
        pirSetSumLevel(NamePir, 6, uint(1250000000000000));
        
        NamePir = 'middle';
        Piramids[NamePir] = IPiramid(_pir2);
        pirSetTrustDoInit(NamePir, address(this));
        pirInitValue(NamePir, NamePir, 8, 4, _owner, _owner, _owner);
        pirSetSumLevel(NamePir, 0, uint(2000000000000000));
        pirSetSumLevel(NamePir, 1, uint(3500000000000000));
        pirSetSumLevel(NamePir, 2, uint(1250000000000000));
        pirSetSumLevel(NamePir, 3, uint(1750000000000000));
        pirSetSumLevel(NamePir, 4, uint(2000000000000000));
        pirSetSumLevel(NamePir, 5, uint(2750000000000000));
        pirSetSumLevel(NamePir, 6, uint(3250000000000000));
        pirSetSumLevel(NamePir, 7, uint(3500000000000000));
        pirSetSumLevel(NamePir, 8, uint(5000000000000000));
        
        NamePir = 'big';
        Piramids[NamePir] = IPiramid(_pir3);
        pirSetTrustDoInit(NamePir, address(this));
        pirInitValue(NamePir, NamePir, 7, 7, _owner, _owner, _owner);
        pirSetSumLevel(NamePir, 0, uint(40000000000000000));
        pirSetSumLevel(NamePir, 1, uint(60000000000000000));
        pirSetSumLevel(NamePir, 2, uint(25000000000000000));
        pirSetSumLevel(NamePir, 3, uint(35000000000000000));
        pirSetSumLevel(NamePir, 4, uint(45000000000000000));
        pirSetSumLevel(NamePir, 5, uint(65000000000000000));
        pirSetSumLevel(NamePir, 6, uint(90000000000000000));
        pirSetSumLevel(NamePir, 7, uint(140000000000000000));
        initComplite = true;
    }
        
    
    function initAllSmall(address _pir1, address _pir2, address _pir3) public onlyTrusted payable{
        require(!initComplite, 'Already initialization!');
        
        string memory NamePir = 'beginner';
        Piramids[NamePir] = IPiramid(_pir1);
        
        NamePir = 'middle';
        Piramids[NamePir] = IPiramid(_pir2);
        
        NamePir = 'big';
        Piramids[NamePir] = IPiramid(_pir3);
        
        initComplite = true;
    }
    
    function GameOver() public onlyOwner payable {
        selfdestruct(address(uint160(_owner)));
    }
    
    function transferAnyERC20Token(IERC20 tokenAddress, address toaddr, uint tokens) public onlyTrusted returns (bool success) {
        return IERC20(tokenAddress).transfer(toaddr, tokens);
    }
    
    function setNewAddressPir(string memory _namepirm, address _account) public onlyTrusted {
        
        Piramids[_namepirm] = IPiramid(_account);
    }
    
    function getAddreesPir(string memory _namepir) public view returns (address AddressPiramid){
        
        return address(Piramids[_namepir]);
    }
    
    
    function addTrustedToAll(address account) public onlyTrusted{
        
        pirAddTrusted('beginner', account);
        
        pirAddTrusted('middle', account);
        
        pirAddTrusted('big', account);
    }
    
    function pirSetTrustDoInit(string memory _namepir, address account) public onlyTrusted {
        
        require(!initComplite, 'Already complite');
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].setTrustDoInit.selector, account);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.setTrustDoInit: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            //////
        }
    }
    
    
    function pirAddTrusted(string memory _namepir, address account) public onlyTrusted returns (bool result){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].addTrusted.selector, account);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.addTrusted: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (bool));
        }
    }
    
    function pirInitValue(string memory _namepir, string memory _namepiramid, int _levels, int _countatlevel, address _feeaddr, address _feeaddr2, address _firstaddr) internal {
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].initValue.selector, _namepiramid, _levels, _countatlevel, _feeaddr, _feeaddr2, _firstaddr);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.initValue: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            /////
        }
    }
    
    function pirSetSumLevel(string memory _namepir, int _level, uint sum) internal {
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].setSumLevel.selector, _level, sum);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.setSumLevel: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            //////
        }
        
    }
    
    function pirGetFullSumPay(string memory _namepir) public returns(uint retSum){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getFullSumPay.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getFullSumPay: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (uint));
        }
    }
    
    
    function pirCheckPresentAddr(string memory _namepir, address account) public returns (bool result){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].checkPresentAddr.selector, account);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.checkPresentAddr: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (bool));
        }
    }
    
    function pirGetName(string memory _namepir) public returns (string memory name){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getName.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getName: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (string));
        }
    }
    
    
    function pirGetLevels(string memory _namepir) public returns (int _Levels){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getLevels.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getLevels: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (int));
        }
    }
    
    
    function pirGetSlotsOnLevel(string memory _namepir) public returns(int _SlotsOnLevel){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getSlotsOnLevel.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getSlotsOnLevel: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (int));
        }
    }
    
    
    function pirGetSumOneLevel(string memory _namepir, int _level) public returns(uint _SlotsOnLevel){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getSumOneLevel.selector, _level);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getSumOneLevel: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (uint));
        }
    }
    
    
    function pirGetInfoByAddr(string memory _namepir, address _addr) public returns(address _parentaddr, address _realpositionaddr, address _thisaddr, int _countchildren, uint _countallref){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getInfoByAddr.selector, _addr);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getInfoByAddr: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (address, address, address, int, uint));
        }
    }
    
    
    
    function pirGetInfoByAddrAnLevel(string memory _namepir, address _addr, int _level) public returns(address _thisaddr, uint _allslots, uint _freeslots, uint _paidslots, uint _paidamount){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getInfoByAddrAnLevel.selector, _addr, _level);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getInfoByAddrAnLevel: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (address, uint, uint, uint, uint));
        }
    }

    
    function pirGetPartner(string memory _namepir, int _idPartner) public returns(address _addrPartner, uint _percentPartner, int _idPartnerRet, uint _Paid){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getPartner.selector, _idPartner);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getPartner: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (address, uint, int, uint));
        }
    }
    
    function pirGetFeeSums(string memory _namepir) public returns(uint _Payments1, uint _Payments2){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getFeeSums.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getFeeSums: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (uint, uint));
        }
    }
    
    
    function pirGetBlockPayment(string memory _namepir, address _addr) public returns(bool _Result){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getBlockPayment.selector, _addr);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getBlockPayment: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (bool));
        }
    }
}