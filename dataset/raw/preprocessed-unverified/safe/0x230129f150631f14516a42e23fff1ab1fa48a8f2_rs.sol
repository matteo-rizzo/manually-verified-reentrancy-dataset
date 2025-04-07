/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.5.0;







contract OjirehToken is ERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    constructor() public {
        decimals = 8;
        _totalSupply = 250000000e8;
        _balances[msg.sender] = _totalSupply;
        name = "Ojireh Token";
        symbol = "OJH";
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(
        address owner,
        address spender
        )
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
        )
        public
        returns (bool)
    {
        require(value <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function burn(uint256 value) public {
        require(value <= _balances[msg.sender]);

        _totalSupply = _totalSupply.sub(value);
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        emit Transfer(msg.sender, address(0), value);
    }
    
        // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }

}