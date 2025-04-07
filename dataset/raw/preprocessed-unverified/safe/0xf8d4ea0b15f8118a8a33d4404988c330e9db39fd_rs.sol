/**

 *Submitted for verification at Etherscan.io on 2019-06-13

*/



pragma solidity 0.5.3;















contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



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

    function allowance(address owner, address spender) public view returns (uint256) {

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

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

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



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

        emit Approval(account, msg.sender, _allowed[account][msg.sender]);

    }

}



contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



contract Documentable is Ownable {

  address private _provenanceDocuments;

  bytes32 public assetHash;



  constructor (address documentsContract) public Ownable() {

    _provenanceDocuments = documentsContract;

  }



  function getProvenanceDocuments() public view returns(address) {

    return _provenanceDocuments;

  }



  function setAssetHash(bytes32 _newHash) public onlyOwner {

    require(assetHash == 0x0, "Asset Hash can only be set once");

    assetHash = _newHash;

  }

}



contract Migratable is ERC20, Ownable{

  address private _new;

  mapping (address => bool) private _old;



  event NewVersionChanges(address old, address new_);

  

  event OldVersionAdded(address old);

  event OldVersionRemoved(address old);

  

  event Migrated(address account, uint256 balance);



  modifier onlyOldVersion(){

    require(msg.sender != address(0x0), "Invalid caller");

    require(_old[msg.sender], "Only callable by old version");

    _;

  }



  modifier onlyIfNewVersionIsDefined(){

    require(_new != address(0x0), "Unknow new version");

    _;

  }



  function appendOldVersion(address old) public onlyOwner{

    require(_old[old] == false, "Know old version");

    _old[old] = true;

    emit OldVersionAdded(old);

  }



  function appendOldVersions(address[] memory olds) public{

    for (uint i = 0; i < olds.length; i++) {

      appendOldVersion(olds[i]);

    }

  }



  function removeOldVersion(address old) public onlyOwner{

    require(_old[old], "Unknow old version");

    _old[old] = false;

    emit OldVersionRemoved(old);

  }



  function removeOldVersions(address[] memory olds) public{

    for (uint i = 0; i < olds.length; i++) {

      removeOldVersion(olds[i]);

    }

  }



  function setNewVersion(address new_) public onlyOwner{

    emit NewVersionChanges(_new, new_);

    _new = new_;

  }



  function newVersion() public view returns(address){

    return _new;

  }



  function isOldVersion(address address_) public view returns(bool){

    return _old[address_];

  }



  function migrate() public onlyIfNewVersionIsDefined {

    address account = msg.sender;

    uint256 balance = balanceOf(account);

    require(balance > 0, "Current balance is zero");



    _burn(account, balance);

    Migratable(_new).migration(account, balance);

    emit Migrated(account, balance);

  }



  function migration(address account, uint256 balance) public onlyOldVersion{

    _mint(account,balance);

    emit Migrated(account, balance);

  }

}



contract Pausable is Ownable {

    event Paused();

    event Unpaused();



    bool private _paused;



    constructor () public {

        _paused = false;

    }



    /**

     * @return True if the contract is paused, false otherwise.

     */

    function paused() public view returns (bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused, "Paused");

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(_paused, "Unpaused");

        _;

    }



    /**

     * @dev Called by a pauser to pause, triggers stopped state.

     */

    function pause() public onlyOwner whenNotPaused {

        _paused = true;

        emit Paused();

    }



    /**

     * @dev Called by a pauser to unpause, returns to normal state.

     */

    function unpause() public onlyOwner whenPaused {

        _paused = false;

        emit Unpaused();

    }

}



contract Policable is Ownable {

    ITransferPolicy public transferPolicy;

    event PolicyChanged(address _oldPolicy, address _newPolicy);



    constructor(

        address policyContract

    ) public {

        transferPolicy = ITransferPolicy(policyContract);

    }





    modifier onlyIfIsTransferPossible(address from, address to, uint256 value){

        require(transferPolicy.isTransferPossible(from, to, value), "Transfer is not possible");

        _;

    }



    modifier onlyIfIsBehalfTransferPossible(address sender, address from, address to, uint256 value){

        require(transferPolicy.isBehalfTransferPossible(sender, from, to, value), "Transfer is not possible");

        _;

    }



    function setTransferPolicy(address _newPolicy) public onlyOwner {

        address old = address(transferPolicy);

        transferPolicy = ITransferPolicy(_newPolicy);

        emit PolicyChanged(old, _newPolicy);

    }

}



contract Seizable is ERC20, Ownable {

    mapping(address => uint256) public seizedAmounts;

    event Seizure(address indexed seized, uint256 amount);



    function seize(address _seized) public onlyOwner {

        uint256 _amount = balanceOf(_seized);

        _burn(_seized, _amount);

        _mint(owner(), _amount);

        emit Seizure(_seized, _amount);

    }

}



contract Token is ERC20, ERC20Detailed {

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 mint) ERC20Detailed(name,symbol,decimals) public {

        _mint(msg.sender, mint);

    }

}



contract ArtworkToken is Token, Policable, Seizable, Pausable, Documentable, Migratable{

    



    constructor (

        string memory name,

        string memory symbol,

        uint8 decimals,

        uint256 amount,

        address policyContract,

        address documentsContract

    ) public 

        Token(name, symbol, decimals, amount)

        Policable(policyContract)

        Pausable()

        Documentable(documentsContract)

    { }



    function transfer(address to, uint256 value) public

        whenNotPaused

        onlyIfIsTransferPossible(msg.sender, to, value)

    returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value)  public

        whenNotPaused

        onlyIfIsBehalfTransferPossible(msg.sender, from, to, value)

    returns (bool) {

        return super.transferFrom(from, to, value);

    }

}



