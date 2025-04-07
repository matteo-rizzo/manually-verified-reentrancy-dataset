/**
 *Submitted for verification at Etherscan.io on 2021-02-27
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

contract BatchTransaction is Context {
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
}