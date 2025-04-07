/**

 *Submitted for verification at Etherscan.io on 2019-01-15

*/



pragma solidity ^0.4.24;



// ---------------------------------------------------------------------------- 

// Symbol      : UBTR

// Name        : OBETR.COM

// Total supply: 12,000,000,000

// Decimals    : 18 

// ----------------------------------------------------------------------------

//https://remix.ethereum.org/#optimize=true&version=soljson-v0.4.24+commit.e67f0147.js

//





// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------









// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





// ----------------------------------------------------------------------------

// Contract function to receive approval and execute function in one call

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

 



// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and a

// fixed supply

// ----------------------------------------------------------------------------

contract FixedSupplyToken is ERC20Interface, Owned {

    using SafeMath for uint;



    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply; 

    

    bool public crowdsaleEnabled;

    uint public ethPerToken;

    uint public bonusMinEth;

    uint public bonusPct; 



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    

    // ------------------------------------------------------------------------

    // Custom Events

    // ------------------------------------------------------------------------

    event Burn(address indexed from, uint256 value);

    event Bonus(address indexed from, uint256 value); 





    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        symbol = "UBTR";

        name = "UBETR";

        decimals = 18;

        _totalSupply = 12000000000000000000000000000;





        crowdsaleEnabled = false;

        ethPerToken = 20000;

        bonusMinEth = 0;

        bonusPct = 0; 



        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }





    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account

    //

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

    // recommends that there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces 

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Transfer `tokens` from the `from` account to the `to` account

    // 

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account. The `spender` contract function

    // `receiveApproval(...)` is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }





    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }





    // ------------------------------------------------------------------------

    // Crowdsale 

    // ------------------------------------------------------------------------

    function () public payable {

        //crowd sale is open/allowed

        require(crowdsaleEnabled); 

        

        uint ethValue = msg.value;

        

        //get token equivalent

        uint tokens = ethValue.mul(ethPerToken);



        

        //append bonus if we have active bonus promo

        //and if ETH sent is more than then minimum required to avail bonus

        if(bonusPct > 0 && ethValue >= bonusMinEth){

            //compute bonus value based on percentage

            uint bonus = tokens.div(100).mul(bonusPct);

            

            //emit bonus event

            emit Bonus(msg.sender, bonus);

            

            //add bonus to final amount of token to be 

            //transferred to sender/purchaser

            tokens = tokens.add(bonus);

        }

        

        

        //validate token amount 

        //assert(tokens > 0);

        //assert(tokens <= balances[owner]);  

        



        //transfer from owner to sender/purchaser

        balances[owner] = balances[owner].sub(tokens);

        balances[msg.sender] = balances[msg.sender].add(tokens);

        

        //emit transfer event

        emit Transfer(owner, msg.sender, tokens);

    } 





    // ------------------------------------------------------------------------

    // Open the token for Crowdsale 

    // ------------------------------------------------------------------------

    function enableCrowdsale() public onlyOwner{

        crowdsaleEnabled = true; 

    }





    // ------------------------------------------------------------------------

    // Close the token for Crowdsale 

    // ------------------------------------------------------------------------

    function disableCrowdsale() public onlyOwner{

        crowdsaleEnabled = false; 

    }





    // ------------------------------------------------------------------------

    // Set the token price.  

    // ------------------------------------------------------------------------

    function setTokenPrice(uint _ethPerToken) public onlyOwner{ 

        ethPerToken = _ethPerToken;

    } 





    // ------------------------------------------------------------------------

    // Set crowdsale bonus percentage and its minimum

    // ------------------------------------------------------------------------

    function setBonus(uint _bonusPct, uint _minEth) public onlyOwner {

        bonusMinEth = _minEth;

        bonusPct = _bonusPct;

    }





    // ------------------------------------------------------------------------

    // Burn token

    // ------------------------------------------------------------------------

    function burn(uint256 _value) public onlyOwner {

        require(_value > 0);

        require(_value <= balances[msg.sender]); 



        address burner = msg.sender;

        

        //deduct from initiator's balance

        balances[burner] = balances[burner].sub(_value);

        

        //deduct from total supply

        _totalSupply = _totalSupply.sub(_value);

        

        emit Burn(burner, _value); 

    } 





    // ------------------------------------------------------------------------

    // Withdraw

    // ------------------------------------------------------------------------ 

    function withdraw(uint _amount) onlyOwner public {

        require(_amount > 0);

        

        // Amount withdraw should be less or equal to balance

        require(_amount <= address(this).balance);     

        

        owner.transfer(_amount);

    }





}