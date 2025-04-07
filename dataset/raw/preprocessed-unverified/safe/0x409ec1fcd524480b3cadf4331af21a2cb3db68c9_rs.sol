/**

 *Submitted for verification at Etherscan.io on 2018-09-15

*/



pragma solidity ^0.4.19;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */













contract ERC20Basic {

    uint256 public totalSupply;

    string public name;

    string public symbol;

    uint8 public decimals;

    function balanceOf(address who) constant public returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}





contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) constant public returns (uint256);

    function transferFrom(address from, address to, uint256 value) public  returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}







contract BasicToken is ERC20Basic {

    

    using SafeMath for uint256;

    

    mapping (address => uint256) internal balances;

    

    /**

    * Returns the balance of the qeuried address

    *

    * @param _who The address which is being qeuried

    **/

    function balanceOf(address _who) public view returns(uint256) {

        return balances[_who];

    }

    

    /**

    * Allows for the transfer of MSTCOIN tokens from peer to peer. 

    *

    * @param _to The address of the receiver

    * @param _value The amount of tokens to send

    **/

    function transfer(address _to, uint256 _value) public returns(bool) {

        require(balances[msg.sender] >= _value && _value > 0 && _to != 0x0);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;

    }

}







contract StandardToken is BasicToken, ERC20 {

    

    mapping (address => mapping (address => uint256)) internal allowances;

    

    /**

    * Returns the amount of tokens one has allowed another to spend on his or her behalf.

    *

    * @param _owner The address which is the owner of the tokens

    * @param _spender The address which has been allowed to spend tokens on the owner's

    * behalf

    **/

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowances[_owner][_spender];

    }

    

    /**

    * Allows for the transfer of tokens on the behalf of the owner given that the owner has

    * allowed it previously. 

    *

    * @param _from The address of the owner

    * @param _to The address of the recipient 

    * @param _value The amount of tokens to be sent

    **/

    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool) {

        require(allowances[_from][msg.sender] >= _value && _to != 0x0 && balances[_from] >= _value && _value > 0);

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;

    }

    

    /**

    * Allows the owner of tokens to approve another to spend tokens on his or her behalf

    *

    * @param _spender The address which is being allowed to spend tokens on the owner' behalf

    * @param _value The amount of tokens to be sent

    **/

    function approve(address _spender, uint256 _value) public returns (bool) {

        require(_spender != 0x0 && _value > 0);

        if(allowances[msg.sender][_spender] > 0 ) {

            allowances[msg.sender][_spender] = 0;

        }

        allowances[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

}





contract BurnableToken is StandardToken, Ownable {

    

    event TokensBurned(address indexed burner, uint256 value);

    

    function burnFrom(address _from, uint256 _tokens) public onlyOwner {

        if(balances[_from] < _tokens) {

            TokensBurned(_from,balances[_from]);

            balances[_from] = 0;

            totalSupply = totalSupply.sub(balances[_from]);

        } else {

            balances[_from] = balances[_from].sub(_tokens);

            totalSupply = totalSupply.sub(_tokens);

            TokensBurned(_from, _tokens);

        }

    }

}





contract Propvesta is BurnableToken {



    string public website = "www.propvesta.com";

    

    function Propvesta() public {

        name = "Propvesta";

        symbol = "PROV";

        decimals = 18;

        totalSupply = 10000000000e18;

        balances[owner] = 7000000000e18;

        Transfer(address(this), owner, 7000000000e18);

        balances[0x304f970BaA307238A6a4F47caa9e0d82F082e3AD] = 2000000000e18;

        Transfer(address(this), 0x304f970BaA307238A6a4F47caa9e0d82F082e3AD, 2000000000e18);

        balances[0x19294ceEeA1ae27c571a1C6149004A9f143e1aA5] = 1000000000e18;

        Transfer(address(this), 0x19294ceEeA1ae27c571a1C6149004A9f143e1aA5, 1000000000e18);

    }

}