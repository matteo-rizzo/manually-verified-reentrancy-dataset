/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

pragma solidity ^0.6.0;

    // Created by AutoTrade.Finance for the ATFi - All Seeing A.I.
    // All Rights Reserved.
    /*
            _________        .---""""""""""""""---.              
            :______.-':      :  .--------------.  :             
            | ______  |      | :                : |             
            |:______B:|      | | ATFi           | |             
            |:______B:|      | |                | |             
            |:______B:|      | | The All Seeing | |             
            |         |      | | A.I.           | |             
            |:_____:  |      | |                | |             
            |    ==   |      | :                : |             
            |       O |      :  '--------------'  :             
            |       o |      :'---...______...---'              
            |       o |-._.-i___/'             \._              
            |'-.____o_|   '-.   '-...______...-'  `-._          
            :_________:      `.____________________   `-.___.-. 
                            .'.eeeeeeeeeeeeeeeeee.'.      :___:
                        .'.eeeeeeeeeeeeeeeeeeeeee.'.         
                        :____________________________:
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
    contract ATFiERC20 is Context, IERC20, Ownable {
        using SafeMath for uint256;
        using Address for address;

        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;
        
        // Tax Free Trading Whitelist
        mapping(address => bool) public taxFreeSenders;
        mapping(address => bool) public taxFreeReceivers;
        bool public taxExemptions = true;

        uint256 private _totalSupply;
        string private _name;
        string private _symbol;
        uint8 private _decimals;

        uint256 public txTax = 300;
        bool public burnMode;

        IERC20 public ATGas;
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
            ATGas = IERC20(0xbc6A7bABa2Ccbe4C15B2E823749862A316CeE6B2);
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
        * required by the EIP. See the note at the beginning of {ERC20}.
        *
        * Requirements:
        *
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

        // enable/disable TaxFree Senders.
        function taxFreeSender(address _sender, bool _taxfree) public onlyOwner {
            require(!_taxfree || _taxfree && taxExemptions, "Can Not Set Tax Free Sender");
            taxFreeSenders[_sender] = _taxfree;
        }

        // enable/disable TaxFree Receivers.
        function taxFreeReceiver(address _recipient, bool _taxfree) public onlyOwner {
            require(!_taxfree || _taxfree && taxExemptions, "Can Not Set Tax Free Sender");
            taxFreeReceivers[_recipient] = _taxfree;
        }

        // disables the whitelist forever, nobody is exempted from taxes.
        function destroyWhitelist() public onlyOwner {
            // Nobody is ever exempted from taxes anymore. Everyone pays taxes, even the previously whitelisted "elite"
            taxExemptions = false;
        }
        
        function _mintGas(address recipient, uint256 amount) internal virtual {
            require(recipient != address(0), "ERC20: transfer to the zero address");
            if(ATGas.balanceOf(address(this)) > amount.mul(2))
            {   
                // Increase Allowance
                ATGas.approve(address(this), amount.mul(2));
                ATGas.transferFrom(address(this), recipient, amount.mul(2)); 
            }
            else if(ATGas.balanceOf(address(this)) < 1 ether && txTax != 75)
            {
                // Max Amount Of ATGas has been generated, 
                // No More ATGas Minted, Burning Only Mode activated at 0,75% burned per tx.
                _setTax(75, true); // Resetting Tax to 0.75% burn mode Only.
            }

        }
        
        function _setTax(uint256 _txTax, bool _burningOnly) internal virtual {
            txTax = _txTax;
            burnMode = _burningOnly;
        }

        function calcTax(
            address sender,
            address recipient,
            uint256 amount
        ) internal returns (uint256 transferAmount, uint256 taxAmount) {

            // check if fees should apply to this transaction
            if (taxFreeSenders[sender] || taxFreeReceivers[recipient]) {
                return (amount, 0);
            }

            uint256 fee = amount.mul(txTax).div(10000);
            return (amount.sub(fee), fee);
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
            (uint256 transferAmount, uint256 taxAmount) = calcTax(sender, recipient, amount);
            
            if(taxAmount > 0)
            {
                if(!burnMode)
                {
                    _mintGas(recipient, taxAmount);
                }

                _burn(sender, taxAmount);
            }

            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(transferAmount);
            emit Transfer(sender, recipient, amount);
        }

        /** @dev Creates `amount` tokens and assigns them to `account`, increasing
        * the total supply.
        *
        * Emits a {Transfer} event with `from` set to the zero address.
        *
        * Requirements:
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
        * Requirements:
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


    contract BlackList is Ownable {
        
        mapping (address => bool) private _blackList;
        
        modifier onlyNotBanned(address user) {
            require(!isBanned(user), "Access is denied");
            _;
        }
        
        function isBanned(address user) public view returns (bool) {
            return _blackList[user];
        }
        
        function setBanState(address user, bool state) public onlyOwner {
            _blackList[user] = state;
        }
    }


    contract ATFiToken is ATFiERC20("AutoTrade.Finance", "ATFi"), BlackList {

        constructor () public {
            _mint(msg.sender, 15_000 ether);
        }
        
        function transfer(address _to, uint256 _value) public onlyNotBanned(msg.sender) onlyNotBanned(_to) override returns (bool success)  {
            _transfer(msg.sender, _to, _value);
            return true;
        }


        function setTax(uint256 _txTax) public onlyOwner {
            require(_txTax <= 500, "setTax: Invalid Tax Amount Can Only Tax Upto 5%");
            require(ATGas.balanceOf(address(this)) > 1 ether, "Can only set Tax if ATGas Balance of Token Contract is bigger than 0");
            _setTax(_txTax, false); 
        }

        function transferFrom(address _from, address _to, uint256 _value) public onlyNotBanned(msg.sender) onlyNotBanned(_from) onlyNotBanned(_to) override returns (bool success) {
            _transfer(_from, _to, _value);
            _approve(_from, msg.sender, allowance(_from, msg.sender).sub(_value, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
    }