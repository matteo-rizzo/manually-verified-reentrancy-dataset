/**

 *Submitted for verification at Etherscan.io on 2019-01-12

*/



pragma solidity ^0.4.24;



/*

*   gibmireinbier

*   0xA4a799086aE18D7db6C4b57f496B081b44888888

*   [emailÂ protected]

*/



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





















contract Bank {

    using SafeMath for uint256;



    mapping(address => uint256) public balance;

    mapping(address => uint256) public claimedSum;

    mapping(address => uint256) public donateSum;

    mapping(address => bool) public isMember;

    address[] public member;



    uint256 public TIME_OUT = 7 * 24 * 60 * 60;

    mapping(address => uint256) public lastClaim;



    CitizenInterface public citizenContract;

    LotteryInterface public lotteryContract;

    F2mInterface public f2mContract;

    DevTeamInterface public devTeamContract;



    constructor (address _devTeam)

        public

    {

        // add administrators here

        devTeamContract = DevTeamInterface(_devTeam);

        devTeamContract.setBankAddress(address(this));

    }



    // _contract = [f2mAddress, bankAddress, citizenAddress, lotteryAddress, rewardAddress, whitelistAddress];

    function joinNetwork(address[6] _contract)

        public

    {

        require(address(citizenContract) == 0x0,"already setup");

        f2mContract = F2mInterface(_contract[0]);

        //bankContract = BankInterface(bankAddress);

        citizenContract = CitizenInterface(_contract[2]);

        lotteryContract = LotteryInterface(_contract[3]);

    }



    // Core functions



    function pushToBank(address _player)

        public

        payable

    {

        uint256 _amount = msg.value;

        lastClaim[_player] = block.timestamp;

        balance[_player] = _amount.add(balance[_player]);

    }



    function collectDividends(address _member)

        public

        returns(uint256)

    {

        require(_member != address(devTeamContract), "no right");

        uint256 collected = f2mContract.withdrawFor(_member);

        claimedSum[_member] += collected;

        return collected;

    }



    function collectRef(address _member)

        public

        returns(uint256)

    {

        require(_member != address(devTeamContract), "no right");

        uint256 collected = citizenContract.withdrawFor(_member);

        claimedSum[_member] += collected;

        return collected;

    }



    function collectReward(address _member)

        public

        returns(uint256)

    {

        require(_member != address(devTeamContract), "no right");

        uint256 collected = lotteryContract.withdrawFor(_member);

        claimedSum[_member] += collected;

        return collected;

    }



    function collectIncome(address _member)

        public

        returns(uint256)

    {

        require(_member != address(devTeamContract), "no right");

        //lastClaim[_member] = block.timestamp;

        uint256 collected = collectDividends(_member) + collectRef(_member) + collectReward(_member);

        return collected;

    }



    function restTime(address _member)

        public

        view

        returns(uint256)

    {

        uint256 timeDist = block.timestamp - lastClaim[_member];

        if (timeDist >= TIME_OUT) return 0;

        return TIME_OUT - timeDist;

    }



    function timeout(address _member)

        public

        view

        returns(bool)

    {

        return lastClaim[_member] > 0 && restTime(_member) == 0;

    }



    function memberLog()

        private

    {

        address _member = msg.sender;

        lastClaim[_member] = block.timestamp;

        if (isMember[_member]) return;

        member.push(_member);

        isMember[_member] = true;

    }



    function cashoutable()

        public

        view

        returns(bool)

    {

        return lotteryContract.cashoutable(msg.sender);

    }



    function cashout()

        public

    {

        address _sender = msg.sender;

        uint256 _amount = balance[_sender];

        require(_amount > 0, "nothing to cashout");

        balance[_sender] = 0;

        memberLog();

        require(cashoutable() && _amount > 0, "need 1 ticket or wait to new round");

        _sender.transfer(_amount);

    }



    // ref => devTeam

    // div => div

    // lottery => div

    function checkTimeout(address _member)

        public

    {

        require(timeout(_member), "member still got time to withdraw");

        require(_member != address(devTeamContract), "no right");

        uint256 _curBalance = balance[_member];

        uint256 _refIncome = collectRef(_member);

        uint256 _divIncome = collectDividends(_member);

        uint256 _rewardIncome = collectReward(_member);

        donateSum[_member] += _refIncome + _divIncome + _rewardIncome;

        balance[_member] = _curBalance;

        f2mContract.pushDividends.value(_divIncome + _rewardIncome)();

        citizenContract.pushRefIncome.value(_refIncome)(0x0);

    }



    function withdraw() 

        public

    {

        address _member = msg.sender;

        collectIncome(_member);

        cashout();

        //lastClaim[_member] = block.timestamp;

    } 



    function lotteryReinvest(string _sSalt, uint256 _amount)

        public

        payable

    {

        address _sender = msg.sender;

        uint256 _deposit = msg.value;

        uint256 _curBalance = balance[_sender];

        uint256 investAmount;

        uint256 collected = 0;

        if (_deposit == 0) {

            if (_amount > balance[_sender]) 

                collected = collectIncome(_sender);

            require(_amount <= _curBalance + collected, "balance not enough");

            investAmount = _amount;//_curBalance + collected;

        } else {

            collected = collectIncome(_sender);

            investAmount = _deposit.add(_curBalance).add(collected);

        }

        balance[_sender] = _curBalance.add(collected + _deposit).sub(investAmount);

        lastClaim [_sender] = block.timestamp;

        lotteryContract.buyFor.value(investAmount)(_sSalt, _sender);

    }



    function tokenReinvest(uint256 _amount) 

        public

        payable

    {

        address _sender = msg.sender;

        uint256 _deposit = msg.value;

        uint256 _curBalance = balance[_sender];

        uint256 investAmount;

        uint256 collected = 0;

        if (_deposit == 0) {

            if (_amount > balance[_sender]) 

                collected = collectIncome(_sender);

            require(_amount <= _curBalance + collected, "balance not enough");

            investAmount = _amount;//_curBalance + collected;

        } else {

            collected = collectIncome(_sender);

            investAmount = _deposit.add(_curBalance).add(collected);

        }

        balance[_sender] = _curBalance.add(collected + _deposit).sub(investAmount);

        lastClaim [_sender] = block.timestamp;

        f2mContract.buyFor.value(investAmount)(_sender);

    }



    // Read

    function getDivBalance(address _sender)

        public

        view

        returns(uint256)

    {

        uint256 _amount = f2mContract.ethBalance(_sender);

        return _amount;

    }



    function getEarlyIncomeBalance(address _sender)

        public

        view

        returns(uint256)

    {

        uint256 _amount = lotteryContract.getCurEarlyIncomeByAddress(_sender);

        return _amount;

    }



    function getRewardBalance(address _sender)

        public

        view

        returns(uint256)

    {

        uint256 _amount = lotteryContract.getRewardBalance(_sender);

        return _amount;

    }



    function getRefBalance(address _sender)

        public

        view

        returns(uint256)

    {

        uint256 _amount = citizenContract.getRefWallet(_sender);

        return _amount;

    }



    function getBalance(address _sender)

        public

        view

        returns(uint256)

    {

        uint256 _sum = getUnclaimedBalance(_sender);

        return _sum + balance[_sender];

    }



    function getUnclaimedBalance(address _sender)

        public

        view

        returns(uint256)

    {

        uint256 _sum = getDivBalance(_sender) + getRefBalance(_sender) + getRewardBalance(_sender) + getEarlyIncomeBalance(_sender);

        return _sum;

    }



    function getClaimedBalance(address _sender)

        public

        view

        returns(uint256)

    {

        return balance[_sender];

    }



    function getTotalMember() 

        public

        view

        returns(uint256)

    {

        return member.length;

    }

}