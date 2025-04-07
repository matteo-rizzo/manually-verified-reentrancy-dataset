/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

// File: contracts/SmartRoute/intf/IDODOV2.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;




// File: contracts/intf/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/lib/SafeMath.sol


/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// File: contracts/lib/SafeERC20.sol


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/intf/IWETH.sol





// File: contracts/lib/ReentrancyGuard.sol

/**
 * @title ReentrancyGuard
 * @author DODO Breeder
 *
 * @notice Protect functions from Reentrancy Attack
 */
contract ReentrancyGuard {
    // https://solidity.readthedocs.io/en/latest/control-structures.html?highlight=zero-state#scoping-and-declarations
    // zero-state of _ENTERED_ is false
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

// File: contracts/SmartRoute/proxies/DODOCpProxyTmp.sol


/**
 * @title DODOUpCpProxy
 * @author DODO Breeder
 *
 * @notice UpCrowdPooling Proxy
 */
contract DODOCpProxyTmp is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage ============

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;
    address public immutable _CP_FACTORY_;

    // ============ Modifiers ============
    fallback() external payable {}

    receive() external payable {}

    constructor(
        address payable weth,
        address cpFactory
    ) public {
        _WETH_ = weth;
        _CP_FACTORY_ = cpFactory;
    }

    //============ UpCrowdPooling Functions (create) ============

    function createCrowdPooling(
        address baseToken,
        address quoteToken,
        uint256 baseInAmount,
        uint256[] memory timeLine,
        uint256[] memory valueList,
        bool isOpenTWAP
    ) external payable preventReentrant returns (address payable newCrowdPooling) {
        address _baseToken = baseToken;
        address _quoteToken = quoteToken == _ETH_ADDRESS_ ? _WETH_ : quoteToken;
        
        newCrowdPooling = IDODOV2(_CP_FACTORY_).createCrowdPooling();

        IERC20(baseToken).transferFrom(msg.sender,newCrowdPooling, baseInAmount);

        (bool success, ) = newCrowdPooling.call{value: msg.value}("");
        require(success, "DODOCpProxyTmp: Transfer Success");

        IDODOV2(_CP_FACTORY_).initCrowdPooling(
            newCrowdPooling,
            msg.sender,
            _baseToken,
            _quoteToken,
            timeLine,
            valueList,
            isOpenTWAP
        );
    }
}