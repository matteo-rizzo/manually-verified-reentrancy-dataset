/**
 *Submitted for verification at Etherscan.io on 2019-09-24
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




contract ENSLoanExtendStorage is Ownable {
    uint256 internal constant MAX_UINT = 2**256 - 1;

    address public bZxContract;
    address public bZxVault;
    address public loanTokenLender;
    address public loanTokenAddress;
    address public wethContract;

    address public ensLoanOwner;

    address public userContractRegistry;
}













contract ENSLoanExtendLogic is ENSLoanExtendStorage {
    using SafeMath for uint256;

    function()
        external
        payable
    {
        if (msg.sender == wethContract) {
            return;
        }
        require(msg.value == 0, "no eth allowed");

        iUserContract userContract = iUserContractRegistry(userContractRegistry).userContracts(msg.sender);
        require(address(userContract) != address(0), "contract not found");

        uint256 beforeBalance = iBasicToken(loanTokenAddress).balanceOf(address(this));

        uint256 transferAmount = userContract.transferAsset(
            loanTokenAddress,
            address(uint256(address(this))),
            0
        );
        require(transferAmount != 0, "no deposit");

        bytes32 loanOrderHash = ILoanToken(loanTokenLender).loanOrderHashes(
            4 ether // leverageAmount
        );
        require(loanOrderHash != 0, "invalid hash");

        iBasicToken token = iBasicToken(loanTokenAddress);
        uint256 tempAllowance = token.allowance(address(this), bZxVault);
        if (tempAllowance != MAX_UINT) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(token.approve(bZxVault, 0), "token approval reset failed");
            }

            require(token.approve(bZxVault, MAX_UINT), "token approval failed");
        }

        uint256 secondsExtended = IBZx(bZxContract).extendLoanByInterest(
            loanOrderHash,
            msg.sender,        // borrower
            address(this),     // payer
            transferAmount,    // depositAmount
            false              // useCollateral
        );
        require(secondsExtended != 0, "loan not extended");

        uint256 afterBalance = iBasicToken(loanTokenAddress).balanceOf(address(this));

        if (afterBalance > beforeBalance) {
            iBasicToken(loanTokenAddress).transfer(
                msg.sender,
                afterBalance - beforeBalance
            );
        } else if (afterBalance < beforeBalance) {
            revert("too much spent");
        }

        assembly {
            mstore(0, secondsExtended)
            return(0, 32)
        }
    }

    function initialize(
        address _bZxContract,
        address _bZxVault,
        address _loanTokenLender,
        address _loanTokenAddress,
        address _userContractRegistry,
        address _wethContract,
        address _ensLoanOwner)
        public
        onlyOwner
    {
        bZxContract = _bZxContract;
        bZxVault = _bZxVault;
        loanTokenLender = _loanTokenLender;
        loanTokenAddress = _loanTokenAddress;
        userContractRegistry = _userContractRegistry;
        wethContract = _wethContract;
        ensLoanOwner = _ensLoanOwner;

        iBasicToken token = iBasicToken(loanTokenAddress);
        uint256 tempAllowance = token.allowance(address(this), bZxVault);
        if (tempAllowance != MAX_UINT) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(token.approve(bZxVault, 0), "token approval reset failed");
            }

            require(token.approve(bZxVault, MAX_UINT), "token approval failed");
        }
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