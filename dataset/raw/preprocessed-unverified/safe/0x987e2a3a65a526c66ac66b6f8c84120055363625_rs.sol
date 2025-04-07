/**
 *Submitted for verification at Etherscan.io on 2021-09-25
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

// File: contracts/intf/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/intf/IWETH.sol





// File: contracts/CollateralVault/intf/ICollateralVault.sol




// File: contracts/DODOVendingMachine/intf/IDVM.sol




// File: contracts/GeneralizedFragment/intf/IFragment.sol




// File: contracts/Factory/Registries/DODONFTRegistry.sol




/**
 * @title DODONFT Registry
 * @author DODO Breeder
 *
 * @notice Register DODONFT Pools 
 */
contract DODONFTRegistry is InitializableOwnable, IDODONFTRegistry {

    mapping (address => bool) public isAdminListed;
    
    // ============ Registry ============
    // Vault -> Frag
    mapping(address => address) public _VAULT_FRAG_REGISTRY_;

    // base -> quote -> DVM address list
    mapping(address => mapping(address => address[])) public _REGISTRY_;

    // ============ Events ============

    event NewRegistry(
        address vault,
        address fragment,
        address dvm
    );

    event RemoveRegistry(address fragment);


    // ============ Admin Operation Functions ============

    function addRegistry(
        address vault,
        address fragment, 
        address quoteToken,
        address dvm
    ) override external {
        require(isAdminListed[msg.sender], "ACCESS_DENIED");
        _VAULT_FRAG_REGISTRY_[vault] = fragment;
        _REGISTRY_[fragment][quoteToken].push(dvm);
        emit NewRegistry(vault, fragment, dvm);
    }

    function removeRegistry(address fragment) override external {
        require(isAdminListed[msg.sender], "ACCESS_DENIED");
        address vault = IFragment(fragment)._COLLATERAL_VAULT_();
        address dvm = IFragment(fragment)._DVM_();

        _VAULT_FRAG_REGISTRY_[vault] = address(0);

        address quoteToken = IDVM(dvm)._QUOTE_TOKEN_();
        address[] memory registryList = _REGISTRY_[fragment][quoteToken];
        for (uint256 i = 0; i < registryList.length; i++) {
            if (registryList[i] == dvm) {
                if(i != registryList.length - 1) {
                    _REGISTRY_[fragment][quoteToken][i] = _REGISTRY_[fragment][quoteToken][registryList.length - 1];
                }                
                _REGISTRY_[fragment][quoteToken].pop();
                break;
            }
        }

        emit RemoveRegistry(fragment);
    }

    function addAdminList (address contractAddr) external onlyOwner {
        isAdminListed[contractAddr] = true;
    }

    function removeAdminList (address contractAddr) external onlyOwner {
        isAdminListed[contractAddr] = false;
    }

    function getDODOPool(address baseToken, address quoteToken)
        external
        view
        returns (address[] memory pools)
    {
        return _REGISTRY_[baseToken][quoteToken];
    }

    function getDODOPoolBidirection(address token0, address token1)
        external
        view
        returns (address[] memory baseToken0Pool, address[] memory baseToken1Pool)
    {
        return (_REGISTRY_[token0][token1], _REGISTRY_[token1][token0]);
    }
}

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

// File: contracts/SmartRoute/proxies/DODONFTProxy.sol



/**
 * @title DODONFTProxy
 * @author DODO Breeder
 *
 * @notice Entrance of NFT in DODO platform
 */
contract DODONFTProxy is ReentrancyGuard, InitializableOwnable {
    using SafeMath for uint256;


    // ============ Storage ============

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;
    address public immutable _DODO_APPROVE_PROXY_;
    address public immutable _CLONE_FACTORY_;
    address public immutable _NFT_REGISTY_;

    address public _DEFAULT_MAINTAINER_;
    address public _MT_FEE_RATE_MODEL_;
    address public _VAULT_TEMPLATE_;
    address public _FRAG_TEMPLATE_;
    address public _DVM_TEMPLATE_;
    address public _BUYOUT_MODEL_;

    // ============ Events ============
    event ChangeVaultTemplate(address newVaultTemplate);
    event ChangeFragTemplate(address newFragTemplate);
    event ChangeDvmTemplate(address newDvmTemplate);
    event ChangeMtFeeRateTemplate(address newMtFeeRateTemplate);
    event ChangeBuyoutModel(address newBuyoutModel);
    event ChangeMaintainer(address newMaintainer);
    event CreateNFTCollateralVault(address creator, address vault, string name, string baseURI);
    event CreateFragment(address vault, address fragment, address dvm);
    event Buyout(address from, address fragment, uint256 amount);

    // ============ Modifiers ============

    modifier judgeExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "DODONFTProxy: EXPIRED");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    constructor(
        address cloneFactory,
        address payable weth,
        address dodoApproveProxy,
        address defaultMaintainer,
        address buyoutModel,
        address mtFeeRateModel,
        address vaultTemplate,
        address fragTemplate,
        address dvmTemplate,
        address nftRegistry
    ) public {
        _CLONE_FACTORY_ = cloneFactory;
        _WETH_ = weth;
        _DODO_APPROVE_PROXY_ = dodoApproveProxy;
        _DEFAULT_MAINTAINER_ = defaultMaintainer;
        _MT_FEE_RATE_MODEL_ = mtFeeRateModel;
        _BUYOUT_MODEL_ = buyoutModel;
        _VAULT_TEMPLATE_ = vaultTemplate;
        _FRAG_TEMPLATE_ = fragTemplate;
        _DVM_TEMPLATE_ = dvmTemplate;
        _NFT_REGISTY_ = nftRegistry;
    }

    function createNFTCollateralVault(string memory name, string memory baseURI) external returns (address newVault) {
        newVault = ICloneFactory(_CLONE_FACTORY_).clone(_VAULT_TEMPLATE_);
        ICollateralVault(newVault).init(msg.sender, name, baseURI);
        emit CreateNFTCollateralVault(msg.sender, newVault, name, baseURI);
    }
    
    function createFragment(
        address[] calldata addrList, //0 - quoteToken, 1 - vaultPreOwner
        uint256[] calldata params, //(DVM: 0 - lpFeeRate 1 - I, 2 - K) , (FRAG: 3 - totalSupply, 4 - ownerRatio, 5 - buyoutTimestamp, 6 - distributionRatio)
        bool isOpenTwap,
        string memory fragSymbol
    ) external returns (address newFragment, address newDvm) {
        newFragment = ICloneFactory(_CLONE_FACTORY_).clone(_FRAG_TEMPLATE_);
        address _quoteToken = addrList[0] == _ETH_ADDRESS_ ? _WETH_ : addrList[0];
        
        {
        uint256[] memory  _params = params;
        
        newDvm = ICloneFactory(_CLONE_FACTORY_).clone(_DVM_TEMPLATE_);
        IDVM(newDvm).init(
            _DEFAULT_MAINTAINER_,
            newFragment,
            _quoteToken,
            _params[0],
            _MT_FEE_RATE_MODEL_,
            _params[1],
            _params[2],
            isOpenTwap
        );
        IFragment(newFragment).init(
            newDvm, 
            addrList[1], 
            msg.sender, 
            _params[3], 
            _params[4], 
            _params[5],
            _DEFAULT_MAINTAINER_,
            _BUYOUT_MODEL_,
            _params[6],
            fragSymbol
        );
        }

        ICollateralVault(msg.sender).directTransferOwnership(newFragment);
        
        IDODONFTRegistry(_NFT_REGISTY_).addRegistry(msg.sender, newFragment, _quoteToken, newDvm);

        emit CreateFragment(msg.sender, newFragment, newDvm);
    }

    function buyout(
        address fragment,
        uint256 quoteMaxAmount,
        uint8 flag, // 0 - ERC20, 1 - quoteInETH
        uint256 deadLine
    ) external payable preventReentrant judgeExpired(deadLine) {
        if(flag == 0)
            require(msg.value == 0, "DODONFTProxy: WE_SAVED_YOUR_MONEY");
        
        address dvm = IFragment(fragment)._DVM_();
        uint256 fragTotalSupply = IFragment(fragment).totalSupply();
        uint256 buyPrice = IDVM(dvm).getMidPrice();

        uint256 curRequireQuote = DecimalMath.mulCeil(buyPrice, fragTotalSupply);

        require(curRequireQuote <= quoteMaxAmount, "DODONFTProxy: CURRENT_TOTAL_VAULE_MORE_THAN_QUOTEMAX");

        _deposit(msg.sender, fragment, IFragment(fragment)._QUOTE_(), curRequireQuote, flag == 1);
        IFragment(fragment).buyout(msg.sender);

        // IDODONFTRegistry(_NFT_REGISTY_).removeRegistry(fragment);

        // refund dust eth
        if (flag == 1 && msg.value > curRequireQuote) msg.sender.transfer(msg.value - curRequireQuote);

        emit Buyout(msg.sender, fragment, curRequireQuote);
    }

    //============= Owner ===================
    function updateVaultTemplate(address newVaultTemplate) external onlyOwner {
        _VAULT_TEMPLATE_ = newVaultTemplate;
        emit ChangeVaultTemplate(newVaultTemplate);
    }

    function updateFragTemplate(address newFragTemplate) external onlyOwner {
        _FRAG_TEMPLATE_ = newFragTemplate;
        emit ChangeFragTemplate(newFragTemplate);
    }

    function updateMtFeeRateTemplate(address newMtFeeRateTemplate) external onlyOwner {
        _MT_FEE_RATE_MODEL_ = newMtFeeRateTemplate;
        emit ChangeMtFeeRateTemplate(newMtFeeRateTemplate);
    }

    function updateDvmTemplate(address newDvmTemplate) external onlyOwner {
        _DVM_TEMPLATE_ = newDvmTemplate;
        emit ChangeDvmTemplate(newDvmTemplate);
    }

    function updateBuyoutModel(address newBuyoutModel) external onlyOwner {
        _BUYOUT_MODEL_ = newBuyoutModel;
        emit ChangeBuyoutModel(newBuyoutModel);
    }

    function updateMaintainer(address newMaintainer) external onlyOwner {
        _DEFAULT_MAINTAINER_ = newMaintainer;
        emit ChangeMaintainer(newMaintainer);
    }


    //============= Internal ================

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