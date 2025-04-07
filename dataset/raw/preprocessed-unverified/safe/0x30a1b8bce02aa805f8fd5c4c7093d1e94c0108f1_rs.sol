/**
 *Submitted for verification at Etherscan.io on 2021-06-24
*/

pragma solidity =0.6.6;





contract PokemonToken is IERC20 {
    using SafeMath for uint;

    string public override constant name = "Pokemon Token";
    string public override constant symbol = "PKT";
    uint8 public override constant decimals = 18;
    uint  public override totalSupply ;
    uint private _init = 5000 * 10**4 * 10**18;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;


    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        _mint(msg.sender, _init);
    }

    function _mint(address to, uint value) private  {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

}