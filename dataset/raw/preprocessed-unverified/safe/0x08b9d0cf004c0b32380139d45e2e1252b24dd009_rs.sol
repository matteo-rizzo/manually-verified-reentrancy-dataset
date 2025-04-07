/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;









contract pVaultEthV2 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    struct Reward {
        uint256 amount;
        uint256 timestamp;
        uint256 totalDeposit;
    }

    mapping(address => uint256) public _lastCheckTime;
    mapping(address => uint256) public _rewardBalance;
    mapping(address => uint256) public _depositBalances;

    uint256 public _totalDeposit;

    Reward[] public _rewards;

    string public _vaultName;

    IERC20 public token1;
    address payable public feeAddress;
    address payable public vaultAddress;
    uint32 public feePermill = 5;
    uint256 public delayDuration = 7 days;
    bool public withdrawable;
    
    address public gov;

    uint256 public _rewardCount;

    event SentReward(uint256 amount);
    event Deposited(address indexed user, uint256 amount);
    event ClaimedReward(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor (address _token1, address payable _feeAddress, address payable _vaultAddress, string memory name) {
        token1 = IERC20(_token1);
        feeAddress = _feeAddress;
        vaultAddress = _vaultAddress;
        _vaultName = name;
        gov = msg.sender;
    }

    modifier onlyGov() {
        require(msg.sender == gov, "!governance");
        _;
    }

    function setGovernance(address _gov)
        external
        onlyGov
    {
        gov = _gov;
    }

    function setToken1(address _token)
        external
        onlyGov
    {
        token1 = IERC20(_token);
    }

    function setFeeAddress(address payable _feeAddress)
        external
        onlyGov
    {
        feeAddress = _feeAddress;
    }

    function setVaultAddress(address payable _vaultAddress)
        external
        onlyGov
    {
        vaultAddress = _vaultAddress;
    }

    function setFeePermill(uint32 _feePermill)
        external
        onlyGov
    {
        feePermill = _feePermill;
    }

    function setDelayDuration(uint32 _delayDuration)
        external
        onlyGov
    {
        delayDuration = _delayDuration;
    }

    function setWithdrawable(bool _withdrawable)
        external
        onlyGov
    {
        withdrawable = _withdrawable;
    }

    function setVaultName(string memory name)
        external
        onlyGov
    {
        _vaultName = name;
    }

    function balance0()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    function balance1()
        external
        view
        returns (uint256)
    {
        return token1.balanceOf(address(this));
    }

    function getReward(address userAddress)
        internal 
    {
        uint256 lastCheckTime = _lastCheckTime[userAddress];
        uint256 rewardBalance = _rewardBalance[userAddress];
        if (lastCheckTime > 0 && _rewards.length > 0) {
            for (uint i = _rewards.length - 1; lastCheckTime < _rewards[i].timestamp; i--) {
                rewardBalance = rewardBalance.add(_rewards[i].amount.mul(_depositBalances[userAddress]).div(_rewards[i].totalDeposit));
                if (i == 0) break;
            }
        }
        _rewardBalance[userAddress] = rewardBalance;
        _lastCheckTime[msg.sender] = block.timestamp;
    }

    function deposit() public payable {
        require(msg.value > 0, "can't deposit 0");
        uint256 amount = msg.value;
        getReward(msg.sender);

        uint256 feeAmount = amount.mul(feePermill).div(1000);
        uint256 realAmount = amount.sub(feeAmount);
        
        if ( ! feeAddress.send(feeAmount)) {
            feeAddress.transfer(feeAmount);
        }
        if ( ! vaultAddress.send(realAmount)) {
            vaultAddress.transfer(realAmount);
        }

        _depositBalances[msg.sender] = _depositBalances[msg.sender].add(realAmount);
        _totalDeposit = _totalDeposit.add(realAmount);
        emit Deposited(msg.sender, realAmount);
    }

    function sendReward(uint256 amount) external {
        require(amount > 0, "can't reward 0");
        require(_totalDeposit > 0, "totalDeposit must bigger than 0");
        token1.safeTransferFrom(msg.sender, address(this), amount);

        Reward memory reward;
        reward = Reward(amount, block.timestamp, _totalDeposit);
        _rewards.push(reward);
        emit SentReward(amount);
    }

    function claimReward(uint256 amount) external {
        getReward(msg.sender);

        uint256 rewardLimit = getRewardAmount(msg.sender);

        if (amount > rewardLimit) {
            amount = rewardLimit;
        }
        _rewardBalance[msg.sender] = _rewardBalance[msg.sender].sub(amount);
        token1.safeTransfer(msg.sender, amount);
    }

    function claimRewardAll() external {
        getReward(msg.sender);
        
        uint256 rewardLimit = getRewardAmount(msg.sender);
        
        _rewardBalance[msg.sender] = _rewardBalance[msg.sender].sub(rewardLimit);
        token1.safeTransfer(msg.sender, rewardLimit);
    }
    
    function getRewardAmount(address userAddress) public view returns (uint256) {
        uint256 lastCheckTime = _lastCheckTime[userAddress];
        uint256 rewardBalance = _rewardBalance[userAddress];
        if (_rewards.length > 0) {
            if (lastCheckTime > 0) {
                for (uint i = _rewards.length - 1; lastCheckTime < _rewards[i].timestamp; i--) {
                    rewardBalance = rewardBalance.add(_rewards[i].amount.mul(_depositBalances[userAddress]).div(_rewards[i].totalDeposit));
                    if (i == 0) break;
                }
            }
            
            for (uint j = _rewards.length - 1; block.timestamp < _rewards[j].timestamp.add(delayDuration); j--) {
                uint256 timedAmount = _rewards[j].amount.mul(_depositBalances[userAddress]).div(_rewards[j].totalDeposit);
                timedAmount = timedAmount.mul(_rewards[j].timestamp.add(delayDuration).sub(block.timestamp)).div(delayDuration);
                rewardBalance = rewardBalance.sub(timedAmount);
                if (j == 0) break;
            }
        }
        return rewardBalance;
    }
}