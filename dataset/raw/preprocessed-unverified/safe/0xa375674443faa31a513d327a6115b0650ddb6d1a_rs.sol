/**
 *Submitted for verification at Etherscan.io on 2020-10-21
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


// File: contracts/oracle/IExchangeRateOracle.sol


/**
 * @title IExchangeRateOracle
 * @notice provides interface for fetching exchange rate values onchain, underlying implementations could use different oracles.
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

    event TokenTransaction(address indexed from, address to, uint256 tokenAmount, uint256 usdAmount);

    // source where the wTokens come from
    address public _poolSource;

    // address of the wToken
    IERC20 public _wToken;

    // address of the USD to CAD oracle
    IExchangeRateOracle public _oracle;

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
        address oracleAddress,
        uint256 fixedPriceCADCent,

        address daiContractddress,
        address usdcContractAddress,
        address usdtContractAddress
    ) public {
        _poolSource = poolSource;
        _wToken = IERC20(tokenAddress);
        _oracle = IExchangeRateOracle(oracleAddress);
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
    * @notice generic function for handling USD deposits and transfer of wTokens as a result
    * @param usdAmount      amount of USD to deposit
    * @param to             address to receive the resulting wTokens
    * @param usdType        1 for Dai, 2 for USDC, 3 for USDT
    * @return true if success
    */
    function depositTo(uint256 usdAmount, address to, uint32 usdType) internal returns (bool) {
        require(usdAmount > 0, "USD amount must be greater than 0");
        require(to != address(0), "Recipient cannot be zero address");

        uint256 usdAmountInWad = usdAmount;
        if (usdType > 1) {
            // USDC and USDT both have 6 decimals, need to change to 18
            usdAmountInWad = usdAmount.mul(1e12);
        }


        // check if there is enough wToken supply to make the conversion
        uint256 tokenAmount = usdToToken(usdAmountInWad);

        // through not strictly needed, useful to have a clear message for this error case
        require(_wToken.balanceOf(address(this)) >= tokenAmount, "Insufficient token supply in the pool");

        // transfer corresponding USD tokens to source of wTokens
        if (usdType == 1) {
            _daiContract.safeTransferFrom(msg.sender, _poolSource, usdAmount);
        } else if (usdType == 2) {
            _usdcContract.safeTransferFrom(msg.sender, _poolSource, usdAmount);
        } else if (usdType == 3) {
            _usdtContract.safeTransferFrom(msg.sender, _poolSource, usdAmount);
        } else {
            revert("Unsupported USD type");
        }

        // transfer wToken to recipient
        _wToken.transfer(to, tokenAmount);

        emit TokenTransaction(msg.sender, to, tokenAmount, usdAmountInWad);
        return true;
    }

    /**
    * @notice deposit Dai and get back wTokens
    * @param usdAmount      amount of Dai to deposit
    * @return true if success
    */
    function depositDai(uint256 usdAmount) external returns (bool) {
        return depositTo(usdAmount, msg.sender, 1);
    }

    /**
    * @notice deposit USDC and get back wTokens
    * @param usdAmount      amount of USDC to deposit
    * @return true if success
    */
    function depositUSDC(uint256 usdAmount) external returns (bool) {
        return depositTo(usdAmount, msg.sender, 2);
    }

    /**
    * @notice deposit USDT and get back wTokens
    * @param usdAmount      amount of USDT to deposit
    * @return true if success
    */
    function depositUSDT(uint256 usdAmount) external returns (bool) {
        return depositTo(usdAmount, msg.sender, 3);
    }

    /**
    * @notice given an USD amount, calculate resulting wToken amount
    * @param usdAmount      amount of USD for conversion
    * @return amount of resulting wTokens
    */
    function usdToToken(uint256 usdAmount) public view returns (uint256) {
        (bool success, uint256 USDToCADRate, uint256 granularity,) = _oracle.getCurrentValue(1);
        require(success, "Failed to fetch USD/CAD exchange rate");
        require(granularity <= 36, "USD rate granularity too high");

        // use mul before div
        return usdAmount.mul(USDToCADRate).mul(100).div(10 ** granularity).div(_fixedPriceCADCent);
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
        (bool success, uint256 USDToCADRate, uint256 granularity,) = _oracle.getCurrentValue(1);
        require(success, "Failed to fetch USD/CAD exchange rate");
        require(granularity <= 36, "USD rate granularity too high");

        uint256 tokenAmount = tokensAvailable();

        return tokenAmount.mul(_fixedPriceCADCent).mul(10 ** granularity).div(100).div(USDToCADRate);
    }
}