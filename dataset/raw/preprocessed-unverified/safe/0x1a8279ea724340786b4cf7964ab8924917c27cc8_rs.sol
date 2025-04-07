/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

// =================================================================================================
//                                    OPEN ZEPPELIN CONTRACTS
// =================================================================================================

pragma solidity 0.5.8; // use same version as Compound's contract

/**
 * @dev Interface of the ERC20 standard as defined in the EIP, plus additional
 * functions for cDAI contract interactions. Does not include the optional
 * functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */




contract FloatifyAccount is Ownable {
    using SafeMath for uint256;
    // =============================================================================================
    //                                    STORAGE VARIABLES
    // =============================================================================================

    // Amount of DAI used to mint cDAI
    // If DAI was sent to the contract but not used to mint cDAI, it will not be counted here
    // Therefore, this value should be updated when the deposit function is called
    uint256 public totalDeposited;

    // Amount of deposited DAI which was redeemed and withdrawn
    // If DAI was sent to the contract and withdrawn without minting cDAI, it will not be counted here
    // Therefore, this value should be updated when the redeemAndWithdraw functions are callled
    uint256 public totalWithdrawn;

    // Fraction of interested earned to withdraw as revenue
    // e.g. interestFraction = 100 = withdraw 10% of interest earned, value of 75 = 7.5%
    uint256 public interestFraction;

    // DAI and CDAI interface variables
    ICERC20 private daiContract; // interface to call functions from DAI contract
    ICERC20 private cdaiContract; // interface to call functions from cDAI contract


    // =============================================================================================
    //                                        EVENTS
    // =============================================================================================

    /**
     * @dev Emitted when cDAI is successfully minted from DAI held by the contract
     */
    event Deposit(uint256 indexed daiAmount);

    /**
     * @dev Emitted on withdrawal of DAI to an external account
     */
    event Withdraw(address indexed destinationAddress, uint256 indexed daiAmount);

     /**
      * @dev Emitted on redemption of cDAI for DAI by specifying cDAI amount
      */
    event Redeem(uint256 indexed cdaiAmount);

    /**
     * @dev Emitted on redemption of cDAI for DAI by specifying DAI amount
     */
    event RedeemUnderlying(uint256 indexed daiAmount);

    /**
     * @dev Emitted on change of interest fraction
     */
    event ChangeInterestFraction(uint256 indexed oldFraction, uint256 indexed newFraction);

    /**
     * @dev Emitted on withdrawal of a fraction of interest earned
     */
    event WithdrawInterestFraction(address indexed destinationAddress, uint256 indexed cdaiAmount);

    // =============================================================================================
    //                                   MAIN OPERATION FUNCTIONS
    // =============================================================================================

    // CONSTRUCTOR FUNCTION AND HELPERS ============================================================
    /**
     * @dev Approve cDAI contract upon deployment, throws error if fails
     */
    constructor(uint256 _interestFraction) public {

        // Set interest fraction for this user
        interestFraction = _interestFraction;

        // Configure the ICERC20 state variables
        address _daiAddress = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359; // mainnet DAI address
        address _cdaiAddress = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC; // mainnet cDAI address
        daiContract = ICERC20(_daiAddress);
        cdaiContract = ICERC20(_cdaiAddress);

        // Approve the cDAI contract to spend our DAI balance
        bool daiApprovalResult = daiContract.approve(_cdaiAddress, 2**256-1);
        require(daiApprovalResult, "Failed to approve cDAI contract to spend DAI");
    }


    // DEPOSIT FUNCTION ============================================================================
    /**
     * @notice Deposits all DAI in this contract and mints cDAI to start earning interest
     */
    function deposit() external onlyOwner {
        uint _daiBalance = daiContract.balanceOf(address(this));
        totalDeposited = _daiBalance.add(totalDeposited);
        emit Deposit(_daiBalance);
        require(cdaiContract.mint(_daiBalance) == 0, "Call to mint function failed");
    }

    // WITHDRAWAL PROCESS FUNCTIONS ================================================================
    // There are two supported flows:
    //        1. Redeem everything:
    //                a. Specify address to withdraw to
    //                b. Get the cDAI balance of this contract
    //                c. Call redeem() with the balance from step 1b
    //                d. Withdraw DAI to the address specified in step 1a
    //        2. Redeem a specified amount of DAI
    //                a. Specify address to withdraw to and an amount of DAI to withdraw
    //                b. Call redeemUnderlying() with the amount of DAI specified in step 2a
    //                c. Withdraw DAI to the address specified in step 2a

    /**
     * @notice Withdraws all DAI from this contract to a specified address
     * @dev We keep this as `public onlyOwner` in case there is ever a need to Withdraw DAI without
     * depositing it in Compound first
     * @param _withdrawalAddress Address to send DAI to
     */
    function withdraw(address _withdrawalAddress) public onlyOwner {
        uint256 _daiBalance = daiContract.balanceOf(address(this));
        emit Withdraw(_withdrawalAddress, _daiBalance);
        require(daiContract.transfer(_withdrawalAddress, _daiBalance), "Withrawal of DAI failed");
    }

    /**
     * @notice Redeems all cDAI held by this contract for DAI and sends it to a specified address
     * @dev This corresponds to flow 1 above
     * @param _withdrawalAddress Address to send DAI to
     */
    function redeemAndWithdrawMax(address _withdrawalAddress) external onlyOwner {
        // 1a. Destination address specified as an input
        // 1b. Get the cDAI balance of this contract
        uint256 _cdaiBalance = cdaiContract.balanceOf(address(this));
        // 1c. Call redeem() with the balance from step 1b
        emit Redeem(_cdaiBalance);
        // EXTERNAL CONTRACT CALL -- state updates must happen after this call
        //   This is bad practice, but because (1) this function is onlyOwner, and (2) we
        //   trust the DAI and cDAI contracts to be secure, the risk is mitigated
        require(cdaiContract.redeem(_cdaiBalance) == 0, "Redemption of all cDAI for DAI failed");
        uint256 _daiBalance = daiContract.balanceOf(address(this));
        totalWithdrawn = _daiBalance.add(totalWithdrawn); // right after this line we withdraw the full DAI balance
        // 1d. Withdraw all DAI to the address specified in step 1a
        withdraw(_withdrawalAddress);
    }

    /**
     * @notice Redeems the specified amount of cDAI for DAI and sends it to a specified address
     * @dev This corresponds to flow 2 above
     * @param _withdrawalAddress Address to send DAI to
     * @param _daiAmount Amount of DAI to redeem
     */
    function redeemAndWithdrawPartial(address _withdrawalAddress, uint256 _daiAmount) external onlyOwner {
        // 2a. Address to withdraw to and amount of DAI to withdraw specified as inputs
        // 2b. Call redeemUnderlying() with the amount of DAI specified in step 2a
        emit RedeemUnderlying(_daiAmount);
        require(cdaiContract.redeemUnderlying(_daiAmount) == 0, "Redemption of some cDAI for DAI failed");
        // EXTERNAL CONTRACT CALL -- state updates must happen after this call
        //   This is bad practice, but because (1) this function is onlyOwner, and (2) we
        //   trust the DAI and cDAI contracts to be secure, the risk is mitigated
        uint256 _daiBalance = daiContract.balanceOf(address(this));
        totalWithdrawn = _daiBalance.add(totalWithdrawn); // right after this line we withdraw the full DAI balance
        // 2c. Withdraw all DAI to the address specified in step 2a
        withdraw(_withdrawalAddress);
    }

    // WITHDRAW REVENUE FUNCTIONS ==================================================================
    /**
     * @notice Change the fraction of interest earned that is withdrawn
     * @param _newInterestFraction New interest fraction to use, e.g. value of 100 means 10%
     */
    function changeInterestFraction(uint256 _newInterestFraction) external onlyOwner {
        emit ChangeInterestFraction(interestFraction, _newInterestFraction);
        interestFraction = _newInterestFraction;
    }


    /**
     * @notice Withdraw a portion of interest earned
     * @dev This version will have some truncation errors, but these should be pretty small for now
     * since initial balances will all be small
     * @param _floatifyAddress Floatify address to send interest to
     */
    function withdrawInterestFraction(address _floatifyAddress) external onlyOwner {
        // Get total DAI the user has, i.e. DAI principal + interest
        uint256 _daiTotal = cdaiContract.balanceOfUnderlying(address(this));

        // Get DAI principal, i.e. deposited - withdrawn
        uint256 _daiPrincipal = totalDeposited.sub(totalWithdrawn);

        // Get difference between the two, i.e., interest earned
        uint256 _daiEarned = _daiTotal.sub(_daiPrincipal);

        // Get cDAI to DAI exchange rate
        // Divide by 1e18 so _exchangeRate lets us go from cDAI > DAI with proper amount of decimals
        uint256 _exchangeRate = cdaiContract.exchangeRateCurrent().div(1e18);

        // Convert the amount of DAI earned into an amount of cDAI
        uint256 _cdaiEarned = _daiEarned.div(_exchangeRate);

        // Withdraw a portion of that cDAI
        uint256 _withdrawalAmount = _cdaiEarned.mul(interestFraction).div(1000);
        emit WithdrawInterestFraction(_floatifyAddress, _withdrawalAmount);
        require(cdaiContract.transfer(_floatifyAddress, _withdrawalAmount), "Withrawal of cDAI failed");
    }

}