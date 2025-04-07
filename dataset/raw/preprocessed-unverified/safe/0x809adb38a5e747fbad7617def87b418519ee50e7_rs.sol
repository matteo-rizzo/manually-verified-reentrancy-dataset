/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract StoreOwner is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor (address ownerAddress) internal {
        _owner = ownerAddress;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

abstract contract NKTContract {
    function balanceOf(address account) external view virtual returns (uint256);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

contract NKTStore is StoreOwner {
    using SafeMath for uint256;

    NKTContract private _mainToken;     // main token

    constructor (NKTContract mainToken, address ownerAddress) StoreOwner(ownerAddress) public {
        _mainToken = mainToken;
    }
    
    function getStoreBalance() external view returns (uint256) {
        return _mainToken.balanceOf(address(this));
    }
    
    function giveReward(address recipient, uint256 amount) external onlyOwner returns (bool) {
        return _mainToken.transfer(recipient, amount);
    }
    
    function withdrawAll(address recipient) external onlyOwner returns (bool) {
        uint256 balance = _mainToken.balanceOf(address(this));
        return _mainToken.transfer(recipient, balance);
    } 
    
}