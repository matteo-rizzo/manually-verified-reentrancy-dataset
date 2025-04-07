/**
 *Submitted for verification at Etherscan.io on 2021-07-19
*/

pragma solidity ^0.8.1;

// SPDX-License-Identifier: GPL-3.0

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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();

    event Unpause();

    bool public paused = false;


    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title ICO
 * @dev ICO is a base contract for managing a public token sale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for a public sale. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of public token sales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */

contract ICOEth is  Ownable, Pausable {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  
  struct UserDetail {
    uint256 depositAmount;
    uint256 totalRewardAmount;
    uint256 withdrawAmount;   
  }

  // The token being sold
  IERC20 public immutable token;

  // Decimals vlaue of the token
  uint256 tokenDecimals;

  // Address where funds are collected
  address payable public wallet;

  // How many token units a buyer gets per ETH/wei during ICO. The ETH price is fixed at 400$ during the ICO to guarantee the 30 % discount rate with the presale rate
  uint256 public ethRatePerToken;    //  1 DCASH Token = 0.001 ETH in wei

  // Amount of Dai raised during the ICO period
  uint256 public totalDepositAmount;

  uint256 private pendingTokenToSend;

  // Minimum purchase size of incoming ether amount
  uint256 public constant minPurchaseIco = 0.001 ether;

  // Unlock time stamp.
  uint256 public unlockTime;

  // The percent that unlocked after unlocktime. 5%
  uint256 private firstUnlockPercent = 5; 

  // The percent that unlocked weekly. 5%
  uint256 private weeklyUnlockPercent = 5; 

  // 1 week as a timestamp.
  uint256 private oneWeek = 604800;
  
  // 8 months as a timestamp.
  uint256 private oneyear = 31556926;

  // ICO start/end
  bool public ico = false;         // State of the ongoing sales ICO period

  // User deposit Dai amount
  mapping(address => UserDetail) public userDetails;

  event TokenPurchase(address indexed buyer, uint256 value, uint256 amount);
  event ClaimTokens(address indexed user, uint256 amount);
  event WithdrawETH(address indexed sender, address indexed recipient, uint256 amount);
  /**
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of reward token
   * @param _tokenDecimals The decimal of reward token
   * @param _ethRatePerToken How many token units a buy get per Dai token.
   */
  constructor(
    address payable _wallet,
    IERC20 _token, 
    uint256 _tokenDecimals,
    uint256 _ethRatePerToken
  ) {
    require(_wallet != address(0) && address(_token) != address(0));
    wallet = _wallet;
    token = _token;
    tokenDecimals = _tokenDecimals;
    ethRatePerToken = _ethRatePerToken;
    // start ico
    ico = true;
  }

  // -----------------------------------------
  // ICO external interface
  // -----------------------------------------
  receive() external payable {
    buyTokens();
  }


  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   */
  function buyTokens() internal whenNotPaused {
    require(ico, "ICO.buyTokens: ICO is already finished.");
    require(unlockTime == 0 || _getNow() < unlockTime, "ICO.buyTokens: Buy period already finished.");
    require(msg.value >= minPurchaseIco, "ICO.buyTokens: Failed the amount is not respecting the minimum deposit of ICO");

    uint256 tokenAmount = _getTokenAmount(msg.value);

    require(token.balanceOf(address(this)).sub(pendingTokenToSend) >= tokenAmount, "ICO.buyTokens: not enough token to send");

    (bool transferSuccess,) = wallet.call{value : msg.value}("");
    require(transferSuccess, "ICO.buyTokens: Failed to send deposit ether");

    totalDepositAmount = totalDepositAmount.add(msg.value);

    pendingTokenToSend = pendingTokenToSend.add(tokenAmount);

    UserDetail storage userDetail = userDetails[msg.sender];
    userDetail.depositAmount = userDetail.depositAmount.add(msg.value);
    userDetail.totalRewardAmount = userDetail.totalRewardAmount.add(tokenAmount);

    emit TokenPurchase(msg.sender, msg.value, tokenAmount);

  }

  function claimTokens() external {
    require(!ico, "ICO.claimTokens: ico is not finished yet.");

    uint256 unlocked = unlockedToken(msg.sender);
    require(unlocked > 0, "ICO.claimTokens: Nothing to claim.");

    UserDetail storage user = userDetails[msg.sender];

    user.withdrawAmount = user.withdrawAmount.add(unlocked);
    pendingTokenToSend = pendingTokenToSend.sub(unlocked);

    token.transfer(msg.sender, unlocked);

    emit ClaimTokens(msg.sender, unlocked);
  }

  /* ADMINISTRATIVE FUNCTIONS */

  // Update the ETH ICO rate in wei
  function updateEthRatePerToken(uint256 _ethRatePerToken) external onlyOwner {
    ethRatePerToken = _ethRatePerToken;
  }

 // start/close Ico
  function setIco(bool status) external onlyOwner {
    ico = status;
  }

  // Update the ETH ICO rate
  function updateUnlockTime(uint256 _unlockTime) external onlyOwner {
    require(_unlockTime >= _getNow(), "ICO.updateUnlockTime: Can't set prev time as a unlock time");
    unlockTime = _unlockTime;
  }

  // Withdraw Eth amount in the contract
  function withdrawEth() external onlyOwner {
    uint256 ethBalance = address(this).balance;
    (bool transferSuccess,) = wallet.call{value : ethBalance}("");
    require(transferSuccess, "ICO.withdrawEth: Failed to send ether");
    emit WithdrawETH(address(this), wallet, ethBalance);
  }
  // -----------------------------------------
  // View functions
  // -----------------------------------------

   function unlockedToken(address _user) public view returns (uint256) {
      UserDetail storage user = userDetails[_user];
      uint256 unlocked;
      if(unlockTime == 0) {
          return 0;
      }
      else if (_getNow() < unlockTime) {
          return 0;
      }
      else {
          uint256 timePassed = _getNow().sub(unlockTime);
          if (timePassed < oneyear) {
            unlocked = user.totalRewardAmount.mul(firstUnlockPercent).div(100);
          }
          else {
            timePassed = timePassed.sub(oneyear);
            uint256 weekPassed = timePassed.div(oneWeek);
            
            if(weekPassed >= 20){
                unlocked = user.totalRewardAmount;
            } else {
                uint256 unlockedPercent = (weeklyUnlockPercent.mul(weekPassed)).add(firstUnlockPercent);
                unlocked = user.totalRewardAmount.mul(unlockedPercent).div(100);
            }
            
          }
          return unlocked.sub(user.withdrawAmount);
          
      }
  }

  // Calcul the amount of token the benifiaciary will get by buying during Sale
  function _getTokenAmount(uint256 _ethAmount) internal view returns (uint256) {
    uint256 _amountToSend = _ethAmount.mul(10 ** tokenDecimals).div(ethRatePerToken);
    return _amountToSend;
  }

  function _getNow() public virtual view returns (uint256) {
      return block.timestamp;
  }

}