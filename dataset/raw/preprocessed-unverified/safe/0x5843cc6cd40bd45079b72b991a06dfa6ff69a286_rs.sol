/**

 *Submitted for verification at Etherscan.io on 2019-01-08

*/



pragma solidity ^0.5.2;

pragma experimental ABIEncoderV2;







contract TwitterPoll is Ownable {

  using ConcatLib for string[];

  string public question;

  string[] public yesVotes;

  string[] public noVotes;



  constructor(string memory _question) public {

    question = _question;

  }



  function submitVotes(string[] memory _yesVotes, string[] memory _noVotes) public onlyOwner() {

    yesVotes.concat(_yesVotes);

    noVotes.concat(_noVotes);

  }



  function getYesVotes() public view returns (string[] memory){

    return yesVotes;

  }



  function getNoVotes() public view returns (string[] memory){

    return noVotes;

  }

}



