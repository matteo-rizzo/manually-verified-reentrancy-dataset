/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

pragma solidity ^0.6.6;







abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



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













contract Withdrawable is Ownable {
    using SafeERC20 for ERC20;
    address constant ETHER = address(0);

    event LogWithdraw(
        address indexed _from,
        address indexed _assetAddress,
        uint amount
    );

    /**
     * @dev Withdraw asset.
     * @param _assetAddress Asset to be withdrawn.
     */
    function withdraw(address _assetAddress) public onlyOwner {
        uint assetBalance;
        if (_assetAddress == ETHER) {
            address self = address(this); // workaround for a possible solidity bug
            assetBalance = self.balance;
            msg.sender.transfer(assetBalance);
        } else {
            assetBalance = ERC20(_assetAddress).balanceOf(address(this));
            ERC20(_assetAddress).safeTransfer(msg.sender, assetBalance);
        }
        emit LogWithdraw(msg.sender, _assetAddress, assetBalance);
    }
}

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver, Withdrawable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    ILendingPoolAddressesProvider public addressesProvider;

    constructor(address _addressProvider) public {
        addressesProvider = ILendingPoolAddressesProvider(_addressProvider);
    }

    receive() payable external {}

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core, _reserve, _amount);
    }

    function transferInternal(address payable _destination, address _reserve, uint256 _amount) internal {
        if(_reserve == ethAddress) {
            (bool success, ) = _destination.call{value: _amount}("");
            require(success == true, "Couldn't transfer ETH");
            return;
        }
        IERC20(_reserve).safeTransfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {
        if(_reserve == ethAddress) {
            return _target.balance;
        }
        return IERC20(_reserve).balanceOf(_target);
    }
}

contract Flashloan is FlashLoanReceiverBase {

    UniswapFactoryInterface factory;
    address factoryAddress;
    KyberNetworkProxyInterface kyber;
    address kyberAddress;

    address TOKEN_1;
    address TOKEN_2;
    address constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    uint256 amountInput;
    uint256 etherBalancePrior;
    bytes32 arb;

    constructor(address _addressProvider) FlashLoanReceiverBase(_addressProvider) public {
      kyber = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
      factory = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    )
        external
        override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        if (arb[1] == "0") {
          // Part 1
          uint256 token1Amount;
          if (arb[0] == "0") token1Amount = tradeWithKyber(ETH_ADDRESS,TOKEN_1,_amount,false);
          else if (arb[0] == "1") token1Amount = tradeWithUniswap(ETH_ADDRESS,TOKEN_1,_amount,0);

          // Part 2
          uint256 token2Amount;
          if (arb[2] == "0") token2Amount = tradeWithKyber(TOKEN_1,TOKEN_2,token1Amount,true);
          else if (arb[2] == "1") token2Amount = tradeWithUniswap(TOKEN_1,TOKEN_2,token1Amount,1);

          // Part 3
          uint256 finalETH;
          if (arb[4] == "0") finalETH = tradeWithKyber(TOKEN_2,ETH_ADDRESS,token2Amount,true);
          else if (arb[4] == "1") finalETH = tradeWithUniswap(TOKEN_2,ETH_ADDRESS,token2Amount,2);
        }
        else {
          // Part 1
          uint256 token2Amount;
          if (arb[0] == "0") token2Amount = tradeWithKyber(ETH_ADDRESS,TOKEN_2,_amount,false);
          else if (arb[0] == "1") token2Amount = tradeWithUniswap(ETH_ADDRESS,TOKEN_2,_amount,0);

          // Part 2
          uint256 token1Amount;
          if (arb[2] == "0") token1Amount = tradeWithKyber(TOKEN_2,TOKEN_1,token2Amount,true);
          else if (arb[2] == "1") token1Amount = tradeWithUniswap(TOKEN_2,TOKEN_1,token2Amount,1);

          // Part 3
          uint256 finalETH;
          if (arb[4] == "0") finalETH = tradeWithKyber(TOKEN_1,ETH_ADDRESS,token1Amount,true);
          else if (arb[4] == "1") finalETH = tradeWithUniswap(TOKEN_1,ETH_ADDRESS,token1Amount,2);
        }

        uint totalDebt = _amount.add(_fee);
        require(etherBalancePrior <= (address(this).balance - totalDebt), "Did not make a profit.");

        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function flashloan(string memory arbRoute, address token1, address token2, uint256 amount) public onlyOwner {
        etherBalancePrior = address(this).balance;
        TOKEN_1 = token1;
        TOKEN_2 = token2;
        bytes memory params = "";
        arb = stringToBytes32(arbRoute);

        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), ETH_ADDRESS, amount, params); // Flashloan from Aave
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
          return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
    }

    function withdrawETHAndTokens(address tokenToWithdraw) public onlyOwner {
        msg.sender.send(address(this).balance);
        if (tokenToWithdraw == address(0x0)) return;
        ERC20 erc20Token = ERC20(tokenToWithdraw);
        uint256 currentTokenBalance = erc20Token.balanceOf(address(this));
        erc20Token.transfer(msg.sender, currentTokenBalance);
    }

    function getPairExchangeRateKyber(ERC20 tokenA, ERC20 tokenB, uint256 amount) public view returns(uint256,uint256) {
        return kyber.getExpectedRate(tokenA,tokenB,amount);
    }

    function tradeWithKyber(address srcToken, address dstToken, uint256 amount, bool sourceIsToken) private returns(uint256){
      if (sourceIsToken) {
        ERC20 ercSrcToken = ERC20(srcToken);
        ercSrcToken.approve(address(kyber),0);
        ercSrcToken.approve(address(kyber),amount);
      }
      uint256 minReturn;
      (,minReturn) = getPairExchangeRateKyber(ERC20(srcToken),ERC20(dstToken),amount);
      if (sourceIsToken) return kyber.tradeWithHint(ERC20(srcToken),amount,ERC20(dstToken),address(this),9999999999999999999999999999999999999999,minReturn,address(0x0),"");
      else return kyber.tradeWithHint{value: amount}(ERC20(srcToken),amount,ERC20(dstToken),address(this),9999999999999999999999999999999999999999,minReturn,address(0x0),"");
    }

    function tradeWithUniswap(address srcToken, address dstToken, uint256 amount, uint256 method) private returns(uint256){
      if (method == 1) {
        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(srcToken));
        UniswapExchangeInterface exchangeDst = UniswapExchangeInterface(factory.getExchange(dstToken));
        ERC20 ercSrcToken = ERC20(srcToken);
        ercSrcToken.approve(address(exchange),0);
        ercSrcToken.approve(address(exchange),amount);
        return exchange.tokenToExchangeSwapInput(amount,1,1,block.timestamp,address(exchangeDst));
      }
      else if (method == 0) {
        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(dstToken));
        uint256 tokensToBuy = exchange.getEthToTokenInputPrice(amount);
        return exchange.ethToTokenSwapInput{value: amount}(tokensToBuy,now+300);
      }
      else {
        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(srcToken));
        ERC20 ercSrcToken = ERC20(srcToken);
        ercSrcToken.approve(address(exchange),0);
        ercSrcToken.approve(address(exchange),amount);
        return exchange.tokenToEthSwapInput(amount,1,block.timestamp);
      }
    }

    fallback () external payable {}

}