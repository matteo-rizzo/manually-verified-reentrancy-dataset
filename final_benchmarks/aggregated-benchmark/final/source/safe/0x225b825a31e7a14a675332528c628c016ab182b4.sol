contract Pay2Chat {
  string[] private data;

  function addMessage(string memory message) public {
    data.push(message);
  }

  function maxMessageIndex() public view returns(uint256) {
    return data.length;
  }

  function minMessageIndex() public pure returns(uint256) {
    return 0;
  }

  function getMessageAtIndex(uint256 index) public view returns(string memory) {
    return data[index];
  }
}
