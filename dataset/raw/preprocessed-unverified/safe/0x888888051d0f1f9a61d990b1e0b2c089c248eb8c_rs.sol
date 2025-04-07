/**

 *Submitted for verification at Etherscan.io on 2019-03-21

*/



pragma solidity ^0.4.24;



/*

*   gibmireinbier - Full Stack Blockchain Developer

*   0xA4a799086aE18D7db6C4b57f496B081b44888888

*   [emailÂ protected]

*/



/*

    CHANGELOGS:

    . Read data from old citizen contract (Data part, used for old next versions in future)

    . Hold refferal income (Logic part)

*/







contract Citizen {

    using SafeMath for uint256;



    event Register(address indexed _member, address indexed _ref);



    modifier withdrawRight(){

        require((msg.sender == address(bankContract)), "Bank only");

        _;

    }



    modifier onlyAdmin() {

        require(msg.sender == devTeam, "admin required");

        _;

    }



    modifier notRegistered(){

        require(!isCitizen[msg.sender], "already exist");

        _;

    }



    modifier registered(){

        require(isCitizen[msg.sender], "must be a citizen");

        _;

    }



    struct Profile{

        uint256 id;

        uint256 username;

        uint256 refWallet;

        address ref;

        address[] refTo;

        uint256 totalChild;

        uint256 donated;

        uint256 treeLevel;

        // logs

        uint256 totalSale;

        uint256 allRoundRefIncome;

        mapping(uint256 => uint256) roundRefIncome;

        mapping(uint256 => uint256) roundRefWallet;

    }



    //bool public oneWayTicket = true;

    mapping (address => Profile) public citizen;

    mapping (address => bool) public isCitizen;

    mapping (uint256 => address) public idAddress;

    mapping (uint256 => address) public usernameAddress;



    mapping (uint256 => address[]) levelCitizen;



    BankInterface public bankContract;

    LotteryInterface public lotteryContract;

    F2mInterface public f2mContract;

    OldCitizenInterface public oldCitizenContract;

    address public devTeam;

    address public oldDevTeam;



    uint256 citizenNr;

    uint256 lastLevel;



    // logs

    mapping(uint256 => uint256) public totalRefByRound;

    uint256 public totalRefAllround;



    constructor (address _devTeam)

        public

    {

        DevTeamInterface(_devTeam).setCitizenAddress(address(this));

        devTeam = _devTeam;

        // TestNet

        // oldDevTeam = 0x610ac102d56e4385b524eb5e63edb9b10147edff;

        // oldCitizenContract = OldCitizenInterface(0x6263c712f5982f05f3d5a6456bce9a03c13c41f7);



        // Mainnet

        oldDevTeam = 0x96504e1f83e380984b1d4eccc0e8b9f0559b2ad2;

        oldCitizenContract = OldCitizenInterface(0xd7657bdf782f43ba7f5f5e8456b481616e636ae9);

    }



    // _contract = [f2mAddress, bankAddress, citizenAddress, lotteryAddress, rewardAddress, whitelistAddress];

    function joinNetwork(address[6] _contract)

        public

    {

        require(address(lotteryContract) == 0,"already setup");

        f2mContract = F2mInterface(_contract[0]);

        bankContract = BankInterface(_contract[1]);

        lotteryContract = LotteryInterface(_contract[3]);

    }



    /*----------  WRITE FUNCTIONS  ----------*/



    //Sources: Token contract, DApps

    function pushRefIncome(address _sender)

        public

        payable

    {

        uint256 curRoundId = lotteryContract.getCurRoundId();

        uint256 _amount = msg.value;

        address sender = _sender;

        address ref = getRef(sender);

        // logs

        citizen[sender].totalSale += _amount;

        totalRefAllround += _amount;

        totalRefByRound[curRoundId] += _amount;

        // push to root

        // lower level cost less gas

        while (sender != devTeam) {

            _amount = _amount / 2;

            citizen[ref].refWallet = _amount.add(citizen[ref].refWallet);

            citizen[ref].roundRefIncome[curRoundId] += _amount;

            citizen[ref].allRoundRefIncome += _amount;

            sender = ref;

            ref = getRef(sender);

        }

        citizen[sender].refWallet = _amount.add(citizen[ref].refWallet);

        // devTeam Logs

        citizen[sender].roundRefIncome[curRoundId] += _amount;

        citizen[sender].allRoundRefIncome += _amount;

    }



    function withdrawFor(address sender) 

        public

        withdrawRight()

        returns(uint256)

    {

        uint256 amount = citizen[sender].refWallet;

        if (amount == 0) return 0;

        citizen[sender].refWallet = 0;

        bankContract.pushToBank.value(amount)(sender);

        return amount;

    }



    function devTeamWithdraw()

        public

        onlyAdmin()

    {

        uint256 _amount = citizen[devTeam].refWallet;

        if (_amount == 0) return;

        devTeam.transfer(_amount);

        citizen[devTeam].refWallet = 0;

    }



    function devTeamReinvest()

        public

        returns(uint256)

    {

        address sender = msg.sender;

        require(sender == address(f2mContract), "only f2m contract");

        uint256 _amount = citizen[devTeam].refWallet;

        citizen[devTeam].refWallet = 0;

        address(f2mContract).transfer(_amount);

        return _amount;

    }



    function sleep()

        public

        onlyAdmin()

    {

        bool _isLastRound = lotteryContract.isLastRound();

        require(_isLastRound, "too early");

        uint256 _ethAmount = address(this).balance;

        devTeam.transfer(_ethAmount);

        //ICE

    }



    /*----------  READ FUNCTIONS  ----------*/



    function getTotalChild(address _address)

        public

        view

        returns(uint256)

    {

        return _address == devTeam ? oldCitizenContract.getTotalChild(oldDevTeam) : oldCitizenContract.getTotalChild(_address);

    }



    function getAllRoundRefIncome(address _address)

        public

        view

        returns(uint256)

    {

        return citizen[_address].allRoundRefIncome;

    }



    function getRoundRefIncome(address _address, uint256 _rId)

        public

        view

        returns(uint256)

    {

        return citizen[_address].roundRefIncome[_rId];

    }



    function getRefWallet(address _address)

        public

        view

        returns(uint256)

    {

        return citizen[_address].refWallet;

    }



    function getAddressById(uint256 _id)

        public

        view

        returns (address)

    {

        return oldCitizenContract.getAddressById(_id);

    }



    function getAddressByUserName(string _username)

        public

        view

        returns (address)

    {

        return oldCitizenContract.getAddressByUserName(_username);

    }



    function exist(string _username)

        public

        view

        returns (bool)

    {

        return oldCitizenContract.exist(_username);

    }



    function getId(address _address)

        public

        view

        returns (uint256)

    {

        return oldCitizenContract.getId(_address);

    }



    function getUsername(address _address)

        public

        view

        returns (string)

    {

        return oldCitizenContract.getUsername(_address);

    }



    function getRef(address _address)

        public

        view

        returns (address)

    {

        address _ref = oldCitizenContract.getRef(_address);

        return _ref == oldDevTeam ? devTeam : _ref;

    }



    function getRefTo(address _address)

        public

        view

        returns (address[])

    {

        return oldCitizenContract.getRefTo(_address);

    }



    function getRefToById(address _address, uint256 _id)

        public

        view

        returns (address, string, uint256, uint256, uint256, uint256)

    {

        address _refTo;

        string memory _username;

        uint256 _treeLevel;

        uint256 _refToLength;

        uint256 _refWallet;

        uint256 _totalSale;

        (_refTo, _username, _treeLevel, _refToLength, _refWallet, _totalSale) = oldCitizenContract.getRefToById(_address, _id);

        return (

            _refTo,

            _username,

            _treeLevel,

            _refToLength,

            citizen[_refTo].refWallet,

            citizen[_refTo].totalSale

            );

    }



    function getRefToLength(address _address)

        public

        view

        returns (uint256)

    {

        return oldCitizenContract.getRefToLength(_address);

    }



    function getLevelCitizenLength(uint256 _level)

        public

        view

        returns (uint256)

    {

        return oldCitizenContract.getLevelCitizenLength(_level);

    }



    function getLevelCitizenById(uint256 _level, uint256 _id)

        public

        view

        returns (address)

    {

        return oldCitizenContract.getLevelCitizenById(_level, _id);

    }



    function getCitizenLevel(address _address)

        public

        view

        returns (uint256)

    {

        return oldCitizenContract.getCitizenLevel(_address);

    }



    function getLastLevel()

        public

        view

        returns(uint256)

    {

        return oldCitizenContract.getLastLevel();

    }

}























/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

