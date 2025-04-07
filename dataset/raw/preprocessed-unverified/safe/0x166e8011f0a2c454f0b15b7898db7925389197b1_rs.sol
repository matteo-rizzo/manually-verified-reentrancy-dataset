pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


//-------------------------------------------------------------------------------------------------

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


//-------------------------------------------------------------------------------------------------

contract AifiAsset is Ownable {
  using SafeMath for uint256;

  enum AssetState { Pending, Active, Expired }
  string public assetType;
  uint256 public totalSupply;
  AssetState public state;

  constructor() public {
    state = AssetState.Pending;
  }

  function setState(AssetState _state) public onlyOwner {
    state = _state;
    emit SetStateEvent(_state);
  }

  event SetStateEvent(AssetState indexed state);
}

//-------------------------------------------------------------------------------------------------

contract InitAifiAsset is AifiAsset {
  string public assetType = "DEBT";
  uint public initialSupply = 1000 * 10 ** 18;
  string[] public subjectMatters;
  
  constructor() public {
    totalSupply = initialSupply;
  }

  function addSubjectMatter(string _subjectMatter) public onlyOwner {
    subjectMatters.push(_subjectMatter);
  }

  function updateSubjectMatter(uint _index, string _subjectMatter) public onlyOwner {
    require(_index <= subjectMatters.length);
    subjectMatters[_index] = _subjectMatter;
  }

  function getSubjectMattersSize() public view returns(uint) {
    return subjectMatters.length;
  }
}