/**
 *Submitted for verification at Etherscan.io on 2020-12-25
*/

pragma solidity ^0.6.10;
    
    // SPDX-License-Identifier: MIT;
    
    
    
    
    
    
    contract Mutex {
        bool isLocked;
        modifier noReentrance() {
            require(!isLocked);
            isLocked = true;
            _;
            isLocked = false;
        }
        
    }
    
    contract Distributor is Mutex {
      using SafeMath for uint256;
    
    
      IERC20 public token;
  
      address payable public wallet = 0x93B3a464aF66Ce7b73cD5a2acBB927A8Ea5BaB0e;
      uint256 public rate = 333;
     
     
      uint256 public trxnCount;
      uint256 public weiRaised;
    
    
      event Bought(uint256 amount);
      event Transfer(address _to, uint256 amount);
      event TransferMultiple(address[] _receivers, uint256 amount);
      event TotalBalance(address sender,uint256 vlue,uint256 balance);
    
      modifier onlyOwner{
          require(msg.sender==wallet);
          _;
      }
      
    constructor(address _token) public {
        token = IERC20(_token);
    }
  


    receive() external payable {
        (bool success,) = wallet.call{value:msg.value}("");
        require(success, "can not transfer funds");
        buy(msg.sender);
        weiRaised = weiRaised.add(msg.value);
    }


    function buy(address _buyer) payable public noReentrance {
        uint256 amountTobuy = _getTokenAmount(msg.value);
        uint256 thisBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= thisBalance, "Not enough tokens in the reserve");
        TransferHelper.safeTransfer(address(token), _buyer, amountTobuy);
        emit Bought(amountTobuy);
        trxnCount++;
    }

  
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(rate);
    }
    
  
    function getEthTokenBal() public view returns(uint256, uint256) {
        return ( address(this).balance, token.balanceOf(address(this)));
    }
  
    function withdrawToken() public onlyOwner{
        uint bal = token.balanceOf(address(this));
        TransferHelper.safeTransfer(address(token), wallet, bal);
        emit Transfer(wallet, bal);
    }
  
    function burn()public onlyOwner {
        
        uint256 bal = token.balanceOf(address(this));
        TransferHelper.safeTransfer(address(token), address(0), bal);
        emit Transfer(address(0), bal);
    }
    

  
}


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
    