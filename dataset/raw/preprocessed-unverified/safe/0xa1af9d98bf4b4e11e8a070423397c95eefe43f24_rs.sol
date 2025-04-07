/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;



contract MultiAirdropINJ {
    IERC20 public inj;
    address public  owner;
    mapping(address => uint256) public claimableAmounts;

    constructor () public {
        owner = msg.sender;
        inj = IERC20(0xe28b3B32B6c345A34Ff64674606124Dd5Aceca30);
    }

    function safeAddAmountsToAirdrop(
        address[] memory to,
        uint256[] memory amounts
    )
    public
    {
        require(msg.sender == owner, "Only Owner");
        require(to.length == amounts.length);
        uint256 totalAmount;
        for(uint256 i = 0; i < to.length; i++) {
            claimableAmounts[to[i]] = amounts[i];
            totalAmount += amounts[i];
        }
        require(inj.allowance(msg.sender, address(this)) >= totalAmount, "not enough allowance");
        inj.transferFrom(msg.sender, address(this), totalAmount);
    }

    function returnINJ() external {
        require(msg.sender == owner, "Only Owner");
        require(inj.transfer(msg.sender, inj.balanceOf(address(this))), "Transfer failed");
    }
    
    function returnAnyToken(IERC20 token) external {
        require(msg.sender == owner, "Only Owner");
        require(token.transfer(msg.sender, token.balanceOf(address(this))), "Transfer failed");
    }

    function claim() external {
        require(claimableAmounts[msg.sender] > 0, "Cannot claim 0 tokens");
        uint256 amount = claimableAmounts[msg.sender];
        claimableAmounts[msg.sender] = 0;
        require(inj.transfer(msg.sender, amount), "Transfer failed");
    }

    function claimFor(address _for) external {
        require(claimableAmounts[_for] > 0, "Cannot claim 0 tokens");
        uint256 amount = claimableAmounts[_for];
        claimableAmounts[_for] = 0;
        require(inj.transfer(_for, amount), "Transfer failed");
    }
    
    function transferOwnerShip(address newOwner) external {
        require(msg.sender == owner, "Only Owner");
        owner = newOwner;
    }
}