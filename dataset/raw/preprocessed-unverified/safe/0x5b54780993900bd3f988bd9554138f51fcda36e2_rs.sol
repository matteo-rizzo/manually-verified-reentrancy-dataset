/**
 *Submitted for verification at Etherscan.io on 2020-09-28
*/

pragma solidity ^0.6.2;



contract Context {
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title ERC1132 interface
 * @dev see https://github.com/ethereum/EIPs/issues/1132
 */

abstract contract ERC1132 {
    /**
     * @dev Reasons why a user's tokens have been locked
     */
    mapping(address => bytes32[]) public lockReason;

    /**
     * @dev locked token structure
     */
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    /**
     * @dev Holds number & validity of tokens locked for a given reason for
     *      a specified address
     */
    mapping(address => mapping(bytes32 => lockToken)) public locked;

    /**
     * @dev Records data of all the tokens Locked
     */
    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    /**
     * @dev Records data of all the tokens unlocked
     */
    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );
    
    /**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be locked
     * @param _time Lock time in seconds
     */
    function lock(string memory _reason, uint256 _amount, uint256 _time)
        public virtual returns (bool);
  
    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     */
    function tokensLocked(address _of, string memory _reason)
        public virtual view returns (uint256 amount);
    
    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specific time
     *
     * @param _of The address whose tokens are locked
     * @param _reason The reason to query the lock tokens for
     * @param _time The timestamp to query the lock tokens for
     */
    function tokensLockedAtTime(address _of, string memory _reason, uint256 _time)
        public virtual view returns (uint256 amount);
    
    /**
     * @dev Returns total tokens held by an address (locked + transferable)
     * @param _of The address to query the total balance of
     */
    function totalBalanceOf(address _of)
        public virtual view returns (uint256 amount);
    
    /**
     * @dev Extends lock for a specified reason and time
     * @param _reason The reason to lock tokens
     * @param _time Lock extension time in seconds
     */
    function extendLock(string memory _reason, uint256 _time)
        public virtual returns (bool);
    
    /**
     * @dev Increase number of tokens locked for a specified reason
     * @param _reason The reason to lock tokens
     * @param _amount Number of tokens to be increased
     */
    function increaseLockAmount(string memory _reason, uint256 _amount)
        public virtual returns (bool);

    /**
     * @dev Returns unlockable tokens for a specified address for a specified reason
     * @param _of The address to query the the unlockable token count of
     * @param _reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address _of, string memory _reason)
        public virtual view returns (uint256 amount);
 
    /**
     * @dev Unlocks the unlockable tokens of a specified address
     * @param _of Address of user, claiming back unlockable tokens
     */
    function unlock(address _of)
        public virtual returns (uint256 unlockableTokens);

    /**
     * @dev Gets the unlockable tokens of a specified address
     * @param _of The address to query the the unlockable token count of
     */
    function getUnlockableTokens(address _of)
        public virtual view returns (uint256 unlockableTokens);

}





contract SocialRocketVesting is Ownable {

    using SafeMath for uint256;

    uint256 public startVesting;
    uint256 public durationVesting;

    mapping (address => uint256) private _released;

    SocialRocketContrat private rocks;
    address private token;
    
    string internal constant ALREADY_LOCKED = 'Tokens already locked';
    string internal constant NOT_LOCKED = 'No tokens locked';
    string internal constant AMOUNT_ZERO = 'Amount can not be 0';

     
    constructor(address socialRocketContract, uint256 duration) public {
        rocks = SocialRocketContrat(socialRocketContract);
        token = socialRocketContract;
        
        startVesting = now;

        require(duration > 0, "Vesting: duration is 0");
        require(startVesting.add(duration) > block.timestamp, "Vesting: final time is before current time");

        durationVesting = duration;
    }

    /****************
    MARKETING VESTING
    *****************/
    function released() public view returns (uint256) {
        return _released[token];
    }

    function release() public onlyOwner {
        uint256 unreleased = releasableAmount();

        require(unreleased > 0, "No tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        rocks.transfer(owner, unreleased);
    }

    function releasableAmount() public view returns (uint256) {
        return vestedAmount().sub(_released[address(token)]);
    }


    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = rocks.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp >= startVesting.add(durationVesting)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(startVesting)).div(durationVesting);
        }
    }
    
    function getRemainingVestingDays() public view returns(uint256){
        return startVesting.add(durationVesting).sub(block.timestamp).div(86400);
    }
    
    
}