/**
 *Submitted for verification at Etherscan.io on 2020-04-28
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


// File: contracts/interfaces/IGovernanceRegistry.sol
/**
 * @title Governance Registry Interface
 */


// File: contracts/governance/GovernanceRegistry.sol
/**
 * @title Governance Registry
 * @dev Holds signees and vaults addresses.
 */
contract GovernanceRegistry is Ownable {

    struct Actor {
        bytes32 name;
        bool enrolled;
    }

    /**
     * @dev Holds signees
     */
    mapping (address => Actor) public signees;

    /**
     * @dev Holds vaults
     */
    mapping (address => Actor) public vaults;

    /**
     * @dev Adds the signee role to an address.
     * @param name Use web3.utils.fromAscii(string).
     */
    function addSignee(address signee, bytes32 name) external onlyOwner{
        signees[signee] = Actor(name,true);
    }

    /**
     * @dev Removes the signee role from an address.
     */
    function removeSignee(address signee) external onlyOwner {
        signees[signee] = Actor(bytes32(0),false);
    }

    /**
     * @dev Adds the vault role to an address.
     * @param name Use web3.utils.fromAscii(string).
     */
    function addVault(address vault, bytes32 name) external onlyOwner {
        vaults[vault] = Actor(name,true);
    }

    /**
     * @dev Removes the vault role from an address.
     */
    function removeVault(address vault) external onlyOwner {
        vaults[vault] = Actor(bytes32(0),false);
    }

    /**
     * @return true if @param account is a signee.
     */
    function isSignee(address account) external view returns (bool) {
        return signees[account].enrolled;
    }

    /**
     * @return true if @param account is a vault.
     */
    function isVault(address account) external view returns (bool) {
        return vaults[account].enrolled;
    }
}