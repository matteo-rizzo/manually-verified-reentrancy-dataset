/**
 *Submitted for verification at Etherscan.io on 2020-09-04
*/

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Initializable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

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
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}

// import "../openzeppelin/upgrades/contracts/Initializable.sol";

// import "../openzeppelin/upgrades/contracts/Initializable.sol";

contract OwnableUpgradable is Initializable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    modifier onlyOwner {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    // ** INITIALIZERS – Constructors for Upgradable contracts **

    function initialize() public initializer {
        owner = msg.sender;
    }

    function initialize(address payable newOwner) public initializer {
        owner = newOwner;
    }

    function changeOwner(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }

    uint256[50] private ______gap;
}

contract AdminableUpgradable is Initializable, OwnableUpgradable {
    mapping(address => bool) public admins;

    modifier onlyOwnerOrAdmin {
        require(msg.sender == owner ||
                admins[msg.sender], "Permission denied");
        _;
    }

    // Initializer – Constructor for Upgradable contracts
    function initialize() public initializer {
        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function initialize(address payable newOwner) public initializer {
        OwnableUpgradable.initialize(newOwner);  // Initialize Parent Contract
    }

    function setAdminPermission(address _admin, bool _status) public onlyOwner {
        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {
        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }

    uint256[50] private ______gap;
}

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";

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




contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {
        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    /*function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }*/
}

contract IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function userInfo(uint256 _pid, address _addr) external returns(uint amount, uint rewardDebt);
}

contract SushiFarmToken is
    Initializable,
    DSMath,
    ERC20,
    ERC20Detailed,
    AdminableUpgradable
{
    using UniversalERC20 for IToken;

    address public constant MASTER_CHEF = address(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    IToken public constant SUSHI = IToken(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IToken public constant USDT = IToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    IToken public lpUniToken;
    uint public sushiPoolNumber;

    mapping(address => uint256) public sushiWithdrawal;
    uint256 public totalSushiWithdrawal;
    
    uint256 totalBurnedSushi;
    // ** INITIALIZER **

    function initialize(address payable newOwner) public initializer {
        // Initialize Parent Contracts
        AdminableUpgradable.initialize(newOwner);
        ERC20Detailed.initialize("Sushi Farm Token", "SFT", 18);

        admins[0x4d3ff3D6C79a3ad20314B0cf86A32D15277AAb85] = true;
    }

    // ** PUBLIC functions **

    // price - Token/USDT (1e6), amount – token numbers (1e18)
    function buy(uint price, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        // check timestamp
        require(block.timestamp < deadline);

        // check signature
        bytes32 hash = sha256(abi.encodePacked(address(this), msg.sender, price, amount, deadline));
        address src = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(admins[src] == true, "Access denied");

        // swap USDT to tokens
        uint usdtAmount = wmul(amount, price * 1e12) / 1e12; //  usdt decimals = 6
        USDT.universalTransferFrom(msg.sender, address(owner), usdtAmount);

        // internal transfer to msg.sender
        _transfer(address(this), msg.sender, amount);
    }

    function recalcTotalSushiWithdrawal(uint256 burnAmount) internal {
        
        if (totalBurnedSushi == 0) {
            uint256 _totalSushiWithdrawal = totalSushiWithdrawal;
            totalBurnedSushi = sub(500000 * 10**18, totalSupply());
            totalSushiWithdrawal = sub(_totalSushiWithdrawal, _totalSushiWithdrawal * totalBurnedSushi / 500000 * 10**18);
        } else {
            if (burnAmount > 0) {
                uint256 _totalSushiWithdrawal = totalSushiWithdrawal;
                totalSushiWithdrawal = sub(_totalSushiWithdrawal, _totalSushiWithdrawal * burnAmount / totalSupply());    
            }
            
        }        
    }
    
    function burn(uint amount) public returns(uint256 withdrawalLpTokens, uint256 sushiAmount) {
        address account = msg.sender;

        recalcTotalSushiWithdrawal(amount);
        
        uint ratio = wdiv(amount, totalSupply());
        uint pid = sushiPoolNumber;

        // burn tokens
        _burn(account, amount);

        // withdraw lp tokens
        (uint totalAmountLpTokens,) = IMasterChef(MASTER_CHEF).userInfo(pid, address(this));
        withdrawalLpTokens = wmul(totalAmountLpTokens, ratio);
        IMasterChef(MASTER_CHEF).withdraw(pid, withdrawalLpTokens);

        // transfer lpTokens to burner
        lpUniToken.transfer(account, withdrawalLpTokens);

        // transfer Sushi to burner and owner
        uint256 _sushiBalance = SUSHI.balanceOf(address(this));
        _sendSushi(account, account, ratio);
        _sendSushi(address(this), owner, wdiv(balanceOf(address(this)), totalSupply()));
        sushiAmount = _sushiBalance - SUSHI.balanceOf(address(this));
    }

    function withdrawSushi() public {
        address account = msg.sender;

        uint ratio = wdiv(balanceOf(account), totalSupply());
        uint pid = sushiPoolNumber;

        // withdraw sushi from MASTER_CHEF
        IMasterChef(MASTER_CHEF).deposit(pid, 0);

        // transfer Sushi to user and owner
        _sendSushi(account, account, ratio);
        _sendSushi(address(this), owner, wdiv(balanceOf(address(this)), totalSupply()));
    }

    // ** OVERRIDDEN ERC20 functions **

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(false, "transfer not available");
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(false, "approve not available");
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(false, "transferFrom not available");
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(false, "increaseAllowance not available");
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(false, "decreaseAllowance not available");
    }

    // ** ONLY_OWNER functions **

    function create(uint _mintAmount, address _lpToken, uint _lpTokenAmount, uint _pool) public onlyOwner {
        // only once
        require(totalSupply() == 0, "Token has already been created");

        // transfer lpToken to MASTER_CHEF
        IToken(_lpToken).transferFrom(msg.sender, address(this), _lpTokenAmount);
        IToken(_lpToken).approve(MASTER_CHEF, _lpTokenAmount);
        IMasterChef(MASTER_CHEF).deposit(_pool, _lpTokenAmount);

        // mint tokens to this address
        _mint(address(this), _mintAmount);

        sushiPoolNumber = _pool;
        lpUniToken = IToken(_lpToken);
    }

    function withdrawContractTokens(uint amount) public onlyOwner {
        if (amount == uint(-1)) {
            amount = this.balanceOf(address(this));
        }

        // internal transfer to owner
        _transfer(address(this), address(owner), amount);
    }

    function burnContractTokens(uint amount) public onlyOwner {
        if (amount == uint(-1)) {
            amount = this.balanceOf(address(this));
        }
        
        recalcTotalSushiWithdrawal(amount);

        address curOwner = address(owner);
        uint ratio = wdiv(amount, totalSupply());
        uint pid = sushiPoolNumber;

        // burn tokens
        _burn(address(this), amount);

        // withdraw lp tokens
        (uint totalAmountLpTokens,) = IMasterChef(MASTER_CHEF).userInfo(pid, address(this));
        uint withdrawalLpTokens = wmul(totalAmountLpTokens, ratio);
        IMasterChef(MASTER_CHEF).withdraw(pid, withdrawalLpTokens);

        // transfer lpTokens to burner
        lpUniToken.transfer(curOwner, withdrawalLpTokens);

        // update ratio - add balance of this contract
        ratio = ratio.add(wdiv(balanceOf(address(this)), totalSupply()));

        // transfer Sushi to owner
        _sendSushi(address(this), curOwner, ratio);
    }

    function withdrawContractSushi() public onlyOwner {
        uint pid = sushiPoolNumber;

        recalcTotalSushiWithdrawal(0);
        
        // withdraw sushi from MASTER_CHEF
        IMasterChef(MASTER_CHEF).deposit(pid, 0);

        // transfer Sushi to owner
        _sendSushi(address(this), owner, wdiv(balanceOf(address(this)), totalSupply()));
    }

    function setLpToken(address _lpToken) public onlyOwner {
        lpUniToken = IToken(_lpToken);
    }

    function externalCallEth(address payable[] memory  _to, bytes[] memory _data, uint256[] memory _ethAmount) public payable onlyOwner {
        for(uint i = 0; i < _to.length; i++) {
            _cast(_to[i], _data[i], _ethAmount[i]);
        }
    }

    // ** INTERNAL functions **

    
    function _sendSushi(address account, address to, uint ratio) internal {
        // calculate SUSHI tokens
        
        recalcTotalSushiWithdrawal(0);
        
        uint withdrawalSushi = wmul(SUSHI.balanceOf(address(this)).add(totalSushiWithdrawal), ratio);
        uint _sushiWithdrawalForAccount = sushiWithdrawal[account];
        if (withdrawalSushi > _sushiWithdrawalForAccount) {
            withdrawalSushi = withdrawalSushi - _sushiWithdrawalForAccount;
        } else {
            return;
        }

        // UPD Sushi states
        sushiWithdrawal[account] = sushiWithdrawal[account].add(withdrawalSushi);
        totalSushiWithdrawal = totalSushiWithdrawal.add(withdrawalSushi);

        // transfer SUSHI to address
        SUSHI.transfer(to, withdrawalSushi);
    }

    function _cast(address payable _to, bytes memory _data, uint256 _ethAmount) internal {
        bytes32 response;

        assembly {
            let succeeded := call(sub(gas, 5000), _to, _ethAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }
}