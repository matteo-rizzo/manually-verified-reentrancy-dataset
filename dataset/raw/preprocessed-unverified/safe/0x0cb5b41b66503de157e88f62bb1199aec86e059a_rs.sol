/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: GPL-3.0-only











contract ESTDepositPool {
  using SafeMath for uint;
  uint256 private base = 100;
  uint256 public minimumDeposit = 1 ether / base;
  uint256 public refRatio = 10;
  uint256 public totalLockedPreETHAmount = 0;
  address public owner;
  address public preETH;
  address public estRewardAddress;
  mapping(address=>uint) public userPreETHAmount;
  mapping(address=>uint) public userInviteCount;
  
  mapping(address=>address) public userRef;
  bool public isNeedStaked = true;
  IDepositContract public DepositContract = IDepositContract(0x00000000219ab540356cBB839Cbe05303d7705Fa); // mainnet
//   IDepositContract public DepositContract = IDepositContract(0x8c5fecdC472E27Bc447696F431E425D02dd46a8c); // prymont test
   
    // Events
    event DepositReceived(address indexed from, uint256 amount, uint256 time);
    
    // Construct
    constructor ()  public {
        owner = msg.sender;
    }

   /**
    * @dev Modifier to scope access to admins
    */
    modifier onlyOwner() {
        require(owner == msg.sender, "Account is not owner");
        _;
    }

    function setAddresses(address _preEth,address _estReward) public onlyOwner {
        preETH = _preEth;
        estRewardAddress = _estReward;
    }

    function setIsNeedStaked(bool isNeed) public onlyOwner {
      isNeedStaked = isNeed;
    }

    // Accept a deposit from a user
    function deposit(address _ref) external payable {
        require(msg.sender != _ref, "The sender address is the same of referer");
        require(msg.value >= minimumDeposit, "The deposited amount is less than the minimum deposit size");
        require(estRewardAddress != address(0),"Invalid EST award contract address!");
        
        if(_ref != address(0) && userRef[msg.sender] == address(0)){
          userRef[msg.sender] = _ref;
          userInviteCount[msg.sender] = userInviteCount[msg.sender].add(1);
        }

        // Mint preETH to this contract account
        IPreETHToken(preETH).mint(msg.value, estRewardAddress);
        
        if(isNeedStaked){
          if(userPreETHAmount[userRef[msg.sender]] > 0){
            IEstReward(estRewardAddress).contractStake(msg.value,msg.sender);
            IEstReward(estRewardAddress).contractStake(msg.value.mul(refRatio).div(base), userRef[msg.sender]);
            IEstReward(estRewardAddress).userStakeFromInvite(userRef[msg.sender], msg.value.mul(refRatio).div(base));
          } else {
            IEstReward(estRewardAddress).contractStake(msg.value,msg.sender);
          }
        } else {
          if(userRef[msg.sender] != address(0)){
            IEstReward(estRewardAddress).contractStake(msg.value.div(base),msg.sender);
            IEstReward(estRewardAddress).contractStake(msg.value.mul(refRatio).div(base), userRef[msg.sender]);
            IEstReward(estRewardAddress).userStakeFromInvite(userRef[msg.sender], msg.value.mul(refRatio).div(base));
          } else {
            IEstReward(estRewardAddress).contractStake(msg.value,msg.sender);
          }
           
        }
        
        // Emit deposit received event
        emit DepositReceived(msg.sender, msg.value, now);
        // Process deposit
        processDeposit(msg.sender, msg.value);
    }
    
    function getUserInfo(address _user) external view returns(uint256 userDeposit,uint256 inviteCount){
        userDeposit = userPreETHAmount[_user];
        inviteCount = userInviteCount[_user];
    }

    function getUserPreETHBalance(address _user) public view returns(uint){
      return userPreETHAmount[_user];
    }

    function processDeposit(address _user, uint _value) private {
      // add user preETH amount
      userPreETHAmount[_user] = userPreETHAmount[_user].add(_value);
      totalLockedPreETHAmount = totalLockedPreETHAmount.add(_value);
    }

    function getUserPreETHPropotion(address _user) public view returns(uint256 totalLockedAmount,uint256 userAmount){
      totalLockedAmount = totalLockedPreETHAmount;
      userAmount = userPreETHAmount[_user];
    }
 
    
    function burnPreETH(uint256 _preETHAmount) public {
        require(_preETHAmount>0, "Invalid amount");
        // IPreETHToken(preETH).burn(_preETHAmount);
        IPreETHToken(preETH).contractBurn(_preETHAmount, msg.sender);
        userPreETHAmount[msg.sender] = userPreETHAmount[msg.sender].sub(_preETHAmount);
        msg.sender.transfer(_preETHAmount);
    }
    
    function stakeETH( 
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root) public onlyOwner{
        DepositContract.deposit{value:32 ether}(pubkey,withdrawal_credentials,signature,deposit_data_root);
    }
    
    fallback () payable external {}
    receive () payable external {}
   
   

    
}