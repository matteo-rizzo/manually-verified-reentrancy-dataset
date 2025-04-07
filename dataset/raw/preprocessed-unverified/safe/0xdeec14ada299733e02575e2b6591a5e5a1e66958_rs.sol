/**
 *Submitted for verification at Etherscan.io on 2020-11-28
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

contract RewardOwner is Context {
    address internal _molStakerContract;
    address internal _lavaStakerContract;

    constructor (address molStakerContract, address lavaStakerContract) internal {
        _molStakerContract = molStakerContract;
        _lavaStakerContract = lavaStakerContract;
    }
    
    modifier onlyMOLStakerContract() {
        require(_msgSender() == _molStakerContract, "RewardOwner: caller is not the MOLStaker contract");
        _;
    }
    
    modifier onlyLAVAStakerContract() {
        require(_msgSender() == _lavaStakerContract, "RewardOwner: caller is not the LAVAStaker contract");
        _;
    }
}

abstract contract MOLContract {
    function balanceOf(address account) external view virtual returns (uint256);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract LAVAContract {
    function balanceOf(address account) external view virtual returns (uint256);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}




contract Reward is RewardOwner {
    using SafeMath for uint256;

    LAVAContract private _lavaContract;     // lava contract
    address private _lavaUniV2Pair;         // lava uniswap-eth v2 pair

    constructor (LAVAContract lavaContract, address lavaUniV2Pair, address molStakerContract, address lavaStakerContract) RewardOwner(molStakerContract, lavaStakerContract) public {
        _lavaContract = lavaContract;
        _lavaUniV2Pair = lavaUniV2Pair;
    }
    
    function MOLStakerContract() external view returns (address) {
        return _molStakerContract;
    }
    
    function LAVAStakerContract() external view returns (address) {
        return _lavaStakerContract;
    }
    
    function getLavaBalance() external view returns (uint256) {
        return _lavaContract.balanceOf(address(this));
    }
    
    function getLavaUNIv2Balance() external view returns (uint256) {
        return IUniswapV2ERC20(_lavaUniV2Pair).balanceOf(address(this));
    }
    
    function giveLavaReward(address recipient, uint256 amount) external onlyMOLStakerContract returns (bool) {
        return _lavaContract.transfer(recipient, amount);
    }
    
    function giveLavaUNIv2Reward(address recipient, uint256 amount) external onlyLAVAStakerContract returns (bool) {
        return IUniswapV2ERC20(_lavaUniV2Pair).transfer(recipient, amount);
    }
}