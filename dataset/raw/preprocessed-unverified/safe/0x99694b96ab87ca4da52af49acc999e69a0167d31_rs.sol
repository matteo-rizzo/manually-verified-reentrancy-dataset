/**
 *Submitted for verification at Etherscan.io on 2021-02-08
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity ^0.5.16;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(initializing || isConstructor() || !initialized);

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract ERC20Token
{
    function decimals() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}




/**
 * @dev Collection of functions related to the address type,
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */







contract VMRDepo is Initializable
{
    using SafeMath for uint256;
    using UniversalERC20 for ERC20Token;

    //  = ERC20Token(0xeE1a71a00aa9771cBbb5a9816aF5bB43fa3c6810); // Kovan
    ERC20Token constant TokenVMR =  ERC20Token(0x063b98a414EAA1D4a5D4fC235a22db1427199024); // Mainnet

    address payable public owner;
    address payable public newOwnerCandidate;
    mapping(address => bool) public admins;

    uint256 constant delayBeforeRewardWithdrawn = 30 days;
    
    struct GlobalState {
        uint256 totalVMR; // current amount
        
        uint256 maxTotalVMR; // 50
        uint256 maxVMRPerUser; // 3 * 1e18
        
        // reward per token for 30 days
        uint256 rewardPerToken;
        uint256 startRewardDate;
        uint256 totalUniqueUsers;    
        mapping (address => uint256) investors;
    }
    GlobalState[] states;
    uint256 public currentState;
    
    event DepositTokens(address indexed userAddress, uint256 prevAmount, uint256 newAmount);
    event NewPeriodStarted(uint256 newState);

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin()
    {
        require(admins[msg.sender]);
        _;
    }
    
    modifier onlyOwnerOrAdmin()
    {
        require(msg.sender == owner || admins[msg.sender]);
        _;
    }

    function initialize() initializer public {
        owner = msg.sender;
        addState(500 * 1e18, 10 * 1e18, 1100000, true);  // 1
        addState(5000 * 1e18, 50 * 1e18, 900000, false); // 2
        setAdmin(0x6Ecb917AfD0611F8Ab161f992a12c82e29dc533c, true);
        owner = 0x4B7b1878338251874Ad8Dace56D198e31278676d;
    }

    function addState(uint256 _maxTotalVMRInWei, uint256 _maxVMRPerUserInWei, uint256 _rewardPerTokenInUSDT, bool finishNow) public onlyOwnerOrAdmin {
        require(_rewardPerTokenInUSDT < 1e16);
        GlobalState memory newState;
        newState.maxTotalVMR = _maxTotalVMRInWei;
        newState.maxVMRPerUser = _maxVMRPerUserInWei;
        newState.rewardPerToken = _rewardPerTokenInUSDT;
        if (finishNow) newState.startRewardDate = now - delayBeforeRewardWithdrawn;
        states.push(newState);
        if (currentState == 0) currentState = 1;
    }
    function changeStartDateState(uint256 _stateNumber, uint256 _startRewardDate) public onlyOwnerOrAdmin {
        states[_stateNumber].startRewardDate = _startRewardDate;    
    }
    
    function editState(uint256 _stateNumber, uint256 _maxTotalVMRInWei, uint256 _maxVMRPerUserInWei, uint256 _rewardPerTokenInUSDT) public onlyOwnerOrAdmin {
        require(_rewardPerTokenInUSDT < 1e16);
        GlobalState storage activeState = states[_stateNumber];
        activeState.maxTotalVMR = _maxTotalVMRInWei;
        activeState.maxVMRPerUser = _maxVMRPerUserInWei;
        activeState.rewardPerToken = _rewardPerTokenInUSDT;
    }

    function setAdmin(address newAdmin, bool activate) onlyOwner public {
        admins[newAdmin] = activate;
    }

    function withdraw(uint256 amount)  public onlyOwner {
        owner.transfer(amount);
    }

    function changeOwnerCandidate(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
    }

    // function for transfer any token from contract
    function transferTokens (address token, address target, uint256 amount) onlyOwner public
    {
        ERC20Token(token).universalTransfer(target, amount);
    }


    // 0 - balance ether
    // 1 - balance VMR
    // 2 - balance investor
    // 3 - rewards started (0 if still depo period)
    // 4 - effective user tokens
        // 5 - current epoch (first epoch started after delayBeforeRewardWithdrawn period) - we not need it
    // 6 - current user reward
        // 7 - pending user reward in next epoch - we not need it
    // 8 - max total VMR (when amount reached deposit - period ends)
    // 9 - current total effective VMR for all users
    // 10 - max effective VMR per each user
    // 11 - epoch duration
    // 12 - reward per epoch
    // 13 - total unique users
    function getInfo(address investor, uint256 _state) view external returns (uint256[14] memory ret)
    {
        if (_state == 0) _state = currentState;
        GlobalState storage dataState = states[_state - 1];
        
        ret[0] = address(this).balance;
        ret[1] = TokenVMR.balanceOf(address(this));
        ret[2] = dataState.investors[investor];
        ret[3] = dataState.startRewardDate > 0 ? (dataState.startRewardDate + delayBeforeRewardWithdrawn) : 0;
        ret[4] = min(ret[2], dataState.maxVMRPerUser);
        // ret[5] = startRewardDate > 0 ? (now - dataState.startRewardDate).div(delayBeforeRewardWithdrawn) : 0;
        ret[6] = dataState.rewardPerToken.wmul(ret[4]);
        // ret[7] = rewardPerToken.wmul(ret[4]);
        
        ret[8] = dataState.maxTotalVMR;
        ret[9] = dataState.totalVMR;
        ret[10] = dataState.maxVMRPerUser;
        ret[11] = delayBeforeRewardWithdrawn;
        ret[12] = dataState.rewardPerToken;
        ret[13] = dataState.totalUniqueUsers;
    }
    
    function readState(uint256 _stateNumber) view public returns(uint256[6] memory ret) {
        GlobalState storage activeState = states[_stateNumber];
        ret[0] = activeState.totalVMR; // current amount
        ret[1] = activeState.maxTotalVMR; 
        ret[2] = activeState.maxVMRPerUser;
        ret[3] = activeState.rewardPerToken;
        ret[4] = activeState.startRewardDate;
        ret[5] = activeState.totalUniqueUsers;   
    }

    function addDepositTokens(address[] calldata userAddress, uint256[] calldata amountTokens) onlyAdmin external {
        internalSetDepositTokens(userAddress, amountTokens, 1); // add mode
    }

    function setDepositTokens(address[] calldata userAddress, uint256[] calldata amountTokens) onlyAdmin external {
        internalSetDepositTokens(userAddress, amountTokens, 0); // set mode
    }

    function min(uint256 a, uint256 b) pure internal returns (uint256) {
        return (a < b) ? a : b;
    }
    // mode = 0 (set mode)
    // mode = 1 (add mode)
    function internalSetDepositTokens(address[] memory userAddress, uint256[] memory amountTokens, uint8 mode) internal {
        GlobalState storage activeState = states[currentState - 1];
        uint256 _maxTotalVMR = activeState.maxTotalVMR;
        uint256 _totalVMR = activeState.totalVMR;
        
        require(_totalVMR < _maxTotalVMR || mode == 0);

        uint256 _maxVMRPerUser = activeState.maxVMRPerUser;
        uint256 len = userAddress.length;
        require(len == amountTokens.length);        
        for(uint16 i = 0;i < len; i++) {
            uint256 currentAmount = activeState.investors[userAddress[i]];
        
            uint256 prevAmount = currentAmount;
            
            // set mode
            if (mode == 0) {
                currentAmount = amountTokens[i];
            } else {
                currentAmount = currentAmount.add(amountTokens[i]);
            }
            
            if (prevAmount == 0 && currentAmount > 0) {
                activeState.totalUniqueUsers++;
            }
            
            uint256 addedPrev = min(prevAmount, _maxVMRPerUser); 
            uint256 addedNow = min(currentAmount, _maxVMRPerUser); 
            _totalVMR = _totalVMR.sub(addedPrev).add(addedNow);
            
            activeState.investors[userAddress[i]] = currentAmount;
            emit DepositTokens(userAddress[i], prevAmount, currentAmount);
            
            if (_totalVMR >= _maxTotalVMR) {
                if (activeState.startRewardDate == 0) activeState.startRewardDate = now;
                break;
            }
        }
        
        activeState.totalVMR = _totalVMR;
    }


    function () payable external
    {
        require(msg.sender == tx.origin); // prevent bots to interact with contract

        if (msg.sender == owner) return;
        
        uint256 _currentState = currentState;
        uint256 _maxState = _currentState;
        if (_currentState > states.length) _currentState = states.length;
        // 
        while (_currentState > 0) {
            GlobalState storage activeState = states[_currentState - 1];
            
            uint256 depositedVMR = activeState.investors[msg.sender];
            if (depositedVMR > 0)
            {
                uint256 _startRewardDate = activeState.startRewardDate;
                // можно раздавать награды в периоде _currentState
                if (_startRewardDate > 0 && now > _startRewardDate + delayBeforeRewardWithdrawn)
                {
                    activeState.investors[msg.sender] = 0;
                    uint256 effectiveTokens = min(depositedVMR, activeState.maxVMRPerUser);
                    
                    uint256 reward = activeState.rewardPerToken.wmul(effectiveTokens);
                    
                    TokenVMR.universalTransfer(msg.sender, depositedVMR); // withdraw body
                    
                    if (reward > 0) {
                        ERC20Token(0xdAC17F958D2ee523a2206206994597C13D831ec7).universalTransfer(msg.sender, reward); // withdraw reward
                    }
                    if (_currentState == _maxState) {
                        currentState++;
                        emit NewPeriodStarted(currentState);
                    }
                }
            }
            _currentState--;
        }
    }
    
}