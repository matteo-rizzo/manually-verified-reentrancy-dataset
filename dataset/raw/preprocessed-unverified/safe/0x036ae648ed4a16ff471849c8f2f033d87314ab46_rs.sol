pragma solidity 0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */



/**
 * Math operations with safety checks
 */



/**
 * @title HardCap
 * @dev Allows updating and retrieveing of Conversion HardCap for ABLE tokens
 *
 * ABI
 * [{"constant": true,"inputs": [{"name": "_symbol","type": "string"}],"name": "getCap","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "owner","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_symbol","type": "string"},{"name": "_cap","type": "uint256"}],"name": "updateCap","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "data","type": "uint256[]"}],"name": "updateCaps","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "getHardCap","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "","type": "bytes32"}],"name": "caps","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "newOwner","type": "address"}],"name": "transferOwnership","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"anonymous": false,"inputs": [{"indexed": false,"name": "timestamp","type": "uint256"},{"indexed": false,"name": "symbol","type": "bytes32"},{"indexed": false,"name": "rate","type": "uint256"}],"name": "CapUpdated","type": "event"}]
 */
contract HardCap is Ownable {
  using SafeMath for uint;
  event CapUpdated(uint timestamp, bytes32 symbol, uint rate);
  
  mapping(bytes32 => uint) public caps;
  uint hardcap = 0;

  /**
   * @dev Allows the current owner to update a single cap.
   * @param _symbol The symbol to be updated. 
   * @param _cap the cap for the symbol. 
   */
  function updateCap(string _symbol, uint _cap) public onlyOwner {
    caps[sha3(_symbol)] = _cap;
    hardcap = hardcap.add(_cap) ;
    CapUpdated(now, sha3(_symbol), _cap);
  }

  /**
   * @dev Allows the current owner to update multiple caps.
   * @param data an array that alternates sha3 hashes of the symbol and the corresponding cap . 
   */
  function updateCaps(uint[] data) public onlyOwner {
    require(data.length % 2 == 0);
    uint i = 0;
    while (i < data.length / 2) {
      bytes32 symbol = bytes32(data[i * 2]);
      uint cap = data[i * 2 + 1];
      caps[symbol] = cap;
      hardcap = hardcap.add(cap);
      CapUpdated(now, symbol, cap);
      i++;
    }
  }

  /**
   * @dev Allows the anyone to read the current cap.
   * @param _symbol the symbol to be retrieved. 
   */
  function getCap(string _symbol) public constant returns(uint) {
    return caps[sha3(_symbol)];
  }
  
  /**
   * @dev Allows the anyone to read the current hardcap.
   */
  function getHardCap() public constant returns(uint) {
    return hardcap;
  }

}