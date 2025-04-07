/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: MIT 
pragma solidity 0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BatchTransaction is Ownable {
    event BatchTransfer(
        address indexed sender, 
        address indexed _tokenAddress, 
        address[] _accounts, 
        uint256[] _values, 
        uint256 _totalAmount
    );
    
    function batchTransfer(address _tokenAddress, address[] memory _accounts, uint256[] memory _values, uint256 _totalAmount) public returns(bool) {
        require(_tokenAddress != address(0), "BatchTransaction: Token address can not be address(0)");
        IERC20(_tokenAddress).transferFrom(_msgSender(), address(this), _totalAmount);
        
        for(uint256 i = 0; i < _accounts.length; ++i) {
            if(_accounts[i] == address(0)) continue;
            IERC20(_tokenAddress).transfer(_accounts[i], _values[i]);
        }
        emit BatchTransfer(_msgSender(), _tokenAddress, _accounts, _values, _totalAmount);
        return true;
    }
    
    function withdraw(address _tokenAddress) external onlyOwner {
        uint256 _balance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(_msgSender(), _balance);
    }
}