/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

/*

  Copyright 2020 ZeroEx Intl.

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

contract IERC20Token {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /// @dev send `value` token to `to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Always true if the call has enough gas to complete execution
    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    /// @dev Query total supply of token
    /// @return Total supply of token
    function totalSupply()
        external
        view
        returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}









contract IWallet {

    bytes4 internal constant LEGACY_WALLET_MAGIC_VALUE = 0xb0671381;

    /// @dev Validates a hash with the `Wallet` signature type.
    /// @param hash Message hash that is signed.
    /// @param signature Proof of signing.
    /// @return magicValue `bytes4(0xb0671381)` if the signature check succeeds.
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (bytes4 magicValue);
}









contract DeploymentConstants {
    /// @dev Mainnet address of the WETH contract.
    address constant private WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // /// @dev Kovan address of the WETH contract.
    // address constant private WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    /// @dev Mainnet address of the KyberNetworkProxy contract.
    address constant private KYBER_NETWORK_PROXY_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    // /// @dev Kovan address of the KyberNetworkProxy contract.
    // address constant private KYBER_NETWORK_PROXY_ADDRESS = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;
    /// @dev Mainnet address of the `UniswapExchangeFactory` contract.
    address constant private UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    // /// @dev Kovan address of the `UniswapExchangeFactory` contract.
    // address constant private UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xD3E51Ef092B2845f10401a0159B2B96e8B6c3D30;
    /// @dev Mainnet address of the Eth2Dai `MatchingMarket` contract.
    address constant private ETH2DAI_ADDRESS = 0x794e6e91555438aFc3ccF1c5076A74F42133d08D;
    // /// @dev Kovan address of the Eth2Dai `MatchingMarket` contract.
    // address constant private ETH2DAI_ADDRESS = 0xe325acB9765b02b8b418199bf9650972299235F4;
    /// @dev Mainnet address of the `ERC20BridgeProxy` contract
    address constant private ERC20_BRIDGE_PROXY_ADDRESS = 0x8ED95d1746bf1E4dAb58d8ED4724f1Ef95B20Db0;
    // /// @dev Kovan address of the `ERC20BridgeProxy` contract
    // address constant private ERC20_BRIDGE_PROXY_ADDRESS = 0xFb2DD2A1366dE37f7241C83d47DA58fd503E2C64;
    ///@dev Mainnet address of the `Dai` (multi-collateral) contract
    address constant private DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // ///@dev Kovan address of the `Dai` (multi-collateral) contract
    // address constant private DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    /// @dev Mainnet address of the `Chai` contract
    address constant private CHAI_ADDRESS = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    /// @dev Mainnet address of the 0x DevUtils contract.
    address constant private DEV_UTILS_ADDRESS = 0x74134CF88b21383713E096a5ecF59e297dc7f547;
    // /// @dev Kovan address of the 0x DevUtils contract.
    // address constant private DEV_UTILS_ADDRESS = 0x9402639A828BdF4E9e4103ac3B69E1a6E522eB59;
    /// @dev Kyber ETH pseudo-address.
    address constant internal KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    /// @dev Mainnet address of the dYdX contract.
    address constant private DYDX_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    /// @dev Mainnet address of the GST2 contract
    address constant private GST_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;
    /// @dev Mainnet address of the GST Collector
    address constant private GST_COLLECTOR_ADDRESS = 0x000000D3b08566BE75A6DB803C03C85C0c1c5B96;
    // /// @dev Kovan address of the GST2 contract
    // address constant private GST_ADDRESS = address(0);
    // /// @dev Kovan address of the GST Collector
    // address constant private GST_COLLECTOR_ADDRESS = address(0);

    /// @dev Overridable way to get the `KyberNetworkProxy` address.
    /// @return kyberAddress The `IKyberNetworkProxy` address.
    function _getKyberNetworkProxyAddress()
        internal
        view
        returns (address kyberAddress)
    {
        return KYBER_NETWORK_PROXY_ADDRESS;
    }

    /// @dev Overridable way to get the WETH address.
    /// @return wethAddress The WETH address.
    function _getWethAddress()
        internal
        view
        returns (address wethAddress)
    {
        return WETH_ADDRESS;
    }

    /// @dev Overridable way to get the `UniswapExchangeFactory` address.
    /// @return uniswapAddress The `UniswapExchangeFactory` address.
    function _getUniswapExchangeFactoryAddress()
        internal
        view
        returns (address uniswapAddress)
    {
        return UNISWAP_EXCHANGE_FACTORY_ADDRESS;
    }

    /// @dev An overridable way to retrieve the Eth2Dai `MatchingMarket` contract.
    /// @return eth2daiAddress The Eth2Dai `MatchingMarket` contract.
    function _getEth2DaiAddress()
        internal
        view
        returns (address eth2daiAddress)
    {
        return ETH2DAI_ADDRESS;
    }

    /// @dev An overridable way to retrieve the `ERC20BridgeProxy` contract.
    /// @return erc20BridgeProxyAddress The `ERC20BridgeProxy` contract.
    function _getERC20BridgeProxyAddress()
        internal
        view
        returns (address erc20BridgeProxyAddress)
    {
        return ERC20_BRIDGE_PROXY_ADDRESS;
    }

    /// @dev An overridable way to retrieve the `Dai` contract.
    /// @return daiAddress The `Dai` contract.
    function _getDaiAddress()
        internal
        view
        returns (address daiAddress)
    {
        return DAI_ADDRESS;
    }

    /// @dev An overridable way to retrieve the `Chai` contract.
    /// @return chaiAddress The `Chai` contract.
    function _getChaiAddress()
        internal
        view
        returns (address chaiAddress)
    {
        return CHAI_ADDRESS;
    }

    /// @dev An overridable way to retrieve the 0x `DevUtils` contract address.
    /// @return devUtils The 0x `DevUtils` contract address.
    function _getDevUtilsAddress()
        internal
        view
        returns (address devUtils)
    {
        return DEV_UTILS_ADDRESS;
    }

    /// @dev Overridable way to get the DyDx contract.
    /// @return exchange The DyDx exchange contract.
    function _getDydxAddress()
        internal
        view
        returns (address dydxAddress)
    {
        return DYDX_ADDRESS;
    }

    /// @dev An overridable way to retrieve the GST2 contract address.
    /// @return gst The GST contract.
    function _getGstAddress()
        internal
        view
        returns (address gst)
    {
        return GST_ADDRESS;
    }

    /// @dev An overridable way to retrieve the GST Collector address.
    /// @return collector The GST collector address.
    function _getGstCollectorAddress()
        internal
        view
        returns (address collector)
    {
        return GST_COLLECTOR_ADDRESS;
    }
}

contract IERC20Bridge {

    /// @dev Result of a successful bridge call.
    bytes4 constant internal BRIDGE_SUCCESS = 0xdc1600f3;

    /// @dev Emitted when a trade occurs.
    /// @param inputToken The token the bridge is converting from.
    /// @param outputToken The token the bridge is converting to.
    /// @param inputTokenAmount Amount of input token.
    /// @param outputTokenAmount Amount of output token.
    /// @param from The `from` address in `bridgeTransferFrom()`
    /// @param to The `to` address in `bridgeTransferFrom()`
    event ERC20BridgeTransfer(
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        address from,
        address to
    );

    /// @dev Transfers `amount` of the ERC20 `tokenAddress` from `from` to `to`.
    /// @param tokenAddress The address of the ERC20 token to transfer.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    /// @param bridgeData Arbitrary asset data needed by the bridge contract.
    /// @return success The magic bytes `0xdc1600f3` if successful.
    function bridgeTransferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        external
        returns (bytes4 success);
}

contract IGasToken is IERC20Token {

    /// @dev Frees up to `value` sub-tokens
    /// @param value The amount of tokens to free
    /// @return How many tokens were freed
    function freeUpTo(uint256 value) external returns (uint256 freed);

    /// @dev Frees up to `value` sub-tokens owned by `from`
    /// @param from The owner of tokens to spend
    /// @param value The amount of tokens to free
    /// @return How many tokens were freed
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

    /// @dev Mints `value` amount of tokens
    /// @param value The amount of tokens to mint
    function mint(uint256 value) external;
}

contract MixinGasToken is
    DeploymentConstants
{

    /// @dev Frees gas tokens based on the amount of gas consumed in the function
    modifier freesGasTokens {
        uint256 gasBefore = gasleft();
        _;
        if (address(_getGstAddress()) != address(0)) {
            // (gasUsed + FREE_BASE) / (2 * REIMBURSE - FREE_TOKEN)
            //            14154             24000        6870
            IGasToken(_getGstAddress()).freeUpTo(
                (gasBefore - gasleft() + 14154) / 41130
            );
        }
    }

    /// @dev Frees gas tokens using the balance of `from`. Amount freed is based
    ///     on the gas consumed in the function
    modifier freesGasTokensFromCollector() {
        uint256 gasBefore = gasleft();
        _;
        if (address(_getGstAddress()) != address(0)) {
            // (gasUsed + FREE_BASE) / (2 * REIMBURSE - FREE_TOKEN)
            //            14154             24000        6870
            IGasToken(_getGstAddress()).freeFromUpTo(
                _getGstCollectorAddress(),
                (gasBefore - gasleft() + 14154) / 41130
            );
        }
    }
}

// solhint-disable space-after-comma, indent
contract DexForwarderBridge is
    IERC20Bridge,
    IWallet,
    DeploymentConstants,
    MixinGasToken
{
    using LibSafeMath for uint256;

    /// @dev Data needed to reconstruct a bridge call.
    struct BridgeCall {
        address target;
        uint256 inputTokenAmount;
        uint256 outputTokenAmount;
        bytes bridgeData;
    }

    /// @dev Intermediate state variables used by `bridgeTransferFrom()`, in
    ///      struct form to get around stack limits.
    struct TransferFromState {
        address inputToken;
        uint256 initialInputTokenBalance;
        uint256 callInputTokenAmount;
        uint256 callOutputTokenAmount;
        uint256 totalInputTokenSold;
        BridgeCall[] calls;
    }

    /// @dev Spends this contract's entire balance of input tokens by forwarding
    /// them to other bridges. Reverts if the entire balance is not spent.
    /// @param outputToken The token being bought.
    /// @param to The recipient of the bought tokens.
    /// @param bridgeData The abi-encoded input token address.
    /// @return success The magic bytes if successful.
    function bridgeTransferFrom(
        address outputToken,
        address /* from */,
        address to,
        uint256 /* amount */,
        bytes calldata bridgeData
    )
        external
        freesGasTokensFromCollector
        returns (bytes4 success)
    {
        TransferFromState memory state;
        (
            state.inputToken,
            state.calls
        ) = abi.decode(bridgeData, (address, BridgeCall[]));

        state.initialInputTokenBalance = IERC20Token(state.inputToken).balanceOf(address(this));

        for (uint256 i = 0; i < state.calls.length; ++i) {
            // Stop if the we've sold all our input tokens.
            if (state.totalInputTokenSold >= state.initialInputTokenBalance) {
                break;
            }

            // Compute token amounts.
            state.callInputTokenAmount = LibSafeMath.min256(
                state.calls[i].inputTokenAmount,
                state.initialInputTokenBalance.safeSub(state.totalInputTokenSold)
            );
            state.callOutputTokenAmount = LibMath.getPartialAmountFloor(
                state.callInputTokenAmount,
                state.calls[i].inputTokenAmount,
                state.calls[i].outputTokenAmount
            );

            // Execute the call in a new context so we can recoup transferred
            // funds by reverting.
            (bool didSucceed, ) = address(this)
                .call(abi.encodeWithSelector(
                    this.executeBridgeCall.selector,
                    state.calls[i].target,
                    to,
                    state.inputToken,
                    outputToken,
                    state.callInputTokenAmount,
                    state.callOutputTokenAmount,
                    state.calls[i].bridgeData
                ));

            if (didSucceed) {
                // Increase the amount of tokens sold.
                state.totalInputTokenSold = state.totalInputTokenSold.safeAdd(
                    state.callInputTokenAmount
                );
            }
        }
        // Revert if we were not able to sell our entire input token balance.
        require(
            state.totalInputTokenSold >= state.initialInputTokenBalance,
            "DexForwarderBridge/INCOMPLETE_FILL"
        );
        // Always succeed.
        return BRIDGE_SUCCESS;
    }

    /// @dev Transfers `inputToken` token to a bridge contract then calls
    ///      its `bridgeTransferFrom()`. This is executed in separate context
    ///      so we can revert the transfer on error. This can only be called
    //       by this contract itself.
    /// @param bridge The bridge contract.
    /// @param to The recipient of `outputToken` tokens.
    /// @param inputToken The input token.
    /// @param outputToken The output token.
    /// @param inputTokenAmount The amount of input tokens to transfer to `bridge`.
    /// @param outputTokenAmount The amount of expected output tokens to be sent
    ///        to `to` by `bridge`.
    function executeBridgeCall(
        address bridge,
        address to,
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        bytes calldata bridgeData
    )
        external
    {
        // Must be called through `bridgeTransferFrom()`.
        require(msg.sender == address(this), "DexForwarderBridge/ONLY_SELF");
        // `bridge` must not be this contract.
        require(bridge != address(this));

        // Get the starting balance of output tokens for `to`.
        uint256 initialRecipientBalance = IERC20Token(outputToken).balanceOf(to);

        // Transfer input tokens to the bridge.
        LibERC20Token.transfer(inputToken, bridge, inputTokenAmount);

        // Call the bridge.
        (bool didSucceed, bytes memory resultData) =
            bridge.call(abi.encodeWithSelector(
                IERC20Bridge(0).bridgeTransferFrom.selector,
                outputToken,
                bridge,
                to,
                outputTokenAmount,
                bridgeData
            ));

        // Revert if the call failed or not enough tokens were bought.
        // This will also undo the token transfer.
        require(
            didSucceed
            && resultData.length == 32
            && LibBytes.readBytes32(resultData, 0) == bytes32(BRIDGE_SUCCESS)
            && IERC20Token(outputToken).balanceOf(to).safeSub(initialRecipientBalance) >= outputTokenAmount
        );
    }

    /// @dev `SignatureType.Wallet` callback, so that this bridge can be the maker
    ///      and sign for itself in orders. Always succeeds.
    /// @return magicValue Magic success bytes, always.
    function isValidSignature(
        bytes32,
        bytes calldata
    )
        external
        view
        returns (bytes4 magicValue)
    {
        return LEGACY_WALLET_MAGIC_VALUE;
    }
}