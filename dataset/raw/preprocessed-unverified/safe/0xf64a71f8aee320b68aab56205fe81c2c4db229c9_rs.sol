/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


// 
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// 
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
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

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
contract VestingContract is Ownable {

	using SafeMath for uint256;

	// CNTR Token Contract
	IERC20 tokenContract = IERC20(0x03042482d64577A7bdb282260e2eA4c8a89C064B);

	uint256[] vestingSchedule;
	address public receivingAddress;
	uint256 public vestingStartTime;
	uint256 constant public releaseInterval = 30 days;

	uint256 public totalTokens;
	uint256 public totalDistributed;

	uint256 index = 0;

	constructor(address _address) public {
        receivingAddress = _address;
    }

	function updateVestingSchedule(uint256[] memory _vestingSchedule) public onlyOwner {
		require(vestingStartTime == 0);

		vestingSchedule = _vestingSchedule;

		for(uint256 i = 0; i < vestingSchedule.length; i++) {
			totalTokens = totalTokens.add(vestingSchedule[i]);
		}
	}

	function updateReceivingAddress(address _address) public onlyOwner {
		receivingAddress = _address;
	}

	function releaseToken() public {
		require(vestingSchedule.length > 0);
		require(msg.sender == owner() || msg.sender == receivingAddress);

		if (vestingStartTime == 0) {
			require(msg.sender == owner());
			vestingStartTime = block.timestamp;
		}


		for (uint256 i = index; i < vestingSchedule.length; i++) {
			if (block.timestamp >= vestingStartTime + (index * releaseInterval)) {
				tokenContract.transfer(receivingAddress, (vestingSchedule[i] * 1 ether));
				totalDistributed = totalDistributed.add(vestingSchedule[i]);
				
				index = index.add(1);
			} else {
				break;
			}
		}
	}

	function getVestingSchedule() public view returns (uint256[] memory) {
        return vestingSchedule;
    }
}

// 
contract VestingContractCaller is Ownable {

	using SafeMath for uint256;

	address[] vestingContracts;

	function addVestingContract(address _address) public onlyOwner {
		vestingContracts.push(_address);
	}

	function removeVestingContract(address _address) public onlyOwner {
		for (uint256 i = 0; i < vestingContracts.length; i++) {
			if (vestingContracts[i] == _address) {
				vestingContracts[i] = vestingContracts[vestingContracts.length -1];
				vestingContracts.pop();
				break;
			}
		}
	}

	function batchReleaseTokens() public onlyOwner {
		for (uint256 i = 0; i < vestingContracts.length; i++) {
			VestingContract vContract = VestingContract(vestingContracts[i]);
			vContract.releaseToken();
		}
	}

	function transferVestingContractOwnership(address _contractAddress, address _newOwner) public onlyOwner {
    	for (uint256 i = 0; i < vestingContracts.length; i++) {
    		if (vestingContracts[i] == _contractAddress) {
    			VestingContract vContract = VestingContract(vestingContracts[i]);
    			vContract.transferOwnership(_newOwner);
    			break;
    		}
    	}
    }

	function getVestingContracts() public view returns (address[] memory) {
        return vestingContracts;
    }

}