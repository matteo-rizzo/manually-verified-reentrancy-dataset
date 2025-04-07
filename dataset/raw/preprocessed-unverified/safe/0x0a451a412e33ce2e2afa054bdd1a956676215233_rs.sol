/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity ^0.7.0;
//SPDX-License-Identifier: UNLICENSED



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
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


contract FireVault is Context, Ownable {
    IERC20 public FIRE;
    uint constant public TheBigBurnTime = 1608854400; // 12/25/2020 @ 12:00am (UTC)
    
    
    function TheBigBurn() external {
        require(block.timestamp >= TheBigBurnTime, "The time didn't come yet!");
        require(FIRE != IERC20(address(0)),"FIRE not set");
        FIRE.burnMyTokensFOREVER(FIRE.balanceOf(address(this)));
    }
    
    function setFIREAddress(IERC20 _addr) external onlyOwner {
        require(FIRE == IERC20(address(0)),"FIRE already set");
        FIRE = _addr;
    }
    
}