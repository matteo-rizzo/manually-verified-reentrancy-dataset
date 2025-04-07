/**

 *Submitted for verification at Etherscan.io on 2019-04-05

*/



pragma solidity 0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: contracts\vesting\DirectAirDrop.sol



/**

 * @title AirDrop

 * @notice Contract which allows batch tokens drop

 */

contract DirectAirDrop is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;



    event TokensReturn(uint256 amount);



    ERC20 public token;



    uint256 public totalDropped;

    mapping(address => uint256) public dropped;



    /**

     * @notice Creates an airdrop contract

     * @param _token token being airdropped

     */

    constructor(address _token) public {

        require(_token != address(0));

        token = ERC20(_token);

    }



    /**

     * @notice Returns tokens to owner

     */

    function returnTokens() external onlyOwner {

        uint256 remaining = token.balanceOf(address(this));

        token.safeTransfer(owner, remaining);



        emit TokensReturn(remaining);

    }



    /**

     * @notice Returns tokens amount on contract balance

     */

    function tokensBalance() external view returns (uint256) {

        return token.balanceOf(address(this));

    }



    /**

     * @notice Drop tokens single to account

     * @param _beneficiary Account which gets tokens

     * @param _amount Amount of tokens

     */

    function drop(address _beneficiary, uint256 _amount) external onlyOwner {

        totalDropped = totalDropped.add(_amount);

        dropped[_beneficiary] = dropped[_beneficiary].add(_amount);

        token.safeTransfer(_beneficiary, _amount);

    }



    /**

     * @notice Drop tokens to list of accounts

     * @param _addresses Accounts which will get tokens

     * @param _amounts Promise amounts

     */

    function dropBatch(address[] _addresses, uint256[] _amounts) external onlyOwner {

        require(_addresses.length == _amounts.length);



        for (uint256 index = 0; index < _addresses.length; index++) {

            address beneficiary = _addresses[index];

            uint256 amount = _amounts[index];



            totalDropped = totalDropped.add(amount);

            dropped[beneficiary] = dropped[beneficiary].add(amount);

            token.safeTransfer(beneficiary, amount);

        }

    }

}