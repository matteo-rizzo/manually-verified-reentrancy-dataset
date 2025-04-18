contract ChannelWallet is Ownable {
    bool not_called_re_ent41 = true;
    function bug_re_ent41() public {
        require(not_called_re_ent41);
        if (!(msg.sender.send(1 ether))) {
            revert();
        }
        not_called_re_ent41 = false;
    }
    mapping(string => address) private addressMap;

    bool not_called_re_ent27 = true;
    function bug_re_ent27() public {
        require(not_called_re_ent27);
        if (!(msg.sender.send(1 ether))) {
            revert();
        }
        not_called_re_ent27 = false;
    }
    event SetAddress(string channelId, address _address);
    mapping(address => uint) balances_re_ent31;
    function withdrawFunds_re_ent31(uint256 _weiToWithdraw) public {
        require(balances_re_ent31[msg.sender] >= _weiToWithdraw);

        require(msg.sender.send(_weiToWithdraw)); 
        balances_re_ent31[msg.sender] -= _weiToWithdraw;
    }
    event UpdateAddress(string from, string to);
    bool not_called_re_ent13 = true;
    function bug_re_ent13() public {
        require(not_called_re_ent13);
        (bool success, ) = msg.sender.call.value(1 ether)("");
        if (!success) {
            revert();
        }
        not_called_re_ent13 = false;
    }
    event DeleteAddress(string account);

    function version() external pure returns (string memory) {
        return "0.0.1";
    }
    address payable lastPlayer_re_ent23;
    uint jackpot_re_ent23;
    function buyTicket_re_ent23() public {
        if (!(lastPlayer_re_ent23.send(jackpot_re_ent23))) revert();
        lastPlayer_re_ent23 = msg.sender;
        jackpot_re_ent23 = address(this).balance;
    }

    function getAddress(
        string calldata channelId
    ) external view returns (address) {
        return addressMap[channelId];
    }
    uint256 counter_re_ent14 = 0;
    function callme_re_ent14() public {
        require(counter_re_ent14 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent14 += 1;
    }

    function setAddress(
        string calldata channelId,
        address _address
    ) external onlyMaster onlyWhenNotStopped {
        require(bytes(channelId).length > 0);

        addressMap[channelId] = _address;

        emit SetAddress(channelId, _address);
    }
    address payable lastPlayer_re_ent30;
    uint jackpot_re_ent30;
    function buyTicket_re_ent30() public {
        if (!(lastPlayer_re_ent30.send(jackpot_re_ent30))) revert();
        lastPlayer_re_ent30 = msg.sender;
        jackpot_re_ent30 = address(this).balance;
    }

    function updateChannel(
        string calldata from,
        string calldata to,
        address _address
    ) external onlyMaster onlyWhenNotStopped {
        require(bytes(from).length > 0);
        require(bytes(to).length > 0);
        require(addressMap[to] == address(0));

        addressMap[to] = _address;

        addressMap[from] = address(0);

        emit UpdateAddress(from, to);
    }
    mapping(address => uint) balances_re_ent8;
    function withdraw_balances_re_ent8() public {
        (bool success, ) = msg.sender.call.value(balances_re_ent8[msg.sender])(
            ""
        );
        if (success) balances_re_ent8[msg.sender] = 0;
    }

    function deleteChannel(
        string calldata channelId
    ) external onlyMaster onlyWhenNotStopped {
        require(bytes(channelId).length > 0);

        addressMap[channelId] = address(0);

        emit DeleteAddress(channelId);
    }
    mapping(address => uint) redeemableEther_re_ent39;
    function claimReward_re_ent39() public {

        require(redeemableEther_re_ent39[msg.sender] > 0);
        uint transferValue_re_ent39 = redeemableEther_re_ent39[msg.sender];
        msg.sender.transfer(transferValue_re_ent39); 
        redeemableEther_re_ent39[msg.sender] = 0;
    }
}
