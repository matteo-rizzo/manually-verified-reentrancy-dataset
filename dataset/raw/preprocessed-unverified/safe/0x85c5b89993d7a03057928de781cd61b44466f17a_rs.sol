/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity 0.5.2;

/***************
**            **
** INTERFACES **
**            **
***************/

/**
 * @dev Interface of OpenZeppelin's ERC20; For definitions / documentation, see below.
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
 * @title   Lock Drop Contract
 *
 * @dev     This contract implements a Kong Lock Drop.
 *
 *          Notes (check online sources for further details):
 *
 *          - `stakeETH()` can be called to participate in the lock drop by staking ETH. Individual
 *          stakes are immediately sent to separate instances of `LockETH` contracts that only the
 *          staker has access to.
 *
 *          - `claimKong()` can be called to claim Kong once the staking period is over.
 *
 *          - The contract is open for contributions for 30 days after its deployment.
 */
contract LockDrop {
    using SafeMath for uint256;

    // Timestamp for the end of staking.
    uint256 public _stakingEnd;

    // Sum of all contribution weights.
    uint256 public _weightsSum;

    // Address of the KONG ERC20 contract.
    address public _kongERC20Address;

    // Mapping from contributors to contribution weights.
    mapping(address => uint256) public _weights;

    // Mapping from contributors to locking period ends.
    mapping(address => uint256) public _lockingEnds;

    // Events for staking and claiming.
    event Staked(
        address indexed contributor,
        address lockETHAddress,
        uint256 ethStaked,
        uint256 endDate
    );
    event Claimed(
        address indexed claimant,
        uint256 ethStaked,
        uint256 kongClaim
    );

    constructor (address kongERC20Address) public {

        // Set the address of the ERC20 token.
        _kongERC20Address = kongERC20Address;

        // Set the end of the staking period to 30 days after deployment.
        _stakingEnd = block.timestamp + 30 days;

    }

    /**
     * @dev Function to stake ETH in this lock drop.
     *
     *      When called with positive `msg.value` and valid `stakingPeriod`, deploys instance of
     *      `LockETH` contract and transfers `msg.value` to it. Each `LockETH` contract is only
     *      accessible to the address that called `stakeETH()` to deploy the respective instance.
     *
     *      For valid stakes, calculates the variable `weight` as the product of total lockup time
     *      and `msg.value`. Stores `weight` in `_weights[msg.sender]` and adds it to `_weightsSum`.
     *
     *      Expects `block.timestamp` to be smaller than `_stakingEnd`. Does not allow for topping
     *      up of existing stakes. Restricts staking period to be between 90 and 365.
     *
     *      Emits `Staked` event.
     */
    function stakeETH(uint256 stakingPeriod) public payable {

        // Require positive msg.value.
        require(msg.value > 0, 'Msg value = 0.');

        // No topping up.
        require(_weights[msg.sender] == 0, 'No topping up.');

        // No contributions after _stakingEnd.
        require(block.timestamp <= _stakingEnd, 'Closed for contributions.');

        // Ensure the staking period is valid.
        require(stakingPeriod >= 30 && stakingPeriod <= 365, 'Staking period outside of allowed range.');

        // Calculate contribution weight as product of msg.value and total time the ETH is locked.
        uint256 totalTime = _stakingEnd + stakingPeriod * 1 days - block.timestamp;
        uint256 weight = totalTime.mul(msg.value);

        // Adjust contribution weights.
        _weightsSum = _weightsSum.add(weight);
        _weights[msg.sender] = weight;

        // Set end date for lock.
        _lockingEnds[msg.sender] = _stakingEnd + stakingPeriod * 1 days;

        // Deploy new lock contract.
        LockETH lockETH = (new LockETH).value(msg.value)(_lockingEnds[msg.sender], msg.sender);

        // Abort if the new contract's balance is lower than expected.
        require(address(lockETH).balance >= msg.value);

        // Emit event.
        emit Staked(msg.sender, address(lockETH), msg.value, _lockingEnds[msg.sender]);

    }

    /**
     * @dev Function to claim Kong.
     *
     *      Determines the ratio of the contribution by `msg.sender` to all contributions. Sends
     *      the product of this ratio and the contract's Kong balance to `msg.sender`. Sets the
     *      contribution of `msg.sender` to zero afterwards and subtracts it from the sum of all
     *      contributions.
     *
     *      Expects `block.timestamp` to be larger than `_lockingEnds[msg.sender]`. Throws if
     *      `_weights[msg.sender]` is zero. Emits `Claimed` event.
     *
     *      NOTE: Overflow protection in calculation of `kongClaim` prevents anyone staking massive
     *      amounts from ever claiming. Fine as long as product of weight and the contract's Kong
     *      balance is at most (2^256)-1.
     */
    function claimKong() external {

        // Verify that this `msg.sender` has contributed.
        require(_weights[msg.sender] > 0, 'Zero contribution.');

        // Verify that this `msg.sender` can claim.
        require(block.timestamp > _lockingEnds[msg.sender], 'Cannot claim yet.');

        // Calculate amount to return.
        uint256 weight = _weights[msg.sender];
        uint256 kongClaim = IERC20(_kongERC20Address).balanceOf(address(this)).mul(weight).div(_weightsSum);

        // Adjust stake and sum of stakes.
        _weights[msg.sender] = 0;
        _weightsSum = _weightsSum.sub(weight);

        // Send kong to `msg.sender`.
        IERC20(_kongERC20Address).transfer(msg.sender, kongClaim);

        // Emit event.
        emit Claimed(msg.sender, weight, kongClaim);

    }

}

/**
 * @title   LockETH contract.
 *
 * @dev     Escrows ETH until `_endOfLockUp`. Calling `unlockETH()` after `_endOfLockUp` sends ETH
 *          to `_contractOwner`.
 */
contract LockETH {

    uint256 public _endOfLockUp;
    address payable public _contractOwner;

    constructor (uint256 endOfLockUp, address payable contractOwner) public payable {

        _endOfLockUp = endOfLockUp;
        _contractOwner = contractOwner;

    }

    /**
     * @dev Send ETH owned by this contract to `_contractOwner`. Can be called by anyone but
     *      requires `block.timestamp` > `endOfLockUp`.
     */
    function unlockETH() external {

        // Verify end of lock-up period.
        require(block.timestamp > _endOfLockUp, 'Cannot claim yet.');

        // Send ETH balance to `_contractOwner`.
        _contractOwner.transfer(address(this).balance);

    }

}