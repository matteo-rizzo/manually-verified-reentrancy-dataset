/**

 *Submitted for verification at Etherscan.io on 2019-06-15

*/



pragma solidity ^0.5.0;













/**

 * @dev Implementation of the `IERC20` interface.

 *

 * This implementation is agnostic to the way tokens are created. This means

 * that a supply mechanism has to be added in a derived contract using `_mint`.

 * For a generic mechanism see `ERC20Mintable`.

 *

 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.

 * This allows applications to reconstruct the allowance for all accounts just

 * by listening to said events. Other implementations of the EIP may not emit

 * these events, as it isn't required by the specification.

 *

 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`

 * functions have been added to mitigate the well-known issues around setting

 * allowances. See `IERC20.approve`.

 */

contract ERC20Basic is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowances;



    uint256 private _totalSupply;



    /**

     * @dev See `IERC20.totalSupply`.

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See `IERC20.balanceOf`.

     */

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }



    /**

     * @dev See `IERC20.transfer`.

     *

     * Requirements:

     *

     * - `recipient` cannot be the zero address.

     * - the caller must have a balance of at least `amount`.

     */

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    /**

     * @dev See `IERC20.allowance`.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];

    }



    /**

     * @dev See `IERC20.approve`.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev See `IERC20.transferFrom`.

     *

     * Emits an `Approval` event indicating the updated allowance. This is not

     * required by the EIP. See the note at the beginning of `ERC20`;

     *

     * Requirements:

     * - `sender` and `recipient` cannot be the zero address.

     * - `sender` must have a balance of at least `value`.

     * - the caller must have allowance for `sender`'s tokens of at least

     * `amount`.

     */

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));

        return true;

    }



    /**

     * @dev Atomically increases the allowance granted to `spender` by the caller.

     *

     * This is an alternative to `approve` that can be used as a mitigation for

     * problems described in `IERC20.approve`.

     *

     * Emits an `Approval` event indicating the updated allowance.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));

        return true;

    }



    /**

     * @dev Atomically decreases the allowance granted to `spender` by the caller.

     *

     * This is an alternative to `approve` that can be used as a mitigation for

     * problems described in `IERC20.approve`.

     *

     * Emits an `Approval` event indicating the updated allowance.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     * - `spender` must have allowance for the caller of at least

     * `subtractedValue`.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));

        return true;

    }



    /**

     * @dev Moves tokens `amount` from `sender` to `recipient`.

     *

     * This is internal function is equivalent to `transfer`, and can be used to

     * e.g. implement automatic token fees, slashing mechanisms, etc.

     *

     * Emits a `Transfer` event.

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



        _balances[sender] = _balances[sender].sub(amount);

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    /** @dev Creates `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a `Transfer` event with `from` set to the zero address.

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



     /**

     * @dev Destoys `amount` tokens from `account`, reducing the

     * total supply.

     *

     * Emits a `Transfer` event with `to` set to the zero address.

     *

     * Requirements

     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.

     *

     * This is internal function is equivalent to `approve`, and can be used to

     * e.g. set automatic allowances for certain subsystems, etc.

     *

     * Emits an `Approval` event.

     *

     * Requirements:

     *

     * - `owner` cannot be the zero address.

     * - `spender` cannot be the zero address.

     */

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



    /**

     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted

     * from the caller's allowance.

     *

     * See `_burn` and `_approve`.

     */

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);

        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));

    }

}











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

 * @title TokenVesting

 * Initilize the vesting contract with token address, amount and periods

 * add beneficiary by calling addBeneficiary funciton with specific amounts

 * release token for available amount

 */

contract TokenVesting is Ownable {

  using SafeMath for uint256;

  using SafeERC20 for ERC20Basic;



  event Released(address beneficiary, uint256 amount);



  ERC20Basic public token;

  uint256 public cliff;

  uint256 public start;

  uint256 public duration;



  mapping (address => uint256) public shares;



  uint256 released = 0;



  address[] public beneficiaries;



  modifier onlyBeneficiaries {

    require( isOwner() || shares[msg.sender] > 0, "You cannot release tokens!");

    _;

  }

  

  constructor(

    ERC20Basic _token,

    uint256 _start,

    uint256 _cliff,

    uint256 _duration

  ) public

  {

    require(_cliff <= _duration, "Cliff has to be lower or equal to duration");

    token = _token;

    duration = _duration;

    cliff = _start.add(_cliff);

    start = _start;

  }



  function addBeneficiary(address _beneficiary, uint256 _sharesAmount) onlyOwner public {

    require(_beneficiary != address(0), "The beneficiary's address cannot be 0");

    require(_sharesAmount > 0, "Shares amount has to be greater than 0");



    releaseAllTokens();



    if (shares[_beneficiary] == 0) {

      beneficiaries.push(_beneficiary);

    }



    shares[_beneficiary] = shares[_beneficiary].add(_sharesAmount);

  }



  function releaseAllTokens() onlyBeneficiaries public {

    uint256 unreleased = releasableAmount();



    if (unreleased > 0) {

      uint beneficiariesCount = beneficiaries.length;



      released = released.add(unreleased);



      for (uint i = 0; i < beneficiariesCount; i++) {

        release(beneficiaries[i], calculateShares(unreleased, beneficiaries[i]));

      }

    }

  }



  function releasableAmount() public view returns (uint256) {

    return vestedAmount().sub(released);

  }



  function calculateShares(uint256 _amount, address _beneficiary) public view returns (uint256) {

    return _amount.mul(shares[_beneficiary]).div(totalShares());

  }



  function totalShares() public view returns (uint256) {

    uint sum = 0;

    uint beneficiariesCount = beneficiaries.length;



    for (uint i = 0; i < beneficiariesCount; i++) {

      sum = sum.add(shares[beneficiaries[i]]);

    }



    return sum;

  }



  function vestedAmount() public view returns (uint256) {

    uint256 currentBalance = token.balanceOf(msg.sender);

    uint256 totalBalance = currentBalance.add(released);



    // solium-disable security/no-block-members

    if (block.timestamp < cliff) {

      return 0;

    } else if (block.timestamp >= start.add(duration)) {

      return totalBalance;

    } else {

      return totalBalance.mul(block.timestamp.sub(start)).div(duration);

    }

    // solium-enable security/no-block-members

  }



  function release(address _beneficiary, uint256 _amount) private {

    token.safeTransfer(_beneficiary, _amount);

    emit Released(_beneficiary, _amount);

  }

}



contract Token {

    uint256 public totalSupply;



    function balanceOf(address _owner) public view returns (uint256 balance);



    function transfer(address _to, uint256 _value) public returns (bool success);



    function transferFrom(address _from, address _to, uint256 _value)public  returns  (bool success);



    function approve(address _spender, uint256 _value) public returns (bool success);



    function allowance(address _owner, address _spender) public view returns  (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;

        balances[_to] += _value; 

        emit Transfer(msg.sender, _to, _value); 

        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >=  _value);

        balances[_to] += _value; 

        balances[_from] -= _value;  

        allowed[_from][msg.sender] -= _value; 

        emit Transfer(_from, _to, _value); 

        return true;

    }

   

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }

    

    function approve(address _spender, uint256 _value) public returns (bool success)   

    {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract SOXToken is StandardToken {

    string public name;                   

    uint8 public decimals;               

    string public symbol;                 

    string public version = 'v0.1';       



    constructor (uint256  _initialAmount, string memory _tokenName, uint8 _decimalUnits, string memory _tokenSymbol) public {

        balances[msg.sender] = _initialAmount; 

        totalSupply = _initialAmount;        

        name = _tokenName;                

        decimals = _decimalUnits;          

        symbol = _tokenSymbol;            

    }

    

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

}