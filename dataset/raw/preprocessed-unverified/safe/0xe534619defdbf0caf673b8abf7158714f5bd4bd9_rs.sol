pragma solidity 0.4.18;



/// @title Math library - Allows calculation of logarithmic and exponential functions

/// @author Alan Lu - <[email protected]>

/// @author Stefan George - <[email protected]>





/// @title Abstract token contract - Functions to be implemented by token contracts

contract Token {



    /*

     *  Events

     */

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);



    /*

     *  Public functions

     */

    function transfer(address to, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function balanceOf(address owner) public constant returns (uint);

    function allowance(address owner, address spender) public constant returns (uint);

    function totalSupply() public constant returns (uint);

}





/// @title Standard token contract with overflow protection

contract StandardToken is Token {

    using Math for *;



    /*

     *  Storage

     */

    mapping (address => uint) balances;

    mapping (address => mapping (address => uint)) allowances;

    uint totalTokens;



    /*

     *  Public functions

     */

    /// @dev Transfers sender's tokens to a given address. Returns success

    /// @param to Address of token receiver

    /// @param value Number of tokens to transfer

    /// @return Was transfer successful?

    function transfer(address to, uint value)

        public

        returns (bool)

    {

        if (   !balances[msg.sender].safeToSub(value)

            || !balances[to].safeToAdd(value))

            return false;

        balances[msg.sender] -= value;

        balances[to] += value;

        Transfer(msg.sender, to, value);

        return true;

    }



    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success

    /// @param from Address from where tokens are withdrawn

    /// @param to Address to where tokens are sent

    /// @param value Number of tokens to transfer

    /// @return Was transfer successful?

    function transferFrom(address from, address to, uint value)

        public

        returns (bool)

    {

        if (   !balances[from].safeToSub(value)

            || !allowances[from][msg.sender].safeToSub(value)

            || !balances[to].safeToAdd(value))

            return false;

        balances[from] -= value;

        allowances[from][msg.sender] -= value;

        balances[to] += value;

        Transfer(from, to, value);

        return true;

    }



    /// @dev Sets approved amount of tokens for spender. Returns success

    /// @param spender Address of allowed account

    /// @param value Number of approved tokens

    /// @return Was approval successful?

    function approve(address spender, uint value)

        public

        returns (bool)

    {

        allowances[msg.sender][spender] = value;

        Approval(msg.sender, spender, value);

        return true;

    }



    /// @dev Returns number of allowed tokens for given address

    /// @param owner Address of token owner

    /// @param spender Address of token spender

    /// @return Remaining allowance for spender

    function allowance(address owner, address spender)

        public

        constant

        returns (uint)

    {

        return allowances[owner][spender];

    }



    /// @dev Returns number of tokens owned by given address

    /// @param owner Address of token owner

    /// @return Balance of owner

    function balanceOf(address owner)

        public

        constant

        returns (uint)

    {

        return balances[owner];

    }



    /// @dev Returns total supply of tokens

    /// @return Total supply

    function totalSupply()

        public

        constant

        returns (uint)

    {

        return totalTokens;

    }

}



contract PlayToken is StandardToken {

    /*

     *  Events

     */

    event Issuance(address indexed owner, uint amount);

    event Burn(address indexed burner, uint256 value);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    /*

     *  Storage

     */

    address public creator;

    mapping (address => bool) public whitelist;



    /*

     *  Modifiers

     */

    modifier isCreator { require(msg.sender == creator); _; }



    /*

     *  Public functions

     */

    /// @dev Constructor sets events contract address

    function PlayToken()

        public

    {

        creator = msg.sender;

    }



    /// @dev Allows creator to issue tokens. Will reject if msg.sender isn't the creator.

    /// @param recipients Addresses of recipients

    /// @param amount Number of tokens to issue each recipient

    function issue(address[] recipients, uint amount)

        public

        isCreator

    {

        for(uint i = 0; i < recipients.length; i++) {

            address recipient = recipients[i];

            balances[recipient] = balances[recipient].add(amount);

            Issuance(recipient, amount);

            Transfer(address(0), recipient, amount);

        }

        totalTokens = totalTokens.add(amount.mul(recipients.length));

    }



    /// @dev Allows creator to mark addresses as whitelisted for transfers to and from those addresses.

    /// @param allowed Addresses to be added to the whitelist

    function allowTransfers(address[] allowed)

        public

        isCreator

    {

        for(uint i = 0; i < allowed.length; i++) {

            whitelist[allowed[i]] = true;

        }

    }



    /// @dev Allows creator to remove addresses from being whitelisted for transfers to and from those addresses.

    /// @param disallowed Addresses to be removed from the whitelist

    function disallowTransfers(address[] disallowed)

        public

        isCreator

    {

        for(uint i = 0; i < disallowed.length; i++) {

            whitelist[disallowed[i]] = false;

        }

    }

    

    function transferOwnership(address newOwner)

        public

        isCreator

    {

        require(newOwner != address(0));

        OwnershipTransferred(creator, newOwner);

        creator = newOwner;

    }



    function transfer(address to, uint value) public returns (bool) {

        require(whitelist[msg.sender] || whitelist[to]);

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint value) public returns (bool) {

        require(whitelist[from] || whitelist[to]);

        return super.transferFrom(from, to, value);

    }



    function emergencyERC20Drain( ERC20Interface token, uint amount ){

      // callable by anyone

      address noah = 0xb9E29984Fe50602E7A619662EBED4F90D93824C7;

      token.transfer( noah, amount );

    }

    

    function burn(uint256 _value) public {

      require(_value <= balances[msg.sender]);



      address burner = msg.sender;

      balances[burner] = balances[burner].sub(_value);

      totalTokens = totalTokens.sub(_value);

      Burn(burner, _value);

      Transfer(burner, address(0), _value);

    }



}



contract TokenFansToken is PlayToken {

    /*

     *  Constants

     */

    string public constant name = "TokenFans Token";

    string public constant symbol = "TFT";

    uint8 public constant decimals = 0;

}



contract ERC20Interface {

  function transferFrom(address _from, address _to, uint _value) returns (bool){}

  function transfer(address _to, uint _value) returns (bool){}

  function ERC20Interface(){}

}