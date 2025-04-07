/**

 *Submitted for verification at Etherscan.io on 2018-08-09

*/



pragma solidity ^0.4.24;



/**

 * @dev winner events

 */

contract WinnerEvents {



    event onBuy

    (

        address paddr,

        uint256 ethIn,

        string  reff,

        uint256 timeStamp

    );



    event onBuyUseBalance

    (

        address paddr,

        uint256 keys,

        uint256 timeStamp

    );



    event onBuyName

    (

        address paddr,

        bytes32 pname,

        uint256 ethIn,

        uint256 timeStamp

    );



    event onWithdraw

    (

        address paddr,

        uint256 ethOut,

        uint256 timeStamp

    );



    event onUpRoundID

    (

        uint256 roundID

    );



    event onUpPlayer

    (

        address addr,

        bytes32 pname,

        uint256 balance,

        uint256 interest,

        uint256 win,

        uint256 reff

    );



    event onAddPlayerOrder

    (

        address addr,

        uint256 keys,

        uint256 eth,

        uint256 otype

    );



    event onUpPlayerRound

    (

        address addr,

        uint256 roundID,

        uint256 eth,

        uint256 keys,

        uint256 interest,

        uint256 win,

        uint256 reff

    );





    event onUpRound

    (

        uint256 roundID,

        address leader,

        uint256 start,

        uint256 end,

        bool ended,

        uint256 keys,

        uint256 eth,

        uint256 pool,

        uint256 interest,

        uint256 win,

        uint256 reff

    );





}



/*

 *  @dev winner contract

 */

contract Winner is WinnerEvents {

    using SafeMath for *;

    using NameFilter for string;



//==============================================================================

// game settings

//==============================================================================



    string constant public name = "Im Winner Game";

    string constant public symbol = "IMW";





//==============================================================================

// public state variables

//==============================================================================



    // activated flag

    bool public activated_ = false;



    // round id

    uint256 public roundID_;



    // *************

    // player data

    // *************



    uint256 private pIDCount_;



    // return pid by address

    mapping(address => uint256) public address2PID_;



    // return player data by pid (pid => player)

    mapping(uint256 => WinnerDatasets.Player) public pID2Player_;



    // return player round data (pid => rid => player round data)

    mapping(uint256 => mapping(uint256 => WinnerDatasets.PlayerRound)) public pID2Round_;



    // return player order data (pid => rid => player order data)

    mapping(uint256 => mapping(uint256 => WinnerDatasets.PlayerOrder[])) public pID2Order_;



    // *************

    // round data

    // *************



    // return the round data by rid (rid => round)

    mapping(uint256 => WinnerDatasets.Round) public rID2Round_;





    constructor()

        public

    {

        pIDCount_ = 0;

    }





//==============================================================================

// function modifiers

//==============================================================================





    /*

     * @dev check if the contract is activated

     */

     modifier isActivated() {

        require(activated_ == true, "the contract is not ready yet");

        _;

     }



     /**

     * @dev check if the msg sender is human account

     */

    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;

        

        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



     /*

      * @dev check if admin or not 

      */

    modifier isAdmin() {

        require( msg.sender == 0x74B25afBbd16Ef94d6a32c311d5c184a736850D3, "sorry admins only");

        _;

    }



    /**

     * @dev sets boundaries for incoming tx 

     */

    modifier isWithinLimits(uint256 _eth) {

        require(_eth >= 10000000000, "eth too small");

        require(_eth <= 100000000000000000000000, "eth too huge");

        _;    

    }



//==============================================================================

// public functions

//==============================================================================



    /*

     *  @dev send eth to contract

     */

    function ()

    isActivated()

    isHuman()

    isWithinLimits(msg.value)

    public

    payable {

        buyCore(msg.sender, msg.value, "");

    }



    /*

     *  @dev send eth to contract

     */

    function buyKey()

    isActivated()

    isHuman()

    isWithinLimits(msg.value)

    public

    payable {

        buyCore(msg.sender, msg.value, "");

    }



    /*

     *  @dev send eth to contract

     */

    function buyKeyWithReff(string reff)

    isActivated()

    isHuman()

    isWithinLimits(msg.value)

    public

    payable {

        buyCore(msg.sender, msg.value, reff);

    }



    /*

     *  @dev buy key use balance

     */



    function buyKeyUseBalance(uint256 keys) 

    isActivated()

    isHuman()

    public {



        uint256 pID = address2PID_[msg.sender];

        require(pID > 0, "cannot find player");



        // fire buy  event 

        emit WinnerEvents.onBuyUseBalance

        (

            msg.sender, 

            keys, 

            now

        );

    }





    /*

     *  @dev buy name

     */

    function buyName(string pname)

    isActivated()

    isHuman()

    isWithinLimits(msg.value)

    public

    payable {



        uint256 pID = address2PID_[msg.sender];



        // new player

        if( pID == 0 ) {

            pIDCount_++;



            pID = pIDCount_;

            WinnerDatasets.Player memory player = WinnerDatasets.Player(pID, msg.sender, 0, 0, 0, 0, 0);

            WinnerDatasets.PlayerRound memory playerRound = WinnerDatasets.PlayerRound(0, 0, 0, 0, 0);



            pID2Player_[pID] = player;

            pID2Round_[pID][roundID_] = playerRound;



            address2PID_[msg.sender] = pID;

        }



        pID2Player_[pID].pname = pname.nameFilter();



        // fire buy  event 

        emit WinnerEvents.onBuyName

        (

            msg.sender, 

            pID2Player_[pID].pname, 

            msg.value, 

            now

        );

        

    }



//==============================================================================

// private functions

//==============================================================================    



    function buyCore(address addr, uint256 eth, string reff) 

    private {

        uint256 pID = address2PID_[addr];



        // new player

        if( pID == 0 ) {

            pIDCount_++;



            pID = pIDCount_;

            WinnerDatasets.Player memory player = WinnerDatasets.Player(pID, addr, 0, 0, 0, 0, 0);

            WinnerDatasets.PlayerRound memory playerRound = WinnerDatasets.PlayerRound(0, 0, 0, 0, 0);



            pID2Player_[pID] = player;

            pID2Round_[pID][roundID_] = playerRound;



            address2PID_[addr] = pID;

        }



        // fire buy  event 

        emit WinnerEvents.onBuy

        (

            addr, 

            eth, 

            reff,

            now

        );

    }



    

//==============================================================================

// admin functions

//==============================================================================    



    /*

     * @dev activate the contract

     */

    function activate() 

    isAdmin()

    public {



        require( activated_ == false, "contract is activated");



        activated_ = true;



        // start the first round

        roundID_ = 1;

    }



    /**

     *  @dev inactivate the contract

     */

    function inactivate()

    isAdmin()

    isActivated()

    public {



        activated_ = false;

    }



    /*

     *  @dev user withdraw

     */

    function withdraw(address addr, uint256 eth)

    isActivated() 

    isAdmin() 

    isWithinLimits(eth) 

    public {



        uint pID = address2PID_[addr];

        require(pID > 0, "user not exist");



        addr.transfer(eth);



        // fire the withdraw event

        emit WinnerEvents.onWithdraw

        (

            msg.sender, 

            eth, 

            now

        );

    }



    /*

     *  @dev update round id

     */

    function upRoundID(uint256 roundID) 

    isAdmin()

    isActivated()

    public {



        require(roundID_ != roundID, "same to the current roundID");



        roundID_ = roundID;



        // fire the withdraw event

        emit WinnerEvents.onUpRoundID

        (

            roundID

        );

    }



    /*

     * @dev upPlayer

     */

    function upPlayer(address addr, bytes32 pname, uint256 balance, uint256 interest, uint256 win, uint256 reff)

    isAdmin()

    isActivated()

    public {



        uint256 pID = address2PID_[addr];



        require( pID != 0, "cannot find the player");

        require( balance >= 0, "balance invalid");

        require( interest >= 0, "interest invalid");

        require( win >= 0, "win invalid");

        require( reff >= 0, "reff invalid");



        pID2Player_[pID].pname = pname;

        pID2Player_[pID].balance = balance;

        pID2Player_[pID].interest = interest;

        pID2Player_[pID].win = win;

        pID2Player_[pID].reff = reff;



        // fire the event

        emit WinnerEvents.onUpPlayer

        (

            addr,

            pname,

            balance,

            interest,

            win,

            reff

        );

    }





    function upPlayerRound(address addr, uint256 roundID, uint256 eth, uint256 keys, uint256 interest, uint256 win, uint256 reff)

    isAdmin()

    isActivated() 

    public {

        

        uint256 pID = address2PID_[addr];



        require( pID != 0, "cannot find the player");

        require( roundID == roundID_, "not current round");

        require( eth >= 0, "eth invalid");

        require( keys >= 0, "keys invalid");

        require( interest >= 0, "interest invalid");

        require( win >= 0, "win invalid");

        require( reff >= 0, "reff invalid");



        pID2Round_[pID][roundID_].eth = eth;

        pID2Round_[pID][roundID_].keys = keys;

        pID2Round_[pID][roundID_].interest = interest;

        pID2Round_[pID][roundID_].win = win;

        pID2Round_[pID][roundID_].reff = reff;



        // fire the event

        emit WinnerEvents.onUpPlayerRound

        (

            addr,

            roundID,

            eth,

            keys,

            interest,

            win,

            reff

        );

    }



    /*

     *  @dev add player order

     */

    function addPlayerOrder(address addr, uint256 roundID, uint256 keys, uint256 eth, uint256 otype, uint256 keysAvailable, uint256 keysEth) 

    isAdmin()

    isActivated()

    public {



        uint256 pID = address2PID_[addr];



        require( pID != 0, "cannot find the player");

        require( roundID == roundID_, "not current round");

        require( keys >= 0, "keys invalid");

        require( eth >= 0, "eth invalid");

        require( otype >= 0, "type invalid");

        require( keysAvailable >= 0, "keysAvailable invalid");



        pID2Round_[pID][roundID_].eth = keysEth;

        pID2Round_[pID][roundID_].keys = keysAvailable;



        WinnerDatasets.PlayerOrder memory playerOrder = WinnerDatasets.PlayerOrder(keys, eth, otype);

        pID2Order_[pID][roundID_].push(playerOrder);



        emit WinnerEvents.onAddPlayerOrder

        (

            addr,

            keys,

            eth,

            otype

        );

    }





    /*

     * @dev upRound

     */

    function upRound(uint256 roundID, address leader, uint256 start, uint256 end, bool ended, uint256 keys, uint256 eth, uint256 pool, uint256 interest, uint256 win, uint256 reff)

    isAdmin()

    isActivated()

    public {



        require( roundID == roundID_, "not current round");



        uint256 pID = address2PID_[leader];

        require( pID != 0, "cannot find the leader");

        require( end >= start, "start end invalid");

        require( keys >= 0, "keys invalid");

        require( eth >= 0, "eth invalid");

        require( pool >= 0, "pool invalid");

        require( interest >= 0, "interest invalid");

        require( win >= 0, "win invalid");

        require( reff >= 0, "reff invalid");



        rID2Round_[roundID_].leader = leader;

        rID2Round_[roundID_].start = start;

        rID2Round_[roundID_].end = end;

        rID2Round_[roundID_].ended = ended;

        rID2Round_[roundID_].keys = keys;

        rID2Round_[roundID_].eth = eth;

        rID2Round_[roundID_].pool = pool;

        rID2Round_[roundID_].interest = interest;

        rID2Round_[roundID_].win = win;

        rID2Round_[roundID_].reff = reff;



        // fire the event

        emit WinnerEvents.onUpRound

        (

            roundID,

            leader,

            start,

            end,

            ended,

            keys,

            eth,

            pool,

            interest,

            win,

            reff

        );

    }

}





//==============================================================================

// interfaces

//==============================================================================





//==============================================================================

// structs

//==============================================================================







//==============================================================================

// libraries

//==============================================================================









/*

 * @dev safe math

 */

