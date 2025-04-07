/**
 *Submitted for verification at Etherscan.io on 2021-05-24
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-04
*/

pragma solidity 0.5.4;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


contract MultiSend is Ownable {
    
    address public contractAddress;
    
    function setContractAddress(address _contractAddress) external onlyOwner {
        contractAddress = _contractAddress;
    }
    
    function sendToMultipleAddresses(address[] calldata _addresses, uint256[] calldata _amounts) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            address destination = _addresses[i];
            uint256 amount = _amounts[i];
            IERC20(contractAddress).transferToLocked(destination,amount);
        }
    }
    
    function withdrawTokens() external onlyOwner {
        IERC20(contractAddress).transfer(msg.sender,IERC20(contractAddress).balanceOf(address(this)));
    }
}