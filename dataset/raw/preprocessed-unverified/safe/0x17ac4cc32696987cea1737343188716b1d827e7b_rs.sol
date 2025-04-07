/**
 *Submitted for verification at Etherscan.io on 2020-07-22
*/

/*

    Copyright 2020 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

// File: canonical-weth/contracts/WETH9.sol

contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() external payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/protocol/v1/lib/P1Types.sol

/**
 * @title P1Types
 * @author dYdX
 *
 * @dev Library for common types used in PerpetualV1 contracts.
 */


// File: contracts/protocol/v1/intf/I_PerpetualV1.sol

/**
 * @title I_PerpetualV1
 * @author dYdX
 *
 * @notice Interface for PerpetualV1.
 */


// File: contracts/protocol/v1/proxies/P1Proxy.sol

/**
 * @title P1Proxy
 * @author dYdX
 *
 * @notice Base contract for proxy contracts, which can be used to provide additional functionality
 *  or restrictions when making calls to a Perpetual contract on behalf of a user.
 */
contract P1Proxy {
    using SafeERC20 for IERC20;

    /**
     * @notice Sets the maximum allowance on the Perpetual contract. Must be called at least once
     *  on a given Perpetual before deposits can be made.
     * @dev Cannot be run in the constructor due to technical restrictions in Solidity.
     */
    function approveMaximumOnPerpetual(
        address perpetual
    )
        external
    {
        IERC20 tokenContract = IERC20(I_PerpetualV1(perpetual).getTokenContract());

        // safeApprove requires unsetting the allowance first.
        tokenContract.safeApprove(perpetual, 0);

        // Set the allowance to the highest possible value.
        tokenContract.safeApprove(perpetual, uint256(-1));
    }
}

// File: contracts/protocol/lib/ReentrancyGuard.sol

/**
 * @title ReentrancyGuard
 * @author dYdX
 *
 * @dev Updated ReentrancyGuard library designed to be used with Proxy Contracts.
 */
contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = uint256(int256(-1));

    uint256 private _STATUS_;

    constructor () internal {
        _STATUS_ = NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_STATUS_ != ENTERED, "ReentrancyGuard: reentrant call");
        _STATUS_ = ENTERED;
        _;
        _STATUS_ = NOT_ENTERED;
    }
}

// File: contracts/protocol/v1/proxies/P1WethProxy.sol

/**
 * @title P1WethProxy
 * @author dYdX
 *
 * @notice A proxy for depositing and withdrawing ETH to/from a Perpetual contract that uses WETH as
 *  its margin token. The ETH will be wrapper and unwrapped by the proxy.
 */
contract P1WethProxy is
    P1Proxy,
    ReentrancyGuard
{
    // ============ Storage ============

    WETH9 public _WETH_;

    // ============ Constructor ============

    constructor (
        address payable weth
    )
        public
    {
        _WETH_ = WETH9(weth);
    }

    // ============ External Functions ============

    /**
     * Fallback function. Disallows ether to be sent to this contract without data except when
     * unwrapping WETH.
     */
    function ()
        external
        payable
    {
        require(
            msg.sender == address(_WETH_),
            "Cannot receive ETH"
        );
    }

    /**
     * @notice Deposit ETH into a Perpetual, by first wrapping it as WETH. Any ETH paid to this
     *  function will be converted and deposited.
     *
     * @param  perpetual  Address of the Perpetual contract to deposit to.
     * @param  account    The account on the Perpetual for which to credit the deposit.
     */
    function depositEth(
        address perpetual,
        address account
    )
        external
        payable
        nonReentrant
    {
        WETH9 weth = _WETH_;
        address marginToken = I_PerpetualV1(perpetual).getTokenContract();
        require(
            marginToken == address(weth),
            "The perpetual does not use WETH for margin deposits"
        );

        // Wrap ETH.
        weth.deposit.value(msg.value)();

        // Deposit all WETH into the perpetual.
        uint256 amount = weth.balanceOf(address(this));
        I_PerpetualV1(perpetual).deposit(account, amount);
    }

    /**
     * @notice Withdraw ETH from a Perpetual, by first withdrawing and unwrapping WETH.
     *
     * @param  perpetual    Address of the Perpetual contract to withdraw from.
     * @param  account      The account on the Perpetual to withdraw from.
     * @param  destination  The address to send the withdrawn ETH to.
     * @param  amount       The amount of ETH/WETH to withdraw.
     */
    function withdrawEth(
        address perpetual,
        address account,
        address payable destination,
        uint256 amount
    )
        external
        nonReentrant
    {
        WETH9 weth = _WETH_;
        address marginToken = I_PerpetualV1(perpetual).getTokenContract();
        require(
            marginToken == address(weth),
            "The perpetual does not use WETH for margin deposits"
        );

        require(
            // Short-circuit if sender is the account owner.
            msg.sender == account ||
                I_PerpetualV1(perpetual).hasAccountPermissions(account, msg.sender),
            "Sender does not have withdraw permissions for the account"
        );

        // Withdraw WETH from the perpetual.
        I_PerpetualV1(perpetual).withdraw(account, address(this), amount);

        // Unwrap all WETH and send it as ETH to the provided destination.
        uint256 balance = weth.balanceOf(address(this));
        weth.withdraw(balance);
        destination.transfer(balance);
    }
}