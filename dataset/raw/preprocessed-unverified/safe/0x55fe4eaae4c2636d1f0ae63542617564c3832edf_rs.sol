/**

 *Submitted for verification at Etherscan.io on 2019-02-25

*/



pragma solidity ^0.4.24;







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









//==============================================================================

//   __|_ _    __|_ _  .

//  _\ | | |_|(_ | _\  .

//==============================================================================





//==============================================================================

//  |  _      _ _ | _  .

//  |<(/_\/  (_(_||(_  .

//=======/======================================================================





//==============================================================================

//  . _ _|_ _  _ |` _  _ _  _  .

//  || | | (/_| ~|~(_|(_(/__\  .

//==============================================================================















contract F3Devents {

    event eventAuction(

        string funName,

        uint256 round,

        uint256 plyr,

        uint256 money,

        uint256 keyPrice,

        uint256 plyrEth,

        uint256 plyrAuc,

        uint256 plyrKeys,

        uint256 aucEth,

        uint256 aucKeys

    );



    event onPot(

        uint256 plyrBP, // pID of player in lead for Big pot

        uint256 ethBP,

        uint256 plyrSP, // pID of player in lead for Small pot

        uint256 ethSP   // eth to pot (during round) / final amount paid to winner (after round ends)

    );



}





contract FoMo3DFast is F3Devents {

    using SafeMath for *;

    //    using F3DKeysCalcShort for uint256;

    //

    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xF2940f868fcD1Fbe8D1E1c02d2eaF68d8D7Db338);



    address private admin = msg.sender;

    // uint256 constant private rndInit_ = 88 minutes;                // round timer starts at this

    uint256 constant private rndInc_ = 60 seconds;              // every full key purchased adds this much to the timer

    uint256 constant private smallTime_ = 5 minutes;              // small time

    uint256 constant private rndMax_ = 24 hours;                // max length a round timer can be

    uint256 public rID_;    // round id number / total rounds that have happened

    uint256 constant public keyPricePot_ = 10000000000000000; // 0.1eth

    //****************

    // PLAYER DATA

    //****************

    mapping(address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address

    mapping(uint256 => F3Ddatasets.PlayerVault) public plyr_;   // (pID => data) player data

    // (pID => rID => data) player round data by player id & round id

    mapping(uint256 => mapping(uint256 => F3Ddatasets.PlayerRound)) public plyrRnds_;

    //****************

    // ROUND DATA

    //****************

    mapping(uint256 => F3Ddatasets.Auction) public auction_;   // (rID => data) round data

    mapping(uint256 => F3Ddatasets.BigPot) public bigPot_;   // (rID => data) round data

    F3Ddatasets.SmallPot public smallPot_;   // (rID => data) round data

    mapping(uint256 => uint256) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id

    uint256 private keyMax_ = 0;

    address private keyMaxAddress_ = address(0);

    uint256 private affKeyMax_ = 0;

    uint256 private affKeyMaxPlayId_ = 0;



    constructor()

    public

    {



    }

    //==============================================================================

    //     _ _  _  _|. |`. _  _ _  .

    //    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)

    //==============================================================================

    /**

    * @dev used to make sure no one can interact with contract until it has

    * been activated.

    */

    modifier isActivated() {

        require(activated_ == true, "its not ready yet.  check ?eta in discord");

        _;

    }



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



    /**

    * @dev sets boundaries for incoming tx

    */

    modifier isWithinLimits(uint256 _eth) {

        require(_eth >= 1000000000, "pocket lint: not a valid currency");

        _;

    }





    function determinePID(address senderAddr)

    private

    {

        uint256 _pID = pIDxAddr_[senderAddr];

        if (_pID == 0)

        {

            _pID = PlayerBook.getPlayerID(senderAddr);

            pIDxAddr_[senderAddr] = _pID;

            plyr_[_pID].addr = senderAddr;



        }

    }





    //==============================================================================

    //     _    |_ |. _   |`    _  __|_. _  _  _  .

    //    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)

    //====|=========================================================================

    /**

    * @dev emergency buy uses last stored affiliate ID and team snek

    */

    function()

    isActivated()

    isHuman()

    isWithinLimits(msg.value)

    external

    payable

    {

        // get/set pID for current player

        determinePID(msg.sender);



        // fetch player id

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _now = now;

        uint256 _rID = rID_;



        if (_now > bigPot_[_rID].strt && _now < bigPot_[_rID].end) {

            // Round(big pot) phase

            buy(_pID, 0);

        } else {

            // check to see if end round needs to be ran

            if (_now > bigPot_[_rID].end && bigPot_[_rID].ended == false)

            {

                // end the round (distributes pot) & start new round

                bigPot_[_rID].ended = true;

                endRound();

            }



            // put eth in players vault

            plyr_[_pID].gen = msg.value.add(plyr_[_pID].gen);

        }

    }



    function buyXQR(address senderAddr, uint256 _affID)

    isActivated()

    isWithinLimits(msg.value)

    public

    payable

    {

        // get/set pID for current player

        determinePID(senderAddr);



        // fetch player id

        uint256 _pID = pIDxAddr_[senderAddr];

        uint256 _now = now;

        uint256 _rID = rID_;





        if (_affID == _pID)

        {

            _affID = 0;



        }



        if (_now > bigPot_[_rID].strt && _now < bigPot_[_rID].end) {

            // Round(big pot) phase

            buy(_pID, _affID);

        } else {

            // check to see if end round needs to be ran

            if (_now > bigPot_[_rID].end && bigPot_[_rID].ended == false)

            {

                // end the round (distributes pot) & start new round

                bigPot_[_rID].ended = true;

                endRound();

            }



            // put eth in players vault

            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);

        }

    }



    function endRound()

    private

    {

        // setup local rID

        uint256 _rID = rID_;

        address _winAddress = keyMaxAddress_;

        // grab our winning player and team id's



        uint256 _winPID = pIDxAddr_[_winAddress];



        // grab our pot amount

        uint256 _win = bigPot_[_rID].pot;

        // 10000000000000000000 10个ether



        // pay our winner bigPot

        plyr_[_winPID].winBigPot = _win.add(plyr_[_winPID].winBigPot);



        // pay smallPot

        smallPot_.keys = 0;

        smallPot_.eth = 0;

        smallPot_.pot = 0;

        smallPot_.plyr = 0;



        if (smallPot_.on == true) {

            uint256 _currentPot = smallPot_.eth;

            uint256 _winSmallPot = smallPot_.pot;

            uint256 _surplus = _currentPot.sub(_winSmallPot);

            smallPot_.on = false;

            plyr_[_winPID].winSmallPot = _winSmallPot.add(plyr_[_winPID].winSmallPot);

            if (_surplus > 0) {

                plyr_[1].winSmallPot = _surplus.add(plyr_[1].winSmallPot);

            }

        } else {

            uint256 _currentPot1 = smallPot_.pot;

            if (_currentPot1 > 0) {

                plyr_[1].winSmallPot = _currentPot1.add(plyr_[1].winSmallPot);

            }

        }





        // start next round

        rID_++;

        _rID++;

        uint256 _now = now;



        bigPot_[_rID].strt = _now;

        bigPot_[_rID].end = _now + rndMax_;

        keyMax_ = 0;

        keyMaxAddress_ = address(0);

        affKeyMax_ = 0;

        affKeyMaxPlayId_ = 0;

    }





    function withdrawXQR(address _realSender)

    isActivated()

    public

    {

        // setup local rID

        uint256 _rID = rID_;



        // grab time

        uint256 _now = now;



        // fetch player ID

        uint256 _pID = pIDxAddr_[_realSender];



        // setup temp var for player eth

        uint256 _eth;



        // check to see if round has ended and no one has run round end yet

        if (_now > bigPot_[_rID].end && bigPot_[_rID].ended == false && bigPot_[_rID].plyr != 0)

        {

            // end the round (distributes pot)

            bigPot_[_rID].ended = true;

            endRound();



            // get their earnings

            _eth = withdrawEarnings(_pID);



            // gib moni

            if (_eth > 0)

                plyr_[_pID].addr.transfer(_eth);



            // in any other situation

        } else {

            // get their earnings

            _eth = withdrawEarnings(_pID);



            // gib moni

            if (_eth > 0)

                plyr_[_pID].addr.transfer(_eth);



        }

    }



    function withdrawEarnings(uint256 _pID)

    private

    returns (uint256)

    {

        updateGenVault(_pID, plyr_[_pID].lrnd);

        // from vaults

        uint256 _earnings = (plyr_[_pID].winBigPot).add(plyr_[_pID].winSmallPot).add(plyr_[_pID].gen).add(plyr_[_pID].aff);

        if (_earnings > 0)

        {

            plyr_[_pID].winBigPot = 0;

            plyr_[_pID].winSmallPot = 0;

            plyr_[_pID].gen = 0;

            plyr_[_pID].aff = 0;

        }

        return (_earnings);

    }



    function updateGenVault(uint256 _pID, uint256 _rIDlast)

    private

    {

        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);

        if (_earnings > 0)

        {

            // put in gen vault

            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);

            // zero out their earnings by updating mask

            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);

        }

    }



    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)

    private

    view

    returns (uint256)

    {

        return ((((bigPot_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask));

    }



    function managePlayer(uint256 _pID)

    private

    {

        // if player has played a previous round, move their unmasked earnings

        // from that round to gen vault.

        if (plyr_[_pID].lrnd != 0)

            updateGenVault(_pID, plyr_[_pID].lrnd);



        // update player's last round played

        plyr_[_pID].lrnd = rID_;

    }





    function buy(uint256 _pID, uint256 _affID)

    private

    {

        // setup local rID

        uint256 _rID = rID_;

        uint256 _keyPrice = keyPricePot_;



        if (plyrRnds_[_pID][_rID].keys == 0)

            managePlayer(_pID);



        uint256 _eth = msg.value;



        uint256 _keys = _eth / _keyPrice;



        if (_eth > 1000000000)

        {

            // if they bought at least 1 whole key

            if (_keys >= 1)

            {

                updateTimer(_keys, _rID);

                // set new leaders

                if (bigPot_[_rID].plyr != _pID)

                    bigPot_[_rID].plyr = _pID;

            }





            // update round

            bigPot_[_rID].keys = _keys.add(bigPot_[_rID].keys);

            bigPot_[_rID].eth = _eth.add(bigPot_[_rID].eth);



            smallPot_.keys = _keys.add(smallPot_.keys);



            // update player

            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);

            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);



            if (_affID != 0) {

                plyrRnds_[_affID][_rID].affKeys = _keys.add(plyrRnds_[_affID][_rID].affKeys);

            }



            // update key max address

            if (plyrRnds_[_pID][_rID].keys > keyMax_) {

                keyMax_ = plyrRnds_[_pID][_rID].keys;

                keyMaxAddress_ = plyr_[_pID].addr;

            }



            // update key max address

            if (plyrRnds_[_affID][_rID].affKeys > affKeyMax_) {

                affKeyMax_ = plyrRnds_[_affID][_rID].affKeys;

                affKeyMaxPlayId_ = pIDxAddr_[plyr_[_affID].addr];

            }





            // key sharing earnings

            uint256 _gen = _eth.mul(5) / 10;

            updateMasks(_rID, _pID, _gen, _keys);



            distributeBuy(_rID, _eth, _affID);

            smallPot();

        }

    }



    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)

    private

    returns (uint256)

    {

        // calc profit per key & round mask based on this buy:  (dust goes to pot)

        uint256 _ppt = (_gen.mul(1000000000000000000)) / (bigPot_[_rID].keys);

        bigPot_[_rID].mask = _ppt.add(bigPot_[_rID].mask);



        // calculate player earning from their own buy (only based on the keys

        // they just bought).  & update player earnings mask

        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);

        plyrRnds_[_pID][_rID].mask = (((bigPot_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);



        // calculate & return dust

        return (_gen.sub((_ppt.mul(bigPot_[_rID].keys)) / (1000000000000000000)));

    }



    function distributeBuy(uint256 _rID, uint256 _eth, uint256 _affID)

    private

    {

        // pay 10% out to team

        uint256 _team = _eth.mul(15) / 2 / 100;

        uint256 _team1 = _team;

        // 10% to aff

        uint256 _aff = _eth.mul(10) / 100;



        uint256 _ethMaxAff = _eth.mul(5) / 100;



        if (_affID == 0) {

            _team = _team.add(_aff);

            _aff = 0;

        }

        if (affKeyMaxPlayId_ == 0) {

            _team = _team.add(_ethMaxAff);

            _ethMaxAff = 0;

        }

        // 10% to big Pot

        uint256 _bigPot = _eth / 10;

        // 10% to small Pot

        uint256 _smallPot = _eth / 10;



        // pay out team

        plyr_[1].aff = _team.add(plyr_[1].aff);

        plyr_[2].aff = _team1.add(plyr_[2].aff);



        if (_ethMaxAff != 0) {

            plyr_[affKeyMaxPlayId_].aff = _ethMaxAff.add(plyr_[affKeyMaxPlayId_].aff);

        }

        if (_aff != 0) {

            // 通过 affID 得到 推荐玩家pID， 并将_aff驾到 pID玩家的 aff中

            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);

        }



        // move money to Pot

        bigPot_[_rID].pot = bigPot_[_rID].pot.add(_bigPot);

        smallPot_.pot = smallPot_.pot.add(_smallPot);

    }



    function smallPot()

    private

    {

        uint256 _now = now;



        if (smallPot_.on == false && smallPot_.keys >= (1000)) {

            smallPot_.on = true;

            smallPot_.eth = smallPot_.pot;

            smallPot_.strt = _now;

            smallPot_.end = _now + smallTime_;

        } else if (smallPot_.on == true && _now > smallPot_.end) {

            uint256 _winSmallPot = smallPot_.eth;

            uint256 _currentPot = smallPot_.pot;

            uint256 _surplus = _currentPot.sub(_winSmallPot);

            uint256 _winPID = pIDxAddr_[keyMaxAddress_];

            smallPot_.on = false;

            smallPot_.keys = 0;

            smallPot_.eth = 0;

            smallPot_.pot = 0;

            smallPot_.plyr = 0;

            plyr_[_winPID].winSmallPot = _winSmallPot.add(plyr_[_winPID].winSmallPot);

            if (_surplus > 0) {

                plyr_[1].winSmallPot = _surplus.add(plyr_[1].winSmallPot);

            }

        }

    }





    function updateTimer(uint256 _keys, uint256 _rID)

    private

    {



        // grab time

        uint256 _now = now;



        // calculate time based on number of keys bought

        uint256 _newTime;

        if (_now > bigPot_[_rID].end && bigPot_[_rID].plyr == 0)

            _newTime = ((_keys).mul(rndInc_)).add(_now);

        else

            _newTime = ((_keys).mul(rndInc_)).add(bigPot_[_rID].end);



        // compare to max and set new end time

        if (_newTime < (rndMax_).add(_now))

            bigPot_[_rID].end = _newTime;

        else

            bigPot_[_rID].end = rndMax_.add(_now);



    }



    function getPlayerIdxAddr(address _addr) public view returns (uint256){

        if (pIDxAddr_[_addr] == 0) {

            return pIDxAddr_[_addr];

        } else {

            return 0;

        }

    }





    function receivePlayerInfo(uint256 _pID, address _addr)

    external

    {

        require(msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");

        if (pIDxAddr_[_addr] != _pID)

            pIDxAddr_[_addr] = _pID;

        if (plyr_[_pID].addr != _addr)

            plyr_[_pID].addr = _addr;

    }





    //==============================================================================

    //     _  _ _|__|_ _  _ _  .

    //    (_|(/_ |  | (/_| _\  . (for UI & viewing things on etherscan)

    //=====_|=======================================================================

    /**

    * @dev return the price buyer will pay for next 1 individual key.

    * -functionhash- 0x018a25e8

    * @return price for next key bought (in wei format)

    */

    // function getBuyPrice()

    // public

    // view

    // returns (uint256)

    // {

    //     if (now < round_[rID_].start) {

    //         // 当前轮游戏开始前

    //         return 5;

    //     } else if (now > round_[rID_].start && now < rndTmEth_[rID_]) {

    //         // 当前轮游戏进行中

    //         return 10;

    //     } else if (now > rndTmEth_[rID_]) {

    //         // 当前轮游戏已结束

    //         return 5;

    //     }

    // }



    function getTimeLeft() public

    view returns (uint256){

        return rndTmEth_[rID_] - now;

    }



    function getrID() public

    view returns (uint256){

        return rID_;

    }



    function getAdmin() public

    view returns (address){

        return admin;

    }



    //==============================================================================

    //    (~ _  _    _._|_    .

    //    _)(/_(_|_|| | | \/  .

    //====================/=========================================================

    /** upon contract deploy, it will be deactivated.  this is a one time

     * use function that will activate the contract.  we do this so devs

     * have time to set things up on the web end                            **/

    bool public activated_ = false;

    uint256  public end_ = 0;



    function activate()

    public

    {

        // only team just can activate

        require(msg.sender == admin, "only admin can activate");

        // can only be ran once

        require(activated_ == false, "FOMO Short already activated");



        // activate the contract

        activated_ = true;



        // lets start first round

        rID_ = 1;

        uint256 _now = now;



        bigPot_[1].strt = _now;

        bigPot_[1].end = _now + rndMax_;

    }



    function getAuctionTimer()

    public

    view

    returns (uint256, uint256, uint256, uint256, bool, uint256, uint256)

    {

        // setup local rID

        uint256 _rID = rID_;

        uint256 _now = now;

        return

        (

        _rID, //1

        auction_[_rID].strt,

        auction_[_rID].end,

        _now,

        _now > auction_[_rID].end,

        bigPot_[_rID].strt,

        bigPot_[_rID].end            //2

        );

    }





    // ================== 页面数据方法 start ======================



    // 获取当前轮BigPot数据

    function getCurrentRoundBigPotInfo()

    public

    view

    returns (uint256, uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256, address, uint256, uint256)

    {

        // setup local rID

        uint256 _rID = rID_;

        uint256 _now = now;

        uint256 _currentpID = pIDxAddr_[keyMaxAddress_];

        uint256 _eth = bigPot_[_rID].eth;

        return

        (

        _rID, // round index

        // bitPot data

        _currentpID, // pID of player in lead for Big pot

        bigPot_[_rID].ended, // has round end function been ran

        bigPot_[_rID].strt, // time round started

        bigPot_[_rID].end, // time ends/ended

        bigPot_[_rID].end - _now,

        bigPot_[_rID].keys, // keys

        _eth, // total eth in

        bigPot_[_rID].pot, // eth to pot (during round) / final amount paid to winner (after round ends)

        keyMaxAddress_, // current lead address

        keyMax_,

        affKeyMax_

        );

    }



    // 获取当前轮SmallPot数据

    function getSmallPotInfo()

    public

    view

    returns (uint256, uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256, address)

    {

        // setup local rID

        uint256 _rID = rID_;

        uint256 _now = now;

        uint256 _currentpID = pIDxAddr_[keyMaxAddress_];

        return

        (

        _rID, // round index

        // smallPot data

        _currentpID,

        smallPot_.on,

        smallPot_.strt,

        smallPot_.end,

        smallPot_.end - _now,

        smallPot_.keys,

        smallPot_.eth,

        smallPot_.pot,

        keyMaxAddress_ // current lead address

        );

    }



    // 获取当前轮数据

    function getPlayerInfoxAddr()

    public

    view

    returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256)

    {

        // setup local rID

        uint256 _rID = rID_;

        uint256 _pID = pIDxAddr_[msg.sender];

        return

        (_rID, //1

        _pID, //1

        plyrRnds_[_pID][_rID].eth,

        plyrRnds_[_pID][_rID].auc,

        plyrRnds_[_pID][_rID].keys,

        plyrRnds_[_pID][_rID].mask, //2

        plyrRnds_[_pID][_rID].refID //2

        );

    }



    // 获取用户钱包信息

    function getPlayerVaultxAddr()

    public

    view

    returns (uint256, address, uint256, uint256, uint256, uint256)

    {

        // setup local rID

        address addr = msg.sender;

        uint256 _pID = pIDxAddr_[addr];

        return

        (

        _pID, //1

        plyr_[_pID].addr,

        plyr_[_pID].winBigPot,

        plyr_[_pID].winSmallPot,

        plyr_[_pID].gen,

        plyr_[_pID].aff

        );

    }



    function getPlayerVaults(uint256 _pID)

    public

    view

    returns (uint256, uint256, uint256, uint256)

    {

        // setup local rID

        uint256 _rID = rID_;



        // if round has ended.  but round end has not been run (so contract has not distributed winnings)

        if (now > bigPot_[_rID].end && bigPot_[_rID].ended == false && keyMaxAddress_ != address(0))

        {

            // if player is winner

            if (pIDxAddr_[keyMaxAddress_] == _pID)

            {

                return

                (

                plyr_[_pID].winBigPot.add(bigPot_[_rID].pot),

                plyr_[_pID].winSmallPot,

                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),

                plyr_[_pID].aff

                );



                // if player is not the winner

            } else {

                return

                (

                plyr_[_pID].winBigPot,

                plyr_[_pID].winSmallPot,

                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),

                plyr_[_pID].aff

                );

            }



            // if round is still going on, or round has ended and round end has been ran

        } else {

            return

            (

            plyr_[_pID].winBigPot,

            plyr_[_pID].winSmallPot,

            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),

            plyr_[_pID].aff

            );

        }

    }



    // ================== 页面数据方法 end ======================







    function getPlayerInfoByAddress(address addr)

    public

    view

    returns (uint256, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)

    {

        // setup local rID

        uint256 _rID = rID_;

        address _addr = addr;



        if (_addr == address(0))

        {

            _addr == msg.sender;

        }

        uint256 _pID = pIDxAddr_[_addr];

        return

        (

        _pID, //0

        _addr, //1

        _rID, //2

        plyr_[_pID].winBigPot, //3

        plyr_[_pID].winSmallPot, //4

        plyr_[_pID].gen, //5

        plyr_[_pID].aff, //6

        plyrRnds_[_pID][_rID].keys, //7

        plyrRnds_[_pID][_rID].eth, //

        plyrRnds_[_pID][_rID].auc, //

        plyrRnds_[_pID][_rID].mask, //

        plyrRnds_[_pID][_rID].refID //

        );

    }



    function getPlayerInfoById(uint256 pID)

    public

    view

    returns (uint256, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)

    {

        // setup local rID

        uint256 _rID = rID_;

        uint256 _pID = pID;

        address _addr = msg.sender;

        return

        (

        _pID, //0

        _addr, //1

        _rID, //2

        plyr_[_pID].winBigPot, //3

        plyr_[_pID].winSmallPot, //4

        plyr_[_pID].gen, //5

        plyr_[_pID].aff, //6

        plyrRnds_[_pID][_rID].keys, //7

        plyrRnds_[_pID][_rID].eth, //

        plyrRnds_[_pID][_rID].auc, //

        plyrRnds_[_pID][_rID].mask, //

        plyrRnds_[_pID][_rID].refID //

        );

    }

}