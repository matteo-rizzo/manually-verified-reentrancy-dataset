/**

 *Submitted for verification at Etherscan.io on 2019-04-04

*/



/**

 * Copyright (c) 2019 blockimmo AG [emailÂ protected]

 * No license

 */



pragma solidity 0.5.4;



















contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

        // The counter starts at one to prevent changing it from zero to a non-zero

        // value, which is a more expensive operation.

        _guardCounter = 1;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter);

    }

}



contract KyberNetworkProxyInterface {

  function getExpectedRate(IERC20 src, IERC20 dest, uint256 srcQty) public view returns (uint256 expectedRate, uint256 slippageRate);

  function trade(IERC20 src, uint256 srcAmount, IERC20 dest, address destAddress, uint256 maxDestAmount, uint256 minConversionRate, address walletId) public payable returns(uint256);

}



contract LandRegistryProxyInterface {

  function owner() public view returns (address);

}



contract PaymentsLayer is ReentrancyGuard {

  using SafeERC20 for IERC20;

  using SafeMath for uint256;



  address public constant ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  KyberNetworkProxyInterface public constant KYBER_NETWORK_PROXY = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);

  LandRegistryProxyInterface public constant LAND_REGISTRY_PROXY = LandRegistryProxyInterface(0xe72AD2A335AE18e6C7cdb6dAEB64b0330883CD56);  // 0x0f5Ea0A652E851678Ebf77B69484bFcD31F9459B;



  event PaymentForwarded(IERC20 indexed src, uint256 srcAmount, IERC20 indexed dest, address indexed destAddress, uint256 destAmount);



  function forwardPayment(IERC20 src, uint256 srcAmount, IERC20 dest, address destAddress, uint256 minConversionRate, uint256 minDestAmount, bytes memory encodedFunctionCall) public nonReentrant payable returns(uint256) {

    if (address(src) != ETH_TOKEN_ADDRESS) {

      require(msg.value == 0);

      src.safeTransferFrom(msg.sender, address(this), srcAmount);

      src.safeApprove(address(KYBER_NETWORK_PROXY), srcAmount);

    }



    uint256 destAmount = KYBER_NETWORK_PROXY.trade.value((address(src) == ETH_TOKEN_ADDRESS) ? srcAmount : 0)(src, srcAmount, dest, address(this), ~uint256(0), minConversionRate, LAND_REGISTRY_PROXY.owner());

    require(destAmount >= minDestAmount);

    if (address(dest) != ETH_TOKEN_ADDRESS)

      dest.safeApprove(destAddress, destAmount);



    (bool success, ) = destAddress.call.value((address(dest) == ETH_TOKEN_ADDRESS) ? destAmount : 0)(encodedFunctionCall);

    require(success, "dest call failed");



    uint256 change = (address(dest) == ETH_TOKEN_ADDRESS) ? address(this).balance : dest.allowance(address(this), destAddress);

    (change > 0 && address(dest) == ETH_TOKEN_ADDRESS) ? msg.sender.transfer(change) : dest.safeTransfer(msg.sender, change);



    emit PaymentForwarded(src, srcAmount, dest, destAddress, destAmount.sub(change));

    return destAmount.sub(change);

  }

}