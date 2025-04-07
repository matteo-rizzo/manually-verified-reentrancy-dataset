/**
 *Submitted for verification at Etherscan.io on 2021-10-09
*/

pragma solidity >=0.5.0;





contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address payable public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == owner;
    }
    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



contract Whitelist is Ownable {
    using SafeMath for uint256;
    
    CosmoChamber cosmoChamber;
    
    event NewNFTPrice(uint256 indexed _newprice);
    
    uint256 public NFTprice = 0.03 * 10**18;
	mapping (address => bool) public IfWhiteList;
    
	constructor(
		address cosmoChamberAddress
	) public {
		cosmoChamber = CosmoChamber(cosmoChamberAddress);
	}
	
	function mint(uint _amount) public payable {
	    require(msg.value >= NFTprice.mul(_amount), "Insufficient ETH");
	    require(_amount > 0 && _amount <= 2, "Invalid amount");
	    require(_ifWhiteListed(msg.sender), "Unqualified!");
        IfWhiteList[msg.sender] = false;
	    cosmoChamber.authorizedGenerator(_amount, msg.sender);
	}
	
	function setWhitelist(address[] memory _users) public onlyOwner {
	    uint userLength = _users.length;
	    for (uint i = 0; i < userLength; i++) {
	        IfWhiteList[_users[i]] = true;
	    }
	}
	
	function _ifWhiteListed(address _user) private view returns(bool) {
	    return IfWhiteList[_user];
	}
	
	function setNFTPrice(uint256 _newPrice) public onlyOwner {
	    require(_newPrice > 0);
	    NFTprice = _newPrice;
	    emit NewNFTPrice(_newPrice);
	}
}

contract CosmoChamberWhiteList is Whitelist {
    constructor(address _cosmoChamberAddress) public Whitelist(_cosmoChamberAddress) {
		
	}
	
	function withdrawBalance() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}