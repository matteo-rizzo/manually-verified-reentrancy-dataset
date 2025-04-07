/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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


// File: openzeppelin-solidity/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type
 */


// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/oracle/ICADConversionOracle.sol


/**
 * @title ICADRateOracle
 * @notice provides interface for converting USD stable coins to CAD
*/


// File: contracts/standardTokens/IDividendAware.sol


/**
 * @dev Interface for dividend claim functions that should be present in dividend aware tokens
 */


// File: contracts/acquisition/ITokenPool.sol


/**
 * @title ITokenPool
 * @notice provides interface for token pool where ERC20 tokens can be deposited and withdraw
*/


// File: contracts/acquisition/FixedPriceCADSingleSourceTokenPool.sol




/**
 * @title FixedPriceCADSingleSourceTokenPool
 * @notice Convert USD into a wToken in CAD. wToken is transfered from a single-source pool to the sender of USD, while USD is transferred to the source.
*/
contract FixedPriceCADSingleSourceTokenPool is ITokenPool {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event TokenDeposited(uint256 amount);
    event TokenWithdrawn(uint256 amount);

    event TokenTransaction(address indexed from, address to, uint256 tokenAmount, uint8 usdType, uint256 usdAmount);

    // source where the wTokens come from
    address public _poolSource;

    // address of the wToken
    IERC20 public _wToken;

    // address of the USD to CAD oracle
    ICADConversionOracle public _cadOracle;

    // wTokens, if fix-priced in CAD, will not require more than 2 decimals
    uint256 public _fixedPriceCADCent;

    // Dai contract
    IERC20 public _daiContract;

    // USDC contract
    IERC20 public _usdcContract;

    // USDT contract
    IERC20 public _usdtContract;


    constructor(
        address poolSource,
        address tokenAddress,
        address cadOracleAddress,
        uint256 fixedPriceCADCent,

        address daiContractddress,
        address usdcContractAddress,
        address usdtContractAddress
    ) public {
        _poolSource = poolSource;
        _wToken = IERC20(tokenAddress);
        _cadOracle = ICADConversionOracle(cadOracleAddress);
        _fixedPriceCADCent = fixedPriceCADCent;

        _daiContract = IERC20(daiContractddress);
        _usdcContract = IERC20(usdcContractAddress);
        _usdtContract = IERC20(usdtContractAddress);
    }

    /**
    * @notice deposit token into the pool from the source
    * @param amount     amount of token to deposit
    * @return true if success
    */
    function depositAssetToken(uint256 amount) external virtual override returns (bool) {
        require(msg.sender == _poolSource, "Only designated source can deposit token");
        require(amount > 0, "Amount must be greater than 0");

        _wToken.transferFrom(_poolSource, address(this), amount);

        emit TokenDeposited(amount);
        return true;
    }

    /**
    * @notice withdraw token from the pool back to the source
    * @param amount     amount of token to withdraw
    * @return true if success
    */
    function withdrawAssetToken(uint256 amount) external virtual override returns (bool) {
        require(msg.sender == _poolSource, "Only designated source can withdraw token");
        require(amount > 0, "Amount must be greater than 0");

        _wToken.transfer(_poolSource, amount);

        emit TokenWithdrawn(amount);
        return true;
    }

    /**
    * @notice withdraw any Dai accumulated as dividends, and any tokens that might have been erroneously sent to this contract
    * @param token      address of token to withdraw
    * @param amount     amount of token to withdraw
    * @return true if success
    */
    function withdrawERC20(address token, uint256 amount) external returns (bool) {
        require(msg.sender == _poolSource, "Only designated source can withdraw any token");
        require(token != address(_wToken), "Cannot withdraw asset token this way");

        IERC20(token).safeTransfer(_poolSource, amount);
        return true;
    }

    /**
    * @notice while the pool holds wNest, it is accumulating dividends, pool source can claim them
    * @return true if success
    */
    function claimDividends() external returns (bool) {
        require(msg.sender == _poolSource, "Only designated source can claim dividends");

        IDividendAware(address(_wToken)).claimAllDividendsTo(msg.sender);
        return true;
    }


    /**
    * @notice deposit Dai and get back wTokens
    * @param amount      amount of Dai to deposit
    * @return true if success
    */
    function swapWithDai(uint256 amount) external returns (bool) {
        require(amount > 0, "Dai amount must be greater than 0");

        uint256 tokenAmount = daiToToken(amount);

        // through not strictly needed, useful to have a clear message for this error case
        require(_wToken.balanceOf(address(this)) >= tokenAmount, "Insufficient token supply in the pool");

        _daiContract.transferFrom(msg.sender, _poolSource, amount);
        _wToken.transfer(msg.sender, tokenAmount);

        emit TokenTransaction(msg.sender, msg.sender, tokenAmount, 1, amount);
        return true;
    }

    /**
    * @notice deposit USDC and get back wTokens
    * @param amount      amount of USDC to deposit
    * @return true if success
    */
    function swapWithUSDC(uint256 amount) external returns (bool) {
        require(amount > 0, "USDC amount must be greater than 0");

        uint256 tokenAmount = usdcToToken(amount);

        require(_wToken.balanceOf(address(this)) >= tokenAmount, "Insufficient token supply in the pool");

        _usdcContract.transferFrom(msg.sender, _poolSource, amount);
        _wToken.transfer(msg.sender, tokenAmount);

        emit TokenTransaction(msg.sender, msg.sender, tokenAmount, 2, amount);
        return true;
    }

    /**
    * @notice deposit USDT and get back wTokens
    * @param amount      amount of USDT to deposit
    * @return true if success
    */
    function swapWithUSDT(uint256 amount) external returns (bool) {
        require(amount > 0, "USDT amount must be greater than 0");

        uint256 tokenAmount = usdtToToken(amount);

        require(_wToken.balanceOf(address(this)) >= tokenAmount, "Insufficient token supply in the pool");

        // safeTransferFrom is necessary for USDT due to argument byte size check in USDT's transferFrom function
        _usdtContract.safeTransferFrom(msg.sender, _poolSource, amount);
        _wToken.transfer(msg.sender, tokenAmount);

        emit TokenTransaction(msg.sender, msg.sender, tokenAmount, 3, amount);
        return true;
    }



    /**
    * @notice given a Dai amount, calculate resulting wToken amount
    * @param amount      amount of Dai for conversion, in 18 decimals
    * @return amount of resulting wTokens
    */
    function daiToToken(uint256 amount) public view returns (uint256) {
        return _cadOracle
            .daiToCad(amount.mul(100))
            .div(_fixedPriceCADCent);
    }

    /**
    * @notice given a USDC amount, calculate resulting wToken amount
    * @param amount      amount of USDC for conversion, in 6 decimals
    * @return amount of resulting wTokens
    */
    function usdcToToken(uint256 amount) public view returns (uint256) {
        return _cadOracle
            .usdcToCad(amount.mul(100))
            .div(_fixedPriceCADCent);
    }

    /**
    * @notice given a USDT amount, calculate resulting wToken amount
    * @param amount      amount of USDT for conversion, in 6 decimals
    * @return amount of resulting wTokens
    */
    function usdtToToken(uint256 amount) public view returns (uint256) {
        return _cadOracle
            .usdtToCad(amount.mul(100))
            .div(_fixedPriceCADCent);
    }



    /**
    * @notice view how many tokens are currently available
    * @return amount of tokens available in the pool
    */
    function tokensAvailable() public view returns (uint256) {
        return _wToken.balanceOf(address(this));
    }

    /**
    * @notice view max amount of USD deposit that can be accepted
    * @return max amount of USD deposit (18 decimal places)
    */
    function availableTokenInUSD() external view returns (uint256) {
        return _cadOracle
            .cadToUsd(tokensAvailable().mul(_fixedPriceCADCent))
            .div(100);
    }
}