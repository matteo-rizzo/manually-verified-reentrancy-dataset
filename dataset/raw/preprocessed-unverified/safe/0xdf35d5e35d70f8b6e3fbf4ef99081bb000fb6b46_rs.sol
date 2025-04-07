/**

 *Submitted for verification at Etherscan.io on 2019-01-25

*/



pragma solidity ^0.4.24;

/*

 * -PlayerBook - beta

 */











contract PlayerBook {

    using NameFilter for string;

    using SafeMath for uint256;

    

    //address constant private NameFee = 0x4a1061afb0af7d9f6c2d545ada068da68052c060;

    //TeamInterface constant private Team = TeamInterface(0x8A9E4d7Ba824ce25e0E72971B3e969383B528c06);

    

    MSFun.Data private msData;

    //function multiSigDev(bytes32 _whatFunction) private returns (bool) {return(MSFun.multiSig(msData, Team.requiredDevSignatures(), _whatFunction));}

    function deleteProposal(bytes32 _whatFunction) private {MSFun.deleteProposal(msData, _whatFunction);}

    function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}

    function checkData(bytes32 _whatFunction) onlyDevs() public view returns(bytes32, uint256) {return(MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}

    function checkSignersByAddress(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyDevs() public view returns(address, address, address) {return(MSFun.checkSigner(msData, _whatFunction, _signerA), MSFun.checkSigner(msData, _whatFunction, _signerB), MSFun.checkSigner(msData, _whatFunction, _signerC));}

    //function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyDevs() public view returns(bytes32, bytes32, bytes32) {return(Team.adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), Team.adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), Team.adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}

//==============================================================================

//     _| _ _|_ _    _ _ _|_    _   .

//    (_|(_| | (_|  _\(/_ | |_||_)  .

//=============================|================================================    

    uint256 public registrationFee_ = 10 finney;            // price to register a name

    mapping(uint256 => PlayerBookReceiverInterface) public games_;  // mapping of our game interfaces for sending your account info to games

    mapping(address => bytes32) public gameNames_;          // lookup a games name

    mapping(address => uint256) public gameIDs_;            // lokup a games ID

    uint256 public gID_;        // total number of games

    uint256 public pID_;        // total number of players

    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address

    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name

    mapping (uint256 => Player) public plyr_;               // (pID => data) player data

    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amoungst any name you own)

    mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_; // (pID => nameNum => name) list of names a player owns

    struct Player {

        address addr;

        bytes32 name;

        uint256 names;

    }

//==============================================================================

//     _ _  _  __|_ _    __|_ _  _  .

//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)

//==============================================================================    

    constructor()

        public

    {

        // premine the dev names (sorry not sorry)

            // No keys are purchased with this method, it's simply locking our addresses,

            // PID's and names for referral codes.

        //plyr_[1].addr = 0x4a1061afb0af7d9f6c2d545ada068da68052c060;

        plyr_[1].name = "deployer";

        plyr_[1].names = 1;

        //pIDxAddr_[0x4a1061afb0af7d9f6c2d545ada068da68052c060] = 1;

        pIDxName_["deployer"] = 1;

        plyrNames_[1]["deployer"] = true;

        plyrNameList_[1][1] = "deployer";



        pID_ = 1;

    }

//==============================================================================

//     _ _  _  _|. |`. _  _ _  .

//    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)

//==============================================================================    

    /**

     * @dev prevents contracts from interacting with fomo3dx 

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

        //require(Team.isDev(msg.sender) == true, "msg sender is not a dev");

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

        returns(bool)

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

     * @param _nameString players desired name

     * @param _all set to true if you want this to push your info to all games 

     * (this might cost a lot of gas)

     */

    function registerNameXID(string _nameString, bool _all)

        isHuman()

        public

        payable 

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        

        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);

        

        // set up address 

        address _addr = msg.sender;

        

        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];

        

        // register name 

        registerNameCore(_pID, _addr, _name, _isNewPlayer, _all);

    }

    

    function registerNameXaddr(string _nameString, bool _all)

        isHuman()

        public

        payable 

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        

        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);

        

        // set up address 

        address _addr = msg.sender;

        

        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];

        

        // register name 

        registerNameCore(_pID, _addr, _name, _isNewPlayer, _all);

    }

    

    function registerNameXname(string _nameString, bool _all)

        isHuman()

        public

        payable 

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        

        // filter name + condition checks

        bytes32 _name = NameFilter.nameFilter(_nameString);

        

        // set up address 

        address _addr = msg.sender;

        

        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];

        

        // register name 

        registerNameCore(_pID, _addr, _name, _isNewPlayer, _all);

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

        games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name);

        

        // add list of all names

        if (_totalNames > 1)

            for (uint256 ii = 1; ii <= _totalNames; ii++)

                games_[_gameID].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);

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

        uint256 _totalNames = plyr_[_pID].names;

        bytes32 _name = plyr_[_pID].name;

        

        for (uint256 i = 1; i <= gID_; i++)

        {

            games_[i].receivePlayerInfo(_pID, _addr, _name);

            if (_totalNames > 1)

                for (uint256 ii = 1; ii <= _totalNames; ii++)

                    games_[i].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);

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

    function registerNameCore(uint256 _pID, address _addr, bytes32 _name, bool _isNewPlayer, bool _all)

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

        //NameFee.transfer(address(this).balance);

        

        // push player info to games

        if (_all == true)

            for (uint256 i = 1; i <= gID_; i++)

                games_[i].receivePlayerInfo(_pID, _addr, _name);

        

        // fire event

        emit onNewName(_pID, _addr, _name, _isNewPlayer, msg.value, now);

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

        return(registrationFee_);

    }

    function registerNameXIDFromDapp(address _addr, bytes32 _name, bool _all)

        isRegisteredGame()

        external

        payable

        returns(bool)

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        

        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];

    

        // register name 

        registerNameCore(_pID, _addr, _name, _isNewPlayer, _all);

        

        return(_isNewPlayer);

    }

    function registerNameXaddrFromDapp(address _addr, bytes32 _name, bool _all)

        isRegisteredGame()

        external

        payable

        returns(bool)

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        

        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // register name 

        registerNameCore(_pID, _addr, _name, _isNewPlayer, _all);

        

        return(_isNewPlayer);

    }

    function registerNameXnameFromDapp(address _addr, bytes32 _name, bool _all)

        isRegisteredGame()

        external

        payable

        returns(bool)

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        

        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);

        

        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];

        

        // register name 

        registerNameCore(_pID, _addr, _name, _isNewPlayer, _all);

        

        return(_isNewPlayer);

    }

    

//==============================================================================

//   _ _ _|_    _   .

//  _\(/_ | |_||_)  .

//=============|================================================================

    function addGame(address _gameAddress, string _gameNameStr)

        onlyDevs()

        public

    {

        require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");

        

        //if (multiSigDev("addGame") == true)

        {deleteProposal("addGame");

            gID_++;

            bytes32 _name = _gameNameStr.nameFilter();

            gameIDs_[_gameAddress] = gID_;

            gameNames_[_gameAddress] = _name;

            games_[gID_] = PlayerBookReceiverInterface(_gameAddress);

        

            games_[gID_].receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name);

        }

    }

    

    function setRegistrationFee(uint256 _fee)

        onlyDevs()

        public

    {

        //if (multiSigDev("setRegistrationFee") == true)

        {deleteProposal("setRegistrationFee");

            registrationFee_ = _fee;

        }

    }

        

}



/**

* @title -Name Filter- beta

*/







/**

 * @title SafeMath v0.1.9

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr 

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */





/** @title -MSFun- v0.2.4

 *

 */

