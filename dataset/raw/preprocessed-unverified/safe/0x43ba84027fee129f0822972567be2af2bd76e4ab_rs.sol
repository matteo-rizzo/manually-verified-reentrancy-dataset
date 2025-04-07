/**

 *Submitted for verification at Etherscan.io on 2018-10-27

*/



pragma solidity ^0.4.24;





/**

 * [email protected]/contracts/math/SafeMath.sol

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * [email protected]/contracts/ownership/Ownable.sol

 */



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * [email protected]/contracts/token/ERC20/ERC20Basic.sol

 */



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  // function transfer(address to, uint256 value) public returns (bool);

  function transfer(address to, uint256 value) public;

  event Transfer(address indexed from, address indexed to, uint256 value);

}





/**

 * [email protected]/contracts/token/ERC20/ERC20.sol

 */



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





/**

 * AirDrop Contract

 */

contract AirDrop is Ownable {

  using SafeMath for uint256;



  function () external payable {}



  function batchTransferToken(address _token_address, address[] _receivers, uint256[] _amounts) public onlyOwner returns (bool) {

    require(_token_address != address(0));

    require(_receivers.length > 0 && _receivers.length <= 256);

    require(_receivers.length == _amounts.length);



    ERC20 token = ERC20(_token_address);

    require(_getTotalSendingAmount(_amounts) <= token.balanceOf(this));



    for (uint i = 0; i < _receivers.length; i++) {

      require(_receivers[i] != address(0));

      require(_amounts[i] > 0);

      token.transfer(_receivers[i], _amounts[i]);

    }



    return true;

  }



  function batchTransferEther(address[] _receivers, uint256[] _amounts) public payable onlyOwner returns (bool) {

    require(_receivers.length > 0 && _receivers.length <= 256);

    require(_receivers.length == _amounts.length);

    require(msg.value > 0 && _getTotalSendingAmount(_amounts) <= msg.value);



    for (uint i = 0; i < _receivers.length; i++) {

      require(_receivers[i] != address(0));

      require(_amounts[i] > 0);

      _receivers[i].transfer(_amounts[i]);

    }



    return true;

  }



  function withdrawToken(address _token_address, address _receiver) public onlyOwner returns (bool) {

    ERC20 token = ERC20(_token_address);

    require(_receiver != address(0) && token.balanceOf(this) > 0);

    token.transfer(_receiver, token.balanceOf(this));

    return true;

  }



  function withdrawEther(address _receiver) public onlyOwner returns (bool) {

    require(_receiver != address(0));

    _receiver.transfer(address(this).balance);

    return true;

  }

  

  function _getTotalSendingAmount(uint256[] _amounts) private pure returns (uint256 totalSendingAmount) {

    for (uint i = 0; i < _amounts.length; i++) {

      require(_amounts[i] > 0);

      totalSendingAmount = totalSendingAmount.add(_amounts[i]);

    }

  }

}