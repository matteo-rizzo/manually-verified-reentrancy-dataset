/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.8;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract ENSLoanOpenerStorage is Ownable {
    address public bZxContract;
    address public bZxVault;
    address public loanTokenLender;
    address public loanTokenAddress;
    address public wethContract;

    address public ensLoanOwner;

    uint256 public initialLoanDuration = 7884000; // approximately 3 months
}







contract ENSLoanOpenerLogic is ENSLoanOpenerStorage {
    using SafeMath for uint256;

    function()
        external
        payable
    {
        iENSLoanOwner(ensLoanOwner).setupUser(msg.sender);

        if (msg.value != 0) {
            uint256 borrowAmount = ILoanToken(loanTokenLender).getBorrowAmountForDeposit(
                msg.value,              // depositAmount,
                4 ether,                // leverageAmount,
                initialLoanDuration,
                address(0)              // collateralTokenAddress,
            ).mul(125).div(150);        // 150% collateralization

            bytes32 loanOrderHash = ILoanToken(loanTokenLender).borrowTokenFromDeposit.value(msg.value)(
                borrowAmount,
                4 ether,                // leverageAmount
                initialLoanDuration,
                0,                      // collateralTokenSent,
                msg.sender,             // borrower,
                address(0),             // collateralTokenAddress
                ""                      // loanData
            );

            assembly {
                mstore(0, loanOrderHash)
                return(0, 32)
            }
        }
    }

    function initialize(
        address _bZxContract,
        address _bZxVault,
        address _loanTokenLender,
        address _ensLoanOwner)
        public
        onlyOwner
    {
        bZxContract = _bZxContract;
        bZxVault = _bZxVault;
        loanTokenLender = _loanTokenLender;
        ensLoanOwner = _ensLoanOwner;
    }

    function setInitialLoanDuration(
        uint256 _value)
        public
        onlyOwner
    {
        initialLoanDuration = _value;
    }

    function recoverEther(
        address receiver,
        uint256 amount)
        public
        onlyOwner
    {
        uint256 balance = address(this).balance;
        if (balance < amount)
            amount = balance;

        (bool success, ) = receiver.call.value(amount)("");
        require(success, "transfer failed");
    }

    function recoverToken(
        address tokenAddress,
        address receiver,
        uint256 amount)
        public
        onlyOwner
    {
        iBasicToken token = iBasicToken(tokenAddress);

        uint256 balance = token.balanceOf(address(this));
        if (balance < amount)
            amount = balance;

        require(token.transfer(
            receiver,
            amount),
            "transfer failed"
        );
    }
}