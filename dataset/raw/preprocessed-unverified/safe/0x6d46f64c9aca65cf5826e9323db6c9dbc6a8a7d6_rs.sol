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

    ERC20Token constant TokenVMR =  ERC20Token(0x063b98a414EAA1D4a5D4fC235a22db1427199024); 

    address payable public owner;
    address payable public newOwnerCandidate;

    // tokens amount
    struct UserData {
        uint128 totalVMR;
        uint128 totalReward;
    }
    mapping (address => uint256) investors;
    
    uint256 public totalVMR; // current amount
    
    uint256 public maxTotalVMR; // 50
    uint256 public maxVMRPerUser; // 3 * 1e18
    uint256 public delayBeforeRewardWithdrawn;// 30 days
    
    // reward per token for 30 days
    uint256 public rewardPerToken;
    uint256 public startRewardDate;
    uint256 public totalUniqueUsers;

    mapping(address => bool) public admins;

    event DepositTokens(address indexed userAddress, uint256 prevAmount, uint256 newAmount);

    modifier onlyOwner()
    {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyAdmin()
    {
        assert(admins[msg.sender]);
        _;
    }

    function initialize() initializer public {
        owner = 0xBeEF483F3dbBa7FC428ebe37060e5b9561219E3d;
        maxTotalVMR = 50 * 1e18;
        maxVMRPerUser = 3 * 1e18;
        delayBeforeRewardWithdrawn = 30 days;
        rewardPerToken = 170357751277683; // 0.1$ per 30 days with 587$/ETH
        
    }

    function changeMaxTotalVMRInWei(uint256 _newValue) public onlyOwner {
        maxTotalVMR = _newValue;
    }
    
    function changeMaxVMRPerUserInWei(uint256 _newValue, address[] memory addressesRecalc) public onlyOwner {
        uint256 len = addressesRecalc.length;
        uint256 _maxVMRPerUser = maxVMRPerUser;
        uint256 _totalVMR = totalVMR;
        for(uint16 i = 0;i < len; i++) {
            uint256 currentAmount = investors[addressesRecalc[i]];
            uint256 addedPrev = min(currentAmount, _maxVMRPerUser); 
            uint256 addedNow = min(currentAmount, _newValue); 
            _totalVMR = _totalVMR.sub(addedPrev).add(addedNow);
        }
        totalVMR = _totalVMR;
        maxVMRPerUser = _newValue;
    }
    
    function changeDelayBeforeRewardWithdrawnInSeconds(uint256 _newValue) public onlyOwner {
        delayBeforeRewardWithdrawn = _newValue;
    }
    
    function changeRewardPerTokenInWei(uint256 _newValue) public onlyOwner {
        rewardPerToken = _newValue;
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
    // 5 - current epoch (first epoch started after delayBeforeRewardWithdrawn period)
    // 6 - current user reward
    // 7 - pending user reward in next epoch
    // 8 - max total VMR (when amount reached deposit - period ends)
    // 9 - current total effective VMR for all users
    // 10 - max effective VMR per each user
    // 11 - epoch duration
    // 12 - reward per epoch
    // 13 - total unique users
    function getInfo(address investor) view external returns (uint256[14] memory ret)
    {
        ret[0] = address(this).balance;
        ret[1] = TokenVMR.balanceOf(address(this));
        ret[2] = investors[investor];
        ret[3] = startRewardDate > 0 ? (startRewardDate + delayBeforeRewardWithdrawn) : 0;
        ret[4] = min(ret[2], maxVMRPerUser);
        ret[5] = startRewardDate > 0 ? (now - startRewardDate).div(delayBeforeRewardWithdrawn) : 0;
        ret[6] = rewardPerToken.wmul(ret[4]).mul(ret[5]);
        ret[7] = rewardPerToken.wmul(ret[4]);
        
        ret[8] = maxTotalVMR;
        ret[9] = totalVMR;
        ret[10] = maxVMRPerUser;
        ret[11] = delayBeforeRewardWithdrawn;
        ret[12] = rewardPerToken;
        ret[13] = totalUniqueUsers;
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
        uint256 _maxTotalVMR = maxTotalVMR;
        uint256 _totalVMR = totalVMR;
        
        require(_totalVMR < _maxTotalVMR || mode == 0);

        uint256 _maxVMRPerUser = maxVMRPerUser;
        uint256 len = userAddress.length;
        require(len == amountTokens.length);        
        for(uint16 i = 0;i < len; i++) {
            uint256 currentAmount = investors[userAddress[i]];
        
            uint256 prevAmount = currentAmount;
            
            // set mode
            if (mode == 0) {
                currentAmount = amountTokens[i];
            } else {
                currentAmount = currentAmount.add(amountTokens[i]);
            }
            
            if (prevAmount == 0 && currentAmount > 0) {
                totalUniqueUsers++;
            }
            
            uint256 addedPrev = min(prevAmount, _maxVMRPerUser); 
            uint256 addedNow = min(currentAmount, _maxVMRPerUser); 
            _totalVMR = _totalVMR.sub(addedPrev).add(addedNow);
            
            investors[userAddress[i]] = currentAmount;
            emit DepositTokens(userAddress[i], prevAmount, currentAmount);
            
            if (_totalVMR >= _maxTotalVMR) {
                if (startRewardDate == 0) startRewardDate = now;
                break;
            }
        }
        
        totalVMR = _totalVMR;
    }


    function () payable external
    {
        require(msg.sender == tx.origin); // prevent bots to interact with contract

        if (msg.sender == owner) return;
        
        uint256 _startRewardDate = startRewardDate;
        
        require(_startRewardDate > 0);
        
        uint256 epoch = (now - _startRewardDate).div(delayBeforeRewardWithdrawn);
        
        require(epoch > 0);
        
        uint256 depositedVMR = investors[msg.sender];
        investors[msg.sender] = 0;
        uint256 effectiveTokens = min(depositedVMR, maxVMRPerUser);
        
        uint256 reward = rewardPerToken.wmul(effectiveTokens).mul(epoch);
        
        if (depositedVMR > 0) TokenVMR.universalTransfer(msg.sender, depositedVMR); // withdraw body
        if (reward > 0) address(uint160(msg.sender)).transfer(reward); // withdraw reward
    }
    
}