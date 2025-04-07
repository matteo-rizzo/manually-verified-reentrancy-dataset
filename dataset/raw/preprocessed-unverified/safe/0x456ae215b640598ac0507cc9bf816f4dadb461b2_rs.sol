/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

pragma solidity 0.5.17;





contract NimbusPriceFeed is IPriceFeedsExt, Ownable {
    
    uint256 private _latestRate;
    uint256 private _lastUpdateTimestamp;
    
    function setLatestAnswer(uint256 rate) external onlyOwner {
        _lastUpdateTimestamp = block.timestamp;
        _latestRate = rate;
    }
    
    function lastUpdateTimestamp() external view returns (uint256) {
        return _lastUpdateTimestamp;
    } 
    
    function latestAnswer() external view returns (uint256) {
        return _latestRate;
    }
}