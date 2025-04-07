/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

pragma solidity ^0.5.16;

/**
  *  @title ArtDeco Finance
  *
  *  @notice OPEN system for Initial early-user swap ETH for ArtDeco token
  * 
  *  Another ARTD-ETH will be first pair for liquidity provide
  * 
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
    constructor () internal {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

/**
 * @dev Collection of functions related to the address type
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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract OpenSwap is Pausable,Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct condition {
        uint256 rate;           //rate of per eth
        uint256 limitFund;      //ETH limit of each address 
        uint256 startTime;      //the stage start time
        uint256 maxSwapAmount;  //the stage max allow swap amount
    }

    uint8 public constant _whiteListStage4 = 4;
    uint8 public constant _whiteListStage5 = 5;
    
    /// All deposited ETH will be instantly forwarded to
    address payable public _teamWallet = 0x3b2b4f84cFE480289df651bE153c147fa417Fb8A;
    
    /// IERC20 compilant token contact instance
    IERC20 public _artd = IERC20(0xA23F8462d90dbc60a06B9226206bFACdEAD2A26F);

    /// tags show address can join in OPEN SWAP
    mapping (uint8 =>  mapping (address => bool)) public _fullWhiteList;

    //the round records map
    mapping (uint8 => condition) public _roundRecord;

    //the user get fund per round
    mapping (uint8 =>  mapping (address => uint256) ) public _roundFund;


    //the round had swap amount
    mapping (uint8 => uint256) public _roundSwapAmount;
    
    /*
     * EVENTS
     */
    event NewSwap(address indexed destAddress, uint256 ethCost, uint256 gotTokens);
    event TeamWallet(address wallet);


    /// @dev valid the address
    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }


    constructor()
        public
    {
        pause();

        setSwapRound(1,2000 ,5 *1e18, now,           200000*1e18);
        setSwapRound(2,1000 ,5 *1e18, now + 7 days,  400000*1e18);
        setSwapRound(3,550  ,5 *1e18, now + 7 days,  600000*1e18);
        setSwapRound(4,1200 ,5 *1e18, now + 14 days, 100000*1e18);
        setSwapRound(5,1400 ,2 *1e18, now + 14 days, 100000*1e18);
    }


    /**
    * @dev for set team wallet
    */
    function setTeamWallet(address payable wallet) public 
        onlyOwner 
    {
        require(wallet != address(0x0));

        _teamWallet = wallet;

        emit TeamWallet(wallet);
    }

    /// @dev set the swap for every round;
    function setSwapRound(
    uint8 stage,
    uint256 rate,
    uint256 limitFund,
    uint256 startTime,
    uint256 maxSwapAmount )
        internal
        onlyOwner
    {
        _roundRecord[stage].rate = rate;
        _roundRecord[stage].limitFund =limitFund;
        _roundRecord[stage].startTime= startTime;
        _roundRecord[stage].maxSwapAmount=maxSwapAmount;
    }

    /// @dev set the swap start time for every stage;
    function setStartTime(uint8 stage,uint256 startTime )
        public
        onlyOwner
    {
        _roundRecord[stage].startTime = startTime;
    }

    function setmaxSwapAmount(uint8 stage,uint256 maxSwapAmount )
        public
        onlyOwner
    {
        _roundRecord[stage].maxSwapAmount = maxSwapAmount;
    }
    
    /// @dev batch set quota for user admin
    /// if openTag <=0, removed 
    function setWhiteList(uint8 stage, address[] calldata users, bool openTag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            _fullWhiteList[stage][users[i]] = openTag;
        }
    }

    /// @dev batch set quota for early user quota
    /// if openTag <=0, removed 
    function addWhiteList(uint8 stage, address user, bool openTag)
        external
        onlyOwner
    {
        _fullWhiteList[stage][user] = openTag;
    }

    /**
     * @dev If anybody sends Ether directly to this  contract, consider he is getting token
     */
    function () external payable {
        swapToken(msg.sender);
    }


    function getStage() view public returns(uint8) {

        for(uint8 i=1; i<=5; i++){
            uint256 startTime = _roundRecord[i].startTime;
            if(now >= startTime && _roundSwapAmount[i] < _roundRecord[i].maxSwapAmount ){
                return i;
            }
        }

        return 0;
    }

    function conditionCheck( address addr ) view internal  returns(uint8) {
    
        uint8 stage = getStage();
        require(stage!=0,"stage not begin");
        
        uint256 fund = _roundFund[stage][addr];
        require(fund < _roundRecord[stage].limitFund,"stage fund is full ");

        return stage;
    }

    /// @dev Exchange msg.value ether to token for account recepient
    /// @param receipient tokens receiver
    function swapToken(address receipient) 
        internal 
        whenNotPaused  
        validAddress(receipient)
        returns (bool) 
    {
        
        // Prevent contracts play
        require(tx.gasprice <= 1000000000000 wei);

        uint8 stage = conditionCheck(receipient);
        if(stage==_whiteListStage4 || stage==_whiteListStage5 ){  
            require(_fullWhiteList[stage][receipient],"your are not in the whitelist ");
        }

        doSwap(receipient, stage);

        return true;
    }


    function doSwap(address receipient, uint8 stage) internal {
        
        // protect partner quota in round each
        uint256 value = msg.value;
        uint256 fund = _roundFund[stage][receipient];
        fund = fund.add(value);
        if (fund > _roundRecord[stage].limitFund ) {
            uint256 refund = fund.sub(_roundRecord[stage].limitFund);
            value = value.sub(refund);
            msg.sender.transfer(refund);
        }
        
        uint256 soldAmount = _roundSwapAmount[stage];
        uint256 tokenAvailable = _roundRecord[stage].maxSwapAmount.sub(soldAmount);
        require(tokenAvailable > 0);

        uint256 costValue = 0;
        uint256 getTokens = 0;

        // all records has checked in the caller functions
        uint256 rate = _roundRecord[stage].rate;
        getTokens = rate * value;
        if (tokenAvailable >= getTokens) {
            costValue = value;
        } else {
            costValue = tokenAvailable.div(rate);
            getTokens = tokenAvailable;
        }

        if (costValue > 0) {
        
            _roundSwapAmount[stage] = _roundSwapAmount[stage].add(getTokens);
            _roundFund[stage][receipient]=_roundFund[stage][receipient].add(costValue);

            _artd.mint(msg.sender, getTokens);   

            emit NewSwap(receipient, costValue, getTokens);             
        }

        // not enough token swap, just return ETH
        uint256 toReturn = value.sub(costValue);
        if (toReturn > 0) {
            msg.sender.transfer(toReturn);
        }

    }

    // get ETH to add liquidity in opening SWAP platform
    function seizeEth() external  {
        uint256 _currentBalance =  address(this).balance;
        _teamWallet.transfer(_currentBalance);
    }
    
}