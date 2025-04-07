/**
 *Submitted for verification at Etherscan.io on 2020-12-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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
contract ReentrancyGuard {
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

    constructor() internal {
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
}

contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() internal {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}







/**
 * @title Basis Dollar Treasury contract
 * @notice Monetary policy logic to adjust supplies of basis dollar assets
 * @author Summer Smith & Rick Sanchez
 */
contract Treasury is ContractGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /* ========= CONSTANT VARIABLES ======== */

    uint256 public constant PERIOD = 12 hours;

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;

    // flags
    bool public migrated = false;
    bool public initialized = false;

    // epoch
    uint256 public startTime;
    uint256 public epoch = 0;
    uint256 public epochSupplyContractionLeft = 0;

    // core components
    address public dollar = address(0x003e0af2916e598Fa5eA5Cb2Da4EDfdA9aEd9Fde);
    address public bond = address(0x9f48b2f14517770F2d238c787356F3b961a6616F);
    address public share = address(0xE7C9C188138f7D70945D420d75F8Ca7d8ab9c700);

    address public boardroom;
    address public dollarOracle;

    // price
    uint256 public dollarPriceOne;
    uint256 public dollarPriceCeiling;

    uint256 public seigniorageSaved;

    // protocol parameters - https://docs.basisdollar.fi/ProtocolParameters
    uint256 public maxSupplyExpansionPercent;
    uint256 public bondDepletionFloorPercent;
    uint256 public seigniorageExpansionFloorPercent;
    uint256 public maxSupplyContractionPercent;
    uint256 public maxDeptRatioPercent;

    /* =================== BDIPs (BasisDollar Improvement Proposals) =================== */

    // BDIP01
    uint256 public bdip01SharedIncentiveForLpEpochs;
    uint256 public bdip01SharedIncentiveForLpPercent;
    address[] public bdip01LiquidityPools;

    // BDIP02
    uint256 public bdip02BootstrapEpochs;
    uint256 public bdip02BootstrapSupplyExpansionPercent;

    /* =================== Events =================== */

    event Initialized(address indexed executor, uint256 at);
    event Migration(address indexed target);
    event RedeemedBonds(address indexed from, uint256 amount);
    event BoughtBonds(address indexed from, uint256 amount);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event BoardroomFunded(uint256 timestamp, uint256 seigniorage);

    /* =================== Modifier =================== */

    modifier onlyOperator() {
        require(operator == msg.sender, "Treasury: caller is not the operator");
        _;
    }

    modifier checkCondition {
        require(!migrated, "Treasury: migrated");
        require(now >= startTime, "Treasury: not started yet");

        _;
    }

    modifier checkEpoch {
        require(now >= nextEpochPoint(), "Treasury: not opened yet");

        _;

        epoch = epoch.add(1);
        epochSupplyContractionLeft = IERC20(dollar).totalSupply().mul(maxSupplyContractionPercent).div(10000);
    }

    modifier checkOperator {
        require(
            IBasisAsset(dollar).operator() == address(this) &&
                IBasisAsset(bond).operator() == address(this) &&
                IBasisAsset(share).operator() == address(this) &&
                Operator(boardroom).operator() == address(this),
            "Treasury: need more permission"
        );

        _;
    }

    modifier notInitialized {
        require(!initialized, "Treasury: already initialized");

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    // flags
    function isMigrated() public view returns (bool) {
        return migrated;
    }

    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // epoch
    function nextEpochPoint() public view returns (uint256) {
        return startTime.add(epoch.mul(PERIOD));
    }

    // oracle
    function getDollarPrice() public view returns (uint256 dollarPrice) {
        try IOracle(dollarOracle).consult(dollar, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert("Treasury: failed to consult dollar price from the oracle");
        }
    }

    // budget
    function getReserve() public view returns (uint256) {
        return seigniorageSaved;
    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _dollar,
        address _bond,
        address _share,
        uint256 _startTime
    ) public notInitialized {
        dollar = _dollar;
        bond = _bond;
        share = _share;
        startTime = _startTime;

        dollarPriceOne = 10**18;
        dollarPriceCeiling = dollarPriceOne.mul(105).div(100);

        maxSupplyExpansionPercent = 450; // Upto 4.5% supply for expansion
        bondDepletionFloorPercent = 10000; // 100% of Bond supply for depletion floor
        seigniorageExpansionFloorPercent = 3500; // At least 35% of expansion reserved for boardroom
        maxSupplyContractionPercent = 450; // Upto 4.5% supply for contraction (to burn BSD and mint BSDB)
        maxDeptRatioPercent = 3500; // Upto 35% supply of BSDB to purchase

        // BDIP01: 75% of X $BSD from expansion to BSDS stakers and 25% to LPs for 14 epochs
        bdip01SharedIncentiveForLpEpochs = 14;
        bdip01SharedIncentiveForLpPercent = 2500;
        bdip01LiquidityPools = [
            address(0x71661297e9784f08fd5d840D4340C02e52550cd9), // DAI/BSD
            address(0x9E7a4f7e4211c0CE4809cE06B9dDA6b95254BaaC), // USDC/BSD
            address(0xc259bf15BaD4D870dFf1FE1AAB450794eB33f8e8), // DAI/BSDS
            address(0xE0e7F7EB27CEbCDB2F1DA5F893c429d0e5954468) // USDC/BSDS
        ];

        // BDIP02: 14 first epochs with 9% max expansion
        bdip02BootstrapEpochs = 14;
        bdip02BootstrapSupplyExpansionPercent = 900;

        // set seigniorageSaved to it's balance
        seigniorageSaved = IERC20(dollar).balanceOf(address(this));

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setBoardroom(address _boardroom) external onlyOperator {
        boardroom = _boardroom;
    }

    function setDollarOracle(address _dollarOracle) external onlyOperator {
        dollarOracle = _dollarOracle;
    }

    function setDollarPriceCeiling(uint256 _dollarPriceCeiling) external onlyOperator {
        require(_dollarPriceCeiling >= dollarPriceOne && _dollarPriceCeiling <= dollarPriceOne.mul(120).div(100), "out of range"); // [$1.0, $1.2]
        dollarPriceCeiling = _dollarPriceCeiling;
    }

    function setMaxSupplyExpansionPercent(uint256 _maxSupplyExpansionPercent) external onlyOperator {
        require(_maxSupplyExpansionPercent >= 10 && _maxSupplyExpansionPercent <= 1500, "out of range"); // [0.1%, 15%]
        maxSupplyExpansionPercent = _maxSupplyExpansionPercent;
    }

    function setBondDepletionFloorPercent(uint256 _bondDepletionFloorPercent) external onlyOperator {
        require(_bondDepletionFloorPercent >= 500 && _bondDepletionFloorPercent <= 10000, "out of range"); // [5%, 100%]
        bondDepletionFloorPercent = _bondDepletionFloorPercent;
    }

    function setMaxSupplyContractionPercent(uint256 _maxSupplyContractionPercent) external onlyOperator {
        require(_maxSupplyContractionPercent >= 100 && _maxSupplyContractionPercent <= 1500, "out of range"); // [0.1%, 15%]
        maxSupplyContractionPercent = _maxSupplyContractionPercent;
    }

    function setMaxDeptRatioPercent(uint256 _maxDeptRatioPercent) external onlyOperator {
        require(_maxDeptRatioPercent >= 1000 && _maxDeptRatioPercent <= 10000, "out of range"); // [10%, 100%]
        maxDeptRatioPercent = _maxDeptRatioPercent;
    }

    function setBDIP01(
        uint256 _bdip01SharedIncentiveForLpEpochs,
        uint256 _bdip01SharedIncentiveForLpPercent,
        address[] memory _bdip01LiquidityPools
    ) external onlyOperator {
        require(_bdip01SharedIncentiveForLpEpochs <= 730, "_bdip01SharedIncentiveForLpEpochs: out of range"); // <= 1 year
        require(_bdip01SharedIncentiveForLpPercent <= 10000, "_bdip01SharedIncentiveForLpPercent: out of range"); // [0%, 100%]
        bdip01SharedIncentiveForLpEpochs = _bdip01SharedIncentiveForLpEpochs;
        bdip01SharedIncentiveForLpPercent = _bdip01SharedIncentiveForLpPercent;
        bdip01LiquidityPools = _bdip01LiquidityPools;
    }

    function setBDIP02(uint256 _bdip02BootstrapEpochs, uint256 _bdip02BootstrapSupplyExpansionPercent) external onlyOperator {
        require(_bdip02BootstrapEpochs <= 60, "_bdip02BootstrapEpochs: out of range"); // <= 1 month
        require(
            _bdip02BootstrapSupplyExpansionPercent >= 100 && _bdip02BootstrapSupplyExpansionPercent <= 1500,
            "_bdip02BootstrapSupplyExpansionPercent: out of range"
        ); // [1%, 15%]
        bdip02BootstrapEpochs = _bdip02BootstrapEpochs;
        bdip02BootstrapSupplyExpansionPercent = _bdip02BootstrapSupplyExpansionPercent;
    }

    function migrate(address target) external onlyOperator checkOperator {
        require(!migrated, "Treasury: migrated");

        // dollar
        Operator(dollar).transferOperator(target);
        Operator(dollar).transferOwnership(target);
        IERC20(dollar).transfer(target, IERC20(dollar).balanceOf(address(this)));

        // bond
        Operator(bond).transferOperator(target);
        Operator(bond).transferOwnership(target);
        IERC20(bond).transfer(target, IERC20(bond).balanceOf(address(this)));

        // share
        Operator(share).transferOperator(target);
        Operator(share).transferOwnership(target);
        IERC20(share).transfer(target, IERC20(share).balanceOf(address(this)));

        migrated = true;
        emit Migration(target);
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    function _updateDollarPrice() internal {
        try IOracle(dollarOracle).update() {} catch {}
    }

    function buyBonds(uint256 amount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {
        require(amount > 0, "Treasury: cannot purchase bonds with zero amount");

        uint256 dollarPrice = getDollarPrice();
        require(dollarPrice == targetPrice, "Treasury: dollar price moved");
        require(
            dollarPrice < dollarPriceOne, // price < $1
            "Treasury: dollarPrice not eligible for bond purchase"
        );

        require(amount <= epochSupplyContractionLeft, "Treasury: not enough bond left to purchase");

        uint256 _boughtBond = amount.mul(1e18).div(dollarPrice);
        uint256 dollarSupply = IERC20(dollar).totalSupply();
        uint256 newBondSupply = IERC20(bond).totalSupply().add(_boughtBond);
        require(newBondSupply <= dollarSupply.mul(maxDeptRatioPercent).div(10000), "over max debt ratio");

        IBasisAsset(dollar).burnFrom(msg.sender, amount);
        IBasisAsset(bond).mint(msg.sender, _boughtBond);

        epochSupplyContractionLeft = epochSupplyContractionLeft.sub(amount);
        _updateDollarPrice();

        emit BoughtBonds(msg.sender, amount);
    }

    function redeemBonds(uint256 amount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {
        require(amount > 0, "Treasury: cannot redeem bonds with zero amount");

        uint256 dollarPrice = getDollarPrice();
        require(dollarPrice == targetPrice, "Treasury: dollar price moved");
        require(
            dollarPrice > dollarPriceCeiling, // price > $1.05
            "Treasury: dollarPrice not eligible for bond purchase"
        );
        require(IERC20(dollar).balanceOf(address(this)) >= amount, "Treasury: treasury has no more budget");

        seigniorageSaved = seigniorageSaved.sub(Math.min(seigniorageSaved, amount));

        IBasisAsset(bond).burnFrom(msg.sender, amount);
        IERC20(dollar).safeTransfer(msg.sender, amount);

        _updateDollarPrice();

        emit RedeemedBonds(msg.sender, amount);
    }

    function _sendToBoardRoom(uint256 _amount) internal {
        IBasisAsset(dollar).mint(address(this), _amount);
        if (epoch < bdip01SharedIncentiveForLpEpochs) {
            uint256 _addedPoolReward = _amount.mul(bdip01SharedIncentiveForLpPercent).div(40000);
            for (uint256 i = 0; i < 4; i++) {
                IERC20(dollar).transfer(bdip01LiquidityPools[i], _addedPoolReward);
                _amount = _amount.sub(_addedPoolReward);
            }
        }
        IERC20(dollar).safeApprove(boardroom, _amount);
        IBoardroom(boardroom).allocateSeigniorage(_amount);
        emit BoardroomFunded(now, _amount);
    }

    function allocateSeigniorage() external onlyOneBlock checkCondition checkEpoch checkOperator {
        _updateDollarPrice();
        uint256 dollarSupply = IERC20(dollar).totalSupply().sub(seigniorageSaved);
        // BDIP02: 14 first epochs with 9% max expansion
        if (epoch < bdip02BootstrapEpochs) {
            _sendToBoardRoom(dollarSupply.mul(bdip02BootstrapSupplyExpansionPercent).div(10000));
        } else {
            uint256 dollarPrice = getDollarPrice();
            if (dollarPrice > dollarPriceCeiling) {
                // Expansion ($BSD Price > 1$): there is some seigniorage to be allocated
                uint256 bondSupply = IERC20(bond).totalSupply();
                uint256 _percentage = dollarPrice.sub(dollarPriceOne);
                uint256 _savedForBond;
                uint256 _savedForBoardRoom;
                if (seigniorageSaved >= bondSupply.mul(bondDepletionFloorPercent).div(10000)) {
                    // saved enough to pay dept, mint as usual rate
                    uint256 _mse = maxSupplyExpansionPercent.mul(1e14);
                    if (_percentage > _mse) {
                        _percentage = _mse;
                    }
                    _savedForBoardRoom = dollarSupply.mul(_percentage).div(1e18);
                } else {
                    // have not saved enough to pay dept, mint double
                    uint256 _mse = maxSupplyExpansionPercent.mul(2e14);
                    if (_percentage > _mse) {
                        _percentage = _mse;
                    }
                    uint256 _seigniorage = dollarSupply.mul(_percentage).div(1e18);
                    _savedForBoardRoom = _seigniorage.mul(seigniorageExpansionFloorPercent).div(10000);
                    _savedForBond = _seigniorage.sub(_savedForBoardRoom);
                }
                if (_savedForBoardRoom > 0) {
                    _sendToBoardRoom(_savedForBoardRoom);
                }
                if (_savedForBond > 0) {
                    seigniorageSaved = seigniorageSaved.add(_savedForBond);
                    IBasisAsset(dollar).mint(address(this), _savedForBond);
                    emit TreasuryFunded(now, _savedForBond);
                }
            }
        }
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        // do not allow to drain core tokens
        require(address(_token) != address(dollar), "dollar");
        require(address(_token) != address(bond), "bond");
        require(address(_token) != address(share), "share");
        _token.safeTransfer(_to, _amount);
    }

    /* ========== BOARDROOM CONTROLLING FUNCTIONS ========== */

    function boardroomSetOperator(address _operator) external onlyOperator {
        IBoardroom(boardroom).setOperator(_operator);
    }

    function boardroomSetLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external onlyOperator {
        IBoardroom(boardroom).setLockUp(_withdrawLockupEpochs, _rewardLockupEpochs);
    }

    function boardroomAllocateSeigniorage(uint256 amount) external onlyOperator {
        IBoardroom(boardroom).allocateSeigniorage(amount);
    }

    function boardroomGovernanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        IBoardroom(boardroom).governanceRecoverUnsupported(_token, _amount, _to);
    }
}