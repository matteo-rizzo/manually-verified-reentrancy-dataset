/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;



/**
 * @title IFlashLoanReceiver interface
 * @notice Interface for the Aave fee IFlashLoanReceiver.
 * @author Aave
 * @dev implement this interface to develop a flashloan-compatible flashLoanReceiver contract
 **/












struct Rebase {
    uint128 elastic;
    uint128 base;
}





contract KashiFlash is IFlashLoanReceiver {

    address owner;

    ILendingPool public LENDING_POOL = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    ILendingPoolAddressesProvider public ADDRESSES_PROVIDER = ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);
    BentoBox private immutable bentobox = BentoBox(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);

    struct Swap {
        address user;
        address desiredAsset;
        uint256 amountInExact;
        uint256 amountOutMin;
    }
    Swap private _swap;

    struct Liquidation {
        address target;
        address kashiAddr;
        address collateral;
        address asset;
        uint ratio;
        address router;
    }
    Liquidation private liq;

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address newOwner) public {
        require(msg.sender == owner);
        owner = newOwner;
    }

    /**
       Use an Aave flashloan to liquidate a Kashi position.
       Take a flashloan in the Kashi borrowed asset.
       Kashi liquidate(), which sends borrowed asset to BentoBox and receives collateral asset.
       Swap collateral asset for borrowed asset.
       Repay borrowed asset to Aave flashloan, keep the extra from the swap.
    **/
    function liquidateWithFlashloan(
        address target,
        address kashiAddr,
        address router
    ) public {
        // require(false, "beginning of liquidateWithFlashloan");
        // uint collateralAmount = Kashi(kashiAddr).userCollateralShare(target);
        uint borrowAmount = Kashi(kashiAddr).userBorrowPart(target);
        Rebase memory totalBorrow = Kashi(kashiAddr).totalBorrow();
        uint ratio = (totalBorrow.elastic + 1) / totalBorrow.base;
        // Get USDC flashloan
        liq = Liquidation({
            target: target,
            kashiAddr: kashiAddr, // has collateral and borrowed asset addresses
            collateral: Kashi(kashiAddr).collateral(),
            asset: Kashi(kashiAddr).asset(),
            ratio: ratio,
            router: router
        });
        // require(false, "after setting liquidation");

        // Take out flashloan
        address[] memory assets = new address[](1);
        assets[0] = Kashi(kashiAddr).asset();
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = borrowAmount * liq.ratio;
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        // require(false, "before flashloan");
        LENDING_POOL.flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(0x0), // onBehalfOf, not used here
            bytes("0x0"), // params, not used here
            0 // referralCode
        );

    }

    /**
       Receive a flashloan in the Kashi borrowed asset.
       Approve and deposit that borrowed asset into BentoBox.
       Kashi liquidate(), which moves the borrowed asset to a diff user in BentoBox and receives collateral asset.
       Withdraw the collateral asset from BentoBox.
       Swap collateral asset for borrowed asset.
       Repay borrowed asset to Aave flashloan, keep the extra from the swap.
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) public override returns (bool) {

        // {
        // Simulate flashloan
        // address target = 0x22A6D12B6D500d173a1c74f61ADE047D05d8faC6;
        // address kashiAddr = 0xB7b45754167d65347C93F3B28797887b4b6cd2F3;

        // liq = Liquidation({
        //     target: 0x22A6D12B6D500d173a1c74f61ADE047D05d8faC6,
        //     kashiAddr: 0xB7b45754167d65347C93F3B28797887b4b6cd2F3, // has collateral and borrowed asset addresses
        //     collateral: Kashi(0xB7b45754167d65347C93F3B28797887b4b6cd2F3).collateral(),
        //     asset: Kashi(0xB7b45754167d65347C93F3B28797887b4b6cd2F3).asset()
        // });

        require(IERC20(assets[0]).balanceOf(address(this)) >= amounts[0], "Insufficient borrow amount");
        IERC20(assets[0]).approve(address(bentobox), amounts[0]);
        bentobox.deposit(
            IERC20(assets[0]),
            address(this),
            address(this),
            amounts[0],
            0
        );


        // uint collateralAmount = Kashi(liq.kashiAddr).userCollateralShare(liq.target);
        // require(collateralAmount > 0, "User collateral should not be 0");
        // uint collateralAmount = bentobox.balanceOf(liq.target, collateral);

        uint collateralRetrieved;
        {
            address[] memory users = new address[](1);
            users[0] = liq.target;

            uint[] memory amountsMinusFees = new uint[](1);
            amountsMinusFees[0] = amounts[0] * 95 / 100; // TODO: Add in our contract call

            // We make it here
            liquidate(
                liq.kashiAddr,
                users,
                amountsMinusFees, // maxBorrowParts; matches the flashloan since that's what we're providing
                address(this)
            );

            // require(false, "Before withdraw");
            collateralRetrieved = bentobox.balanceOf(liq.collateral, address(this));
            bentobox.withdraw(
                IERC20(liq.collateral),
                address(this),
                address(this),
                // collateralAmount,
                collateralRetrieved,
                0
            );
        }


        // Swap collateral
        {
            uint loanPlusPremium = amounts[0] + premiums[0];

            address[] memory data = new address[](2);
            data[0] = liq.collateral;
            data[1] = assets[0];
            uint deadline = type(uint).max;

            uint bal = IERC20(liq.collateral).balanceOf(address(this));
            require(bal >= collateralRetrieved, "Insufficient input amount to swap");
            IERC20(liq.collateral).approve(address(liq.router), collateralRetrieved);
            IUniswapV2Router02(liq.router).swapExactTokensForTokens(
                collateralRetrieved,
                loanPlusPremium,
                data,
                address(this),
                deadline
            );

            // Approve the LendingPool contract allowance to *pull* the owed amount
            IERC20(assets[0]).approve(address(LENDING_POOL), loanPlusPremium);
            uint borrowBalance = IERC20(assets[0]).balanceOf(address(this));
            require(
                borrowBalance >= loanPlusPremium,
                "Not enough tokens to repay flashloan"
            );
            // uint surplus = borrowBalance - loanPlusPremium;
            IERC20(assets[0]).transfer(owner, borrowBalance - loanPlusPremium);
            // For manual testing before adding the flashloan back
            // IERC20(assets[0]).transfer(address(LENDING_POOL), loanPlusPremium);
        }

        // Remove the swap information from storage
        delete liq;

        return true;
    }

    // Precondition: the borrowed asset is in BentoBox owned by this contract
    function liquidate(
        address kashiAddr,
        address[] memory users,
        uint256[] memory maxBorrowParts,
        address to
    ) public {
        address collateral = Kashi(kashiAddr).collateral();
        address borrow = Kashi(kashiAddr).asset();
        // uint collateralBalanceBefore = Kashi(kashiAddr).userCollateralShare(address(this));
        uint collateralBalanceBefore = bentobox.balanceOf(collateral, address(this));
        uint borrowBalanceBefore = bentobox.balanceOf(borrow, address(this));


        bentobox.setMasterContractApproval(
            address(this),
            Kashi(kashiAddr).masterContract(),
            true,
            0,
            0x0,
            0x0
        );

        Rebase memory totalBorrow = Kashi(kashiAddr).totalBorrow();
        require(borrowBalanceBefore >= maxBorrowParts[0], "Don't have enough to repay the borrow");
        // IERC20(borrow).approve(bentoboxAddr, maxBorrowParts[0]); // doesn't do anything, the asset is already in bento
        Kashi(kashiAddr).liquidate(
            users,
            maxBorrowParts,
            address(this),
            ISwapper(address(0x0)),
            true
        );

        uint collateralBalanceAfter = bentobox.balanceOf(collateral, address(this));
        uint borrowBalanceAfter = bentobox.balanceOf(borrow, address(this));
        require(collateralBalanceAfter > collateralBalanceBefore, "BentoBox balance did not increase after liquidation");
    }

}