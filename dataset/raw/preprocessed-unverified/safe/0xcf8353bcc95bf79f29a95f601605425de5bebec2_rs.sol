/**
 *Submitted for verification at Etherscan.io on 2021-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
// License-Identifier: MIT



// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT



/// @notice Interface for AAVE deposit and withdraw.


/// @notice Interface for BENTO deposit and withdraw.


/// @notice Interface for COMPOUND deposit and withdraw.


/// @notice Interface for DAI deposit via `permit()` primitive.


/// @notice Contract to bridge underlying defi tokens and BENTO.
contract BentoBridge {
    using BoringERC20 for IERC20;

    IAaveBridge immutable aave; // AAVE lending contract - 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
    IBentoBridge immutable bento; // BENTO vault contract - 0xF5BCE5077908a1b7370B9ae04AdC565EBd643966
    address immutable dai; // DAI token contract - 0x6B175474E89094C44Da98b954EedeAC495271d0F

    constructor(IAaveBridge _aave, IBentoBridge _bento, address _dai) public {
        _bento.registerProtocol();
        aave = _aave;
        bento = _bento;
        dai = _dai;
    }

    function approveTokenBridge(IERC20[] calldata underlying, address[] calldata cToken) external {
        for (uint256 i = 0; i < underlying.length; i++) {
            underlying[i].approve(address(aave), type(uint256).max); // max approve `aave` spender to pull `underlying` from this contract
            underlying[i].approve(address(bento), type(uint256).max); // max approve `bento` spender to pull `underlying` from this contract
            underlying[i].approve(cToken[i], type(uint256).max); // max approve `cToken` spender to pull `underlying` from this contract
        }
    }

    /// - AAVE - ///
    function aaveToBento(address aToken, uint256 amount) external {
        IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount);
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
        aave.withdraw(underlying, amount, address(this));
        bento.deposit(IERC20(underlying), address(this), msg.sender, amount, 0);
    }

    function aaveToBentoWithPermit(
        address aToken, uint256 amount, uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        IERC20(aToken).permit(msg.sender, address(this), amount, deadline, v, r, s);
        IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount);
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
        aave.withdraw(underlying, amount, address(this));
        bento.deposit(IERC20(underlying), address(this), msg.sender, amount, 0);
    }

    function bentoToAave(IERC20 underlying, uint256 amount) external {
        bento.withdraw(underlying, msg.sender, address(this), amount, 0);
        aave.deposit(address(underlying), amount, msg.sender, 0); 
    }

    /// - COMPOUND/CREAM - ///
    function compoundToBento(address cToken, uint256 cTokenAmount) external {
        IERC20(cToken).safeTransferFrom(msg.sender, address(this), cTokenAmount);
        IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying());
        ICompoundBridge(cToken).redeem(cTokenAmount);
        bento.deposit(underlying, address(this), msg.sender, underlying.balanceOf(address(this)), 0);
    }

    function bentoToCompound(address cToken, uint256 underlyingAmount) external {
        IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying());
        bento.withdraw(underlying, msg.sender, address(this), underlyingAmount, 0);
        ICompoundBridge(cToken).mint(underlyingAmount);
        IERC20(cToken).safeTransfer(msg.sender, IERC20(cToken).balanceOf(address(this))); 
    }

    /// - DAI - ///
    function daiToBentoWithPermit(
        uint256 amount, uint256 nonce, uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        IDaiPermit(dai).permit(msg.sender, address(this), nonce, deadline, true, v, r, s);
        IERC20(dai).safeTransferFrom(msg.sender, address(this), amount);
        bento.deposit(IERC20(dai), address(this), msg.sender, amount, 0);
    }
}