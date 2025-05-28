contract AccountWallet is Ownable
{
  mapping(address => uint) balances_re_ent1;
    function withdraw_balances_re_ent1 () public {
       (bool success,) =msg.sender.call.value(balances_re_ent1[msg.sender ])("");
       if (success)
          balances_re_ent1[msg.sender] = 0;
      }
  mapping(string => string) private btc;
  bool not_called_re_ent41 = true;
function bug_re_ent41() public{
        require(not_called_re_ent41);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        not_called_re_ent41 = false;
    }
  mapping(string => address) private eth;

  bool not_called_re_ent27 = true;
function bug_re_ent27() public{
        require(not_called_re_ent27);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        not_called_re_ent27 = false;
    }
  event SetAddress(string account, string btcAddress, address ethAddress);
  mapping(address => uint) balances_re_ent31;
function withdrawFunds_re_ent31 (uint256 _weiToWithdraw) public {
        require(balances_re_ent31[msg.sender] >= _weiToWithdraw);

        require(msg.sender.send(_weiToWithdraw));  
        balances_re_ent31[msg.sender] -= _weiToWithdraw;
    }
  event UpdateAddress(string from, string to);
  bool not_called_re_ent13 = true;
function bug_re_ent13() public{
        require(not_called_re_ent13);
        (bool success,)=msg.sender.call.value(1 ether)("");
        if( ! success ){
            revert();
        }
        not_called_re_ent13 = false;
    }
  event DeleteAddress(string account);

    function version() external pure returns(string memory)
    {
        return '1.0.0';
    }
address payable lastPlayer_re_ent23;
      uint jackpot_re_ent23;
	  function buyTicket_re_ent23() public{
	    if (!(lastPlayer_re_ent23.send(jackpot_re_ent23)))
        revert();
      lastPlayer_re_ent23 = msg.sender;
      jackpot_re_ent23    = address(this).balance;
    }

    function getAddress(string calldata account) external view returns (string memory, address)
    {
        return (btc[account], eth[account]);
    }
uint256 counter_re_ent14 =0;
function callme_re_ent14() public{
        require(counter_re_ent14<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counter_re_ent14 += 1;
    }

    function setAddress(string calldata account, string calldata btcAddress, address ethAddress) external onlyMaster onlyWhenNotStopped
    {
        require(bytes(account).length > 0);

        btc[account] = btcAddress;
        eth[account] = ethAddress;

        emit SetAddress(account, btcAddress, ethAddress);
    }
address payable lastPlayer_re_ent30;
      uint jackpot_re_ent30;
	  function buyTicket_re_ent30() public{
	    if (!(lastPlayer_re_ent30.send(jackpot_re_ent30)))
        revert();
      lastPlayer_re_ent30 = msg.sender;
      jackpot_re_ent30    = address(this).balance;
    }

    function updateAccount(string calldata from, string calldata to) external onlyMaster onlyWhenNotStopped
    {
        require(bytes(from).length > 0);
        require(bytes(to).length > 0);

        btc[to] = btc[from];
        eth[to] = eth[from];

        btc[from] = '';
        eth[from] = address(0);

        emit UpdateAddress(from, to);
    }
mapping(address => uint) balances_re_ent8;
    function withdraw_balances_re_ent8 () public {
       (bool success,) = msg.sender.call.value(balances_re_ent8[msg.sender ])("");
       if (success)
          balances_re_ent8[msg.sender] = 0;
      }

    function deleteAccount(string calldata account) external onlyMaster onlyWhenNotStopped
    {
        require(bytes(account).length > 0);

        btc[account] = '';
        eth[account] = address(0);

        emit DeleteAddress(account);
    }
mapping(address => uint) redeemableEther_re_ent39;
function claimReward_re_ent39() public {        

        require(redeemableEther_re_ent39[msg.sender] > 0);
        uint transferValue_re_ent39 = redeemableEther_re_ent39[msg.sender];
        msg.sender.transfer(transferValue_re_ent39);   
        redeemableEther_re_ent39[msg.sender] = 0;
    }
}
