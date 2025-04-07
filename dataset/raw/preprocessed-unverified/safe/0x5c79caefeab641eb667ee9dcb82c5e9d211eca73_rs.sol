/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

pragma solidity ^0.4.21;
/***
 *         _____                                               ___           ___     
 *        /  /::\       ___           ___        ___          /  /\         /  /\    
 *       /  /:/\:\     /  /\         /__/\      /  /\        /  /:/_       /  /:/_   
 *      /  /:/  \:\   /  /:/         \  \:\    /  /:/       /  /:/ /\     /  /:/ /\  
 *     /__/:/ \__\:| /__/::\          \  \:\  /__/::\      /  /:/ /:/_   /  /:/ /::\ 
 *     \  \:\ /  /:/ \__\/\:\__   ___  \__\:\ \__\/\:\__  /__/:/ /:/ /\ /__/:/ /:/\:\
 *      \  \:\  /:/     \  \:\/\ /__/\ |  |:|    \  \:\/\ \  \:\/:/ /:/ \  \:\/:/~/:/
 *       \  \:\/:/       \__\::/ \  \:\|  |:|     \__\::/  \  \::/ /:/   \  \::/ /:/ 
 *        \  \::/        /__/:/   \  \:\__|:|     /__/:/    \  \:\/:/     \__\/ /:/  
 *         \__\/         \__\/     \__\::::/      \__\/      \  \::/        /__/:/   
 *                                     ~~~~                   \__\/         \__\/    
 *  v 1.1.0
 *  "Spread the Love"
 *
 *  Ethereum Commonwealth.gg Divies(based on contract @ ETC:0x93123bA3781bc066e076D249479eEF760970aa32)
 *  Modifications: 
 *  -> reinvest Crop Function
 *
 *  What?
 *  -> eWLTH div interface. Send ETH here, and then call distribute to give to eWLTH holders.
 *  -> Distributes 75% of the contract balance.
 * 
 *                                ©°©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´
 *                                ©¦ Usage Instructions ©¦
 *                                ©¸©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¼
 * Transfer funds directly to this contract. These will be distributed via the distribute function.
 *   
 *    address diviesAddress = 0xd1A231ae68eBE7Aec3ECDAEAC4C0776eB525D969;
 *    diviesAddress.transfer(232000000000000000000); 
 * 
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 


contract Divies {
    using SafeMath for uint256;
    using UintCompressor for uint256;
    address private eWLTHAddress = 0x5833C959C3532dD5B3B6855D590D70b01D2d9fA6;

    HourglassInterface constant eWLTH = HourglassInterface(eWLTHAddress);
    
    uint256 public pusherTracker_ = 100;
    mapping (address => Pusher) public pushers_;
    struct Pusher
    {
        uint256 tracker;
        uint256 time;
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
        uint256 finalBalance,
        uint256 compressedData
    );
    /* compression key
    [0-14] - timestamp
    [15-29] - caller pusher tracker 
    [30-44] - global pusher tracker 
    */  
    
    
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    // DISTRIBUTE
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    function distribute()
        public
    {
        uint256 _percent = 75;
        // data setup
        address _pusher = msg.sender;
        uint256 _bal = address(this).balance;
        uint256 _compressedData;
        
        // update pushers wait que 
        pushers_[_pusher].tracker = pusherTracker_;
        pusherTracker_++;
            
        // setup _stop.  this will be used to tell the loop to stop
        uint256 _stop = (_bal.mul(100 - _percent)) / 100;
            
        // buy & sell    
        eWLTH.buy.value(_bal)(address(0));
        eWLTH.sell(eWLTH.balanceOf(address(this)));
            
        // setup tracker.  this will be used to tell the loop to stop
        uint256 _tracker = eWLTH.dividendsOf(address(this), true);
    
        // reinvest/sell loop
        while (_tracker >= _stop) 
        {
            // lets burn some tokens to distribute dividends to eWLTH holders
            eWLTH.reinvest();
            eWLTH.sell(eWLTH.balanceOf(address(this)));
                
            // update our tracker with estimates (yea. not perfect, but cheaper on gas)
            _tracker = (_tracker.mul(81)) / 100;
        }
            
        // withdraw
        eWLTH.withdraw();
        
        // update pushers timestamp  (do outside of "if" for super saiyan level top kek)
        pushers_[_pusher].time = now;
    
        // prep event compression data 
        _compressedData = _compressedData.insert(now, 0, 14);
        _compressedData = _compressedData.insert(pushers_[_pusher].tracker, 15, 29);
        _compressedData = _compressedData.insert(pusherTracker_, 30, 44);

        // fire event
        emit onDistribute(_pusher, _bal, address(this).balance, _compressedData);
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
