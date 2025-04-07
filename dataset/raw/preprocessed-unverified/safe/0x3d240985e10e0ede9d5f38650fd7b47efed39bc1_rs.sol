/**

 *Submitted for verification at Etherscan.io on 2019-01-31

*/



pragma solidity ^0.5.2;













contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);

        return true;

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);

        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));

        return true;

    }



    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }





    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));

        require(owner != address(0));



        _allowed[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



}



contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



contract SaveWon is ERC20, ERC20Detailed {

    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 5000000000 * (10 ** uint256(DECIMALS));

    constructor () public ERC20Detailed("SaveWon", "SVW", DECIMALS) {

        _mint(msg.sender, INITIAL_SUPPLY);

    }

}