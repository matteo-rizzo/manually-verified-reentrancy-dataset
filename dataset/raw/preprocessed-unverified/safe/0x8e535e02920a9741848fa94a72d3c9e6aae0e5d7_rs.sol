/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;









contract pFDIVault {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    struct RewardDivide {
        uint256 amount;
        uint256 startTime;
        uint256 checkTime;
    }

    string public _vaultName;
    IERC20 public token1;
    address payable public feeAddress;
    address payable public vaultAddress;
    uint32 public feePermill = 5;
    uint256 public delayDuration = 7 days;
    bool public withdrawable;
    
    address public gov;
    uint256 public totalDeposit;
    mapping(address => uint256) public depositBalances;
    mapping(address => uint256) public rewardBalances;
    address[] public addressIndices;

    mapping(uint256 => RewardDivide) public _rewards;
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
        public
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    function balance1()
        public
        view
        returns (uint256)
    {
        return token1.balanceOf(address(this));
    }

    function rewardUpdate()
        public
    {
        if (_rewardCount > 0 && totalDeposit > 0) {
            uint256 i;
            uint256 j;

            for (i = _rewardCount - 1; _rewards[i].startTime < block.timestamp; --i) {
                uint256 duration;
                if (block.timestamp.sub(_rewards[i].startTime) > delayDuration) {
                    duration = _rewards[i].startTime.add(delayDuration).sub(_rewards[i].checkTime);
                    _rewards[i].startTime = uint256(-1);
                } else {
                    duration = block.timestamp.sub(_rewards[i].checkTime);
                }
                _rewards[i].checkTime = block.timestamp;
                uint256 timedAmount = _rewards[i].amount.mul(duration).div(delayDuration);
                uint256 addAmount;
                for (j = 0; j < addressIndices.length; j++) {
                    addAmount = timedAmount.mul(depositBalances[addressIndices[j]]).div(totalDeposit);
                    rewardBalances[addressIndices[j]] = rewardBalances[addressIndices[j]].add(addAmount);
                }
                if (i == 0) {
                    break;
                }
            }
        }
    }

    function deposit()
        public
        payable
    {
        uint256 _amount = msg.value;
        require(_amount > 0, "can't deposit 0");

        rewardUpdate();

        uint256 arrayLength = addressIndices.length;
        bool found = false;
        for (uint256 i = 0; i < arrayLength; i++) {
            if (addressIndices[i]==msg.sender){
                found=true;
                break;
            }
        }
        
        if(!found){
            addressIndices.push(msg.sender);
        }
        
        uint256 feeAmount = _amount.mul(feePermill).div(1000);
        uint256 realAmount = _amount.sub(feeAmount);
        
        if ( ! feeAddress.send(feeAmount)) {
            feeAddress.transfer(feeAmount);
        }

        if ( ! vaultAddress.send(realAmount)) {
            vaultAddress.transfer(realAmount);
        }
        
        totalDeposit = totalDeposit.add(realAmount);
        depositBalances[msg.sender] = depositBalances[msg.sender].add(realAmount);
        emit Deposited(msg.sender, realAmount);
    }
    
    function sendReward(uint256 _amount)
        external
    {
        require(_amount > 0, "can't reward 0");
        require(totalDeposit > 0, "totalDeposit must bigger than 0");
        token1.safeTransferFrom(msg.sender, address(this), _amount);

        rewardUpdate();

        _rewards[_rewardCount].amount = _amount;
        _rewards[_rewardCount].startTime = block.timestamp;
        _rewards[_rewardCount].checkTime = block.timestamp;
        _rewardCount++;
        emit SentReward(_amount);
    }
    
    function claimRewardAll()
        external
    {
        claimReward(uint256(-1));
    }
    
    function claimReward(uint256 _amount)
        public
    {
        require(_rewardCount > 0, "no reward amount");

        rewardUpdate();

        if (_amount > rewardBalances[msg.sender]) {
            _amount = rewardBalances[msg.sender];
        }

        require(_amount > 0, "can't claim reward 0");

        token1.safeTransfer(msg.sender, _amount);
        
        rewardBalances[msg.sender] = rewardBalances[msg.sender].sub(_amount);
        emit ClaimedReward(msg.sender, _amount);
    }

    function availableRewardAmount(address owner)
        public
        view
        returns(uint256)
    {
        uint256 i;
        uint256 availableReward = rewardBalances[owner];
        if (_rewardCount > 0 && totalDeposit > 0) {
            for (i = _rewardCount - 1; _rewards[i].startTime < block.timestamp; --i) {
                uint256 duration;
                if (block.timestamp.sub(_rewards[i].startTime) > delayDuration) {
                    duration = _rewards[i].startTime.add(delayDuration).sub(_rewards[i].checkTime);
                } else {
                    duration = block.timestamp.sub(_rewards[i].checkTime);
                }
                uint256 timedAmount = _rewards[i].amount.mul(duration).div(delayDuration);
                uint256 addAmount = timedAmount.mul(depositBalances[owner]).div(totalDeposit);
                    availableReward = availableReward.add(addAmount);
                if (i == 0) {
                    break;
                }
            }
        }
        return availableReward;
    }
}