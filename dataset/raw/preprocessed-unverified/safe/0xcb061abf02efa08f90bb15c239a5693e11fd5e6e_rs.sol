/**
 *Submitted for verification at Etherscan.io on 2020-11-15
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;













contract TreasuryVault {
    using SafeERC20 for IERC20;
    
    address public governance;
    address public onesplit;
    address public rewards = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    //change to AFIRewards.sol address
    address public ygov = address(0xE8B7eB8629e4FF2bC5a0d10933AF6569261C445D);
    
    mapping(address => bool) authorized;
    
    constructor() public {
        governance = msg.sender;
        onesplit = address(0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e);
    }
    
    function setOnesplit(address _onesplit) external {
        require(msg.sender == governance, "!governance");
        onesplit = _onesplit;
    }
    
    function setRewards(address _rewards) external {
        require(msg.sender == governance, "!governance");
        rewards = _rewards;
    }
    
    function setYGov(address _ygov) external {
        require(msg.sender == governance, "!governance");
        ygov = _ygov;
    }
    
    function setAuthorized(address _authorized) external {
        require(msg.sender == governance, "!governance");
        authorized[_authorized] = true;
    }
    
    function revokeAuthorized(address _authorized) external {
        require(msg.sender == governance, "!governance");
        authorized[_authorized] = false;
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function toGovernance(address _token, uint _amount) external {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(governance, _amount);
    }
    
    function toVoters() external {
        uint _balance = IERC20(rewards).balanceOf(address(this));
        IERC20(rewards).safeApprove(ygov, 0);
        IERC20(rewards).safeApprove(ygov, _balance);
        Governance(ygov).notifyRewardAmount(_balance);
    }
    
    function getExpectedReturn(address _from, address _to, uint parts) external view returns (uint expected) {
        uint _balance = IERC20(_from).balanceOf(address(this));
        (expected,) = OneSplitAudit(onesplit).getExpectedReturn(_from, _to, _balance, parts, 0);
    }
    
    // Only allows to withdraw non-core strategy tokens ~ this is over and above normal yield
    function convert(address _from, uint parts) external {
        require(authorized[msg.sender]==true,"!authorized");
        uint _amount = IERC20(_from).balanceOf(address(this));
        uint[] memory _distribution;
        uint _expected;
        IERC20(_from).safeApprove(onesplit, 0);
        IERC20(_from).safeApprove(onesplit, _amount);
        (_expected, _distribution) = OneSplitAudit(onesplit).getExpectedReturn(_from, rewards, _amount, parts, 0);
        OneSplitAudit(onesplit).swap(_from, rewards, _amount, _expected, _distribution, 0);
    }
}