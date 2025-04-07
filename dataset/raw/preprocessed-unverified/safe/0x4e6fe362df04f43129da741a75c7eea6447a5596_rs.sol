/**
 *Submitted for verification at Etherscan.io on 2020-10-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;




/******************************************/
/*      TOKEN INSTANCE STARTS HERE       */
/******************************************/

contract Token {
    
    using SafeMath for uint256;
    
    //variables of the token, EIP20 standard
    string public name = "Exodus Computing Networks";
    string public symbol = "DUS";
    uint256 public decimals = 10; // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply = uint256(330000000).mul(uint256(10) ** decimals);
    
    address ZERO_ADDR = address(0x0000000000000000000000000000000000000000);
    address payable public creator; // for destruct contract

    // mapping structure
    mapping (address => uint256) public balanceOf;  //eip20
    mapping (address => mapping (address => uint256)) public allowance; //eip20

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 token);  //eip20
    event Approval(address indexed owner, address indexed spender, uint256 token);   //eip20
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    // constructor (string memory _name, string memory _symbol, uint256 _total, uint256 _decimals) public {
    constructor () public {
        // name = _name;
        // symbol = _symbol;
        // totalSupply = _total.mul(uint256(10) ** _decimals);
        // decimals = _decimals;
        creator = msg.sender;
        balanceOf[creator] = totalSupply;
        emit Transfer(ZERO_ADDR, msg.sender, totalSupply);
    }
    
    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        // prevent 0 and attack!
        require(_value > 0 && _value <= totalSupply, 'Invalid token amount to transfer!');

        require(_to != ZERO_ADDR, 'Cannot send to ZERO address!'); 
        require(_from != _to, "Cannot send token to yourself!");
        require (balanceOf[_from] >= _value, "No enough token to transfer!");   

        // update balance before transfer
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 token) public returns (bool success) {
        return _transfer(msg.sender, to, token);
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 token) public returns (bool success) {
        require(spender != ZERO_ADDR);
        require(balanceOf[msg.sender] >= token, "No enough balance to approve!");
        // prevent state race attack
        require(allowance[msg.sender][spender] == 0 || token == 0, "Invalid allowance state!");
        allowance[msg.sender][spender] = token;
        emit Approval(msg.sender, spender, token);
        return true;
    }
	
    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 token) public returns (bool success) {
        require(allowance[from][msg.sender] >= token, "No enough allowance to transfer!");
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(token);
        _transfer(from, to, token);
        return true;
    }
    
    //destroy this contract
    function destroy() public {
        require(msg.sender == creator, "You're not creator!");
        selfdestruct(creator);
    }

    //Fallback: reverts if Ether is sent to this smart contract by mistake
    fallback() external {
  	    revert();
    }
}