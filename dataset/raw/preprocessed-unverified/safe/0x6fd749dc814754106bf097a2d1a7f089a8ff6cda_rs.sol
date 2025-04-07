/**

 *Submitted for verification at Etherscan.io on 2019-01-05

*/



pragma solidity ^0.4.24;



// File: contracts\utils\NameFilter.sol







// File: contracts\utils\Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts\PlayerBook.sol







contract PlayerBook is Ownable {

    using NameFilter for string;

    

    string constant public name = "PlayerBook";

    string constant public symbol = "PlayerBook";    



    uint256 public registrationFee_ = 10 finney;            // price to register a name

    mapping (bytes32 => address) public nameToAddr;

    mapping (address => string[]) public addrToNames;

    

    PlayerBookReceiverInterface public currentGame; 

    

    address public CFO;

    address public COO; 

    

    modifier onlyCOO() {

        require(msg.sender == COO);

        _; 

    }

    

    constructor(address _CFO, address _COO) public {

        CFO = _CFO;

        COO = _COO; 

    }

    

    function setCFO(address _CFO) onlyOwner public {

        CFO = _CFO; 

    }  

  

    function setCOO(address _COO) onlyOwner public {

        COO = _COO; 

    }  



    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }

    



    function checkIfNameValid(string _nameStr) public view returns(bool) {

      bytes32 _name = _nameStr.nameFilter();

      if (nameToAddr[_name] == address(0))

        return (true);

      else

        return (false);

    }



    function getPlayerAddr(string _nameStr) public view returns(address) {

      bytes32 _name = _nameStr.nameFilter();

      return nameToAddr[_name];

    }



    function getPlayerName() public view returns(string) {

      address _addr = msg.sender;

      string[] memory names = addrToNames[_addr];

      if(names.length > 0) {

        return names[names.length-1];

      } else {

        return ""; 

      }

    }



    function registerName(string _nameString) public isHuman payable {

      // make sure name fees paid

      require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");



      // filter name + condition checks

      bytes32 _name = NameFilter.nameFilter(_nameString);

      require(nameToAddr[_name] == address(0), "name must not be taken by others");

      address _addr = msg.sender;

      nameToAddr[_name] = _addr;

      addrToNames[_addr].push(_nameString);

      // update current game user info 

      currentGame.receivePlayerInfo(_addr, _nameString); 

    }



    function registerNameByCOO(string _nameString, address _addr) public onlyCOO {

      bytes32 _name = NameFilter.nameFilter(_nameString);

      require(nameToAddr[_name] == address(0), "name must not be taken by others");

      nameToAddr[_name] = _addr;

      addrToNames[_addr].push(_nameString);

      // update current game user info 

      currentGame.receivePlayerInfo(_addr, _nameString);       

    }

    

    

    function setCurrentGame(address _addr) public onlyCOO {

        currentGame = PlayerBookReceiverInterface(_addr); 

    }



    function withdrawBalance() public onlyCOO {

      uint _amount = address(this).balance;

      CFO.transfer(_amount);

    }

}