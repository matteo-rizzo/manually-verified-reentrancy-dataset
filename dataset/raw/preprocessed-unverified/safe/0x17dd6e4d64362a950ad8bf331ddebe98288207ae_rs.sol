/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.4.25;







contract ICO{

    

    using SafeMath for uint256;

    

    mapping(address=>uint256) depositRecord;

    

    event collectionRecords(

        address indexed addr,

        uint256 amount

    );



    event refundRecords(

        address indexed addr,

        uint256 amount

    );

    

    uint256 public  total;//Total fundraising.

    uint256 public  goalOne;//After the goal is reached, the project starts.

    uint256 public  goalTwo;//End this fundraising after reaching this goal.

    

    address public  owner;//Contract manager.



    constructor() public{

      goalOne = 10000 ether;

      goalTwo = 40000 ether;

      owner = msg.sender;

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    function() payable public{



      //Not less than 0.1 ether.

      require (msg.value >= 100 finney);

      

      //No longer receive new investment after completing the second goal.

      require (goalTwo > total);

      

      depositRecord[msg.sender] = depositRecord[msg.sender].add(msg.value);

      total = total.add(msg.value);

      emit collectionRecords(msg.sender, msg.value);

    }



    //Allow investment to be returned before the first goal is reached.

    function refund() public {

      

      require (depositRecord[msg.sender] > 0);



      require (goalOne > total);



      uint256 amount = depositRecord[msg.sender];

      depositRecord[msg.sender] = 0;

      total = total.sub(amount);



      emit refundRecords(msg.sender, amount);

      msg.sender.transfer(amount);

    }

    

    function withdrawBalance() public onlyOwner {

      require (goalOne <= total);

      owner.transfer(address(this).balance);

    }



    function getBalance(address addr) public view returns(uint256) {

      return depositRecord[addr];

    }

    

}