/**
 *Submitted for verification at Etherscan.io on 2021-07-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */








contract YITZU {
    BasicTokenLib.Xrc20Token private xrc20Token;
    using BasicTokenLib for BasicTokenLib.Xrc20Token;

    constructor(){
        xrc20Token.initialize(0x5DB357308BB38d74093272f9F8F2A2F52A66374D, "YITZU", "YZU", 18, 1000000000000000, "", "");
        xrc20Token.mint(msg.sender, 1000000000);
    }

    receive() external virtual payable { } 

    fallback() external virtual payable {  }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return xrc20Token.name();
    }

    function symbol() public view virtual  returns (string memory) {
        return xrc20Token.symbol();
    }

    function decimals() public view virtual  returns (uint8) {
        return xrc20Token.decimals();
    }

    function totalSupply() public view virtual  returns (uint256) {
        return xrc20Token.totalSupply();
    }

    function balanceOf(address account) public view virtual  returns (uint256) {
        return xrc20Token.balanceOf(account);
    }

    function burn(address _who, uint256 _value) public virtual returns (bool) 
    {
        return xrc20Token.burn(_who, _value);
    }

    function transfer(address recipient, uint256 amount) public virtual  returns (bool) {
        return xrc20Token.transfer(recipient, amount);
    }

    function allowance(address owner, address spender) public view virtual  returns (uint256) {
        return xrc20Token.allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) public virtual  returns (bool) {
        return xrc20Token.approve(spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual  returns (bool) {
        return xrc20Token.transferFrom(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        return xrc20Token.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        return xrc20Token.decreaseAllowance(spender, subtractedValue);
    }
}