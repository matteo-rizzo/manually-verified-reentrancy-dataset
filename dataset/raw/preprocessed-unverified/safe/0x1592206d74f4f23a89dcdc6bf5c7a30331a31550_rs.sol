/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity 0.5.17;






/// @title ERC-165 Standard Interface Detection
/// @dev See https://eips.ethereum.org/EIPS/eip-165
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

interface IERC173 /* is ERC165 */ {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    function owner() external view returns (address);

    /// @notice Set the address of the new owner of the contract
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

contract ERC173 is IERC173, ERC165  {
    address private _owner;

    constructor() public {
        _registerInterface(0x7f5828d0);
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Must be owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner() {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        address previousOwner = owner();
	_owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}

contract Operatable is ERC173 {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    Roles.Role private operators;

    constructor() public {
        operators.add(msg.sender);
        _paused = false;
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender), "Must be operator");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOperator() {
        _transferOwnership(_newOwner);
    }

    function isOperator(address account) public view returns (bool) {
        return operators.has(account);
    }

    function addOperator(address account) public onlyOperator() {
        operators.add(account);
        emit OperatorAdded(account);
    }

    function removeOperator(address account) public onlyOperator() {
        operators.remove(account);
        emit OperatorRemoved(account);
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOperator() whenNotPaused() {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOperator() whenPaused() {
        _paused = false;
        emit Unpaused(msg.sender);
    }

}

contract MCHPrimeV2 is Operatable {

    address public validator;
    mapping (address => uint256) public lastSignedBlock;
    uint256 ableToBuyAfterRange;
    uint256 sigExpireBlock;

    event BuyPrimeRight(
        address indexed buyer,
        uint256 signedBlock,
        int64 signedAt
    );

    constructor(address _varidator) public {
        setValidater(_varidator);
        setBlockRanges(20000, 10000);
    }

    function setValidater(address _varidator) public onlyOperator() {
        validator = _varidator;
    }

    function setBlockRanges(uint256 _ableToBuyAfterRange, uint256 _sigExpireBlock) public onlyOperator() {
        ableToBuyAfterRange = _ableToBuyAfterRange;
        sigExpireBlock = _sigExpireBlock;
    }

    function isApplicableNow() public view returns (bool) {
        isApplicable(msg.sender, block.number, block.number);
    }

    function isApplicable(address _buyer, uint256 _blockNum, uint256 _currentBlock) public view returns (bool) {
        if (lastSignedBlock[_buyer] != 0) {
            if (_blockNum < lastSignedBlock[_buyer] + ableToBuyAfterRange) {
                return false;
            }
        }

        if (_blockNum >= _currentBlock + sigExpireBlock) {
            return false;
        }
        return true;
    }

    function buyPrimeRight(bytes calldata _signature, uint256 _blockNum, int64 _signedAt) external payable whenNotPaused() {
        require(isApplicable(msg.sender, _blockNum, block.number), "block num error");
        require(validateSig(msg.sender, _blockNum, _signedAt, msg.value, _signature), "invalid signature");
        lastSignedBlock[msg.sender] = _blockNum;
        emit BuyPrimeRight(msg.sender, _blockNum, _signedAt);
    }

    function validateSig(address _from, uint256 _blockNum, int64 _signedAt, uint256 _priceWei, bytes memory _signature) internal view returns (bool) {
        require(validator != address(0));
        address signer = recover(ethSignedMessageHash(encodeData(_from, _blockNum, _signedAt, _priceWei)), _signature);
        return (signer == validator);
    }

    function encodeData(address _from, uint256 _blockNum, int64 _signedAt, uint256 _priceWei) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                                _from,
                                _blockNum,
                                _signedAt,
                                _priceWei
                                )
                     );
    }

    function ethSignedMessageHash(bytes32 _data) internal pure returns (bytes32) {
        return ECDSA.toEthSignedMessageHash(_data);
    }

    function recover(bytes32 _data, bytes memory _signature) internal pure returns (address) {
        return ECDSA.recover(_data, _signature);
    }
}