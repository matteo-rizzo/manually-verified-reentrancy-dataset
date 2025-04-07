/**

 *Submitted for verification at Etherscan.io on 2019-02-17

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */



contract MinterRole {

    using Roles for Roles.Role;



    event MinterAdded(address indexed account);

    event MinterRemoved(address indexed account);



    Roles.Role private minters;



    constructor() internal {

        _addMinter(msg.sender);

    }



    modifier onlyMinter() {

        require(isMinter(msg.sender));

        _;

    }



    function isMinter(address account) public view returns (bool) {

        return minters.has(account);

    }



    function addMinter(address account) public onlyMinter {

        _addMinter(account);

    }



    function renounceMinter() public {

        _removeMinter(msg.sender);

    }



    function _addMinter(address account) internal {

        minters.add(account);

        emit MinterAdded(account);

    }



    function _removeMinter(address account) internal {

        minters.remove(account);

        emit MinterRemoved(account);

    }

}



contract StandardERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) internal _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor(string name, string symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns(string) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns(string) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns(uint8) {

        return _decimals;

    }

    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(

        address owner,

        address spender

    )

    public

    view

    returns (uint256)

    {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(

        address from,

        address to,

        uint256 value

    )

    public

    returns (bool)

    {

        require(value <= _allowed[from][msg.sender]);



        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(

        address spender,

        uint256 addedValue

    )

    public

    returns (bool)

    {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(

        address spender,

        uint256 subtractedValue

    )

    public

    returns (bool)

    {

        require(spender != address(0));



        _allowed[msg.sender][spender] = (

        _allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(value <= _balances[from]);

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



}



/**

 * @title ERC20Mintable

 * @dev ERC20 minting logic

 */

contract ERC20Mintable is StandardERC20, MinterRole {



    constructor(string name, string symbol, uint8 decimals)

    public

    StandardERC20(name,symbol,decimals)

    {

    }

    /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(

        address to,

        uint256 value

    )

    public

    onlyMinter

    returns (bool)

    {

        _mint(to, value);

        return true;

    }

}



/**

 * @title Capped token

 * @dev Mintable token with a token cap.

 */

contract ERC20Capped is ERC20Mintable {



    uint256 private _cap;



    constructor(string name, string symbol, uint8 decimals,uint256 cap)

    public

    ERC20Mintable(name,symbol,decimals)

    {

        require(cap > 0);

        _cap =  cap.mul(uint(10) **decimals);

    }



    /**

     * @return the cap for the token minting.

     */

    function cap() public view returns(uint256) {

        return _cap;

    }



    function _mint(address account, uint256 value) internal {

        require(totalSupply().add(value) <= _cap);

        super._mint(account, value);

    }

}



contract FSTToken is ERC20Capped {



    constructor(string name, string symbol, uint8 decimals,uint256 cap)

    public

    ERC20Capped(name,symbol,decimals,cap)

    {



    }



}



contract FSTTokenAgentHolder is Ownable{



    using SafeMath for uint256;



    FSTToken private token ;



    uint256 public totalLockTokens;



    uint256 public totalUNLockTokens;

    uint256 public globalLockPeriod;



    uint256 public totalUnlockNum=4;

    mapping (address => HolderSchedule) public holderList;

    address[] public holderAccountList=[0x0];



    uint256 private singleNodeTime;



    event ReleaseTokens(address indexed who,uint256 value);

    event HolderToken(address indexed who,uint256 value,uint256 totalValue);



    struct HolderSchedule {

        uint256 startAt;

        uint256 lockAmount;

        uint256 releasedAmount;

        uint256 totalReleasedAmount;

        uint256 lastUnlocktime;

        bool isReleased;

        bool isInvested;

        uint256 unlockNumed;

    }



    constructor(address _tokenAddress ,uint256 _globalLockPeriod,uint256 _totalUnlockNum) public{

        token = FSTToken(_tokenAddress);

        globalLockPeriod=_globalLockPeriod;

        totalUnlockNum=_totalUnlockNum;

        singleNodeTime=globalLockPeriod.div(totalUnlockNum);

    }



    function addHolderToken(address _adr,uint256 _lockAmount) public onlyOwner {

        HolderSchedule storage holderSchedule = holderList[_adr];

        require(_lockAmount > 0);

        _lockAmount=_lockAmount.mul(uint(10) **token.decimals());

        if(holderSchedule.isInvested==false||holderSchedule.isReleased==true){

            holderSchedule.isInvested=true;

            holderSchedule.startAt = block.timestamp;

            holderSchedule.lastUnlocktime=holderSchedule.startAt;

            if(holderSchedule.isReleased==false){

                holderSchedule.releasedAmount=0;

                if(holderAccountList[0]==0x0){

                    holderAccountList[0]=_adr;

                }else{

                    holderAccountList.push(_adr);

                }

            }

        }

        holderSchedule.isReleased = false;

        holderSchedule.lockAmount=holderSchedule.lockAmount.add(_lockAmount);

        totalLockTokens=totalLockTokens.add(_lockAmount);

        emit HolderToken(_adr,_lockAmount,holderSchedule.lockAmount.add(holderSchedule.releasedAmount));

    }



    function subHolderToken(address _adr,uint256 _lockAmount)public onlyOwner{

        HolderSchedule storage holderSchedule = holderList[_adr];

        require(_lockAmount > 0);

        _lockAmount=_lockAmount.mul(uint(10) **token.decimals());

        require(holderSchedule.lockAmount>=_lockAmount);

        holderSchedule.lockAmount=holderSchedule.lockAmount.sub(_lockAmount);

        totalLockTokens=totalLockTokens.sub(_lockAmount);

        emit HolderToken(_adr,_lockAmount,holderSchedule.lockAmount.add(holderSchedule.releasedAmount));

    }



    function accessToken(address rec,uint256 value) private {

        totalUNLockTokens=totalUNLockTokens.add(value);

        token.mint(rec,value);

    }

    function releaseMyTokens() public{

        releaseTokens(msg.sender);

    }



    function releaseTokens(address _adr) public{

        require(_adr!=address(0));

        HolderSchedule storage holderSchedule = holderList[_adr];

        if(holderSchedule.isReleased==false&&holderSchedule.lockAmount>0){

            uint256 unlockAmount=lockStrategy(_adr);

            if(unlockAmount>0&&holderSchedule.lockAmount>=unlockAmount){

                holderSchedule.lockAmount=holderSchedule.lockAmount.sub(unlockAmount);

                holderSchedule.releasedAmount=holderSchedule.releasedAmount.add(unlockAmount);

                holderSchedule.totalReleasedAmount=holderSchedule.totalReleasedAmount.add(unlockAmount);

                holderSchedule.lastUnlocktime=block.timestamp;

                if(holderSchedule.lockAmount==0){

                    holderSchedule.isReleased=true;

                    holderSchedule.releasedAmount=0;

                    holderSchedule.unlockNumed=0;

                }

                accessToken(_adr,unlockAmount);

                emit ReleaseTokens(_adr,unlockAmount);

            }

        }

    }

    function releaseEachTokens() public {

        require(holderAccountList.length>0);

        for(uint i=0;i<holderAccountList.length;i++){

            HolderSchedule storage holderSchedule = holderList[holderAccountList[i]];

            if(holderSchedule.lockAmount>0&&holderSchedule.isReleased==false){

                uint256 unlockAmount=lockStrategy(holderAccountList[i]);

                if(unlockAmount>0){

                    holderSchedule.lockAmount=holderSchedule.lockAmount.sub(unlockAmount);

                    holderSchedule.releasedAmount=holderSchedule.releasedAmount.add(unlockAmount);

                    holderSchedule.totalReleasedAmount=holderSchedule.totalReleasedAmount.add(unlockAmount);

                    holderSchedule.lastUnlocktime=block.timestamp;

                    if(holderSchedule.lockAmount==0){

                        holderSchedule.isReleased=true;

                        holderSchedule.releasedAmount=0;

                        holderSchedule.unlockNumed=0;

                    }

                    accessToken(holderAccountList[i],unlockAmount);

                }

            }

        }

    }

    function lockStrategy(address _adr) private returns(uint256){

        HolderSchedule storage holderSchedule = holderList[_adr];

        uint256 interval=block.timestamp.sub(holderSchedule.startAt);

        uint256 unlockAmount=0;

        if(interval>=singleNodeTime){

            uint256 unlockNum=interval.div(singleNodeTime);

            uint256 nextUnlockNum=unlockNum.sub(holderSchedule.unlockNumed);

            if(nextUnlockNum>0){

                holderSchedule.unlockNumed=unlockNum;

                uint totalAmount=holderSchedule.lockAmount.add(holderSchedule.releasedAmount);

                uint singleAmount=totalAmount.div(totalUnlockNum);

                unlockAmount=singleAmount.mul(nextUnlockNum);

                if(unlockAmount>holderSchedule.lockAmount){

                    unlockAmount=holderSchedule.lockAmount;

                }

            }

        }

        return unlockAmount;

    }

}