// SPDX-License-Identifier: MIT

/*
MIT License

Copyright (c) 2020 Rebased

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity 0.5.17;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title Rebased Swap Contract V1 -> V2
 */
contract RebasedSwap is Ownable {
    using SafeMath for uint256;
    
    IERC20 rebasedv1;
    IERC20 rebasedv2;

    uint256 private constant DECIMALS = 9;
    uint256 private constant v1Supply = 1907412747493439;
    
    uint256 end;
    bool public active;
    
    modifier isActive {
        require(active);
        _;
    }
    
    constructor(address _v1, address _v2) public {
        rebasedv1 = IERC20(_v1);
        rebasedv2 = IERC20(_v2);
        end = block.timestamp.add(30 days);
    }
    
    function setActive(bool _active) external onlyOwner() {
        active = _active;
    }
    
    function getReb2OutputAmount(uint256 amount) public view returns (uint256) {
        
        uint256 v2Supply = rebasedv2.totalSupply();
        
        // Adjust for new LP rewards fund which accounts for ~8.4% of the supply
        uint256 correctedSupply = v2Supply.mul(v1Supply).div(2082412747493439);
        return amount.mul(correctedSupply).div(v1Supply);
    }

    function swap(uint256 amount) external isActive {
        require(rebasedv1.transferFrom(msg.sender, address(this), amount), "Transferring REB from user failed");
        
        uint256 _amount = getReb2OutputAmount(amount);
        
        require(rebasedv2.transfer(msg.sender, _amount), "Unable to transfer REB2 to user");
    }
    
    function skim(address to, uint256 amount) external onlyOwner {
        require(block.timestamp > end);
        
        rebasedv2.transfer(to, amount);
    }    

}