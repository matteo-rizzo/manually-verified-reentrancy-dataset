/**
 *Submitted for verification at Etherscan.io on 2020-09-26
*/

/* Token lock contract for YF Gamma Staking tokens 
*/
pragma solidity 0.6.0;





/*
 *    Lock YF Gamma Tokens and create lock contract
 */
contract YFGMTokenLock {

    // Safemath Liberary
    using SafeMath for uint256;

    // Unlock token duration
    uint256 public unlockTwoDate;
    uint256 public unlockOneDate;

    // Grouping token owner
    uint256 public YFGMLockOne;
    uint256 public YFGMLockTwo;
    address public owner;
    ERC20 public YFGMToken;

    //
    constructor(address _wallet) public {
        owner = msg.sender; 
        YFGMToken = ERC20(_wallet);
    }

    // Lock 10000 YFGM for 21 days
    function LockOneTokens (address _from, uint _amount) public {
        require(_from == owner);
        require(YFGMToken.balanceOf(_from) >= _amount);
        YFGMLockOne = _amount;
        unlockOneDate = now;
        YFGMToken.transferFrom(owner, address(this), _amount);
    }

    // Lock 1000 YFGM for 21 days
    function LockTwoTokens (address _from, uint256 _amount) public {
        require(_from == owner);
        require(YFGMToken.balanceOf(_from) >= _amount);
        YFGMLockTwo = _amount;
        unlockTwoDate = now;
        YFGMToken.transferFrom(owner, address(this), _amount);
    }

    function withdrawOneTokens(address _to, uint256 _amount) public {
        require(_to == owner);
        require(_amount <= YFGMLockOne);
        require(now.sub(unlockOneDate) >= 21 days);
        YFGMLockOne = YFGMLockOne.sub(_amount);
        YFGMToken.transfer(_to, _amount);
    }

    function withdrawTwoTokens(address _to, uint256 _amount) public {
        require(_to == owner);
        require(_amount <= YFGMLockTwo);
        require(now.sub(unlockTwoDate) >= 21 days);
        YFGMLockTwo = YFGMLockTwo.sub(_amount);
        YFGMToken.transfer(_to, _amount);
    }

    function balanceOf() public view returns (uint256) {
        return YFGMLockOne.add(YFGMLockTwo);
    }

}