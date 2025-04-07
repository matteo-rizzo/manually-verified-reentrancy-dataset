/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.
/**
 * Rekeep3r.network 
 * A standard implementation of kp3rv1 protocol
 * Mint function capped both for normal mint and for addKPRCredit
 * Original functionality still in place
 */
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */




contract ProxyReKeep3r {
    using SafeMath for uint;
    /// @notice The name of this contract
    string public constant name = "ProxyReKeep3r";

    // max cap for owner
    uint256 constant maxCap = 100000000000000000000000;

    /// @notice The address of the governance token
    IReKeep3rV1 immutable public REKP3R;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
        
    bytes32 public immutable DOMAINSEPARATOR;

    function getChainId() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    address public guardian;
    address public pendingGuardian;
    
    function setGuardian(address _guardian) external {
        require(msg.sender == guardian, "ProxyReKeep3r::setGuardian: !guardian");
        pendingGuardian = _guardian;
    }
    
    function acceptGuardianship() external {
        require(msg.sender == pendingGuardian, "ProxyReKeep3r::setGuardian: !pendingGuardian");
        guardian = pendingGuardian;
    }
    
    function addVotes(address voter, uint amount) external {
        require(msg.sender == guardian, "ProxyReKeep3r::addVotes: !guardian");
        REKP3R.addVotes(voter, amount);
    }

    function removeVotes(address voter, uint amount) external {
        require(msg.sender == guardian, "ProxyReKeep3r::removeVotes: !guardian");
        REKP3R.removeVotes(voter, amount);
    }

    function addKPRCredit(address job, uint amount) external {
        require(msg.sender == guardian && REKP3R.totalSupply().add(amount) <= maxCap, "ProxyReKeep3r::addKPRCredit: !guardian or mint maxCap limit");
        REKP3R.addKPRCredit(job, amount);
    }

    function approveLiquidity(address liquidity) external {
        require(msg.sender == guardian, "ProxyReKeep3r::approveLiquidity: !guardian");
        REKP3R.approveLiquidity(liquidity);
    }

    function revokeLiquidity(address liquidity) external {
        require(msg.sender == guardian, "ProxyReKeep3r::revokeLiquidity: !guardian");
        REKP3R.revokeLiquidity(liquidity);
    }

    function addJob(address job) external {
        require(msg.sender == guardian, "ProxyReKeep3r::addJob: !guardian");
        REKP3R.addJob(job);
    }

    function removeJob(address job) external {
        require(msg.sender == guardian, "ProxyReKeep3r::removeJob: !guardian");
        REKP3R.removeJob(job);
    }

    function setKeep3rHelper(address kprh) external {
        require(msg.sender == guardian, "ProxyReKeep3r::setKeep3rHelper: !guardian");
        REKP3R.setKeep3rHelper(kprh);
    }

    function setGovernance(address _governance) external {
        require(msg.sender == guardian, "ProxyReKeep3r::setGovernance: !guardian");
        REKP3R.setGovernance(_governance);
    }

    function acceptGovernance() external {
        require(msg.sender == guardian, "ProxyReKeep3r::acceptGovernance: !guardian");
        REKP3R.acceptGovernance();
    }

    function dispute(address keeper) external {
        require(msg.sender == guardian, "ProxyReKeep3r::dispute: !guardian");
        REKP3R.dispute(keeper);
    }

    function slash(address bonded, address keeper, uint amount) external {
        require(msg.sender == guardian, "ProxyReKeep3r::slash: !guardian");
        REKP3R.slash(bonded, keeper, amount);
    }

    function revoke(address keeper) external {
        require(msg.sender == guardian, "ProxyReKeep3r::revoke: !guardian");
        REKP3R.revoke(keeper);
    }

    function resolve(address keeper) external {
        require(msg.sender == guardian, "ProxyReKeep3r::resolve: !guardian");
        REKP3R.resolve(keeper);
    }

    constructor(address token_) public {
        guardian = msg.sender;
        REKP3R = IReKeep3rV1(token_);
        DOMAINSEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
    }

    receive() external payable { }

}