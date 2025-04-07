/**
 *Submitted for verification at Etherscan.io on 2021-09-22
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the initial owner.
     */
    function initializeOwnable(address ownerAddr_) internal {
        _setOwner(ownerAddr_);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



struct OriginalToken {
    uint256 chainId;
    address addr;
}

contract EthTeleportAgent is Ownable, Initializable {
    using SafeERC20 for IERC20;
    using Address for address;

    mapping(uint256/*fromChainId*/ => mapping(uint256/*fromChainTeleportId*/ => bool/*finished*/)) public finishedTeleports;
    mapping(uint256/*original chain id*/ => mapping(address/*original token address*/ => address/*wrapped token address*/)) public originalToWrappedTokens;
    mapping(address/*wrapped token address*/ => OriginalToken) public wrappedToOriginalTokens;
    
    address public signOwner;
    address public feeOwner;
    address public wrappedTokenImplementation;
    address public wrappedTokenAdmin;
    
    uint256 public teleportIdGenerator;
    uint256 public teleportFee;
    
    string private constant ERROR_ALREADY_EXECUTED = "already executed";
    string private constant ERROR_MINT_FAILED = "mint failed";
    
    event SetSignOwner(
        address indexed oldValue,
        address indexed newValue);
        
    event SetFeeOwner(
        address indexed oldValue,
        address indexed newValue);
        
    event SetTeleportFee(
        uint256 oldValue,
        uint256 newValue);
        
    event SetWrappedTokenAdmin(
        address indexed oldValue,
        address indexed newValue);
    
    event WrappedTokenCreated(
        address indexed sponsor,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed wrappedTokenAddr,
        string name,
        string symbol,
        uint8 decimals);

    event TeleportStarted(
        uint256 teleportId,
        address indexed sender,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed tokenAddr,
        uint256 amount,
        uint256 toChainId,
        address recipient,
        uint256 feeAmount);

    event TeleportFinished(
        address indexed recipient,
        uint256 fromChainId,
        uint256 fromChainTeleportId,
        uint256 originalTokenChainId,
        address indexed originalTokenAddr,
        address indexed tokenAddr,
        uint256 amount);
        
    event TeleportCancelStarted(
        uint256 fromChainId,
        uint256 fromChainTeleportId);
        
    event TeleportCancelFinished(
        uint256 teleportId,
        address tokenAddr,
        uint256 amount,
        address recipient);

    function initialize(
        address payable _ownerAddr,
        address _signOwner,
        address _feeOwner,
        uint256 _teleportFee,
        address _wrappedTokenImpl,
        address _wrappedTokenAdmin) external virtual initializer {
            
        _ensureNotZeroAddress(_ownerAddr);
        _ensureNotZeroAddress(_signOwner);
        _ensureNotZeroAddress(_feeOwner);
        _ensureNotZeroAddress(_wrappedTokenImpl);

        initializeOwnable(_ownerAddr);

        signOwner = _signOwner;
        emit SetSignOwner(address(0), _signOwner);
        
        feeOwner = _feeOwner;
        emit SetFeeOwner(address(0), _feeOwner);
        
        teleportFee = _teleportFee;
        emit SetTeleportFee(0, _teleportFee);
        
        wrappedTokenImplementation = _wrappedTokenImpl;
        
        wrappedTokenAdmin = _wrappedTokenAdmin;
        emit SetWrappedTokenAdmin(address(0), _wrappedTokenAdmin);
    }
    
    function setSignOwner(address _signOwner) onlyOwner external {
        _ensureNotZeroAddress(_signOwner);
        require(signOwner != _signOwner, ERROR_ALREADY_EXECUTED);
        emit SetSignOwner(signOwner, _signOwner);
        signOwner = _signOwner;
    }
    
    function setFeeOwner(address _feeOwner) onlyOwner external {
        _ensureNotZeroAddress(_feeOwner);
        require(feeOwner != _feeOwner, ERROR_ALREADY_EXECUTED);
        emit SetFeeOwner(feeOwner, _feeOwner);
        feeOwner = _feeOwner;
    }

    function setTeleportFee(uint256 _teleportFee) onlyOwner external {
        require(teleportFee != _teleportFee, ERROR_ALREADY_EXECUTED);
        emit SetTeleportFee(teleportFee, _teleportFee);
        teleportFee = _teleportFee;
    }
    
    function setWrappedTokenAdmin(address _wrappedTokenAdmin) onlyOwner external {
        _ensureNotZeroAddress(_wrappedTokenAdmin);
        require(wrappedTokenAdmin != _wrappedTokenAdmin, ERROR_ALREADY_EXECUTED);
        emit SetWrappedTokenAdmin(wrappedTokenAdmin, _wrappedTokenAdmin);
        wrappedTokenAdmin = _wrappedTokenAdmin;
    }
    
    /**
     * @dev This function is called by the oracle to create wrapped token in present chain.
     * Wrapped token will represent the original token from another chain.
     * This function is optional but it will reduce the cost of the first {teleportFinish} function call
     * for given token pair.
     */
    function createWrappedToken(
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals) onlyOwner external {
        
        _createWrappedToken(
            _originalTokenChainId,
            _originalTokenAddr,
            _name,
            _symbol,
            _decimals);
    }
    
    /**
     * @dev This function is called by the user to create wrapped token in present chain.
     * Wrapped token will represent the original token from another chain.
     * This function is optional but it will reduce the cost of the first {teleportFinish} function call
     * for given token pair.
     * All parameters of this function are signed with oracle private key. The signature is passed in
     * {_signature} parameter.
     */
    function createWrappedToken(
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        bytes calldata _signature) external {
        
        string memory message = string(abi.encodePacked(
            _toAsciiString(_msgSender()), ";",
            _uintToString(_originalTokenChainId), ";",
            _toAsciiString(_originalTokenAddr), ";",
            _name, ";",
            _symbol, ";",
            _uintToString(_decimals)));
            
        _verify(message, _signature);
        
        _createWrappedToken(
            _originalTokenChainId,
            _originalTokenAddr,
            _name,
            _symbol,
            _decimals);
    }
    
    function _createWrappedToken(
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        string memory _name,
        string memory _symbol,
        uint8 _decimals) private returns (address) {
            
        _ensureNotZeroAddress(_originalTokenAddr);
        require(block.chainid != _originalTokenChainId, "can't create wrapped token in original chain");
        require(originalToWrappedTokens[_originalTokenChainId][_originalTokenAddr] == address(0), "already created");
        
        address msgSender = _msgSender();

        address wrappedToken = _deployMinimalProxy(wrappedTokenImplementation);
        IWrappedToken(wrappedToken).initialize(_name, _symbol, _decimals, address(this), wrappedTokenAdmin);
        
        originalToWrappedTokens[_originalTokenChainId][_originalTokenAddr] = wrappedToken;
        wrappedToOriginalTokens[wrappedToken] = OriginalToken({chainId: _originalTokenChainId, addr: _originalTokenAddr});
        
        emit WrappedTokenCreated(
            msgSender,
            _originalTokenChainId,
            _originalTokenAddr,
            wrappedToken,
            _name,
            _symbol,
            _decimals);
            
        return wrappedToken;
    }
    

    /**
     * @dev Anyone can call this function to start the token teleportation process.
     * It either freezes the {_tokenAddr} tokens on the bridge or burns them and emits a signal to the oracle.
     */
    function teleportStart(address _tokenAddr, uint256 _amount, uint256 _toChainId, address _recipient) payable external {
        _ensureNotZeroAddress(_tokenAddr);
        _ensureNotZeroAddress(_recipient);
        require(_amount > 0, "zero amount");
        require(msg.value >= teleportFee, "fee mismatch");

        if (msg.value != 0) {
            (bool sent, ) = feeOwner.call{value: msg.value}("");
            require(sent, "fee send failed");
        }
        
        address msgSender = _msgSender();
        
        OriginalToken storage originalToken = wrappedToOriginalTokens[_tokenAddr];
        
        if (originalToken.addr == address(0)) { // teleportable token {_tokenAddr} is original token
            IERC20(_tokenAddr).safeTransferFrom(msgSender, address(this), _amount);
        
            emit TeleportStarted(
                ++teleportIdGenerator,
                msgSender,
                block.chainid,
                _tokenAddr,
                _tokenAddr,
                _amount,
                _toChainId,
                _recipient,
                msg.value);
            
            return;
        }
        
        // teleportable token {_tokenAddr} is wrapped token
            
        require(IWrappedToken(_tokenAddr).burnFrom(msgSender, _amount), "burn failed");
        
        emit TeleportStarted(
            ++teleportIdGenerator,
            msgSender,
            originalToken.chainId,
            originalToken.addr,
            _tokenAddr,
            _amount,
            _toChainId,
            _recipient,
            msg.value);
    }
    
    /**
     * @dev This function is called by the oracle to finish the token teleportation process.
     * The required admount of tokens is minted or unfreezed to {_toAddress} address in present chain.
     */
    function teleportFinish(
        uint256 _fromChainId,
        uint256 _fromChainTeleportId,
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _recipient,
        uint256 _amount) onlyOwner external {
            
        _teleportFinish(
            _fromChainId,
            _fromChainTeleportId,
            _originalTokenChainId,
            _originalTokenAddr,
            _name,
            _symbol,
            _decimals,
            _recipient,
            _amount);
    }
    
    /**
     * @dev This function is called by the user to finish the token teleportation process.
     * All parameters of this function are signed with oracle private key. The signature is passed in
     * {_signature} parameter.
     * The required admount of tokens is minted or unfreezed to {_toAddress} address in present chain.
     */
    function teleportFinish(
        uint256 _fromChainId,
        uint256 _fromChainTeleportId,
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _amount,
        bytes memory _signature) external {
        
        address recipient = _msgSender();
        
        string memory message = string(abi.encodePacked(
            _toAsciiString(recipient), ";",
            _uintToString(_fromChainId), ";",
            _uintToString(_fromChainTeleportId), ";",
            _uintToString(_originalTokenChainId), ";",
            _toAsciiString(_originalTokenAddr), ";",
            _name, ";",
            _symbol, ";",
            _uintToString(_decimals), ";",
            _uintToString(_amount)));
            
        _verify(message, _signature);
        
        _teleportFinish(
            _fromChainId,
            _fromChainTeleportId,
            _originalTokenChainId,
            _originalTokenAddr,
            _name,
            _symbol,
            _decimals,
            recipient,
            _amount);
    }
    
    function _teleportFinish(
        uint256 _fromChainId,
        uint256 _fromChainTeleportId,
        uint256 _originalTokenChainId,
        address _originalTokenAddr,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _recipient,
        uint256 _amount) private {
            
        _ensureNotZeroAddress(_originalTokenAddr);
        _ensureNotZeroAddress(_recipient);
            
        require(!finishedTeleports[_fromChainId][_fromChainTeleportId], ERROR_ALREADY_EXECUTED);
        finishedTeleports[_fromChainId][_fromChainTeleportId] = true;
            
        address tokenAddr;
    
        if (_originalTokenChainId == block.chainid) {
            IERC20(_originalTokenAddr).safeTransfer(_recipient, _amount);
            tokenAddr = _originalTokenAddr;
        } else {
            tokenAddr = originalToWrappedTokens[_originalTokenChainId][_originalTokenAddr];
            
            if (tokenAddr == address(0)) {
                tokenAddr = _createWrappedToken(
                    _originalTokenChainId,
                    _originalTokenAddr,
                    _name,
                    _symbol,
                    _decimals);
            }
            
            require(IWrappedToken(tokenAddr).mintTo(_recipient, _amount), ERROR_MINT_FAILED);
        }
        
        emit TeleportFinished(
            _recipient,
            _fromChainId,
            _fromChainTeleportId,
            _originalTokenChainId,
            _originalTokenAddr,
            tokenAddr,
            _amount);
    }
    
    function teleportCancelStart(uint256 _fromChainId, uint256 _fromChainTeleportId) onlyOwner external {
        require(!finishedTeleports[_fromChainId][_fromChainTeleportId], ERROR_ALREADY_EXECUTED);
        finishedTeleports[_fromChainId][_fromChainTeleportId] = true;
        
        emit TeleportCancelStarted(_fromChainId, _fromChainTeleportId);
    }
    
    function teleportCancelFinish(
        uint256 _teleportId,
        address _tokenAddr,
        uint256 _amount,
        address _recipient) onlyOwner external {
            
        OriginalToken storage originalToken = wrappedToOriginalTokens[_tokenAddr];
        
        if (originalToken.addr == address(0)) { // {_tokenAddr} is original token
            IERC20(_tokenAddr).safeTransfer(_recipient, _amount);
        } else { // {_tokenAddr} is wrapped token
            require(IWrappedToken(_tokenAddr).mintTo(_recipient, _amount), ERROR_MINT_FAILED);
        }

        emit TeleportCancelFinished(_teleportId, _tokenAddr, _amount, _recipient);
    }

    function _deployMinimalProxy(address _logic) private returns (address proxy) {
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(_logic);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }
    
    function _verify(string memory _message, bytes memory _sig) private view {
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(_message))));
        address messageSigner = _recover(messageHash, _sig);

        require(messageSigner == signOwner, "verification failed");
    }

    function _recover(bytes32 _hash, bytes memory _sig) private pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        require(_sig.length == 65, "_recover: invalid sig size");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "_recover: invalid sig");

        return ecrecover(_hash, v, r, s);
    }

    function _uintToString(uint _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _toAsciiString(address _addr) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(_addr)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = _char(hi);
            s[2 * i + 1] = _char(lo);
        }
        return string(s);
    }

    function _char(bytes1 value) private pure returns (bytes1) {
        return (uint8(value) < 10) ? bytes1(uint8(value) + 0x30) : bytes1(uint8(value) + 0x57);
    }
    
    function _ensureNotZeroAddress(address _address) private pure {
        require(_address != address(0), "zero address");
    }
}