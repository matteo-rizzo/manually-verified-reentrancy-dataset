/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

// Dependency file: contracts/interfaces/IERC20.sol

// pragma solidity ^0.6.12;




// Dependency file: contracts/Ownable.sol

// pragma solidity ^0.6.12;

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


// Dependency file: contracts/libraries/Math.sol

// pragma solidity ^0.6.12;

// a library for performing various math operations




// Dependency file: contracts/libraries/SafeMath.sol

// pragma solidity ^0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
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




// Dependency file: contracts/libraries/Address.sol

// pragma solidity ^0.6.12;

/**
 * @dev Collection of functions related to the address type
 */


// Dependency file: contracts/libraries/SafeERC20.sol

// pragma solidity ^0.6.12;

// import "contracts/interfaces/IERC20.sol";
// import "contracts/libraries/SafeMath.sol";
// import "contracts/libraries/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Dependency file: contracts/interfaces/IStakingRewards.sol

// pragma solidity ^0.6.12;




// Dependency file: contracts/ReentrancyGuard.sol

// pragma solidity ^0.6.0;

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

    constructor () internal {
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


// Dependency file: contracts/staking/StakingRewardsV2.sol

// pragma solidity ^0.6.12;


// import 'contracts/libraries/Math.sol';
// import 'contracts/libraries/SafeMath.sol';
// import "contracts/libraries/SafeERC20.sol";

// import 'contracts/interfaces/IERC20.sol';
// import 'contracts/interfaces/IStakingRewards.sol';

// import 'contracts/ReentrancyGuard.sol';

contract StakingRewardsV2 is ReentrancyGuard, IStakingRewards {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public initialized;
    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    address public rewardsDistributor;
    address public externalController;

    struct RewardEpoch {
        uint id;
        uint totalSupply;
        uint startEpoch;
        uint finishEpoch;
        uint rewardRate;
        uint lastUpdateTime;
        uint rewardPerTokenStored;
    }
    // epoch
    mapping(uint => RewardEpoch) public epochData;
    mapping(uint => mapping(address => uint)) public userRewardPerTokenPaid;
    mapping(uint => mapping(address => uint)) public rewards;
    mapping(uint => mapping(address => uint)) private _balances;
    mapping(address => uint) public lastAccountEpoch;
    uint public currentEpochId;

    function initialize(
        address _externalController,
        address _rewardsDistributor,
        address _rewardsToken,
        address _stakingToken
        ) external {
            require(initialized == false, "Contract already initialized.");
            rewardsToken = IERC20(_rewardsToken);
            stakingToken = IERC20(_stakingToken);
            rewardsDistributor = _rewardsDistributor;
            externalController = _externalController;
    }

    function _totalSupply(uint epoch) internal view returns (uint) {
        return epochData[epoch].totalSupply;
    }

    function _balanceOf(uint epoch, address account) public view returns (uint) {
        return _balances[epoch][account];
    }

    function _lastTimeRewardApplicable(uint epoch) internal view returns (uint) {
        if (block.timestamp < epochData[epoch].startEpoch) {
            return 0;
        }
        return Math.min(block.timestamp, epochData[epoch].finishEpoch);
    }

    function totalSupply() external override view returns (uint) {
        return _totalSupply(currentEpochId);
    }

    function balanceOf(address account) external override view returns (uint) {
        return _balanceOf(currentEpochId, account);
    }

    function lastTimeRewardApplicable() public override view returns (uint) {
        return _lastTimeRewardApplicable(currentEpochId);
    }

    function _rewardPerToken(uint _epoch) internal view returns (uint) {
        RewardEpoch memory epoch = epochData[_epoch];
        if (block.timestamp < epoch.startEpoch) {
            return 0;
        }
        if (epoch.totalSupply == 0) {
            return epoch.rewardPerTokenStored;
        }
        return
            epoch.rewardPerTokenStored.add(
                _lastTimeRewardApplicable(_epoch).sub(epoch.lastUpdateTime).mul(epoch.rewardRate).mul(1e18).div(epoch.totalSupply)
            );
    }

    function rewardPerToken() public override view returns (uint) {
        _rewardPerToken(currentEpochId);
    }

    function _earned(uint _epoch, address account) internal view returns (uint256) {
        return _balances[_epoch][account].mul(_rewardPerToken(_epoch).sub(userRewardPerTokenPaid[_epoch][account])).div(1e18).add(rewards[_epoch][account]);
    }

    function earned(address account) public override view returns (uint256) {
        return _earned(currentEpochId, account);
    }

    function getRewardForDuration() external override view returns (uint256) {
        RewardEpoch memory epoch = epochData[currentEpochId];
        return epoch.rewardRate.mul(epoch.finishEpoch - epoch.startEpoch);
    }

    function _stake(uint amount, bool withDepositTransfer) internal {
        require(amount > 0, "Cannot stake 0");
        require(lastAccountEpoch[msg.sender] == currentEpochId || lastAccountEpoch[msg.sender] == 0, "Account should update epoch to stake.");
        epochData[currentEpochId].totalSupply = epochData[currentEpochId].totalSupply.add(amount);
        _balances[currentEpochId][msg.sender] = _balances[currentEpochId][msg.sender].add(amount);
        if(withDepositTransfer) {
            stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        lastAccountEpoch[msg.sender] = currentEpochId;
        emit Staked(msg.sender, amount, currentEpochId);
    }

    function stake(uint256 amount) nonReentrant updateReward(msg.sender) override external {
        _stake(amount, true);
    }

    function withdraw(uint256 amount) override public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        uint lastEpoch = lastAccountEpoch[msg.sender];
        epochData[lastEpoch].totalSupply = epochData[lastEpoch].totalSupply.sub(amount);
        _balances[lastEpoch][msg.sender] = _balances[lastEpoch][msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, lastEpoch);
    }

    function getReward() override public nonReentrant updateReward(msg.sender) {
        uint lastEpoch = lastAccountEpoch[msg.sender];
        uint reward = rewards[lastEpoch][msg.sender];
        if (reward > 0) {
            rewards[lastEpoch][msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() override external {
        withdraw(_balances[lastAccountEpoch[msg.sender]][msg.sender]);
        getReward();
    }

    function updateStakingEpoch() public {
        uint lastEpochId = lastAccountEpoch[msg.sender];
        _updateRewardForEpoch(msg.sender, lastEpochId);

        // Remove record about staking on last account epoch
        uint stakedAmount = _balances[lastEpochId][msg.sender];
        _balances[lastEpochId][msg.sender] = 0;
        epochData[lastEpochId].totalSupply = epochData[lastEpochId].totalSupply.sub(stakedAmount);
        // Move collected rewards from last epoch to the current
        rewards[currentEpochId][msg.sender] = rewards[lastEpochId][msg.sender];
        rewards[lastEpochId][msg.sender] = 0;

        // Restake
        lastAccountEpoch[msg.sender] = currentEpochId;
        _stake(stakedAmount, false);
    }

    function _updateRewardForEpoch(address account, uint epoch) internal {
        epochData[epoch].rewardPerTokenStored = _rewardPerToken(epoch);
        epochData[epoch].lastUpdateTime = _lastTimeRewardApplicable(epoch);
        if (account != address(0)) {
            rewards[epoch][account] = _earned(epoch, account);
            userRewardPerTokenPaid[epoch][account] = epochData[epoch].rewardPerTokenStored;
        }
    }


    modifier updateReward(address account) {
        uint lastEpoch = lastAccountEpoch[account];
        if(account == address(0)) {
            lastEpoch = currentEpochId;
        }
        _updateRewardForEpoch(account, lastEpoch);
        _;
    }

    function notifyRewardAmount(uint reward, uint startEpoch, uint finishEpoch) nonReentrant external {
        require(msg.sender == rewardsDistributor, "Only reward distribured allowed.");
        require(startEpoch >= block.timestamp, "Provided start date too late.");
        require(finishEpoch > startEpoch, "Wrong end date epoch.");
        require(reward > 0, "Wrong reward amount");
        uint rewardsDuration = finishEpoch - startEpoch;

        RewardEpoch memory newEpoch;
        // Initialize new epoch
        currentEpochId++;
        newEpoch.id = currentEpochId;
        newEpoch.startEpoch = startEpoch;
        newEpoch.finishEpoch = finishEpoch;
        newEpoch.rewardRate = reward.div(rewardsDuration);
        // last update time will be right when epoch starts
        newEpoch.lastUpdateTime = startEpoch;

        epochData[newEpoch.id] = newEpoch;

        emit EpochAdded(newEpoch.id, startEpoch, finishEpoch, reward);
    }

    function externalWithdraw() external {
        require(msg.sender == externalController, "Only external controller allowed.");
        rewardsToken.transfer(msg.sender, rewardsToken.balanceOf(msg.sender));
    }

    event EpochAdded(uint epochId, uint startEpoch, uint finishEpoch, uint256 reward);
    event Staked(address indexed user, uint amount, uint epoch);
    event Withdrawn(address indexed user, uint amount, uint epoch);
    event RewardPaid(address indexed user, uint reward);


}

// Dependency file: contracts/interfaces/IWSCustomProxy.sol

// pragma solidity ^0.6.12;




// Dependency file: contracts/proxy/WSCustomProxy.sol

// pragma solidity ^0.6.12;

// import 'contracts/interfaces/IWSCustomProxy.sol';

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 * 
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 * 
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () payable external {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () payable external {
        _delegate(_implementation());
    }
}

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 * 
 * Upgradeability is only provided internally through {_upgradeTo}. For an externally upgradeable proxy see
 * {TransparentUpgradeableProxy}.
 */
contract UpgradeableCustomProxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     * 
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor() public payable {
        assert(_IMPLEMENTATION_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation_storage")) - 1));
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementationStorage);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _IMPLEMENTATION_STORAGE_SLOT = 0x32966ed17b28d3117e87cb2c15a847a3829937667aa3286f41cf85a257e10460;

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal virtual override returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_STORAGE_SLOT;
        address storage_address;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            storage_address := sload(slot)
        }
        impl = ImplementationGetter(storage_address).getImplementationAddress();
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     * 
     * Emits an {Upgraded} event.
     */
    function _upgradeStorageTo(address newImplementationStorage) virtual internal {
        _setImplementationStorage(newImplementationStorage);
        emit Upgraded(newImplementationStorage);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementationStorage(address newImplementationStorage) private {
        bytes32 slot = _IMPLEMENTATION_STORAGE_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementationStorage)
        }
    }
}

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 * 
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 * 
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 * 
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 * 
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative inerface of your proxy.
 */
contract TransparentUpgradeableCustomProxy is UpgradeableCustomProxy, IWSCustomProxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor() public payable UpgradeableCustomProxy() {
        require(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1), "Wrong admin slot");
        _setAdmin(msg.sender);
    }

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     */
    function admin() external override ifAdmin returns (address) {
        return _admin();
    }

    function initialize(address _newImplementationStorage, address _admin, bytes calldata _data) external override ifAdmin {
        _upgradeStorageTo(_newImplementationStorage);
        _setAdmin(_admin);
        if(_data.length > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = _implementation().delegatecall(_data);
            require(success);
        }
    }

    /**
     * @dev Returns the current implementation.
     */
    function implementation() external override ifAdmin returns (address) {
        return _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     * 
     * Emits an {AdminChanged} event.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external override ifAdmin {
        require(newAdmin != _admin(), "WSProxy: new admin is the same admin.");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeStorageTo(address newImplementation) external override ifAdmin {
        _upgradeStorageTo(newImplementation);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeStorageToAndCall(address newImplementation, bytes calldata data) external override payable ifAdmin {
        _upgradeStorageTo(newImplementation);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        bytes32 slot = _ADMIN_SLOT;
        // remove this protection
        // require(newAdmin != address(0), "WSProxy: Can't set admin to zero address.");

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newAdmin)
        }
    }
}



// Dependency file: contracts/proxy/WSStakingRewardsProxy.sol

// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity ^0.6.12;

// import "contracts/proxy/WSCustomProxy.sol";

contract StakingProxy is TransparentUpgradeableCustomProxy {
    constructor() public payable TransparentUpgradeableCustomProxy() {
    }
}

// Root file: contracts/staking/StakingRewardsFactoryV2.sol


pragma solidity ^0.6.12;

// import 'contracts/interfaces/IERC20.sol';
// import 'contracts/Ownable.sol';

// import 'contracts/staking/StakingRewardsV2.sol';
// import 'contracts/proxy/WSStakingRewardsProxy.sol';

contract StakingRewardsFactoryV2 is Ownable {
    uint public SEALED_TIME = 16 days;

    bool public initialized;
    address public implementationGetter;
    address public externalController;
    address public rewardsToken;
    address[] public stakingTokens;
    mapping(address => address payable) public stakingRewardsByStakingToken;

    struct Epoch {
        uint id;
        uint startEpoch;
        uint finishEpoch;
        address[] stakingRewards;
        uint[] rewards;
        // could be used later
        uint sealedTimestamp;
        bool executed;
    }
    mapping(uint => Epoch) public stakingEpoch;
    uint public currentEpochId;
    uint public upcomingEpochId;

    function initialize(address _rewardsToken, address _externalController, address _implementationGetter) external {
        require(initialized == false, "StakingRewardsFactoryV2::initialize:Contract already initialized.");
        rewardsToken = _rewardsToken;
        externalController = _externalController;
        implementationGetter = _implementationGetter;
        super._transferOwnership(msg.sender);
        initialized = true;
    }

    function setupNewEpoch(address[] memory stakingTokensEpoch, uint[] memory rewards, uint startEpoch, uint finishEpoch) onlyOwner external {
        require(stakingTokensEpoch.length == rewards.length, "StakingRewardsFactoryV2::setupNewEpoch:Array length should be equal.");
        require(stakingTokensEpoch.length > 0, "StakingRewardsFactoryV2::setupNewEpoch:New epoch should not be empty.");
        Epoch storage newEpoch = stakingEpoch[currentEpochId + 1];
        for(uint i = 0; i < stakingTokensEpoch.length; i++) {
            address stakingReward = stakingRewardsByStakingToken[stakingTokensEpoch[i]];
            require(stakingReward != address(0), "StakingRewardsFactoryV2::setupNewEpoch:Wrong staking reward address");
            require(rewards[i] != 0, "StakingRewardsFactoryV2::setupNewEpoch:Wrong staking reward amount");
            newEpoch.stakingRewards.push(stakingReward);
            newEpoch.rewards.push(rewards[i]);
        }
        newEpoch.startEpoch = startEpoch;
        newEpoch.finishEpoch = finishEpoch;
        newEpoch.id = currentEpochId + 1;
    }

    function cancelNewEpoch() onlyOwner external {
        delete stakingEpoch[currentEpochId + 1];
    }

    function executeNewEpoch() onlyOwner external {
        currentEpochId++;
        Epoch memory newEpoch = stakingEpoch[currentEpochId];
        require(newEpoch.id == currentEpochId, "StakingRewardsFactoryV2::notifyRewardAmount:New epoch should be configured before execution.");
        assert(newEpoch.executed == false);
        for(uint i = 0; i < newEpoch.stakingRewards.length; i++) {
            require(
                IERC20(rewardsToken).transfer(newEpoch.stakingRewards[i], newEpoch.rewards[i]),
                'StakingRewardsFactoryV2::notifyRewardAmount: transfer failed'
            );
            StakingRewardsV2(newEpoch.stakingRewards[i]).notifyRewardAmount(newEpoch.rewards[i], newEpoch.startEpoch, newEpoch.finishEpoch);
        }
        stakingEpoch[currentEpochId].executed = true;
    }

    function deploy(address stakingToken) onlyOwner external {
        require(stakingRewardsByStakingToken[stakingToken] == address(0), 'StakingRewardsFactoryV2::deploy: already deployed');
        stakingRewardsByStakingToken[stakingToken] = address(new StakingProxy());
        // We set admin address to zero, because we can change implementation with implementationGetter
        StakingProxy(stakingRewardsByStakingToken[stakingToken]).initialize(implementationGetter, address(0), '');
        StakingRewardsV2(stakingRewardsByStakingToken[stakingToken]).initialize(externalController, address(this), rewardsToken, stakingToken);
        stakingTokens.push(stakingToken);
    }

}