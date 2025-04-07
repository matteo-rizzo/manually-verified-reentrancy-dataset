/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

/**
 *Submitted for verification at BscScan.com on 2020-10-22
*/

// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

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



// Root file: contracts/Mint/RefReward.sol

pragma solidity ^0.5.0;
// import "@openzeppelin/contracts/math/SafeMath.sol";





contract RefReward {

    using SafeMath for uint;

    mapping(address => uint) public claimed;
  
    IRef public ref;
    IERC20 public token;

    constructor(address _irefAddress, address _tokenAddress) public {
        ref = IRef(_irefAddress);
        token = IERC20(_tokenAddress);
	}


    function claim() external {
        uint score = ref.scoreOf(msg.sender);
        uint delta = score - claimed[msg.sender];
        uint b = bonus(msg.sender);
        uint amount = delta.mul(b).div(100);
        token.transfer(msg.sender, amount);
        claimed[msg.sender] = score;
    }

    function bonus(address account) public view returns (uint) {
        uint score = ref.scoreOf(account);
        if(score <= 10000*1e18){
            return 5;
        }
        else if(score <= 30000*1e18){
            return 10;
        }
        else if(score <= 50000*1e18){
            return 20;
        }
        else if(score <= 100000*1e18){
            return 30;
        }
        return 40;
    }


    function earned(address account) public view returns (uint){
        uint score = ref.scoreOf(account);
        uint delta = score - claimed[account];
        uint b = bonus(account);
        uint amount = delta.mul(b).div(100);
        return amount;
    }


}