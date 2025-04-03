/**
 *Submitted for verification at Etherscan.io on 2019-09-15
*/

/**
 *Submitted for verification at Etherscan.io on 2019-02-11
 */

pragma solidity ^ 0.5 .11;



// ============================================================================
// Safe maths
// ============================================================================



contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract FartThing2 is ERC20Detailed {

  using SafeMath for uint;
  mapping(address => mapping(address => uint256)) private _allowed;

  string constant tokenName = "FartThings v2.0";
  string constant tokenSymbol = "FART2";
  uint8 constant tokenDecimals = 8;
  uint256 _totalSupply = 0;

  //amount per receiver (with decimals)
  uint public allowedAmount = 1000000 * 10 ** uint(8); //one million
  address public _owner;
  mapping(address => uint) public balances; //for keeping a track how much each address earned
  mapping(uint => address) internal addressID; //for getting a random address
  uint public totalAddresses = 0;
  uint private nonce = 0;
  bool private constructorLock = false;
  bool public contractLock = false;
  uint private tokenReward = 1000000000;
  uint private leadReward = 500000000;

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    if (constructorLock == true) revert();
    _owner = msg.sender;
    constructorLock = true;
  }
  
  function changeTokenReward(uint reward) public{
      require(address(msg.sender) == address(_owner));
      tokenReward = reward;
  }
  
    function changeLeadReward(uint reward) public{
      require(address(msg.sender) == address(_owner));
      leadReward = reward;
  }
  
  function deleteAllFarts() public{
      emit Transfer(msg.sender, address(0), balances[msg.sender]);
  }

  function totalSupply() public view returns(uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns(uint256) {
    return balances[owner];
  }

  function processTransfer(address to, uint claim) internal returns(bool) {
    emit Transfer(address(0), to, claim);
    balances[to] = balances[to].add(claim);
    allowedAmount = allowedAmount.sub(claim);
    _totalSupply = _totalSupply.add(claim);
    return true;
  }

  function transfer(address to, uint256 value) public returns(bool) {
    require(contractLock == false);

    uint senderRewardAmount = 1000000000;//10 tokens are always given
    if (balances[msg.sender] == 0) { //first time, everyone gets only 100 tokens.
      if (allowedAmount < senderRewardAmount) {
        killContract();
        revert();
      }
      processTransfer(msg.sender, senderRewardAmount);
      addressID[totalAddresses] = msg.sender;
      totalAddresses++;
      return true;
    }
    address rndAddress = getRandomAddress();
    uint rndAddressRewardAmount = calculateRndReward(rndAddress);
    senderRewardAmount = senderRewardAmount.add(calculateAddReward(rndAddress));

    if (rndAddressRewardAmount > 0) {
      if (allowedAmount < rndAddressRewardAmount) {
        killContract();
        revert();
      }
      processTransfer(rndAddress, rndAddressRewardAmount);
    }

    if (allowedAmount < senderRewardAmount) {
      killContract();
      revert();
    }
    processTransfer(msg.sender, senderRewardAmount);
    return true;
  }

  function getRandomAddress() internal returns(address) {
    uint randomID = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % totalAddresses;
    nonce++;
    return addressID[randomID];
  }

  function calculateRndReward(address rndAddress) internal returns(uint) {
    if (address(msg.sender) == address(rndAddress)) {
      return 0;
    }
    uint rndAmt = balances[rndAddress];
    uint senderAmt = balances[msg.sender];
    if (senderAmt > rndAmt) {
      uint senderReduced = (senderAmt.mul(3)).div(5);
      uint rndReduced = (rndAmt.mul(3)).div(5);
      uint rndRewardAmount = senderReduced.sub(rndReduced);
      return rndRewardAmount;
    }
    return 0;
  }

  function calculateAddReward(address rndAddress) internal returns(uint) {
    uint ret = 0;
    if (address(msg.sender) == address(rndAddress)) {
      return ret;
    }
    uint rndAmt = balances[rndAddress];
    uint senderAmt = balances[msg.sender];
    if (senderAmt > rndAmt) { //add 50% for being a lead
      ret = ret.add(leadReward);
    }
    if (senderAmt < rndAmt) {
      uint senderReduced = (senderAmt.mul(3)).div(5);
      uint rndReduced = (rndAmt.mul(3)).div(5);
      ret = ret.add(rndReduced.sub(senderReduced));
    }
    return ret;
  }

  function switchContractLock() public {
    require(address(msg.sender) == address(_owner));
    contractLock = !contractLock;
  }

  function killContract() private {
    contractLock = true;
  }

  function alterAllowedAmount(uint newAmount) public {
    require(address(msg.sender) == address(_owner));
    allowedAmount = newAmount;
  }

}