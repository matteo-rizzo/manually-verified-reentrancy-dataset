/**
 *Submitted for verification at Etherscan.io on 2021-09-22
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;



/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract MinimalProxyFactoryEx {
    using SafeERC20 for IERC20;
    
    event ProxyDeployed(address caller, address proxy, address logic, uint256 deployId);
    
    function deploy(
        address _logic,
        IERC20 _token,
        uint256 _amount,
        bytes calldata _data,
        uint256 _deployId) external {
        
        address proxy = _deployMinimalProxy(_logic);
        
        emit ProxyDeployed(msg.sender, proxy, _logic, _deployId);
        
        if (_amount > 0) {
            _token.safeTransferFrom(msg.sender, proxy, _amount);
        }
        
        if (_data.length > 0) {
            (bool success,) = proxy.call(_data);
            require(success);
        }
    }
    
    function _deployMinimalProxy(address _logic) private returns (address proxy) {
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(_logic);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }
}