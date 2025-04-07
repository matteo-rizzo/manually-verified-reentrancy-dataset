/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: TradingRewards.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/TradingRewards.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/TradingRewards
*
* Contract Dependencies: 
*	- IAddressResolver
*	- IERC20
*	- ITradingRewards
*	- MixinResolver
*	- Owned
*	- Pausable
*	- ReentrancyGuard
* Libraries: 
*	- Address
*	- SafeDecimalMath
*	- SafeERC20
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2021 PeriFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/



pragma solidity 0.5.16;

// https://docs.peri.finance/contracts/source/contracts/owned



// Inheritance


// https://docs.peri.finance/contracts/source/contracts/pausable
contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    constructor() internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;

        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = now;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


// https://docs.peri.finance/contracts/source/interfaces/iaddressresolver



// https://docs.peri.finance/contracts/source/interfaces/ipynth



// https://docs.peri.finance/contracts/source/interfaces/iissuer



// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/addressresolver
contract AddressResolver is Owned, IAddressResolver {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== RESTRICTED FUNCTIONS ========== */

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }

    /* ========= PUBLIC FUNCTIONS ========== */

    function rebuildCaches(MixinResolver[] calldata destinations) external {
        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }

    /* ========== VIEWS ========== */

    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {
        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getPynth(bytes32 key) external view returns (address) {
        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.pynths(key));
    }

    /* ========== EVENTS ========== */

    event AddressImported(bytes32 name, address destination);
}


// solhint-disable payable-fallback

// https://docs.peri.finance/contracts/source/contracts/readproxy
contract ReadProxy is Owned {
    address public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(address _target) external onlyOwner {
        target = _target;
        emit TargetUpdated(target);
    }

    function() external {
        // The basics of a proxy read call
        // Note that msg.sender in the underlying will always be the address of this contract.
        assembly {
            calldatacopy(0, 0, calldatasize)

            // Use of staticcall - this will revert if the underlying function mutates state
            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event TargetUpdated(address newTarget);
}


// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/mixinresolver
contract MixinResolver {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {
        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    // Note: this function is public not external in order for it to be overridden and invoked via super in subclasses
    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}

    function rebuildCache() public {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        // The resolver must call this function whenver it updates its state
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }

    /* ========== VIEWS ========== */

    function isResolverCached() external view returns (bool) {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function requireAndGetAddress(bytes32 name) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }

    /* ========== EVENTS ========== */

    event CacheUpdated(bytes32 name, address destination);
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */



/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


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
 * @dev Collection of functions related to the address type,
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


// Libraries


// https://docs.peri.finance/contracts/source/libraries/safedecimalmath



// https://docs.peri.finance/contracts/source/interfaces/itradingrewards






// https://docs.peri.finance/contracts/source/interfaces/iexchanger



// Internal dependencies.


// External dependencies.


// Libraries.


// Internal references.


// https://docs.peri.finance/contracts/source/contracts/tradingrewards
contract TradingRewards is ITradingRewards, ReentrancyGuard, Owned, Pausable, MixinResolver {
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    uint private _currentPeriodID;
    uint private _balanceAssignedToRewards;
    mapping(uint => Period) private _periods;

    struct Period {
        bool isFinalized;
        uint recordedFees;
        uint totalRewards;
        uint availableRewards;
        mapping(address => uint) unaccountedFeesForAccount;
    }

    address private _periodController;

    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */

    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_PERIFINANCE = "PeriFinance";

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address owner,
        address periodController,
        address resolver
    ) public Owned(owner) MixinResolver(resolver) {
        require(periodController != address(0), "Invalid period controller");

        _periodController = periodController;
    }

    /* ========== VIEWS ========== */

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](2);
        addresses[0] = CONTRACT_EXCHANGER;
        addresses[1] = CONTRACT_PERIFINANCE;
    }

    function periFinance() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_PERIFINANCE));
    }

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER));
    }

    function getAvailableRewards() external view returns (uint) {
        return _balanceAssignedToRewards;
    }

    function getUnassignedRewards() external view returns (uint) {
        return periFinance().balanceOf(address(this)).sub(_balanceAssignedToRewards);
    }

    function getRewardsToken() external view returns (address) {
        return address(periFinance());
    }

    function getPeriodController() external view returns (address) {
        return _periodController;
    }

    function getCurrentPeriod() external view returns (uint) {
        return _currentPeriodID;
    }

    function getPeriodIsClaimable(uint periodID) external view returns (bool) {
        return _periods[periodID].isFinalized;
    }

    function getPeriodIsFinalized(uint periodID) external view returns (bool) {
        return _periods[periodID].isFinalized;
    }

    function getPeriodRecordedFees(uint periodID) external view returns (uint) {
        return _periods[periodID].recordedFees;
    }

    function getPeriodTotalRewards(uint periodID) external view returns (uint) {
        return _periods[periodID].totalRewards;
    }

    function getPeriodAvailableRewards(uint periodID) external view returns (uint) {
        return _periods[periodID].availableRewards;
    }

    function getUnaccountedFeesForAccountForPeriod(address account, uint periodID) external view returns (uint) {
        return _periods[periodID].unaccountedFeesForAccount[account];
    }

    function getAvailableRewardsForAccountForPeriod(address account, uint periodID) external view returns (uint) {
        return _calculateRewards(account, periodID);
    }

    function getAvailableRewardsForAccountForPeriods(address account, uint[] calldata periodIDs)
        external
        view
        returns (uint totalRewards)
    {
        for (uint i = 0; i < periodIDs.length; i++) {
            uint periodID = periodIDs[i];

            totalRewards = totalRewards.add(_calculateRewards(account, periodID));
        }
    }

    function _calculateRewards(address account, uint periodID) internal view returns (uint) {
        Period storage period = _periods[periodID];
        if (period.availableRewards == 0 || period.recordedFees == 0 || !period.isFinalized) {
            return 0;
        }

        uint accountFees = period.unaccountedFeesForAccount[account];
        if (accountFees == 0) {
            return 0;
        }

        uint participationRatio = accountFees.divideDecimal(period.recordedFees);
        return participationRatio.multiplyDecimal(period.totalRewards);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function claimRewardsForPeriod(uint periodID) external nonReentrant notPaused {
        _claimRewards(msg.sender, periodID);
    }

    function claimRewardsForPeriods(uint[] calldata periodIDs) external nonReentrant notPaused {
        for (uint i = 0; i < periodIDs.length; i++) {
            uint periodID = periodIDs[i];

            // Will revert if any independent claim reverts.
            _claimRewards(msg.sender, periodID);
        }
    }

    function _claimRewards(address account, uint periodID) internal {
        Period storage period = _periods[periodID];
        require(period.isFinalized, "Period is not finalized");

        uint amountToClaim = _calculateRewards(account, periodID);
        require(amountToClaim > 0, "No rewards available");

        period.unaccountedFeesForAccount[account] = 0;
        period.availableRewards = period.availableRewards.sub(amountToClaim);

        _balanceAssignedToRewards = _balanceAssignedToRewards.sub(amountToClaim);

        periFinance().safeTransfer(account, amountToClaim);

        emit RewardsClaimed(account, amountToClaim, periodID);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function recordExchangeFeeForAccount(uint usdFeeAmount, address account) external onlyExchanger {
        Period storage period = _periods[_currentPeriodID];
        // Note: In theory, the current period will never be finalized.
        // Such a require could be added here, but it would just spend gas, since it should always satisfied.

        period.unaccountedFeesForAccount[account] = period.unaccountedFeesForAccount[account].add(usdFeeAmount);
        period.recordedFees = period.recordedFees.add(usdFeeAmount);

        emit ExchangeFeeRecorded(account, usdFeeAmount, _currentPeriodID);
    }

    function closeCurrentPeriodWithRewards(uint rewards) external onlyPeriodController {
        uint currentBalance = periFinance().balanceOf(address(this));
        uint availableForNewRewards = currentBalance.sub(_balanceAssignedToRewards);
        require(rewards <= availableForNewRewards, "Insufficient free rewards");

        Period storage period = _periods[_currentPeriodID];

        period.totalRewards = rewards;
        period.availableRewards = rewards;
        period.isFinalized = true;

        _balanceAssignedToRewards = _balanceAssignedToRewards.add(rewards);

        emit PeriodFinalizedWithRewards(_currentPeriodID, rewards);

        _currentPeriodID = _currentPeriodID.add(1);

        emit NewPeriodStarted(_currentPeriodID);
    }

    function recoverTokens(address tokenAddress, address recoverAddress) external onlyOwner {
        _validateRecoverAddress(recoverAddress);
        require(tokenAddress != address(periFinance()), "Must use another function");

        IERC20 token = IERC20(tokenAddress);

        uint tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to recover");

        token.safeTransfer(recoverAddress, tokenBalance);

        emit TokensRecovered(tokenAddress, recoverAddress, tokenBalance);
    }

    function recoverUnassignedRewardTokens(address recoverAddress) external onlyOwner {
        _validateRecoverAddress(recoverAddress);

        uint tokenBalance = periFinance().balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to recover");

        uint unassignedBalance = tokenBalance.sub(_balanceAssignedToRewards);
        require(unassignedBalance > 0, "No tokens to recover");

        periFinance().safeTransfer(recoverAddress, unassignedBalance);

        emit UnassignedRewardTokensRecovered(recoverAddress, unassignedBalance);
    }

    function recoverAssignedRewardTokensAndDestroyPeriod(address recoverAddress, uint periodID) external onlyOwner {
        _validateRecoverAddress(recoverAddress);
        require(periodID < _currentPeriodID, "Cannot recover from active");

        Period storage period = _periods[periodID];
        require(period.availableRewards > 0, "No rewards available to recover");

        uint amount = period.availableRewards;
        periFinance().safeTransfer(recoverAddress, amount);

        _balanceAssignedToRewards = _balanceAssignedToRewards.sub(amount);

        delete _periods[periodID];

        emit AssignedRewardTokensRecovered(recoverAddress, amount, periodID);
    }

    function _validateRecoverAddress(address recoverAddress) internal view {
        if (recoverAddress == address(0) || recoverAddress == address(this)) {
            revert("Invalid recover address");
        }
    }

    function setPeriodController(address newPeriodController) external onlyOwner {
        require(newPeriodController != address(0), "Invalid period controller");

        _periodController = newPeriodController;

        emit PeriodControllerChanged(newPeriodController);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyPeriodController() {
        require(msg.sender == _periodController, "Caller not period controller");
        _;
    }

    modifier onlyExchanger() {
        require(msg.sender == address(exchanger()), "Only Exchanger can invoke this");
        _;
    }

    /* ========== EVENTS ========== */

    event ExchangeFeeRecorded(address indexed account, uint amount, uint periodID);
    event RewardsClaimed(address indexed account, uint amount, uint periodID);
    event NewPeriodStarted(uint periodID);
    event PeriodFinalizedWithRewards(uint periodID, uint rewards);
    event TokensRecovered(address tokenAddress, address recoverAddress, uint amount);
    event UnassignedRewardTokensRecovered(address recoverAddress, uint amount);
    event AssignedRewardTokensRecovered(address recoverAddress, uint amount, uint periodID);
    event PeriodControllerChanged(address newPeriodController);
}