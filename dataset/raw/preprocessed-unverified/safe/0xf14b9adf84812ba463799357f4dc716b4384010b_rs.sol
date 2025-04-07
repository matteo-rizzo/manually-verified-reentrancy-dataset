/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

// PensionPlan
// Warning: For protection of our investors, Pension Plan token should not be purchased before 6/10/2021. Such practice will result in address being excluded from transacting forever and lost of  investment.
// Sources flattened with hardhat v2.6.4 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts/utils/[email protected]

/**
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
        return msg.data;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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

// File @openzeppelin/contracts/utils/math/[email protected]

/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// File @openzeppelin/contracts/utils/[email protected]

/**
 * @dev Collection of functions related to array types.
 */



// File @openzeppelin/contracts/utils/[email protected]

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */


// File @openzeppelin/contracts/access/[email protected]

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
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/[email protected]

/**
 * @dev Collection of functions related to the address type
 */



// File contracts/uniswap.sol







interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract PensionPlan is Context, IERC20, IERC20Metadata, Ownable {
    using Address for address;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant _totalSupply = 1000000000000 * 10**8;

    string private constant _name = "Pension Plan";
    string private constant _symbol = "PP";
    
    address payable public marketingAddress = payable(0x83B6d6dec5b35259f6bAA3371006b9AC397A4Ff7);
    address payable public developmentAddress = payable(0x2F01336282CEbF5D981e923edE9E6FaC333dA2C6);
    address payable public foundationAddress = payable(0x72d752776B093575a40B1AC04c57811086cb4B55);
    address payable public hachikoInuBuybackAddress = payable(0xd6C8385ec4F08dF85B39c301C993A692790288c7);
    address payable public constant deadAddress = payable(0x000000000000000000000000000000000000dEaD);

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    mapping (address => bool) private _isBanned;
    address[] private _banned;
   
    uint256 public constant totalFee = 12;

    uint256 public minimumTokensBeforeSwap = 200000000 * 10**8; 

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;

    uint256 public minimumETHBeforePayout = 1 * 10**18;
    uint256 public payoutsToProcess = 5;
    uint256 private _lastProcessedAddressIndex;
    uint256 public _payoutAmount;
    bool public processingPayouts;
    uint256 public _snapshotId;
    
    struct Set {
        address[] values;
        mapping (address => bool) is_in;
    }
    
    Set private _allAddresses;

    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event PayoutStarted(
        uint256 amount
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        excludeFromReward(owner());
        excludeFromReward(_uniswapV2Pair);
        excludeFromReward(marketingAddress);
        excludeFromReward(developmentAddress);
        excludeFromReward(foundationAddress);
        excludeFromReward(hachikoInuBuybackAddress);
        excludeFromReward(deadAddress);
        
        _beforeTokenTransfer(address(0), owner());
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public pure override returns (uint8) {
        return 8;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public pure override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function eligibleSupply() public view returns (uint256) {
        uint256 supply =  _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            unchecked {
                supply = supply - _balances[_excluded[i]];
            }
        }
        return supply;
        
    }

    function eligibleSupplyAt(uint256 snapshotId) public view returns (uint256) {
        uint256 supply =  _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            unchecked {
                supply = supply - balanceOfAt(_excluded[i], snapshotId);
            }
        }
        return supply;
        
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function isBanned(address account) public view returns (bool) {
        return _isBanned[account];
    }

    function ban(address account) external onlyOwner() {
        require(!_isBanned[account], "Account is already banned");
        _isBanned[account] = true;
        _banned.push(account);
        if (!_isExcluded[account]) {
            excludeFromReward(account);
        }
    }

    function unban(address account) external onlyOwner() {
        require(_isBanned[account], "Account is already unbanned");
        for (uint256 i = 0; i < _banned.length; i++) {
            if (_banned[i] == account) {
                _banned[i] = _banned[_banned.length - 1];
                _isBanned[account] = false;
                _banned.pop();
                break;
            }
        }
        if (_isExcluded[account]) {
            includeInReward(account);
        }
    }

    function _processPayouts() private {
        if (_lastProcessedAddressIndex == 0) {
            _lastProcessedAddressIndex = _allAddresses.values.length;
        }
        
        uint256 i = _lastProcessedAddressIndex;
        uint256 loopLimit = 0;
        if (_lastProcessedAddressIndex > payoutsToProcess) {
            loopLimit = _lastProcessedAddressIndex-payoutsToProcess;
        }
        
        uint256 _availableSupply = eligibleSupplyAt(_snapshotId);
        for (; i > loopLimit; i--) {
            address to = _allAddresses.values[i-1];
            if (_isExcluded[to] || to.isContract()) {
                continue;
            }
            uint256 payout = balanceOfAt(to, _snapshotId) / (_availableSupply / _payoutAmount);
            payable(to).send(payout);
        }
        _lastProcessedAddressIndex = i;
        if (_lastProcessedAddressIndex == 0) {
            processingPayouts = false;
        }
    }
    
    function _handleSwapAndPayout(address to) private {
        if (!inSwapAndLiquify && to == uniswapV2Pair) {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            if (overMinimumTokenBalance) {
                swapTokensForEth(contractTokenBalance);    
            }
            uint256 balance = address(this).balance;
            if (!processingPayouts && balance > minimumETHBeforePayout) {
                marketingAddress.transfer(balance / 6);
                developmentAddress.transfer(balance / 12);
                foundationAddress.transfer(balance / 12);
                hachikoInuBuybackAddress.transfer( balance / 24);
                swapETHForTokensAndBurn(balance / 24);
                processingPayouts = true;
                _payoutAmount = address(this).balance;
                _snapshotId = _snapshot();
                emit PayoutStarted(_payoutAmount);
            }
        }
    }
    
    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_isBanned[sender], "ERC: transfer from banned address");
        require(!_isBanned[recipient], "ERC: transfer to banned address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient);
        if (!inSwapAndLiquify && processingPayouts) {
            _processPayouts();
        }
        _handleSwapAndPayout(recipient);

        bool takeFee = (recipient == uniswapV2Pair || sender == uniswapV2Pair);
        if(recipient == deadAddress || sender == owner()){
            takeFee = false;
        }
        
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        uint256 originalAmount = amount;
        if (takeFee) {
            uint256 fee = (amount * totalFee) / 100;
            _balances[address(this)] += fee;
            amount -= fee;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, originalAmount);
    }

    function _beforeTokenTransfer(
        address sender,
        address recipient
    ) internal {
        if (sender == address(0)) {
            // mint
            _updateAccountSnapshot(recipient);
            _updateTotalSupplySnapshot();
        } else if (recipient == address(0)) {
            // burn
            _updateAccountSnapshot(sender);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(sender);
            _updateAccountSnapshot(recipient);
        }
        if (!_allAddresses.is_in[recipient]) {
            _allAddresses.values.push(recipient);
            _allAddresses.is_in[recipient] = true;
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokensAndBurn(uint256 amount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

      // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp + 300
        );
        
        emit SwapETHForTokens(amount, path);
    }

    function setMinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap) external onlyOwner() {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }
    
    function setMarketingAddress(address _marketingAddress) external onlyOwner() {
        marketingAddress = payable(_marketingAddress);
    }
    
    function setDevelopmentAddress(address _developmentAddress) external onlyOwner() {
        developmentAddress = payable(_developmentAddress);
    }
    
    function setFoundationAddress(address _foundationAddress) external onlyOwner() {
        foundationAddress = payable(_foundationAddress);
    }
    
    function setHachikoInuBuybackAddress(address _hachikoInuBuybackAddress) external onlyOwner() {
        hachikoInuBuybackAddress = payable(_hachikoInuBuybackAddress);
    }
    
    function setMinimumETHBeforePayout(uint256 _minimumETHBeforePayout) external onlyOwner() {
        minimumETHBeforePayout = _minimumETHBeforePayout;
    }
    
    function setPayoutsToProcess(uint256 _payoutsToProcess) external onlyOwner() {
        payoutsToProcess = _payoutsToProcess;
    }
    
    function manuallyProcessPayouts() external onlyOwner() returns(bool, uint256) {
        if (processingPayouts) {
            _processPayouts();
        }
        else {
            uint256 balance = address(this).balance;
            marketingAddress.transfer(balance / 6);
            developmentAddress.transfer(balance / 12);
            foundationAddress.transfer(balance / 12);
            hachikoInuBuybackAddress.transfer( balance / 24);
            swapETHForTokensAndBurn(balance / 24);
            processingPayouts = true;
            _payoutAmount = address(this).balance;
            _snapshotId = _snapshot();
            emit PayoutStarted(_payoutAmount);
        }
        return (processingPayouts, _lastProcessedAddressIndex);
    }
    
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

     //to receive ETH from uniswapV2Router when swaping
    receive() external payable {}
}