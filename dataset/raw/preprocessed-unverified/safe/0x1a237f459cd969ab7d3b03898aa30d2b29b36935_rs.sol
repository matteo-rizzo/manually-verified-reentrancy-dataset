/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

// Dependency file: contracts/Ownable.sol

// pragma solidity ^0.6.12;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


// Root file: contracts/staking/ImplementationGetter.sol

pragma solidity ^0.6.12;

// import 'contracts/Ownable.sol';

contract ImplementationGetter is Ownable {
    address public implementation;

    event UpgrageImplementation(address impl);
    
    constructor(address _implementation) public {
        implementation = _implementation;
        emit UpgrageImplementation(_implementation);
    }

    function getImplementationAddress() external view returns (address) {
        return implementation;
    }

    function upgradeImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
        emit UpgrageImplementation(implementation);
    }
}