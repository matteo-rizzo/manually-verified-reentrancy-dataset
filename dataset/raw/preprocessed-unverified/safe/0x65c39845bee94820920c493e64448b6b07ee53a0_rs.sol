/**
 *Submitted for verification at Etherscan.io on 2021-09-06
*/

// SPDX-License-Identifier: AGPL V3.0

pragma solidity 0.8.0;
pragma abicoder v2;



// Part: IBattle



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

/*
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

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Ownable

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
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: BattleRewarder.sol

/**
 * @title  BattleRewarder
 * @notice V0 Reward contract for the Loot wars battle system
 */
contract BattleRewarder is Ownable {
    using SafeERC20 for IERC20;
    // mapping battleId => warrior => bool
    mapping(uint256 => mapping(address => bool)) public isRewardClaimed;
    // coefficient 1 in the reward calculator
    uint256 public X;
    // coefficient 2 in the reward calculator
    uint256 public Y;
    // floor in the reward calculator
    uint256 public F;
    // min number to switch to N
    uint256 public N;
    // address of the xp contract
    IERC20 public xp = IERC20(0xf18eC76f918A89a5d790E7150DD468D750a5c4e8);
    // battle contract
    IBattle public battleContract = IBattle(0x56Ddd8167164DA0c0C48e1e9A904553f3571C5B6);
    bool public isRewarderActive;

    event RewardClaimed(
        uint256 indexed battleId,
        address indexed warrior,
        uint256 rewardAmount
    );
    event BattleChanged(
        address indexed newBattle
    );
    event RewarderStatusChanged(
        bool status
    );
    event VariablesChanged(
        uint256 X,
        uint256 Y,
        uint256 F,
        uint256 N
    );

    function changeXp(address _xp) external onlyOwner {
        xp = IERC20(_xp);
    }

    function setBattleContract(IBattle newBattle) public onlyOwner {
        battleContract = newBattle;
        emit BattleChanged(address(newBattle));
    }

    function changeX(uint256 _X) external onlyOwner {
        X = _X;
    }
    function changeY(uint256 _Y) external onlyOwner {
        Y = _Y;
    }
    function changeF(uint256 _F) external onlyOwner {
        require(_F > 0, "!F");
        F = _F;
    }
    function changeN(uint256 _N) external onlyOwner {
        N = _N;
    }
    function changeAll(uint256 _X, uint256 _Y, uint256 _F, uint256 _N) external onlyOwner {
        require(_F > 0, "!F");
        X = _X;
        Y = _Y;
        F = _F;
        N = _N;
        emit VariablesChanged(_X, _Y, _F, _N);
    }
    function rescueXp(uint256 _amount) external onlyOwner {
        xp.safeTransfer(msg.sender, _amount);
    }
    function addXp(uint256 _amount) external {
        xp.safeTransferFrom(msg.sender, address(this), _amount);
    }
    function switchRewarder(bool _flag) external onlyOwner {
        isRewarderActive = _flag;
        emit RewarderStatusChanged(_flag);
    }

    function claimRewardsForBattle(uint256 battleId) external {
        require(isRewarderActive, "rewarder inactive");
        IBattle.WarriorInfo memory warriorInfo = battleContract.battleIdToWarriorInfo(battleId, msg.sender);
        require(warriorInfo.side != 0, "you did not enlist in the battle you claim!");
        IBattle.BattleInfo memory battleInfo = battleContract.idToBattleInfo(battleId);
        require(block.timestamp > battleInfo.endTimestamp, "Battle has not concluded");
        uint256 side = battleInfo.attackerPower > battleInfo.defenderPower ? 1 : 2;
        // Note: This treats draws as no-win scenarios
        require(side == warriorInfo.side, "Your side did not win");
        uint256 reward;
        if (battleInfo.numWarriors < N){
            reward = _smallN(battleInfo, warriorInfo, side);
        } else {
            reward = _bigN(battleInfo, warriorInfo, side);
        }
        require(reward < xpBalance(), "Notify the Loot Wars DAO to top up the rewarder");
        isRewardClaimed[battleId][msg.sender] = true;
        emit RewardClaimed(battleId, msg.sender, reward);
        xp.safeTransfer(msg.sender, reward);
    }

    function _smallN(IBattle.BattleInfo memory battleInfo, IBattle.WarriorInfo memory warriorInfo, uint256 side) internal pure returns (uint256) {
        if (warriorInfo.power == 0){
            return 100e18;
        } else{
            return warriorInfo.power * 1e18;
        }
    }

    function _bigN(IBattle.BattleInfo memory battleInfo, IBattle.WarriorInfo memory warriorInfo, uint256 side) internal view returns (uint256) {
        uint256 total = side == 1 ? battleInfo.attackerPower : battleInfo.defenderPower;
        uint256 A = battleInfo.attackerPower;
        uint256 B = battleInfo.defenderPower;
        uint256 battleDiff;
        if (A > B) {
            battleDiff = A - B > ((A + B) / F) ? A - B : (A + B) / F;
        } else {
            battleDiff = B - A > ((A + B) / F) ? B - A : (A + B) / F;
        }
        uint256 xpPool = (X * battleInfo.numWarriors**2 + Y * (A + B) / (battleDiff + 1)) * 1e18;
        uint256 power;
        if (warriorInfo.power == 0){
            power = 100;
        } else{
            power = warriorInfo.power;
        }
        uint256 reward = (power * xpPool) / total;
        return reward;
    }
    function xpBalance() public view returns (uint256) {
        return xp.balanceOf(address(this));
    }
}