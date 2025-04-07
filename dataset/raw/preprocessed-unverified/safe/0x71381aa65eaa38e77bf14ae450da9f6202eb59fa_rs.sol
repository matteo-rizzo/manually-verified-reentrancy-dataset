/**
 *Submitted for verification at Etherscan.io on 2021-08-20
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.2;





abstract contract ERC165 is IERC165 {
    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(type(IERC165).interfaceId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract NFTBridgeTransfers is Context, ERC165 {

    address payable public bankVault;
    address public nftVault;
    address public NFT2DAddress;
    address public NFT3DAddress;
    uint256 public gasFee;
    address public unlocker;
    mapping (uint8 => address) public managers;
    mapping (bytes32 => bool) public executedTask;

    uint16 public taskIndex;
    
    uint256 public depositIndex;
    
    struct Deposit {
        uint256 assetId;
        address sender;
        uint128 value;
        uint32 lastTrade;
        uint32 lastPayment;
        uint32 typeDetail;
        uint32 customDetails;
    } 
    
    mapping (uint256 => Deposit) public deposits;
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    
    modifier isManager() {
        require(managers[0] == msg.sender || managers[1] == msg.sender || managers[2] == msg.sender, "Not manager");
        _;
    }
    
    constructor() {
        NFT2DAddress = 0x57E9a39aE8eC404C08f88740A9e6E306f50c937f;
        NFT3DAddress = 0xB20217bf3d89667Fa15907971866acD6CcD570C8;
        bankVault = payable(0xf7A9F6001ff8b499149569C54852226d719f2D76);
        nftVault = address(this);
        
        managers[0] = msg.sender;
        managers[1] = 0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec;
        managers[2] = 0xB1A951141F1b3A16824241f687C3741459E33225;
        gasFee = (1 gwei)*70000;
        
        _registerInterface(_ERC721_RECEIVED);
    }

    function bridgeSend(uint256 _assetId, address _nftAddress) public payable returns (bool) {
        require((_nftAddress == NFT2DAddress) || (_nftAddress == NFT3DAddress), "Invalid NFT Contract");
        require(msg.value >= gasFee, "Invalid gas fee");
        Address.sendValue(bankVault, msg.value);
        uint32 assetType;
        uint32 lastTransfer;
        uint32 lastPayment;
        uint32 customDetails;
        uint256 value;
        if (_nftAddress == NFT2DAddress) {
            (value, assetType, customDetails, lastTransfer, lastPayment ) = NFT2D(NFT2DAddress).getTokenDetails(_assetId);
        } else {
            (assetType, customDetails, lastTransfer, lastPayment, value, ) = NFT3D(NFT3DAddress).getTokenDetails(_assetId);
        }
        deposits[depositIndex].assetId = _assetId;
        deposits[depositIndex].sender = msg.sender;
        deposits[depositIndex].value = uint128(value);
        deposits[depositIndex].lastTrade = lastTransfer;
        deposits[depositIndex].lastPayment = lastPayment;
        deposits[depositIndex].typeDetail = assetType;
        deposits[depositIndex].customDetails = customDetails;
        depositIndex += 1;
        IERC721(_nftAddress).safeTransferFrom(msg.sender, nftVault, _assetId);
        return true;
    }
    
    function setBankVault(address _vault, bytes memory _sig) public isManager {
        uint8 mId = 1;
        bytes32 taskHash = keccak256(abi.encode(_vault, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        bankVault = payable(_vault);
    }
    
    function setGasFee(uint256 _fee, bytes memory _sig) public isManager {
        uint8 mId = 2;
        bytes32 taskHash = keccak256(abi.encode(_fee, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        gasFee = _fee;
    }
    
    function setUnlocker(address _unlocker, bytes memory _sig) public isManager {
        uint8 mId = 3;
        bytes32 taskHash = keccak256(abi.encode(_unlocker, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        unlocker = _unlocker;
    }
    
    function setUnlockerApproval(bool _approval, bytes memory _sig) public isManager {
        uint8 mId = 4;
        bytes32 taskHash = keccak256(abi.encode(_approval, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        IERC721(NFT2DAddress).setApprovalForAll(unlocker, _approval);
        IERC721(NFT3DAddress).setApprovalForAll(unlocker, _approval);
    }
    
    function verifyApproval(bytes32 _taskHash, bytes memory _sig) private {
        require(executedTask[_taskHash] == false, "Task already executed");
        address mSigner = ECDSA.recover(ECDSA.toEthSignedMessageHash(_taskHash), _sig);
        require(mSigner == managers[0] || mSigner == managers[1] || mSigner == managers[2], "Invalid signature"  );
        require(mSigner != msg.sender, "Signature from different managers required");
        executedTask[_taskHash] = true;
        taskIndex += 1;
    }
    
    function changeManager(address _manager, uint8 _index, bytes memory _sig) public isManager {
        require(_index >= 0 && _index <= 2, "Invalid index");
        uint8 mId = 100;
        bytes32 taskHash = keccak256(abi.encode(_manager, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        managers[_index] = _manager;
    }
    

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public returns (bytes4) {
        return _ERC721_RECEIVED;
    }
    

    
}