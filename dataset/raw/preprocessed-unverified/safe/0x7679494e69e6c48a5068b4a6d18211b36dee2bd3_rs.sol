/**
 *Submitted for verification at Etherscan.io on 2021-04-02
*/

pragma solidity ^0.6.9;
//SPDX-License-Identifier: MIT






contract VRFRequestIDBase {

  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {
    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}


abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMathChainlink for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
    internal returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));

    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);

    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

 

contract CandorFi is VRFConsumerBase{
    uint[] private entryArray;
    address[] public userAddresses;
    address public owner;
    uint public totalEntry;
    uint public round;
    uint public random;
    uint public ticketPrice = 10 * 1e6; // 10$ ticket price (18 decimals)
    uint public poolLimit = 600000 * 1e6; // 6000$ pool limit
    uint public adminFee = 99; //99% admin fee
    IERC20 public token;
    
    bytes32 internal keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
	uint internal fee;
	uint public randomResult;
	uint public oldRandomResult;
	
    struct User{
        bool isEntered;
        uint totalEntries;
    }
    modifier onlyOwner{
        require(msg.sender == owner,"Only owner allowed");
        _;
    }
    mapping(uint => address) public entryMapping;
    mapping(uint => mapping(address => User)) public userInfo;
    
    event RandomNumberGenerated(bytes32,uint256);
    event EntryComplete(address,uint,uint);
    event WinnerPicked(address,uint);
    
    function setTicketPrice(uint value) external onlyOwner{
       ticketPrice = value; 
    }
    
    function setPoolLimit(uint value) external onlyOwner{
        poolLimit = value;
    }
    
    function setAdminFee(uint value) external onlyOwner{
        adminFee = value;
    }
    
    function withdrawLink(uint value) external onlyOwner {
    	require(LINK.transfer(msg.sender, value), "Unable to transfer");
    }
    
    function transferOwnership(address newOwner) external onlyOwner{
        owner = newOwner;
    }
    
    //Mainnet network
    constructor() VRFConsumerBase (
            0xf0d54349aDdcf704F77AE15b96510dEA15cb7952,  //VRF Coordinator
	        0x514910771AF9Ca656af840dff83E8264EcF986CA   //LINK token
           ) public {
        fee = 2000000000000000000; // 2 LINK
        owner = msg.sender;
        token = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC contract address
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        emit RandomNumberGenerated(requestId,randomResult);
    }
    
    function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, getSeed());
    }
    
    function enterLottery(uint256 amount) external {
        require(amount >= ticketPrice && amount <= (poolLimit / 4),"Invalid amount!");
        require(!userInfo[round][msg.sender].isEntered,"Already entered!");
        require(token.allowance(msg.sender,address(this)) >= amount,"Set allowance first!");
        bool success = token.transferFrom(msg.sender,address(this),amount);
        require(success,"Transfer failed");
        require(token.balanceOf(address(this)) <= poolLimit,"Pool already full");
        uint ticketCount = amount.div(ticketPrice);
        require((totalEntry + ticketCount) <= (poolLimit / ticketPrice),"Buy lower amount of tickets");
        userInfo[round][msg.sender].totalEntries = ticketCount;
        userInfo[round][msg.sender].isEntered = true;
        entryArray.push(totalEntry);
        entryMapping[totalEntry] = msg.sender; 
        totalEntry += ticketCount;
        userAddresses.push(msg.sender);
        emit EntryComplete(msg.sender,amount,ticketCount);
    }
    
    function pickWinner() external onlyOwner{
        require(userAddresses.length >=4,"Atleast 4 participants");
        require(oldRandomResult != randomResult,"Update random number first!");
        oldRandomResult = randomResult;
        uint totalBalance = token.balanceOf(address(this));
        uint winner = calculateWinner((randomResult.mod(totalEntry)));
        address wonUser = entryMapping[winner];
        token.transfer(owner,(totalBalance * adminFee) / 100);
        totalBalance -= (totalBalance * adminFee) / 100;
        token.transfer(wonUser,totalBalance);
        emit WinnerPicked(wonUser,(randomResult.mod(totalEntry)));
        totalEntry = 0;
        entryArray = new uint[](0);
        userAddresses = new address[](0);
        round++;
    }
    
    function getSeed() private view returns(uint) {
		return uint(keccak256(abi.encodePacked(block.difficulty, now, userAddresses)));
	}
	
	function calculateWinner(uint target) internal view returns(uint){
	    uint last = entryArray.length; 
	    uint first = 0;
	    uint mid = 0;
	    if(target <= entryArray[0]){
	        return entryArray[0];
	    }
	    
	    if(target >= entryArray[last-1]){
	        return entryArray[last-1];
	    }
	    
	    while(first < last){
	        mid = (first + last) / 2;
	        
	        if(entryArray[mid] == target){
	            return entryArray[mid];
	        }
	        
	        if(target < entryArray[mid]){
	            if(mid > 0 && target > entryArray[mid - 1]){
	                return entryArray[mid - 1];
	            }
	            
	            last = mid;
	        }
	        else{
	            if(mid < last - 1 && target < entryArray[mid + 1]){
	                return entryArray[mid];
	            }
	            
	            first = mid + 1;
	        }
	    }
	    return entryArray[mid];
	}
	
	function winningAmount() public view returns(uint amount,uint winchance){
	    return(
	        token.balanceOf(address(this)) * 8 / 10,
	        (userInfo[round][msg.sender].totalEntries * 100) / totalEntry);
	}
	
	function allUsers() external view returns(address[] memory){
	    return userAddresses;
	}
	
	function transferAnyERC20(address _tokenAddress, address _to, uint _amount) public onlyOwner {
	    require(_tokenAddress != address(token),"Not USDT");
        IERC20(_tokenAddress).transfer(_to, _amount);
    }
	
}