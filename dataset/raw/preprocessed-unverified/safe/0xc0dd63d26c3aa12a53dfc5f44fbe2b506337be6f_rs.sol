/**
 *Submitted for verification at Etherscan.io on 2020-02-24
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}









// Solidity Interface



contract yCurveBalances is ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public DAI;
  address public yDAI;
  address public USDC;
  address public yUSDC;
  address public USDT;
  address public yUSDT;
  address public TUSD;
  address public yTUSD;

  address public AAVE;
  address public DYDX;
  address public cDAI;
  address public cUSDC;

  constructor () public {
    DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    yDAI = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);

    USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    yUSDC = address(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);

    USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    yUSDT = address(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);

    TUSD = address(0x0000000000085d4780B73119b644AE5ecd22b376);
    yTUSD = address(0x73a052500105205d34Daf004eAb301916DA8190f);

    AAVE = address(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3);
    DYDX = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    cDAI = address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    cUSDC = address(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
  }

  function() external payable {

  }

  function balanceOfDAI() external view returns (uint256) {
    uint8 provider = yERC20(yDAI).provider();
    if (provider == 2) {
      IERC20(DAI).balanceOf(cDAI);
    }
    if (provider == 3) {
      IERC20(DAI).balanceOf(AAVE);
    }
    if (provider == 1) {
      IERC20(DAI).balanceOf(DYDX);
    }
  }

  function balanceOfUSDT() external view returns (uint256) {
    uint8 provider = yERC20(yUSDT).provider();
    if (provider == 3) {
      IERC20(USDT).balanceOf(AAVE);
    }
    if (provider == 1) {
      IERC20(USDT).balanceOf(DYDX);
    }
  }

  function balanceOfUSDC() external view returns (uint256) {
    uint8 provider = yERC20(yUSDC).provider();
    if (provider == 2) {
      IERC20(USDC).balanceOf(cUSDC);
    }
    if (provider == 3) {
      IERC20(USDC).balanceOf(AAVE);
    }
    if (provider == 1) {
      IERC20(USDC).balanceOf(DYDX);
    }
  }

  function balanceOfTUSD() external view returns (uint256) {
    uint8 provider = yERC20(yTUSD).provider();
    if (provider == 3) {
      IERC20(TUSD).balanceOf(AAVE);
    }
    if (provider == 1) {
      IERC20(TUSD).balanceOf(DYDX);
    }
  }



  // incase of half-way error
  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
      uint qty = _TokenAddress.balanceOf(address(this));
      _TokenAddress.safeTransfer(msg.sender, qty);
  }

  // incase of half-way error
  function inCaseETHGetsStuck() onlyOwner public{
      (bool result, ) = msg.sender.call.value(address(this).balance)("");
      require(result, "transfer of ETH failed");
  }
}