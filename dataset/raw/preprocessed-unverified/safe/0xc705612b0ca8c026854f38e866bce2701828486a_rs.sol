/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

pragma solidity 0.5.12;

/**
 * @title SafeMath 
 * @dev Unsigned math operations with safety checks that revert on error.
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


/**
 * @title ERC20 interface
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


contract PairFeeDistribution is Ownable{
    using SafeMath for uint256;
    
    struct PairInfo {
        uint256 totalfee;
        uint256 unclaimedfee;
        uint256 accpreshare;
    }
 
    struct UserInfo {
        uint256 claimedfee;
        uint256 rewardDebt;
    }

    address public factoryContract;
    address[] public pairs;
    address[] public users;
    mapping(address => PairInfo) public pairInfo;

    mapping(address =>mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public userStatus;
    mapping(address => uint256) public userIndex;
    uint256 public pairUpdateIdx;
    mapping(address => uint256) public withdrawIdx;
    event AddInvestors(address user, bool update);
    event RemoveInvestors(address user);
    event UpdateInvestorPairPerShare(uint256 times);
    event Withdrawfee(address pair, address account, uint256 amount);
    event SetFactory(address preFactory, address newFactory);

    function setFactory(address _factoryContract) public onlyOwner returns(bool) {
        require(_factoryContract != address(0) , "The _factoryContract address cannot be zero address");
        require(_factoryContract != factoryContract , "Repeated _factoryContract address");
        emit SetFactory(factoryContract, _factoryContract);
        factoryContract = _factoryContract;
        return true;
    }

    modifier olnyFactory() {
        require(msg.sender == factoryContract, "Caller is not the factoryContract");
        _;
    }

    function addpair(address pair) public olnyFactory {
        pairs.push(pair);
    }

    function addInvestors(address user, bool update) public onlyOwner returns(uint256){
        require(user != address(0), "Investor address cannot be zero address");
        require(!userStatus[user],"The user already exist");
        require(pairUpdateIdx == 0);
        uint256 length = pairs.length;
        if (update) {
            updateInvestorPairPerShare(length);
        }
        for (uint256 i = 0; i < length; i++) {
             userInfo[user][pairs[i]].rewardDebt = pairInfo[pairs[i]].accpreshare.div(10000);
        }
        userStatus[user] = true;
        users.push(user);
        userIndex[user] = users.length.sub(1);
        emit AddInvestors(user, update);
        return users.length;
    }

    function removeInvestors(address user) public onlyOwner returns (uint256){
        require(userStatus[user],"The user doesn't exist");
        userStatus[user] = false;
        userIndex[users[users.length.sub(1)]] = userIndex[user];
        users[userIndex[user]] = users[users.length.sub(1)];
        users.length--;
        emit RemoveInvestors(user);
        return users.length;
    }

    function updateInvestorPairPerShare(uint256 number) public onlyOwner {
        uint256 userLength = users.length;
        uint256 pairLength = pairs.length;
        uint256 processCount;
        uint256 index = pairUpdateIdx;
        processCount = pairLength.sub(pairUpdateIdx) <= number ? pairLength.sub(pairUpdateIdx) : number;
        for (uint256 i = pairUpdateIdx; i < processCount.add(pairUpdateIdx); i++) {
            uint256 amount = IERC20(pairs[i]).balanceOf(address(this)).sub(pairInfo[pairs[i]].unclaimedfee);
            if (amount > 0) {
                pairInfo[pairs[i]].unclaimedfee = pairInfo[pairs[i]].unclaimedfee.add(amount);
                pairInfo[pairs[i]].totalfee = pairInfo[pairs[i]].totalfee.add(amount);
                pairInfo[pairs[i]].accpreshare = pairInfo[pairs[i]].accpreshare.add(amount.mul(10000).div(userLength));
            }
            index += 1;
            if (index == pairLength) {
                index = 0;
                break;
            }  
        }
        pairUpdateIdx = index;
        emit UpdateInvestorPairPerShare(processCount);
    }
    
    function withdrawfee(address paird, address account) public {
        require(userStatus[msg.sender],"The caller doesn't exist");
        PairInfo storage pair = pairInfo[paird];
        UserInfo storage user = userInfo[msg.sender][paird];
        uint256 amount = pair.accpreshare.div(10000).sub(user.rewardDebt);
        if (amount >0) {
            IERC20(paird).transfer(account,amount);
            pair.unclaimedfee = pair.unclaimedfee.sub(amount);
            user.rewardDebt = pair.accpreshare.div(10000);
            user.claimedfee = user.claimedfee.add(amount);
        }
        emit Withdrawfee(paird, account, amount);
    }

    function batchwithdrawfee(address account, uint256 number) public {
        require(userStatus[msg.sender],"The caller doesn't exist");
        uint256 pairLength = pairs.length;
        uint256 index = withdrawIdx[account];
        uint256 processCount = pairLength.sub(index) <= number ? pairLength.sub(index) : number;
        for (uint256 i = withdrawIdx[account]; i < processCount.add(withdrawIdx[account]); i++) {
            uint256 amount = pairInfo[pairs[i]].accpreshare.div(10000).sub(userInfo[msg.sender][pairs[i]].rewardDebt);
            if (amount >0) {
                IERC20(pairs[i]).transfer(account,amount);
                pairInfo[pairs[i]].unclaimedfee = pairInfo[pairs[i]].unclaimedfee.sub(amount);
                userInfo[msg.sender][pairs[i]].rewardDebt = pairInfo[pairs[i]].accpreshare.div(10000);
                userInfo[msg.sender][pairs[i]].claimedfee = userInfo[msg.sender][pairs[i]].claimedfee.add(amount);
                emit Withdrawfee(pairs[i], account, amount);
            }
            index += 1;
            if (index == pairLength) {
                index = 0;
                break;
            }
        }
        withdrawIdx[account] = index;
    }

    function getpendingfee(address account,  address paird) public view returns(uint256){
        PairInfo storage pair = pairInfo[paird];
        UserInfo storage user = userInfo[account][paird];
        uint256 amount = pair.accpreshare.div(10000).sub(user.rewardDebt);
        if (!userStatus[account]){
            return 0;
        }else{
            return amount;
        }
        
    }

    function getpairlength() public view returns(uint256){
        return pairs.length;
    }
         
}