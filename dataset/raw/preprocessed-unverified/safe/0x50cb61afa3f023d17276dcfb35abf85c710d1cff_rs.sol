/**

 *Submitted for verification at Etherscan.io on 2019-07-15

*/



pragma solidity 0.4.24;



/**

 * @dev Collection of functions related to the address type,

 */







/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    // SafeMath.sub will throw if there is not enough balance.

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];

  }



}





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see `ERC20Detailed`.

 */







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/*



  Copyright Ethfinex Inc 2018



  Licensed under the Apache License, Version 2.0

  http://www.apache.org/licenses/LICENSE-2.0



*/



contract WrapperLockEth is BasicToken, Ownable {

    using SafeERC20 for IERC20;

    using SafeMath for uint256;



    address public TRANSFER_PROXY_VEFX = 0xdcDb42C9a256690bd153A7B409751ADFC8Dd5851;

    address public TRANSFER_PROXY_V2 = 0x95e6f48254609a6ee006f7d493c8e5fb97094cef;

    mapping (address => bool) public isSigner;



    string public name;

    string public symbol;

    uint public decimals;

    address public originalToken = 0x00;



    mapping (address => uint) public depositLock;

    mapping (address => uint256) public balances;



    constructor(string _name, string _symbol, uint _decimals ) Ownable() {

        name = _name;

        symbol = _symbol;

        decimals = _decimals;

        isSigner[msg.sender] = true;

    }



    // @dev method only for testing, needs to be commented out when deploying

    // function addProxy(address _addr) public {

    //     TRANSFER_PROXY_VEFX = _addr;

    // }



    function deposit(uint _value, uint _forTime) public payable returns (bool success) {

        require(_forTime >= 1);

        require(now + _forTime * 1 hours >= depositLock[msg.sender]);

        balances[msg.sender] = balances[msg.sender].add(msg.value);

        totalSupply_ = totalSupply_.add(msg.value);

        depositLock[msg.sender] = now + _forTime * 1 hours;

        return true;

    }



    function withdraw(

        uint _value,

        uint8 v,

        bytes32 r,

        bytes32 s,

        uint signatureValidUntilBlock

    )

        public

        returns

        (bool)

    {

        require(balanceOf(msg.sender) >= _value);

        if (now > depositLock[msg.sender]) {

            balances[msg.sender] = balances[msg.sender].sub(_value);

            totalSupply_ = totalSupply_.sub(_value);

            msg.sender.transfer(_value);

        } else {

            require(block.number < signatureValidUntilBlock);

            require(isValidSignature(keccak256(msg.sender, address(this), signatureValidUntilBlock), v, r, s));

            balances[msg.sender] = balances[msg.sender].sub(_value);

            totalSupply_ = totalSupply_.sub(_value);

            depositLock[msg.sender] = 0;

            msg.sender.transfer(_value);

        }

        return true;

    }



    function withdrawDifferentToken(address _differentToken) public onlyOwner returns (bool) {

        require(_differentToken != originalToken);

        require(IERC20(_differentToken).balanceOf(address(this)) > 0);

        IERC20(_differentToken).safeTransfer(msg.sender, IERC20(_differentToken).balanceOf(address(this)));

        return true;

    }



    function transfer(address _to, uint256 _value) public returns (bool) {

        return false;

    }



    function transferFrom(address _from, address _to, uint _value) public {

        require(isSigner[_to] || isSigner[_from]);

        assert(msg.sender == TRANSFER_PROXY_VEFX || msg.sender == TRANSFER_PROXY_V2);

        balances[_to] = balances[_to].add(_value);

        depositLock[_to] = depositLock[_to] > now ? depositLock[_to] : now + 1 hours;

        balances[_from] = balances[_from].sub(_value);

        Transfer(_from, _to, _value);

    }



    function allowance(address _owner, address _spender) public constant returns (uint) {

        if (_spender == TRANSFER_PROXY_VEFX || _spender == TRANSFER_PROXY_V2) {

            return 2**256 - 1;

        }

    }



    function balanceOf(address _owner) public constant returns (uint256) {

        return balances[_owner];

    }



    function isValidSignature(

        bytes32 hash,

        uint8 v,

        bytes32 r,

        bytes32 s)

        public

        constant

        returns (bool)

    {

        return isSigner[ecrecover(

            keccak256("\x19Ethereum Signed Message:\n32", hash),

            v,

            r,

            s

        )];

    }



    function addSigner(address _newSigner) public {

        require(isSigner[msg.sender]);

        isSigner[_newSigner] = true;

    }



    function keccak(address _sender, address _wrapper, uint _validTill) public pure returns(bytes32) {

        return keccak256(_sender, _wrapper, _validTill);

    }

}