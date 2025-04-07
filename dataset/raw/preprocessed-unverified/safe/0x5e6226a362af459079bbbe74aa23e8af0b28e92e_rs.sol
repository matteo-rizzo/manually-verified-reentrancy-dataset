/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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
    constructor () internal {
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


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

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



// Dependency file: contracts/interfaces/IFarmFactory.sol

// pragma solidity ^0.6.10;




// Dependency file: contracts/farm/Farm.sol


// pragma solidity 0.6.10;

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// import { IFarmFactory } from "contracts/interfaces/IFarmFactory.sol";

contract Farm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ============ Struct ============ */

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
    }

    struct FarmInfo {
        IERC20 lpToken;
        IERC20 rewardToken;
        uint256 startBlock;
        uint256 blockReward;
        uint256 bonusEndBlock;
        uint256 bonus;
        uint256 endBlock;
        uint256 lastRewardBlock;  // Last block number that reward distribution occurs.
        uint256 accRewardPerShare; // Accumulated Rewards per share, times 1e12
        uint256 farmableSupply; // set in init, total amount of tokens farmable
        uint256 numFarmers;
    }

    /* ============ State Variables ============ */

    // Useful for back-end systems to know how to read the contract (ABI) as we plan to launch multiple farm types
    uint256 public farmType = 1;

    IFarmFactory public factory;
    address public farmGenerator;

    FarmInfo public farmInfo;

    // Information on each user than stakes LP tokens
    mapping (address => UserInfo) public userInfo;

    /* ============ Events ============ */

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event WithdrawWithoutReward(address indexed user, uint256 amount);

    /* ============ Constructor ============ */

    /**
     * Store factory and generator instance.
     *
     * @param _factory              Instance of Farm Factory
     * @param _farmGenerator        Instance of Farm Generator
     */
    constructor(address _factory, address _farmGenerator) public {
        factory = IFarmFactory(_factory);
        farmGenerator = _farmGenerator;
    }

    /* ============ Public/External functions ============ */

    /**
     * Initialize the farming contract. This is called only once upon farm creation and the FarmGenerator
     * ensures the farm has the correct paramaters
     *
     * @param _rewardToken          Instance of reward token contract
     * @param _amount               Total sum of reward
     * @param _lpToken              Instance of LP token contract
     * @param _blockReward          Reward per block
     * @param _startBlock           Block number to start reward
     * @param _bonusEndBlock        Block number to end the bonus reward
     * @param _bonus                Bonus multipler which will be applied until bonus end block
     */
    function init(
        IERC20 _rewardToken,
        uint256 _amount,
        IERC20 _lpToken,
        uint256 _blockReward,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _bonusEndBlock,
        uint256 _bonus
    ) external {
        require(msg.sender == address(farmGenerator), "FORBIDDEN");

        _rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
        farmInfo.rewardToken = _rewardToken;

        farmInfo.startBlock = _startBlock;
        farmInfo.blockReward = _blockReward;
        farmInfo.bonusEndBlock = _bonusEndBlock;
        farmInfo.bonus = _bonus;

        uint256 lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        farmInfo.lpToken = _lpToken;
        farmInfo.lastRewardBlock = lastRewardBlock;
        farmInfo.accRewardPerShare = 0;

        farmInfo.endBlock = _endBlock;
        farmInfo.farmableSupply = _amount;
    }

    /**
     * Updates pool information to be up to date to the current block
     */
    function updatePool() public {
        if (block.number <= farmInfo.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = farmInfo.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            farmInfo.lastRewardBlock = block.number < farmInfo.endBlock ? block.number : farmInfo.endBlock;
            return;
        }
        uint256 multiplier = getMultiplier(farmInfo.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(farmInfo.blockReward);
        farmInfo.accRewardPerShare = farmInfo.accRewardPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        farmInfo.lastRewardBlock = block.number < farmInfo.endBlock ? block.number : farmInfo.endBlock;
    }

    /**
     * Deposit LP token function for msg.sender
     *
     * @param _amount               the total deposit amount
     */
    function deposit(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(farmInfo.accRewardPerShare).div(1e12).sub(user.rewardDebt);
            _safeRewardTransfer(msg.sender, pending);
        }
        if (user.amount == 0 && _amount > 0) {
            factory.userEnteredFarm(msg.sender);
            farmInfo.numFarmers++;
        }
        farmInfo.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(farmInfo.accRewardPerShare).div(1e12);
        emit Deposit(msg.sender, _amount);
    }

    /**
     * Withdraw LP token function for msg.sender
     *
     * @param                       _amount the total withdrawable amount
     */
    function withdraw(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "INSUFFICIENT");
        updatePool();
        if (user.amount == _amount && _amount > 0) {
            factory.userLeftFarm(msg.sender);
            farmInfo.numFarmers--;
        }
        uint256 pending = user.amount.mul(farmInfo.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        _safeRewardTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(farmInfo.accRewardPerShare).div(1e12);
        farmInfo.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _amount);
    }

    /**
     * Function to withdraw LP tokens and forego harvest rewards. Important to protect users LP tokens
     */
    function withdrawWithoutReward() external {
        UserInfo storage user = userInfo[msg.sender];
        farmInfo.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit WithdrawWithoutReward(msg.sender, user.amount);
        if (user.amount > 0) {
            factory.userLeftFarm(msg.sender);
            farmInfo.numFarmers--;
        }
        user.amount = 0;
        user.rewardDebt = 0;
    }

    /**
     * Withdraw tokens emergency.
     *
     * @param _token                Token contract address
     * @param _to                   Address where the token withdraw to
     * @param _amount               Amount of tokens to withdraw
     */
    function emergencyWithdraw(address _token, address _to, uint256 _amount) external onlyOwner {
        IERC20 erc20Token = IERC20(_token);
        require(erc20Token.balanceOf(address(this)) > 0, "Insufficient balane");

        uint256 amountToWithdraw = _amount;
        if (_amount == 0) {
            amountToWithdraw = erc20Token.balanceOf(address(this));
        }
        erc20Token.safeTransfer(_to, amountToWithdraw);
    }

    /* ============ View functions ============ */

    /**
     * Get the reward multiplier over the given _from_block until _to block
     *
     * @param _fromBlock            the start of the period to measure rewards for
     * @param _to                   the end of the period to measure rewards for
     *
     * @return                      The weighted multiplier for the given period
     */
    function getMultiplier(uint256 _fromBlock, uint256 _to) public view returns (uint256) {
        uint256 _from = _fromBlock >= farmInfo.startBlock ? _fromBlock : farmInfo.startBlock;
        uint256 to = farmInfo.endBlock > _to ? _to : farmInfo.endBlock;
        if (to <= farmInfo.bonusEndBlock) {
            return to.sub(_from).mul(farmInfo.bonus);
        } else if (_from >= farmInfo.bonusEndBlock) {
            return to.sub(_from);
        } else {
            return farmInfo.bonusEndBlock.sub(_from).mul(farmInfo.bonus).add(
                to.sub(farmInfo.bonusEndBlock)
            );
        }
    }

    /**
     * Function to see accumulated balance of reward token for specified user
     *
     * @param _user                 the user for whom unclaimed tokens will be shown
     *
     * @return                      total amount of withdrawable reward tokens
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 accRewardPerShare = farmInfo.accRewardPerShare;
        uint256 lpSupply = farmInfo.lpToken.balanceOf(address(this));
        if (block.number > farmInfo.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(farmInfo.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(farmInfo.blockReward);
            accRewardPerShare = accRewardPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    /* ============ Internal functions ============ */

    /**
     * Safe reward transfer function, just in case a rounding error causes pool to not have enough reward tokens
     *
     * @param _to                   the user address to transfer tokens to
     * @param _amount               the total amount of tokens to transfer
     */
    function _safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 rewardBal = farmInfo.rewardToken.balanceOf(address(this));
        if (_amount > rewardBal) {
            farmInfo.rewardToken.transfer(_to, rewardBal);
        } else {
            farmInfo.rewardToken.transfer(_to, _amount);
        }
    }
}


// Root file: contracts/farm/FarmGenerator.sol

pragma solidity 0.6.10;

// import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

// import { IFarmFactory } from "contracts/interfaces/IFarmFactory.sol";
// import { Farm } from "contracts/farm/Farm.sol";

contract FarmGenerator is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ============ Struct ============ */

    struct FarmParameters {
        uint256 bonusBlocks;
        uint256 totalBonusReward;
        uint256 numBlocks;
        uint256 endBlock;
        uint256 requiredAmount;
    }

    /* ============ State Variables ============ */

    IFarmFactory public factory;

    /* ============ Events ============ */

    event FarmCreated(
        IERC20 rewardToken,
        uint256 amount,
        IERC20 lpToken,
        uint256 blockReward,
        uint256 startBlock,
        uint256 bonusEndBlock,
        uint256 bonus
    );

    /* ============ Constructor ============ */

    /**
     * Store factory instance.
     *
     * @param _factory              Instance of Farm Factory contract
     */
    constructor(IFarmFactory _factory) public {
        factory = _factory;
    }

    /**
     * Determine the endBlock based on inputs. Used on the front end to show the exact settings the Farm contract
     * will be deployed with
     *
     * @param _amount               Total sum of reward
     * @param _blockReward          Reward per block
     * @param _startBlock           Block number to start reward
     * @param _bonusEndBlock        Block number to end the bonus reward
     * @param _bonus                Bonus multipler which will be applied until bonus end block
     */
    function determineEndBlock(
        uint256 _amount,
        uint256 _blockReward,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _bonus
    )
        public
        pure
        returns (uint256, uint256)
    {
        FarmParameters memory params;
        params.bonusBlocks = _bonusEndBlock.sub(_startBlock);
        params.totalBonusReward = params.bonusBlocks.mul(_bonus).mul(_blockReward);
        params.numBlocks = _amount.sub(params.totalBonusReward).div(_blockReward);
        params.endBlock = params.numBlocks.add(params.bonusBlocks).add(_startBlock);

        uint256 nonBonusBlocks = params.endBlock.sub(_bonusEndBlock);
        uint256 effectiveBlocks = params.bonusBlocks.mul(_bonus).add(nonBonusBlocks);
        uint256 requiredAmount = _blockReward.mul(effectiveBlocks);
        return (params.endBlock, requiredAmount);
    }

    /**
     * Determine the blockReward based on inputs specifying an end date. Used on the front end to show the exact settings
     * the Farm contract will be deployed with
     *
     * @param _amount               Total sum of reward
     * @param _startBlock           Block number to start reward
     * @param _bonusEndBlock        Block number to end the bonus reward
     * @param _bonus                Bonus multipler which will be applied until bonus end block
     * @param _endBlock             Block number to end reward
     */
    function determineBlockReward(
        uint256 _amount,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _bonus,
        uint256 _endBlock
    )
        public
        pure
        returns (uint256, uint256)
    {
        uint256 bonusBlocks = _bonusEndBlock.sub(_startBlock);
        uint256 nonBonusBlocks = _endBlock.sub(_bonusEndBlock);
        uint256 effectiveBlocks = bonusBlocks.mul(_bonus).add(nonBonusBlocks);
        uint256 blockReward = _amount.div(effectiveBlocks);
        uint256 requiredAmount = blockReward.mul(effectiveBlocks);
        return (blockReward, requiredAmount);
    }

    /**
     * Creates a new Farm contract and registers it in the farm factory. Farming rewards are locked in the farm
     *
     * @param _rewardToken          Instance of reward token contract
     * @param _amount               Total sum of reward
     * @param _lpToken              Instance of LP token contract
     * @param _blockReward          Reward per block
     * @param _startBlock           Block number to start reward
     * @param _bonusEndBlock        Block number to end the bonus reward
     * @param _bonus                Bonus multipler which will be applied until bonus end block
     * @param _manager              Manager of the farm
     */
    function createFarm(
        IERC20 _rewardToken,
        uint256 _amount,
        IERC20 _lpToken,
        uint256 _blockReward,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _bonus,
        address _manager
    )
        public
        onlyOwner
        returns (address)
    {
        require(_startBlock > block.number, "START"); // ideally at least 24 hours more to give farmers time
        require(_bonus > 0, "BONUS");
        require(address(_rewardToken) != address(0), "TOKEN");
        require(_blockReward > 1000, "BR"); // minimum 1000 divisibility per block reward

        (uint256 endBlock, uint256 requiredAmount) = determineEndBlock(_amount, _blockReward, _startBlock, _bonusEndBlock, _bonus);

        _rewardToken.safeTransferFrom(address(msg.sender), address(this), requiredAmount);
        Farm newFarm = new Farm(address(factory), address(this));
        newFarm.transferOwnership(_manager);
        _rewardToken.safeApprove(address(newFarm), requiredAmount);
        newFarm.init(_rewardToken, requiredAmount, _lpToken, _blockReward, _startBlock, endBlock, _bonusEndBlock, _bonus);

        factory.registerFarm(address(newFarm));

        emit FarmCreated(_rewardToken, _amount, _lpToken, _blockReward, _startBlock, _bonusEndBlock, _bonus);
        return (address(newFarm));
    }
}