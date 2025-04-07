/**
 *Submitted for verification at Etherscan.io on 2021-07-06
*/

pragma solidity ^0.5.12;

contract BDSCITransferableTrustFundAccount {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function withdrawAll() public {
        require(owner == msg.sender);
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAmount(uint256 amount) public {
        require(owner == msg.sender);
        require(address(this).balance >= amount);
        msg.sender.transfer(amount);
    }

    function() external payable {}

    function transferAccount(address newAccount) public {
    require(owner == msg.sender);
    require(newAccount != address(0));
    owner = newAccount;
    }

    function terminateAccount() public {
    require(owner == msg.sender);
    selfdestruct(msg.sender);
    }
}

contract BDSCIAssetTokenized{
uint public supply;
uint public pricePerEth;
mapping( address => uint ) public balance;

constructor() public {
    supply = 1000000000000;                    // There are a total of 1000 tokens for this asset
    pricePerEth = 100000000000000000; // One token costs 0.1 ether
  }

  function check() public view returns(uint) {
    return balance[msg.sender];
  }

  function () external payable {
    balance[msg.sender] += msg.value/pricePerEth; // adds asset tokens to how much ether is sent by the investor
    supply -= msg.value/pricePerEth;              //subtracts the remaining asset tokens from the total supply
  }
}

contract CoreInterface {

    /* Module manipulation events */

    event ModuleAdded(string name, address indexed module);

    event ModuleRemoved(string name, address indexed module);

    event ModuleReplaced(string name, address indexed from, address indexed to);


    /* Functions */

    function set(string memory  _name, address _module, bool _constant) public;

    function setMetadata(string memory _name, string  memory _description) public;

    function remove(string memory _name) public;
    
    function contains(address _module)  public view returns (bool);

    function size() public view returns (uint);

    function isConstant(string memory _name) public view returns (bool);

    function get(string memory _name)  public view returns (address);

    function getName(address _module)  public view returns (string memory);

    function first() public view returns (address);

    function next(address _current)  public view returns (address);
}

