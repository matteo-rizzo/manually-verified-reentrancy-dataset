/**
 *Submitted for verification at Etherscan.io on 2021-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: ITrusteeCount



// Part: ITrusteeFeePool



// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Ownable

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
abstract contract Ownable is Context {
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

// File: TrusteeFeePool.sol

contract TrusteeFeePool is Ownable, ITrusteeFeePool{
    
    using SafeMath for uint256;
    
     uint256 public perTrustee;
     bytes32 public tunnelKey;

     mapping(address=>uint256) public userPerPaid;
     mapping(address=>uint256) public userReward;
     mapping(address=>uint256) public balanceOf;
     
     IERC20 public rewardToken;
     address public boringDAO;
     address public tunnel;
     
     constructor(address _rewardToken, bytes32 _tunnelKey, address _boringDAO, address _tunnel) public {
         rewardToken = IERC20(_rewardToken);
         tunnelKey = _tunnelKey;
         boringDAO = _boringDAO;
         tunnel = _tunnel;
     }

     function trusteeCount() internal view returns(uint){
         return ITrusteeCount(boringDAO).getRoleMemberCount(tunnelKey);
     }
     
     function setBoringDAO(address _boringDAO) external onlyOwner {
         boringDAO = _boringDAO;
     }
     
     function setTunnel(address _tunnel) external onlyOwner {
         tunnel = _tunnel;
     }
     
     function notifyReward(uint reward) public override onlyTunnel {
         perTrustee = perTrustee.add(reward.div(trusteeCount()));
     }
     
     function earned(address account) public view returns (uint) {
         return perTrustee.sub(userPerPaid[account]).mul(balanceOf[account]).add(userReward[account]);
     }
     
     function claim() public updateReward(msg.sender){
         uint reward = userReward[msg.sender];
         userReward[msg.sender] = 0;
         if (reward > 0) {
            rewardToken.transfer(msg.sender, reward);
         }
     }
     
     function enter(address account) external override onlyBoringDAO updateReward(account){
         balanceOf[account] = 1;
         uint reward = userReward[msg.sender];
         userReward[msg.sender] = 0;
         if (reward > 0) {
            rewardToken.transfer(msg.sender, reward);
         }

     }
     
     function exit(address account) external override onlyBoringDAO updateReward(account) {
         balanceOf[account] = 0;
     }
     
     modifier updateReward(address account) {
         userReward[account] = earned(account);
         userPerPaid[account] = perTrustee;
         _;
     }
     
     modifier onlyBoringDAO {
         require(msg.sender == boringDAO, "TrusteePool::caller is not boringDAO");
         _;
     }
     
     modifier onlyTunnel {
         require(msg.sender == tunnel, "TrusteePool::caller is not tunnel");
         _;
     }
     
}