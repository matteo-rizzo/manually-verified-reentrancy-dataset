pragma solidity ^0.6.5;


// SPDX-License-Identifier: MIT
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract RoniToken is ERC20  {
    using SafeMath for uint256;
   
    address public owner;   
    
    uint public stakeholdersIndexFor3Months = 0;
    uint public stakeholdersIndexFor6Months = 0;
    uint public stakeholdersIndexFor12Months = 0;
    uint public totalStakes = 0;
    uint public stakingPool = 0;
    uint public totalStakesFor3Months = 0;
    uint public totalStakesFor6Months = 0;
    uint public totalStakesFor12Months = 0;
   
    struct Stakeholder {
         bool staker;
         uint id;
    }
    
    struct UserInfo {
        uint id;
        uint[] stake;
        uint[] lockUpTime;
    }
    
    mapping (address => Stakeholder) public stakeholdersFor3Months;
    
    mapping (uint => address) public stakeholdersReverseMappingFor3Months;
    
    mapping(address => UserInfo) public stakesFor3Months;
    
    mapping (address => Stakeholder) public stakeholdersFor6Months;
    
    mapping (uint => address) public stakeholdersReverseMappingFor6Months;
    
    mapping(address => UserInfo) public stakesFor6Months;
    
    mapping (address => Stakeholder) public stakeholdersFor12Months;
    
    mapping (uint => address) public stakeholdersReverseMappingFor12Months;
    
    mapping(address => UserInfo) public stakesFor12Months;
    
    mapping (address => address) public admins;
    
    constructor(address _owner, uint256 _supply) public ERC20("Pepperoni", "Roni") {
        owner = _owner;
        uint supply = _supply.mul(1e18);
        _mint(_owner, supply); 
        admins[owner] = owner;
        admins[0x0E8eB83e976AEa321Cab0d60B54Bc6Ba1c5E26ab] = 0x0E8eB83e976AEa321Cab0d60B54Bc6Ba1c5E26ab;
    }
    
    function stakeAndLockUpTimeDetailsFor3Months(uint id) view external returns(uint,uint){
      return (stakesFor3Months[msg.sender].stake[id],stakesFor3Months[msg.sender].lockUpTime[id]);
    }
    
    function stakeFor3Months(uint _stake) external {
        if(stakeholdersFor3Months[msg.sender].staker == false){
            addStakeholderFor3Months(msg.sender);
        }
        
        uint availableTostake = calculateStakingCost(_stake);
        stakesFor3Months[msg.sender].stake.push(availableTostake);
        stakesFor3Months[msg.sender].lockUpTime.push(now+90 days);
        stakesFor3Months[msg.sender].id = stakesFor3Months[msg.sender].stake.length-1;
        stakingPool = stakingPool.add(_stake);
        totalStakes = totalStakes.add(availableTostake);
        totalStakesFor3Months = totalStakesFor3Months.add(availableTostake);
        _burn(msg.sender, _stake);
    } 
    
    function withdrawStakeAfter3months(uint _stake, uint id) external {
        require(stakesFor3Months[msg.sender].stake[id] > 0, 'must have stake');
        require(stakesFor3Months[msg.sender].stake[id] >= _stake, 'not enough stake');
        
        if(stakesFor3Months[msg.sender].lockUpTime[id] <= now){
          stakesFor3Months[msg.sender].stake[id] = stakesFor3Months[msg.sender].stake[id].sub(_stake);
          uint reward = _stake.mul(25).div(100);
          uint sum = _stake.add(reward);
          require(stakingPool> sum,'no enough funds in pool');
          stakingPool = stakingPool.sub(sum);
          totalStakes = totalStakes.sub(_stake);
          totalStakesFor3Months = totalStakesFor3Months.sub(_stake);
          _mint(msg.sender, sum);
        }
        else{
            uint stakeToReceive = calculateUnstakingCost(_stake);
            require(stakingPool> stakeToReceive,'no enough funds in pool');
            stakingPool = stakingPool.sub(stakeToReceive);
            totalStakes = totalStakes.sub(_stake);
            stakesFor3Months[msg.sender].stake[id] = stakesFor3Months[msg.sender].stake[id].sub(_stake);
            totalStakesFor3Months = totalStakesFor3Months.sub(_stake);
            _mint(msg.sender, stakeToReceive);
        }
        
        if(stakeholdersFor3Months[msg.sender].staker == true){
            removeStakeholderFor3Months(msg.sender);
        }
    }
    
    function addStakeholderFor3Months(address _stakeholder) private {
       stakeholdersFor3Months[_stakeholder].staker = true;    
       stakeholdersFor3Months[_stakeholder].id = stakeholdersIndexFor3Months;
       stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months] = _stakeholder;
       stakeholdersIndexFor3Months = stakeholdersIndexFor3Months.add(1);
    }
   
    function removeStakeholderFor3Months(address _stakeholder) private  {
        if(stakesFor3Months[msg.sender].stake[stakesFor3Months[msg.sender].id] == 0){
            // get id of the stakeholders to be deleted
            //dev @cnote00
            uint swappableId = stakeholdersFor3Months[_stakeholder].id;
            
            // swap the stakeholders info and update admins mapping
            // get the last stakeholdersReverseMapping address for swapping
            address swappableAddress = stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months -1];
            
            // swap the stakeholdersReverseMapping and then reduce stakeholder index
            stakeholdersReverseMappingFor3Months[swappableId] = stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months - 1];
            
            // also remap the stakeholder id
            stakeholdersFor3Months[swappableAddress].id = swappableId;
            
            // delete and reduce admin index 
            delete(stakeholdersFor3Months[_stakeholder]);
            delete(stakeholdersReverseMappingFor3Months[stakeholdersIndexFor3Months - 1]);
            stakeholdersIndexFor3Months = stakeholdersIndexFor3Months.sub(1);
        }
    }
    
    function stakeAndLockUpTimeDetailsFor6Months(uint id) view external returns(uint,uint){
      return (stakesFor6Months[msg.sender].stake[id],stakesFor6Months[msg.sender].lockUpTime[id]);
    }
    
    function stakeFor6Months(uint _stake) external {
        if(stakeholdersFor6Months[msg.sender].staker == false){
            addStakeholderFor6Months(msg.sender);
        }
        
        uint availableTostake = calculateStakingCost(_stake);
        stakesFor6Months[msg.sender].stake.push(availableTostake);
        stakesFor6Months[msg.sender].lockUpTime.push(now + 180 days);
        stakesFor6Months[msg.sender].id = stakesFor6Months[msg.sender].stake.length-1;
        stakingPool = stakingPool.add(_stake);
        totalStakes = totalStakes.add(availableTostake);
        totalStakesFor6Months = totalStakesFor6Months.add(availableTostake);
        _burn(msg.sender, _stake);
    } 
    
    function withdrawStakeAfter6months(uint _stake, uint id) external {
        require(stakesFor6Months[msg.sender].stake[id] > 0, 'must have stake');
        require(stakesFor6Months[msg.sender].stake[id] >= _stake, 'not enough stake');
        
        if(stakesFor6Months[msg.sender].lockUpTime[id] <= now){
          stakesFor6Months[msg.sender].stake[id] = stakesFor6Months[msg.sender].stake[id].sub(_stake);
          uint reward = _stake.mul(200).div(100);
          uint sum = _stake.add(reward);
          require(stakingPool> sum,'no enough funds in pool');
          stakingPool = stakingPool.sub(sum);
          totalStakes = totalStakes.sub(_stake);
          totalStakesFor6Months = totalStakesFor6Months.sub(_stake);
          _mint(msg.sender, sum);
        }
        else{
            uint stakeToReceive = calculateUnstakingCost(_stake);
            require(stakingPool> stakeToReceive,'no enough funds in pool');
            stakingPool = stakingPool.sub(stakeToReceive);
            totalStakes = totalStakes.sub(_stake);
            stakesFor6Months[msg.sender].stake[id] = stakesFor6Months[msg.sender].stake[id].sub(_stake);
            totalStakesFor6Months = totalStakesFor6Months.sub(_stake);
            _mint(msg.sender, stakeToReceive);
        }
        
        if(stakeholdersFor6Months[msg.sender].staker == true){
            removeStakeholderFor6Months(msg.sender);
        }
    }
    
    function addStakeholderFor6Months(address _stakeholder) private {
       stakeholdersFor6Months[_stakeholder].staker = true;    
       stakeholdersFor6Months[_stakeholder].id = stakeholdersIndexFor6Months;
       stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months] = _stakeholder;
       stakeholdersIndexFor6Months = stakeholdersIndexFor6Months.add(1);
    }
   
    function removeStakeholderFor6Months(address _stakeholder) private  {
        if(stakesFor6Months[msg.sender].stake[stakesFor6Months[msg.sender].id] == 0){
            // get id of the stakeholders to be deleted
            uint swappableId = stakeholdersFor6Months[_stakeholder].id;
            
            // swap the stakeholders info and update admins mapping
            // get the last stakeholdersReverseMapping address for swapping
            address swappableAddress = stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months -1];
            
            // swap the stakeholdersReverseMapping and then reduce stakeholder index
            stakeholdersReverseMappingFor6Months[swappableId] = stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months - 1];
            
            // also remap the stakeholder id
            stakeholdersFor6Months[swappableAddress].id = swappableId;
            
            // delete and reduce admin index 
            delete(stakeholdersFor6Months[_stakeholder]);
            delete(stakeholdersReverseMappingFor6Months[stakeholdersIndexFor6Months - 1]);
            stakeholdersIndexFor6Months = stakeholdersIndexFor6Months.sub(1);
        }
    }
    
    function stakeAndLockUpTimeDetailsFor12Months(uint id) view external returns(uint,uint){
      return (stakesFor12Months[msg.sender].stake[id],stakesFor12Months[msg.sender].lockUpTime[id]);
    }
    
    function stakeFor12Months(uint _stake) external {
        if(stakeholdersFor12Months[msg.sender].staker == false){
            addStakeholderFor12Months(msg.sender);
        }
        
        uint availableTostake = calculateStakingCost(_stake);
        stakesFor12Months[msg.sender].stake.push(availableTostake);
        stakesFor12Months[msg.sender].lockUpTime.push(now + 360 days);
        stakesFor12Months[msg.sender].id = stakesFor12Months[msg.sender].stake.length-1;
        stakingPool = stakingPool.add(_stake);
        totalStakes = totalStakes.add(availableTostake);
        totalStakesFor12Months = totalStakesFor12Months.add(availableTostake);
        _burn(msg.sender, _stake);
    } 
    
    function withdrawStakeAfter12months(uint _stake, uint id) external {
        require(stakesFor12Months[msg.sender].stake[id] > 0, 'must have stake');
        require(stakesFor12Months[msg.sender].stake[id] >= _stake, 'not enough stake');
        
        if(stakesFor12Months[msg.sender].lockUpTime[id] <= now){
          stakesFor12Months[msg.sender].stake[id] = stakesFor12Months[msg.sender].stake[id].sub(_stake);
          uint reward = _stake.mul(500).div(100);
          uint sum = _stake.add(reward);
          require(stakingPool> sum,'no enough funds in pool');
          stakingPool = stakingPool.sub(sum);
          totalStakes = totalStakes.sub(_stake);
          totalStakesFor12Months = totalStakesFor12Months.sub(_stake);
          _mint(msg.sender, sum);
        }
        else{
            uint stakeToReceive = calculateUnstakingCost(_stake);
            require(stakingPool> stakeToReceive,'no enough funds in pool');
            stakingPool = stakingPool.sub(stakeToReceive);
            totalStakes = totalStakes.sub(_stake);
            stakesFor12Months[msg.sender].stake[id] = stakesFor12Months[msg.sender].stake[id].sub(_stake);
            totalStakesFor12Months = totalStakesFor12Months.sub(_stake);
            _mint(msg.sender, stakeToReceive);
        }
        
        if(stakeholdersFor12Months[msg.sender].staker == true){
            removeStakeholderFor12Months(msg.sender);
        }
    }
    
    function addStakeholderFor12Months(address _stakeholder) private {
       stakeholdersFor12Months[_stakeholder].staker = true;    
       stakeholdersFor12Months[_stakeholder].id = stakeholdersIndexFor12Months;
       stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months] = _stakeholder;
       stakeholdersIndexFor12Months = stakeholdersIndexFor12Months.add(1);
    }
   
    function removeStakeholderFor12Months(address _stakeholder) private  {
        if(stakesFor12Months[msg.sender].stake[stakesFor12Months[msg.sender].id] == 0){
            // get id of the stakeholders to be deleted
            uint swappableId = stakeholdersFor12Months[_stakeholder].id;
            
            // swap the stakeholders info and update admins mapping
            // get the last stakeholdersReverseMapping address for swapping
            address swappableAddress = stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months -1];
            
            // swap the stakeholdersReverseMapping and then reduce stakeholder index
            stakeholdersReverseMappingFor12Months[swappableId] = stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months - 1];
            
            // also remap the stakeholder id
            stakeholdersFor12Months[swappableAddress].id = swappableId;
            
            // delete and reduce admin index 
            delete(stakeholdersFor12Months[_stakeholder]);
            delete(stakeholdersReverseMappingFor12Months[stakeholdersIndexFor12Months - 1]);
            stakeholdersIndexFor12Months = stakeholdersIndexFor12Months.sub(1);
        }
    }
    
    function transfer(address _to, uint256 _tokens) public override  returns (bool) {
       if(msg.sender == admins[msg.sender]){
              _transfer(msg.sender, _to, _tokens);  
          }
        else{
            uint toSend = transferFee(msg.sender, _tokens);
            _transfer(msg.sender, _to, toSend);
           }
        return true;
    }
    
    function bulkTransfer(address[] calldata _receivers, uint256[] calldata _tokens) external returns (bool) {
        require(_receivers.length == _tokens.length);
        
        uint toSend;
        for (uint256 i = 0; i < _receivers.length; i++) {
            if(msg.sender == admins[msg.sender]){
              _transfer(msg.sender, _receivers[i], _tokens[i].mul(1e18));  
            }
            else{
             toSend = transferFee(msg.sender, _tokens[i]);
            _transfer(msg.sender, _receivers[i], toSend);
            }
        }
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 _tokens) public override returns (bool)  {
        if(sender == admins[msg.sender]){
              _transfer(sender, recipient, _tokens);  
        }
        else{
           uint  toSend = transferFee(sender, _tokens);
           _transfer(sender, recipient, toSend);
        }
        _approve(sender, _msgSender(),allowance(sender,msg.sender).sub(_tokens, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function transferFee(address sender, uint _token) private returns(uint _transferred){
        uint transferFees =  _token.div(10);
        uint burn = transferFees.div(10);
        uint addToPool = transferFees.sub(burn);
        stakingPool = stakingPool.add(addToPool);
        _transferred = _token - transferFees;
        _burn(sender, transferFees);
    }
    
    /*skaing cost 10% */
    function calculateStakingCost(uint256 _stake) private pure returns(uint) {
        uint stakingCost =  (_stake).mul(10);
        uint percent = stakingCost.div(100);
        uint availableForstake = _stake.sub(percent);
        return availableForstake;
    }
    
    /*unskaing cost 20% */
    function calculateUnstakingCost(uint _stake) private pure returns(uint ) {
        uint unstakingCost =  (_stake).mul(20);
        uint percent = unstakingCost.div(100);
        uint stakeReceived = _stake.sub(percent);
        return stakeReceived;
    }
}