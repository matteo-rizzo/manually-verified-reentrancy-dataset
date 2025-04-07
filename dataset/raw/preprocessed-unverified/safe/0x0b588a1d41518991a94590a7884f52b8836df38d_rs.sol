pragma solidity ^0.4.24;

contract FlyToTheMoonEvents {

    // buy keys during first stage
    event onFirStage
    (
        address indexed player,
        uint256 indexed rndNo,
        uint256 keys,
        uint256 eth,
        uint256 timeStamp  
    );

    // become leader during second stage
    event onSecStage
    (
        address indexed player,
        uint256 indexed rndNo,
        uint256 eth,
        uint256 timeStamp  
    );

    // player withdraw
    event onWithdraw
    (
        address indexed player,
        uint256 indexed rndNo,
        uint256 eth,
        uint256 timeStamp
    );

    // award
    event onAward
    (
        address indexed player,
        uint256 indexed rndNo,
        uint256 eth,
        uint256 timeStamp
    );
}

contract FlyToTheMoon is FlyToTheMoonEvents {
    using SafeMath for *;
    using KeysCalc for uint256;

    struct Round {
        uint256 eth;        // total eth
        uint256 keys;       // total keys
        uint256 startTime;  // end time
        uint256 endTime;    // end time
        address leader;     // leader
        uint256 lastPrice;  // The latest price for the second stage
        bool award;         // has been accept
    }

    struct PlayerRound {
        uint256 eth;        // eth player has added to round
        uint256 keys;       // keys
        uint256 withdraw;   // how many eth has been withdraw
    }

    uint256 public rndNo = 1;                                   // current round number
    uint256 public totalEth = 0;                                // total eth in all round

    uint256 constant private rndFirStage_ = 12 hours;           // round timer at first stage
    uint256 constant private rndSecStage_ = 12 hours;           // round timer at second stage

    mapping (uint256 => Round) public round_m;                  // (rndNo => Round)
    mapping (uint256 => mapping (address => PlayerRound)) public playerRound_m;   // (rndNo => addr => PlayerRound)

    address public owner;               // owner address
    uint256 public ownerWithdraw = 0;   // how many eth has been withdraw by owner

    constructor()
        public
    {
        round_m[1].startTime = now;
        round_m[1].endTime = now + rndFirStage_;

        owner = msg.sender;
    }

    /**
     * @dev prevents contracts from interacting
     */
    modifier onlyHuman() 
    {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    /**
     * @dev sets boundaries for incoming tx 
     */
    modifier isWithinLimits(uint256 _eth) 
    {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;    
    }

    /**
     * @dev only owner
     */
    modifier onlyOwner() 
    {
        require(owner == msg.sender, "only owner can do it");
        _;    
    }

    /**
     * @dev play
     */
    function()
        onlyHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        uint256 _eth = msg.value;
        uint256 _now = now;
        uint256 _rndNo = rndNo;
        uint256 _ethUse = msg.value;

        // start next round?
        if (_now > round_m[_rndNo].endTime)
        {
            _rndNo = _rndNo.add(1);
            rndNo = _rndNo;
            round_m[_rndNo].startTime = _now;
            round_m[_rndNo].endTime = _now + rndFirStage_;
        }

        // first or second stage
        if (round_m[_rndNo].keys < 10000000000000000000000000)
        {
            // first stage
            uint256 _keys = (round_m[_rndNo].eth).keysRec(_eth);
            // keys number 10,000,000, enter the second stage
            if (_keys.add(round_m[_rndNo].keys) >= 10000000000000000000000000)
            {
                _keys = (10000000000000000000000000).sub(round_m[_rndNo].keys);

                if (round_m[_rndNo].eth >= 8562500000000000000000)
                {
                    _ethUse = 0;
                } else {
                    _ethUse = (8562500000000000000000).sub(round_m[_rndNo].eth);
                }

                if (_eth > _ethUse)
                {
                    // refund
                    msg.sender.transfer(_eth.sub(_ethUse));
                } else {
                    // fix
                    _ethUse = _eth;
                }
            }

            // if they bought at least 1 whole key
            if (_keys >= 1000000000000000000)
            {
                round_m[_rndNo].endTime = _now + rndFirStage_;
                round_m[_rndNo].leader = msg.sender;
            }

            // update playerRound
            playerRound_m[_rndNo][msg.sender].keys = _keys.add(playerRound_m[_rndNo][msg.sender].keys);
            playerRound_m[_rndNo][msg.sender].eth = _ethUse.add(playerRound_m[_rndNo][msg.sender].eth);

            // update round
            round_m[_rndNo].keys = _keys.add(round_m[_rndNo].keys);
            round_m[_rndNo].eth = _ethUse.add(round_m[_rndNo].eth);

            // update global variable
            totalEth = _ethUse.add(totalEth);

            // event
            emit FlyToTheMoonEvents.onFirStage
            (
                msg.sender,
                _rndNo,
                _keys,
                _ethUse,
                _now
            );
        } else {
            // second stage
            // no more keys
            // lastPrice + 0.1Ether <= newPrice <= lastPrice + 10Ether
            uint256 _lastPrice = round_m[_rndNo].lastPrice;
            uint256 _maxPrice = (10000000000000000000).add(_lastPrice);
            // less than (lastPrice + 0.1Ether) ?
            require(_eth >= (100000000000000000).add(_lastPrice), "Need more Ether");
            // more than (lastPrice + 10Ether) ?
            if (_eth > _maxPrice)
            {
                _ethUse = _maxPrice;
                // refund
                msg.sender.transfer(_eth.sub(_ethUse));
            }

            round_m[_rndNo].endTime = _now + rndSecStage_;
            round_m[_rndNo].leader = msg.sender;
            round_m[_rndNo].lastPrice = _ethUse;

            // update playerRound
            playerRound_m[_rndNo][msg.sender].eth = _ethUse.add(playerRound_m[_rndNo][msg.sender].eth);

            // update round
            round_m[_rndNo].eth = _ethUse.add(round_m[_rndNo].eth);

            // update global variable
            totalEth = _ethUse.add(totalEth);

            // event
            emit FlyToTheMoonEvents.onSecStage
            (
                msg.sender,
                _rndNo,
                _ethUse,
                _now
            );
        }
    }

    /**
     * @dev withdraws earnings by rndNo.
     * 0x528ce7de
     * 0x528ce7de0000000000000000000000000000000000000000000000000000000000000001
     */
    function withdrawByRndNo(uint256 _rndNo)
        onlyHuman()
        public
    {
        require(_rndNo <= rndNo, "You're running too fast");
        uint256 _total = (((round_m[_rndNo].eth).mul(playerRound_m[_rndNo][msg.sender].keys)).mul(60) / ((round_m[_rndNo].keys).mul(100)));
        uint256 _withdrawed = playerRound_m[_rndNo][msg.sender].withdraw;
        require(_total > _withdrawed, "No need to withdraw");
        uint256 _ethOut = _total.sub(_withdrawed);
        playerRound_m[_rndNo][msg.sender].withdraw = _total;
        msg.sender.transfer(_ethOut);

        // event
        emit FlyToTheMoonEvents.onWithdraw
        (
            msg.sender,
            _rndNo,
            _ethOut,
            now
        );
    }

    /**
     * @dev Award by rndNo.
     * 0x80ec35ff
     * 0x80ec35ff0000000000000000000000000000000000000000000000000000000000000001
     */
    function awardByRndNo(uint256 _rndNo)
        onlyHuman()
        public
    {
        require(_rndNo <= rndNo, "You're running too fast");
        require(now > round_m[_rndNo].endTime, "Wait patiently");
        require(round_m[_rndNo].leader == msg.sender, "The prize is not yours");
        require(round_m[_rndNo].award == false, "Can't get prizes repeatedly");

        uint256 _ethOut = ((round_m[_rndNo].eth).mul(35) / (100));
        round_m[_rndNo].award = true;
        msg.sender.transfer(_ethOut);

        // event
        emit FlyToTheMoonEvents.onAward
        (
            msg.sender,
            _rndNo,
            _ethOut,
            now
        );
    }

    /**
     * @dev fee withdraw to owner, everyone can do it.
     * 0x6561e6ba
     */
    function feeWithdraw()
        onlyHuman()
        public
    {
        uint256 _total = (totalEth.mul(5) / (100));
        uint256 _withdrawed = ownerWithdraw;
        require(_total > _withdrawed, "No need to withdraw");
        ownerWithdraw = _total;
        owner.transfer(_total.sub(_withdrawed));
    }

    /**
     * @dev change owner.
     */
    function changeOwner(address newOwner)
        onlyOwner()
        public
    {
        owner = newOwner;
    }

    /**
     * @dev returns all current round info needed for front end
     * 0x747dff42
     * @return round id 
     * @return total eth for round
     * @return total keys for round 
     * @return time round started
     * @return time round ends
     * @return current leader
     * @return lastest price
     * @return current key price
     */
    function getCurrentRoundInfo()
        public 
        view 
        returns(uint256, uint256, uint256, uint256, uint256, address, uint256, uint256)
    {

        uint256 _rndNo = rndNo;
        
        return (
            _rndNo,
            round_m[_rndNo].eth,
            round_m[_rndNo].keys,
            round_m[_rndNo].startTime,
            round_m[_rndNo].endTime,
            round_m[_rndNo].leader,
            round_m[_rndNo].lastPrice,
            getBuyPrice()
        );
    }
    
    /**
     * @dev return the price buyer will pay for next 1 individual key during first stage.
     * 0x018a25e8
     * @return price for next key bought (in wei format)
     */
    function getBuyPrice()
        public 
        view 
        returns(uint256)
    {
        uint256 _rndNo = rndNo;
        uint256 _now = now;
        
        // start next round?
        if (_now > round_m[_rndNo].endTime)
        {
            return (75000000000000);
        }
        if (round_m[_rndNo].keys < 10000000000000000000000000)
        {
            return ((round_m[_rndNo].keys.add(1000000000000000000)).ethRec(1000000000000000000));
        }
        //second stage
        return (0);
    }
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
