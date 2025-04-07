/**
 *Submitted for verification at Etherscan.io on 2020-10-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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





/// @title Planets (yield farming)
/// @author Meteor Finance
contract Planets is ReentrancyGuard {
    using SafeMath for uint256;
    address public governance;
    address public rewardToken;
    bool public killed;
    uint256 public adminDeadline;
    uint256 public totalDistributed;
    mapping (address=>bool) tokens;
    mapping (address=>mapping (address=>uint256)) public entryBlock;
    mapping (address=>uint256) public rewards;
    mapping (address=>uint256) public totalValue;
    mapping (address=>mapping (address=>uint256)) public balances;
    
    event Deposit(address indexed owner, address indexed token, uint256 value);
    event Withdraw(address indexed owner, address indexed token, uint256 value, bool rewardOnly);

    constructor (address _governance, address _rewardToken) public {
        governance = _governance;
        rewardToken = _rewardToken;
        killed = false;
        adminDeadline = block.timestamp.add(86400);
    }
    
    modifier govOnly() {
        require(msg.sender == governance, "Only governance address can interact with this function");
        _;
    }
    
    modifier contractAlive() {
        require(killed==false, "Contract is killed, please try emergencyWithdraw()");
        _;
    }
    
    /// @notice Deposit funds to the smart contract
    /// @param _token address of the token to deposit
    /// @param _amount amount of the token to deposit
    /// @return True if deposit is successful
    function deposit(address _token, uint256 _amount) external contractAlive nonReentrant returns (bool) {
        require(tokens[_token] == true, "Token is not allowed for deposit.");
        require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "You do not have enough allowance for this operation.");
        if (entryBlock[msg.sender][_token]>0) {
            _withdrawRewards(msg.sender, _token, true);
        } else {
            entryBlock[msg.sender][_token] = block.number;
        }
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender][_token] = balances[msg.sender][_token].add(_amount);
        totalValue[_token] = totalValue[_token].add(_amount);
        emit Deposit(msg.sender, _token, _amount);
        return true;
    }


    /// @notice Claim rewards and withdraw
    /// @param _token address of the token to withdraw
    /// @param _rewardOnly true if only claiming rewards otherwise false
    /// @return True if withdraw is successful
    function _withdrawRewards(address _receiver, address _token, bool _rewardOnly) internal contractAlive returns (bool) {
        require(entryBlock[_receiver][_token]!=block.number, "Please wait at least one block before new deposit");
        require(81000>totalDistributed, "Contract is out of rewards, please use emergencyWithraw()");
        uint256 rewardAmount = block.number.sub(entryBlock[_receiver][_token]).mul(rewards[_token]).mul(balances[_receiver][_token]).div(totalValue[_token]);
        require(rewardAmount>0, "No rewards are available for this address. Try emergencyWithdraw()");
        if (!_rewardOnly) {
            require(balances[_receiver][_token]>0, "Token balance must be bigger than 0");
            IERC20(_token).transfer(_receiver, balances[_receiver][_token]);
            totalValue[_token] = totalValue[_token].sub(balances[_receiver][_token]);
            balances[_receiver][_token] = 0;
            entryBlock[_receiver][_token] = 0;

        } else {
            entryBlock[_receiver][_token] = block.number;
        }
        IERC20(rewardToken).transfer(_receiver, rewardAmount.mul(100000000000000000));
        totalDistributed = totalDistributed.add(rewardAmount);
        emit Withdraw(_receiver, _token, rewardAmount, _rewardOnly);
        return true;
    }

    /// @notice Claim rewards and withdraw
    /// @param _token address of the token to withdraw
    /// @param _rewardOnly true if only claiming rewards otherwise false
    /// @return True if withdraw is successful
    function withdraw(address _token, bool _rewardOnly) public contractAlive nonReentrant returns (bool) {
        require(entryBlock[msg.sender][_token]>0, "Please make sure you have made a deposit.");
        return _withdrawRewards(msg.sender, _token, _rewardOnly);
    }

    /// @notice Emergency withdraw without claiming rewards
    /// @param _token address of the token to deposit
    /// @return True if withdraw is successful
    function emergencyWithdraw(address _token) external nonReentrant returns (bool) {
        require(balances[msg.sender][_token]>0, "You do not have balance to withdraw");
        IERC20(_token).transfer(msg.sender, balances[msg.sender][_token]);
        totalValue[_token] = totalValue[_token].sub(balances[msg.sender][_token]);
        balances[msg.sender][_token] = 0;
        entryBlock[msg.sender][_token] = 0;
        return true;
    }
    
    
    // @notice Admin withdraw for emergencies
    // @param _amount Amount of reward token to withdraw
    function adminWithdraw(uint256 _amount) external govOnly {
        require(adminDeadline>block.timestamp);
        IERC20(rewardToken).transfer(msg.sender, _amount);
    }

    /// @notice Add new token
    /// @param _token address of the token to add
    /// @param _reward amount of starting rewards
    /// @return True if token adding is successful
    function addToken(address _token, uint256 _reward) external govOnly returns (bool) {
        tokens[_token] = true;
        rewards[_token] = _reward;
        return true;
    }

    /// @notice Delete token
    /// @param _token address of the token to remove
    /// @return True if token removing is successful
    function delToken(address _token) external govOnly returns (bool) {
        require(tokens[_token] == true, "Token already does not exist, so you can not remove it");
        tokens[_token] = false;
        rewards[_token] = 0;
        return true;
    }

    /// @notice Change governance address
    /// @param _governance address of the new governance address
    /// @return True if address change is successful
    function transferGov(address _governance) external govOnly returns (bool) {
        governance = _governance;
        return true;
    }

    /// @notice Kill contract (freezes deposits)
    /// @return True if contract killing is successful
    function kill() external govOnly returns (bool) {
        killed = true;
        return true;
    }

    /// @notice Unkill contract (unfreezes deposits)
    /// @return True if contract unkilling is successful
    function unkill() external govOnly returns (bool) {
        killed = false;
        return true;
    }
 }