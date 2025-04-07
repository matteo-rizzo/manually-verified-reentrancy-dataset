pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2Ï€.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be sent to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
 */
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  constructor() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/pixie/PixieTokenAirdropper.sol

contract PixieTokenAirdropper is Ownable, HasNoEther {

  // The token which is already deployed to the network
  ERC20Basic public token;

  event AirDroppedTokens(uint256 addressCount);
  event AirDrop(address indexed receiver, uint256 total);

  // After this contract is deployed, we will grant access to this contract
  // by calling methods on the token since we are using the same owner
  // and granting the distribution of tokens to this contract
  constructor(address _token) public payable {
    require(_token != address(0), "Must be a non-zero address");

    token = ERC20Basic(_token);
  }

  function transfer(address[] _address, uint256[] _values) onlyOwner public {
    require(_address.length == _values.length, "Address array and values array must be same length");

    for (uint i = 0; i < _address.length; i += 1) {
      _transfer(_address[i], _values[i]);
    }

    emit AirDroppedTokens(_address.length);
  }

  function transferSingle(address _address, uint256 _value) onlyOwner public {
    _transfer(_address, _value);

    emit AirDroppedTokens(1);
  }

  function _transfer(address _address, uint256 _value) internal {
    require(_address != address(0), "Address invalid");
    require(_value > 0, "Value invalid");

    token.transfer(_address, _value);

    emit AirDrop(_address, _value);
  }

  function remainingBalance() public view returns (uint256) {
    return token.balanceOf(address(this));
  }

  // after we distribute the bonus tokens, we will send them back to the coin itself
  function ownerRecoverTokens(address _beneficiary) external onlyOwner {
    require(_beneficiary != address(0));
    require(_beneficiary != address(token));

    uint256 _tokensRemaining = token.balanceOf(address(this));
    if (_tokensRemaining > 0) {
      token.transfer(_beneficiary, _tokensRemaining);
    }
  }

}