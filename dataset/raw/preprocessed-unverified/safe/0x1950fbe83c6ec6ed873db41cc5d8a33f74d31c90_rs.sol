/**

 *Submitted for verification at Etherscan.io on 2018-09-30

*/



pragma solidity ^0.4.22;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



// 名称检验









contract SimpleAuction {

    using NameFilter for string;

    using SafeMath for *;

    

    

    // 受益人

    address private boss;



    // fees

    uint public fees;



    address private top;



    address private loser;



    uint private topbid;



    uint private loserbid;





    //可以取回的之前的出价

    mapping(address => uint) pendingReturns;



    mapping(address => string) giverNames;



    mapping(address => string) giverMessages;











    constructor(

        address _beneficiary

    ) public {

        boss = _beneficiary;

    }





    /// How much would you like to pay?

    function bid() public payable {

        // 如果出价不够0.0001ether

        require(

            msg.value > 0.0001 ether,

            "?????"

        );

        // 如果出价不够高，返还你的钱

        require(

            msg.value > topbid,

            "loser fuck off."

        );

        // 参数不是必要的。因为所有的信息已经包含在了交易中。

        // 对于能接收以太币的函数，关键字 payable 是必须的。

        pendingReturns[msg.sender] += (msg.value.div(10).mul(9));

        fees+= msg.value.div(10);

        

        if(top != 0){

            loser = top;

            loserbid = topbid;

        }

        top = msg.sender;

        topbid = msg.value;



        if(bytes(giverNames[msg.sender]).length== 0) {

            giverNames[msg.sender] = "#Anonymous";

            giverMessages[msg.sender] = "#Nothing";

        }

    }



    function setInfo(string _name,string _message) public {

        

        giverNames[msg.sender] = _name.filter();

        giverMessages[msg.sender] = _message.filter();

    }



    function getMyInfo() public view returns (string,string){

        return getInfo(msg.sender);

    }

    

    function getFess() public view returns (uint){

        return fees;

    }







    function getWLInfo() public view returns (string,string,uint,string,string,uint){

return (giverNames[top],giverMessages[top],topbid,giverNames[loser],giverMessages[loser],loserbid);

    }







    function getInfo(address _add) public view returns (string,string){

        return (giverNames[_add],giverMessages[_add]);

    }





    /// 取回

    function withdraw() public returns (bool) {

        require(pendingReturns[msg.sender]>0,"Nothing left for you");

        uint amount = pendingReturns[msg.sender];

        pendingReturns[msg.sender] = 0;

        msg.sender.transfer(amount);

        if(msg.sender==top){

            loser = top;

            loserbid =topbid;

            top = 0;

            topbid = 0;

        }    

        return true;

    }



    /// shouqian

    function woyaoqianqian(uint fee) public {

                require(

            fee < fees,

            "loser fuck off."

        );

        fees = fees.sub(fee);

        // 3. 交互

        boss.transfer(fee);

    }

}