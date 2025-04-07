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


// File: contracts/oracle/ICADConversionOracle.sol


/**
 * @title ICADRateOracle
 * @notice provides interface for converting USD stable coins to CAD
*/


// File: contracts/acquisition/IAsyncRedemption.sol


/**
 * @title IAsyncRedemption
 * @notice provides interface for token redemptions
*/


// File: contracts/acquisition/ManagedAsyncDaiRedemptionPool.sol



/**
 * @title ManagedAsyncDaiRedemptionPool
 * @notice Token to Dai pool to facilitate immediate and asynchronous redemptions
*/
contract ManagedAsyncDaiRedemptionPool is IAsyncRedemption {
    using SafeMath for uint256;

    event Redeemed(address indexed holder, uint256 tokenAmount, uint256 daiAmount);
    event RedemptionPending(address indexed holder, uint256 tokenAmount);

    event Capitalized(uint256 usdAmount);

    // source where the Dai comes from
    address public _poolSource;

    // address of the wToken
    IERC20 public _wToken;

    // address of the USD to CAD oracle
    ICADConversionOracle public _cadOracle;

    // wTokens, if fix-priced in CAD, will not require more than 2 decimals
    uint256 public _fixedPriceCADCent;

    // Dai contract
    IERC20 public _daiContract;


    /**
    * @dev records each asynchronous redemption request
    **/
    struct AsyncRedemptionRequest {
        // account that submitted the request
        address account;

        // amount of tokens to redeem
        uint256 tokenAmount;
    }

    // array of redemption requests to keep track of
    AsyncRedemptionRequest[] internal _asyncRequests;

    // index of the first un-fulfilled async redemption request
    uint256 public _asyncIndex = 0;


    constructor(
        address poolSource,
        address tokenAddress,
        address cadOracleAddress,
        uint256 fixedPriceCADCent,

        address daiContractddress
    ) public {
        _poolSource = poolSource;

        _wToken = IERC20(tokenAddress);
        _cadOracle = ICADConversionOracle(cadOracleAddress);
        _fixedPriceCADCent = fixedPriceCADCent;

        _daiContract = IERC20(daiContractddress);
    }

     /**
    * @notice redeem tokens instantly
    * @param tokenAmount     amount of token to redeem
    * @return true if success
    */
    function instantRedemption(uint256 tokenAmount) external virtual override returns (bool) {
        require(tokenAmount > 0, "Token amount must be greater than 0");

        uint256 requestDaiAmount = _cadOracle
            .cadToDai(tokenAmount.mul(_fixedPriceCADCent))
            .div(100);

        require(requestDaiAmount <= fundsAvailable(), "Insufficient Dai for instant redemption");


        _wToken.transferFrom(msg.sender, _poolSource, tokenAmount);
        _daiContract.transfer(msg.sender, requestDaiAmount);

        emit Redeemed(msg.sender, tokenAmount, requestDaiAmount);
        return true;
    }

    /**
    * @notice redeem tokens asynchronously
    * @param tokenAmount     amount of token to redeem
    * @return true if success
    */
    function asyncRedemption(uint256 tokenAmount) external virtual override returns (bool) {
        require(tokenAmount >= 5e19, "Token amount must be greater than or equal to 50");

        AsyncRedemptionRequest memory newRequest = AsyncRedemptionRequest(msg.sender, tokenAmount);
        _asyncRequests.push(newRequest);

        _wToken.transferFrom(msg.sender, address(this), tokenAmount);

        emit RedemptionPending(msg.sender, tokenAmount);
        return true;
    }


    /**
    * @notice deposit Dai to faciliate redemptions
    * @param maxDaiAmount    max amount of Dai to pay for redemptions
    * @return true if success
    */
    function capitalize(uint256 maxDaiAmount) external returns (bool) {
        uint256 daiAmountRemaining = maxDaiAmount;
        uint256 newIndex = _asyncIndex;
        uint256 requestLength = _asyncRequests.length;

        for (; newIndex < requestLength; newIndex = newIndex.add(1)) {
            AsyncRedemptionRequest storage request = _asyncRequests[newIndex];

            uint256 requestDaiAmount = _cadOracle
                .cadToDai(request.tokenAmount.mul(_fixedPriceCADCent))
                .div(100);

            // if cannot completely redeem a request, then do not perform partial redemptions
            if (requestDaiAmount > daiAmountRemaining) {
                break;
            }

            daiAmountRemaining = daiAmountRemaining.sub(requestDaiAmount);

            _wToken.transfer(_poolSource, request.tokenAmount);
            _daiContract.transferFrom(msg.sender, request.account, requestDaiAmount);

            emit Redeemed(request.account, request.tokenAmount, requestDaiAmount);
        }

        // if all async requests have been redeemed, add Dai to this contract as reserve
        if (newIndex == requestLength && daiAmountRemaining > 0) {
            _daiContract.transferFrom(msg.sender, address(this), daiAmountRemaining);
            emit Capitalized(daiAmountRemaining);
        }

        // update redemption index to the latest
        _asyncIndex = newIndex;

        return true;
    }

    /**
    * @notice withdraw Dai reserves back to source
    * @return true if success
    */
    function withdrawReserve(uint256 daiAmount) external returns (bool) {
        require(msg.sender == _poolSource, "Only designated source can withdraw reserves");

        _daiContract.transfer(_poolSource, daiAmount);

        return true;
    }



    /**
    * @notice view how many tokens are currently available
    * @return amount of tokens available in the pool
    */
    function fundsAvailable() public view virtual override returns (uint256) {
        return _daiContract.balanceOf(address(this));
    }

    /**
    * @notice view the max number of tokens that can be instantly redeemed
    * @return amount of tokens instantly redeemable
    */
    function maxTokenForInstantRedemption() external view virtual override returns (uint256) {
        return _cadOracle
            .daiToCad(fundsAvailable().mul(100))
            .div(_fixedPriceCADCent);
    }

    /**
    * @notice see the total token balance awaiting redemptions for a given account
    * @dev IMPORTANT this function involves unbounded loop, should NOT be used in critical logical paths
    * @param account     account that has tokens pending
    * @return token amount in 18 decimals
    */
    function tokensPending(address account) external view virtual override returns (uint256) {
        uint256 pendingAmount = 0;
        uint256 requestLength = _asyncRequests.length;

        for (uint256 i = _asyncIndex; i < requestLength; i = i.add(1)) {
            AsyncRedemptionRequest storage request = _asyncRequests[i];

            if (request.account == account) {
                pendingAmount = pendingAmount.add(request.tokenAmount);
            }
        }

        return pendingAmount;
    }

    /**
    * @notice view a specific async redemption request
    * @param index     index of the async redemption request
    * @return account and tokenAmount in the request
    */
    function requestAtIndex(uint256 index) external view returns (address, uint256) {
        AsyncRedemptionRequest storage request = _asyncRequests[index];
        return (request.account, request.tokenAmount);
    }

    /**
    * @notice view the current async redemption request index
    * @return the index
    */
    function currentRequestIndex() external view returns (uint256) {
        return _asyncIndex;
    }

    /**
    * @notice view the number of total async redemption requests
    * @return total number of all async requests
    */
    function numberOfRequests() external view returns (uint256) {
        return _asyncRequests.length;
    }
}