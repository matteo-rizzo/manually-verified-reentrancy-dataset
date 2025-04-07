/**
 *Submitted for verification at Etherscan.io on 2021-08-13
*/

pragma solidity 0.6.6;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)






// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: UNLICENSED
abstract contract IMintableERC20 is IERC20 {
    function mint(uint amount) public virtual;
    function mintTo(address account, uint amount) public virtual;
    function burn(uint amount) public virtual;
    function setMinter(address account, bool isMinter) public virtual;
}

// SPDX-License-Identifier: UNLICENSED
abstract contract IRewardManager {
    function add(uint256 _allocPoint, address _newMlp) public virtual;
    function notifyDeposit(address _account, uint256 _amount) public virtual;
    function notifyWithdraw(address _account, uint256 _amount) public virtual;
    function getPoolSupply(address pool) public view virtual returns(uint);
    function getUserAmount(address pool, address user) public view virtual returns(uint);
}

// SPDX-License-Identifier: UNLICENSED
abstract contract IPopMarketplace {
    function submitMlp(address _token0, address _token1, uint _liquidity, uint _endDate, uint _bonusToken0, uint _bonusToken1) public virtual returns(uint);
    function endMlp(uint _mlpId) public virtual returns(uint);
    function cancelMlp(uint256 _mlpId) public virtual;
}

// SPDX-License-Identifier: UNLICENSED
abstract contract IFeesController {
    function feesTo() public view virtual returns (address);
    function setFeesTo(address) public virtual;

    function feesPpm() public view virtual returns (uint);
    function setFeesPpm(uint) public virtual;
}

// SPDX-License-Identifier: UNLICENSED


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: UNLICENSED
contract PopMarketplace is IFeesController, IPopMarketplace, Initializable, OwnableUpgradeSafe {
    using SafeERC20 for IERC20;
    address public uniswapFactory;
    address public uniswapRouter;
    address[] public allMlp;
    address private _feesTo;
    uint256 private _feesPpm;
    uint256 public pendingMlpCount;
    IRewardManager public rewardManager;
    IMintableERC20 public popToken;

    mapping(uint256 => PendingMlp) public getMlp;

    IMlpDeployer public mlpFactory;

    enum MlpStatus {PENDING, APPROVED, CANCELED, ENDED}

    struct PendingMlp {
        address uniswapPair;
        address submitter;
        uint256 liquidity;
        uint256 endDate;
        MlpStatus status;
        uint256 bonusToken0;
        uint256 bonusToken1;
    }

    event MlpCreated(uint256 id, address indexed mlp);
    event MlpSubmitted(uint256 id);
    event MlpCanceled(uint256 id);
    event ChangeFeesPpm(uint256 id);
    event ChangeFeesTo(address indexed feeTo);
    event MlpEnded(uint256 id);

    function initialize(
        address _popToken,
        address _uniswapFactory,
        address _uniswapRouter,
        address _rewardManager,
        address _mlpFactory
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        popToken = IMintableERC20(_popToken);
        uniswapFactory = _uniswapFactory;
        uniswapRouter = _uniswapRouter;
        rewardManager = IRewardManager(_rewardManager);
        mlpFactory = IMlpDeployer(_mlpFactory);
    }

    function setMlpFactory(address _mlpFactory) external onlyOwner {
        require(_mlpFactory != address(0), "!address0");
        mlpFactory = IMlpDeployer(_mlpFactory);
    }

    function submitMlp(
        address _token0,
        address _token1,
        uint256 _liquidity,
        uint256 _endDate,
        uint256 _bonusToken0,
        uint256 _bonusToken1
    ) public override returns (uint) {
        require(_endDate > now, "!datenow");
        if (IUniswapV2Factory(uniswapFactory).getPair(_token0, _token1) == address(0)) {
            IUniswapV2Factory(uniswapFactory).createPair(_token0, _token1);
        }
        IUniswapV2Pair pair =
            IUniswapV2Pair(
                UniswapV2Library.pairFor(uniswapFactory, _token0, _token1)
            );
        require(address(pair) != address(0), "!address0");

        if (_liquidity > 0) {
            IERC20(address(pair)).safeTransferFrom(
                msg.sender,
                address(this),
                _liquidity
            );
        }
        if (_bonusToken0 > 0) {
            IERC20(_token0).safeTransferFrom(
                msg.sender,
                address(this),
                _bonusToken0
            );
        }
        if (_bonusToken1 > 0) {
            IERC20(_token1).safeTransferFrom(
                msg.sender,
                address(this),
                _bonusToken1
            );
        }

        if (_token0 != pair.token0()) {
            uint256 tmp = _bonusToken0;
            _bonusToken0 = _bonusToken1;
            _bonusToken1 = tmp;
        }

        getMlp[pendingMlpCount++] = PendingMlp({
            uniswapPair: address(pair),
            submitter: msg.sender,
            liquidity: _liquidity,
            endDate: _endDate,
            status: MlpStatus.PENDING,
            bonusToken0: _bonusToken0,
            bonusToken1: _bonusToken1
        });
        uint256 mlpId = pendingMlpCount - 1;
        emit MlpSubmitted(mlpId);
        return mlpId;
    }

    function approveMlp(uint256 _mlpId, uint256 _allocPoint, IUniswapV2Pair safetyPair0, IUniswapV2Pair safetyPair1)
        external
        onlyOwner()
        returns (address mlpAddress)
    {
        PendingMlp storage pendingMlp = getMlp[_mlpId];
        require(pendingMlp.status == MlpStatus.PENDING, "Mlp status not pending!");
        require(block.timestamp < pendingMlp.endDate, "timestamp >= endDate");

        address token0 = IUniswapV2Pair(pendingMlp.uniswapPair).token0();
        address token1 = IUniswapV2Pair(pendingMlp.uniswapPair).token1();

        (bool isFirstTokenInPair0, bool isFirstTokenInPair1) = _checkPairs(token0, token1, safetyPair0, safetyPair1);

        mlpAddress = createMlp(
            pendingMlp.uniswapPair, 
            pendingMlp.submitter, 
            pendingMlp.endDate, 
            pendingMlp.bonusToken0, 
            pendingMlp.bonusToken1, 
            safetyPair0, 
            safetyPair1, 
            isFirstTokenInPair0, 
            isFirstTokenInPair1);

        rewardManager.add(_allocPoint, mlpAddress);
        allMlp.push(mlpAddress);
        IERC20(token0).safeTransfer(
            mlpAddress,
            pendingMlp.bonusToken0
        );
        IERC20(token1).safeTransfer(
            mlpAddress,
            pendingMlp.bonusToken1
        );

        pendingMlp.status = MlpStatus.APPROVED;
        emit MlpCreated(_mlpId, mlpAddress);

        return mlpAddress;
    }

    function createMlp(
        address uniswapPair, 
        address submitter, 
        uint256 endDate, 
        uint256 bonusToken0, 
        uint256 bonusToken1,
        IUniswapV2Pair safetyPair0,
        IUniswapV2Pair safetyPair1,
        bool isFirstTokenInPair0,
        bool isFirstTokenInPair1
    ) private returns (address) {

        address newMlp = mlpFactory.createMlp(
            address(this),
            uniswapPair,
            submitter,
            endDate,
            uniswapRouter,
            address(rewardManager),
            bonusToken0,
            bonusToken1,
            address(safetyPair0),
            address(safetyPair1),
            isFirstTokenInPair0,
            isFirstTokenInPair1,
            owner()
        );

        return newMlp;
    }

    function _checkPairs(address token0, address token1, IUniswapV2Pair pair0, IUniswapV2Pair pair1) private view returns (bool, bool) {
        (address pair0Token, bool isFirstTokenInPair0) = _checkPair(pair0, token0);
        (address pair1Token, bool isFirstTokenInPair1) = _checkPair(pair1, token1);

        require(pair0Token == pair1Token, "checkPairs: INCOMPATIBLE_PAIRS");

        return (isFirstTokenInPair0, isFirstTokenInPair1);
    }

    function _checkPair(IUniswapV2Pair pair, address forToken) private view returns (address pairedWith, bool isFirstTokenInPair) {
        address token0 = pair.token0();
        if (token0 == forToken) {
            pairedWith = pair.token1();
            isFirstTokenInPair = true;
        } else if (pair.token1() == forToken) {
            pairedWith = token0;
            isFirstTokenInPair = false;
        } else {
            revert("checkPair: INVALID_UNI_PAIR");
        }
    }

    function cancelMlp(uint256 _mlpId) public override {
        PendingMlp storage pendingMlp = getMlp[_mlpId];

        require(pendingMlp.submitter == msg.sender, "!submitter");
        require(pendingMlp.status == MlpStatus.PENDING, "!pending");

        if (pendingMlp.liquidity > 0) {
            IUniswapV2Pair pair = IUniswapV2Pair(pendingMlp.uniswapPair);
            IERC20(address(pair)).safeTransfer(
                pendingMlp.submitter,
                pendingMlp.liquidity
            );
        }

        if (pendingMlp.bonusToken0 > 0) {
            IERC20(IUniswapV2Pair(pendingMlp.uniswapPair).token0())
                .safeTransfer(pendingMlp.submitter, pendingMlp.bonusToken0);
        }
        if (pendingMlp.bonusToken1 > 0) {
            IERC20(IUniswapV2Pair(pendingMlp.uniswapPair).token1())
                .safeTransfer(pendingMlp.submitter, pendingMlp.bonusToken1);
        }

        pendingMlp.status = MlpStatus.CANCELED;
        emit MlpCanceled(_mlpId);
    }

    function setFeesTo(address _newFeesTo) public override onlyOwner {
        require(_newFeesTo != address(0), "!address0");
        _feesTo = _newFeesTo;
        emit ChangeFeesTo(_newFeesTo);
    }

    function feesTo() public view override returns (address) {
        return _feesTo;
    }

    function feesPpm() public view override returns (uint256) {
        return _feesPpm;
    }

    function setFeesPpm(uint256 _newFeesPpm) public override onlyOwner {
        require(_newFeesPpm > 0, "!<0");
        _feesPpm = _newFeesPpm;
        emit ChangeFeesPpm(_newFeesPpm);
    }

    function endMlp(uint256 _mlpId) public override returns (uint256) {
        PendingMlp storage pendingMlp = getMlp[_mlpId];

        require(pendingMlp.submitter == msg.sender, "!submitter");
        require(pendingMlp.status == MlpStatus.APPROVED, "!approved");
        require(block.timestamp >= pendingMlp.endDate, "not yet ended");

        if (pendingMlp.liquidity > 0) {
            IUniswapV2Pair pair = IUniswapV2Pair(pendingMlp.uniswapPair);
            IERC20(address(pair)).safeTransfer(
                pendingMlp.submitter,
                pendingMlp.liquidity
            );
        }

        pendingMlp.status = MlpStatus.ENDED;
        emit MlpEnded(_mlpId);
        return pendingMlp.liquidity;
    }
}