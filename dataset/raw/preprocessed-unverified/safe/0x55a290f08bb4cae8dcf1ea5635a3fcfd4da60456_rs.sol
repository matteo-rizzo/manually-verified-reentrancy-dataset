pragma solidity 0.7.1;

    

    


    abstract contract ApproveAndCallFallBack {
        function receiveApproval(address from, uint256 tokens, address token, bytes memory data) virtual public;
    }

    

    contract BITTO is ERC20Interface, Owned {
        using SafeMath for uint;

        string public symbol;
        string public  name;
        uint8 public decimals;
        uint _totalSupply;

        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowed;

        constructor() public {
            symbol = "BITTO";
            name = "BITTO";
            decimals = 18;
            _totalSupply = 17709627 * 10**uint(decimals);
            balances[owner] = _totalSupply;
            emit Transfer(address(0), owner, _totalSupply);
        }

        function totalSupply() public view override returns (uint) {
            return _totalSupply.sub(balances[address(0)]);
        }

        function balanceOf(address tokenOwner) public view override returns (uint balance) {
            return balances[tokenOwner];
        }

        function transfer(address to, uint tokens) public override returns (bool success) {
            balances[msg.sender] = balances[msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(msg.sender, to, tokens);
            return true;
        }

        function approve(address spender, uint tokens) public override returns (bool success) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }

        function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
            balances[from] = balances[from].sub(tokens);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(from, to, tokens);
            return true;
        }


        function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
            return allowed[tokenOwner][spender];
        }


        function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
            return true;
        }

        fallback () external {
            revert();
        }


        function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
            return ERC20Interface(tokenAddress).transfer(owner, tokens);
        }
    }