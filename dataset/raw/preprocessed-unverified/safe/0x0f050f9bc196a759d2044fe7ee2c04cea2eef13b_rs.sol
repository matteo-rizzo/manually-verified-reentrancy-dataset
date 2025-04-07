/**
 *Submitted for verification at Etherscan.io on 2021-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;



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
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Claiming is Ownable{
    
    using SafeMath for uint256;
    
    /**
     * Structure of an object to pass for allowance list
     */
    struct allowedUser {
        address wallet;
        uint256 amount;
    }

    IERC20 public token;
    bool internal isClaimOpen;
    uint256 internal totalUnclaimed;

    mapping(address => uint256) allowanceAmounts;

    constructor(IERC20 _token){
        token = _token;
        isClaimOpen = false;
        totalUnclaimed = 0;
    }

    event UnsuccessfulTransfer(address recipient);

    /**
    * Ensures that claiming tokens is currently allowed by the owner.
    */
    modifier openClaiming() {
        require(
            isClaimOpen,
            "Claiming tokens is not currently allowed."
        );
        _;
    }

    /**
    * Ensures that the amount of claimed tokens is not bigger than the user is allowed to claim.
    */
    modifier userHasEnoughClaimableTokens (uint256 amount) {
        require(
            allowanceAmounts[msg.sender] >= amount,
            "The users token amount is smaller than the requested."
        );
        _;
    }

    /**
    * Ensures that contract has enough tokens for the transaction.
    */
    modifier enoughContractAmount(uint256 amount) {
        require(
            token.balanceOf(address(this)) >= amount, 
            "Owned token amount is too small."
        );
        _;
    }
    
    /**
    * Ensures that only people from the allowance list can claim tokens.
    */
    modifier userHasClaimableTokens() {
        require(
            allowanceAmounts[msg.sender] > 0,
            "There is no tokens for the user to claim or the user is not allowed to do so."
        );
        _;
    }
    
    modifier hasContractTokens() {
        require(
            token.balanceOf(address(this)) > 0,
            "There is no tokens for the user to claim or the user is not allowed to do so."
        );
        _;
    }

    /** @dev Transfers the spacified number of tokens to the user requesting
     *
     * Substracts the requested amount of tokens from the allowance amount of the user
     * Transfers tokens from contract to the message sender
     * In case of failure restores the previous allowance amount
     *
     * Requirements:
     *
     * - message sender cannot be address(0) and has to be in AllowanceList
     */
    function claimCustomAmountTokens(uint256 amount)
        public 
        openClaiming 
        userHasEnoughClaimableTokens(amount)
        enoughContractAmount(amount)
    {
        require(msg.sender != address(0), "Sender is address zero");
        allowanceAmounts[msg.sender] = allowanceAmounts[msg.sender].sub(amount);
        token.approve(address(this), amount);
        if (!token.transferFrom(address(this), msg.sender, amount)){
            allowanceAmounts[msg.sender].add(amount);
            emit UnsuccessfulTransfer(msg.sender);
        }
        else {
            totalUnclaimed = totalUnclaimed.sub(amount);
        }
    }

    /** @dev Transfers the spacified number of tokens to the user requesting
     *
     * Makes the allowance equal to zero
     * Transfers all allowed tokens from contract to the message sender
     * In case of failure restores the previous allowance amount
     *
     * Requirements:
     *
     * - message sender cannot be address(0) and has to be in AllowanceList
     */
    function claimRemainingTokens()
        public
        openClaiming
        userHasClaimableTokens   
    {   
        
        require(msg.sender != address(0), "Sender is address zero");
        uint256 amount = allowanceAmounts[msg.sender];
        
        require(token.balanceOf(address(this)) >= amount, "Insufficient amount of tokens in contract");
        
        allowanceAmounts[msg.sender] = 0;
        token.approve(address(this), amount);
        if (!token.transferFrom(address(this), msg.sender, amount)){
            allowanceAmounts[msg.sender] = amount;
            emit UnsuccessfulTransfer(msg.sender);
        }
        else{
            totalUnclaimed = totalUnclaimed.sub(amount);
        }
    }

    /** @dev Adds the provided address to Allowance list with allowed provided amount of tokens
     * Available only for the owner of contract
     */
    function addToAllowanceListSingle(address addAddress, uint256 amount) 
        public 
        onlyOwner 
    {
        allowanceAmounts[addAddress] = allowanceAmounts[addAddress].add(amount);
        totalUnclaimed = totalUnclaimed.add(amount);
    }
    
    /** @dev Adds the provided address to Allowance list with allowed provided amount of tokens
     * Available only for the owner
     */
    function substractFromAllowanceListSingle(address subAddress, uint256 amount) 
        public 
        onlyOwner 
    {
        require(allowanceAmounts[subAddress] != 0, "The address does not have allowance to substract from.");
        allowanceAmounts[subAddress] = allowanceAmounts[subAddress].sub(amount);
        totalUnclaimed = totalUnclaimed.sub(amount);
    }


    /** @dev Adds the provided address list to Allowance list with allowed provided amounts of tokens
     * Available only for the owner
     */
    function addToAllowanceListMultiple(allowedUser[] memory addAddresses)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addAddresses.length; i++) {
            allowanceAmounts[addAddresses[i].wallet] = allowanceAmounts[addAddresses[i].wallet].add(addAddresses[i].amount);
            totalUnclaimed = totalUnclaimed.add(addAddresses[i].amount);
        }
    }
    
    /** @dev Removes the provided address from Allowance list by setting his allowed sum to zero
     * Available only for the owner of contract
     */
    function removeFromAllowanceList(address remAddress) 
        public 
        onlyOwner 
    {
        totalUnclaimed = totalUnclaimed.sub(allowanceAmounts[remAddress]);
        delete allowanceAmounts[remAddress];
    }

    /** @dev Allows the owner to turn the claiming on.
     */
    function turnClaimingOn() 
        public 
        onlyOwner
    {
        isClaimOpen = true;
    }

    /** @dev Allows the owner to turn the claiming off.
     */
    function turnClaimingOff() 
        public 
        onlyOwner
    {
        isClaimOpen = false;
    }

    /** @dev Allows the owner to withdraw all the remaining tokens from the contract
     */
    function withdrawAllTokensOwner() 
        public 
        onlyOwner
    {
        token.approve(address(this), token.balanceOf(address(this)));
        if (!token.transferFrom(address(this), msg.sender, token.balanceOf(address(this)))){
            emit UnsuccessfulTransfer(msg.sender);
        }
    }
    
    /** @dev Allows the owner to withdraw the specified amount of tokens from the contract
     */
     function withdrawCustomTokensOwner(uint256 amount) 
        public 
        onlyOwner 
        enoughContractAmount(amount)
    {
        token.approve(address(this), amount);
        if (!token.transferFrom(address(this), msg.sender, amount)){
            emit UnsuccessfulTransfer(msg.sender);
        }
    }
    
    /** @dev Allows the owner to withdraw the residual tokens from the contract
     */
     function withdrawResidualTokensOwner() 
        public 
        onlyOwner 
    {
        uint256 amount = token.balanceOf(address(this)).sub(totalUnclaimed);
        require(token.balanceOf(address(this)) >= amount, "Insufficient amount of tokens in contract");
        token.approve(address(this), amount);
        if (!token.transferFrom(address(this), msg.sender, amount)){
            emit UnsuccessfulTransfer(msg.sender);
        }
    }
    
    /** @dev Allows the owner to withdraw the specified amount of any IERC20 tokens from the contract
     */
    function withdrawAnyContractTokens(IERC20 tokenAddress, address recipient) 
        public 
        onlyOwner 
    {
        require(msg.sender != address(0), "Sender is address zero");
        require(recipient != address(0), "Receiver is address zero");
        tokenAddress.approve(address(this), tokenAddress.balanceOf(address(this)));
        if(!tokenAddress.transferFrom(address(this), recipient, tokenAddress.balanceOf(address(this)))){
            emit UnsuccessfulTransfer(msg.sender);
        }
    } 
    
    /** @dev Shows the amount of total unclaimed tokens in the contract
     */
    function totalUnclaimedTokens() 
        public 
        view 
        onlyOwner
        returns (uint256)
    {
        return totalUnclaimed;
    }
    
    /** @dev Shows the residual tokens of the user sending request
     */
    function myResidualTokens() 
        public
        view
        returns (uint256)
    {
        return allowanceAmounts[msg.sender];
    } 
    
    /** @dev Shows the owner residual tokens of any address (owner only function)
     */
    function residualTokensOf(address user) 
        public  
        view
        onlyOwner 
        returns (uint256)
    {
        return allowanceAmounts[user];
    }

    /** @dev Shows the amount of total tokens in the contract
     */
    function tokenBalance() 
        public 
        view 
        returns (uint256)
    {
        return token.balanceOf(address(this));
    }

    /** @dev Shows whether claiming is allowed right now.
     */
    function isClaimingOn() 
        public
        view 
        returns (bool)
    {
        return isClaimOpen;
    }
    
}