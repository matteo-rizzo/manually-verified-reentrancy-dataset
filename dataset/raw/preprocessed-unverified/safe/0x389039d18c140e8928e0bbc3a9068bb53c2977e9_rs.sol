/**
 *Submitted for verification at Etherscan.io on 2021-05-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/* @dev Interface of the ERC20 standard as defined in the EIP. */


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /* @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    /* @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /* @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /* @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /* @dev Transfers ownership of the contract to a new account (newOwner).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Bullstake is Ownable {
    IERC20 public token;
    uint256 public totalAmountStaked;
    uint256 public rewardpool;
    uint public minimumStakeValue;
    uint public communityReward;

    mapping(address => Stake) public staking;
    
    struct Stake {
        address user;
        uint256 amount;
        uint256 timestamp;
    }
    
    
    constructor(IERC20 _token){
        token = _token;
        minimumStakeValue = 10000 ether;
    }
    
    function tranferCommunityToken() external onlyOwner {
        communityReward = 1000000 ether;
        token.transferFrom(msg.sender,address(this),communityReward);
    }
    
   function stake(uint256 amount) external {
        require(staking[msg.sender].amount == 0, "You have already staked");
        require(amount >= minimumStakeValue, "Minimum Stake is 10,000 BULL");
         
        uint256 tax = (amount * 5) / 100;
        uint256 finalamount = amount - tax;
        rewardpool = rewardpool + tax;
        totalAmountStaked = totalAmountStaked + finalamount;
        
        token.transferFrom(msg.sender,address(this),amount);
        staking[msg.sender] = Stake(msg.sender,finalamount, block.timestamp);
        
    }
    

    function withdrawStake() external {
        require(staking[msg.sender].amount > 0, "No active stake");
        uint256 amountStaked = staking[msg.sender].amount;
        staking[msg.sender].amount = 0;
        
        uint256 tax = (amountStaked * 10) / 100;
        
        uint256 _reward = distributeReward(amountStaked);
        uint256 _finalAmount = amountStaked + _reward - tax;
        rewardpool = rewardpool+ tax;
        
        totalAmountStaked = totalAmountStaked - amountStaked;
        token.transfer(msg.sender,_finalAmount);
    }
    
    function distributeReward(uint256 amountStaked) private returns (uint256) {
        uint256 dreward = (rewardpool * 10) / 100;
        
        rewardpool = rewardpool - dreward;
    
        if(communityReward >= dreward) {
            communityReward = communityReward - dreward;
            dreward = dreward * 2;
        } else {
             dreward += communityReward;
             communityReward = 0;
        }
        
        uint256 _reward = (amountStaked * dreward) / totalAmountStaked;
        return _reward;
    
    }
    
}