pragma solidity ^0.4.18;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract HasWallet is Ownable {
    address public wallet;

    function setWallet(address walletAddress) public onlyOwner {
        require(walletAddress != address(0));
        wallet = walletAddress;
    }


}
contract WalletUsage is HasWallet {


    /**
      * 合约自己是否保留eth.
      */
    bool public keepEth;


    /**
      * 为避免默认方法被占用，特别开指定方法接受以太坊
      */
    function depositEth() public payable {
    }

    function withdrawEth2Wallet(uint256 weiAmount) public onlyOwner {
        require(wallet != address(0));
        require(weiAmount > 0);
        wallet.transfer(weiAmount);
    }

    function setKeepEth(bool _keepEth) public onlyOwner {
        keepEth = _keepEth;
    }

}


contract PublicBatchTransfer is WalletUsage {
    using SafeERC20 for ERC20;

    uint256 public fee;

    function PublicBatchTransfer(address walletAddress,uint256 _fee){
        require(walletAddress != address(0));
        setWallet(walletAddress);
        setFee(_fee);
    }

    function batchTransfer(address tokenAddress, address[] beneficiaries, uint256[] tokenAmount) payable public returns (bool) {
        require(msg.value >= fee);
        require(tokenAddress != address(0));
        require(beneficiaries.length > 0 && beneficiaries.length == tokenAmount.length);
        ERC20 ERC20Contract = ERC20(tokenAddress);
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            ERC20Contract.safeTransferFrom(msg.sender, beneficiaries[i], tokenAmount[i]);
        }
        if (!keepEth) {
            wallet.transfer(msg.value);
        }

        return true;
    }

    function setFee(uint256 _fee) onlyOwner public {
        fee = _fee;
    }
}