/**

 *Submitted for verification at Etherscan.io on 2018-08-25

*/



pragma solidity ^0.4.24;



// File: contracts\library\SafeMath.sol



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





// File: contracts\library\NameFilter.sol



/**

* @title -Name Filter- v0.1.9

* ┌┬┐┌─┐┌─┐┌┬┐   ╦╦ ╦╔═╗╔╦╗  ┌─┐┬─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐

*  │ ├┤ ├─┤│││   ║║ ║╚═╗ ║   ├─┘├┬┘├┤ └─┐├┤ │││ │ └─┐

*  ┴ └─┘┴ ┴┴ ┴  ╚╝╚═╝╚═╝ ╩   ┴  ┴└─└─┘└─┘└─┘┘└┘ ┴ └─┘

*                                  _____                      _____

*                                 (, /     /)       /) /)    (, /      /)          /)

*          ┌─┐                      /   _ (/_      // //       /  _   // _   __  _(/

*          ├─┤                  ___/___(/_/(__(_/_(/_(/_   ___/__/_)_(/_(_(_/ (_(_(_

*          ┴ ┴                /   /          .-/ _____   (__ /                               

*                            (__ /          (_/ (, /                                      /)™ 

*                                                 /  __  __ __ __  _   __ __  _  _/_ _  _(/

* ┌─┐┬─┐┌─┐┌┬┐┬ ┬┌─┐┌┬┐                          /__/ (_(__(_)/ (_/_)_(_)/ (_(_(_(__(/_(_(_

* ├─┘├┬┘│ │ │││ ││   │                      (__ /              .-/  © Jekyll Island Inc. 2018

* ┴  ┴└─└─┘─┴┘└─┘└─┘ ┴                                        (_/

*              _       __    _      ____      ____  _   _    _____  ____  ___  

*=============| |\ |  / /\  | |\/| | |_ =====| |_  | | | |    | |  | |_  | |_)==============*

*=============|_| \| /_/--\ |_|  | |_|__=====|_|   |_| |_|__  |_|  |_|__ |_| \==============*

*

* ╔═╗┌─┐┌┐┌┌┬┐┬─┐┌─┐┌─┐┌┬┐  ╔═╗┌─┐┌┬┐┌─┐ ┌──────────┐

* ║  │ ││││ │ ├┬┘├─┤│   │   ║  │ │ ││├┤  │ Inventor │

* ╚═╝└─┘┘└┘ ┴ ┴└─┴ ┴└─┘ ┴   ╚═╝└─┘─┴┘└─┘ └──────────┘

*/







// File: contracts\library\MSFun.sol



/** @title -MSFun- v0.2.4

 * ┌┬┐┌─┐┌─┐┌┬┐   ╦╦ ╦╔═╗╔╦╗  ┌─┐┬─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐

 *  │ ├┤ ├─┤│││   ║║ ║╚═╗ ║   ├─┘├┬┘├┤ └─┐├┤ │││ │ └─┐

 *  ┴ └─┘┴ ┴┴ ┴  ╚╝╚═╝╚═╝ ╩   ┴  ┴└─└─┘└─┘└─┘┘└┘ ┴ └─┘

 *                                  _____                      _____

 *                                 (, /     /)       /) /)    (, /      /)          /)

 *          ┌─┐                      /   _ (/_      // //       /  _   // _   __  _(/

 *          ├─┤                  ___/___(/_/(__(_/_(/_(/_   ___/__/_)_(/_(_(_/ (_(_(_

 *          ┴ ┴                /   /          .-/ _____   (__ /                               

 *                            (__ /          (_/ (, /                                      /)™ 

 *                                                 /  __  __ __ __  _   __ __  _  _/_ _  _(/

 * ┌─┐┬─┐┌─┐┌┬┐┬ ┬┌─┐┌┬┐                          /__/ (_(__(_)/ (_/_)_(_)/ (_(_(_(__(/_(_(_

 * ├─┘├┬┘│ │ │││ ││   │                      (__ /              .-/  © Jekyll Island Inc. 2018

 * ┴  ┴└─└─┘─┴┘└─┘└─┘ ┴                                        (_/

 *  _           _             _  _  _  _             _  _  _  _  _                                      

 *=(_) _     _ (_)==========_(_)(_)(_)(_)_==========(_)(_)(_)(_)(_)================================*

 * (_)(_)   (_)(_)         (_)          (_)         (_)       _         _    _  _  _  _                 

 * (_) (_)_(_) (_)         (_)_  _  _  _            (_) _  _ (_)       (_)  (_)(_)(_)(_)_               

 * (_)   (_)   (_)           (_)(_)(_)(_)_          (_)(_)(_)(_)       (_)  (_)        (_)              

 * (_)         (_)  _  _    _           (_)  _  _   (_)      (_)       (_)  (_)        (_)  _  _        

 *=(_)=========(_)=(_)(_)==(_)_  _  _  _(_)=(_)(_)==(_)======(_)_  _  _(_)_ (_)========(_)=(_)(_)==*

 * (_)         (_) (_)(_)    (_)(_)(_)(_)   (_)(_)  (_)        (_)(_)(_) (_)(_)        (_) (_)(_)

 *

 * ╔═╗┌─┐┌┐┌┌┬┐┬─┐┌─┐┌─┐┌┬┐  ╔═╗┌─┐┌┬┐┌─┐ ┌──────────┐

 * ║  │ ││││ │ ├┬┘├─┤│   │   ║  │ │ ││├┤  │ Inventor │

 * ╚═╝└─┘┘└┘ ┴ ┴└─┴ ┴└─┘ ┴   ╚═╝└─┘─┴┘└─┘ └──────────┘

 *  

 *         ┌──────────────────────────────────────────────────────────────────────┐

 *         │ MSFun, is an importable library that gives your contract the ability │

 *         │ add multiSig requirement to functions.                               │

 *         └──────────────────────────────────────────────────────────────────────┘

 *                                ┌────────────────────┐

 *                                │ Setup Instructions │

 *                                └────────────────────┘

 * (Step 1) import the library into your contract

 * 

 *    import "./MSFun.sol";

 *

 * (Step 2) set up the signature data for msFun

 * 

 *     MSFun.Data private msData;

 *                                ┌────────────────────┐

 *                                │ Usage Instructions │

 *                                └────────────────────┘

 * at the beginning of a function

 * 

 *     function functionName() 

 *     {

 *         if (MSFun.multiSig(msData, required signatures, "functionName") == true)

 *         {

 *             MSFun.deleteProposal(msData, "functionName");

 * 

 *             // put function body here 

 *         }

 *     }

 *                           ┌────────────────────────────────┐

 *                           │ Optional Wrappers For TeamJust │

 *                           └────────────────────────────────┘

 * multiSig wrapper function (cuts down on inputs, improves readability)

 * this wrapper is HIGHLY recommended

 * 

 *     function multiSig(bytes32 _whatFunction) private returns (bool) {return(MSFun.multiSig(msData, TeamJust.requiredSignatures(), _whatFunction));}

 *     function multiSigDev(bytes32 _whatFunction) private returns (bool) {return(MSFun.multiSig(msData, TeamJust.requiredDevSignatures(), _whatFunction));}

 *

 * wrapper for delete proposal (makes code cleaner)

 *     

 *     function deleteProposal(bytes32 _whatFunction) private {MSFun.deleteProposal(msData, _whatFunction);}

 *                             ┌────────────────────────────┐

 *                             │ Utility & Vanity Functions │

 *                             └────────────────────────────┘

 * delete any proposal is highly recommended.  without it, if an admin calls a multiSig

 * function, with argument inputs that the other admins do not agree upon, the function

 * can never be executed until the undesirable arguments are approved.

 * 

 *     function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}

 * 

 * for viewing who has signed a proposal & proposal data

 *     

 *     function checkData(bytes32 _whatFunction) onlyAdmins() public view returns(bytes32, uint256) {return(MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}

 *

 * lets you check address of up to 3 signers (address)

 * 

 *     function checkSignersByAddress(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(address, address, address) {return(MSFun.checkSigner(msData, _whatFunction, _signerA), MSFun.checkSigner(msData, _whatFunction, _signerB), MSFun.checkSigner(msData, _whatFunction, _signerC));}

 *

 * same as above but will return names in string format.

 *

 *     function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(bytes32, bytes32, bytes32) {return(TeamJust.adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), TeamJust.adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), TeamJust.adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}

 *                             ┌──────────────────────────┐

 *                             │ Functions In Depth Guide │

 *                             └──────────────────────────┘

 * In the following examples, the Data is the proposal set for this library.  And

 * the bytes32 is the name of the function.

 *

 * MSFun.multiSig(Data, uint256, bytes32) - Manages creating/updating multiSig 

 *      proposal for the function being called.  The uint256 is the required 

 *      number of signatures needed before the multiSig will return true.  

 *      Upon first call, multiSig will create a proposal and store the arguments 

 *      passed with the function call as msgData.  Any admins trying to sign the 

 *      function call will need to send the same argument values. Once required

 *      number of signatures is reached this will return a bool of true.

 * 

 * MSFun.deleteProposal(Data, bytes32) - once multiSig unlocks the function body,

 *      you will want to delete the proposal data.  This does that.

 *

 * MSFun.checkMsgData(Data, bytes32) - checks the message data for any given proposal 

 * 

 * MSFun.checkCount(Data, bytes32) - checks the number of admins that have signed

 *      the proposal 

 * 

 * MSFun.checkSigners(data, bytes32, uint256) - checks the address of a given signer.

 *      the uint256, is the log number of the signer (ie 1st signer, 2nd signer)

 */







// File: contracts\interface\PlayerBookReceiverInterface.sol







// File: contracts\interface\PlayerBookInterface.sol







// File: contracts\PlayerBook.sol



contract PlayerBook is PlayerBookInterface {

    using NameFilter for string;

    using SafeMath for uint256;



    //TODO: 收取购买推荐资格费用账号

    address public affWallet = 0xed68B3eD49571F1884cf2b5824656DdE35cdf54D;







    //==============================================================================

    //     _| _ _|_ _    _ _ _|_    _   .

    //    (_|(_| | (_|  _\(/_ | |_||_)  .

    //=============================|================================================

    uint256 public registrationFee_ = 20 finney;            // 购买推荐资格的费用



    mapping(uint256 => PlayerBookReceiverInterface) public games_;  // mapping of our game interfaces for sending your account info to games

    mapping(address => bytes32) public gameNames_;          // lookup a games name

    mapping(address => uint256) public gameIDs_;            // lokup a games ID

    uint256 public gID_;        // 游戏的局数

    uint256 public pID_;        // 合约总共的会员数目

    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) 根据会员的钱包地址查询id

    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) 根据会员的名字查询id

    mapping (uint256 => Player) public plyr_;               // (pID => data) 会员数据库

    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amoungst any name you own)

    mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_; // (pID => nameNum => name) list of names a player owns





    struct Player {

        address addr; //会员的地址

        bytes32 name; //会员的名字

        uint256 laff; //会员最后一次的推荐人

        uint256 names; //会员姓名列表 可以删掉TODO

        bool    isAgent; //是否成为代理

        bool    isHasRec; //是否有推荐资格

    }

//==============================================================================

//     _ _  _  __|_ _    __|_ _  _  .

//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)

//==============================================================================

    constructor()

        public

    {



        plyr_[1].addr = 0xe4b3a6f1556aec6de2a7c8accdfb288d2bfb3371;

        plyr_[1].name = "system";

        plyr_[1].names = 1;

        pIDxAddr_[0xe4b3a6f1556aec6de2a7c8accdfb288d2bfb3371] = 1;

        pIDxName_["system"] = 1;

        plyrNames_[1]["system"] = true;

        plyrNameList_[1][1] = "system";



        pID_ = 1;

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



    modifier onlyDevs() {

        //TODO:

        require(

            msg.sender == 0x2191eF87E392377ec08E7c08Eb105Ef5448eCED5 ||

            msg.sender == 0xE003d8A487ef29668d034f73F3155E78247b89cb,

            "only team just can activate"

        );

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

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



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

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



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

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



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

        games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);



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

        uint256 _laff = plyr_[_pID].laff;

        uint256 _totalNames = plyr_[_pID].names;

        bytes32 _name = plyr_[_pID].name;



        for (uint256 i = 1; i <= gID_; i++)

        {

            games_[i].receivePlayerInfo(_pID, _addr, _name, _laff);

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

        //Jekyll_Island_Inc.deposit.value(address(this).balance)();

        affWallet.transfer(address(this).balance);

        // push player info to games

        if (_all == true)

            for (uint256 i = 1; i <= gID_; i++)

                games_[i].receivePlayerInfo(_pID, _addr, _name, _affID);



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

        return(registrationFee_);

    }



    function registerAgent()

        external

        payable

    {





    }



    /**

     *

     * 购买推荐资格

     *

     */

    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all)

        isRegisteredGame()

        external

        payable

        returns(bool, uint256)

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given, no new affiliate code was given, or the

        // player tried to use their own pID as an affiliate code, lolz

        if (plyr_[_pID].laff == 0) {

            if(_affCode != 0 && _affCode != _pID && plyr_[_affCode].name != ""){

                plyr_[_pID].laff = _affCode;

            }else{

                plyr_[_pID].laff = 1;

            }

        }



        // register name

        registerNameCore(_pID, _addr, plyr_[_pID].laff, _name, _isNewPlayer, _all);



        return(_isNewPlayer, plyr_[_pID].laff);

    }

    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all)

        isRegisteredGame()

        external

        payable

        returns(bool, uint256)

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given or player tried to use their own, lolz

        if (plyr_[_pID].laff == 0) {

            if (_affCode != address(0) && _affCode != msg.sender && plyr_[pIDxAddr_[_affCode]].name != "") {

                plyr_[_pID].laff = pIDxAddr_[_affCode];

            }else{

                plyr_[_pID].laff = 1;

            }

        }



        // register name

        registerNameCore(_pID, _addr, plyr_[_pID].laff, _name, _isNewPlayer, _all);



        return(_isNewPlayer, plyr_[_pID].laff);

    }

    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all)

        isRegisteredGame()

        external

        payable

        returns(bool, uint256)

    {

        // make sure name fees paid

        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



        // set up our tx event data and determine if player is new or not

        bool _isNewPlayer = determinePID(_addr);



        // fetch player id

        uint256 _pID = pIDxAddr_[_addr];



        // manage affiliate residuals

        // if no affiliate code was given or player tried to use their own, lolz

        if (plyr_[_pID].laff == 0) {

            if (_affCode != "" && _affCode != _name) {

                plyr_[_pID].laff = pIDxName_[_affCode];

            }else{

                plyr_[_pID].laff = 1;

            }

        }



        // register name

        registerNameCore(_pID, _addr, plyr_[_pID].laff, _name, _isNewPlayer, _all);



        return(_isNewPlayer, plyr_[_pID].laff);

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



        gID_++;

        bytes32 _name = _gameNameStr.nameFilter();

        gameIDs_[_gameAddress] = gID_;

        gameNames_[_gameAddress] = _name;

        games_[gID_] = PlayerBookReceiverInterface(_gameAddress);



        games_[gID_].receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name, 0);



    }



    function setRegistrationFee(uint256 _fee)

        onlyDevs()

        public

    {



        registrationFee_ = _fee;



    }



}