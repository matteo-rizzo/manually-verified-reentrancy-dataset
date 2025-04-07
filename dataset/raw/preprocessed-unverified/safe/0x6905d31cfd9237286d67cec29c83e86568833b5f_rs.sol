/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity 0.6.8;





contract YFMSTokenSwap {
  using SafeMath for uint256;

  ERC20 public YFMSToken;
  ERC20 public LUCRToken;

  address public owner;

  constructor(address yfms, address lucr) public {
    owner = msg.sender;
    YFMSToken = ERC20(yfms);
    LUCRToken = ERC20(lucr);
  }

  function swap () public {
    uint256 balance = YFMSToken.balanceOf(msg.sender);
    require(balance > 0, "balance must be greater than 0");
    require(YFMSToken.transferFrom(msg.sender, address(this), balance), "YFMS transfer failed");
    require(LUCRToken.transferFrom(owner, msg.sender, balance), "LUCR transfer failed");
  }

  function withdrawYFMS () public {
    require(msg.sender == owner);
    YFMSToken.transfer(owner, YFMSToken.balanceOf(address(this)));
  }
}