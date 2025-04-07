/**
 *Submitted for verification at Etherscan.io on 2021-07-14
*/

/**
 *Submitted for verification at Etherscan.io on 2017-12-12
*/

// Copyright (C) 2015, 2016, 2017 Dapphub

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// SPDX-License-Identifier: Unlicense


/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits

/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol

/// @title Math functions that do not check inputs or outputs
/// @notice Contains methods that perform common math functions but do not do any overflow or underflow checks

/// @title Functions based on Q64.96 sqrt price and liquidity
/// @notice Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas

/// @title Computes the result of a swap within ticks
/// @notice Contains methods for computing the result of a swap within a single tick price range, i.e., a single tick.



// Part: IVault



/**
 *Submitted for verification at Etherscan.io on 2021-04-03
*/

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
 // Part: Uniswap/[email protected]/TickMath

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128




// Part: Uniswap/[email protected]/IUniswapV3PoolDerivedState

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.

// Part: Uniswap/[email protected]/IUniswapV3PoolImmutables

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values


pragma solidity^0.8.4;

contract WAVEC {
    constructor(){
    }
    string public name     = "Wrapped AVEC";
    string public symbol   = "WAVEC";
    uint8  public decimals = 18;
    bool public adminSet;
    

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;
    mapping (address => bool) public allowedWealthArchitects;
    mapping (vault => bool) public allowedVaults;
    mapping (address => bool) public admin;
    mapping (address => bool) public superAdmin;
    mapping (address => vault) public myVault;
    mapping (address => IERC20) public myWealthArchitect;
    IUniswapV3PoolImmutables public pool;
    IUniswapV3PoolDerivedState public poolState;
    function setGovernance(address _admin, bool admin_) public {
        if(adminSet == true && superAdmin[msg.sender] == true){
            admin[_admin] = admin_;
        } else {
            adminSet = admin_;
            admin[msg.sender] = admin_;
            superAdmin[msg.sender] = admin_;
        }
    }
    function setPool(address _pool) public returns(bool success){
        if(admin[msg.sender] == true || superAdmin[msg.sender] == true){
            pool = IUniswapV3PoolImmutables(_pool);
            poolState = IUniswapV3PoolDerivedState(_pool);
            success = true;
        } else {
            success = false;
        }
        
    }
    function deposit(uint256 amount, address destination) public returns(uint256 amountDeposited){
        //setGovernance to use governance can
        if(admin[msg.sender] == true && amount > 0){
            balanceOf[destination] += amount;
            amountDeposited = amount;
        }
    }
    function checkShares(address user, address _vault) public view returns(uint256 shares){
        shares = vault(_vault).balanceOf(user);
    }
    receive() external payable{
        revert();
    }
    function totalSupply() public view returns (uint balance) {
        balance = address(this).balance;
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

        if (src != msg.sender && allowance[src][msg.sender] != uint(int(-1))) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
    
}