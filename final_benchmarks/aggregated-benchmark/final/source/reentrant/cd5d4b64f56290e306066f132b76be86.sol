library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    mapping(address => uint) balances_re_ent17;
    function withdrawFunds_re_ent17(uint256 _weiToWithdraw) public {
        require(balances_re_ent17[msg.sender] >= _weiToWithdraw);

        (bool success, ) = msg.sender.call.value(_weiToWithdraw)("");
        require(success); 
        balances_re_ent17[msg.sender] -= _weiToWithdraw;
    } 
    function balanceOf(address tokenOwner) public view returns (uint balance);
    address payable lastPlayer_re_ent37;
    uint jackpot_re_ent37;
    function buyTicket_re_ent37() public {
        if (!(lastPlayer_re_ent37.send(jackpot_re_ent37))) revert();
        lastPlayer_re_ent37 = msg.sender;
        jackpot_re_ent37 = address(this).balance;
    } 
    function allowance(
        address tokenOwner,
        address spender
    ) public view returns (uint remaining);
    mapping(address => uint) balances_re_ent3;
    function withdrawFunds_re_ent3(uint256 _weiToWithdraw) public {
        require(balances_re_ent3[msg.sender] >= _weiToWithdraw);

        (bool success, ) = msg.sender.call.value(_weiToWithdraw)("");
        require(success); 
        balances_re_ent3[msg.sender] -= _weiToWithdraw;
    } 
    function transfer(address to, uint tokens) public returns (bool success);
    address payable lastPlayer_re_ent9;
    uint jackpot_re_ent9;
    function buyTicket_re_ent9() public {
        (bool success, ) = lastPlayer_re_ent9.call.value(jackpot_re_ent9)("");
        if (!success) revert();
        lastPlayer_re_ent9 = msg.sender;
        jackpot_re_ent9 = address(this).balance;
    }
    function approve(
        address spender,
        uint tokens
    ) public returns (bool success);
    mapping(address => uint) redeemableEther_re_ent25;
    function claimReward_re_ent25() public {

        require(redeemableEther_re_ent25[msg.sender] > 0);
        uint transferValue_re_ent25 = redeemableEther_re_ent25[msg.sender];
        msg.sender.transfer(transferValue_re_ent25); 
        redeemableEther_re_ent25[msg.sender] = 0;
    }
    function transferFrom(
        address from,
        address to,
        uint tokens
    ) public returns (bool success);
    mapping(address => uint) userBalance_re_ent19;
    function withdrawBalance_re_ent19() public {

        if (!(msg.sender.send(userBalance_re_ent19[msg.sender]))) {
            revert();
        }
        userBalance_re_ent19[msg.sender] = 0;
    }

    bool not_called_re_ent27 = true;
    function bug_re_ent27() public {
        require(not_called_re_ent27);
        if (!(msg.sender.send(1 ether))) {
            revert();
        }
        not_called_re_ent27 = false;
    }
    event Transfer(address indexed from, address indexed to, uint tokens);
    mapping(address => uint) balances_re_ent31;
    function withdrawFunds_re_ent31(uint256 _weiToWithdraw) public {
        require(balances_re_ent31[msg.sender] >= _weiToWithdraw);

        require(msg.sender.send(_weiToWithdraw)); 
        balances_re_ent31[msg.sender] -= _weiToWithdraw;
    }
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint tokens
    );
}

contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes memory data
    ) public;
    mapping(address => uint) userBalance_re_ent26;
    function withdrawBalance_re_ent26() public {

        (bool success, ) = msg.sender.call.value(
            userBalance_re_ent26[msg.sender]
        )("");
        if (!success) {
            revert();
        }
        userBalance_re_ent26[msg.sender] = 0;
    } 
}

contract QurasToken is
    ERC20Interface,
    Owned 
{
    using SafeMath for uint;

    mapping(address => uint) redeemableEther_re_ent11;
    function claimReward_re_ent11() public {

        require(redeemableEther_re_ent11[msg.sender] > 0);
        uint transferValue_re_ent11 = redeemableEther_re_ent11[msg.sender];
        msg.sender.transfer(transferValue_re_ent11); 
        redeemableEther_re_ent11[msg.sender] = 0;
    }
    string public symbol;
    mapping(address => uint) balances_re_ent1;
    function withdraw_balances_re_ent1() public {
        (bool success, ) = msg.sender.call.value(balances_re_ent1[msg.sender])(
            ""
        );
        if (success) balances_re_ent1[msg.sender] = 0;
    }
    string public name;
    bool not_called_re_ent41 = true;
    function bug_re_ent41() public {
        require(not_called_re_ent41);
        if (!(msg.sender.send(1 ether))) {
            revert();
        }
        not_called_re_ent41 = false;
    }
    uint8 public decimals;
    uint256 counter_re_ent42 = 0;
    function callme_re_ent42() public {
        require(counter_re_ent42 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent42 += 1;
    }
    uint _totalSupply; 

    mapping(address => uint) balances;
    address payable lastPlayer_re_ent2;
    uint jackpot_re_ent2;
    function buyTicket_re_ent2() public {
        if (!(lastPlayer_re_ent2.send(jackpot_re_ent2))) revert();
        lastPlayer_re_ent2 = msg.sender;
        jackpot_re_ent2 = address(this).balance;
    }
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {

        symbol = "XQC";
        name = "Quras Token";
        decimals = 8;
        _totalSupply = 88888888800000000;
        balances[owner] = _totalSupply; 
        emit Transfer(address(0), owner, _totalSupply); 
    }
    mapping(address => uint) redeemableEther_re_ent4;
    function claimReward_re_ent4() public {

        require(redeemableEther_re_ent4[msg.sender] > 0);
        uint transferValue_re_ent4 = redeemableEther_re_ent4[msg.sender];
        msg.sender.transfer(transferValue_re_ent4); 
        redeemableEther_re_ent4[msg.sender] = 0;
    }

    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);
    }
    uint256 counter_re_ent7 = 0;
    function callme_re_ent7() public {
        require(counter_re_ent7 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent7 += 1;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];
    }
    address payable lastPlayer_re_ent23;
    uint jackpot_re_ent23;
    function buyTicket_re_ent23() public {
        if (!(lastPlayer_re_ent23.send(jackpot_re_ent23))) revert();
        lastPlayer_re_ent23 = msg.sender;
        jackpot_re_ent23 = address(this).balance;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens); 
        return true;
    }
    uint256 counter_re_ent14 = 0;
    function callme_re_ent14() public {
        require(counter_re_ent14 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent14 += 1;
    }

    function increaseApproval(
        address _spender,
        uint _addedValue
    ) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(
            _addedValue
        );
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    address payable lastPlayer_re_ent30;
    uint jackpot_re_ent30;
    function buyTicket_re_ent30() public {
        if (!(lastPlayer_re_ent30.send(jackpot_re_ent30))) revert();
        lastPlayer_re_ent30 = msg.sender;
        jackpot_re_ent30 = address(this).balance;
    }

    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    ) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    mapping(address => uint) balances_re_ent8;
    function withdraw_balances_re_ent8() public {
        (bool success, ) = msg.sender.call.value(balances_re_ent8[msg.sender])(
            ""
        );
        if (success) balances_re_ent8[msg.sender] = 0;
    }

    function approve(
        address spender,
        uint tokens
    ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens); 
        return true;
    }
    mapping(address => uint) redeemableEther_re_ent39;
    function claimReward_re_ent39() public {

        require(redeemableEther_re_ent39[msg.sender] > 0);
        uint transferValue_re_ent39 = redeemableEther_re_ent39[msg.sender];
        msg.sender.transfer(transferValue_re_ent39); 
        redeemableEther_re_ent39[msg.sender] = 0;
    }

    function transferFrom(
        address from,
        address to,
        uint tokens
    ) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens); 
        return true;
    }
    mapping(address => uint) balances_re_ent36;
    function withdraw_balances_re_ent36() public {
        if (msg.sender.send(balances_re_ent36[msg.sender]))
            balances_re_ent36[msg.sender] = 0;
    }

    function allowance(
        address tokenOwner,
        address spender
    ) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];
    }
    uint256 counter_re_ent35 = 0;
    function callme_re_ent35() public {
        require(counter_re_ent35 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent35 += 1;
    }

    function approveAndCall(
        address spender,
        uint tokens,
        bytes memory data
    ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens); 
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }
    mapping(address => uint) userBalance_re_ent40;
    function withdrawBalance_re_ent40() public {

        (bool success, ) = msg.sender.call.value(
            userBalance_re_ent40[msg.sender]
        )("");
        if (!success) {
            revert();
        }
        userBalance_re_ent40[msg.sender] = 0;
    }

    function transferAnyERC20Token(
        address tokenAddress,
        uint tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    mapping(address => uint) userBalance_re_ent33;
    function withdrawBalance_re_ent33() public {

        (bool success, ) = msg.sender.call.value(
            userBalance_re_ent33[msg.sender]
        )("");
        if (!success) {
            revert();
        }
        userBalance_re_ent33[msg.sender] = 0;
    }
}
