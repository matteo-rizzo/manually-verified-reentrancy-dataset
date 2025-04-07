/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;





contract VTNG is IERC20 {
    using SafeMath for uint256;

    string public name = "Voting International Blockchain Platform";
    string public symbol = "VTNG";
    uint8 public decimals = 8;
    uint256 public _totalSupply = 270000000000000000;

    address owner;
    modifier ownerOnly {
        require(msg.sender == owner, "OWNER ONLY");
        _;
    }

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner)
        public
        override
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender)
        public
        override
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function mint(uint256 amount) public ownerOnly {
        _totalSupply = _totalSupply.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint256 amount) public ownerOnly {
        _totalSupply = _totalSupply.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}