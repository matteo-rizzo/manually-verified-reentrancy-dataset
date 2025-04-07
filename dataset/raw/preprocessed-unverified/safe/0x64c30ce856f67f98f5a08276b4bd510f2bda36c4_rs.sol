pragma solidity ^0.4.23;



contract RootInBlocks is Ownable {

  mapping(string => uint) map;

  event Added(
    string hash,
    uint time
  );

  function put(string hash) public onlyOwner {
    require(map[hash] == 0);
    map[hash] = block.timestamp;
    emit Added(hash, block.timestamp);
  }

  function get(string hash) public constant returns(uint) {
    return map[hash];
  }

}