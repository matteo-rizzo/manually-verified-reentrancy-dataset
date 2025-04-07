/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.6.0;



contract TokenERC20 {
    
    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    uint8 public decimals = 10;
    uint256 public totalSupply;
    
    address payable public creator;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
        creator = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[creator] = totalSupply;  
        name = tokenName;                     
        symbol = tokenSymbol;                
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0), "Cannot send token to ZERO address!");
        require(_value > 0 && _value <= totalSupply, "Invalid token amount to transfer!");
        
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public  returns (bool) {
        _transfer(msg.sender, _to, _value);
       return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "Invalid token amount to transfer from!");
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        // prevent state race attack
        require((allowance[msg.sender][_spender] == 0) || (_value == 0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
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