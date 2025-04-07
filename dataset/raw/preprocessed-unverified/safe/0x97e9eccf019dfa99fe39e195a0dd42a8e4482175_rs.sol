/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.4.23;







contract ERC20Basic {
  // events
  event Transfer(address indexed from, address indexed to, uint256 value);

  // public functions
  function totalSupply() public view returns (uint256);
  function balanceOf(address addr) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

contract BatchTransfer is Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    ERC20Basic public token;
    uint256 public decimal = 8;

    constructor() public {
        token = ERC20Basic(0x0f8c45b896784a1e408526b9300519ef8660209c);
    }
    
    function batchTransfer(address[] addrs, uint256[] amounts) public onlyOwner {
        require(addrs.length > 0 && addrs.length == amounts.length);
        
        uint256 total = token.balanceOf(this);
        require(total > 0);
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < addrs.length; i++) {
            require(!(addrs[i].isContract()));
            totalAmount = totalAmount.add(amounts[i] * 10 ** decimal);
        }
        require(totalAmount <= total);
        
        for (uint256 j = 0; j < addrs.length; j++) {
            token.transfer(addrs[j], amounts[j] * 10 ** decimal);
        }
    }
    
    function getBalance() public view returns(uint256) {
        return token.balanceOf(this);
    }
    
    function() public payable {
        revert();
    }
    
}