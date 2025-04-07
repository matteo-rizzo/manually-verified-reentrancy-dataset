/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.7.0;

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



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.7.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// pragma solidity ^0.7.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */



// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.7.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */



// Dependency file: contracts/model/StoredOfferModel.sol


// pragma solidity 0.7.3;

abstract contract StoredOfferModel {

    // The order of fields in this struct is optimised to use the fewest storage slots
    struct StoredOffer {
        uint32 nonce;
        uint32 timelockPeriod;
        address loanTokenAddress;
        address itemTokenAddress;
        uint256 itemTokenId;
        uint256 itemValue;
        uint256 redemptionPrice;
    }
}


// Dependency file: contracts/utils/FractionMath.sol


// pragma solidity 0.7.3;

// import "@openzeppelin/contracts/math/SafeMath.sol";




// Dependency file: contracts/model/LoanModel.sol


// pragma solidity 0.7.3;

// import "contracts/model/StoredOfferModel.sol";
// import "contracts/utils/FractionMath.sol";

abstract contract LoanModel is StoredOfferModel {
    enum LoanStatus {
        TAKEN,
        RETURNED,
        CLAIMED
    }

    // The order of fields in this struct is optimised to use the fewest storage slots
    struct Loan {
        StoredOffer offer;
        LoanStatus status;
        address borrowerAddress;
        address lenderAddress;
        uint48 redemptionFeeNumerator;
        uint48 redemptionFeeDenominator;
        uint256 timestamp;
    }
}


// Dependency file: contracts/model/StakingModel.sol


// pragma solidity 0.7.3;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// For deeper understanding of the meaning of StakingState fields refer to `docs/PawnshopStaking.md` document

abstract contract StakingModel {
    struct StakingState {
        IERC20 token;
        uint256 totalClaimedRewards; // total amount of rewards already transferred to the stakers
        uint256 totalRewards; // total amount of rewards collected
        uint256 cRPT; // cumulative reward per token
        mapping(address => uint256) alreadyPaidCRPT; // cumulative reward per token already "paid" to the staker
        mapping(address => uint256) claimableReward; // the amount of rewards that can be withdrawn from the contract by the staker
    }
}


// Dependency file: contracts/handlers/IHandler.sol


// pragma solidity 0.7.3;




// Dependency file: contracts/utils/EnumerableMap.sol


// pragma solidity 0.7.3;

/**
 * This library was copied from OpenZeppelin's EnumerableMap.sol and adjusted to our needs.
 * The only changes made are:
 * - change // pragma solidity to 0.7.3
 * - change UintToAddressMap to AddressToAddressMap by renaming and adjusting methods
 * - add SupportState enum declaration
 * - clone AddressToAddressMap and change it to AddressToSupportStateMap by renaming and adjusting methods
 */



// Dependency file: contracts/PawnshopStorage.sol


// pragma solidity 0.7.3;

// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "contracts/model/LoanModel.sol";
// import "contracts/model/StakingModel.sol";
// import "contracts/handlers/IHandler.sol";
// import "contracts/utils/EnumerableMap.sol";
// import "contracts/utils/FractionMath.sol";

abstract contract PawnshopStorage is LoanModel, StakingModel {
    // Initializable.sol
    bool internal _initialized;
    bool internal _initializing;

    // Ownable.sol
    address internal _owner;

    // ReentrancyGuard.sol
    uint256 internal _guardStatus;

    // Pawnshop.sol
    mapping (bytes32 => Loan) internal _loans;
    mapping (bytes32 => bool) internal _usedOfferSignatures;

    // PawnshopConfig.sol
    uint256 internal _maxTimelockPeriod;
    EnumerableMap.AddressToAddressMap internal _tokenAddressToHandlerAddress;
    EnumerableMap.AddressToSupportStateMap internal _loanTokens;
    mapping (address => FractionMath.Fraction) internal _minLenderProfits;
    mapping (address => FractionMath.Fraction) internal _depositFees;
    mapping (address => FractionMath.Fraction) internal _redemptionFees;
    mapping (address => FractionMath.Fraction) internal _flashFees;

    // PawnshopStaking.sol
    IERC20 internal _stakingToken;
    mapping(address => uint256) internal _staked;
    uint256 internal _totalStaked;
    mapping(address => StakingState) internal _stakingStates;

    // EIP712Domain.sol
    bytes32 internal DOMAIN_SEPARATOR; // solhint-disable-line var-name-mixedcase
}


// Dependency file: contracts/Initializable.sol


// pragma solidity 0.7.3;

// import "contracts/PawnshopStorage.sol";

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
contract Initializable is PawnshopStorage {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    // bool _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    // bool _initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(_initializing || isConstructor() || !_initialized, "Contract instance has already been initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}


// Dependency file: contracts/Ownable.sol


// pragma solidity 0.7.3;

// import "contracts/PawnshopStorage.sol";
// import "contracts/Initializable.sol";

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
contract Ownable is PawnshopStorage, Initializable {
    // address _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __Ownable_init_unchained(address owner) internal initializer {
        _owner = owner;
        emit OwnershipTransferred(address(0), owner);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
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
}


// Dependency file: contracts/ReentrancyGuard.sol


// pragma solidity 0.7.3;

// import "contracts/PawnshopStorage.sol";
// import "contracts/Initializable.sol";

abstract contract ReentrancyGuard is PawnshopStorage, Initializable {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // uint256 _guardStatus;

    // solhint-disable-next-line func-name-mixedcase
    function __ReentrancyGuard_init_unchained() internal initializer {
        _guardStatus = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_guardStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        _guardStatus = _ENTERED;
        _;
        _guardStatus = _NOT_ENTERED;
    }
}


// Dependency file: contracts/PawnshopConfig.sol


// pragma solidity 0.7.3;
// pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";

// import "contracts/PawnshopStorage.sol";
// import "contracts/Initializable.sol";
// import "contracts/Ownable.sol";
// import "contracts/utils/EnumerableMap.sol";
// import "contracts/utils/FractionMath.sol";

abstract contract PawnshopConfig is PawnshopStorage, Ownable {
    using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.AddressToAddressMap;
    using EnumerableMap for EnumerableMap.AddressToSupportStateMap;
    using FractionMath for FractionMath.Fraction;

    // uint256 _maxTimelockPeriod;
    // EnumerableMap.AddressToAddressMap _tokenAddressToHandlerAddress;
    // EnumerableMap.AddressToSupportStateMap _loanTokens;
    // mapping (address => FractionMath.Fraction) _minLenderProfits;
    // mapping (address => FractionMath.Fraction) _depositFees;
    // mapping (address => FractionMath.Fraction) _redemptionFees;
    // mapping (address => FractionMath.Fraction) _flashFees;

    event MaxTimelockPeriodSet(uint256 indexed time);
    event MinLenderProfitSet(address indexed loanTokenAddress, FractionMath.Fraction minProfit);
    event PawnshopFeesSet(
        address indexed loanTokenAddress,
        FractionMath.Fraction depositFee,
        FractionMath.Fraction redemptionFee,
        FractionMath.Fraction flashFee
    );
    event ItemSupported(address indexed tokenAddress);
    event LoanTokenSupported(address indexed tokenAddress);
    event ItemSupportStopped(address indexed tokenAddress);
    event LoanTokenSupportStopped(address indexed tokenAddress);

    function setMaxTimelockPeriod(uint256 time) external onlyOwner {
        _setMaxTimelockPeriod(time);
    }

    function _setMaxTimelockPeriod(uint256 time) internal {
        require(time > 0, "Pawnshop: the max timelock period must be greater than 0");
        _maxTimelockPeriod = time;
        emit MaxTimelockPeriodSet(time);
    }

    function setMinLenderProfit(address loanTokenAddress, FractionMath.Fraction calldata minProfit) public onlyOwner {
        require(isLoanTokenSupported(loanTokenAddress), "Pawnshop: the loan token is not supported");
        _minLenderProfits[loanTokenAddress] = FractionMath.sanitize(minProfit);

        emit MinLenderProfitSet(loanTokenAddress, minProfit);
    }

    function setPawnshopFees(
        address loanTokenAddress,
        FractionMath.Fraction calldata depositFee,
        FractionMath.Fraction calldata redemptionFee,
        FractionMath.Fraction calldata flashFee
    ) public onlyOwner {
        require(isLoanTokenSupported(loanTokenAddress), "Pawnshop: the loan token is not supported");
        _depositFees[loanTokenAddress] = FractionMath.sanitize(depositFee);
        _redemptionFees[loanTokenAddress] = FractionMath.sanitize(redemptionFee);
        _flashFees[loanTokenAddress] = FractionMath.sanitize(flashFee);

        emit PawnshopFeesSet(
            loanTokenAddress,
            depositFee,
            redemptionFee,
            flashFee
        );
    }

    function supportItem(IHandler handler, address tokenAddress) external onlyOwner {
        require(!handler.isSupported(tokenAddress), "Pawnshop: the item is already supported");
        handler.supportToken(tokenAddress);
        _tokenAddressToHandlerAddress.set(tokenAddress, address(handler));
        emit ItemSupported(tokenAddress);
    }

    function supportLoanToken(
        address tokenAddress,
        FractionMath.Fraction calldata minProfit,
        FractionMath.Fraction calldata depositFee,
        FractionMath.Fraction calldata redemptionFee,
        FractionMath.Fraction calldata flashFee
    ) external onlyOwner {
        require(!isLoanTokenSupported(tokenAddress), "Pawnshop: the ERC20 loan token is already supported");
        require(tokenAddress != address(_stakingToken), "Pawnshop: cannot support the staking token");
        _loanTokens.set(tokenAddress, EnumerableMap.SupportState.SUPPORTED);
        StakingState storage newStakingState = _stakingStates[tokenAddress];
        newStakingState.token = IERC20(tokenAddress);
        setMinLenderProfit(tokenAddress, minProfit);
        setPawnshopFees(tokenAddress, depositFee, redemptionFee, flashFee);
        emit LoanTokenSupported(tokenAddress);
    }

    function stopSupportingItem(address tokenAddress) external onlyOwner {
        IHandler handler = itemHandler(tokenAddress);
        handler.stopSupportingToken(tokenAddress);
        emit ItemSupportStopped(tokenAddress);
    }

    function stopSupportingLoanToken(address tokenAddress) external onlyOwner {
        require(isLoanTokenSupported(tokenAddress), "Pawnshop: the ERC20 loan token is not supported");
        _loanTokens.set(tokenAddress, EnumerableMap.SupportState.SUPPORT_STOPPED);
        emit LoanTokenSupportStopped(tokenAddress);
    }

    function isLoanTokenSupported(address tokenAddress) public view returns (bool) {
        return _loanTokens.contains(tokenAddress) &&
            _loanTokens.get(tokenAddress) == EnumerableMap.SupportState.SUPPORTED;
    }

    function wasLoanTokenEverSupported(address tokenAddress) public view returns (bool) {
        return _loanTokens.contains(tokenAddress);
    }

    function isItemTokenSupported(address tokenAddress) external view returns (bool) {
        if (!_tokenAddressToHandlerAddress.contains(tokenAddress)) {
            return false;
        }
        address handler = _tokenAddressToHandlerAddress.get(tokenAddress);
        return IHandler(handler).isSupported(tokenAddress);
    }

    function totalItemTokens() external view returns (uint256) {
        return _tokenAddressToHandlerAddress.length();
    }

    function itemTokenByIndex(uint256 index) external view returns (address tokenAddress, address handlerAddress, bool isCurrentlySupported) {
        (tokenAddress, handlerAddress) = _tokenAddressToHandlerAddress.at(index);
        isCurrentlySupported = IHandler(handlerAddress).isSupported(tokenAddress);
    }

    function maxTimelockPeriod() external view returns (uint256) {
        return _maxTimelockPeriod;
    }

    function minLenderProfit(address loanTokenAddress) external view returns (FractionMath.Fraction memory) {
        return _minLenderProfits[loanTokenAddress];
    }

    function depositFee(address loanTokenAddress) external view returns (FractionMath.Fraction memory) {
        return _depositFees[loanTokenAddress];
    }

    function redemptionFee(address loanTokenAddress) external view returns (FractionMath.Fraction memory) {
        return _redemptionFees[loanTokenAddress];
    }

    function flashFee(address loanTokenAddress) external view returns (FractionMath.Fraction memory) {
        return _flashFees[loanTokenAddress];
    }

    function totalLoanTokens() external view returns (uint256) {
        return _loanTokens.length();
    }

    function loanTokenByIndex(uint256 index) external view returns (address, EnumerableMap.SupportState) {
        return _loanTokens.at(index);
    }

    function itemHandler(address itemTokenAddress) public view returns (IHandler) {
        return IHandler(_tokenAddressToHandlerAddress.get(itemTokenAddress, "Pawnshop: the item is not supported"));
    }

    function minReturnAmount(address loanTokenAddress, uint256 loanAmount) public view returns (uint256) {
        FractionMath.Fraction storage minProfit = _minLenderProfits[loanTokenAddress];
        uint256 lenderProfit = minProfit.mul(loanAmount);
        return loanAmount.add(lenderProfit);
    }
}


// Dependency file: contracts/PawnshopStaking.sol


// pragma solidity 0.7.3;
// pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

// import "contracts/PawnshopStorage.sol";
// import "contracts/PawnshopConfig.sol";
// import "contracts/model/StakingModel.sol";
// import "contracts/utils/EnumerableMap.sol";


abstract contract PawnshopStaking is StakingModel, PawnshopStorage, PawnshopConfig {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableMap for EnumerableMap.AddressToSupportStateMap;

    uint256 private constant PRECISION = 1e30;

    // IERC20 _stakingToken;
    // mapping(address => uint256) _staked;
    // uint256 _totalStaked;
    // mapping(address => StakingState) _stakingStates;

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, address indexed token, uint256 amount);

    // solhint-disable-next-line func-name-mixedcase
    function __PawnshopStaking_init_unchained(IERC20 stakingToken) internal initializer {
        _stakingToken = stakingToken;
    }

    function stake(uint256 amount) external {
        if (_totalStaked > 0) {
            _updateRewards();
        }
        _staked[msg.sender] = _staked[msg.sender].add(amount);
        _totalStaked = _totalStaked.add(amount);
        _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount <= _staked[msg.sender], "PawnshopStaking: cannot unstake more than was staked");
        _updateRewards();
        _staked[msg.sender] = _staked[msg.sender].sub(amount);
        _totalStaked = _totalStaked.sub(amount);
        _stakingToken.safeTransfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() external {
        uint256 loanTokensCount = _loanTokens.length();
        for (uint256 i = 0; i < loanTokensCount; i++) {
            (address loanToken,) = _loanTokens.at(i);
            StakingState storage state = _stakingStates[loanToken];
            if (_totalStaked > 0) {
                _updateSingleTokenRewards(state);
            }
            _transferReward(state);
        }
    }

    function emergencyStakeRecovery() external onlyOwner {
        uint256 balance = _stakingToken.balanceOf(address(this));
        uint256 recoveryAmount = balance.sub(_totalStaked);
        require(recoveryAmount > 0, "PawnshopStaking: there are no additional staking tokens for recovery in the contract");
        _stakingToken.safeTransfer(msg.sender, recoveryAmount);
    }

    function _updateRewards() private {
        uint256 loanTokensCount = _loanTokens.length();
        for (uint256 i = 0; i < loanTokensCount; i++) {
            (address loanToken,) = _loanTokens.at(i);
            _updateSingleTokenRewards(_stakingStates[loanToken]);
        }
    }

    function _updateSingleTokenRewards(StakingState storage state) private {
        uint256 newTotalRewards = _calculateNewTotalRewards(state);
        uint256 newCRPT = _calculateNewCRPT(state, newTotalRewards);
        state.claimableReward[msg.sender] = _calculateNewClaimableReward(state, newCRPT, msg.sender);
        state.alreadyPaidCRPT[msg.sender] = newCRPT;
        state.cRPT = newCRPT;
        state.totalRewards = newTotalRewards;
    }

    function _calculateNewTotalRewards(StakingState storage state) private view returns (uint256) {
        uint256 currentLoanTokenBalance = state.token.balanceOf(address(this));
        return currentLoanTokenBalance.add(state.totalClaimedRewards);
    }

    function _calculateNewCRPT(StakingState storage state, uint256 newTotalRewards) private view returns (uint256) {
        uint256 newRewards = newTotalRewards.sub(state.totalRewards);
        uint256 rewardPerToken = newRewards.mul(PRECISION).div(_totalStaked);
        return state.cRPT.add(rewardPerToken);
    }

    function _calculateNewClaimableReward(StakingState storage state, uint256 newCRPT, address staker) private view returns (uint256) {
        uint256 stakerCRPT = newCRPT.sub(state.alreadyPaidCRPT[staker]);
        uint256 stakerCurrentlyClaimableReward = _staked[staker].mul(stakerCRPT).div(PRECISION);
        return state.claimableReward[staker].add(stakerCurrentlyClaimableReward);
    }

    function _transferReward(StakingState storage state) private {
        uint256 rewardToClaim = state.claimableReward[msg.sender];
        state.totalClaimedRewards = state.totalClaimedRewards.add(rewardToClaim);
        state.claimableReward[msg.sender] = 0;
        state.token.safeTransfer(msg.sender, rewardToClaim);
        emit RewardClaimed(msg.sender, address(state.token), rewardToClaim);
    }

    function stakedAmount(address staker) external view returns (uint256) {
        return _staked[staker];
    }

    function totalStaked() external view returns (uint256) {
        return _totalStaked;
    }

    function claimableReward(address stakerAddress, address loanTokenAddress) external view returns (uint256) {
        require(wasLoanTokenEverSupported(loanTokenAddress), "PawnshopStaking: the ERC20 loan token was never supported");
        StakingState storage state = _stakingStates[loanTokenAddress];
        uint256 newTotalRewards = _calculateNewTotalRewards(state);
        uint256 newCRPT = _totalStaked > 0 ? _calculateNewCRPT(state, newTotalRewards) : state.cRPT;
        return _calculateNewClaimableReward(state, newCRPT, stakerAddress);
    }

    function totalClaimedRewards(address loanTokenAddress) external view returns (uint256) {
        require(wasLoanTokenEverSupported(loanTokenAddress), "PawnshopStaking: the ERC20 loan token was never supported");
        return _stakingStates[loanTokenAddress].totalClaimedRewards;
    }

    function totalRewards(address loanTokenAddress) external view returns (uint256) {
        require(wasLoanTokenEverSupported(loanTokenAddress), "PawnshopStaking: the ERC20 loan token was never supported");
        StakingState storage state = _stakingStates[loanTokenAddress];
        return _calculateNewTotalRewards(state);
    }

    function stakingToken() external view returns (IERC20) {
        return _stakingToken;
    }
}


// Dependency file: contracts/model/OfferModel.sol


// pragma solidity 0.7.3;

abstract contract OfferModel {
    string internal constant ITEM__TYPE = "Item(address tokenAddress,uint256 tokenId,uint256 depositTimestamp)";
    string internal constant LOAN_PARAMS__TYPE = "LoanParams(uint256 itemValue,uint256 redemptionPrice,uint32 timelockPeriod)";
    string internal constant OFFER__TYPE = "Offer(uint32 nonce,uint40 expirationTime,address loanTokenAddress,Item collateralItem,LoanParams loanParams)"
                                           "Item(address tokenAddress,uint256 tokenId,uint256 depositTimestamp)"
                                           "LoanParams(uint256 itemValue,uint256 redemptionPrice,uint32 timelockPeriod)";

    struct Item {
        address tokenAddress;
        uint256 tokenId;
        uint256 depositTimestamp;
    }

    struct LoanParams {
        uint256 itemValue;
        uint256 redemptionPrice;
        uint32 timelockPeriod;
    }

    struct Offer {
        uint32 nonce;
        uint40 expirationTime;
        address loanTokenAddress;
        Item collateralItem;
        LoanParams loanParams;
    }
}


// Dependency file: @openzeppelin/contracts/cryptography/ECDSA.sol


// pragma solidity ^0.7.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */



// Dependency file: contracts/verifiers/EIP712Domain.sol


// pragma solidity 0.7.3;

// import "contracts/Initializable.sol";
// import "contracts/PawnshopStorage.sol";
// import "contracts/model/OfferModel.sol";

abstract contract EIP712Domain is PawnshopStorage, Initializable {
    string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));

    // bytes32 DOMAIN_SEPARATOR;

    // solhint-disable-next-line func-name-mixedcase
    function __EIP712Domain_init_unchained() internal initializer {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("Pawnshop"),
                keccak256("1.0.0"),
                _getChainId(),
                address(this)
            ));
    }

    function _getChainId() private pure returns (uint256 id) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
    }
}


// Dependency file: contracts/verifiers/OfferSigVerifier.sol


// pragma solidity 0.7.3;

// import "@openzeppelin/contracts/cryptography/ECDSA.sol";

// import "contracts/verifiers/EIP712Domain.sol";
// import "contracts/model/OfferModel.sol";

abstract contract OfferSigVerifier is OfferModel, EIP712Domain {
    using ECDSA for bytes32;

    bytes32 private constant ITEM__TYPEHASH = keccak256(abi.encodePacked(ITEM__TYPE));
    bytes32 private constant LOAN_PARAMS__TYPEHASH = keccak256(abi.encodePacked(LOAN_PARAMS__TYPE));
    bytes32 private constant OFFER__TYPEHASH = keccak256(abi.encodePacked(OFFER__TYPE));

    function _hashItem(Item calldata item) private pure returns (bytes32) {
        return keccak256(abi.encode(
                ITEM__TYPEHASH,
                item.tokenAddress,
                item.tokenId,
                item.depositTimestamp
            ));
    }

    function _hashLoanParams(LoanParams calldata params) private pure returns (bytes32) {
        return keccak256(abi.encode(
                LOAN_PARAMS__TYPEHASH,
                params.itemValue,
                params.redemptionPrice,
                params.timelockPeriod
            ));
    }

    function _hashOffer(Offer calldata offer) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    OFFER__TYPEHASH,
                    offer.nonce,
                    offer.expirationTime,
                    offer.loanTokenAddress,
                    _hashItem(offer.collateralItem),
                    _hashLoanParams(offer.loanParams)
                ))
            ));
    }

    function _verifyOffer(address signerAddress, bytes calldata signature, Offer calldata offer) internal view returns (bool) {
        bytes32 hash = _hashOffer(offer);
        return hash.recover(signature) == signerAddress;
    }
}


// Dependency file: contracts/model/FlashOfferModel.sol


// pragma solidity 0.7.3;

abstract contract FlashOfferModel {
    string internal constant FLASH_OFFER__TYPE = "FlashOffer(uint32 nonce,uint40 expirationTime,address loanTokenAddress,uint256 loanAmount,uint256 returnAmount)";

    struct FlashOffer {
        uint32 nonce;
        uint40 expirationTime;
        address loanTokenAddress;
        uint256 loanAmount;
        uint256 returnAmount;
    }
}


// Dependency file: contracts/verifiers/FlashOfferSigVerifier.sol


// pragma solidity 0.7.3;

// import "@openzeppelin/contracts/cryptography/ECDSA.sol";

// import "contracts/verifiers/EIP712Domain.sol";
// import "contracts/model/FlashOfferModel.sol";

abstract contract FlashOfferSigVerifier is FlashOfferModel, EIP712Domain {
    using ECDSA for bytes32;

    bytes32 private constant FLASH_OFFER__TYPEHASH = keccak256(abi.encodePacked(FLASH_OFFER__TYPE));

    function _hashFlashOffer(FlashOffer calldata offer) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    FLASH_OFFER__TYPEHASH,
                    offer.nonce,
                    offer.expirationTime,
                    offer.loanTokenAddress,
                    offer.loanAmount,
                    offer.returnAmount
                ))
            ));
    }

    function _verifyFlashOffer(
        address signerAddress,
        bytes calldata signature,
        FlashOffer calldata offer
    ) internal view returns (bool) {
        bytes32 hash = _hashFlashOffer(offer);
        return hash.recover(signature) == signerAddress;
    }
}


// Dependency file: contracts/interfaces/IERC3156FlashBorrower.sol


// pragma solidity 0.7.3;




// Dependency file: contracts/FlashLoan.sol


// pragma solidity 0.7.3;
// pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";

// import "contracts/PawnshopConfig.sol";
// import "contracts/PawnshopStorage.sol";
// import "contracts/utils/FractionMath.sol";
// import "contracts/model/FlashOfferModel.sol";
// import "contracts/verifiers/FlashOfferSigVerifier.sol";
// import "contracts/interfaces/IERC3156FlashBorrower.sol";

abstract contract FlashLoan is FlashOfferModel, PawnshopStorage, FlashOfferSigVerifier, PawnshopConfig {
    using FractionMath for FractionMath.Fraction;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event FlashLoanMade(
        address indexed borrowerAddress,
        address indexed receiverAddress,
        address indexed lenderAddress,
        bytes32 signatureHash
    );

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address lenderAddress,
        bytes calldata signature,
        FlashOffer calldata offer,
        bytes calldata data
    ) external {
        require(isLoanTokenSupported(offer.loanTokenAddress), "FlashLoan: the ERC20 loan token is not supported");
        require(block.timestamp < offer.expirationTime, "FlashLoan: the offer has expired");
        require(offer.loanAmount > 0, "FlashLoan: loan amount must be greater than 0");
        require(offer.returnAmount > 0, "FlashLoan: return amount must be greater than 0");
        require(offer.returnAmount >= minReturnAmount(offer.loanTokenAddress, offer.loanAmount),
            "FlashLoan: the return amount is less then the minimum return amount for this loan token and loan amount");
        require(_verifyFlashOffer(lenderAddress, signature, offer), "FlashLoan: the signature of the offer is invalid");

        bytes32 signatureHash = keccak256(signature);
        require(!_usedOfferSignatures[signatureHash], "FlashLoan: the loan has already been taken or the offer was cancelled");
        _usedOfferSignatures[signatureHash] = true;

        IERC20(offer.loanTokenAddress).safeTransferFrom(lenderAddress, address(receiver), offer.loanAmount);

        uint256 flashFee = _flashFees[offer.loanTokenAddress].mul(offer.loanAmount);
        uint256 totalFee = offer.returnAmount.sub(offer.loanAmount).add(flashFee);
        receiver.onFlashLoan(msg.sender, offer.loanTokenAddress, offer.loanAmount, totalFee, data);

        IERC20(offer.loanTokenAddress).safeTransferFrom(address(receiver), lenderAddress, offer.returnAmount);
        IERC20(offer.loanTokenAddress).safeTransferFrom(address(receiver), address(this), flashFee);

        emit FlashLoanMade(msg.sender, address(receiver), lenderAddress, signatureHash);
    }
}


// Root file: contracts/Pawnshop.sol


pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// import "contracts/PawnshopStorage.sol";
// import "contracts/Initializable.sol";
// import "contracts/Ownable.sol";
// import "contracts/ReentrancyGuard.sol";
// import "contracts/PawnshopConfig.sol";
// import "contracts/PawnshopStaking.sol";
// import "contracts/model/LoanModel.sol";
// import "contracts/model/OfferModel.sol";
// import "contracts/verifiers/OfferSigVerifier.sol";
// import "contracts/handlers/IHandler.sol";
// import "contracts/FlashLoan.sol";
// import "contracts/utils/FractionMath.sol";

contract Pawnshop is LoanModel, PawnshopStorage, Initializable, Ownable, ReentrancyGuard, OfferSigVerifier, PawnshopConfig, PawnshopStaking, FlashLoan, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using FractionMath for FractionMath.Fraction;

    // mapping (bytes32 => Loan) _loans;
    // mapping (bytes32 => bool) _usedOfferSignatures;

    modifier onlyBorrower(bytes32 signatureHash) {
        Loan storage loan = _loans[signatureHash];
        require(msg.sender == loan.borrowerAddress, "Pawnshop: caller is not the borrower");

        _;
    }

    modifier onlyLender(bytes32 signatureHash) {
        Loan storage loan = _loans[signatureHash];
        require(msg.sender == loan.lenderAddress, "Pawnshop: caller is not the lender");

        _;
    }

    event ItemDeposited(address indexed previousOwner, address indexed tokenAddress, uint256 indexed tokenId);
    event ItemWithdrawn(address indexed ownerAddress, address indexed tokenAddress, uint256 indexed tokenId);
    event LoanTaken(address indexed borrowerAddress, address indexed lenderAddress, bytes32 signatureHash);
    event OfferCanceled(address indexed lenderAddres, bytes32 signatureHash);
    event ItemRedeemed(address indexed borrowerAddress, bytes32 signatureHash);
    event ItemClaimed(address indexed lenderAddress, bytes32 signatureHash);

    constructor(address owner) {
        __Ownable_init_unchained(owner);
    }

    function initialize(address owner, IERC20 stakingToken, uint256 maxTimelockPeriod) public initializer {
        __Ownable_init_unchained(owner);
        __ReentrancyGuard_init_unchained();
        __EIP712Domain_init_unchained();
        __PawnshopStaking_init_unchained(stakingToken);
        __Pawnshop_init_unchained(maxTimelockPeriod);
    }

    // solhint-disable-next-line func-name-mixedcase
    function __Pawnshop_init_unchained(uint256 maxTimelockPeriod) internal {
        _setMaxTimelockPeriod(maxTimelockPeriod);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        revert("Pawnshop: tokens cannot be transferred directly, use Pawnshop.depositItem function instead");
    }

    function itemOwner(address tokenAddress, uint256 tokenId) external view returns (address) {
        IHandler handler = itemHandler(tokenAddress);
        return handler.ownerOf(tokenAddress, tokenId);
    }

    function _calculateRedemptionFee(Loan storage loan) private view returns (uint256) {
        return loan.offer.redemptionPrice
            .mul(loan.redemptionFeeNumerator)
            .div(loan.redemptionFeeDenominator);
    }

    function depositItem(address tokenAddress, uint256 tokenId) external {
        IHandler handler = itemHandler(tokenAddress);
        handler.deposit(msg.sender, tokenAddress, tokenId);
        emit ItemDeposited(msg.sender, tokenAddress, tokenId);
    }

    function itemDepositTimestamp(address tokenAddress, uint256 tokenId) public view returns (uint256) {
        IHandler handler = itemHandler(tokenAddress);
        return handler.depositTimestamp(tokenAddress, tokenId);
    }

    function takeLoan(address lenderAddress, bytes calldata signature, Offer calldata offer) external nonReentrant {
        Item calldata item = offer.collateralItem;
        LoanParams calldata params = offer.loanParams;
        IHandler handler = itemHandler(item.tokenAddress);

        require(handler.isSupported(item.tokenAddress), "Pawnshop: the item is not supported");
        require(isLoanTokenSupported(offer.loanTokenAddress), "Pawnshop: the ERC20 loan token is not supported");
        require(block.timestamp < offer.expirationTime, "Pawnshop: the offer has expired");
        require(params.itemValue > 0, "Pawnshop: the item value must be greater than 0");
        require(params.redemptionPrice > 0, "Pawnshop: the redemption price must be greater than 0");
        require(params.timelockPeriod > 0, "Pawnshop: the timelock period must be greater than 0");
        require(params.timelockPeriod <= _maxTimelockPeriod, "Pawnshop: the timelock period must be less or equal to the max timelock period");
        require(params.redemptionPrice >= minReturnAmount(offer.loanTokenAddress, params.itemValue),
            "Pawnshop: the redemption price is less then the minimum return amount for this loan token and loan amount");

        require(_verifyOffer(lenderAddress, signature, offer), "Pawnshop: the signature of the offer is invalid");

        bytes32 signatureHash = keccak256(signature);
        require(!_usedOfferSignatures[signatureHash], "Pawnshop: the loan has already been taken or the offer was cancelled");
        require(handler.ownerOf(item.tokenAddress, item.tokenId) == msg.sender, "Pawnshop: the item must be deposited to the pawnshop first");
        require(handler.depositTimestamp(item.tokenAddress, item.tokenId) == item.depositTimestamp, "Pawnshop: the item was redeposited after offer signing");

        uint256 depositFee = _depositFees[offer.loanTokenAddress].mul(params.itemValue);
        IERC20(offer.loanTokenAddress).safeTransferFrom(lenderAddress, address(this), depositFee);
        IERC20(offer.loanTokenAddress).safeTransferFrom(lenderAddress, msg.sender, params.itemValue.sub(depositFee));

        _usedOfferSignatures[signatureHash] = true;
        _loans[signatureHash] = Loan({
            offer: StoredOffer({
                nonce: offer.nonce,
                timelockPeriod: offer.loanParams.timelockPeriod,
                loanTokenAddress: offer.loanTokenAddress,
                itemTokenAddress: offer.collateralItem.tokenAddress,
                itemTokenId: offer.collateralItem.tokenId,
                itemValue: offer.loanParams.itemValue,
                redemptionPrice: offer.loanParams.redemptionPrice
            }),
            status: LoanStatus.TAKEN,
            borrowerAddress: msg.sender,
            lenderAddress: lenderAddress,
            redemptionFeeNumerator: _redemptionFees[offer.loanTokenAddress].numerator,
            redemptionFeeDenominator: _redemptionFees[offer.loanTokenAddress].denominator,
            timestamp: block.timestamp
        });

        handler.changeOwnership(address(this), item.tokenAddress, item.tokenId);

        emit LoanTaken(msg.sender, lenderAddress, signatureHash);
    }

    function loan(bytes32 signatureHash) external view returns (Loan memory) {
        Loan storage _loan = _loans[signatureHash];
        require(_loan.timestamp != 0, "Pawnshop: there's no loan with given signature");
        return _loan;
    }

    function isSignatureUsed(bytes32 signatureHash) external view returns (bool) {
        return _usedOfferSignatures[signatureHash];
    }

    function cancelOffer(bytes calldata signature, Offer calldata offer) external {
        require(_verifyOffer(msg.sender, signature, offer), "Pawnshop: the transaction sender is not the offer signer");

        bytes32 signatureHash = keccak256(signature);
        _usedOfferSignatures[signatureHash] = true;

        emit OfferCanceled(msg.sender, signatureHash);
    }

    function redemptionPriceWithFee(bytes32 signatureHash) external view returns (uint256) {
        Loan storage _loan = _loans[signatureHash];
        require(_loan.timestamp != 0, "Pawnshop: there's no loan with given signature");

        return _loan.offer.redemptionPrice.add(_calculateRedemptionFee(_loan));
    }

    function redemptionDeadline(bytes32 signatureHash) public view returns (uint256) {
        Loan storage _loan = _loans[signatureHash];
        require(_loan.timestamp != 0, "Pawnshop: there's no loan with given signature");

        return _loan.timestamp.add(_loan.offer.timelockPeriod);
    }

    function _reedemItem(bytes32 signatureHash) private returns (Loan storage _loan) {
        _loan = _loans[signatureHash];
        StoredOffer storage offer = _loan.offer;
        require(block.timestamp <= redemptionDeadline(signatureHash), "Pawnshop: the redemption time has already passed");
        require(_loan.status == LoanStatus.TAKEN, "Pawnshop: the item was already redeemed/claimed");

        address loanTokenAddress = offer.loanTokenAddress;
        uint256 redemptionFee = _calculateRedemptionFee(_loan);
        IERC20(loanTokenAddress).safeTransferFrom(_loan.borrowerAddress, address(this), redemptionFee);
        IERC20(loanTokenAddress).safeTransferFrom(_loan.borrowerAddress, _loan.lenderAddress, offer.redemptionPrice);

        IHandler handler = itemHandler(offer.itemTokenAddress);
        handler.changeOwnership(msg.sender, offer.itemTokenAddress, offer.itemTokenId);
        _loan.status = LoanStatus.RETURNED;

        emit ItemRedeemed(msg.sender, signatureHash);
    }

    function redeemItem(bytes32 signatureHash) external onlyBorrower(signatureHash) {
        _reedemItem(signatureHash);
    }

    function _claimItem(bytes32 signatureHash) private returns (Loan storage _loan) {
        _loan = _loans[signatureHash];
        StoredOffer storage offer = _loan.offer;
        require(block.timestamp > redemptionDeadline(signatureHash), "Pawnshop: the item timelock period hasn't passed yet");
        require(_loan.status == LoanStatus.TAKEN, "Pawnshop: the item was already redeemed/claimed");

        IHandler handler = itemHandler(offer.itemTokenAddress);
        handler.changeOwnership(msg.sender, offer.itemTokenAddress, offer.itemTokenId);
        _loan.status = LoanStatus.CLAIMED;

        emit ItemClaimed(msg.sender, signatureHash);
    }

    function claimItem(bytes32 signatureHash) external onlyLender(signatureHash) {
        _claimItem(signatureHash);
    }

    function withdrawItem(address tokenAddress, uint256 tokenId) public {
        IHandler handler = itemHandler(tokenAddress);
        handler.withdraw(msg.sender, tokenAddress, tokenId);
        emit ItemWithdrawn(msg.sender, tokenAddress, tokenId);
    }

    function redeemAndWithdrawItem(bytes32 signatureHash) external onlyBorrower(signatureHash) {
        Loan storage _loan = _reedemItem(signatureHash);
        withdrawItem(_loan.offer.itemTokenAddress, _loan.offer.itemTokenId);
    }

    function claimAndWithdrawItem(bytes32 signatureHash) external onlyLender(signatureHash) {
        Loan storage _loan = _claimItem(signatureHash);
        withdrawItem(_loan.offer.itemTokenAddress, _loan.offer.itemTokenId);
    }
}