/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token contract
 * returns false). Tokens that return no value (and instead revert or throw on failure)
 * are also supported, non-reverting calls are assumed to be successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



struct Action {
    ActionType actionType;
    bytes32 protocolName;
    uint256 adapterIndex;
    address[] tokens;
    uint256[] amounts;
    AmountType[] amountTypes;
    bytes data;
}

enum ActionType { None, Deposit, Withdraw }


enum AmountType { None, Relative, Absolute }


/**
 * @title Protocol adapter interface.
 * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract ProtocolAdapter {

    /**
     * @dev MUST return "Asset" or "Debt".
     * SHOULD be implemented by the public constant state variable.
     */
    function adapterType() external pure virtual returns (bytes32);

    /**
     * @dev MUST return token type (default is "ERC20").
     * SHOULD be implemented by the public constant state variable.
     */
    function tokenType() external pure virtual returns (bytes32);

    /**
     * @dev MUST return amount of the given token locked on the protocol by the given account.
     */
    function getBalance(address token, address account) public view virtual returns (uint256);
}


/**
 * @title Adapter for TokenSets.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract TokenSetsAdapter is ProtocolAdapter {

    bytes32 public constant override adapterType = "Asset";

    bytes32 public constant override tokenType = "SetToken";

    /**
     * @return Amount of SetTokens held by the given account.
     * @param token Address of the SetToken contract.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account) public view override returns (uint256) {
        return ERC20(token).balanceOf(account);
    }
}


/**
 * @title Base contract for interactive protocol adapters.
 * @dev deposit() and withdraw() functions MUST be implemented
 * as well as all the functions from ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract InteractiveAdapter is ProtocolAdapter {

    uint256 internal constant RELATIVE_AMOUNT_BASE = 1e18;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @dev The function must deposit assets to the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
    function deposit(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory data
    )
        public
        payable
        virtual
        returns (address[] memory);

    /**
     * @dev The function must withdraw assets from the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
    function withdraw(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory data
    )
        public
        payable
        virtual
        returns (address[] memory);

    function getAbsoluteAmountDeposit(
        address token,
        uint256 amount,
        AmountType amountType
    )
        internal
        view
        virtual
        returns (uint256)
    {
        if (amountType == AmountType.Relative) {
            require(amount <= RELATIVE_AMOUNT_BASE, "L: wrong relative value!");

            uint256 totalAmount;
            if (token == ETH) {
                totalAmount = address(this).balance;
            } else {
                totalAmount = ERC20(token).balanceOf(address(this));
            }

            if (amount == RELATIVE_AMOUNT_BASE) {
                return totalAmount;
            } else {
                return totalAmount * amount / RELATIVE_AMOUNT_BASE; // TODO overflow check
            }
        } else {
            return amount;
        }
    }

    function getAbsoluteAmountWithdraw(
        address token,
        uint256 amount,
        AmountType amountType
    )
        internal
        view
        virtual
        returns (uint256)
    {
        if (amountType == AmountType.Relative) {
            require(amount <= RELATIVE_AMOUNT_BASE, "L: wrong relative value!");

            if (amount == RELATIVE_AMOUNT_BASE) {
                return getBalance(token, address(this));
            } else {
                return getBalance(token, address(this)) * amount / RELATIVE_AMOUNT_BASE; // TODO overflow check
            }
        } else {
            return amount;
        }
    }
}


/**
 * @dev RebalancingSetIssuanceModule contract interface.
 * Only the functions required for TokenSetsInteractiveAdapter contract are added.
 * The RebalancingSetIssuanceModule contract is available here
 * github.com/SetProtocol/set-protocol-contracts/blob/master/contracts/core/modules/RebalancingSetIssuanceModule.sol.
 */



/**
 * @dev SetToken contract interface.
 * Only the functions required for TokenSetsInteractiveAdapter contract are added.
 * The SetToken contract is available here
 * github.com/SetProtocol/set-protocol-contracts/blob/master/contracts/core/tokens/SetToken.sol.
 */



/**
 * @dev RebalancingSetToken contract interface.
 * Only the functions required for TokenSetsInteractiveAdapter contract are added.
 * The RebalancingSetToken contract is available here
 * github.com/SetProtocol/set-protocol-contracts/blob/master/contracts/core/tokens/RebalancingSetTokenV3.sol.
 */



/**
 * @title Interactive adapter for TokenSets.
 * @dev Implementation of InteractiveAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract TokenSetsInteractiveAdapter is InteractiveAdapter, TokenSetsAdapter {

    using SafeERC20 for ERC20;

    address internal constant TRANSFER_PROXY = 0x882d80D3a191859d64477eb78Cca46599307ec1C;
    address internal constant ISSUANCE_MODULE = 0xDA6786379FF88729264d31d472FA917f5E561443;

    /**
     * @notice Deposits tokens to the TokenSet.
     * @param tokens Array with one element - payment token address.
     * @param amounts Array with one element - payment token amount to be deposited.
     * @param amountTypes Array with one element - amount type.
     * @param data ABI-encoded additional parameters:
     *     - rebalancingSetAddress - rebalancing set address;
     *     - rebalancingSetQuantity - rebalancing set amount to be minted;
     * @return Asset sent back to the msg.sender.
     * @dev Implementation of InteractiveAdapter function.
     */
    function deposit(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory data
    )
        public
        payable
        override
        returns (address[] memory)
    {
        uint256 absoluteAmount;
        for (uint256 i = 0; i < tokens.length; i++) {
            absoluteAmount = getAbsoluteAmountDeposit(tokens[i], amounts[i], amountTypes[i]);
            ERC20(tokens[i]).safeApprove(TRANSFER_PROXY, absoluteAmount, "TSIA![1]");
        }

        (address setAddress, uint256 setQuantity) = abi.decode(data, (address, uint256));

        address[] memory tokensToBeWithdrawn = new address[](1);
        tokensToBeWithdrawn[0] = setAddress;

        try RebalancingSetIssuanceModule(ISSUANCE_MODULE).issueRebalancingSet(
            setAddress,
            setQuantity,
            false
        ) {} catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory) {
            revert("TSIA: tokenSet fail!");
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            ERC20(tokens[i]).safeApprove(TRANSFER_PROXY, 0, "TSIA![2]");
        }

        return tokensToBeWithdrawn;
    }

    /**
     * @notice Withdraws tokens from the TokenSet.
     * @param tokens Array with one element - rebalancing set address.
     * @param amounts Array with one element - rebalancing set amount to be burned.
     * @param amountTypes Array with one element - amount type.
     * @return Asset sent back to the msg.sender.
     * @dev Implementation of InteractiveAdapter function.
     */
    function withdraw(
        address[] memory tokens,
        uint256[] memory amounts,
        AmountType[] memory amountTypes,
        bytes memory
    )
        public
        payable
        override
        returns (address[] memory)
    {
        require(tokens.length == 1, "TSIA: should be 1 token/amount/type!");

        uint256 amount = getAbsoluteAmountWithdraw(tokens[0], amounts[0], amountTypes[0]);
        RebalancingSetIssuanceModule issuanceModule = RebalancingSetIssuanceModule(ISSUANCE_MODULE);
        RebalancingSetToken rebalancingSetToken = RebalancingSetToken(tokens[0]);
        SetToken setToken = rebalancingSetToken.currentSet();
        address[] memory tokensToBeWithdrawn = setToken.getComponents();

        try issuanceModule.redeemRebalancingSet(
            tokens[0],
            amount,
            false
        ) {} catch Error(string memory reason) {
            revert(reason);
        } catch (bytes memory) {
            revert("TSIA: tokenSet fail!");
        }

        return tokensToBeWithdrawn;
    }
}