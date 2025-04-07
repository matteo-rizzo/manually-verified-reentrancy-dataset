/**

 *Submitted for verification at Etherscan.io on 2018-08-18

*/



pragma solidity ^0.4.24;

/** title -Divies- v0.7.1

 *         ©°©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´

 *         ©¦ Divies!, is a contract that adds an external dividend system to H4D. ©¦

 *         ©¦ All eth sent to this contract, can be distributed to H4D holders.    ©¦

 *         ©¦ Uses msg.sender as masternode for initial buy order.                 ©¦

 *         ©¸©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¼

 *                                ©°©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´

 *                                ©¦ Setup Instructions ©¦

 *                                ©¸©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¼

 * (Step 1) import this contracts interface into your contract

 * 

 *    import "./DiviesInterface.sol";

 * 

 * (Step 2) set up the interface and point it to this contract

 * 

 *    DiviesInterface private Divies = DiviesInterface(0xeB0b5FA53843aAa2e636ccB599bA4a8CE8029aA1);

 *                                ©°©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´

 *                                ©¦ Usage Instructions ©¦

 *                                ©¸©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¼

 * call as follows anywhere in your code:

 *   

 *    Divies.deposit.value(amount)();

 *          ex:  Divies.deposit.value(232000000000000000000)();

 */







contract Divies {

    using SafeMath for uint256;

    using UintCompressor for uint256;



    HourglassInterface constant H4Dcontract_ = HourglassInterface(0xeB0b5FA53843aAa2e636ccB599bA4a8CE8029aA1);

    

    uint256 public pusherTracker_ = 100;

    mapping (address => Pusher) public pushers_;

    struct Pusher

    {

        uint256 tracker;

        uint256 time;

    }

    uint256 public rateLimiter_;

    

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // MODIFIERS

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    modifier isHuman() {

        require(tx.origin == msg.sender);

        _;

    }

    

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // BALANCE

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    function balances()

        public

        view

        returns(uint256)

    {

        return (address(this).balance);

    }

    

    

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // DEPOSIT

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    function deposit()

        external

        payable

    {

        

    }

    

    // used so the distribute function can call hourglass's withdraw

    function() external payable {}

    

    

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // EVENTS

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    event onDistribute(

        address pusher,

        uint256 startingBalance,

        uint256 masternodePayout,

        uint256 finalBalance,

        uint256 compressedData

    );

    /* compression key

    [0-14] - timestamp

    [15-29] - caller pusher tracker 

    [30-44] - global pusher tracker 

    [45-46] - percent

    [47] - greedy

    */  

    

    

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    // DISTRIBUTE

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    function distribute(uint256 _percent)

        public

        isHuman()

    {

        // make sure _percent is within boundaries

        require(_percent > 0 && _percent < 100, "please pick a percent between 1 and 99");

        

        // data setup

        address _pusher = msg.sender;

        uint256 _bal = address(this).balance;

        uint256 _mnPayout;

        uint256 _compressedData;

        

        // limit pushers greed (use "if" instead of require for level 42 top kek)

        if (

            pushers_[_pusher].tracker <= pusherTracker_.sub(100) && // pusher is greedy: wait your turn

            pushers_[_pusher].time.add(1 hours) < now               // pusher is greedy: its not even been 1 hour

        )

        {

            // update pushers wait que 

            pushers_[_pusher].tracker = pusherTracker_;

            pusherTracker_++;

            

            // setup mn payout for event

            if (H4Dcontract_.balanceOf(_pusher) >= H4Dcontract_.stakingRequirement())

                _mnPayout = (_bal / 10) / 3;

            

            // setup _stop.  this will be used to tell the loop to stop

            uint256 _stop = (_bal.mul(100 - _percent)) / 100;

            

            // buy & sell    

            H4Dcontract_.buy.value(_bal)(_pusher);

            H4Dcontract_.sell(H4Dcontract_.balanceOf(address(this)));

            

            // setup tracker.  this will be used to tell the loop to stop

            uint256 _tracker = H4Dcontract_.dividendsOf(address(this));

    

            // reinvest/sell loop

            while (_tracker >= _stop) 

            {

                // lets burn some tokens to distribute dividends to H4D holders

                H4Dcontract_.reinvest();

                H4Dcontract_.sell(H4Dcontract_.balanceOf(address(this)));

                

                // update our tracker with estimates (yea. not perfect, but cheaper on gas)

                _tracker = (_tracker.mul(81)) / 100;

            }

            

            // withdraw

            H4Dcontract_.withdraw();

        } else {

            _compressedData = _compressedData.insert(1, 47, 47);

        }

        

        // update pushers timestamp  (do outside of "if" for super saiyan level top kek)

        pushers_[_pusher].time = now;

    

        // prep event compression data 

        _compressedData = _compressedData.insert(now, 0, 14);

        _compressedData = _compressedData.insert(pushers_[_pusher].tracker, 15, 29);

        _compressedData = _compressedData.insert(pusherTracker_, 30, 44);

        _compressedData = _compressedData.insert(_percent, 45, 46);

            

        // fire event

        emit onDistribute(_pusher, _bal, _mnPayout, address(this).balance, _compressedData);

    }

}



/**

* @title -UintCompressor- v0.1.9



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

