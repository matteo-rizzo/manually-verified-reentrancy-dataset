/**

 *Submitted for verification at Etherscan.io on 2018-08-30

*/



pragma solidity ^0.4.24;











contract ERC20Token {

    /* This is a slight change to the ERC20 base standard.

    function totalSupply() constant returns (uint256 supply);

    is replaced with:

    uint256 public totalSupply;

    This automatically creates a getter function for the totalSupply.

    This is moved to the base contract since public getter functions are not

    currently recognised as an implementation of the matching abstract

    function by the compiler.

    */

    /// total amount of tokens

    uint256 public totalSupply;

    

    /// user tokens

    mapping (address => uint256) public balances;

    

    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) constant public returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success);

    

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract TxProxy is Owned {

    

    uint256 decimals = 18;

    

    address public USEAddr = 0xd9485499499d66B175Cf5ED54c0a19f1a6Bcb61A;

    

    /// @dev token holder

    address public allocTokenHolder;

    

    /// @dev change token holder

    function changeTokenHolder(address _tokenHolder) public onlyInitOwner {

        allocTokenHolder = _tokenHolder;

    }

    

    /// @dev This owner allocate token for candy airdrop

    /// @param _owners The address of the account that owns the token

    /// @param _values The amount of tokens

	function allocateToken(address[] _owners, uint256[] _values) public onlyOwners(msg.sender) {

	   require (_owners.length == _values.length);

       for(uint i = 0; i < _owners.length ; i++){

           uint256 value = _values[i] * 10 ** decimals;

           require(ERC20Token(USEAddr).transferFrom(allocTokenHolder, _owners[i], value) == true);

        }

    }

}