/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */









/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */



 contract uniLock  {
    using Address for address;
    using SafeMath for uint;
    address factory;
    uint public locked = 0;
    uint public unlock_date = 0;
    address public owner;
    address public token;
    uint public softCap;
    uint public hardCap;
    uint public start_date;
    uint public end_date;
    uint public rate; // coin sale rate 1 ETH = 1 XYZ (rate = 1e18) <=> 1 ETH = 10 XYZ (rate = 1e19) 
    uint public min_allowed;
    uint public max_allowed; // Max ETH 
    uint public collected; // collected ETH
    uint public pool_rate; // uniswap liquidity pool rate  1 ETH = 1 XYZ (rate = 1e18) <=> 1 ETH = 10 XYZ (rate = 1e19)
    uint public lock_duration; // duration wished to keep the LP tokens locked
    uint public uniswap_rate;
    bool public doRefund = false;
    constructor() public{
        factory = msg.sender;
        
    }
   

    
    
    
    mapping(address => uint) participant;
    
    // Initilaize  a new campaign (can only be triggered by the factory contract)
    function initilaize(uint[] calldata _data,address _token,address _owner_Address,uint _pool_rate,uint _lock_duration,uint _uniswap_rate) external returns (uint){
      require(msg.sender == factory,'You are not allowed to initialize a new Campaign');
      owner = _owner_Address; 
      softCap = _data[0];
      hardCap = _data[1];
      start_date = _data[2];
      end_date = _data[3];
      rate = _data[4]; 
      min_allowed = _data[5];
      max_allowed = _data[6];
      token = _token;
      pool_rate = _pool_rate;
      lock_duration = _lock_duration;
      uniswap_rate = _uniswap_rate;
    }
    
    function buyTokens() public payable returns (uint){
        require(isLive(),'campaign is not live');
        require((msg.value>= min_allowed)&& (getGivenAmount(msg.sender).add(msg.value) <= max_allowed) && (msg.value <= getRemaining()),'The contract has insufficent funds or you are not allowed');
        participant[msg.sender] = participant[msg.sender].add(msg.value);
        collected = (collected).add(msg.value);
        return 1;
    }
    function withdrawTokens() public returns (uint){
        require(locked == 1,'liquidity is not yet added');
        require(IERC20(address(token)).transfer(msg.sender,calculateAmount(participant[msg.sender])),"can't transfer");
        participant[msg.sender] = 0;

    }
    function unlock(address _LPT,uint _amount) public returns (bool){
        require(locked == 1 || failed(),'liquidity is not yet locked');
        require(address(_LPT) != address(token),'You are not allowed to withdraw tokens');
        require(block.timestamp >= unlock_date ,"can't receive LP tokens");
        require(msg.sender == owner,'You are not the owner');
        IERC20(address(_LPT)).transfer(msg.sender,_amount);
    }
    
    // Add liquidity to uniswap and burn the remaining tokens, can be only executed when the campaign completes
    
    function uniLOCK() public returns(uint){
        require(locked ==0,'Liquidity is already locked');
        require(!isLive(),'Presale is still live');
        require(!failed(),"Presale failed , can't lock liquidity");
        require(softCap <= collected,"didn't reach soft cap");
        require(addLiquidity(),'error adding liquidity to uniswap');
        locked = 1;
        unlock_date = (block.timestamp).add(lock_duration);
        return 1;
    }
    
    function addLiquidity() internal returns(bool){
        if(IUniswapV2Factory(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f)).getPair(token,address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)) == address(0)){
        uint campaign_amount = collected.mul(uint(IUniLockFactory(factory).fee())).div(1000);
        IERC20(address(token)).approve(address(IUniLockFactory(factory).uni_router()),(hardCap.mul(rate)).div(1e18));
        if(uniswap_rate > 0){
                IUniswapV2Router02(address(IUniLockFactory(factory).uni_router())).addLiquidityETH{value : campaign_amount.mul(uniswap_rate).div(1000)}(address(token),((campaign_amount.mul(uniswap_rate).div(1000)).mul(pool_rate)).div(1e18),0,0,address(this),block.timestamp + 100000000);
        }
        payable(IUniLockFactory(factory).toFee()).transfer(collected.sub(campaign_amount));
        payable(owner).transfer(campaign_amount.sub(campaign_amount.mul(uniswap_rate).div(1000)));
        }else{
            doRefund = true;
        }
        return true;
    }
    
    // Check whether the campaign failed
    
    function failed() public view returns(bool){
        if((block.timestamp >= end_date) && (softCap > collected)){
            return true;
            
        }
        return false;
    }
    
    // Allows Participants to withdraw funds when campaign fails
    function withdrawFunds() public returns(uint){
        require(failed() || doRefund,"campaign didn't fail");
        require(participant[msg.sender] >0 ,"You didn't participate in the campaign");
        uint withdrawAmount = participant[msg.sender].mul(uint(IUniLockFactory(factory).fee())).div(1000);
        (msg.sender).transfer(withdrawAmount);
        payable(IUniLockFactory(factory).toFee()).transfer(participant[msg.sender].sub(withdrawAmount));
        participant[msg.sender] = 0;

    }
    // Checks whether the campaign is still Live
    
    function isLive() public view returns(bool){
       if((block.timestamp < start_date)) return false;
       if((block.timestamp >= end_date)) return false;
       if((collected >= hardCap)) return false;
       return true;
    }
    // Returns amount in XYZ.
    function calculateAmount(uint _amount) public view returns(uint){
        return (_amount.mul(rate)).div(1e18);
        
    }
    
    // Gets remaining ETH to reach hardCap
    function getRemaining() public view returns (uint){
        return (hardCap).sub(collected);
    }
    function getGivenAmount(address _address) public view returns (uint){
        return participant[_address];
    }
    
  
    


    
}