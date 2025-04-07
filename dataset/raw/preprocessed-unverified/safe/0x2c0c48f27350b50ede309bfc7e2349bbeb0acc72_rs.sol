/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity ^0.4.24;

/*

 * FOMO Fast-PlayerBook - v0.3.14

 */







contract PlayerBook {

    using SafeMath for uint256;



    address private admin = msg.sender;

    //==============================================================================

    //     _| _ _|_ _    _ _ _|_    _   .

    //    (_|(_| | (_|  _\(/_ | |_||_)  .

    //=============================|================================================

    // mapping of our game interfaces for sending your account info to games

    mapping(uint256 => PlayerBookReceiverInterface) public games_;

    mapping(address => uint256) public gameIDs_;            // lokup a games ID

    uint256 public gID_;        // total number of games

    uint256 public pID_;        // total number of players

    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address

    mapping (uint256 => Player) public plyr_;               // (pID => data) player data

    mapping (uint256 => uint256) public refIDxpID_;

    

    struct Player {

        address addr;

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

        plyr_[1].addr = 0xe50ac0d497db44ffaaeb7d98cb57c420992e1d9d;

        pIDxAddr_[0xe50ac0d497db44ffaaeb7d98cb57c420992e1d9d] = 1;



        //Total number of players

        pID_ = 1;

    }

//==============================================================================

//     _ _  _  _|. |`. _  _ _  .

//    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)

//==============================================================================

    /**

     * @dev prevents contracts from interacting with fomo3d 解读: 判断是否是合约

     */

    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

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

//     _    |_ |. _   |`    _  __|_. _  _  _  .

//    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)

//====|=========================================================================





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



    function getPlayerAddr(uint256 _pID)

        external

        view

        returns (address)

    {

        return (plyr_[_pID].addr);

    }





    //==============================================================================

    //   _ _ _|_    _   .

    //  _\(/_ | |_||_)  .

    //=============|================================================================

    function addGame(address _gameAddress)

        public

    {

        require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");

        gID_++;

        gameIDs_[_gameAddress] = gID_;

        games_[gID_] = PlayerBookReceiverInterface(_gameAddress);



        // No.1 for team , more to add later

        games_[gID_].receivePlayerInfo(1, plyr_[1].addr);

    }

}



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

