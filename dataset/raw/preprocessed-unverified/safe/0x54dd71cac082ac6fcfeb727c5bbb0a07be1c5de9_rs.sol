/**

 *Submitted for verification at Etherscan.io on 2018-10-17

*/



pragma solidity ^0.4.19;



/*

Game: MylittleProgram

Dev: WhiteMatrix

*/







contract MylittleProgram {

using SafeMath for uint256;

mapping (address => bool) private admins;

mapping (uint => uint256) public levels;

mapping (uint => bool) private lock;

address contractCreator;

address winnerAddress;

uint256 prize;

function MylittleProgram () public {



contractCreator = msg.sender;

winnerAddress = 0xFb2D26b0caa4C331bd0e101460ec9dbE0A4783A4;

admins[contractCreator] = true;

}



struct Pokemon {

string pokemonName;

address ownerAddress;

uint256 currentPrice;

}

Pokemon[] pokemons;



//modifiers

modifier onlyContractCreator() {

require (msg.sender == contractCreator);

_;

}

modifier onlyAdmins() {

require(admins[msg.sender]);

_;

}



//Owners and admins



/* Owner */

function setOwner (address _owner) onlyContractCreator() public {

contractCreator = _owner;

}



function addAdmin (address _admin) public {

admins[_admin] = true;

}



function removeAdmin (address _admin) onlyContractCreator() public {

delete admins[_admin];

}



// Adresses

function setPrizeAddress (address _WinnerAddress) onlyAdmins() public {

winnerAddress = _WinnerAddress;

}



bool isPaused;

/*

When countdowns and events happening, use the checker.

*/

function pauseGame() public onlyContractCreator {

isPaused = true;

}

function unPauseGame() public onlyContractCreator {

isPaused = false;

}

function GetGamestatus() public view returns(bool) {

return(isPaused);

}



function addLock (uint _pokemonId) onlyContractCreator() public {

lock[_pokemonId] = true;

}







function getPokemonLock(uint _pokemonId) public view returns(bool) {

return(lock[_pokemonId]);

}



/*

This function allows users to purchase PokeMon.

The price is automatically multiplied by 1.5 after each purchase.

Users can purchase multiple PokeMon.

*/

function putPrize() public payable {



require(msg.sender != address(0));

prize = prize + msg.value;



}





function withdraw () onlyAdmins() public {



winnerAddress.transfer(prize);



}

function pA() public view returns (address _pA ) {

return winnerAddress;

}



function totalPrize() public view returns (uint256 _totalSupply) {

return prize;

}



}