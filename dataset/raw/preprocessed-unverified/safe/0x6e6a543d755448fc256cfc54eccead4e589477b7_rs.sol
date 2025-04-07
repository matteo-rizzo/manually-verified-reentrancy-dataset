/**
 *Submitted for verification at Etherscan.io on 2020-10-27
*/

// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

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



// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol

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


// Dependency file: @uniswap/lib/contracts/libraries/TransferHelper.sol

// pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false



// Dependency file: contracts/IUniTradeStaker.sol

// pragma solidity ^0.6.6;




// Root file: contracts/UniTradeStaker01.sol

pragma solidity ^0.6.6;

// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
// import "contracts/IUniTradeStaker.sol";

contract UniTradeStaker01 is IUniTradeStaker, ReentrancyGuard {
    using SafeMath for uint256;

    address immutable unitrade;

    uint256 constant DEFAULT_STAKE_PERIOD = 30 days;
    uint256 public totalStake;
    uint256 totalWeight;
    uint256 public totalEthReceived;
    mapping(address => uint256) public staked;
    mapping(address => uint256) public timelock;
    mapping(address => uint256) weighted;
    mapping(address => uint256) accumulated;

    event Stake(address indexed staker, uint256 unitradeIn);
    event Withdraw(address indexed staker, uint256 unitradeOut, uint256 reward);
    event Deposit(address indexed depositor, uint256 amount);

    constructor(address _unitrade) public {
        unitrade = _unitrade;
    }

    function stake(uint256 unitradeIn) nonReentrant public {
        require(unitradeIn > 0, "Nothing to stake");

        _stake(unitradeIn);
        timelock[msg.sender] = block.timestamp.add(DEFAULT_STAKE_PERIOD);

        TransferHelper.safeTransferFrom(
            unitrade,
            msg.sender,
            address(this),
            unitradeIn
        );
    }

    function withdraw() nonReentrant public returns (uint256 unitradeOut, uint256 reward) {
        require(block.timestamp >= timelock[msg.sender], "Stake is locked");

        (unitradeOut, reward) = _applyReward();
        emit Withdraw(msg.sender, unitradeOut, reward);

        timelock[msg.sender] = 0;

        TransferHelper.safeTransfer(unitrade, msg.sender, unitradeOut);
        if (reward > 0) {
            TransferHelper.safeTransferETH(msg.sender, reward);
        }
    }

    function payout() nonReentrant public returns (uint256 reward) {
        (uint256 unitradeOut, uint256 _reward) = _applyReward();
        emit Withdraw(msg.sender, unitradeOut, _reward);
        reward = _reward;

        require(reward > 0, "Nothing to pay out");
        TransferHelper.safeTransferETH(msg.sender, reward);

        // restake after withdrawal
        _stake(unitradeOut);
        timelock[msg.sender] = block.timestamp.add(DEFAULT_STAKE_PERIOD);
    }

    function deposit() nonReentrant public override payable {
        require(msg.value > 0, "Nothing to deposit");
        require(totalStake > 0, "Nothing staked");

        totalEthReceived = totalEthReceived.add(msg.value);

        emit Deposit(msg.sender, msg.value);

        _distribute(msg.value, totalStake);
    }

    function _stake(uint256 unitradeIn) private {
        uint256 addBack;
        if (staked[msg.sender] > 0) {
            (uint256 unitradeOut, uint256 reward) = _applyReward();
            addBack = unitradeOut;
            accumulated[msg.sender] = reward;
            staked[msg.sender] = unitradeOut;
        }

        staked[msg.sender] = staked[msg.sender].add(unitradeIn);
        weighted[msg.sender] = totalWeight;
        totalStake = totalStake.add(unitradeIn);

        if (addBack > 0) {
            totalStake = totalStake.add(addBack);
        }

        emit Stake(msg.sender, unitradeIn);
    }

    function _applyReward() private returns (uint256 unitradeOut, uint256 reward) {
        require(staked[msg.sender] > 0, "Nothing staked");

        unitradeOut = staked[msg.sender];
        reward = unitradeOut
            .mul(totalWeight.sub(weighted[msg.sender]))
            .div(10**18)
            .add(accumulated[msg.sender]);
        totalStake = totalStake.sub(unitradeOut);
        accumulated[msg.sender] = 0;
        staked[msg.sender] = 0;
    }

    function _distribute(uint256 _value, uint256 _totalStake) private {
        totalWeight = totalWeight.add(_value.mul(10**18).div(_totalStake));
    }
}