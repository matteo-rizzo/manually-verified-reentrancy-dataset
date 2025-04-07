/**
 *Submitted for verification at Etherscan.io on 2020-11-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.2;

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



/**
 * @dev Collection of functions related to the address type
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


 /* @dev Contract module which provides a basic access control mechanism, where
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
    constructor () {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract YMF20UNIFarm is Ownable {
    using SafeMath for uint256;

    uint256 public farmYieldRate = 50;
    uint256 public farmDecimals = 1e18;
    IERC20 public yieldToken;
    IERC20 public farmToken;
    
    struct Farm {
        uint256 planted;
        uint256 lastHarvest;
    }
    
    mapping(address => Farm) farms;
    
    constructor() {
        farmToken = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
        yieldToken = IERC20(0x16bE21C08EB27953273608629e4397556c561D26);
    }
    
    function lastHarvest(address _farmer) external view returns(uint256) {
        return farms[_farmer].lastHarvest;
    }
    
    function planted(address _farmer) external view returns(uint256) {
        return farms[_farmer].planted;
    }
    
    function newFarmer(uint256 _plant) public {
        require(_plant > 0, "Cannot farm zero");
        uint256 prevPlanted = farms[_msgSender()].planted;
        
        if (prevPlanted > 0) {
            harvest();
        }
        _plant = _plant.add(prevPlanted);
        require(farmToken.transferFrom(_msgSender(), address(this), _plant), "Could not transfer token to farm");
        farms[_msgSender()] = Farm({lastHarvest: block.timestamp, planted: _plant});
        emit NewFarmer(_msgSender(), _plant);
    }
    
    function exit() public {
        harvest();
        _exit();
    }
    
    function emergencyExit() public {
        _exit();
    }
    
    function _exit() internal {
        Farm storage farm = farms[_msgSender()];
        require(farmToken.transfer(_msgSender(), farm.planted), "Could not transfer farmed token");
        farm.planted = 0;
        emit Exit(_msgSender());
    }
    
    function harvest() public {
        Farm storage farm = farms[_msgSender()];
        
        if (farm.planted > 0) {
            uint256 thisYield = _harvestable(farm);
            farm.lastHarvest = block.timestamp;
            
            if (yieldToken.balanceOf(address(this)) < thisYield) {
                 thisYield = yieldToken.balanceOf(address(this));
            }
            require(yieldToken.transfer(_msgSender(), thisYield), "Could not transfer yield token"); 
            emit Harvest(_msgSender(), thisYield);
        }
    }
    
    function harvestable(address _farmer) public view returns(uint256) {
        Farm memory farm = farms[_farmer];
        return _harvestable(farm);
    }
    
    function _harvestable(Farm memory _farm) internal view returns(uint256) {
        uint256 duration = block.timestamp.sub(_farm.lastHarvest);
        uint256 inFarmToken = _farm.planted.mul(duration).mul(1369).div(1e5).div(86400);
        return toYieldToken(inFarmToken);
    }
    
    function toYieldToken(uint256 _amount) public view returns(uint256) {
        return _amount.mul(1e8).div(farmYieldRate).div(farmDecimals);
    }
    
    function updateFarmYeidRate(uint256 _rate) public onlyOwner {
        farmYieldRate = _rate;
    } 
    
    event NewFarmer(address indexed farmer, uint256 amount);
    event Exit(address indexed farmer);
    event Harvest(address indexed farmer, uint256 amount);
}