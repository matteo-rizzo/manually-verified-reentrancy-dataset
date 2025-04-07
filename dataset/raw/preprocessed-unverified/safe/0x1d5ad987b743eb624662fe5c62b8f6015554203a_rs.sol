/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

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









contract yTokenProxy is ReentrancyGuard, Ownable {
  using Address for address;
  using SafeMath for uint256;

  yToken public _yToken;

  constructor () public {
     _yToken = yToken(0x26EA744E5B887E5205727f55dFBE8685e3b21951);
  }

  function withdrawAave() public onlyOwner {
    _yToken.withdrawAave(_yToken.balanceAave());
  }

  function withdrawCompound(uint256 _amount) public onlyOwner {
    _yToken.withdrawSomeCompound(_yToken.balanceCompoundInToken().sub(_amount));
  }

  function withdrawDydx() public onlyOwner {
    _yToken.withdrawDydx(_yToken.balanceDydx());
  }

  function set_new_yToken(yToken _new_yToken) public onlyOwner {
      _yToken = _new_yToken;
  }

  function transferYTokenOwnership(address _newOwner) public onlyOwner {
    _yToken.transferOwnership(_newOwner);
  }

}