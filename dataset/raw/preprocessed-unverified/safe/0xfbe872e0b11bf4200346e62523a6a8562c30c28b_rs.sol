/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}











contract ERC20BatchTransfer is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function transfer(IERC20 _token, address[] memory _tos, uint[] memory _values, uint _total) public returns(bool) {
        require(_tos.length == _values.length);
        uint sum = 0;
        for (uint i = 0; i < _tos.length; i++) {
            address to = _tos[i];
            uint value = _values[i];
            sum = sum + value;
            _token.transferFrom(msg.sender, to, value);
        }
        require(sum == _total);
        return true;
    }

    function ownerTransfer(IERC20 _token, address[] memory _tos, uint[] memory _values, uint _total) public onlyOwner returns(bool)  {
        require(_tos.length == _values.length);
        uint sum = 0;
        for (uint i = 0; i < _tos.length; i++) {
            address to = _tos[i];
            uint value = _values[i];
            sum = sum + value;
            _token.transfer(to, value);
        }
        require(sum == _total);
        return true;
    }
}