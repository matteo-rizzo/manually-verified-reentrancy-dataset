/**
 *Submitted for verification at Etherscan.io on 2021-05-25
*/

pragma solidity ^0.6.12;





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



contract Holder is Ownable {
  bytes32 password;
  bool public isPassUsed;
  uint256 public holdTime;

  constructor(bytes32 _password) public {
    password = _password;
    holdTime = now + 365 days;
  }

  function withdrawETH() external onlyOwner {
    require(now >= holdTime, "EARLY");
    uint256 amount = address(this).balance;
    payable(owner()).transfer(amount);
  }

  function withdrawERC20(address _token) external onlyOwner {
    require(now >= holdTime, "EARLY");
    uint256 amount = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(owner(), amount);
  }

  function emergencyWithdrawETH(string calldata _password) external onlyOwner {
     require(keccak256(abi.encodePacked(_password)) == password, "WRONG PASS");
     uint256 amount = address(this).balance;
     payable(owner()).transfer(amount);
     isPassUsed = true;
  }

  function emergencyWithdrawERC20(string calldata _password, address _token) external onlyOwner {
     require(keccak256(abi.encodePacked(_password)) == password, "WRONG PASS");
     uint256 amount = IERC20(_token).balanceOf(address(this));
     IERC20(_token).transfer(owner(), amount);
     isPassUsed = true;
  }

  function setNewPassword(bytes32 _password) external onlyOwner {
     require(isPassUsed, "OLD PASS MUST BE USED");
     password = _password;
     isPassUsed = false;
  }

  // not allow increase more than 1 year per one transaction
  // for case if user pass too big number in param
  function increaseHoldTime(uint256 _addTime) external onlyOwner {
     require(_addTime <= 365 days, "CAN NOT SET MORE THAN 1 YEAR");
     holdTime = holdTime + _addTime;
  }

  function renounceOwnership() public override onlyOwner {
     revert("NOT ALLOW LEAVE CONTRACT");
  }

  // fallback payable function to receive ether
  receive() external payable{}
}