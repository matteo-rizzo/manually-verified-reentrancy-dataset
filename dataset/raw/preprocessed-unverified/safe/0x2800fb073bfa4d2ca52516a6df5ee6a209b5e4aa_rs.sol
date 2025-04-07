/**
 *Submitted for verification at Etherscan.io on 2020-10-18
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





contract Planets is ReentrancyGuard {
    using SafeMath for uint256;
    address public governance;
    address public rewardToken;
    bool public killed;
    uint256 withdrawDeadline;
    mapping (address=>bool) tokens;
    mapping (address=>mapping (address=>uint256)) entryBlock;
    mapping (address=>uint256) public rewards;
    mapping (address=>uint256) totalValue;
    mapping (address=>uint256) public totalHolders;
    mapping (address=>mapping (address=>uint256)) public balance;
    
    event Deposit(address indexed owner, address indexed token, uint256 value);
    event Withdraw(address indexed owner, address indexed token, uint256 value, bool rewardOnly);

    constructor (address _governance, address _rewardToken) public {
        governance = _governance;
        rewardToken = _rewardToken;
        killed = false;
    }
    
    modifier govOnly() {
        require(msg.sender == governance);
        _;
    }
    
    modifier contractAlive() {
        require(killed==false);
        _;
    }
    
    function deposit(address _token, uint256 _amount) external contractAlive returns (bool) {
        require(tokens[_token] == true, "TOKEN_NOT_ALLOWED");
        require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "ALLOWANCE_NOT_ENOUGH");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        balance[msg.sender][_token] = balance[msg.sender][_token].add(_amount);
        totalHolders[_token] = totalHolders[_token].add(1);
        totalValue[_token] = totalValue[_token].add(_amount);
        entryBlock[msg.sender][_token] = block.number;
        emit Deposit(msg.sender, _token, _amount);
        return true;
    }

    function withdraw(address _token, bool _rewardOnly) external contractAlive nonReentrant returns (bool) {
        require(entryBlock[msg.sender][_token]>0, "NO_TOKEN_DEPOSIT");
        require(entryBlock[msg.sender][_token]!=block.number);
        require(rewards[_token]>0, "NO_REWARD_OFFERED_FOR_TOKEN");
        uint256 rewardAmount = block.number.sub(entryBlock[msg.sender][_token]).mul(rewards[_token]).mul(balance[msg.sender][_token]).div(totalValue[_token]);
        require(IERC20(rewardToken).balanceOf(address(this))>rewardAmount, "NOT_ENOUGH_REWARD_TOKEN_USE_EMERGENCY_WITHDRAW");
        require(rewardAmount>0, "NO_REWARDS_FOR_ADDRESS");
        if (!_rewardOnly) {
            require(balance[msg.sender][_token]>0);
            IERC20(_token).transfer(msg.sender, balance[msg.sender][_token]);
            totalHolders[_token] = totalHolders[_token].sub(1);
            totalValue[_token] = totalValue[_token].sub(balance[msg.sender][_token]);
            balance[msg.sender][_token] = 0;
            entryBlock[msg.sender][_token] = 0;

        } else {
            entryBlock[msg.sender][_token] = block.number;
        }
        IERC20(rewardToken).transfer(msg.sender, rewardAmount);
        emit Withdraw(msg.sender, _token, rewardAmount, _rewardOnly);
        return true;
    }

    function emergencyWithdraw(address _token) external nonReentrant returns (bool) {
        require(balance[msg.sender][_token]>0, "NO_INITIAL_BALANCE_FOUND");
        IERC20(_token).transfer(msg.sender, balance[msg.sender][_token]);
        totalValue[_token] = totalValue[_token].sub(balance[msg.sender][_token]);
        balance[msg.sender][_token] = 0;
        return true;
    }

    function adminWithdraw(uint256 _amount) external govOnly nonReentrant returns (bool) {
        IERC20(rewardToken).transfer(msg.sender, _amount);
        return true;
    }

    function addToken(address _token, uint256 _reward) external govOnly returns (bool) {
        tokens[_token] = true;
        rewards[_token] = _reward;
        return true;
    }

    function delToken(address _token) external govOnly returns (bool) {
        tokens[_token] = false;
        rewards[_token] = 0;
        return true;
    }
    
    function changeGovernance(address _governance) external govOnly returns (bool) {
        governance = _governance;
        return true;
    }

    function kill() external govOnly returns (bool) {
        killed = true;
        return true;
    }

    function unkill() external govOnly returns (bool) {
        killed = false;
        return true;
    }
 }