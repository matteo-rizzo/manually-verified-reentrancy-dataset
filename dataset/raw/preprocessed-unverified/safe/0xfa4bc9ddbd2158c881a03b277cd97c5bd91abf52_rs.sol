/**

 *Submitted for verification at Etherscan.io on 2018-08-31

*/



pragma solidity ^0.4.24;



// ----------------------------------------------------------------------------

// Ceito Token Contract

// ----------------------------------------------------------------------------





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

  function totalSupply() public view returns (uint256);



  function balanceOf(address _who) public view returns (uint256);



  function allowance(address _owner, address _spender) public view returns (uint256);



  function transfer(address _to, uint256 _value) public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);



  event Transfer(address indexed from, address indexed to, uint256 value);



  event Approval(address indexed owner, address indexed spender, uint256 value);

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

//  Detailed ERC20 Token with a fixed supply

// ----------------------------------------------------------------------------

contract CeitoToken is ERC20, Owned {

    using SafeMath for uint256;



    string public symbol = "CEITO";

    string public  name = "Ceito Token";

    uint8 public decimals = 0;

    uint256 _totalSupply = 1000000000;



    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) internal allowed;



	

	// ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }

	



    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint256) {

        return _totalSupply.sub(balances[address(0)]);

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public view returns (uint256 balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint256 tokens) public returns (bool success) {

        require(to != address(0));

        require(tokens <= balances[msg.sender]);



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

    function approve(address spender, uint256 tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Token owner can increase the allowance amount that was approved

    // for `spender` to transferFrom(...) `tokens` from the token owner's account

    // ------------------------------------------------------------------------

    function increaseApproval(address spender, uint256 addedValue) public returns (bool success){

        allowed[msg.sender][spender] = (allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

        return true;

    }





    // ------------------------------------------------------------------------

    // Token owner can decrease the allowance amount that was approved

    // for `spender` to transferFrom(...) `tokens` from the token owner's account

    // ------------------------------------------------------------------------

    function decreaseApproval(address spender, uint256 subtractedValue) public returns (bool success)

    {

        uint256 oldValue = allowed[msg.sender][spender];

        if (subtractedValue > oldValue) {

            allowed[msg.sender][spender] = 0;

        } else {

            allowed[msg.sender][spender] = oldValue.sub(subtractedValue);

        }

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

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

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {

        require(to != address(0));

        require(tokens <= balances[from]);

        require(tokens <= allowed[from][msg.sender]);



        balances[from] = balances[from].sub(tokens);

        balances[to] = balances[to].add(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {

        return allowed[tokenOwner][spender];

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account. The `spender` contract function

    // `receiveApproval(...)` is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint256 tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }





    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function() public payable {

        revert();

    }





    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {

        return ERC20(tokenAddress).transfer(owner, tokens);

    }

}