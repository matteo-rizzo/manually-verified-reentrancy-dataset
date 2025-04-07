// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
pragma solidity ^0.7.1;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not inclusde
 * the optional functions; to access them see {ERC20Detailed}.
 */


contract TokenTimelock {

    IERC20 private _token;

    address private _beneficiary;

    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 timeLockDays) public {
        // solhint-disable-next-line not-rely-on-time
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = block.timestamp + (timeLockDays*24*3600);
        require(_releaseTime > block.timestamp, "ERROR");
    }
    function token() public view returns (IERC20) {
        return _token;
    }
    function balance() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }
    function getBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
    function canRelease() public view returns (bool) {
        if(_releaseTime < block.timestamp){return true;}
        else {return false;}
    }
    function release() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.transfer(_beneficiary, amount);
    }
}