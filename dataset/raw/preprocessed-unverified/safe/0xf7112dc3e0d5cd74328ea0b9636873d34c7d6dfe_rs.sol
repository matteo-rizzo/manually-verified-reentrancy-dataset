/**
 *Submitted for verification at Etherscan.io on 2020-09-23
*/

pragma solidity 0.6.0;





/*
 *    Lock Moonbeam Tokens For certain Duration
 *    
 *    Create locking contract
 */
contract MYFITokenLock {

    // Safemath Liberary
    using SafeMath for uint256;

    // Unlock token duration
    uint256 public unlockDateCommunityTwo;
    uint256 public unlockDateCommunityOne;

    // Grouping token owner
    uint256 public MYFILockedCommunityOne;
    uint256 public MYFILockedCommunityTwo;
    address public owner;
    ERC20 public MYFIToken;

    //
    constructor(address _wallet) public {
        owner = msg.sender; 
        MYFIToken = ERC20(_wallet);
    }

    // Lock 10000 MYFI 3 Weeks
    function lockCommunityOneTokens (address _from, uint _amount) public {
        require(_from == owner);
        require(MYFIToken.balanceOf(_from) >= _amount);
        MYFILockedCommunityOne = _amount;
        unlockDateCommunityOne = now;
        MYFIToken.transferFrom(owner, address(this), _amount);
    }

    // Lock 1000 MYFI 3 Weeks
    function lockCommunityTwoTokens (address _from, uint256 _amount) public {
        require(_from == owner);
        require(MYFIToken.balanceOf(_from) >= _amount);
        MYFILockedCommunityTwo = _amount;
        unlockDateCommunityTwo = now;
        MYFIToken.transferFrom(owner, address(this), _amount);
    }

    function withdrawCommunityOneTokens(address _to, uint256 _amount) public {
        require(_to == owner);
        require(_amount <= MYFILockedCommunityOne);
        require(now.sub(unlockDateCommunityOne) >= 21 days);
        MYFILockedCommunityOne = MYFILockedCommunityOne.sub(_amount);
        MYFIToken.transfer(_to, _amount);
    }

    function withdrawCommunityTwoTokens(address _to, uint256 _amount) public {
        require(_to == owner);
        require(_amount <= MYFILockedCommunityTwo);
        require(now.sub(unlockDateCommunityTwo) >= 21 days);
        MYFILockedCommunityTwo = MYFILockedCommunityTwo.sub(_amount);
        MYFIToken.transfer(_to, _amount);
    }

    function balanceOf() public view returns (uint256) {
        return MYFILockedCommunityOne.add(MYFILockedCommunityTwo);
    }

}