/**

 *Submitted for verification at Etherscan.io on 2019-06-05

*/



pragma solidity 0.5.8;



/**

 * @title SafeMath 

 * @dev Unsigned math operations with safety checks that revert on error.

 */





/**

 * @title ERC20 interface

 * @dev See https://eips.ethereum.org/EIPS/eip-20

 */













contract DUSDToken is IERC20, Ownable {

    using SafeMath for uint256;

    TokenStore public tokenInstance;

    event Pause();

    event Unpause();



    /**

     * @dev Set '_owner' to a speicified address.

     * This owner just used for the 'kill' function.

     */

    constructor() public {

        _owner = 0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1;

    }

    

    

    /**

     * contract only can initialized once 

     */

    bool private initialized = false;



    /**

     * @dev Set 0 initials tokens, the owner.

     * this serves as the constructor for the proxy.

     */

    function initialize(TokenStore token_instance) public {

        require(!initialized, "already initialized");

        tokenInstance = token_instance;

        _owner = 0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1;

        initialized = true;

    }



    

    /**

     * @dev See `IERC20.totalSupply`.

     */

    function totalSupply() public view returns (uint256) {

        return tokenInstance.getTotalSupply();

    }



    /**

     * @dev See `IERC20.balanceOf`.

     */

    function balanceOf(address account) public view returns (uint256) {

        return tokenInstance.getBalance(account);

    }

    

    function name() public view returns (string memory) {

        return tokenInstance.getTokenName();

    }

    

    function symbol() public view returns (string memory) {

        return tokenInstance.getSymbol();

    }

    

    function decimals() public view returns (uint8) {

        return tokenInstance.getDecimals();

    }



    function kill() public onlyOwner {

        selfdestruct(msg.sender);

    }

    

    modifier whenNotPaused() {

        require(!tokenInstance.getPaused(), "Only when the contract is not paused");

        _;

    }



    modifier whenPaused() {

        require(tokenInstance.getPaused(), "Only when the contract is paused");

        _;

    }





    function pause() public onlyOwner whenNotPaused {

        tokenInstance.pause();

        emit Pause();

    }

    

    function unpause() public onlyOwner whenPaused {

        tokenInstance.unpause();

        emit Unpause();

    }

    

    function pauseStatus() public view returns (bool) {

        return tokenInstance.getPaused();

    }

    

    function addToBlackList(address user) public onlyOwner {

        tokenInstance.addBlackList(user);

    }



    function removeToBlackList(address user) public onlyOwner {

        tokenInstance.removeBlackList(user);

    }



    function isBlackList(address user) public view returns (bool) {

        return tokenInstance.isBlackList(user);

    }



    /**

     * @dev See `IERC20.transfer`.

     *

     * Requirements:

     *

     * - `recipient` cannot be the zero address.

     * - the caller must have a balance of at least `amount`.

     */

    function transfer(address recipient, uint256 amount) whenNotPaused public returns (bool) {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    /**

     * @dev See `IERC20.allowance`.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return tokenInstance.getAllowance(owner, spender);

    }



    /**

     * @dev See `IERC20.approve`.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 value) whenNotPaused public returns (bool) {

        _approve(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev See `IERC20.transferFrom`.

     *

     * Emit an `Approval` event indicating the updated allowance. This is not

     * required by the EIP. See the note at the beginning of `ERC20`;

     *

     * Requirements:

     * - `sender` and `recipient` cannot be the zero address.

     * - `sender` must have a balance of at least `value`.

     * - the caller must have allowance for `sender`'s tokens of at least

     * `amount`.

     */

    function transferFrom(address sender, address recipient, uint256 amount) whenNotPaused public returns (bool) {

        require(!isBlackList(msg.sender), "Black List: Msg.sender is in blacklist");

        _transfer(sender, recipient, amount);

        tokenInstance.subAllowance(sender, msg.sender, amount);

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

    function increaseAllowance(address spender, uint256 addedValue) whenNotPaused public returns (bool) {

        _approve(msg.sender, spender, tokenInstance.getAllowance(msg.sender, spender).add(addedValue));

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

    function decreaseAllowance(address spender, uint256 subtractedValue) whenNotPaused public returns (bool) {

        _approve(msg.sender, spender, tokenInstance.getAllowance(msg.sender, spender).sub(subtractedValue));

        return true;

    }



     function mint(address account, uint256 amount) public onlyOwner returns (bool) {

        _mint(account, amount);

        return true;

    }



    function burn(uint256 amount) public whenNotPaused returns (bool) {

        _burn(msg.sender, amount);

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

        require(sender != address(0), "ERC20: Transfer from the zero address");

        require(recipient != address(0), "ERC20: Transfer to the zero address");

        require(!isBlackList(sender), "Black List: Sender is in blacklist");

        require(!isBlackList(recipient), "Black List: Recipient is in blacklist");

        tokenInstance.subBalance(sender, amount);

        tokenInstance.addBalance(recipient, amount);

        emit Transfer(sender, recipient, amount);

    }



    /** @dev Create `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a `Transfer` event with `from` set to the zero address.

     *

     * Requirements

     *

     * - `to` cannot be the zero address.

     */

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: Mint to the zero address");

        require(!isBlackList(account), "Black List: Recipient is in blacklist");

        tokenInstance.addTotalSupply(amount);

        tokenInstance.addBalance(account, amount);

        emit Transfer(address(0), account, amount);

    }



     /**

     * @dev Destroy `amount` tokens from `account`, reducing the

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

        tokenInstance.subBalance(account, value);

        tokenInstance.subTotalSupply(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Set `amount` as the allowance of `spender` over the `owner`s tokens.

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

        require(owner != address(0), "ERC20: Approve from the zero address");

        require(spender != address(0), "ERC20: Approve to the zero address");

        require(!isBlackList(owner), "Black List: owner is in blacklist");

        require(!isBlackList(spender), "Black List: spender is in blacklist");

        tokenInstance.setAllowance(owner, spender, value);

        emit Approval(owner, spender, value);

    }

}