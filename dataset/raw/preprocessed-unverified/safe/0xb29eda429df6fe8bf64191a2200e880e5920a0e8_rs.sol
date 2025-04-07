pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */










contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
}

contract Helpers is DSMath {

    using SafeERC20 for IERC20;

    /**
     * @dev Return ethereum address
     */
    function getAddressETH() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return Memory Variable Address
     */
    function getMemoryAddr() internal pure returns (address) {
        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
    }

    /**
     * @dev Get Uint value from InstaMemory Contract.
    */
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
    }

    /**
     * @dev Set Uint value in InstaMemory Contract.
    */
    function setUint(uint setId, uint val) internal {
        if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
    }

    /**
     * @dev Connector Details.
    */
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 48);
    }

    function _transfer(address payable to, IERC20 token, uint _amt) internal {
        address(token) == getAddressETH() ?
            to.transfer(_amt) :
            token.safeTransfer(to, _amt);
    }

    function _getBalance(IERC20 token) internal view returns (uint256) {
        return address(token) == getAddressETH() ?
            address(this).balance :
            token.balanceOf(address(this));
    }
}


contract DydxFlashHelpers is Helpers {
    /**
     * @dev Return Dydx flashloan address
     */
    function getDydxFlashAddr() internal pure returns (address) {
        return 0x1753758423D19d5ba583e99294B51C86B3F7E512;
    }

    function calculateTotalFeeAmt(DydxFlashInterface dydxContract, uint amt) internal view returns (uint totalAmt) {
        uint fee = dydxContract.fee();
        if (fee == 0) {
            totalAmt = amt;
        } else {
            uint feeAmt = wmul(amt, fee);
            totalAmt = add(amt, feeAmt);
        }
    }

    function calculateFlashFeeAmt(DydxFlashInterface dydxContract, uint flashAmt, uint amt) internal view returns (uint totalAmt) {
        uint fee = dydxContract.fee();
        if (fee == 0) {
            totalAmt = amt;
        } else {
            uint feeAmt = wmul(flashAmt, fee);
            totalAmt = add(amt, feeAmt);
        }
    }
}

contract LiquidityAccessHelper is DydxFlashHelpers {
    /**
     * @dev Add Fee Amount to borrowed flashloan/
     * @param amt Get token amount at this ID from `InstaMemory` Contract.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function addFeeAmount(uint flashAmt, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);
        require(_amt != 0, "amt-is-0");
        DydxFlashInterface dydxContract = DydxFlashInterface(getDydxFlashAddr());

        uint totalFee = calculateFlashFeeAmt(dydxContract, flashAmt, amt);

        setUint(setId, totalFee);
    }

}

contract LiquidityAccess is LiquidityAccessHelper {

    event LogDydxFlashBorrow(address[] token, uint256[] tokenAmt);
    event LogDydxFlashPayback(address[] token, uint256[] tokenAmt, uint256[] totalAmtFee);

    /**
     * @dev Borrow Flashloan and Cast spells.
     * @param token Token Address.
     * @param amt Token Amount.
     * @param data targets & data for cast.
     */
    function flashBorrowAndCast(address token, uint amt, uint route, bytes memory data) public payable {
        AccountInterface(address(this)).enable(getDydxFlashAddr());

        address[] memory tokens = new address[](1);
        uint[] memory amts = new uint[](1);
        tokens[0] = token;
        amts[0] = amt;

        emit LogDydxFlashBorrow(tokens, amts);

        DydxFlashInterface(getDydxFlashAddr()).initiateFlashLoan(tokens, amts, route, data);

        AccountInterface(address(this)).disable(getDydxFlashAddr());

    }

    /**
     * @dev Return token to dydx flashloan.
     * @param token token address.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amt token amt.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function flashPayback(address token, uint amt, uint getId, uint setId) external payable {
        uint _amt = getUint(getId, amt);
        
        DydxFlashInterface dydxContract = DydxFlashInterface(getDydxFlashAddr());
        IERC20 tokenContract = IERC20(token);

        (uint totalFeeAmt) = calculateTotalFeeAmt(dydxContract, _amt);

        _transfer(payable(address(getDydxFlashAddr())), tokenContract, totalFeeAmt);

        setUint(setId, totalFeeAmt);

        address[] memory tokens = new address[](1);
        uint[] memory amts = new uint[](1);
        uint[] memory totalFeeAmts = new uint[](1);
        tokens[0] = token;
        amts[0] = amt;
        totalFeeAmts[0] = totalFeeAmt;

        emit LogDydxFlashPayback(tokens, amts, totalFeeAmts);
    }
}

contract LiquidityAccessMulti is LiquidityAccess {
    /**
     * @dev Borrow Flashloan and Cast spells.
     * @param tokens Array of token Addresses.
     * @param amts Array of token Amounts.
     * @param route Route to borrow.
     * @param data targets & data for cast.
     */
    function flashMultiBorrowAndCast(address[] calldata tokens, uint[] calldata amts, uint route, bytes calldata data) external payable {
        AccountInterface(address(this)).enable(getDydxFlashAddr());

        emit LogDydxFlashBorrow(tokens, amts);

        DydxFlashInterface(getDydxFlashAddr()).initiateFlashLoan(tokens, amts, route, data);

        AccountInterface(address(this)).disable(getDydxFlashAddr());

    }

    /**
     * @dev Return Multiple token liquidity from InstaPool.
     * @param tokens Array of token addresses.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param amts Array of token amounts.
     * @param getId get token amounts at this IDs from `InstaMemory` Contract.
     * @param setId set token amounts at this IDs in `InstaMemory` Contract.
    */
    function flashMultiPayback(address[] calldata tokens, uint[] calldata amts, uint[] calldata getId, uint[] calldata setId) external payable {
        uint _length = tokens.length;
        DydxFlashInterface dydxContract = DydxFlashInterface(getDydxFlashAddr());

        uint[] memory totalAmtFees = new uint[](_length);
        for (uint i = 0; i < _length; i++) {
            uint _amt = getUint(getId[i], amts[i]);
            IERC20 tokenContract = IERC20(tokens[i]);

            
            (totalAmtFees[i]) = calculateTotalFeeAmt(dydxContract, _amt);

            _transfer(payable(address(getDydxFlashAddr())), tokenContract, totalAmtFees[i]);

            setUint(setId[i], totalAmtFees[i]);
        }

        emit LogDydxFlashPayback(tokens, amts, totalAmtFees);
    }

}

contract ConnectInstaPool is LiquidityAccessMulti {
    string public name = "Instapool-v2";
}