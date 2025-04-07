/**

 *Submitted for verification at Etherscan.io on 2019-01-25

*/



/**

 * Copyright (c) 2019 blockimmo AG [emailÂ protected]

 * Non-Profit Open Software License 3.0 (NPOSL-3.0)

 * https://opensource.org/licenses/NPOSL-3.0

 */



pragma solidity ^0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





contract KyberNetworkProxyInterface {

  function swapEtherToToken(IERC20 token, uint minConversionRate) public payable returns(uint);

}



contract PaymentsLayer {

  using SafeMath for uint256;



  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;  // 0x9Ad61E35f8309aF944136283157FABCc5AD371E5;

  IERC20 public dai = IERC20(DAI_ADDRESS);



  address public constant ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  IERC20 public eth = IERC20(ETH_TOKEN_ADDRESS);



  event PaymentForwarded(address indexed from, address indexed to, uint256 amountEth, uint256 amountDai, bytes encodedFunctionCall);



  function forwardEth(KyberNetworkProxyInterface _kyberNetworkProxy, uint256 _minimumRate, address _destinationAddress, bytes memory _encodedFunctionCall) public payable {

    require(msg.value > 0 && _minimumRate > 0 && _destinationAddress != address(0), "invalid parameter(s)");



    uint256 amountDai = _kyberNetworkProxy.swapEtherToToken.value(msg.value)(dai, _minimumRate);

    require(amountDai >= msg.value.mul(_minimumRate), "_kyberNetworkProxy failed");



    require(dai.allowance(address(this), _destinationAddress) == 0, "non-zero initial destination allowance");

    require(dai.approve(_destinationAddress, amountDai), "approving destination failed");



    (bool success, ) = _destinationAddress.call(_encodedFunctionCall);

    require(success, "destination call failed");

    require(dai.allowance(address(this), _destinationAddress) == 0, "allowance not fully consumed by destination");



    emit PaymentForwarded(msg.sender, _destinationAddress, msg.value, amountDai, _encodedFunctionCall);

  }

}