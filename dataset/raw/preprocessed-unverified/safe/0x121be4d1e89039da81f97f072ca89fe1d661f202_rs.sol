/**
 *Submitted for verification at Etherscan.io on 2021-10-01
*/

// SPDX-License-Identifier: No License (None)
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/ownership/Ownable.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Ownable implementation from an openzeppelin version.
 */
abstract 



contract GatewayVault is Ownable {

    mapping(address => bool) public gateways; // different gateways will be used for different pairs (chains)
    event ChangeGateway(address gateway, bool active);


    /**
     * @dev Throws if called by any account other than the Gateway.
     */
    modifier onlyGateway() {
        require(gateways[msg.sender], "Not Gateway");
        _;
    }

    function changeGateway(address gateway, bool active) external onlyOwner returns(bool) {
        gateways[gateway] = active;
        emit ChangeGateway(gateway, active);
        return true;
    }

    function vaultTransfer(address token, address recipient, uint256 amount) external onlyGateway returns (bool) {
        return IERC20(token).transfer(recipient, amount);
    }

    function vaultApprove(address token, address spender, uint256 amount) external onlyGateway returns (bool) {
        return IERC20(token).approve(spender, amount);
    }
}