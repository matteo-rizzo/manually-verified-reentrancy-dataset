/**
 *Submitted for verification at Etherscan.io on 2021-03-09
*/

// Dependency file: @openzeppelin/contracts/utils/Address.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

// pragma solidity >=0.5.0;




// Dependency file: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

// pragma solidity >=0.6.2;




// Dependency file: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

// pragma solidity >=0.6.2;

// import '/Users/alexsoong/Source/set-protocol/index-coop-contracts/node_modules/@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// Dependency file: @openzeppelin/contracts/math/Math.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

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



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: contracts/interfaces/ISetToken.sol

// pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ISetToken
 * @author Set Protocol
 *
 * Interface for operating with SetTokens.
 */
interface ISetToken is IERC20 {

    /* ============ Enums ============ */

    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    /* ============ Structs ============ */
    /**
     * The base definition of a SetToken Position
     *
     * @param component           Address of token in the Position
     * @param module              If not in default state, the address of associated module
     * @param unit                Each unit is the # of components per 10^18 of a SetToken
     * @param positionState       Position ENUM. Default is 0; External is 1
     * @param data                Arbitrary data
     */
    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    /**
     * A struct that stores a component's cash position details and external positions
     * This data structure allows O(1) access to a component's cash position units and 
     * virtual units.
     *
     * @param virtualUnit               Virtual value of a component's DEFAULT position. Stored as virtual for efficiency
     *                                  updating all units at once via the position multiplier. Virtual units are achieved
     *                                  by dividing a "real" value by the "positionMultiplier"
     * @param componentIndex            
     * @param externalPositionModules   List of external modules attached to each external position. Each module
     *                                  maps to an external position
     * @param externalPositions         Mapping of module => ExternalPosition struct for a given component
     */
    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    /**
     * A struct that stores a component's external position details including virtual unit and any
     * auxiliary data.
     *
     * @param virtualUnit       Virtual value of a component's EXTERNAL position.
     * @param data              Arbitrary data
     */
    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    /* ============ Functions ============ */
    
    function addComponent(address _component) external;
    function removeComponent(address _component) external;
    function editDefaultPositionUnit(address _component, int256 _realUnit) external;
    function addExternalPositionModule(address _component, address _positionModule) external;
    function removeExternalPositionModule(address _component, address _positionModule) external;
    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;
    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;

    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);

    function editPositionMultiplier(int256 _newMultiplier) external;

    function mint(address _account, uint256 _quantity) external;
    function burn(address _account, uint256 _quantity) external;

    function lock() external;
    function unlock() external;

    function addModule(address _module) external;
    function removeModule(address _module) external;
    function initializeModule() external;

    function setManager(address _manager) external;

    function manager() external view returns (address);
    function moduleStates(address _module) external view returns (ModuleState);
    function getModules() external view returns (address[] memory);
    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);
    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);
    function getComponents() external view returns(address[] memory);
    function getExternalPositionModules(address _component) external view returns(address[] memory);
    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);
    function isExternalPositionModule(address _component, address _module) external view returns(bool);
    function isComponent(address _component) external view returns(bool);
    
    function positionMultiplier() external view returns (int256);
    function getPositions() external view returns (Position[] memory);
    function getTotalComponentRealUnits(address _component) external view returns(int256);

    function isInitializedModule(address _module) external view returns(bool);
    function isPendingModule(address _module) external view returns(bool);
    function isLocked() external view returns (bool);
}

// Dependency file: contracts/interfaces/IBasicIssuanceModule.sol

/*
    Copyright 2020 Set Labs Inc.
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
// pragma solidity >=0.6.10;

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";



// Dependency file: contracts/interfaces/IController.sol

/*
    Copyright 2020 Set Labs Inc.
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
// pragma solidity 0.6.10;




// Dependency file: contracts/interfaces/IWETH.sol

// pragma solidity >=0.6.10;



// Dependency file: @openzeppelin/contracts/math/SignedSafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */



// Dependency file: contracts/lib/PreciseUnitMath.sol

/*
    Copyright 2020 Set Labs Inc.

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

// pragma solidity 0.6.10;

// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";


/**
 * @title PreciseUnitMath
 * @author Set Protocol
 *
 * Arithmetic for fixed-point numbers with 18 decimals of precision. Some functions taken from
 * dYdX's BaseMath library.
 *
 * CHANGELOG:
 * - 9/21/20: Added safePower function
 */


// Dependency file: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

// pragma solidity >=0.5.0;




// Dependency file: external/contracts/SushiswapV2Library.sol


// pragma solidity >=0.5.0;

// import '/Users/alexsoong/Source/set-protocol/index-coop-contracts/node_modules/@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";



// Dependency file: external/contracts/uniswap/lib/UniswapV2Library.sol

// pragma solidity >=0.5.0;

// import '/Users/alexsoong/Source/set-protocol/index-coop-contracts/node_modules/@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";



// Root file: contracts/exchangeIssuance/ExchangeIssuance.sol

/*
    Copyright 2021 Index Cooperative
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
pragma solidity 0.6.10;

// import { Address } from "@openzeppelin/contracts/utils/Address.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { IUniswapV2Factory } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
// import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// import { Math } from "@openzeppelin/contracts/math/Math.sol";
// import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// import { IBasicIssuanceModule } from "contracts/interfaces/IBasicIssuanceModule.sol";
// import { IController } from "contracts/interfaces/IController.sol";
// import { ISetToken } from "contracts/interfaces/ISetToken.sol";
// import { IWETH } from "contracts/interfaces/IWETH.sol";
// import { PreciseUnitMath } from "contracts/lib/PreciseUnitMath.sol";
// import { SushiswapV2Library } from "external/contracts/SushiswapV2Library.sol";
// import { UniswapV2Library } from "external/contracts/uniswap/lib/UniswapV2Library.sol";


/**
 * @title ExchangeIssuance
 * @author Index Coop
 *
 * Contract for issuing and redeeming any SetToken using ETH or an ERC20 as the paying/receiving currency.
 * All swaps are done using the best price found on Uniswap or Sushiswap.
 *
 */
contract ExchangeIssuance is ReentrancyGuard {
    
    using Address for address payable;
    using SafeMath for uint256;
    using PreciseUnitMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ISetToken;
    
    /* ============ Enums ============ */
    
    enum Exchange { Uniswap, Sushiswap, None }

    /* ============ Constants ============= */

    uint256 constant private MAX_UINT96 = 2**96 - 1;
    address constant public ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    /* ============ State Variables ============ */

    address public WETH;
    IUniswapV2Router02 public uniRouter;
    IUniswapV2Router02 public sushiRouter;
    
    address public immutable uniFactory;
    address public immutable sushiFactory;
    
    IController public immutable setController;
    IBasicIssuanceModule public immutable basicIssuanceModule;

    /* ============ Events ============ */

    event ExchangeIssue(
        address indexed _recipient,     // The recipient address of the issued SetTokens
        ISetToken indexed _setToken,    // The issued SetToken
        IERC20 indexed _inputToken,     // The address of the input asset(ERC20/ETH) used to issue the SetTokens
        uint256 _amountInputToken,      // The amount of input tokens used for issuance
        uint256 _amountSetIssued        // The amount of SetTokens received by the recipient
    );

    event ExchangeRedeem(
        address indexed _recipient,     // The recipient address which redeemed the SetTokens
        ISetToken indexed _setToken,    // The redeemed SetToken
        IERC20 indexed _outputToken,    // The addres of output asset(ERC20/ETH) received by the recipient
        uint256 _amountSetRedeemed,     // The amount of SetTokens redeemed for output tokens
        uint256 _amountOutputToken      // The amount of output tokens received by the recipient
    );

    event Refund(
        address indexed _recipient,     // The recipient address which redeemed the SetTokens
        uint256 _refundAmount           // The amount of ETH redunder by this transaction
    );
    
    /* ============ Modifiers ============ */
    
    modifier isSetToken(ISetToken _setToken) {
         require(setController.isSet(address(_setToken)), "ExchangeIssuance: INVALID SET");
         _;
    }
    
    /* ============ Constructor ============ */

    constructor(
        address _weth,
        address _uniFactory,
        IUniswapV2Router02 _uniRouter, 
        address _sushiFactory, 
        IUniswapV2Router02 _sushiRouter, 
        IController _setController,
        IBasicIssuanceModule _basicIssuanceModule
    )
        public
    {
        uniFactory = _uniFactory;
        uniRouter = _uniRouter;

        sushiFactory = _sushiFactory;
        sushiRouter = _sushiRouter;
        
        setController = _setController;
        basicIssuanceModule = _basicIssuanceModule;
        
        WETH = _weth;
        IERC20(WETH).safeApprove(address(uniRouter), PreciseUnitMath.maxUint256());
        IERC20(WETH).safeApprove(address(sushiRouter), PreciseUnitMath.maxUint256());
    }
    
    /* ============ Public Functions ============ */
    
    /**
     * Runs all the necessary approval functions required for a given ERC20 token.
     * This function can be called when a new token is added to a SetToken during a 
     * rebalance.
     *
     * @param _token    Address of the token which needs approval
     */
    function approveToken(IERC20 _token) public {
        _safeApprove(_token, address(uniRouter), MAX_UINT96);
        _safeApprove(_token, address(sushiRouter), MAX_UINT96);
        _safeApprove(_token, address(basicIssuanceModule), MAX_UINT96);
    }

    /* ============ External Functions ============ */
    
    receive() external payable {
        // required for weth.withdraw() to work properly
        require(msg.sender == WETH, "ExchangeIssuance: Direct deposits not allowed");
    }
    
    /**
     * Runs all the necessary approval functions required for a list of ERC20 tokens.
     *
     * @param _tokens    Addresses of the tokens which need approval
     */
    function approveTokens(IERC20[] calldata _tokens) external {
        for (uint256 i = 0; i < _tokens.length; i++) {
            approveToken(_tokens[i]);
        }
    }

    /**
     * Runs all the necessary approval functions required before issuing
     * or redeeming a SetToken. This function need to be called only once before the first time
     * this smart contract is used on any particular SetToken.
     *
     * @param _setToken    Address of the SetToken being initialized
     */
    function approveSetToken(ISetToken _setToken) isSetToken(_setToken) external {
        address[] memory components = _setToken.getComponents();
        for (uint256 i = 0; i < components.length; i++) {
            // Check that the component does not have external positions
            require(
                _setToken.getExternalPositionModules(components[i]).length == 0,
                "ExchangeIssuance: EXTERNAL_POSITIONS_NOT_ALLOWED"
            );
            approveToken(IERC20(components[i]));
        }
    }

    /**
     * Issues SetTokens for an exact amount of input ERC20 tokens.
     * The ERC20 token must be approved by the sender to this contract. 
     *
     * @param _setToken         Address of the SetToken being issued
     * @param _inputToken       Address of input token
     * @param _amountInput      Amount of the input token / ether to spend
     * @param _minSetReceive    Minimum amount of SetTokens to receive. Prevents unnecessary slippage.
     *
     * @return setTokenAmount   Amount of SetTokens issued to the caller
     */
    function issueSetForExactToken(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountInput,
        uint256 _minSetReceive
    )   
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {   
        require(_amountInput > 0, "ExchangeIssuance: INVALID INPUTS");
        
        _inputToken.safeTransferFrom(msg.sender, address(this), _amountInput);
        
        uint256 amountEth = address(_inputToken) == WETH
            ? _amountInput
            : _swapTokenForWETH(_inputToken, _amountInput);

        uint256 setTokenAmount = _issueSetForExactWETH(_setToken, _minSetReceive, amountEth);
        
        emit ExchangeIssue(msg.sender, _setToken, _inputToken, _amountInput, setTokenAmount);
        return setTokenAmount;
    }
    
    /**
     * Issues SetTokens for an exact amount of input ether.
     * 
     * @param _setToken         Address of the SetToken to be issued
     * @param _minSetReceive    Minimum amount of SetTokens to receive. Prevents unnecessary slippage.
     *
     * @return setTokenAmount   Amount of SetTokens issued to the caller
     */
    function issueSetForExactETH(
        ISetToken _setToken,
        uint256 _minSetReceive
    )
        isSetToken(_setToken)
        external
        payable
        nonReentrant
        returns(uint256)
    {
        require(msg.value > 0, "ExchangeIssuance: INVALID INPUTS");
        
        IWETH(WETH).deposit{value: msg.value}();
        
        uint256 setTokenAmount = _issueSetForExactWETH(_setToken, _minSetReceive, msg.value);
        
        emit ExchangeIssue(msg.sender, _setToken, IERC20(ETH_ADDRESS), msg.value, setTokenAmount);
        return setTokenAmount;
    }
    
    /**
    * Issues an exact amount of SetTokens for given amount of input ERC20 tokens.
    * The excess amount of tokens is returned in an equivalent amount of ether.
    *
    * @param _setToken              Address of the SetToken to be issued
    * @param _inputToken            Address of the input token
    * @param _amountSetToken        Amount of SetTokens to issue
    * @param _maxAmountInputToken   Maximum amount of input tokens to be used to issue SetTokens. The unused 
    *                               input tokens are returned as ether.
    *
    * @return amountEthReturn       Amount of ether returned to the caller
    */
    function issueExactSetFromToken(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountSetToken,
        uint256 _maxAmountInputToken
    )
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {
        require(_amountSetToken > 0 && _maxAmountInputToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        _inputToken.safeTransferFrom(msg.sender, address(this), _maxAmountInputToken);
        
        uint256 initETHAmount = address(_inputToken) == WETH
            ? _maxAmountInputToken
            :  _swapTokenForWETH(_inputToken, _maxAmountInputToken);
        
        uint256 amountEthSpent = _issueExactSetFromWETH(_setToken, _amountSetToken, initETHAmount);
        
        uint256 amountEthReturn = initETHAmount.sub(amountEthSpent);
        if (amountEthReturn > 0) {
            IWETH(WETH).withdraw(amountEthReturn);
            (payable(msg.sender)).sendValue(amountEthReturn);
        }
        
        emit Refund(msg.sender, amountEthReturn);
        emit ExchangeIssue(msg.sender, _setToken, _inputToken, _maxAmountInputToken, _amountSetToken);
        return amountEthReturn;
    }
    
    /**
    * Issues an exact amount of SetTokens using a given amount of ether.
    * The excess ether is returned back.
    * 
    * @param _setToken          Address of the SetToken being issued
    * @param _amountSetToken    Amount of SetTokens to issue
    *
    * @return amountEthReturn   Amount of ether returned to the caller
    */
    function issueExactSetFromETH(
        ISetToken _setToken,
        uint256 _amountSetToken
    )
        isSetToken(_setToken)
        external
        payable
        nonReentrant
        returns (uint256)
    {
        require(msg.value > 0 && _amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        IWETH(WETH).deposit{value: msg.value}();
        
        uint256 amountEth = _issueExactSetFromWETH(_setToken, _amountSetToken, msg.value);
        
        uint256 amountEthReturn = msg.value.sub(amountEth);
        
        if (amountEthReturn > 0) {
            IWETH(WETH).withdraw(amountEthReturn);
            (payable(msg.sender)).sendValue(amountEthReturn);
        }
        
        emit Refund(msg.sender, amountEthReturn);
        emit ExchangeIssue(msg.sender, _setToken, IERC20(ETH_ADDRESS), amountEth, _amountSetToken);
        return amountEthReturn;
    }
    
    /**
     * Redeems an exact amount of SetTokens for an ERC20 token.
     * The SetToken must be approved by the sender to this contract.
     *
     * @param _setToken             Address of the SetToken being redeemed
     * @param _outputToken          Address of output token
     * @param _amountSetToken       Amount SetTokens to redeem
     * @param _minOutputReceive     Minimum amount of output token to receive
     *
     * @return outputAmount         Amount of output tokens sent to the caller
     */
    function redeemExactSetForToken(
        ISetToken _setToken,
        IERC20 _outputToken,
        uint256 _amountSetToken,
        uint256 _minOutputReceive
    )
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {
        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 totalEth, 
            uint256[] memory amountComponents, 
            Exchange[] memory exchanges
        ) =  _getAmountETHForRedemption(_setToken, components, _amountSetToken);
        
        uint256 outputAmount;
        if (address(_outputToken) == WETH) {
            require(totalEth > _minOutputReceive, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
            _redeemExactSet(_setToken, _amountSetToken);
            outputAmount = _liquidateComponentsForWETH(components, amountComponents, exchanges);
        } else {
            (uint256 totalOutput, Exchange outTokenExchange) = _getMaxTokenForExactToken(totalEth, address(WETH), address(_outputToken));
            require(totalOutput > _minOutputReceive, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
            _redeemExactSet(_setToken, _amountSetToken);
            uint256 outputEth = _liquidateComponentsForWETH(components, amountComponents, exchanges);
            outputAmount = _swapExactTokensForTokens(outTokenExchange, WETH, address(_outputToken), outputEth);
        }
        
        _outputToken.safeTransfer(msg.sender, outputAmount);
        emit ExchangeRedeem(msg.sender, _setToken, _outputToken, _amountSetToken, outputAmount);
        return outputAmount;
    }
    
    /**
     * Redeems an exact amount of SetTokens for ETH.
     * The SetToken must be approved by the sender to this contract.
     *
     * @param _setToken             Address of the SetToken to be redeemed
     * @param _amountSetToken       Amount of SetTokens to redeem
     * @param _minEthOut            Minimum amount of ETH to receive
     *
     * @return amountEthOut         Amount of ether sent to the caller
     */
    function redeemExactSetForETH(
        ISetToken _setToken,
        uint256 _amountSetToken,
        uint256 _minEthOut
    )
        isSetToken(_setToken)
        external
        nonReentrant
        returns (uint256)
    {
        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 totalEth, 
            uint256[] memory amountComponents, 
            Exchange[] memory exchanges
        ) =  _getAmountETHForRedemption(_setToken, components, _amountSetToken);
        
        require(totalEth > _minEthOut, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
        
        _redeemExactSet(_setToken, _amountSetToken);
        
        uint256 amountEthOut = _liquidateComponentsForWETH(components, amountComponents, exchanges);
        
        IWETH(WETH).withdraw(amountEthOut);
        (payable(msg.sender)).sendValue(amountEthOut);

        emit ExchangeRedeem(msg.sender, _setToken, IERC20(ETH_ADDRESS), _amountSetToken, amountEthOut);
        return amountEthOut;
    }

    /**
     * Returns an estimated quantity of the specified SetToken given a specified amount of input ERC20 token.
     * Estimating pulls the best price of each component using Uniswap or Sushiswap
     *
     * @param _setToken         Address of the SetToken being issued
     * @param _amountInput      Amount of the input token to spend
     * @param _inputToken       Address of input token.
     *
     * @return                  Estimated amount of SetTokens that will be received
     */
    function getEstimatedIssueSetAmount(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountInput
    )
        isSetToken(_setToken)
        external
        view
        returns (uint256)
    {
        require(_amountInput > 0, "ExchangeIssuance: INVALID INPUTS");
        
        uint256 amountEth;
        if (address(_inputToken) != WETH) {
            // get max amount of WETH for the `_amountInput` amount of input tokens
            (amountEth, ) = _getMaxTokenForExactToken(_amountInput, address(_inputToken), WETH);
        } else {
            amountEth = _amountInput;
        }
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 sumEth, 
            uint256[] memory amountEthIn, 
            Exchange[] memory exchanges, 
            uint256[] memory amountComponents
        ) = _getAmountETHForIssuance(_setToken, components, PreciseUnitMath.preciseUnit());
        
        uint256 maxIndexAmount = PreciseUnitMath.maxUint256();
        
        for (uint256 i = 0; i < components.length; i++) {
            uint256 scaledAmountEth = amountEthIn[i].mul(amountEth).div(sumEth);
            
            // if exchange[i] is Exchange.None then amountTokenOut remains equal to scaledAmountEth
            uint256 amountTokenOut = scaledAmountEth;
            if (exchanges[i] == Exchange.Uniswap) {
                (uint256 reserveIn, uint256 reserveOut) = UniswapV2Library.getReserves(uniFactory, WETH, components[i]);
                amountTokenOut = UniswapV2Library.getAmountOut(scaledAmountEth, reserveIn, reserveOut);
            } else if (exchanges[i] == Exchange.Uniswap) {
                (uint256 reserveIn, uint256 reserveOut) = SushiswapV2Library.getReserves(sushiFactory, WETH, components[i]);
                amountTokenOut = SushiswapV2Library.getAmountOut(scaledAmountEth, reserveIn, reserveOut);
            }
            
            maxIndexAmount = Math.min(amountTokenOut.preciseDiv(amountComponents[i]), maxIndexAmount);
        }
        return maxIndexAmount;
    }
    
    /**
    * Returns the amount of input ERC20 tokens required to issue an exact amount of SetTokens.
    *
    * @param _setToken          Address of the SetToken being issued
    * @param _amountSetToken    Amount of SetTokens to issue
    *
    * @return                   Amount of tokens needed to issue specified amount of SetTokens
    */
    function getAmountInToIssueExactSet(
        ISetToken _setToken,
        IERC20 _inputToken,
        uint256 _amountSetToken
    )
        isSetToken(_setToken)
        external
        view
        returns(uint256)
    {
        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (uint256 totalEth, , , ) = _getAmountETHForIssuance(_setToken, components, _amountSetToken);
        
        if (address(_inputToken) == WETH) {
            return totalEth;
        }
        
        (uint256 tokenAmount, ) = _getMinTokenForExactToken(totalEth, address(_inputToken), address(WETH));
        return tokenAmount;
    }
    
    /**
     * Returns amount of output ERC20 tokens received upon redeeming a given amount of SetToken.
     *
     * @param _setToken             Address of SetToken to be redeemed
     * @param _amountSetToken       Amount of SetToken to be redeemed
     * @param _outputToken          Address of output token
     *
     * @return                      Estimated amount of ether/erc20 that will be received
     */
    function getAmountOutOnRedeemSet(
        ISetToken _setToken,
        address _outputToken,
        uint256 _amountSetToken
    ) 
        isSetToken(_setToken)
        external
        view
        returns (uint256)
    {
        require(_amountSetToken > 0, "ExchangeIssuance: INVALID INPUTS");
        
        address[] memory components = _setToken.getComponents();
        (uint256 totalEth, , ) = _getAmountETHForRedemption(_setToken, components, _amountSetToken);
        
        if (_outputToken == WETH) {
            return totalEth;
        }
        
        // get maximum amount of tokens for totalEth amount of ETH
        (uint256 tokenAmount, ) = _getMaxTokenForExactToken(totalEth, WETH, _outputToken);
        return tokenAmount;
    }
    
    
    /* ============ Internal Functions ============ */

    /**
     * Sets a max aproval limit for an ERC20 token, provided the current allowance 
     * is less than the required allownce. 
     * 
     * @param _token    Token to approve
     * @param _spender  Spender address to approve
     */
    function _safeApprove(IERC20 _token, address _spender, uint256 _requiredAllowance) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _requiredAllowance) {
            _token.safeIncreaseAllowance(_spender, MAX_UINT96 - allowance);
        }
    }
    
    /**
     * Issues SetTokens for an exact amount of input WETH. 
     * Acquires SetToken components at the best price accross uniswap and sushiswap.
     * Uses the acquired components to issue the SetTokens.
     * 
     * @param _setToken         Address of the SetToken being issued
     * @param _minSetReceive    Minimum amount of index to receive
     * @param _totalEthAmount   Total amount of WETH to be used to purchase the SetToken components
     *
     * @return setTokenAmount   Amount of SetTokens issued
     */
    function _issueSetForExactWETH(ISetToken _setToken, uint256 _minSetReceive, uint256 _totalEthAmount) internal returns (uint256) {
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 sumEth, 
            uint256[] memory amountEthIn, 
            Exchange[] memory exchanges, 
            uint256[] memory amountComponents
        ) = _getAmountETHForIssuance(_setToken, components, PreciseUnitMath.preciseUnit());
        
        // Acquire the SetToken components from exchanges
        uint256 setTokenAmount = PreciseUnitMath.maxUint256();
        for (uint256 i = 0; i < components.length; i++) {
            uint256 scaledAmountEth = amountEthIn[i].mul(_totalEthAmount).div(sumEth);
            uint256 amountTokenOut = _swapExactTokensForTokens(exchanges[i], WETH, components[i], scaledAmountEth);
            setTokenAmount = Math.min(amountTokenOut.preciseDiv(amountComponents[i]), setTokenAmount);
        }
        
        require(setTokenAmount >= _minSetReceive, "ExchangeIssuance: INSUFFICIENT_OUTPUT_AMOUNT");
        
        basicIssuanceModule.issue(_setToken, setTokenAmount, msg.sender);
        return setTokenAmount;
    }
    
    /**
     * Issues an exact amount of SetTokens using WETH. 
     * Acquires SetToken components at the best price accross uniswap and sushiswap.
     * Uses the acquired components to issue the SetTokens.
     * 
     * @param _setToken          Address of the SetToken being issued
     * @param _amountSetToken    Amount of SetTokens to be issued
     * @param _maxEther          Max amount of ether that can be used to acquire the SetToken components
     *
     * @return totalEth          Total amount of ether used to acquire the SetToken components
     */
    function _issueExactSetFromWETH(ISetToken _setToken, uint256 _amountSetToken, uint256 _maxEther) internal returns (uint256) {
        
        address[] memory components = _setToken.getComponents();
        (
            uint256 sumEth,
            , 
            Exchange[] memory exchanges, 
            uint256[] memory amountComponents
        ) = _getAmountETHForIssuance(_setToken, components, _amountSetToken);
        
        require(sumEth <= _maxEther, "ExchangeIssuance: INSUFFICIENT_INPUT_AMOUNT");
        
        uint256 totalEth = 0;
        for (uint256 i = 0; i < components.length; i++) {
            uint256 amountEth = _swapTokensForExactTokens(exchanges[i], WETH, components[i], amountComponents[i]);
            totalEth = totalEth.add(amountEth);
        }
        basicIssuanceModule.issue(_setToken, _amountSetToken, msg.sender);
        return totalEth;
    }
    
    /**
     * Redeems a given amount of SetToken.
     * 
     * @param _setToken     Address of the SetToken to be redeemed
     * @param _amount       Amount of SetToken to be redeemed
     */
    function _redeemExactSet(ISetToken _setToken, uint256 _amount) internal returns (uint256) {
        _setToken.safeTransferFrom(msg.sender, address(this), _amount);
        basicIssuanceModule.redeem(_setToken, _amount, address(this));
    }
    
    /**
     * Liquidates a given list of SetToken components for WETH.
     * 
     * @param _components           An array containing the address of SetToken components
     * @param _amountComponents     An array containing the amount of each SetToken component
     * @param _exchanges            An array containing the exchange on which to liquidate the SetToken component
     *
     * @return                      Total amount of WETH received after liquidating all SetToken components
     */
    function _liquidateComponentsForWETH(address[] memory _components, uint256[] memory _amountComponents, Exchange[] memory _exchanges)
        internal
        returns (uint256)
    {
        uint256 sumEth = 0;
        for (uint256 i = 0; i < _components.length; i++) {
            sumEth = _exchanges[i] == Exchange.None
                ? sumEth.add(_amountComponents[i]) 
                : sumEth.add(_swapExactTokensForTokens(_exchanges[i], _components[i], WETH, _amountComponents[i]));
        }
        return sumEth;
    }
    
    /**
     * Gets the total amount of ether required for purchasing each component in a SetToken,
     * to enable the issuance of a given amount of SetTokens.
     * 
     * @param _setToken             Address of the SetToken to be issued
     * @param _components           An array containing the addresses of the SetToken components
     * @param _amountSetToken       Amount of SetToken to be issued
     *
     * @return sumEth               The total amount of Ether reuired to issue the set
     * @return amountEthIn          An array containing the amount of ether to purchase each component of the SetToken
     * @return exchanges            An array containing the exchange on which to perform the purchase
     * @return amountComponents     An array containing the amount of each SetToken component required for issuing the given
     *                              amount of SetToken
     */
    function _getAmountETHForIssuance(ISetToken _setToken, address[] memory _components, uint256 _amountSetToken)
        internal
        view
        returns (uint256, uint256[] memory, Exchange[] memory, uint256[] memory)
    {
        uint256 sumEth = 0;
        uint256[] memory amountEthIn = new uint256[](_components.length);
        uint256[] memory amountComponents = new uint256[](_components.length);
        Exchange[] memory exchanges = new Exchange[](_components.length);
        
        for (uint256 i = 0; i < _components.length; i++) {

            // Check that the component does not have external positions
            require(
                _setToken.getExternalPositionModules(_components[i]).length == 0,
                "Exchange Issuance: EXTERNAL_POSITIONS_NOT_ALLOWED"
            );

            // Get minimum amount of ETH to be spent to acquire the required amount of SetToken component
            uint256 unit = uint256(_setToken.getDefaultPositionRealUnit(_components[i]));
            amountComponents[i] = uint256(unit).preciseMul(_amountSetToken);
            
            (amountEthIn[i], exchanges[i]) = _getMinTokenForExactToken(amountComponents[i], WETH, _components[i]);
            sumEth = sumEth.add(amountEthIn[i]);
        }
        return (sumEth, amountEthIn, exchanges, amountComponents);
    }
    
    /**
     * Gets the total amount of ether returned from liquidating each component in a SetToken.
     * 
     * @param _setToken             Address of the SetToken to be redeemed
     * @param _components           An array containing the addresses of the SetToken components
     * @param _amountSetToken       Amount of SetToken to be redeemed
     *
     * @return sumEth               The total amount of Ether that would be obtained from liquidating the SetTokens
     * @return amountComponents     An array containing the amount of SetToken component to be liquidated
     * @return exchanges            An array containing the exchange on which to liquidate the SetToken components
     */
    function _getAmountETHForRedemption(ISetToken _setToken, address[] memory _components, uint256 _amountSetToken)
        internal
        view
        returns (uint256, uint256[] memory, Exchange[] memory)
    {
        uint256 sumEth = 0;
        uint256 amountEth = 0;
        
        uint256[] memory amountComponents = new uint256[](_components.length);
        Exchange[] memory exchanges = new Exchange[](_components.length);
        
        for (uint256 i = 0; i < _components.length; i++) {
            
            // Check that the component does not have external positions
            require(
                _setToken.getExternalPositionModules(_components[i]).length == 0,
                "Exchange Issuance: EXTERNAL_POSITIONS_NOT_ALLOWED"
            );
            
            uint256 unit = uint256(_setToken.getDefaultPositionRealUnit(_components[i]));
            amountComponents[i] = unit.preciseMul(_amountSetToken);
            
            // get maximum amount of ETH received for a given amount of SetToken component
            (amountEth, exchanges[i]) = _getMaxTokenForExactToken(amountComponents[i], _components[i], WETH);
            sumEth = sumEth.add(amountEth);
        }
        return (sumEth, amountComponents, exchanges);
    }
    
    /**
     * Swaps a given amount of an ERC20 token for WETH for the best price on Uniswap/Sushiswap.
     * 
     * @param _token    Address of the ERC20 token to be swapped for WETH
     * @param _amount   Amount of ERC20 token to be swapped
     *
     * @return          Amount of WETH received after the swap
     */
    function _swapTokenForWETH(IERC20 _token, uint256 _amount) internal returns (uint256) {
        (, Exchange exchange) = _getMaxTokenForExactToken(_amount, address(_token), WETH);
        IUniswapV2Router02 router = _getRouter(exchange);
        _safeApprove(_token, address(router), _amount);
        return _swapExactTokensForTokens(exchange, address(_token), WETH, _amount);
    }
    
    /**
     * Swap exact tokens for another token on a given DEX.
     *
     * @param _exchange     The exchange on which to peform the swap
     * @param _tokenIn      The address of the input token
     * @param _tokenOut     The address of the output token
     * @param _amountIn     The amount of input token to be spent
     *
     * @return              The amount of output tokens
     */
    function _swapExactTokensForTokens(Exchange _exchange, address _tokenIn, address _tokenOut, uint256 _amountIn) internal returns (uint256) {
        if (_tokenIn == _tokenOut) {
            return _amountIn;
        }
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        return _getRouter(_exchange).swapExactTokensForTokens(_amountIn, 0, path, address(this), block.timestamp)[1];
    }
    
    /**
     * Swap tokens for exact amount of output tokens on a given DEX.
     *
     * @param _exchange     The exchange on which to peform the swap
     * @param _tokenIn      The address of the input token
     * @param _tokenOut     The address of the output token
     * @param _amountOut    The amount of output token required
     *
     * @return              The amount of input tokens spent
     */
    function _swapTokensForExactTokens(Exchange _exchange, address _tokenIn, address _tokenOut, uint256 _amountOut) internal returns (uint256) {
        if (_tokenIn == _tokenOut) {
            return _amountOut;
        }
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        return _getRouter(_exchange).swapTokensForExactTokens(_amountOut, PreciseUnitMath.maxUint256(), path, address(this), block.timestamp)[0];
    }
 
    /**
     * Compares the amount of token required for an exact amount of another token across both exchanges,
     * and returns the min amount.
     *
     * @param _amountOut    The amount of output token
     * @param _tokenA       The address of tokenA
     * @param _tokenB       The address of tokenB
     *
     * @return              The min amount of tokenA required across both exchanges
     * @return              The Exchange on which minimum amount of tokenA is required
     */
    function _getMinTokenForExactToken(uint256 _amountOut, address _tokenA, address _tokenB) internal view returns (uint256, Exchange) {
        if (_tokenA == _tokenB) {
            return (_amountOut, Exchange.None);
        }
        
        uint256 maxIn = PreciseUnitMath.maxUint256() ; 
        uint256 uniTokenIn = maxIn;
        uint256 sushiTokenIn = maxIn;
        
        if (_pairAvailable(uniFactory, _tokenA, _tokenB)) {
            (uint256 reserveIn, uint256 reserveOut) = UniswapV2Library.getReserves(uniFactory, _tokenA, _tokenB);
            // Prevent subtraction overflow by making sure pool reserves are greater than swap amount
            if(reserveOut > _amountOut) {
                uniTokenIn = UniswapV2Library.getAmountIn(_amountOut, reserveIn, reserveOut);
            }
        }
        
        if (_pairAvailable(sushiFactory, _tokenA, _tokenB)) {
            (uint256 reserveIn, uint256 reserveOut) = SushiswapV2Library.getReserves(sushiFactory, _tokenA, _tokenB);
            // Prevent subtraction overflow by making sure pool reserves are greater than swap amount
            if(reserveOut > _amountOut) {
                sushiTokenIn = SushiswapV2Library.getAmountIn(_amountOut, reserveIn, reserveOut);
            }
        }
        
        // Fails if both the values are maxIn
        require(!(uniTokenIn == maxIn && sushiTokenIn == maxIn), "ExchangeIssuance: ILLIQUID_SET_COMPONENT");
        return (uniTokenIn <= sushiTokenIn) ? (uniTokenIn, Exchange.Uniswap) : (sushiTokenIn, Exchange.Sushiswap);
    }
    
    /**
     * Compares the amount of token received for an exact amount of another token across both exchanges,
     * and returns the max amount.
     *
     * @param _amountIn     The amount of input token
     * @param _tokenA       The address of tokenA
     * @param _tokenB       The address of tokenB
     *
     * @return              The max amount of tokens that can be received across both exchanges
     * @return              The Exchange on which maximum amount of token can be received
     */
    function _getMaxTokenForExactToken(uint256 _amountIn, address _tokenA, address _tokenB) internal view returns (uint256, Exchange) {
        if (_tokenA == _tokenB) {
            return (_amountIn, Exchange.None);
        }
        
        uint256 uniTokenOut = 0;
        uint256 sushiTokenOut = 0;
        
        if(_pairAvailable(uniFactory, _tokenA, _tokenB)) {
            (uint256 reserveIn, uint256 reserveOut) = UniswapV2Library.getReserves(uniFactory, _tokenA, _tokenB);
            uniTokenOut = UniswapV2Library.getAmountOut(_amountIn, reserveIn, reserveOut);
        }
        
        if(_pairAvailable(sushiFactory, _tokenA, _tokenB)) {
            (uint256 reserveIn, uint256 reserveOut) = SushiswapV2Library.getReserves(sushiFactory, _tokenA, _tokenB);
            sushiTokenOut = SushiswapV2Library.getAmountOut(_amountIn, reserveIn, reserveOut);
        }
        
        // Fails if both the values are 0
        require(!(uniTokenOut == 0 && sushiTokenOut == 0), "ExchangeIssuance: ILLIQUID_SET_COMPONENT");
        return (uniTokenOut >= sushiTokenOut) ? (uniTokenOut, Exchange.Uniswap) : (sushiTokenOut, Exchange.Sushiswap); 
    }
    
    /**
     * Checks if a pair is available on the given DEX.
     *
     * @param _factory   The factory to use (can be either uniFactory or sushiFactory)
     * @param _tokenA    The address of the tokenA
     * @param _tokenB    The address of the tokenB
     *
     * @return           A boolean representing if the token is available
     */
    function _pairAvailable(address _factory, address _tokenA, address _tokenB) internal view returns (bool) {
        return IUniswapV2Factory(_factory).getPair(_tokenA, _tokenB) != address(0);
    }
    
    /**
     * Returns the router address of a given exchange.
     * 
     * @param _exchange     The Exchange whose router address is needed
     *
     * @return              IUniswapV2Router02 router of the given exchange
     */
     function _getRouter(Exchange _exchange) internal view returns(IUniswapV2Router02) {
         return (_exchange == Exchange.Uniswap) ? uniRouter : sushiRouter;
     }
    
}