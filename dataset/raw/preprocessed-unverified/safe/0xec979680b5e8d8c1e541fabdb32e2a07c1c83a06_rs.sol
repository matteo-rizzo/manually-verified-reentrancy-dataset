/**
 *Submitted for verification at Etherscan.io on 2021-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */











/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */







// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */










/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
abstract contract Ownable is Context {
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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev A token staking contract that will allow a beneficiary to get a reward in tokens
 *
 */
contract StakingContract is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;
    
    // ERC20 basic token contract being held
    IERC20 immutable private _token;
    
    // Staking variables, amount and days needed
    uint public rewardInterest = 14;                // Percentage 14%
    uint public rewardPeriod = 31536000;            // Number of seconds needed to get the whole percentage = 1 Year
    uint public MIN_ALLOWED_AMOUNT = 10000;        // Minumum number of tokens to stake
    bool public closed;                             // is the staking closed? 
    address[] public StakeHoldersList;              // List of all stakeholders
    
    // Struct for tracking stakeholders
    struct stakeHolder {
        uint joinDate;
        uint stake;
    }
    
    // Stakeholders
    mapping (address => stakeHolder) public StakeHolders;
    
    // Amount of actually staked tokens
    uint public stakedTokens;
    // Total amount of tokens rewarded
    uint public rewardedTokens;


    /*** MODIFIERS *******************************************************************************/
    
    /**
        @dev    Checks if the msg.sender is staking tokens
     */
    modifier isStakeHolder() {
        require(StakeHolders[msg.sender].stake != 0);
        _;
    }

    /*** EVENTS **********************************************************************************/

    event Staked(address _address, uint _amount);
    event Withdrawed(address _address, uint _amount);
    event StakingisClosed(bool _closed);
    event CleanedUp(address _recipient, uint _amount);
    

    /*** CONSTRUCTOR *****************************************************************************/
    
    constructor(address _tokenAddress) {
        _token = IERC20(_tokenAddress);
        stakedTokens = 0;
        rewardedTokens = 0;
        closed = false;
    }
    
    /*** METHODS *********************************************************************************/


    /**
        Stake tokens
        @notice     conditions are:
        @notice         - staking must be open
        @notice         - must be stakeholder
        @notice         - must stake at least MIN_ALLOWED_AMOUNT tokens
        @notice         - can't stake more than he owns
        @notice         - transfer must be successful
     */
    function stake(uint _amount) external  {
        // if closed cannot accept new stakes 
        require( ! closed, "Sorry, staking is closed");
        // One address can stake only once
        require(StakeHolders[msg.sender].stake == 0, "Already Staking");
        // Do we have anought tokens ?
        require(_amount >= MIN_ALLOWED_AMOUNT);
        require(_token.balanceOf(msg.sender) >= _amount);

        // Get user tokens (must be allowed first)
        require(_token.transferFrom(msg.sender,address(this),_amount));

        // Update internal counters
        StakeHolders[msg.sender].stake = _amount;
        StakeHoldersList.push(msg.sender);
        // solhint-disable-next-line not-rely-on-time
        StakeHolders[msg.sender].joinDate = block.timestamp;
        stakedTokens = stakedTokens.add(_amount);
        emit Staked(msg.sender, _amount);      
    }
    

    /**
        Withdraw stake
        gets back the staked tokens and the matured interests if any
        If staking is closed will not get interests

        @notice     Only stakeholders can call this
     */
    function withdraw() isStakeHolder external {
        // How much to send back?
        // A closed staking allow only to get stake back
        // A non-closed staking state adds matured interest
        uint _toSend  = StakeHolders[msg.sender].stake;
        uint _interest = 0;
        if (closed == false) {
            _interest = getInterest();
            _toSend   = _toSend.add(_interest);
        }

        // Do we have anoughgt tokens in the contract?
        require(_token.balanceOf(address(this)) >= _toSend, "Not enough tokens on the contract");

        // Update internal counters
        stakedTokens = stakedTokens.sub(StakeHolders[msg.sender].stake);
        rewardedTokens = rewardedTokens.add(_interest);

        // Give tokens to the staker
        returnTokens(msg.sender,_toSend);      
    }
    

    /**
        Forcefully return funds to a stakeholder
     */
    function returnTokens(address _hodler, uint _toSend) internal {
        // Give tokens to the staker
        require(_token.transfer(_hodler,_toSend));
        // Update internal counters
        StakeHolders[_hodler].stake = 0;
        StakeHolders[_hodler].joinDate = 0;
        emit Withdrawed(_hodler, _toSend);   
    }

    /**
        @dev    Internal function to compute the interests matured
     */
    function getInterest() isStakeHolder public view returns (uint) {
        uint _stake = StakeHolders[msg.sender].stake;
        uint _time = StakeHolders[msg.sender].joinDate;
        uint _now = block.timestamp;
        uint _diff = _now.sub(_time);

        uint numerator = _stake.mul(_diff).mul(rewardInterest);
        uint denominator = rewardPeriod.mul(100);
        
        uint _interest = numerator.div(denominator);
        return _interest;
    }


    /**
        Sets the staking as closed. In a closed state:
        - won't accept new stakes
        - those who staked can only get back theyr stake without interest
    
        @notice    Only owner can set the staking closed/open
     */
     
    function openStaking() public onlyOwner { 
        closed = false;
        emit StakingisClosed (false);
    }

    function closeStaking() public onlyOwner {
        // Set the staking as open/closed
        closed = true;

        uint hodlers = StakeHoldersList.length;
        for (uint i=0; i<hodlers; i++) {
            if (StakeHolders[StakeHoldersList[i]].stake > 0) {
                stakedTokens = stakedTokens.sub(StakeHolders[StakeHoldersList[i]].stake);
                returnTokens(StakeHoldersList[i], StakeHolders[StakeHoldersList[i]].stake);
            }
        }

        // Get back remaining tokens
        cleanUpRemainings();
        emit StakingisClosed (true);
    }


    /**
        Once the staking is closed and all stakeholders withdrawed their
        stakes, allow owner to get back all remaining tokens handled by 
        the staking contract

        @notice     staking must be closed
        @notice     stakedTokens must be zero
     */    
    function cleanUpRemainings() internal onlyOwner {
        // Staking must be closed first
        require (closed, "Contract is not closed");
        // Owner can cleanup only last
        require (stakedTokens == 0, "Someone still has his token in stake");

        // Send all remaining tokens to owner = msg.sender
        uint remainings = _token.balanceOf(address(this));
        require(_token.transfer(msg.sender,remainings));

        emit CleanedUp(msg.sender, remainings);
    }
}