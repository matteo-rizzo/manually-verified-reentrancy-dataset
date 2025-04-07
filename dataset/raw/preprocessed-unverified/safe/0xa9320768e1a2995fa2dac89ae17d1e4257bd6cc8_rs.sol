/**

 *Submitted for verification at Etherscan.io on 2018-10-17

*/



pragma solidity ^0.4.24;



contract WorldByEth {

    using SafeMath for *;

    using NameFilter for string;

    



    string constant public name = "ETH world cq";

    string constant public symbol = "ecq";

    uint256 public rID_;

    uint256 public pID_;

    uint256 public com_;

    address public comaddr = 0x9ca974f2c49d68bd5958978e81151e6831290f57;

    mapping(uint256 => uint256) public pot_;

    mapping(uint256 => mapping(uint256 => Ctry)) public ctry_;

    uint public gap = 1 hours;

    uint public timeleft;

    address public lastplayer = 0x9ca974f2c49d68bd5958978e81151e6831290f57;

    address public lastwinner;

    uint[] public validplayers;

    uint private ctnum = 181;



    struct Ctry {

        uint256 id;

        uint256 price;

        bytes32 name;

        bytes32 mem;

        address owner;

    }



    mapping(uint256 => uint256) public totalinvest_;



    //===========

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

        pID_++;

        rID_++;

        validplayers.length = 0;

        timeleft = now + 24 hours;

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

        require(msg.value >= 0.1 ether);

        require(msg.sender == ctry_[rID_][id].owner);

        com_ += msg.value;

        if (mem != ""){

            ctry_[rID_][id].mem = mem;

        }

    }



    function buy(uint id, bytes32 mem)

    isHuman

    public

    payable

    {

        require(msg.value >= 0.01 ether);

        require(msg.value >=ctry_[rID_][id].price);

        require(id<=ctnum);



        if (mem != ""){

            ctry_[rID_][id].mem = mem;

        }



        if (update() == true) {

            uint com = (msg.value).div(50);

            com_ += com;



            uint pot = (msg.value).mul(8).div(100);

            pot_[rID_] += pot;



            uint pre = msg.value - com - pot;

        

            if (ctry_[rID_][id].owner != address(0x0)){

                ctry_[rID_][id].owner.transfer(pre);

            }else{

                validplayers.push(id);

            }    

            ctry_[rID_][id].owner = msg.sender;

            ctry_[rID_][id].price = (msg.value).mul(14).div(10);

        }else{

            rID_++;

            validplayers.length = 0;

            ctry_[rID_][id].owner = msg.sender;

            ctry_[rID_][id].price = (0.01 ether).mul(14).div(10);

            validplayers.push(id);

            (msg.sender).transfer(msg.value - 0.01 ether);

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

            lastplayer.transfer(pot_[rID_].mul(6).div(10));

            lastwinner = lastplayer;

            com_ += pot_[rID_].div(10);

            pot_[rID_+1] += pot_[rID_].mul(3).div(10);

            timeleft = now + 24 hours;

            return false;

        }



        timeleft += gap;

        if (timeleft > now + 24 hours) {

            timeleft = now + 24 hours;

        }

        return true;

    }



    function()

    public

    payable

    {

        com_ += msg.value;

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

        require(id > 181);

        ctnum = id;

    }



    // upgrade withdraw com_ and clear it to 0

    function withcom()

    onlyDevs

    public

    {

        if (com_ <= address(this).balance){

            comaddr.transfer(com_);

            com_ = 0;

        }else{

            comaddr.transfer(address(this).balance);

        }

    }

}







// File: contracts/library/SafeMath.sol



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

