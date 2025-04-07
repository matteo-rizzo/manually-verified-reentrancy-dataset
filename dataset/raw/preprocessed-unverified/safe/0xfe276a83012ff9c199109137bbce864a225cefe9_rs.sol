/**
 *Submitted for verification at Etherscan.io on 2021-01-04
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-23
*/

pragma solidity ^0.6.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract zinStake {
     address burnWallet;
     constructor( ZinFinance _token,address _burnWallet) public {
      burnWallet=_burnWallet;
      token=_token;
      owner = msg.sender;
       }
     using SafeMath for uint256;
     /**
     * @notice address of contract
     */
    uint256 public percentage=2;
    mapping(address=>uint256) public rewardsGiven;
    mapping(address=>uint256) public prevReward;
    address public contractAddress=address(this);
     /**
     * @notice address of owener
     */
     address payable owner;
     /**
     * @notice total stake holders.
     */
     address[] public stakeholders;

     /**
     * @notice The stakes for each stakeholder.
     */
     mapping(address => uint256) public stakes;
      /**
     * @notice deposit_time for each user!
     */
     mapping(address => uint256) public deposit_time;

    
    ZinFinance public token;
//========Events=========
event stakezin(
        uint256 timestamp,
        address _Staker,
        uint256 token,
        string nature
    );
    event unstakeEvent(
        uint256 timestamp,
        address _Staker,
        uint256 token,
        string nature
    );
//========Modifiers========
    modifier onlyOwner(){
    require(msg.sender==owner);
    _;
    }
    modifier onlyBurnwalletowner(){
    require(msg.sender==burnWallet);
    _;
    }
//=========**============

    // ---------- STAKES ----------
    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function stakeZin(uint256 _stake)
        public
    { 
        address _Staker=msg.sender;
        require(token.balanceOf(_Staker)>=_stake,"You don't have enough Zin tokens to Stake");
        token.transferFrom(_Staker,address(this),_stake);
        if(stakes[_Staker] == 0){
         deposit_time[_Staker]=now;
         addStakeholder(_Staker);
        }
        stakes[_Staker] +=_stake;
       emit stakezin(
            block.timestamp, 
            _Staker, 
            _stake, 
            "stake"
        );
    }
     function setBurnPercentage(uint256 _percentage)public onlyOwner{
        percentage=_percentage;
    }
    //------------Add Stake holders----------
        /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }
      // ---------- STAKEHOLDERS ----------

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }
    
        /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }
    //--------Unstake zin Token
    function unStakeZin(uint256 _amount)
        public
    {   address _stakeholder=msg.sender;
        uint256 stakedZin=stakes[_stakeholder];
        require(stakedZin>=_amount,"You don't have enough Zin tokens to Unstake");
        uint256 stakingWallet=(_amount.div(100)).mul(percentage);
        uint256 unStakedZin=_amount.sub(stakingWallet);
        token.transfer(burnWallet,stakingWallet);
        token.transfer(_stakeholder,unStakedZin);
        stakes[_stakeholder]=stakedZin.sub(stakingWallet.add(unStakedZin));
        if(stakes[_stakeholder]==0){
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
        }
         emit unstakeEvent(
            block.timestamp, 
            msg.sender, 
            _amount, 
            "unstake"
        );
    }
    function sendGasFee(uint256 _amount) payable public{}
    function getGasFee(uint256 _amount)public onlyOwner{
        owner.transfer(_amount*1000000000000000000);
    }
    function getTokens(uint256 _amount)public
    onlyOwner{
        token.transfer(owner,_amount*1000000000000000000);
    }
    function destroy()
    public
    onlyOwner
    {
        require(token.transfer(owner,token.balanceOf(address(this))),"Balance is not transferring to the owner");
        selfdestruct(owner);
    }

}