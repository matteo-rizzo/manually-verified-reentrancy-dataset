/**

 *Submitted for verification at Etherscan.io on 2019-01-29

*/



/**

 * Copyright (c) 2019 STX AG [emailÂ protected]

 * No license

 */



pragma solidity 0.5.3;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





contract KyberNetworkProxyInterface {

  function swapEtherToToken(IERC20 token, uint minConversionRate) public payable returns (uint);

  function swapTokenToToken(IERC20 src, uint srcAmount, IERC20 dest, uint minConversionRate) public returns (uint);

}



contract PaymentsLayer {

  using SafeERC20 for IERC20;

  using SafeMath for uint256;



  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;  // 0x9Ad61E35f8309aF944136283157FABCc5AD371E5;

  IERC20 public dai = IERC20(DAI_ADDRESS);



  address public constant ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;



  event PaymentForwarded(address indexed from, address indexed to, address indexed srcToken, uint256 amountDai, uint256 amountSrc, uint256 changeDai, bytes encodedFunctionCall);



  function forwardEth(KyberNetworkProxyInterface _kyberNetworkProxy, IERC20 _srcToken, uint256 _minimumRate, address _destinationAddress, bytes memory _encodedFunctionCall) public payable {

    require(address(_srcToken) != address(0) && _minimumRate > 0 && _destinationAddress != address(0), "invalid parameter(s)");



    uint256 srcQuantity = address(_srcToken) == ETH_TOKEN_ADDRESS ? msg.value : _srcToken.allowance(msg.sender, address(this));



    if (address(_srcToken) != ETH_TOKEN_ADDRESS) {

      _srcToken.safeTransferFrom(msg.sender, address(this), srcQuantity);



      require(_srcToken.allowance(address(this), address(_kyberNetworkProxy)) == 0, "non-zero initial _kyberNetworkProxy allowance");

      require(_srcToken.approve(address(_kyberNetworkProxy), srcQuantity), "approving _kyberNetworkProxy failed");

    }



    uint256 amountDai = address(_srcToken) == ETH_TOKEN_ADDRESS ? _kyberNetworkProxy.swapEtherToToken.value(srcQuantity)(dai, _minimumRate) : _kyberNetworkProxy.swapTokenToToken(_srcToken, srcQuantity, dai, _minimumRate);

    require(amountDai >= srcQuantity.mul(_minimumRate).div(1e18), "_kyberNetworkProxy failed");



    require(dai.allowance(address(this), _destinationAddress) == 0, "non-zero initial destination allowance");

    require(dai.approve(_destinationAddress, amountDai), "approving destination failed");



    (bool success, ) = _destinationAddress.call(_encodedFunctionCall);

    require(success, "destination call failed");



    uint256 changeDai = dai.allowance(address(this), _destinationAddress);

    if (changeDai > 0) {

      dai.safeTransfer(msg.sender, changeDai);

      require(dai.approve(_destinationAddress, 0), "un-approving destination failed");

    }



    emit PaymentForwarded(msg.sender, _destinationAddress, address(_srcToken), amountDai.sub(changeDai), srcQuantity, changeDai, _encodedFunctionCall);

  }

}