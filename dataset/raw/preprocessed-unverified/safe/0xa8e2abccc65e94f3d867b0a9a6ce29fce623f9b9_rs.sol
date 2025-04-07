/**
 *Submitted for verification at Etherscan.io on 2021-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;







contract ibAgreement {
    using SafeERC20 for IERC20;
    
    address public immutable executor;
    address public immutable borrower;
    cyToken public immutable cy;
    IERC20 public immutable underlying;
    
    constructor(address _executor, address _borrower, address _cy) {
        executor = _executor;
        borrower = _borrower;
        cy = cyToken(_cy);
        underlying = IERC20(cyToken(_cy).underlying());
    }
    
    function debt() external view returns (uint borrowBalance) {
        (,,borrowBalance,) = cy.getAccountSnapshot(address(this));
    }
    
    function seize(IERC20 token, uint amount) external {
        require(msg.sender == executor);
        token.safeTransfer(executor, amount);
    }
    
    function borrow(uint _amount) external {
        require(msg.sender == borrower);
        require(cy.borrow(_amount) == 0, 'borrow failed');
        underlying.safeTransfer(borrower, _amount);
    }
    
    function repay() external {
        uint _balance = underlying.balanceOf(address(this));
        underlying.safeApprove(address(cy), _balance);
        cy.repayBorrow(_balance);
    }
}