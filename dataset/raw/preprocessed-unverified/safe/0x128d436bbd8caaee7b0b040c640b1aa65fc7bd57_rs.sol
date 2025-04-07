/**
 *Submitted for verification at Etherscan.io on 2021-09-09
*/

pragma solidity ^0.5.0;

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
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    /** @dev Creates `amount` tokens and assigns them to `account`,
     * NOT increasing the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _tmpmint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        //_totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    /**
     * @dev Destroys `amount` tokens from `account`,
     * change the total supply by `addtotal`-`amount`.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _tmpburn(address account, uint256 amount, uint256 addtotal) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.add(addtotal).sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

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
 * @title Pausable token
 * @dev ERC20 with pausable transfers and allowances.
 *
 * Useful if you want to stop trades until the end of a crowdsale, or have
 * an emergency switch for freezing all token transfers in the event of a large
 * bug.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

/**
 * @dev Collection of functions related to the address type
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


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract OwnerRole is Context {
    using Roles for Roles.Role;

    event OwnerAdded(address indexed account);
    event OwnerRemoved(address indexed account);

    Roles.Role private _owners;

    constructor () internal {
        _addOwner(_msgSender());
    }

    modifier onlyOwner() {
        require(isOwner(_msgSender()), "OwnerRole: caller does not have the Owner role");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return _owners.has(account);
    }

    function addOwner(address account) public onlyOwner {
        _addOwner(account);
    }

    function renounceOwner() public {
        _removeOwner(_msgSender());
    }

    function _addOwner(address account) internal {
        _owners.add(account);
        emit OwnerAdded(account);
    }

    function _removeOwner(address account) internal {
        _owners.remove(account);
        emit OwnerRemoved(account);
    }
}

contract OneEUR is ERC20, ERC20Pausable, OwnerRole, MinterRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string private _name; //includes serial number in bonds
    string private _symbol; //includes serial number in bonds
    uint8 private _decimals; //=5
    int32 private _serial; //-1 for 1EUR base token
    uint256 private _bondedSupply; // funds in bonds
    uint32 private _bondPrice; // price of 1EUR bond (6 decimal places), 1000000=1EUR
    uint40 private _bondBuyStart; // start of subscription
    uint40 private _bondBuyEnd; // end of subscription
    uint40 private _bondMature; // maturity date
    string private _www; // web page for more info on how to buy and sell 1EUR

    mapping (address => uint256) private _minterAllowances;
    address[] private _bonds;

    constructor () public {
        _name = "1EUR stablecoin";
        _symbol = "1EUR";
        _decimals = 6;
        _serial =  -1;
    }
    function init(string calldata _newname,string calldata _newsymbol,uint8 _newdecimals,int32 _newserial,uint256 _limit,uint32 _price,uint40 _start, uint40 _end,uint40 _mature) external returns (bool) {
	require(bytes(_name).length == 0);
	_name=_newname;
	_symbol=_newsymbol;
	_decimals=_newdecimals;
	_serial=_newserial;
	_bondPrice=_price;
	_bondBuyStart=_start;
	_bondBuyEnd=_end;
	_bondMature=_mature;
	_addOwner(_msgSender());
	_addMinter(_msgSender());
	_minterApprove(_msgSender(),_limit);
	return true;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint) {
        return _decimals;
    }
    /**
     * @dev Bond serial number, starts with 0, -1 for 1EUR base token (no bond)
     * @return int, -1 for base token (1EUR)
     */
    function serialNumber() public view returns (int) {
        return _serial;
    }
    /**
     * @dev Circulating supply = totalSupply - funds in bonds
     * @return uint
     */
    function circulatingSupply() public view returns (uint) {
        return totalSupply().sub(_bondedSupply);
    }
    /**
     * @dev Bond price with 6 decimals (1000000 = 1.000000 EUR base token)
     * @return uint
     */
    function bondPrice() public view returns (uint) {
        return _bondPrice;
    }
    /**
     * @dev Bond can be purchased after this date
     * @return uint
     */
    function bondBuyStart() public view returns (uint) {
        return _bondBuyStart;
    }
    /**
     * @dev Bond can be purchased before this date
     * @return uint
     */
    function bondBuyEnd() public view returns (uint) {
        return _bondBuyEnd;
    }
    /**
     * @dev Bond is mature after this date, funds can be retreived with redeemBond
     * @return uint
     */
    function bondMature() public view returns (uint) {
        return _bondMature;
    }
    /**
     * @dev Web page with info on how to buy and sell 1EUR via SEPA
     * @return string
     */
    function www() public view returns (string memory) {
        return _www;
    }
    /**
     * @dev Returns contract address of the bond[n]
     * @param n serial number of bond, starting with 0
     * @return address
     */
    function bondAddress(uint256 n) public view returns (address) {
        return _bonds[n];
    }
    /**
     * @dev View first Bond with serial number >= n with invested funds owned by provided address
     * @param n minium serial number of bond, >= 0
     * @param owner address of the owner
     * @return int serial number of bond
     */
    function myBond(uint256 n,address owner) public view returns (int) {
	for (uint i=n; i < _bonds.length; i++) {
          OneEUR nbond = OneEUR(address(_bonds[i]));
          if(nbond.balanceOf(owner)>0){
            return int(i);}}
        return -1; // no bonds with assets
    }
    /**
     * @dev View first mature Bond with serial number >= n with invested funds owned by provided address
     * @param n minium serial number of bond, >= 0
     * @param owner address of the owner
     * @return int serial number of bond
     */
    function myMatureBond(uint256 n,address owner) public view returns (int) {
	for (uint i=n; i < _bonds.length; i++) {
          OneEUR nbond = OneEUR(address(_bonds[i]));
          if(nbond.balanceOf(owner)>0 && nbond.bondMature()<block.timestamp){
            return int(i);}}
        return -1; // no mature bond available
    }
    /**
     * @dev view first active Bond with serial number >= n (bond can be purchased now)
     * @param n minium serial number of bond, >= 0
     * @return int serial number of bond
     */
    function activeBond(uint256 n) public view returns (int) {
	for (uint i=n; i < _bonds.length; i++) {
          OneEUR nbond = OneEUR(address(_bonds[i]));
          if(nbond.bondBuyStart()<block.timestamp && block.timestamp<nbond.bondBuyEnd()){
            return int(i);}}
        return -1;
    }
    /**
     * @dev view number of bonds and total outstanding balance
     * @return uint number of bonds
     * @return uint sum of totalSupply
     */
    function bondTotalSupply() public view returns (uint256 num,uint256 total) {
	for (num=0; num < _bonds.length; num++) {
          OneEUR nbond = OneEUR(address(_bonds[num]));
          total+=nbond.totalSupply();}
    }
    /**
     * @dev view parameters of Bond with serial number n
     * @return address address of bonds
     * @return uint256 bonds bought (totalSupply)
     * @return uint256 bonds available (if bond active)
     * @return uint256 bond price (6 decimals)
     * @return uint256 bond buy start
     * @return uint256 bond buy end
     * @return uint256 bond maturity
     * @return string status [error,waiting,active,immature,mature]
     */
    function bondDetails(uint256 n) public view returns (
          address bondaddress,
          uint256 bondsbought,
          uint256 bondsavailable,
          uint256 bondprice,
          uint256 bondbuystart,
          uint256 bondbuyend,
          uint256 bondmature,
          string memory status ) {
        bondaddress = _bonds[n];
        OneEUR nbond = OneEUR(bondaddress);
        bondsbought = nbond.totalSupply(); 
        bondsavailable = nbond.minterAllowance(address(this)); 
        bondprice = nbond.bondPrice();
        bondbuystart = nbond.bondBuyStart();
        bondbuyend = nbond.bondBuyEnd();
        bondmature = nbond.bondMature();
        if(bondbuystart==0){
          status='error';}
        else if(bondbuystart>block.timestamp){
          status='waiting';}
        else if(bondbuyend>block.timestamp){
          status='active';}
        else if(bondmature>block.timestamp){
          status='immature';}
        else{
          status='mature';}
    }
    /**
     * @dev show size of available subscription for Bond with serial number n
     * @param n serial number of bond, starts with zero
     * @return uint size of bond (number of bonds) still available (if bond active)
     */
    function bondAvailable(uint256 n) public view returns (uint256) {
        OneEUR nbond = OneEUR(address(_bonds[n]));
        if(nbond.bondBuyStart()<block.timestamp && block.timestamp<nbond.bondBuyEnd()){
          return nbond.minterAllowance(address(this)); }
        return 0;
    }
    /**
     * @dev buys bond
     * @param n serial number of bond, starts with zero
     * @param amount size of bond (number of bonds) to buy in 1EUR (6 decimal places)
     */
    function buyBond(uint256 n, uint256 amount) external whenNotPaused {
        OneEUR nbond = OneEUR(address(_bonds[n]));
        bool success = nbond.wrapTo(_msgSender(),amount,0);
        require(success);
        uint256 price = amount.mul(nbond.bondPrice()).div(1000000); 
        _tmpburn(_msgSender(),price,amount);
        _bondedSupply+=amount;
    }
    /**
     * @dev redeem bond
     * @param n serial number of bond, starts with zero
     */
    function redeemBond(uint256 n) external whenNotPaused {
        OneEUR nbond = OneEUR(address(_bonds[n]));
        uint256 amount = nbond.unwrapAll(_msgSender());
        require(amount>0);
        _tmpmint(_msgSender(), amount);
        _bondedSupply-= amount;
    }
    /**
     * @dev Set www address, onlyOwner
     * @param newwww URL
     */
    function setWww(string calldata newwww) external onlyOwner returns (bool) {
    	_www=newwww;
    	return true;
    }
    /**
     * @dev Deploy new bond, onlyMinter
     * Bond will wait 1 week before subscription starts.
     * Subscription ends in 2 weeks.
     * @param limit bond size with 6 decimals (1000000 = 1EUR)
     * @param price price of a single 1EUR bond (1000000 = 1EUR), should be < 1000000 && > 100000, 900000 means 10% discount
     * @param numweeks number of weeks (after subscription end) for bond to mature (1 year ~ 52)
     * @return address new bond address
     */
    function deployBond(uint limit,uint price,uint numweeks) external onlyMinter returns (address bondaddress) {
	require(_bondBuyStart==0, "OneEUR: no bonds on bond");
	require(limit>0, "OneEUR: bond size must be > 0");
        require(price<1000000 && price>100000, "OneEUR: discount must be < 90%");
        require(numweeks>3, "OneEUR: bond must mature at least 4 weeks");
        uint start=block.timestamp+1 weeks;
        uint end=start+1 weeks;
        uint mature=end+numweeks*1 weeks;
        _minterApprove(_msgSender(), _minterAllowances[_msgSender()].sub(limit.mul(1000000-price).div(1000000), "OneEUR: bond parameters exceed minterAllowance"));
	bytes20 targetBytes = bytes20(address(this));
	assembly {
	  let clone := mload(0x40)
	  mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
	  mstore(add(clone, 0x14), targetBytes)
	  mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
	  bondaddress := create(0, clone, 0x37)
	}
	emit newBond(address(bondaddress));
	OneEUR nbond = OneEUR(address(bondaddress));
	bool success = nbond.init(string(abi.encodePacked("1EUR Zero-Coupon Bond [",uint2str(_bonds.length),"]")),string(abi.encodePacked("1EURb",uint2str(_bonds.length))),uint8(_decimals),int32(_bonds.length),limit,uint32(price),uint40(start),uint40(end),uint40(mature));
	require(success);
	_bonds.push(address(bondaddress));
    }
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    /**
     * @dev wraps received fiat and mint wrapped 1EUR. Logs native txid from SEPA.
     * Or wraps declared 1EUR and mints bond (then txid=0).
     * onlyMinter
     * @param owner owner of the wrapped token or bond
     * @param amount amount of token or bonds
     * @param txid of SEPA transaction
     * @return bool true on success
     */
    function wrapTo(address owner, uint256 amount, uint256 txid) external onlyMinter whenNotPaused returns (bool) {
        require(_bondBuyStart==0 || (_bondBuyStart<block.timestamp && block.timestamp<_bondBuyEnd), "OneEUR: bond subscription not active");
        emit Wrap(owner, txid, amount);
        _mint(owner, amount);
        _minterApprove(_msgSender(), _minterAllowances[_msgSender()].sub(amount, "OneEUR: minted amount exceeds minterAllowance"));
        return true;
    }
    /**
     * @dev Unwrap and destroy amount of 1EUR from the caller. Logs ibanhash to receive fiat over SEPA.
     * @param amount amount of token or bonds
     * @param ibanhash hash of SEPA destination, check web page to obtain correct ibanhash parameter
     */
    function unwrap(uint256 amount, uint256 ibanhash) external whenNotPaused {
        require(_bondBuyStart==0, "OneEUR: no unwrap on bond");
        emit Unwrap(_msgSender(), ibanhash, amount);
        _burn(_msgSender(), amount);
    }
    /**
     * @dev Unwrap and destroy amount of 1EUR from owner. Logs ibanhash to receive fiat over SEPA.
     * @param owner address of the owner
     * @param amount amount of token or bonds
     * @param ibanhash hash of SEPA destination, check web page to obtain correct ibanhash parameter
     */
    function unwrapFrom(address owner, uint256 amount, uint256 ibanhash) external whenNotPaused {
        require(_bondBuyStart==0, "OneEUR: no unwrap on bond");
        emit Unwrap(owner, ibanhash, amount);
        _burnFrom(owner, amount);
    }
    /**
     * @dev Unwrap and destroy all tokens from owner. onlyMinter
     * @param owner address of the owner
     */
    function unwrapAll(address owner) external onlyMinter whenNotPaused returns (uint256 amount) {
        require(_bondBuyStart>0, "OneEUR: this is not a bond");
        require(_bondMature<block.timestamp, "OneEUR: bond not mature yet");
        amount=balanceOf(owner);
        require(amount>0);
        emit Unwrap(owner, 0, amount);
        _burn(owner, amount);
    }
    /**
     * @dev Return allowence of the minter
     * @param minter address of the minter
     */
    function minterAllowance(address minter) public view returns (uint256) {
        return _minterAllowances[minter];
    }
    /**
     * @dev Set the minterAllowance granted to minter
     * @param minter address of the minter
     * @param amount allowence in tokens (6 decimals)
     */
    function minterApprove(address minter, uint256 amount) external onlyOwner {
        _minterApprove(minter, amount);
    }
    /**
     * @dev Increases the minterAllowance granted to minter.
     * @param minter address of the minter
     * @param addedValue allowence in tokens (6 decimals) added to current value
     */
    function increaseMinterAllowance(address minter, uint256 addedValue) external onlyOwner {
        _minterApprove(minter, _minterAllowances[minter].add(addedValue));
    }
    /**
     * @dev Decreases the minterAllowance granted to minter.
     * @param minter address of the minter
     * @param subtractedValue allowence in tokens (6 decimals) subtracted from current value
     */
    function decreaseMinterAllowance(address minter, uint256 subtractedValue) external onlyOwner returns (bool) {
        _minterApprove(minter, _minterAllowances[minter].sub(subtractedValue, "OneEUR: decreased minterAllowance below zero"));
        return true;
    }
    function _minterApprove(address minter, uint256 amount) internal {
        require(isMinter(minter), "OneEUR: minter approve for non-minting address");
        _minterAllowances[minter] = amount;
        emit MinterApproval(minter, amount);
    }
    function isMinter(address account) public view returns (bool) {
        return MinterRole.isMinter(account) || isOwner(account);
    }
    function removeMinter(address account) external onlyOwner {
        _minterApprove(account, 0);
        _removeMinter(account);
    }
    function isPauser(address account) public view returns (bool) {
        return PauserRole.isPauser(account) || isOwner(account);
    }
    function removePauser(address account) external onlyOwner {
        _removePauser(account);
    }
    /**
     * @dev Send message, onlyOwner.
     */
    function exec(address _to,bytes calldata _data) payable external onlyOwner returns (bool, bytes memory) {
        return _to.call.value(msg.value)(_data);
    }
    /**
     * @dev Transfer all Ether held by the contract to the owner, onlyOwner.
     */
    function reclaimEther() external onlyOwner {
        _msgSender().transfer(address(this).balance);
    }
    /**
     * @dev Reclaim all ERC20 compatible tokenst,onlyOwner.
     */
    function reclaimToken(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(_msgSender(), balance);
    }

    event Wrap(address indexed to, uint256 indexed txid, uint256 amount);
    event Unwrap(address indexed from, uint256 indexed ibanhash, uint256 amount);
    event MinterApproval(address indexed minter, uint256 amount);
    event newBond(address bondaddress);
}