/**

 *Submitted for verification at Etherscan.io on 2018-08-28

*/



pragma solidity ^0.4.24;

// Spielley's King of the crypto hill beta Coallition expansion v1.01

// Coallition owner sets shares for the alliance, alliance members send in their eth winnings to share among the group

// Coallition owner can increase or decrease members and shares

// this is not a trustless situation, alliance owner can screw everyone over, only join an alliance you trust



// play at https://kotch.dvx.me/# 

// 28/08/2018



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------



contract Coallition is Owned {

     using SafeMath for uint;

     

     mapping(uint256 => address) public members;

     mapping(address => uint256) public shares;

     

     uint256 public total;

     constructor () public {

         

    }

     function addmember(uint256 index , address newmember) public onlyOwner  {

   members[index] = newmember;

}

     function addshares(uint256 sharestoadd , address member) public onlyOwner  {

shares[member] += sharestoadd;

}

function deductshares(uint256 sharestoadd , address member) public onlyOwner  {

   shares[member] -= sharestoadd;

}

function setshares(uint256 sharestoadd , address member) public onlyOwner  {

   shares[member] = sharestoadd;

}

// set total number of members

function settotal(uint256 set) public onlyOwner  {

   total = set;

}

    function payout() public payable {

        

   for(uint i=0; i< total; i++)

        {

            uint256 totalshares;

            totalshares += shares[members[i]];

        }

        uint256 base = msg.value.div(totalshares);

    for(i=0; i< total; i++)

        {

            

            uint256 amounttotransfer = base.mul(shares[members[i]]);

            members[i].transfer(amounttotransfer);

            

        }

}

function collectdustatcontract() public payable {

        

   for(uint i=0; i< total; i++)

        {

            uint256 totalshares;

            totalshares += shares[members[i]];

        }

       

        uint256 base = address(this).balance.div(totalshares);

    for(i=0; i< total; i++)

        {

            

            uint256 amounttotransfer = base.mul(shares[members[i]]);

            members[i].transfer(amounttotransfer);

            

        }

}

 function () external payable{payout();}     

}