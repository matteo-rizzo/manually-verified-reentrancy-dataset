pragma solidity 0.5.15;

// YAM v2 to YAM v3 migrator contract

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}







/**
 * @title YAMv2 to V3 Token Migrator
 * @dev YAMv3 Mintable Token with migration from legacy contract.
 */
contract Migrator is Context, Ownable {

    using SafeMath for uint256;

    address public constant yamV2 = address(0xAba8cAc6866B83Ae4eec97DD07ED254282f6aD8A);

    address public yamV3;

    bool public token_initialized;

    bool public delegatorRewardsSet;

    uint256 public constant vestingDuration = 30 days;

    uint256 public constant delegatorVestingDuration = 90 days;

    uint256 public constant startTime = 1600444800; // Friday, September 18, 2020 4:00:00 PM

    uint256 public constant BASE = 10**18;

    mapping(address => uint256) public delegator_vesting;

    mapping(address => uint256) public delegator_claimed;

    mapping(address => uint256) public vesting;

    mapping(address => uint256) public claimed;

    constructor () public {
    }



    /**
     * @dev Sets yamV3 token address
     *
     */
    function setV3Address(address yamV3_) public onlyOwner {
        require(!token_initialized, "already set");
        token_initialized = true;
        yamV3 = yamV3_;
    }

    // Tells contract delegator rewards setting is done
    function delegatorRewardsDone() public onlyOwner {
        delegatorRewardsSet = true;
    }


    function vested(address who) public view returns (uint256) {
      // completion percentage of vesting
      uint256 vestedPerc = now.sub(startTime).mul(BASE).div(vestingDuration);

      uint256 delegatorVestedPerc = now.sub(startTime).mul(BASE).div(delegatorVestingDuration);

      if (vestedPerc > BASE) {
          vestedPerc = BASE;
      }
      if (delegatorVestedPerc > BASE) {
          delegatorVestedPerc = BASE;
      }

      // add to total vesting
      uint256 totalVesting = vesting[who];

      // get redeemable total vested by checking how much time has passed
      uint256 totalVestingRedeemable = totalVesting.mul(vestedPerc).div(BASE);

      uint256 totalVestingDelegator = delegator_vesting[who].mul(delegatorVestedPerc).div(BASE);

      // get already claimed vested rewards
      uint256 alreadyClaimed = claimed[who].add(delegator_claimed[who]);

      // get current redeemable
      return totalVestingRedeemable.add(totalVestingDelegator).sub(alreadyClaimed);
    }


    modifier started() {
        require(block.timestamp >= startTime, "!started");
        require(token_initialized, "!initialized");
        require(delegatorRewardsSet, "!delegatorRewards");
        _;
    }

    /**
     * @dev Migrate a users' entire balance
     *
     * One way function. YAMv2 tokens are BURNED. 1/2 YAMv3 tokens are minted instantly, other half vests over 1 month.
     */
    function migrate()
        external
        started
    {
        // completion percentage of vesting
        uint256 vestedPerc = now.sub(startTime).mul(BASE).div(vestingDuration);

        // completion percentage of delegator vesting
        uint256 delegatorVestedPerc = now.sub(startTime).mul(BASE).div(delegatorVestingDuration);

        if (vestedPerc > BASE) {
            vestedPerc = BASE;
        }
        if (delegatorVestedPerc > BASE) {
            delegatorVestedPerc = BASE;
        }

        // gets the yamValue for a user.
        uint256 yamValue = YAMv2(yamV2).balanceOf(_msgSender());

        // half is instant redeemable
        uint256 halfRedeemable = yamValue / 2;

        uint256 mintAmount;

        // scope
        {
            // add to total vesting
            uint256 totalVesting = vesting[_msgSender()].add(halfRedeemable);

            // update vesting
            vesting[_msgSender()] = totalVesting;

            // get redeemable total vested by checking how much time has passed
            uint256 totalVestingRedeemable = totalVesting.mul(vestedPerc).div(BASE);

            uint256 totalVestingDelegator = delegator_vesting[_msgSender()].mul(delegatorVestedPerc).div(BASE);

            // get already claimed
            uint256 alreadyClaimed = claimed[_msgSender()];

            // get already claimed delegator
            uint256 alreadyClaimedDelegator = delegator_claimed[_msgSender()];

            // get current redeemable
            uint256 currVested = totalVestingRedeemable.sub(alreadyClaimed);

            // get current redeemable delegator
            uint256 currVestedDelegator = totalVestingDelegator.sub(alreadyClaimedDelegator);

            // add instant redeemable to current redeemable to get mintAmount
            mintAmount = halfRedeemable.add(currVested).add(currVestedDelegator);

            // update claimed
            claimed[_msgSender()] = claimed[_msgSender()].add(currVested);

            // update delegator rewards claimed
            delegator_claimed[_msgSender()] = delegator_claimed[_msgSender()].add(currVestedDelegator);
        }


        // BURN YAMv2 - UNRECOVERABLE.
        SafeERC20.safeTransferFrom(
            IERC20(yamV2),
            _msgSender(),
            address(0x000000000000000000000000000000000000dEaD),
            yamValue
        );

        // mint, this is in raw internalDecimals. Handled by updated _mint function
        YAMv3(yamV3).mint(_msgSender(), mintAmount);
    }


    function claimVested()
        external
        started
    {
        // completion percentage of vesting
        uint256 vestedPerc = now.sub(startTime).mul(BASE).div(vestingDuration);

        // completion percentage of delegator vesting
        uint256 delegatorVestedPerc = now.sub(startTime).mul(BASE).div(delegatorVestingDuration);

        if (vestedPerc > BASE) {
            vestedPerc = BASE;
        }
        if (delegatorVestedPerc > BASE) {
          delegatorVestedPerc = BASE;
        }

        // add to total vesting
        uint256 totalVesting = vesting[_msgSender()];

        // get redeemable total vested by checking how much time has passed
        uint256 totalVestingRedeemable = totalVesting.mul(vestedPerc).div(BASE);

        uint256 totalVestingDelegator = delegator_vesting[_msgSender()].mul(delegatorVestedPerc).div(BASE);

        // get already claimed vested rewards
        uint256 alreadyClaimed = claimed[_msgSender()];

        // get already claimed delegator
        uint256 alreadyClaimedDelegator = delegator_claimed[_msgSender()];

        // get current redeemable
        uint256 currVested = totalVestingRedeemable.sub(alreadyClaimed);

        // get current redeemable delegator
        uint256 currVestedDelegator = totalVestingDelegator.sub(alreadyClaimedDelegator);

        // update claimed
        claimed[_msgSender()] = claimed[_msgSender()].add(currVested);

        // update delegator rewards claimed
        delegator_claimed[_msgSender()] = delegator_claimed[_msgSender()].add(currVestedDelegator);

        // mint, this is in raw internalDecimals. Handled by updated _mint function
        YAMv3(yamV3).mint(_msgSender(), currVested.add(currVestedDelegator));
    }


    // this is a gas intensive airdrop of sorts
    function addDelegatorReward(
        address[] calldata delegators,
        uint256[] calldata amounts,
        bool under27 // indicates this batch is for those who delegated under 27 yams
    )
        external
        onlyOwner
    {
        require(!delegatorRewardsSet, "set");
        require(delegators.length == amounts.length, "!len");
        if (!under27) {
            for (uint256 i = 0; i < delegators.length; i++) {
                delegator_vesting[delegators[i]] = amounts[i]; // must be on order of 1e24;
            }
        } else {
            for (uint256 i = 0; i < delegators.length; i++) {
                delegator_vesting[delegators[i]] = 27 * 10**24; // flat distribution;
            }
        }
    }

    // if people are dumb and send tokens here, give governance ability to save them.
    function rescueTokens(
        address token,
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        // transfer to
        SafeERC20.safeTransfer(IERC20(token), to, amount);
    }
}