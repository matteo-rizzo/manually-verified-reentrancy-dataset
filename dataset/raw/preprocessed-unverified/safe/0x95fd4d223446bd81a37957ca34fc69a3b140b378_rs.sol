/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

// SPDX-License-Identifier: MPL-2.0

pragma solidity 0.6.6;





contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}



contract MinterRole is ContextUpgradeSafe, OwnableUpgradeSafe {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private _minters;

  modifier onlyMinter() {
    require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return _minters.has(account);
  }

  function addMinter(address account) public onlyOwner {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(_msgSender());
  }

  function _addMinter(address account) internal {
    _minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    _minters.remove(account);
    emit MinterRemoved(account);
  }
}



/// @title  Strudel Token.
/// @notice This is the Strudel ERC20 contract.
contract StrudelWrapper is ITokenRecipient, MinterRole {

	event LogSwapin(bytes32 indexed txhash, address indexed account, uint amount);
	event LogSwapout(address indexed account, address indexed bindaddr, uint amount);

	address public strdlAddr;

	constructor(address _strdlAddr) public {
		__Ownable_init();
		strdlAddr = _strdlAddr;
	}

	function mint(address to, uint256 amount) external onlyMinter returns (bool) {
		IStrudel(strdlAddr).mint(to, amount);
		return true;
	}

	function burn(address from, uint256 amount) external onlyMinter returns (bool) {
		require(from != address(0), "StrudelWrapper: address(0x0)");
		IStrudel(strdlAddr).burnFrom(from, amount);
		return true;
	}

	function Swapin(bytes32 txhash, address account, uint256 amount) public onlyMinter returns (bool) {
		IStrudel(strdlAddr).mint(account, amount);
		emit LogSwapin(txhash, account, amount);
		return true;
	}

	function Swapout(uint256 amount, address bindaddr) public returns (bool) {
		require(bindaddr != address(0), "StrudelWrapper: address(0x0)");
		IStrudel(strdlAddr).burnFrom(msg.sender, amount);
		emit LogSwapout(msg.sender, bindaddr, amount);
		return true;
	}

	function getAddr(bytes memory _extraData) internal pure returns (address){
		address addr;
		assembly {
			addr := mload(add(_extraData,20))
		}
		return addr;
	}

	function receiveApproval(
		address _from,
		uint256 _value,
		address _token,
		bytes calldata _extraData
	) external override {
		require(msg.sender == strdlAddr, "StrudelWrapper: onlyAuth");
		require(_token == strdlAddr, "StrudelWrapper: onlyAuth");
		address bindaddr = getAddr(_extraData);
		require(bindaddr != address(0), "StrudelWrapper: address(0x0)");
		IStrudel(strdlAddr).burnFrom(_from, _value);
		emit LogSwapout(_from, bindaddr, _value);
	}
}