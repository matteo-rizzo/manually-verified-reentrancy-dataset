/**
 *Submitted for verification at Etherscan.io on 2020-12-13
*/

// Dependency file: /Users/present/code/super-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: /Users/present/code/super-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol


// pragma solidity ^0.6.0;

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



// Dependency file: /Users/present/code/super-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol


// pragma solidity >=0.4.24 <0.7.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


// Dependency file: /Users/present/code/super-sett/interfaces/meme/IMemeLtd.sol

// pragma solidity ^0.6.0;




// Root file: contracts/badger-hunt/HoneypotMeme.sol

pragma solidity ^0.6.11;

// import "/Users/present/code/super-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/super-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/super-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
// import "/Users/present/code/super-sett/interfaces/meme/IMemeLtd.sol";

contract HoneypotMeme is Initializable {
    using SafeMathUpgradeable for uint256;

    IERC20Upgradeable public token;
    bool public isClaimed;

    IMemeLtd public memeLtd;
    uint256 public honeypot;
    uint256[] public nftIndicies;

    address public constant memeLtdAddress = 0xe4605d46Fd0B3f8329d936a8b258D69276cBa264;

    event Claimed(address account, uint256 amount);

    function initialize(
        IERC20Upgradeable token_,
        uint256 honeypot_,
        uint256[] memory nftIndicies_
    ) public virtual {
        memeLtd = IMemeLtd(memeLtdAddress);
        token = token_;
        honeypot = honeypot_;
        nftIndicies = nftIndicies_;
    }

    function claim() external {
        _verifyRequirements();
        isClaimed = true;
        emit Claimed(msg.sender, honeypot);
        require(token.transfer(msg.sender, honeypot), "honeypot/transfer-failed");
    }

    /// @dev The called must possess all required NFTs, as well as the secret
    function _verifyRequirements() internal {
        require(!isClaimed, "honeypot/is-claimed");
        for (uint256 i = 0; i < nftIndicies.length; i++) {
            require(memeLtd.balanceOf(msg.sender, nftIndicies[i]) > 0, "honeypot/nft-ownership");
        }
    }
}