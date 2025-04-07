/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: AGPL V3.0

pragma solidity 0.6.12;



// Part: AddressUpgradeable

/**
 * @dev Collection of functions related to the address type
 */


// Part: IERC20Mintable



// Part: IERC20Upgradeable

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: IStakingPool



// Part: Initializable

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

// Part: MerkleProofUpgradeable

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// Part: SafeMathUpgradeable

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// Part: ContextUpgradeable

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
abstract contract ContextUpgradeable is Initializable {
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

// Part: ReentrancyGuardUpgradeable

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// Part: SafeERC20Upgradeable

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: OwnableUpgradeable

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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

// File: AdelVAkroSwap.sol

contract AdelVAkroSwap is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
 
    event AdelSwapped(address indexed receiver, uint256 adelAmount, uint256 akroAmount);

    enum AdelSource{ WALLET, STAKE, REWARDS }

    //Addresses of affected contracts
    address public akro;
    address public adel;
    address public vakro;
    address public stakingPool;
    address public rewardAkroPool;
    address public rewardAdelPool;

    //Swap settings
    uint256 public minAmountToSwap = 0;
    uint256 public swapRateNumerator = 0;   //Amount of vAkro for 1 ADEL - 0 by default
    uint256 public swapRateDenominator = 1; //Akro amount = Adel amount * swapRateNumerator / swapRateDenominator
                                            //1 Adel = swapRateNumerator/swapRateDenominator Akro

    bytes32[] public merkleRoots;
    mapping (address => uint256[3]) public swappedAdel;

    modifier swapEnabled() {
        require(swapRateNumerator != 0, "Swap is disabled");
        _;
    }

    modifier enoughAdel(uint256 _adelAmount) {
        require(_adelAmount > 0 && _adelAmount >= minAmountToSwap, "Insufficient ADEL amount");
        _;
    }

    function initialize(address _akro, address _adel, address _vakro) virtual public initializer {
        require(_akro != address(0), "Zero address");
        require(_adel != address(0), "Zero address");
        require(_vakro != address(0), "Zero address");

        __Ownable_init();

        akro = _akro;
        adel = _adel;
        vakro = _vakro;
    }    

    //Setters for the swap tuning

    /**
     * @notice Sets the ADEL staking pool address
     * @param _stakingPool Adel staking pool address)
     */
    function setStakingPool(address _stakingPool) external onlyOwner {
        require(_stakingPool != address(0), "Zero address");
        stakingPool = _stakingPool;
    }

    /**
     * @notice Sets the staking pool addresses with ADEL rewards
     * @param _rewardAkroPool Akro staking pool address)
     * @param _rewardAdelPool Adel staking pool address)
     */
    function setRewardStakingPool(address _rewardAkroPool, address _rewardAdelPool) external onlyOwner {
        require(_rewardAkroPool != address(0) || _rewardAdelPool != address(0), "Zero address");
        rewardAkroPool = _rewardAkroPool;
        rewardAdelPool = _rewardAdelPool;
    }

    /**
     * @notice Sets the minimum amount of ADEL which can be swapped. 0 by default
     * @param _minAmount Minimum amount in wei (the least decimals)
     */
    function setMinSwapAmount(uint256 _minAmount) external onlyOwner {
        minAmountToSwap = _minAmount;
    }

    /**
     * @notice Sets the rate of ADEL to vAKRO swap: 1 ADEL = _swapRateNumerator/_swapRateDenominator vAKRO
     * @notice By default is set to 0, that means that swap is disabled
     * @param _swapRateNumerator Numerator for Adel converting. Can be set to 0 - that stops the swap.
     * @param _swapRateDenominator Denominator for Adel converting. Can't be set to 0
     */
    function setSwapRate(uint256 _swapRateNumerator, uint256 _swapRateDenominator) external onlyOwner {
        require(_swapRateDenominator > 0, "Incorrect value");
        swapRateNumerator = _swapRateNumerator;
        swapRateDenominator = _swapRateDenominator;
    }

    /**
     * @notice Sets the Merkle roots
     * @param _merkleRoots Array of hashes
     */
    function setMerkleRoots(bytes32[] memory _merkleRoots) external onlyOwner {
        require(_merkleRoots.length > 0, "Incorrect data");
        if (merkleRoots.length > 0) {
            delete merkleRoots;
        }
        merkleRoots = new bytes32[](_merkleRoots.length);
        merkleRoots = _merkleRoots;
    }

    /**
     * @notice Withdraws all ADEL collected on a Swap contract
     * @param _recepient Recepient of ADEL.
     */
    function withdrawAdel(address _recepient) external onlyOwner {
        require(_recepient != address(0), "Zero address");
        uint256 _adelAmount = IERC20Upgradeable(adel).balanceOf(address(this));
        require(_adelAmount > 0, "Nothing to withdraw");
        IERC20Upgradeable(adel).safeTransfer(_recepient, _adelAmount);
    }

    /**
     * @notice Allows to swap ADEL token from the wallet for vAKRO
     * @param _adelAmount Amout of ADEL the user approves for the swap.
     * @param merkleRootIndex Index of a merkle root to be used for calculations
     * @param adelAllowedToSwap Maximum ADEL allowed for a user to swap
     * @param merkleProofs Array of consiquent merkle hashes
     */
    function swapFromAdel(
        uint256 _adelAmount,
        uint256 merkleRootIndex, 
        uint256 adelAllowedToSwap,
        bytes32[] memory merkleProofs
    ) 
        external nonReentrant swapEnabled enoughAdel(_adelAmount)
    {
        require(verifyMerkleProofs(_msgSender(), merkleRootIndex, adelAllowedToSwap, merkleProofs), "Merkle proofs not verified");

        IERC20Upgradeable(adel).safeTransferFrom(_msgSender(), address(this), _adelAmount);

        swap(_adelAmount, adelAllowedToSwap, AdelSource.WALLET);
    }
    

    /**
     * @notice Allows to swap ADEL token which is currently staked in StakingPool
     * @param merkleRootIndex Index of a merkle root to be used for calculations
     * @param adelAllowedToSwap Maximum ADEL allowed for a user to swap
     * @param merkleProofs Array of consiquent merkle hashes
     */
    function swapFromStakedAdel(
        uint256 merkleRootIndex, 
        uint256 adelAllowedToSwap,
        bytes32[] memory merkleProofs
    )
        external nonReentrant swapEnabled
    {
        require(stakingPool != address(0), "Swap from stake is disabled");

        require(verifyMerkleProofs(_msgSender(), merkleRootIndex, adelAllowedToSwap, merkleProofs), "Merkle proofs not verified");
        
        uint256 adelBefore = IERC20Upgradeable(adel).balanceOf(address(this));
        uint256 akroBefore = IERC20Upgradeable(akro).balanceOf(address(this));
        uint256 _adelAmount = IStakingPool(stakingPool).withdrawStakeForSwap(_msgSender(), adel, "0x");
        uint256 adelAfter = IERC20Upgradeable(adel).balanceOf(address(this));
        uint256 akroAfter = IERC20Upgradeable(akro).balanceOf(address(this));
        
        require( adelAfter - adelBefore == _adelAmount, "ADEL was not transferred");

        if (akroAfter - akroBefore > 0) {
            IERC20Upgradeable(akro).safeTransfer(_msgSender(), akroAfter - akroBefore);
        }
                
        swap(_adelAmount, adelAllowedToSwap, AdelSource.STAKE);
    }


    /**
     * @notice Allows to swap ADEL token which belongs to vested unclaimed rewards
     * @param merkleRootIndex Index of a merkle root to be used for calculations
     * @param adelAllowedToSwap Maximum ADEL allowed for a user to swap
     * @param merkleProofs Array of consiquent merkle hashes
     */
    function swapFromRewardAdel(
        uint256 merkleRootIndex, 
        uint256 adelAllowedToSwap,
        bytes32[] memory merkleProofs
    ) 
        external nonReentrant swapEnabled
    {
        require(rewardAkroPool != address(0) || rewardAdelPool != address(0), "Swap from rewards is disabled");

        require(verifyMerkleProofs(_msgSender(), merkleRootIndex, adelAllowedToSwap, merkleProofs), "Merkle proofs not verified");

        uint256 adelBefore;
        uint256 _adelAmount;
        uint256 adelAfter;
        uint256 adelReceived;

        //Withdraw ADEL rewards from AKRO staking pool
        if (rewardAkroPool != address(0))
        {
            adelBefore = IERC20Upgradeable(adel).balanceOf(address(this));
            _adelAmount = IStakingPool(rewardAkroPool).withdrawRewardForSwap(_msgSender(), adel);
            adelAfter = IERC20Upgradeable(adel).balanceOf(address(this));

            require( adelAfter - adelBefore == _adelAmount, "ADEL was not transferred from AKRO pool");

            adelReceived = adelReceived.add(_adelAmount);
        }

        //Withdraw ADEL rewards from ADEL staking pool
        if (rewardAdelPool != address(0))
        {
            adelBefore = IERC20Upgradeable(adel).balanceOf(address(this));
            _adelAmount = IStakingPool(rewardAdelPool).withdrawRewardForSwap(_msgSender(), adel);
            adelAfter = IERC20Upgradeable(adel).balanceOf(address(this));

            require( adelAfter - adelBefore == _adelAmount, "ADEL was not transferred rom ADEL pool");

            adelReceived = adelReceived.add(_adelAmount);
        }
        
        swap(adelReceived, adelAllowedToSwap, AdelSource.REWARDS);
    }

    /**
     * @notice Verifies merkle proofs of user to be elligible for swap
     * @param _account Address of a user
     * @param _merkleRootIndex Index of a merkle root to be used for calculations
     * @param _adelAllowedToSwap Maximum ADEL allowed for a user to swap
     * @param _merkleProofs Array of consiquent merkle hashes
     */
    function verifyMerkleProofs(
        address _account,
        uint256 _merkleRootIndex,
        uint256 _adelAllowedToSwap,
        bytes32[] memory _merkleProofs) virtual public view returns(bool)
    {
        require(_merkleProofs.length > 0, "No Merkle proofs");
        require(_merkleRootIndex < merkleRoots.length, "Merkle roots are not set");


        bytes32 node = keccak256(abi.encodePacked(_account, _adelAllowedToSwap));
        return MerkleProofUpgradeable.verify(_merkleProofs, merkleRoots[_merkleRootIndex], node);
    }

    /**
     * @notice Returns the actual amount of ADEL swapped by a user
     * @param _account Address of a user
     */
    function adelSwapped(address _account) public view returns (uint256)
    {
        return swappedAdel[_account][0] + swappedAdel[_account][1] + swappedAdel[_account][2];
    }

    /**
     * @notice Internal function to collect ADEL and mint vAkro for the sender
     * @notice Function lays on the fact, that ADEL is already on the contract
     * @param _adelAmount Amout of ADEL the contract needs to swap.
     * @param _adelAllowedToSwap Maximum ADEL from any source allowed to swap for user.
     *                           Any extra ADEL which exceeds this value is sent to the user
     * @param _index Number of the source of ADEL (wallet, stake, rewards)
     */
    function swap(uint256 _adelAmount, uint256 _adelAllowedToSwap, AdelSource _index) internal
    {
        uint256 amountSwapped = adelSwapped(_msgSender());
        require(amountSwapped < _adelAllowedToSwap, "Limit for swap is reached");
        require(_adelAmount != 0 && _adelAmount >= minAmountToSwap, "Not enough ADEL");

        uint256 actualAdelAmount;
        uint256 adelChange;
        if (amountSwapped.add(_adelAmount) > _adelAllowedToSwap) {
            actualAdelAmount = _adelAllowedToSwap.sub(amountSwapped);
            adelChange = _adelAmount.sub(actualAdelAmount);
        }
        else {
            actualAdelAmount = _adelAmount;
        }

        uint256 vAkroAmount = actualAdelAmount.mul(swapRateNumerator).div(swapRateDenominator);

        swappedAdel[_msgSender()][uint128(_index)] = swappedAdel[_msgSender()][uint128(_index)].add(actualAdelAmount);
        IERC20Mintable(vakro).mint(address(this), vAkroAmount);
        IERC20Upgradeable(vakro).transfer(_msgSender(), vAkroAmount);

        emit AdelSwapped(_msgSender(), actualAdelAmount, vAkroAmount);

        if (adelChange > 0)
            IERC20Upgradeable(adel).safeTransfer(_msgSender(), adelChange);
    }
}