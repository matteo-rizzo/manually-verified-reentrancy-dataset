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


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: contracts/governance/Burner.sol
/**
 * @title Burner
 * @dev Burner contract for the AWG tokens.
 */
contract Burner {

    using SafeMath for uint256;

    uint256 public index;

    /**
     * @dev Fired when a token burn happens for the @param account.
     */
    event BurnFrom(address indexed account, address indexed vault, bytes32 indexed barId, uint256 value);

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
     * @notice Requires a call to `IERC20.approve` from @param account with the @param value to be burned.
     * @notice The spender param from the `IERC20.approve` function needs to be the address of the `Burner` contract (this).
     * @dev Burns tokens by transfering the 'to be burned' amount initially to this contract and then self burns the ammount. 
     * @param barId Use web3.utils.fromAscii(string).
     */
    function burn(address account, bytes32 barId ,uint256 value) onlyVault external {
        IERC20(address(token)).transferFrom(account, address(this), value);
        token.burn(value);
        emit BurnFrom(account, msg.sender, barId, value);          
    }

    /**
     * @dev Only a vault can call a function with this modifier.
     */
    modifier onlyVault() {
        require(registry.isVault(msg.sender), "Caller is not a vault");
        _;
    }
}