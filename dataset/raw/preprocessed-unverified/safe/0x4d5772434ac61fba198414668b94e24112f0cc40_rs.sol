// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;


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














contract Gof2Eth{
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address constant public want = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH
  address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address constant public gof = address(0x488E0369f9BC5C40C002eA7c1fe4fd01A198801c);

  function harvest() public{
    IERC20(gof).safeApprove(unirouter, uint(-1));
    address[] memory path2 = new address[](2);
    path2[0] = address(gof);
    path2[1] = UniswapRouter(unirouter).WETH();
    UniswapRouter(unirouter).swapExactTokensForETH(IERC20(gof).balanceOf(address(this)), 0, path2, address(this), now.add(1800));
  }
}