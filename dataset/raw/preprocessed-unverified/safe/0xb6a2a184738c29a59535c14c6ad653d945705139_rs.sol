/**
 *Submitted for verification at Etherscan.io on 2021-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract FROGE is IERC20 {

    bytes32 public constant name = "FROGE";
    bytes32 public constant symbol = "FROGE";
    uint8 public constant decimals = 18;

    event Mint(address indexed to, uint256 amount);	
    mapping(address => uint256) balances;
	
	address public owner;
    uint256 totalSupply_;
    uint256 minted_;
    using SafeMath for uint256;
	
	constructor() {
		totalSupply_ = 1000000000000000000000000000;
		owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
	
    function totalSupply() public override view returns (uint256) {
		return totalSupply_;
    }
    
    function totalMinted() public override view returns (uint256) {
		return minted_;
    }
	
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }
	
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    
    function mint(address receiver, uint256 numTokens) public onlyOwner returns (bool) {
        minted_ = minted_.add(numTokens);
        require(minted_ <= totalSupply_);
        
        balances[receiver] = balances[receiver].add(numTokens);
        emit Mint(receiver, numTokens);
        return true;
    }
	
	function transferOwnership(address newOwner) public onlyOwner returns (bool) {
		if (newOwner != address(0)) {
			owner = newOwner;
			return true;
		}else{
		    return false;
		}
	}
	
}

