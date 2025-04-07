/**
 *Submitted for verification at Etherscan.io on 2021-04-19
*/

// File: contracts/intf/IDODOApprove.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;



// File: contracts/lib/InitializableOwnable.sol


/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// File: contracts/SmartRoute/DODOApproveProxy.sol





/**
 * @title DODOApproveProxy
 * @author DODO Breeder
 *
 * @notice Allow different version dodoproxy to claim from DODOApprove
 */
contract DODOApproveProxy is InitializableOwnable {
    
    // ============ Storage ============
    uint256 private constant _TIMELOCK_DURATION_ = 3 days;
    mapping (address => bool) public _IS_ALLOWED_PROXY_;
    uint256 public _TIMELOCK_;
    address public _PENDING_ADD_DODO_PROXY_;
    address public immutable _DODO_APPROVE_;

    // ============ Modifiers ============
    modifier notLocked() {
        require(
            _TIMELOCK_ <= block.timestamp,
            "SetProxy is timelocked"
        );
        _;
    }

    constructor(address dodoApporve) public {
        _DODO_APPROVE_ = dodoApporve;
    }

    function init(address owner, address[] memory proxies) external {
        initOwner(owner);
        for(uint i = 0; i < proxies.length; i++) 
            _IS_ALLOWED_PROXY_[proxies[i]] = true;
    }

    function unlockAddProxy(address newDodoProxy) public onlyOwner {
        _TIMELOCK_ = block.timestamp + _TIMELOCK_DURATION_;
        _PENDING_ADD_DODO_PROXY_ = newDodoProxy;
    }

    function lockAddProxy() public onlyOwner {
       _PENDING_ADD_DODO_PROXY_ = address(0);
       _TIMELOCK_ = 0;
    }


    function addDODOProxy() external onlyOwner notLocked() {
        _IS_ALLOWED_PROXY_[_PENDING_ADD_DODO_PROXY_] = true;
        lockAddProxy();
    }

    function removeDODOProxy (address oldDodoProxy) public onlyOwner {
        _IS_ALLOWED_PROXY_[oldDodoProxy] = false;
    }
    
    function claimTokens(
        address token,
        address who,
        address dest,
        uint256 amount
    ) external {
        require(_IS_ALLOWED_PROXY_[msg.sender], "DODOApproveProxy:Access restricted");
        IDODOApprove(_DODO_APPROVE_).claimTokens(
            token,
            who,
            dest,
            amount
        );
    }

    function isAllowedProxy(address _proxy) external view returns (bool) {
        return _IS_ALLOWED_PROXY_[_proxy];
    }
}

// File: contracts/intf/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/intf/IWETH.sol





// File: contracts/lib/SafeMath.sol



/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// File: contracts/lib/SafeERC20.sol


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/lib/DecimalMath.sol



/**
 * @title DecimalMath
 * @author DODO Breeder
 *
 * @notice Functions for fixed point number with 18 decimals
 */


// File: contracts/lib/ReentrancyGuard.sol


/**
 * @title ReentrancyGuard
 * @author DODO Breeder
 *
 * @notice Protect functions from Reentrancy Attack
 */
contract ReentrancyGuard {
    // https://solidity.readthedocs.io/en/latest/control-structures.html?highlight=zero-state#scoping-and-declarations
    // zero-state of _ENTERED_ is false
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

// File: contracts/DODOStablePool/intf/IDSP.sol




// File: contracts/lib/CloneFactory.sol




// introduction of proxy mode design: https://docs.openzeppelin.com/upgrades/2.8/
// minimum implementation of transparent proxy: https://eips.ethereum.org/EIPS/eip-1167

contract CloneFactory is ICloneFactory {
    function clone(address prototype) external override returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}

// File: contracts/Factory/DSPFactory.sol







/**
 * @title DODO StablePool Factory
 * @author DODO Breeder
 *
 * @notice Create And Register DSP Pools
 */
contract DSPFactory is InitializableOwnable {
    // ============ Templates ============

    address public immutable _CLONE_FACTORY_;
    address public immutable _DEFAULT_MAINTAINER_;
    address public immutable _DEFAULT_MT_FEE_RATE_MODEL_;
    address public _DSP_TEMPLATE_;

    // ============ Registry ============

    // base -> quote -> DSP address list
    mapping(address => mapping(address => address[])) public _REGISTRY_;
    // creator -> DSP address list
    mapping(address => address[]) public _USER_REGISTRY_;

    // ============ Events ============

    event NewDSP(address baseToken, address quoteToken, address creator, address DSP);

    event RemoveDSP(address DSP);

    // ============ Functions ============

    constructor(
        address cloneFactory,
        address DSPTemplate,
        address defaultMaintainer,
        address defaultMtFeeRateModel
    ) public {
        _CLONE_FACTORY_ = cloneFactory;
        _DSP_TEMPLATE_ = DSPTemplate;
        _DEFAULT_MAINTAINER_ = defaultMaintainer;
        _DEFAULT_MT_FEE_RATE_MODEL_ = defaultMtFeeRateModel;
    }

    function createDODOStablePool(
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external returns (address newStablePool) {
        newStablePool = ICloneFactory(_CLONE_FACTORY_).clone(_DSP_TEMPLATE_);
        {
            IDSP(newStablePool).init(
                _DEFAULT_MAINTAINER_,
                baseToken,
                quoteToken,
                lpFeeRate,
                _DEFAULT_MT_FEE_RATE_MODEL_,
                i,
                k,
                isOpenTWAP
            );
        }
        _REGISTRY_[baseToken][quoteToken].push(newStablePool);
        _USER_REGISTRY_[tx.origin].push(newStablePool);
        emit NewDSP(baseToken, quoteToken, tx.origin, newStablePool);
    }

    // ============ Admin Operation Functions ============

    function updateDSPTemplate(address _newDSPTemplate) external onlyOwner {
        _DSP_TEMPLATE_ = _newDSPTemplate;
    }

    function addPoolByAdmin(
        address creator,
        address baseToken,
        address quoteToken,
        address pool
    ) external onlyOwner {
        _REGISTRY_[baseToken][quoteToken].push(pool);
        _USER_REGISTRY_[creator].push(pool);
        emit NewDSP(baseToken, quoteToken, creator, pool);
    }

    function removePoolByAdmin(
        address creator,
        address baseToken,
        address quoteToken,
        address pool
    ) external onlyOwner {
        address[] memory registryList = _REGISTRY_[baseToken][quoteToken];
        for (uint256 i = 0; i < registryList.length; i++) {
            if (registryList[i] == pool) {
                registryList[i] = registryList[registryList.length - 1];
                break;
            }
        }
        _REGISTRY_[baseToken][quoteToken] = registryList;
        _REGISTRY_[baseToken][quoteToken].pop();
        address[] memory userRegistryList = _USER_REGISTRY_[creator];
        for (uint256 i = 0; i < userRegistryList.length; i++) {
            if (userRegistryList[i] == pool) {
                userRegistryList[i] = userRegistryList[userRegistryList.length - 1];
                break;
            }
        }
        _USER_REGISTRY_[creator] = userRegistryList;
        _USER_REGISTRY_[creator].pop();
        emit RemoveDSP(pool);
    }

    // ============ View Functions ============

    function getDODOPool(address baseToken, address quoteToken)
        external
        view
        returns (address[] memory machines)
    {
        return _REGISTRY_[baseToken][quoteToken];
    }

    function getDODOPoolBidirection(address token0, address token1)
        external
        view
        returns (address[] memory baseToken0Machines, address[] memory baseToken1Machines)
    {
        return (_REGISTRY_[token0][token1], _REGISTRY_[token1][token0]);
    }

    function getDODOPoolByUser(address user) external view returns (address[] memory machines) {
        return _USER_REGISTRY_[user];
    }
}

// File: contracts/SmartRoute/proxies/DODODspProxy.sol


/**
 * @title DODODspProxy
 * @author DODO Breeder
 *
 * @notice Entrance of DODO Stable Pair in DODO platform
 */
contract DODODspProxy is ReentrancyGuard {
    using SafeMath for uint256;

    // ============ Storage ============

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;
    address public immutable _DODO_APPROVE_PROXY_;
    address public immutable _DSP_FACTORY_;

    // ============ Modifiers ============

    modifier judgeExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "DODODspProxy: EXPIRED");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    constructor(
        address dspFactory,
        address payable weth,
        address dodoApproveProxy
    ) public {
        _DSP_FACTORY_ = dspFactory;
        _WETH_ = weth;
        _DODO_APPROVE_PROXY_ = dodoApproveProxy;
    }

    // ============ DSP Functions (create & add liquidity) ============

    function createDODOStablePair(
        address baseToken,
        address quoteToken,
        uint256 baseInAmount,
        uint256 quoteInAmount,
        uint256 lpFeeRate,
        uint256 i,
        uint256 k,
        bool isOpenTWAP,
        uint256 deadLine
    )
        external
        payable
        preventReentrant
        judgeExpired(deadLine)
        returns (address newDODOStablePair, uint256 shares)
    {
        {
            address _baseToken = baseToken == _ETH_ADDRESS_ ? _WETH_ : baseToken;
            address _quoteToken = quoteToken == _ETH_ADDRESS_ ? _WETH_ : quoteToken;
            newDODOStablePair = IDSPFactory(_DSP_FACTORY_).createDODOStablePool(
                _baseToken,
                _quoteToken,
                lpFeeRate,
                i,
                k,
                isOpenTWAP
            );
        }

        {
            address _baseToken = baseToken;
            address _quoteToken = quoteToken;
            _deposit(
                msg.sender,
                newDODOStablePair,
                _baseToken,
                baseInAmount,
                _baseToken == _ETH_ADDRESS_
            );
            _deposit(
                msg.sender,
                newDODOStablePair,
                _quoteToken,
                quoteInAmount,
                _quoteToken == _ETH_ADDRESS_
            );
        }

        (shares, , ) = IDSP(newDODOStablePair).buyShares(msg.sender);
    }

    function addDSPLiquidity(
        address dspAddress,
        uint256 baseInAmount,
        uint256 quoteInAmount,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        uint8 flag, // 0 - ERC20, 1 - baseInETH, 2 - quoteInETH
        uint256 deadLine
    )
        external
        payable
        preventReentrant
        judgeExpired(deadLine)
        returns (
            uint256 shares,
            uint256 baseAdjustedInAmount,
            uint256 quoteAdjustedInAmount
        )
    {
        address _dsp = dspAddress;
        (baseAdjustedInAmount, quoteAdjustedInAmount) = _addDSPLiquidity(
            _dsp,
            baseInAmount,
            quoteInAmount
        );
        require(
            baseAdjustedInAmount >= baseMinAmount && quoteAdjustedInAmount >= quoteMinAmount,
            "DODODspProxy: deposit amount is not enough"
        );

        _deposit(msg.sender, _dsp, IDSP(_dsp)._BASE_TOKEN_(), baseAdjustedInAmount, flag == 1);
        _deposit(msg.sender, _dsp, IDSP(_dsp)._QUOTE_TOKEN_(), quoteAdjustedInAmount, flag == 2);
        
        (shares, , ) = IDSP(_dsp).buyShares(msg.sender);

        // refund dust eth
        if (flag == 1 && msg.value > baseAdjustedInAmount) msg.sender.transfer(msg.value - baseAdjustedInAmount);
        if (flag == 2 && msg.value > quoteAdjustedInAmount) msg.sender.transfer(msg.value - quoteAdjustedInAmount);
    }


    // =================== internal functions =====================

    function _addDSPLiquidity(
        address dspAddress,
        uint256 baseInAmount,
        uint256 quoteInAmount
    ) internal view returns (uint256 baseAdjustedInAmount, uint256 quoteAdjustedInAmount) {
        (uint256 baseReserve, uint256 quoteReserve) = IDSP(dspAddress).getVaultReserve();
        if (quoteReserve == 0 && baseReserve == 0) {
            uint256 i = IDSP(dspAddress)._I_();
            uint256 shares = quoteInAmount < DecimalMath.mulFloor(baseInAmount, i)
                ? DecimalMath.divFloor(quoteInAmount, i)
                : baseInAmount;
            baseAdjustedInAmount = shares;
            quoteAdjustedInAmount = DecimalMath.mulFloor(shares, i);
        }
        if (quoteReserve > 0 && baseReserve > 0) {
            uint256 baseIncreaseRatio = DecimalMath.divFloor(baseInAmount, baseReserve);
            uint256 quoteIncreaseRatio = DecimalMath.divFloor(quoteInAmount, quoteReserve);
            if (baseIncreaseRatio <= quoteIncreaseRatio) {
                baseAdjustedInAmount = baseInAmount;
                quoteAdjustedInAmount = DecimalMath.mulFloor(quoteReserve, baseIncreaseRatio);
            } else {
                quoteAdjustedInAmount = quoteInAmount;
                baseAdjustedInAmount = DecimalMath.mulFloor(baseReserve, quoteIncreaseRatio);
            }
        }
    }

    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).deposit{value: amount}();
                if (to != address(this)) SafeERC20.safeTransfer(IERC20(_WETH_), to, amount);
            }
        } else {
            IDODOApproveProxy(_DODO_APPROVE_PROXY_).claimTokens(token, from, to, amount);
        }
    }
}