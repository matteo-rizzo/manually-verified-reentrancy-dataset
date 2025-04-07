/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

pragma solidity ^0.5.0;

/*  ____________________________________________________________________

    1. Notify Reward and send to staking : 90% of this reward deposits  
    2. Total Rewards    : 90% of this contract balance                  
    3. Notifier Rewards : 10 % of this contract balance                 
    ____________________________________________________________________
    
    -Codezeros Developers
    -https://www.codezeros.com/
    ____________________________________________________________________

*/





contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}









contract RewardCollector is Ownable, Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    Staking stakingInstance;

    uint256 notifierFee;
    uint256 notifyAmount;


    IERC20 public APE ;

    constructor(address _presale, address _staking) public {
        
        APE = IERC20(_presale);
        stakingInstance = Staking(_staking);


    }

    function rewardDeposits() public view returns (uint256) {
        return APE.balanceOf(address(this));
    }

    function balanceOf(address account) public view returns (uint256) {
        return APE.balanceOf(account);
    }

    function calculateTenPercent(uint256 amount)
        public
        pure
        returns (uint256)
    {
        return amount.mul(100).div(1000);
    }

    function calculateNinetyPercent(uint256 amount)
        public
        pure
        returns (uint256)
    {
        return amount.mul(900).div(1000);
    }

    function notifyRewardAmount() public returns (bool) {
        return stakingInstance.notifyRewardAmount();
    }

    function notifyExternal() public returns (bool) {

        notifyRewardAmount();
        notifierFee = calculateTenPercent(rewardDeposits());       //-----| Notifier Reward |------------
        notifyAmount = calculateNinetyPercent(rewardDeposits());   //-----| For Notify Purpose |---------

        APE.safeTransfer(msg.sender, notifierFee);                 //-----| Send notifier reward |-------
        APE.safeTransfer(address(stakingInstance), notifyAmount);           //-----| Send to staking contract|-----


        return true;

    }
}