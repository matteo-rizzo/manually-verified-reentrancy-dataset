// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}








contract LnAdmin {
    address public admin;
    address public candidate;

    constructor(address _admin) public {
        require(_admin != address(0), "admin address cannot be 0");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit candidateChanged( old, candidate);
    }

    function becomeAdmin( ) external {
        require( msg.sender == candidate, "Only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged( old, admin ); 
    }

    modifier onlyAdmin {
        require( (msg.sender == admin), "Only the contract admin can perform this action");
        _;
    }

    event candidateChanged(address oldCandidate, address newCandidate );
    event AdminChanged(address oldAdmin, address newAdmin);
}

contract LnProxyBase is LnAdmin {
    LnProxyImpl public target;

    constructor(address _admin) public LnAdmin(_admin) {}

    function setTarget(LnProxyImpl _target) external onlyAdmin {
        target = _target;
        emit TargetUpdated(_target);
    }

    function Log0( bytes calldata callData ) external onlyTarget {
        uint size = callData.length;
        bytes memory _callData = callData;
        assembly {
            log0(add(_callData, 32), size)
        }
    }

    function Log1( bytes calldata callData, bytes32 topic1 ) external onlyTarget {
        uint size = callData.length;
        bytes memory _callData = callData;
        assembly {
            log1(add(_callData, 32), size, topic1 )
        }
    }

    function Log2( bytes calldata callData, bytes32 topic1, bytes32 topic2 ) external onlyTarget {
        uint size = callData.length;
        bytes memory _callData = callData;
        assembly {
            log2(add(_callData, 32), size, topic1, topic2 )
        }
    }

    function Log3( bytes calldata callData, bytes32 topic1, bytes32 topic2, bytes32 topic3 ) external onlyTarget {
        uint size = callData.length;
        bytes memory _callData = callData;
        assembly {
            log3(add(_callData, 32), size, topic1, topic2, topic3 )
        }
    }

    function Log4( bytes calldata callData, bytes32 topic1, bytes32 topic2, bytes32 topic3, bytes32 topic4 ) external onlyTarget {
        uint size = callData.length;
        bytes memory _callData = callData;
        assembly {
            log4(add(_callData, 32), size, topic1, topic2, topic3, topic4 )
        }
    }

    //receive: It is executed on a call to the contract with empty calldata. This is the function that is executed on plain Ether transfers (e.g. via .send() or .transfer()).
    //fallback: can only rely on 2300 gas being available,
    receive() external payable {
        target.setMessageSender(msg.sender);

        assembly {
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize())

            let result := call(gas(), sload(target_slot), callvalue(), free_ptr, calldatasize(), 0, 0)
            returndatacopy(free_ptr, 0, returndatasize())

            if iszero(result) {
                revert(free_ptr, returndatasize())
            }
            return(free_ptr, returndatasize())
        }
    }

    modifier onlyTarget {
        require(LnProxyImpl(msg.sender) == target, "Must be proxy target");
        _;
    }

    event TargetUpdated(LnProxyImpl newTarget);
}


abstract contract LnProxyImpl is LnAdmin {
    
    LnProxyBase public proxy;
    LnProxyBase public integrationProxy;

    address public messageSender;

    constructor(address payable _proxy) internal {
        
        require(admin != address(0), "Admin must be set");

        proxy = LnProxyBase(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address payable _proxy) external onlyAdmin {
        proxy = LnProxyBase(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setIntegrationProxy(address payable _integrationProxy) external onlyAdmin {
        integrationProxy = LnProxyBase(_integrationProxy);
    }

    function setMessageSender(address sender) external onlyProxy {
        messageSender = sender;
    }

    modifier onlyProxy {
        require(LnProxyBase(msg.sender) == proxy || LnProxyBase(msg.sender) == integrationProxy, "Only the proxy can call");
        _;
    }

    modifier optionalProxy {
        if (LnProxyBase(msg.sender) != proxy && LnProxyBase(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        _;
    }

    modifier optionalProxy_onlyAdmin {
        if (LnProxyBase(msg.sender) != proxy && LnProxyBase(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == admin, "only for admin");
        _;
    }

    event ProxyUpdated(address proxyAddress);
}

contract LnErc20Handler is IERC20, LnAdmin, LnProxyImpl {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    LnTokenStorage public tokenStorage;

    string public override name;
    string public override symbol;
    uint public override totalSupply;
    uint8 public override decimals;

    constructor( address payable _proxy, LnTokenStorage _tokenStorage, string memory _name, 
        string memory _symbol, uint _totalSupply, uint8 _decimals, address _admin ) 
        public LnAdmin(_admin) LnProxyImpl(_proxy) {
        
        tokenStorage = _tokenStorage;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return tokenStorage.allowance(owner, spender);
    }

    function balanceOf(address account) external view override returns (uint) {
        return tokenStorage.balanceOf(account);
    }

    function setTokenStorage(LnTokenStorage _tokenStorage) external optionalProxy_onlyAdmin {
        tokenStorage = _tokenStorage;
        emitTokenStorageUpdated(address(tokenStorage));
    }

    function _internalTransfer( address from, address to, uint value ) internal returns (bool) {
        
        require(to != address(0) && to != address(this) && to != address(proxy), "Cannot transfer to this address");
        _beforeTokenTransfer(from, to, value);

        tokenStorage.setBalanceOf(from, tokenStorage.balanceOf(from).sub(value));
        tokenStorage.setBalanceOf(to, tokenStorage.balanceOf(to).add(value));

        emitTransfer(from, to, value);

        return true;
    }

    function _transferByProxy(
        address from,
        address to,
        uint value
    ) internal returns (bool) {
        return _internalTransfer(from, to, value);
    }

    function _transferFromByProxy(
        address sender,
        address from,
        address to,
        uint value
    ) internal returns (bool) {
        
        tokenStorage.setAllowance(from, sender, tokenStorage.allowance(from, sender).sub(value));
        return _internalTransfer(from, to, value);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    // default transfer
    function transfer(address to, uint value) external virtual override optionalProxy returns (bool) {
        _transferByProxy(messageSender, to, value);

        return true;
    }
    
    // default transferFrom
    function transferFrom(
        address from,
        address to,
        uint value
    ) external virtual override optionalProxy returns (bool) {
        return _transferFromByProxy(messageSender, from, to, value);
    }


    function approve(address spender, uint value) public virtual override optionalProxy returns (bool) {
        address sender = messageSender;

        tokenStorage.setAllowance(sender, spender, value);
        emitApproval(sender, spender, value);
        return true;
    }

    function addressToBytes32(address input) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(input)));
    }

    event Transfer(address indexed from, address indexed to, uint value);
    bytes32 internal constant TRANSFER_SIG = keccak256("Transfer(address,address,uint256)");

    function emitTransfer(
        address from,
        address to,
        uint value
    ) internal {
        proxy.Log3( abi.encode(value),  TRANSFER_SIG, addressToBytes32(from), addressToBytes32(to) );
    }

    event Approval(address indexed owner, address indexed spender, uint value);
    bytes32 internal constant APPROVAL_SIG = keccak256("Approval(address,address,uint256)");

    function emitApproval(
        address owner,
        address spender,
        uint value
    ) internal {
        proxy.Log3( abi.encode(value),  APPROVAL_SIG, addressToBytes32(owner), addressToBytes32(spender) );
    }

    event TokenStorageUpdated(address newTokenStorage);
    bytes32 internal constant TOKENSTORAGE_UPDATED_SIG = keccak256("TokenStorageUpdated(address)");

    function emitTokenStorageUpdated(address newTokenStorage) internal {
        proxy.Log1( abi.encode(newTokenStorage), TOKENSTORAGE_UPDATED_SIG );
    }
}


abstract contract LnOperatorModifier is LnAdmin {
    
    address public operator;

    constructor(address _operator) internal {
        require(admin != address(0), "admin must be set");

        operator = _operator;
        emit OperatorUpdated(_operator);
    }

    function setOperator(address _opperator) external onlyAdmin {
        operator = _opperator;
        emit OperatorUpdated(_opperator);
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator can perform this action");
        _;
    }

    event OperatorUpdated(address operator);
}



contract LnTokenStorage is LnAdmin, LnOperatorModifier {
    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(address _admin, address _operator) public LnAdmin(_admin) LnOperatorModifier(_operator) {}

    function setAllowance(address tokenOwner, address spender, uint value) external onlyOperator {
        allowance[tokenOwner][spender] = value;
    }

    function setBalanceOf(address account, uint value) external onlyOperator {
        balanceOf[account] = value;
    }
}



contract LinearFinance is LnErc20Handler {
    
    string public constant TOKEN_NAME = "Linear Token";
    string public constant TOKEN_SYMBOL = "LINA";
    uint8 public constant DECIMALS = 18;

    constructor(
        address payable _proxy,
        LnTokenStorage _tokenStorage,
        address _admin,
        uint _totalSupply
    )
        public
        LnErc20Handler(_proxy, _tokenStorage, TOKEN_NAME, TOKEN_SYMBOL, _totalSupply, DECIMALS, _admin)
    {
    }
    
    //
    function _mint(address account, uint256 amount) private  {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);

        tokenStorage.setBalanceOf(account, tokenStorage.balanceOf(account).add(amount));
        totalSupply = totalSupply.add(amount);

        emitTransfer(address(0), account, amount);
    }

    function mint(address account, uint256 amount) external onlyAdmin {
        _mint(account, amount);
    }

   function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);

        tokenStorage.setBalanceOf(account, tokenStorage.balanceOf(account).sub(amount));
        totalSupply = totalSupply.sub(amount);
        emitTransfer(account, address(0), amount);
    }

    //function burn(address account, uint256 amount) external onlyAdmin {
    //    _burn(account, amount);
    //}

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused, "ERC20Pausable: token transfer while paused");
    }

    ////////////////////////////////////////////////////// paused
    bool public paused = false;
    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
    function setPaused(bool _paused) external onlyAdmin {
        if (_paused == paused) {
            return;
        }
        paused = _paused;
        emit PauseChanged(paused);
    }

    //////////////////////////////////////////////////////
    event PauseChanged(bool isPaused);
}