/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity 0.6.12;


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




// A simple reward distributor that takes any ERC20 token, and allows Fund Manager roles to send/notify reward to IRewardsDistributionRecipient.
contract RewardDistributor {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    address public governance;
    mapping(address => bool) public fundManager;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address[] memory _fundManagers
    )
        public
    {
        governance = msg.sender;

        for(uint256 i = 0; i < _fundManagers.length; i++) {
            fundManager[_fundManagers[i]] = true;
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function addFundManager(address _address)
        external
        onlyGov
    {
        fundManager[_address] = true;
    }

    function removeFundManager(address _address)
        external
        onlyGov
    {
        fundManager[_address] = false;
    }

    // Allow governance to rescue rewards
    function rescue(address _rewardToken)
        external
        onlyGov
    {
        uint _balance = IERC20(_rewardToken).balanceOf(address(this));
        IERC20(_rewardToken).safeTransfer(governance, _balance);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function distributeRewards(
        IRewardsDistributionRecipient[] calldata _recipients,
        IERC20[] calldata _rewardTokens,
        uint256[] calldata _amounts
    )
        external
        onlyFundManager
    {
        uint256 len = _recipients.length;
        require(len > 0, "Must choose recipients");
        require(len == _rewardTokens.length, "Mismatching inputs");
        require(len == _amounts.length, "Mismatching inputs");

        for(uint i = 0; i < len; i++){
            uint256 amount = _amounts[i];
            IERC20 rewardToken = _rewardTokens[i];
            IRewardsDistributionRecipient recipient = _recipients[i];
            // Send the RewardToken to recipient
            rewardToken.safeTransfer(address(recipient), amount);
            // Only after successfull tx - notify the contract of the new funds
            recipient.notifyRewardAmount(address(rewardToken), amount);

            emit DistributedReward(msg.sender, address(recipient), address(rewardToken), amount);
        }
    }

    /* ========== MODIFIERS ========== */

    modifier onlyGov() {
        require(msg.sender == governance, "!governance");
        _;
    }

    modifier onlyFundManager() {
        require(fundManager[msg.sender] == true, "!manager");
        _;
    }

    /* ========== EVENTS ========== */

    event DistributedReward(address funder, address recipient, address rewardToken, uint256 amount);
}