/**

 *Submitted for verification at Etherscan.io on 2018-12-29

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



    uint256 public registrationFee_ = 10 finney;            // price to register a name

    mapping (bytes32 => address) public nameToAddr;

    mapping (address => string[]) public addrToNames;



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

      return names[names.length-1];

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

    }



    function registerNameByOwner(string _nameString, address _addr) public onlyOwner {

      bytes32 _name = NameFilter.nameFilter(_nameString);

      require(nameToAddr[_name] == address(0), "name must not be taken by others");

      nameToAddr[_name] = _addr;

      addrToNames[_addr].push(_nameString);

    }





    function withdrawBalance(address _to) public onlyOwner {

      uint _amount = address(this).balance;

      _to.transfer(_amount);

    }

}