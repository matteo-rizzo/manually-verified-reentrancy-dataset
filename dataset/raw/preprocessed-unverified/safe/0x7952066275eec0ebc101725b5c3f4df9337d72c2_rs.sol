/**
 *Submitted for verification at Etherscan.io on 2019-09-15
*/

pragma solidity ^0.5.0;










contract TokenTimelock {
    using SafeERC20 for IERC20;

    
    IERC20 private _token;

    
    address private _beneficiary;

    
    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {
        
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    
    function token() public view returns (IERC20) {
        return _token;
    }

    
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    
    function release() public {
        
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
    }
}

contract TokenTimelockTest is TokenTimelock {
    constructor () public TokenTimelock(
        IERC20(0x9da1659a203cEfE6E9C6da98C7a669a1eC3D7EdE), 
        0xEfF3cb55501f1214A3f495A2B3575260D66eAD30, 
        1568545200) {
    }
}