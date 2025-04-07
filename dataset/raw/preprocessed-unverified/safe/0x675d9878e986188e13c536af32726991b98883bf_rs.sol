/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


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

contract ADORsETHFarm is Ownable {
    using SafeMath for uint256;
    
    uint256 public lockDuration = 31540000;
    uint256 public yieldDuration = 31540000;
    uint256 public yieldRate = 3; // 300% APY
    uint256 public maxFarmable = 25e18;
    uint256 public minFarmable = 5e18;
    uint256 public maxProviders = 111;
    uint256 public currentProviders;
    IERC20 public yieldToken;
    IERC20 public farmToken;
    
    struct Farm {
        uint256 createdAt;
        uint256 planted;
        uint256 lastHarvest;
    }
    
    mapping(address => Farm) farms;
    
    constructor() {
        farmToken = IERC20(0xA24DDcEbCedF2A214Fe20FDc2992D244ac515498);
        yieldToken = IERC20(0x099f95b0694A0D808f7C6c46A621f4E5E5E36dF5);
    }
    
    function created(address _farmer) external view returns(uint256) {
        return farms[_farmer].createdAt;
    }
    
    function lastHarvest(address _farmer) external view returns(uint256) {
        return farms[_farmer].lastHarvest;
    }
    
    function planted(address _farmer) external view returns(uint256) {
        return farms[_farmer].planted;
    }
    
    function newFarmer(uint256 _plant) public {
        require(farms[_msgSender()].planted == 0, "Farming");
        require(currentProviders < maxProviders, "!Needed");
        require(_plant <= maxFarmable, "Much");
        require(_plant >= minFarmable, "Small");
        require(farmToken.transferFrom(_msgSender(), address(this), _plant), "Failed");
        farms[_msgSender()] = Farm({createdAt: block.timestamp, planted: _plant, lastHarvest: block.timestamp});
        currentProviders = currentProviders.add(1);
        emit NewFarm(_msgSender(), _plant);
    }
    
    function harvest() public {
        Farm storage farm = farms[_msgSender()];
        if (farm.planted > 0 && farm.createdAt.add(yieldDuration) > farm.lastHarvest) {
            uint256 thisYield = _harvestable(farm);
            require(yieldToken.transfer(_msgSender(), thisYield), "Failed");
            farm.lastHarvest = block.timestamp;
            emit Harvest(_msgSender(), thisYield);   
        }
    }
    
    function _exit() internal {
        Farm storage farm = farms[_msgSender()];
        require(block.timestamp.sub(farm.createdAt) > lockDuration);
        require(farmToken.transfer(_msgSender(), farm.planted), "Failed");
        farm.planted = 0;
        emit Exit(_msgSender());
    }
    
    function exit() public {
        harvest();
        _exit();
    }
    
    function emergencyExit() public {
        /*
        * Exit without rewards
        */
        _exit();
    }
    
    function harvestable(address _farmer) public view returns(uint256) {
        Farm memory farm = farms[_farmer];
        return _harvestable(farm);
    }
    
    function _harvestable(Farm memory _farm) internal view returns(uint256) {
        uint256 periodBoundary = Math.min(block.timestamp, _farm.createdAt.add(yieldDuration));
        uint256 thisYieldPeriod = periodBoundary.sub(_farm.lastHarvest);
        return toYieldToken(_farm.planted).mul(thisYieldPeriod).mul(yieldRate).div(yieldDuration);
    }
    
    function estimateYield(uint256 _plant) public view returns(uint256) {
        return toYieldToken(_plant).mul(yieldRate);
    }
    
    function toYieldToken(uint256 _amount) public view returns(uint256) {
        /*
        * Rate for 1 farmToken to yieldToken.
        * Could be a state variable e.g 5 ADORs (1 farmToken = 5 yieldToken)
        */
        return (_amount.mul( IERC20(yieldToken).balanceOf(address(farmToken)) ).div( IERC20(farmToken).totalSupply() )).mul(2);
    }
    
    function harvestLeftover(uint256 _plant) external onlyOwner {
        require(yieldToken.balanceOf(address(this)) >= _plant, "> Balance");
        require(yieldToken.transfer(owner(), _plant), "Failed");
        emit Harvest(owner(), _plant);
    }
    
    function setLockDuration(uint256 _duration) external onlyOwner {
        lockDuration = _duration;
    }
    
    function setMaxFarmable(uint256 _max) external onlyOwner {
        maxFarmable = _max;
    }
    
    function setMinFarmable(uint256 _min) external onlyOwner {
        minFarmable = _min;
    }
    
    function setProvider(uint256 _max) external onlyOwner {
        maxProviders = _max;
    }
    
    event NewFarm(address indexed farmer, uint256 planted);
    event Harvest(address indexed farmer, uint256 harvested);
    event Exit(address indexed farmer);
}