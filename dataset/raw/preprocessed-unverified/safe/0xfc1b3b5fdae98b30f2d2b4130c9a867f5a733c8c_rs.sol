/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.24;



contract WorldByEth {

    using SafeMath for *;



    string constant public name = "ETH world cq";

    string constant public symbol = "ecq";

    uint256 public rID_;

    address public comaddr = 0x9ca974f2c49d68bd5958978e81151e6831290f57;

    mapping(uint256 => uint256) public pot_;

    mapping(uint256 => mapping(uint256 => Ctry)) public ctry_;

    uint public gap = 1 hours;

    address public lastplayer = 0x9ca974f2c49d68bd5958978e81151e6831290f57;

    address public lastwinner;

    uint[] public validplayers;

    uint public ctnum = 180;

    uint public timeleft;

    bool public active = true;

    bool public autobegin = true;

    uint public max = 24 hours;

    //mapping(uint256 => address) public lastrdowner;



    struct Ctry {

        uint256 id;

        uint256 price;

        bytes32 name;

        bytes32 mem;

        address owner;

    }



    mapping(uint256 => uint256) public totalinvest_;



    modifier isHuman() {

        address _addr = msg.sender;

        require(_addr == tx.origin);

        

        uint256 _codeLength;

        

        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }

    

    constructor()

    public

    {

        rID_++;

        validplayers.length = 0;

        timeleft = now + max;

    }



    function getvalid()

    public

    returns(uint[]){

        return validplayers;

    }

    

    function changemem(uint id, bytes32 mem)

    isHuman

    public

    payable

    {

        require(msg.sender == ctry_[rID_][id].owner);

        if (mem != ""){

            ctry_[rID_][id].mem = mem;

        }

    }



    function buy(uint id, bytes32 mem)

    isHuman

    public

    payable

    {

        require(active == true);

        require(msg.value >= 0.02 ether);

        require(msg.value >= ctry_[rID_][id].price);

        require(id <= ctnum);



        if (validplayers.length <= 50) {

            timeleft = now + max;

        }

        

        if (mem != ""){

            ctry_[rID_][id].mem = mem;

        }



        if (update() == true) {

            uint pot = (msg.value).div(10);

            pot_[rID_] += pot;



            if (rID_> 1){

                if (ctry_[rID_-1][id].owner != address(0x0)) {

                    ctry_[rID_-1][id].owner.send((msg.value).div(50));

                }

            }

        

            if (ctry_[rID_][id].owner != address(0x0)){

                ctry_[rID_][id].owner.transfer((msg.value).mul(86).div(100));

            }else{

                validplayers.push(id);

            }

            ctry_[rID_][id].owner = msg.sender;

            ctry_[rID_][id].price = (msg.value).mul(14).div(10);

        }else{

            rID_++;

            validplayers.length = 0;

            ctry_[rID_][id].owner = msg.sender;

            ctry_[rID_][id].price = 0.028 ether;

            validplayers.push(id);

            (msg.sender).send(msg.value - 0.02 ether);

        }



        lastplayer = msg.sender;

        totalinvest_[rID_] += msg.value;

        ctry_[rID_][id].id = id;

    }



    function update()

    private

    returns(bool)

    {

        if (now > timeleft) {

            uint win = pot_[rID_].mul(6).div(10);

            lastplayer.transfer(win);

            lastwinner = lastplayer;

            pot_[rID_+1] += pot_[rID_].div(5);

            pot_[rID_] = 0;

            timeleft = now + max;

            if (autobegin == false){

                active = false;  // waiting for set open again

            }

            return false;

        }



        if (validplayers.length < ctnum) {

            timeleft += gap;

        }

        

        if (timeleft > now + max) {

            timeleft = now + max;

        }

        return true;

    }



    function()

    public

    payable

    {

        

    }

    

    // add to pot

    function pot()

    public

    payable

    {

        pot_[rID_] += msg.value;

    }



    modifier onlyDevs() {

        require(

            msg.sender == 0x9ca974f2c49d68bd5958978e81151e6831290f57,

            "only team just can activate"

        );

        _;

    }



    // add more countries

    function setctnum(uint id)

    onlyDevs

    public

    {

        require(id > 180);

        ctnum = id;

    }

    

    // withdraw unreachable eth

    function withcom()

    onlyDevs

    public

    {

        if (address(this).balance > pot_[rID_]){

            uint left = address(this).balance - pot_[rID_];

            comaddr.transfer(left);

        }

    }

    

    function setActive(bool _auto)

    onlyDevs

    public

    {

        active = true;

        autobegin = _auto;

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

