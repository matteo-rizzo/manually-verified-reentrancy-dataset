/**

 *Submitted for verification at Etherscan.io on 2018-09-15

*/



pragma solidity ^0.4.24;





contract ERC20 {

  function transfer(address _recipient, uint256 _value) public returns (bool success);

  function balanceOf(address _owner) external view returns (uint256);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract MultiSend is Ownable {

  function transferMultiple(address _tokenAddress, address[] recipients, uint256[] values) public onlyOwner returns (uint256) {

    ERC20 token = ERC20(_tokenAddress);

    for (uint256 i = 0; i < recipients.length; i++) {

      token.transfer(recipients[i], values[i]);

    }

    return i;

  }



  function emergencyERC20Drain(address _tokenAddress, address recipient) external onlyOwner returns (bool) {

    require(recipient != address(0));

    ERC20 token = ERC20(_tokenAddress);

    require(token.balanceOf(this) > 0);

    return token.transfer(recipient, token.balanceOf(this));

  }

}