/**
 *Submitted for verification at Etherscan.io on 2021-03-05
*/

pragma solidity ^0.5.16;


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
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
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
}

/**
 * @dev Contract module which provides a Governance access control mechanism, where
 * there is an account (a Governor) that can be granted exclusive access to
 * specific functions.
 *
 * Unlike with Ownable, governance can not be renounced.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyGovernance`, which can be applied to your functions to restrict their use to
 * the Governance.
 */
contract Governable is Context {

    address private _governance;

    event GovernanceTransferred(address indexed previousGovernance, address indexed newGovernance);

    /**
     * @dev Initializes the contract setting the deployer as the initial Governance.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function governance() public view returns (address) {
        return _governance;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGovernance() {
        require(isGovernance(), "Governable: caller is not the governance");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isGovernance() public view returns (bool) {
        return _msgSender() == _governance;
    }


    /**
     * @dev Transfers governance of the contract to a new account (`newGovernance`).
     * Can only be called by the current governance.
     */
    function setGovernance(address newGovernance) public onlyGovernance {
        _transferGovernance(newGovernance);
    }

    /**
     * @dev Transfers governance of the contract to a new account (`newGovernance`).
     */
    function _transferGovernance(address newGovernance) internal {
        require(newGovernance != address(0), "Governable: new governance is the zero address");
        emit GovernanceTransferred(_governance, newGovernance);
        _governance = newGovernance;
    }
}

contract EDDA is ERC20, ERC20Detailed, Governable {
    constructor () public ERC20Detailed("EDDA", "EDDA", 18) {
        // Mint total supply to Governance during contract creation.
        // _mint is internal funciton of Openzeppelin ERC20 contract used to create all supply.
        // After contract creation, there is no way to call _mint() function on deployed contract.
        _mint(governance(), uint256(5000 * 10 ** uint256(decimals())));
    }
}

contract IReleaser {
    function release() external;

    function isReleaser() external pure returns (bool) {
        return true;
    }
}

contract TokenSplitter is IReleaser, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);

    IERC20 public token;

    address[] public payees;
    mapping(address => uint256) public shares;
    mapping(address => bool) public releasers;

    uint256 private _totalShares;

    constructor (IERC20 token_, address[] memory payees_, uint256[] memory shares_, bool[] memory releasers_) public {
        require(address(token_) != address(0), "TokenSplitter: token is the zero address");
        require(payees_.length == shares_.length, "TokenSplitter: payees and shares length mismatch");
        require(payees_.length == releasers_.length, "TokenSplitter: payees and releasers length mismatch");
        require(payees_.length > 0, "TokenSplitter: no payees");

        token = token_;
        for (uint256 i = 0; i < payees_.length; i++) {
            _addPayee(payees_[i], shares_[i], releasers_[i]);
        }
    }

    function payeesCount() public view returns (uint256) {
        return payees.length;
    }

    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    function release() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            for (uint256 i = 0; i < payees.length; i++) {
                address account = payees[i];
                uint256 payment = balance.mul(shares[account]).div(_totalShares);
                if (payment > 0) {
                    token.safeTransfer(account, payment);
                    if (releasers[account]) {
                        IReleaser(address(account)).release();
                    }
                    emit PaymentReleased(account, payment);
                }
            }
        }
    }

    function _addPayee(address account_, uint256 shares_, bool releaser_) private {
        require(account_ != address(0), "TokenSplitter: account is the zero address");
        require(shares_ > 0, "TokenSplitter: shares are 0");
        require(shares[account_] == 0, "TokenSplitter: account already has shares");
        // if announced as releaser - should implement interface 
        require(
            !releaser_ || IReleaser(account_).isReleaser(), 
            "TokenSplitter: account releaser status wrong"
        );

        payees.push(account_);
        shares[account_] = shares_;
        releasers[account_] = releaser_;
        _totalShares = _totalShares.add(shares_);
        emit PayeeAdded(account_, shares_);
    }
}

// SPDX-License-Identifier: MIT
/**
 * Yggdrasil.finance
 * https://yggdrasil.finance
 *
 * Additional details for contract and wallet information:
 * https://yggdrasil.finance/tracking/
 */
contract EDDATokenSale is Ownable {
    //Enable SafeMath
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for EDDA;

    uint8 public constant percentSale = 65; 
    bool public initialized;

    uint256 public constant SCALAR = 1e18; // multiplier
    uint256 public constant minBuyWei = 1e17; // in Wei

    address public tokenAcceptor;
    address payable public ETHAcceptor;
    uint256 public priceInWei;
    uint256 public maxBuyTokens = 20; // in EDDA per address
    uint256 public initialSupplyInWei;
    
    address[] buyers; // buyers
    mapping(address => uint256) public purchases; // balances
    uint256 public purchased; // spent
    uint256 public distributionBatch = 1;
    uint256 public transferredToTokenAcceptor;

    bool public saleEnabled = false;

    EDDA public tokenContract;
    TokenSplitter public reserved;

    // Events
    event Sell(address _buyer, uint256 _amount);
    event Paid(address _from, uint256 _amount);
    event Withdraw(address _to, uint256 _amount);

    // On deployment
    constructor(
        EDDA _tokenContract, 
        uint256 _priceInWei,
        address _tokenAcceptor, 
        address payable _ETHAcceptor,
        address _reserved
    ) public {
        tokenContract = _tokenContract;
        tokenAcceptor = _tokenAcceptor;
        priceInWei = _priceInWei;
        ETHAcceptor = _ETHAcceptor;
        reserved = TokenSplitter(_reserved);
    }

    // Initialise
    function init() external onlyOwner {
        require(!initialized, "Could be initialized only once");
        require(reserved.owner() == address(this), "Sale should be the owner of Reserved funds");

        uint256 _initialSupplyInWei = tokenContract.balanceOf(address(this));
        require(
            _initialSupplyInWei > 0, 
            "Initial supply should be > 0"
        );

        initialSupplyInWei = _initialSupplyInWei;
        
        uint256 _tokensToReserveInWei = _getInitialSupplyPercentInWei(100 - percentSale); 
        initialized = true;
        tokenContract.safeTransfer(address(reserved), _tokensToReserveInWei);
    }
  
    /// @notice Any funds sent to this function will be unrecoverable
    /// @dev This function receives funds, there is currently no way to send funds back
    function () external payable {
        emit Paid(msg.sender, msg.value);
    }

    // Buy tokens with ETH
    function buyTokens() external payable {
        uint256 _ethSent = msg.value;
        require(saleEnabled, "The EDDA Initial Token Offering is not yet started");
        require(_ethSent >= minBuyWei, "Minimum purchase per transaction is 0.1 ETH");

        uint256 _tokens = _ethSent.mul(SCALAR).div(priceInWei);

        // Check that the purchase amount does not exceed remaining tokens
        require(_tokens <= _remainingTokens(), "Not enough tokens remain");

        if (purchases[msg.sender] == 0) {
            buyers.push(msg.sender);
        }
        purchases[msg.sender] = purchases[msg.sender].add(_tokens);
        require(purchases[msg.sender] <= maxBuyTokens.mul(SCALAR), "Exceeded maximum purchase limit per address");

        purchased = purchased.add(_tokens);

        emit Sell(msg.sender, _tokens);
    }

    // Enable the token sale
    function enableSale(bool _saleStatus) external onlyOwner {
        require(initialized, "Sale should be initialized");
        saleEnabled = _saleStatus;
    }

    // Update the current Token price in ETH
    function setPriceETH(uint256 _priceInWei) external onlyOwner {
        require(_priceInWei > 0, "Token price should be > 0");
        priceInWei = _priceInWei;
    }

    // Update the maximum buy in tokens
    function updateMaxBuyTokens(uint256 _maxBuyTokens) external onlyOwner {
        maxBuyTokens = _maxBuyTokens;
    }

    // Update the distribution batch size
    function updateDistributionBatch(uint256 _distributionBatch) external onlyOwner {
        distributionBatch = _distributionBatch;
    }

    // Distribute purchased tokens
    function distribute(uint256 _offset) external onlyOwner returns (uint256) {
        uint256 _distributed = 0;
        for (uint256 i = _offset; i < buyers.length; i++) {
            address _buyer = buyers[i];
            uint256 _purchase = purchases[_buyer];
            if (_purchase > 0) {
                purchases[_buyer] = 0;
                tokenContract.safeTransfer(_buyer, _purchase);
                if (++_distributed >= distributionBatch) {
                    break;
                }
            }            
        }
        return _distributed;
    }

    // Withdraw current ETH balance
    function withdraw() public onlyOwner {
        emit Withdraw(ETHAcceptor, address(this).balance);
        ETHAcceptor.transfer(address(this).balance);
    }

    // Get percent value of initial supply in wei
    function _getInitialSupplyPercentInWei(uint8 _percent) private view returns (uint256) {
        return initialSupplyInWei.mul(_percent).div(100); 
    }

    // Get tokens remaining on token sale balance
    function _remainingTokens() private view returns (uint256) {
        return _getInitialSupplyPercentInWei(percentSale)
            .sub(purchased)
            .sub(transferredToTokenAcceptor);
    }

    // End the token sale and transfer remaining ETH and tokens to the acceptors
    function endSale() external onlyOwner {
        uint256 remainingTokens = _remainingTokens();
        if (remainingTokens > 0) {
            transferredToTokenAcceptor = transferredToTokenAcceptor.add(remainingTokens);
            tokenContract.safeTransfer(tokenAcceptor, remainingTokens);
        }
        withdraw();
        reserved.release();

        saleEnabled = false;
    }
}