/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

pragma solidity 0.5.4;
// File: contracts/interfaces/IGovernanceRegistry.sol
/**
 * @title Governance Registry Interface
 */


// File: contracts/interfaces/IToken.sol
/**
 * @title Token Interface
 * @dev Exposes token functionality
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol
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


// File: contracts/governance/Minter.sol
/**
 * @title Minter
 * @dev Minter contract for the AWG tokens.
 */
contract Minter {

    using SafeMath for uint256;

    uint256 public index;

    /**
     * @dev Fired when a vault calls `createMintRequest`.
     */
    event MintRequestCreated(
        address indexed vault, 
        uint256 indexed id, 
        address indexed receiver, 
        bytes32 barId,
        uint256 barSize,
        uint256 value
    );

    /**
     * @dev Fired when a vault calls `signMintRequest`.
     */
    event MintRequestSigned(
        address indexed signer, 
        uint256 indexed id, 
        address indexed vault, 
        address receiver, 
        bytes32 barId,
        uint256 barSize,
        uint256 value
    );

    /**
     * @dev Holds the data required for an actual token minting.
     */
    struct MintRequest{
        /**
         * @dev Autoincremented from 'index'.
         */
        uint256 id;

        /**
         * @dev Who will get the minted token.
         */
        address receiver; 

        /**
         * @dev Who initiated the mint transaction.
         */
        address vault;

        /**
         * @dev How many tokens are minted.
         */
        uint256 value;

        /**
         * @dev Gold bar identifier.
         */
        bytes32 barId;

        /**
         * @dev Size of gold bar.
         */
        uint256 barSize;

        /**
         * @dev Indicates if the transaction was signed by a signee.
         */
        bool signed;
    }

    /**
     * @dev Holds all mint requests initialised by the vaults.
     */
    mapping (uint256 => MintRequest) public requests;

    /**
     * @dev Reference to governance registry contract.
     */
    IGovernanceRegistry public registry;

    /**
     * @dev Reference to minted token contract.
     */
    IToken public token;

    /**
     * @param governanceRegistry Deployed address of the Governance Registry smart contract.
     * @param mintedToken Specifies the minted token address.     
     */
    constructor(IGovernanceRegistry governanceRegistry, IToken mintedToken) public {
        registry = governanceRegistry;
        token = mintedToken;
    }

    /**
     * @dev Initialises a mint request.
     * @dev Actual minting will hapen only after `signMintRequest` is called.
     * @param barId Use web3.utils.fromAscii(string).
     */
    function createMintRequest(address receiver, bytes32 barId, uint256 barSize, uint256 value) onlyVault external {
        index = index.add(1);
        requests[index] = MintRequest(index, receiver, msg.sender, value, barId, barSize, false);
        emit MintRequestCreated(msg.sender, index, receiver, barId, barSize, value);
    }

    /**
     * @dev Signs a mint request.
     * @dev Mints the amount of token specified in the `MintRequest` struct.
     */
    function signMintRequest(uint256 id) onlySignee external {
        MintRequest storage request = requests[id];
        require(!request.signed, "Request was signed previosuly");
        request.signed = true;
        token.mint(request.receiver, request.value);
        emit MintRequestSigned(
            msg.sender, 
            request.id, 
            request.vault, 
            request.receiver, 
            request.barId,
            request.barSize,
            request.value
        );
    }

    /**
     * @dev Only a vault can call a function with this modifier
     */
    modifier onlyVault() {
        require(registry.isVault(msg.sender), "Caller is not a vault");
        _;
    }

    /**
     * @dev Only a signee can call a function with this modifier
     */
    modifier onlySignee() {
        require(registry.isSignee(msg.sender), "Caller is not a signee");
        _;
    }
}