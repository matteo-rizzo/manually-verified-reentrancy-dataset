/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/// @dev brief EIP 20 interface for contract bridges








contract BentoBridge {
    IAaveBridge immutable aave; // AAVE lending pool contract - 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
    IBentoBridge immutable bento; // BENTO token vault contract - 0xF5BCE5077908a1b7370B9ae04AdC565EBd643966

    constructor(IAaveBridge _aave, IBentoBridge _bento) public {
        _bento.registerProtocol();
        aave = _aave;
        bento = _bento;
    }

    function approveTokenBridge(IERC20[] calldata underlying, address[] calldata cToken) external {
        for (uint256 i = 0; i < underlying.length; i++) {
            underlying[i].approve(address(aave), type(uint256).max); // max approve `aave` spender to pull `underlying` from this contract
            underlying[i].approve(address(bento), type(uint256).max); // max approve `bento` spender to pull `underlying` from this contract
            underlying[i].approve(address(cToken[i]), type(uint256).max); // max approve `cToken` spender to pull `underlying` from this contract
        }
    }

    /// - AAVE - ///
    function aaveToBento(address aToken, uint256 amount) external {
        IERC20(aToken).transferFrom(msg.sender, address(this), amount);
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
        aave.withdraw(underlying, amount, address(this));
        bento.deposit(IERC20(underlying), address(this), msg.sender, amount, 0);
    }

    function aaveToBentoWithPermit(
        address aToken, uint256 amount, 
        uint8 v, bytes32 r, bytes32 s
    ) external {
        IERC20(aToken).permit(msg.sender, address(this), amount, now, v, r, s);
        IERC20(aToken).transferFrom(msg.sender, address(this), amount);
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
        aave.withdraw(underlying, amount, address(this));
        bento.deposit(IERC20(underlying), address(this), msg.sender, amount, 0);
    }

    function bentoToAave(IERC20 underlying, uint256 amount) external {
        bento.withdraw(underlying, msg.sender, address(this), amount, 0);
        aave.deposit(address(underlying), underlying.balanceOf(address(this)), msg.sender, 0); 
    }

    /// - COMPOUND - ///
    function compoundToBento(address cToken, uint256 amount) external {
        IERC20(cToken).transferFrom(msg.sender, address(this), amount);
        address underlying = ICompoundBridge(cToken).underlying();
        ICompoundBridge(cToken).redeemUnderlying(amount);
        bento.deposit(IERC20(underlying), address(this), msg.sender, amount, 0);
    }

    function bentoToCompound(address cToken, uint256 amount) external {
        address underlying = ICompoundBridge(cToken).underlying();
        bento.withdraw(IERC20(underlying), msg.sender, address(this), amount, 0);
        ICompoundBridge(cToken).mint(amount);
        IERC20(cToken).transfer(msg.sender, IERC20(cToken).balanceOf(address(this))); 
    }
}