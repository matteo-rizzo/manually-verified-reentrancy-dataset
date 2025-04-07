pragma solidity ^0.4.22;





contract EtherZaarTwitter is Ownable {

  using SafeMath for uint256;

  event addressRegistration(uint256 twitterId, address ethereumAddress);
  event Transfer(uint256 receiverTwitterId, uint256 senderTwitterId, uint256 ethereumAmount);
  event Withdraw(uint256 twitterId, uint256 ethereumAmount);
  event EthereumDeposit(uint256 twitterId, address ethereumAddress, uint256 ethereumAmount);
  event TransferCreditDeposit(uint256 twitterId, uint256 transferCredits);

  mapping (uint256 => address) public twitterIdToEthereumAddress;
  mapping (uint256 => uint256) public twitterIdToEthereumBalance;
  mapping (uint256 => uint256) public twitterIdToTransferCredits;

  function _addEthereumAddress(uint256 _twitterId, address _ethereumAddress) external onlyTwitterBot {
    twitterIdToEthereumAddress[_twitterId] = _ethereumAddress;

    emit addressRegistration(_twitterId, _ethereumAddress);
  }

  function _depositEthereum(uint256 _twitterId) external payable{
      twitterIdToEthereumBalance[_twitterId] += msg.value;
      emit EthereumDeposit(_twitterId, twitterIdToEthereumAddress[_twitterId], msg.value);
  }

  function _depositTransferCredits(uint256 _twitterId, uint256 _transferCredits) external onlyTransferCreditBot{
      twitterIdToTransferCredits[_twitterId] += _transferCredits;
      emit TransferCreditDeposit(_twitterId, _transferCredits);
  }

  function _transferEthereum(uint256 _senderTwitterId, uint256 _receiverTwitterId, uint256 _ethereumAmount) external onlyTwitterBot {
      require(twitterIdToEthereumBalance[_senderTwitterId] >= _ethereumAmount);
      require(twitterIdToTransferCredits[_senderTwitterId] > 0);

      twitterIdToEthereumBalance[_senderTwitterId] = twitterIdToEthereumBalance[_senderTwitterId] - _ethereumAmount;
      twitterIdToTransferCredits[_senderTwitterId] = twitterIdToTransferCredits[_senderTwitterId] - 1;
      twitterIdToEthereumBalance[_receiverTwitterId] += _ethereumAmount;

      emit Transfer(_receiverTwitterId, _senderTwitterId, _ethereumAmount);
  }

  function _withdrawEthereum(uint256 _twitterId) external {
      require(twitterIdToEthereumBalance[_twitterId] > 0);
      require(twitterIdToEthereumAddress[_twitterId] == msg.sender);

      uint256 transferAmount = twitterIdToEthereumBalance[_twitterId];
      twitterIdToEthereumBalance[_twitterId] = 0;

      (msg.sender).transfer(transferAmount);

      emit Withdraw(_twitterId, transferAmount);
  }

  function _sendEthereum(uint256 _twitterId) external onlyTwitterBot {
      require(twitterIdToEthereumBalance[_twitterId] > 0);
      require(twitterIdToTransferCredits[_twitterId] > 0);

      twitterIdToTransferCredits[_twitterId] = twitterIdToTransferCredits[_twitterId] - 1;
      uint256 sendAmount = twitterIdToEthereumBalance[_twitterId];
      twitterIdToEthereumBalance[_twitterId] = 0;

      (twitterIdToEthereumAddress[_twitterId]).transfer(sendAmount);

      emit Withdraw(_twitterId, sendAmount);
  }
}