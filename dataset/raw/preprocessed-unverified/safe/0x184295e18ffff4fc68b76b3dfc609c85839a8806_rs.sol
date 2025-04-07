/**

 *Submitted for verification at Etherscan.io on 2019-01-09

*/



pragma solidity ^0.4.24;





contract owned {

    address public owner;

    constructor() public {

        owner = msg.sender;

    }

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;

    }

}

contract SavitarToken is owned {

    using SafeMath for uint256;

    mapping (address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    

    // Token parameters

    string public name                  = "Savitar Token";

    string public symbol                = "SVT";

    uint8 public decimals               = 8;

    uint256 public totalSupply          = 50000000 * (uint256(10) ** decimals);



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {

      // Initially assign all tokens to the contract's creator.

        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);

    }

    function transfer(address to, uint256 value) public returns (bool success) {

        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);

        balanceOf[to] = balanceOf[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;

    }

    function approve(address spender, uint256 value) public returns (bool success) {

        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {

        require(value <= balanceOf[from]);

        require(value <= allowance[from][msg.sender]);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value);

        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;

    }

}