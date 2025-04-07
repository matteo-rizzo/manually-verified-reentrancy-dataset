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



    BankInterface bankContract;

    LotteryInterface lotteryContract;

    F2mInterface f2mContract;

    address devTeam;



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



        // first citizen is the development team

        citizenNr = 1;

        idAddress[1] = devTeam;

        isCitizen[devTeam] = true;

        //root => self ref

        citizen[devTeam].ref = devTeam;

        // username rules bypass

        uint256 _username = Helper.stringToUint("f2m");

        citizen[devTeam].username = _username;

        usernameAddress[_username] = devTeam; 

        citizen[devTeam].id = 1;

        citizen[devTeam].treeLevel = 1;

        levelCitizen[1].push(devTeam);

        lastLevel = 1;

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

    function updateTotalChild(address _address)

        private

    {

        address _member = _address;

        while(_member != devTeam) {

            _member = getRef(_member);

            citizen[_member].totalChild ++;

        }

    }



    function register(string _sUsername, address _ref)

        public

        notRegistered()

    {

        require(Helper.validUsername(_sUsername), "invalid username");

        address sender = msg.sender;

        uint256 _username = Helper.stringToUint(_sUsername);

        require(usernameAddress[_username] == 0x0, "username already exist");

        usernameAddress[_username] = sender;

        //ref must be a citizen, else ref = devTeam

        address validRef = isCitizen[_ref] ? _ref : devTeam;



        //Welcome new Citizen

        isCitizen[sender] = true;

        citizen[sender].username = _username;

        citizen[sender].ref = validRef;

        citizenNr++;



        idAddress[citizenNr] = sender;

        citizen[sender].id = citizenNr;

        

        uint256 refLevel = citizen[validRef].treeLevel;

        if (refLevel == lastLevel) lastLevel++;

        citizen[sender].treeLevel = refLevel + 1;

        levelCitizen[refLevel + 1].push(sender);

        //add child

        citizen[validRef].refTo.push(sender);

        updateTotalChild(sender);

        emit Register(sender, validRef);

    }



    function updateUsername(string _sNewUsername)

        public

        registered()

    {

        require(Helper.validUsername(_sNewUsername), "invalid username");

        address sender = msg.sender;

        uint256 _newUsername = Helper.stringToUint(_sNewUsername);

        require(usernameAddress[_newUsername] == 0x0, "username already exist");

        uint256 _oldUsername = citizen[sender].username;

        citizen[sender].username = _newUsername;

        usernameAddress[_oldUsername] = 0x0;

        usernameAddress[_newUsername] = sender;

    }



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



    /*----------  READ FUNCTIONS  ----------*/



    function getTotalChild(address _address)

        public

        view

        returns(uint256)

    {

        return citizen[_address].totalChild;

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

        return idAddress[_id];

    }



    function getAddressByUserName(string _username)

        public

        view

        returns (address)

    {

        return usernameAddress[Helper.stringToUint(_username)];

    }



    function exist(string _username)

        public

        view

        returns (bool)

    {

        return usernameAddress[Helper.stringToUint(_username)] != 0x0;

    }



    function getId(address _address)

        public

        view

        returns (uint256)

    {

        return citizen[_address].id;

    }



    function getUsername(address _address)

        public

        view

        returns (string)

    {

        if (!isCitizen[_address]) return "";

        return Helper.uintToString(citizen[_address].username);

    }



    function getUintUsername(address _address)

        public

        view

        returns (uint256)

    {

        return citizen[_address].username;

    }



    function getRef(address _address)

        public

        view

        returns (address)

    {

        return citizen[_address].ref == 0x0 ? devTeam : citizen[_address].ref;

    }



    function getRefTo(address _address)

        public

        view

        returns (address[])

    {

        return citizen[_address].refTo;

    }



    function getRefToById(address _address, uint256 _id)

        public

        view

        returns (address, string, uint256, uint256, uint256, uint256)

    {

        address _refTo = citizen[_address].refTo[_id];

        return (

            _refTo,

            Helper.uintToString(citizen[_refTo].username),

            citizen[_refTo].treeLevel,

            citizen[_refTo].refTo.length,

            citizen[_refTo].refWallet,

            citizen[_refTo].totalSale

            );

    }



    function getRefToLength(address _address)

        public

        view

        returns (uint256)

    {

        return citizen[_address].refTo.length;

    }



    function getLevelCitizenLength(uint256 _level)

        public

        view

        returns (uint256)

    {

        return levelCitizen[_level].length;

    }



    function getLevelCitizenById(uint256 _level, uint256 _id)

        public

        view

        returns (address)

    {

        return levelCitizen[_level][_id];

    }



    function getCitizenLevel(address _address)

        public

        view

        returns (uint256)

    {

        return citizen[_address].treeLevel;

    }



    function getLastLevel()

        public

        view

        returns(uint256)

    {

        return lastLevel;

    }



}