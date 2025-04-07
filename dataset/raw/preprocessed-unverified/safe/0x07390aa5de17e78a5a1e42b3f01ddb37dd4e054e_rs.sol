/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



pragma solidity ^0.4.24;

// produced by the Solididy File Flattener (c) David Appleton 2018

// contact : [emailÂ protected]

// released under Apache 2.0 licence















contract TeamJust is TeamJustInterface {

    address private Jekyll_Island_Inc;

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // SET UP MSFun (note, check signers by name is modified from MSFun sdk)

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    MSFun.Data private msData;

    function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}

    function checkData(bytes32 _whatFunction) onlyAdmins() public view returns(bytes32 message_data, uint256 signature_count) {return(MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}

    function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(bytes32, bytes32, bytes32) {return(this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}



    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // DATA SETUP

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    struct Admin {

        bool isAdmin;

        bool isDev;

        bytes32 name;

    }

    mapping (address => Admin) admins_;

    

    uint256 adminCount_;

    uint256 devCount_;

    uint256 requiredSignatures_;

    uint256 requiredDevSignatures_;

    

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // CONSTRUCTOR

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    constructor()

        public

    {

        Jekyll_Island_Inc = msg.sender;

        address inventor = 0x18E90Fc6F70344f53EBd4f6070bf6Aa23e2D748C;

        address mantso   = 0x8b4DA1827932D71759687f925D17F81Fc94e3A9D;

        address justo    = 0x8e0d985f3Ec1857BEc39B76aAabDEa6B31B67d53;

        address sumpunk  = 0x7ac74Fcc1a71b106F12c55ee8F802C9F672Ce40C;

		address deployer = msg.sender;

        

        admins_[inventor] = Admin(true, true, "inventor");

        admins_[mantso]   = Admin(true, true, "mantso");

        admins_[justo]    = Admin(true, true, "justo");

        admins_[sumpunk]  = Admin(true, true, "sumpunk");

		admins_[deployer] = Admin(true, true, "deployer");

        

        adminCount_ = 5;

        devCount_ = 5;

        requiredSignatures_ = 1;

        requiredDevSignatures_ = 1;

    }

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // FALLBACK, SETUP, AND FORWARD

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // there should never be a balance in this contract.  but if someone

    // does stupidly send eth here for some reason.  we can forward it 

    // to jekyll island

    function ()

        public

        payable

    {

        Jekyll_Island_Inc.transfer(address(this).balance);

    }





    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // MODIFIERS

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    modifier onlyDevs()

    {

        require(admins_[msg.sender].isDev == true, "onlyDevs failed - msg.sender is not a dev");

        _;

    }

    

    modifier onlyAdmins()

    {

        require(admins_[msg.sender].isAdmin == true, "onlyAdmins failed - msg.sender is not an admin");

        _;

    }



    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // DEV ONLY FUNCTIONS

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    /**

    * @dev DEV - use this to add admins.  this is a dev only function.

    * @param _who - address of the admin you wish to add

    * @param _name - admins name

    * @param _isDev - is this admin also a dev?

    */

    function addAdmin(address _who, bytes32 _name, bool _isDev)

        public

        onlyDevs()

    {

        if (MSFun.multiSig(msData, requiredDevSignatures_, "addAdmin") == true) 

        {

            MSFun.deleteProposal(msData, "addAdmin");

            

            // must check this so we dont mess up admin count by adding someone

            // who is already an admin

            if (admins_[_who].isAdmin == false) 

            { 

                

                // set admins flag to true in admin mapping

                admins_[_who].isAdmin = true;

        

                // adjust admin count and required signatures

                adminCount_ += 1;

                requiredSignatures_ += 1;

            }

            

            // are we setting them as a dev?

            // by putting this outside the above if statement, we can upgrade existing

            // admins to devs.

            if (_isDev == true) 

            {

                // bestow the honored dev status

                admins_[_who].isDev = _isDev;

                

                // increase dev count and required dev signatures

                devCount_ += 1;

                requiredDevSignatures_ += 1;

            }

        }

        

        // by putting this outside the above multisig, we can allow easy name changes

        // without having to bother with multisig.  this will still create a proposal though

        // so use the deleteAnyProposal to delete it if you want to

        admins_[_who].name = _name;

    }



    /**

    * @dev DEV - use this to remove admins. this is a dev only function.

    * -requirements: never less than 1 admin

    *                never less than 1 dev

    *                never less admins than required signatures

    *                never less devs than required dev signatures

    * @param _who - address of the admin you wish to remove

    */

    function removeAdmin(address _who)

        public

        onlyDevs()

    {

        // we can put our requires outside the multisig, this will prevent

        // creating a proposal that would never pass checks anyway.

        require(adminCount_ > 1, "removeAdmin failed - cannot have less than 2 admins");

        require(adminCount_ >= requiredSignatures_, "removeAdmin failed - cannot have less admins than number of required signatures");

        if (admins_[_who].isDev == true)

        {

            require(devCount_ > 1, "removeAdmin failed - cannot have less than 2 devs");

            require(devCount_ >= requiredDevSignatures_, "removeAdmin failed - cannot have less devs than number of required dev signatures");

        }

        

        // checks passed

        if (MSFun.multiSig(msData, requiredDevSignatures_, "removeAdmin") == true) 

        {

            MSFun.deleteProposal(msData, "removeAdmin");

            

            // must check this so we dont mess up admin count by removing someone

            // who wasnt an admin to start with

            if (admins_[_who].isAdmin == true) {  

                

                //set admins flag to false in admin mapping

                admins_[_who].isAdmin = false;

                

                //adjust admin count and required signatures

                adminCount_ -= 1;

                if (requiredSignatures_ > 1) 

                {

                    requiredSignatures_ -= 1;

                }

            }

            

            // were they also a dev?

            if (admins_[_who].isDev == true) {

                

                //set dev flag to false

                admins_[_who].isDev = false;

                

                //adjust dev count and required dev signatures

                devCount_ -= 1;

                if (requiredDevSignatures_ > 1) 

                {

                    requiredDevSignatures_ -= 1;

                }

            }

        }

    }



    /**

    * @dev DEV - change the number of required signatures.  must be between

    * 1 and the number of admins.  this is a dev only function

    * @param _howMany - desired number of required signatures

    */

    function changeRequiredSignatures(uint256 _howMany)

        public

        onlyDevs()

    {  

        // make sure its between 1 and number of admins

        require(_howMany > 0 && _howMany <= adminCount_, "changeRequiredSignatures failed - must be between 1 and number of admins");

        

        if (MSFun.multiSig(msData, requiredDevSignatures_, "changeRequiredSignatures") == true) 

        {

            MSFun.deleteProposal(msData, "changeRequiredSignatures");

            

            // store new setting.

            requiredSignatures_ = _howMany;

        }

    }

    

    /**

    * @dev DEV - change the number of required dev signatures.  must be between

    * 1 and the number of devs.  this is a dev only function

    * @param _howMany - desired number of required dev signatures

    */

    function changeRequiredDevSignatures(uint256 _howMany)

        public

        onlyDevs()

    {  

        // make sure its between 1 and number of admins

        require(_howMany > 0 && _howMany <= devCount_, "changeRequiredDevSignatures failed - must be between 1 and number of devs");

        

        if (MSFun.multiSig(msData, requiredDevSignatures_, "changeRequiredDevSignatures") == true) 

        {

            MSFun.deleteProposal(msData, "changeRequiredDevSignatures");

            

            // store new setting.

            requiredDevSignatures_ = _howMany;

        }

    }



    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // EXTERNAL FUNCTIONS 

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    function requiredSignatures() external view returns(uint256) {return(requiredSignatures_);}

    function requiredDevSignatures() external view returns(uint256) {return(requiredDevSignatures_);}

    function adminCount() external view returns(uint256) {return(adminCount_);}

    function devCount() external view returns(uint256) {return(devCount_);}

    function adminName(address _who) external view returns(bytes32) {return(admins_[_who].name);}

    function isAdmin(address _who) external view returns(bool) {return(admins_[_who].isAdmin);}

    function isDev(address _who) external view returns(bool) {return(admins_[_who].isDev);}

}

contract PlayerBook is PlayerBookInterface {

    using NameFilter for string;

    using SafeMath for uint256;



    address private Jekyll_Island_Inc;

    address public teamJust;// = new TeamJustInterface();



    MSFun.Data private msData;



    function multiSigDev(bytes32 _whatFunction) private returns (bool) {return (MSFun.multiSig(msData, TeamJustInterface(teamJust).requiredDevSignatures(), _whatFunction));}



    function deleteProposal(bytes32 _whatFunction) private {MSFun.deleteProposal(msData, _whatFunction);}



    function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}



    function checkData(bytes32 _whatFunction) onlyDevs() public view returns (bytes32, uint256) {return (MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}



    function checkSignersByAddress(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyDevs() public view returns (address, address, address) {return (MSFun.checkSigner(msData, _whatFunction, _signerA), MSFun.checkSigner(msData, _whatFunction, _signerB), MSFun.checkSigner(msData, _whatFunction, _signerC));}



    function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyDevs() public view returns (bytes32, bytes32, bytes32) {return (TeamJustInterface(teamJust).adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), TeamJustInterface(teamJust).adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), TeamJustInterface(teamJust).adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}

    //==============================================================================

    //     _| _ _|_ _    _ _ _|_    _   .

    //    (_|(_| | (_|  _\(/_ | |_||_)  .

    //=============================|================================================

    uint256 public registrationFee_ = 10 finney;            // price to register a name

    mapping(uint256 => address) public games_;  // mapping of our game interfaces for sending your account info to games

    mapping(address => bytes32) public gameNames_;          // lookup a games name

    mapping(address => uint256) public gameIDs_;            // lokup a games ID

    uint256 public gID_;        // total number of games

    uint256 public pID_;        // total number of players

    mapping(address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address

    mapping(bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name

    mapping(uint256 => Player) public plyr_;               // (pID => data) player data

    mapping(uint256 => mapping(bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amoungst any name you own)

    mapping(uint256 => mapping(uint256 => bytes32)) public plyrNameList_; // (pID => nameNum => name) list of names a player owns

    struct Player {

        address addr;

        bytes32 name;

        uint256 laff;

        uint256 names;

    }



    address public owner;



    function setTeam(address _teamJust) external {

        require(msg.sender == owner, 'only dev!');

        require(address(teamJust) == address(0), 'already set!');

        teamJust = _teamJust;

    }

    //==============================================================================

    //     _ _  _  __|_ _    __|_ _  _  .

    //    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)

    //==============================================================================

    constructor()

    public

    {

        owner = msg.sender;

        // premine the dev names (sorry not sorry)

        // No keys are purchased with this method, it's simply locking our addresses,

        // PID's and names for referral codes.

        plyr_[1].addr = msg.sender;

        plyr_[1].name = "wq";

        plyr_[1].names = 1;

        pIDxAddr_[msg.sender] = 1;

        pIDxName_["wq"] = 1;

        plyrNames_[1]["wq"] = true;

        plyrNameList_[1][1] = "wq";



        pID_ = 1;

        Jekyll_Island_Inc = msg.sender;

    }

    //==============================================================================

    //     _ _  _  _|. |`. _  _ _  .

    //    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)

    //==============================================================================

    /**

     * @dev prevents contracts from interacting with fomo3d 

     */

    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



    modifier onlyDevs()

    {

        require(TeamJustInterface(teamJust).isDev(msg.sender) == true, "msg sender is not a dev");

        _;

    }



    modifier isRegisteredGame()

    {

        require(gameIDs_[msg.sender] != 0);

        _;

    }

    //==============================================================================

    //     _    _  _ _|_ _  .

    //    (/_\/(/_| | | _\  .

    //==============================================================================

    // fired whenever a player registers a name

    event onNewName

    (

        uint256 indexed playerID,

        address indexed playerAddress,

        bytes32 indexed playerName,

        bool isNewPlayer,

        uint256 affiliateID,

        address affiliateAddress,

        bytes32 affiliateName,

        uint256 amountPaid,

        uint256 timeStamp

    );

    //==============================================================================

    //     _  _ _|__|_ _  _ _  .

    //    (_|(/_ |  | (/_| _\  . (for UI & viewing things on etherscan)

    //=====_|=======================================================================

    function checkIfNameValid(string _nameStr)

    public

    view

    returns (bool)

    {

        bytes32 _name = _nameStr.nameFilter();

        if (pIDxName_[_name] == 0)

            return (true);

        else

            return (false);

    }

    //==============================================================================

    //     _    |_ |. _   |`    _  __|_. _  _  _  .

    //    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)

    //====|=========================================================================

    /**

     * @dev registers a name.  UI will always display the last name you registered.

     * but you will still own all previously registered names to use as affiliate 

     * links.

     * - must pay a registration fee.

     * - name must be unique

     * - names will be converted to lowercase

     * - name cannot start or end with a space 

     * - cannot have more than 1 space in a row

     * - cannot be only numbers

     * - cannot start with 0x 

     * - name must be at least 1 char

     * - max length of 32 characters long

     * - allowed characters: a-z, 0-9, and space

     * -functionhash- 0x921dec21 (using ID for affiliate)

     * -functionhash- 0x3ddd4698 (using address for affiliate)

     * -functionhash- 0x685ffd83 (using name for affiliate)

     * @param _nameString players desired name

     * @param _affCode affiliate ID, address, or name of who refered you

     * @param _all set to true if you want this to push your info to all games 

     * (this might cost a lot of gas)

     */

    function registerNameXID(string _nameString, uint256 _affCode, bool _all)

    isHuman()

    public

    payable

    {

        // make sure name fees paid

        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);



        // set up address 

        address _addr = msg.sender;



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given, no new affiliate code was given, or the 

        // player tried to use their own pID as an affiliate code, lolz

        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID)

        {

            // update last affiliate 

            plyr_[_pID].laff = _affCode;

        } else if (_affCode == _pID) {

            _affCode = 0;

        }



        // register name 

        registerNameCore(_pID, _addr, _affCode, _name, _isNewPlayer, _all);

    }



    function registerNameXaddr(string _nameString, address _affCode, bool _all)

    isHuman()

    public

    payable

    {

        // make sure name fees paid

        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);



        // set up address 

        address _addr = msg.sender;



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given or player tried to use their own, lolz

        uint256 _affID;

        if (_affCode != address(0) && _affCode != _addr)

        {

            // get affiliate ID from aff Code 

            _affID = pIDxAddr_[_affCode];



            // if affID is not the same as previously stored 

            if (_affID != plyr_[_pID].laff)

            {

                // update last affiliate

                plyr_[_pID].laff = _affID;

            }

        }



        // register name 

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

    }



    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)

    isHuman()

    public

    payable

    {

        // make sure name fees paid

        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);



        // set up address 

        address _addr = msg.sender;



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given or player tried to use their own, lolz

        uint256 _affID;

        if (_affCode != "" && _affCode != _name)

        {

            // get affiliate ID from aff Code 

            _affID = pIDxName_[_affCode];



            // if affID is not the same as previously stored 

            if (_affID != plyr_[_pID].laff)

            {

                // update last affiliate

                plyr_[_pID].laff = _affID;

            }

        }



        // register name 

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

    }



    /**

     * @dev players, if you registered a profile, before a game was released, or

     * set the all bool to false when you registered, use this function to push

     * your profile to a single game.  also, if you've  updated your name, you

     * can use this to push your name to games of your choosing.

     * -functionhash- 0x81c5b206

     * @param _gameID game id 

     */

    function addMeToGame(uint256 _gameID)

    isHuman()

    public

    {

        require(_gameID <= gID_, "silly player, that game doesn't exist yet");

        address _addr = msg.sender;

        uint256 _pID = pIDxAddr_[_addr];

        require(_pID != 0, "hey there buddy, you dont even have an account");

        uint256 _totalNames = plyr_[_pID].names;



        // add players profile and most recent name

        PlayerBookReceiverInterface(games_[_gameID]).receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);



        // add list of all names

        if (_totalNames > 1)

            for (uint256 ii = 1; ii <= _totalNames; ii++)

                PlayerBookReceiverInterface(games_[_gameID]).receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);

    }



    /**

     * @dev players, use this to push your player profile to all registered games.

     * -functionhash- 0x0c6940ea

     */

    function addMeToAllGames()

    isHuman()

    public

    {

        address _addr = msg.sender;

        uint256 _pID = pIDxAddr_[_addr];

        require(_pID != 0, "hey there buddy, you dont even have an account");

        uint256 _laff = plyr_[_pID].laff;

        uint256 _totalNames = plyr_[_pID].names;

        bytes32 _name = plyr_[_pID].name;



        for (uint256 i = 1; i <= gID_; i++)

        {

            PlayerBookReceiverInterface(games_[i]).receivePlayerInfo(_pID, _addr, _name, _laff);

            if (_totalNames > 1)

                for (uint256 ii = 1; ii <= _totalNames; ii++)

                    PlayerBookReceiverInterface(games_[i]).receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);

        }



    }



    /**

     * @dev players use this to change back to one of your old names.  tip, you'll

     * still need to push that info to existing games.

     * -functionhash- 0xb9291296

     * @param _nameString the name you want to use 

     */

    function useMyOldName(string _nameString)

    isHuman()

    public

    {

        // filter name, and get pID

        bytes32 _name = _nameString.nameFilter();

        uint256 _pID = pIDxAddr_[msg.sender];



        // make sure they own the name 

        require(plyrNames_[_pID][_name] == true, "umm... thats not a name you own");



        // update their current name 

        plyr_[_pID].name = _name;

    }



    //==============================================================================

    //     _ _  _ _   | _  _ . _  .

    //    (_(_)| (/_  |(_)(_||(_  .

    //=====================_|=======================================================

    function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer, bool _all)

    private

    {

        // if names already has been used, require that current msg sender owns the name

        if (pIDxName_[_name] != 0)

            require(plyrNames_[_pID][_name] == true, "sorry that names already taken");



        // add name to player profile, registry, and name book

        plyr_[_pID].name = _name;

        pIDxName_[_name] = _pID;

        if (plyrNames_[_pID][_name] == false)

        {

            plyrNames_[_pID][_name] = true;

            plyr_[_pID].names++;

            plyrNameList_[_pID][plyr_[_pID].names] = _name;

        }



        // registration fee goes directly to community rewards

        Jekyll_Island_Inc.transfer(address(this).balance);



        // push player info to games

        if (_all == true)

            for (uint256 i = 1; i <= gID_; i++)

                PlayerBookReceiverInterface(games_[i]).receivePlayerInfo(_pID, _addr, _name, _affID);



        // fire event

        emit onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, msg.value, now);

    }

    //==============================================================================

    //    _|_ _  _ | _  .

    //     | (_)(_)|_\  .

    //==============================================================================

    function determinePID(address _addr)

    private

    returns (bool)

    {

        if (pIDxAddr_[_addr] == 0)

        {

            pID_++;

            pIDxAddr_[_addr] = pID_;

            plyr_[pID_].addr = _addr;



            // set the new player bool to true

            return (true);

        } else {

            return (false);

        }

    }

    //==============================================================================

    //   _   _|_ _  _ _  _ |   _ _ || _  .

    //  (/_>< | (/_| | |(_||  (_(_|||_\  .

    //==============================================================================

    function getPlayerID(address _addr)

    isRegisteredGame()

    external

    returns (uint256)

    {

        determinePID(_addr);

        return (pIDxAddr_[_addr]);

    }



    function getPlayerName(uint256 _pID)

    external

    view

    returns (bytes32)

    {

        return (plyr_[_pID].name);

    }



    function getPlayerLAff(uint256 _pID)

    external

    view

    returns (uint256)

    {

        return (plyr_[_pID].laff);

    }



    function getPlayerAddr(uint256 _pID)

    external

    view

    returns (address)

    {

        return (plyr_[_pID].addr);

    }



    function getNameFee()

    external

    view

    returns (uint256)

    {

        return (registrationFee_);

    }



    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all)

    isRegisteredGame()

    external

    payable

    returns (bool, uint256)

    {

        // make sure name fees paid

        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given, no new affiliate code was given, or the 

        // player tried to use their own pID as an affiliate code, lolz

        uint256 _affID = _affCode;

        if (_affID != 0 && _affID != plyr_[_pID].laff && _affID != _pID)

        {

            // update last affiliate 

            plyr_[_pID].laff = _affID;

        } else if (_affID == _pID) {

            _affID = 0;

        }



        // register name 

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);



        return (_isNewPlayer, _affID);

    }



    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all)

    isRegisteredGame()

    external

    payable

    returns (bool, uint256)

    {

        // make sure name fees paid

        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given or player tried to use their own, lolz

        uint256 _affID;

        if (_affCode != address(0) && _affCode != _addr)

        {

            // get affiliate ID from aff Code 

            _affID = pIDxAddr_[_affCode];



            // if affID is not the same as previously stored 

            if (_affID != plyr_[_pID].laff)

            {

                // update last affiliate

                plyr_[_pID].laff = _affID;

            }

        }



        // register name 

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);



        return (_isNewPlayer, _affID);

    }



    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all)

    isRegisteredGame()

    external

    payable

    returns (bool, uint256)

    {

        // make sure name fees paid

        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given or player tried to use their own, lolz

        uint256 _affID;

        if (_affCode != "" && _affCode != _name)

        {

            // get affiliate ID from aff Code 

            _affID = pIDxName_[_affCode];



            // if affID is not the same as previously stored 

            if (_affID != plyr_[_pID].laff)

            {

                // update last affiliate

                plyr_[_pID].laff = _affID;

            }

        }



        // register name 

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);



        return (_isNewPlayer, _affID);

    }



    //==============================================================================

    //   _ _ _|_    _   .

    //  _\(/_ | |_||_)  .

    //=============|================================================================

    function addGame(address _gameAddress, bytes32 _gameNameStr)

    onlyDevs()

    external

    {

        require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");



        if (multiSigDev("addGame") == true)

        {deleteProposal("addGame");

            gID_++;

            bytes32 _name = _gameNameStr;

            gameIDs_[_gameAddress] = gID_;

            gameNames_[_gameAddress] = _name;

            games_[gID_] = _gameAddress;



//            PlayerBookReceiverInterface(games_[gID_]).receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name, 0);



        }

    }



    function setRegistrationFee(uint256 _fee)

    onlyDevs()

    public

    {

        if (multiSigDev("setRegistrationFee") == true)

        {deleteProposal("setRegistrationFee");

            registrationFee_ = _fee;

        }

    }



    function isDev(address _who) external view returns(bool) {return TeamJustInterface(teamJust).isDev(_who);}



}