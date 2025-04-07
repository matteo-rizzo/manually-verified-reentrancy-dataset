/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-14
 */

// SPDX-License-Identifier: AGPL-3.0-or-later\
pragma solidity 0.7.5;

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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract ASGCirculatingSupplyContract {
    using SafeMath for uint256;

    bool public isInitialized;

    address public ASG;
    address public owner;
    address[] public nonCirculatingASGAddresses;

    constructor(address _owner) {
        owner = _owner;
    }

    function initialize(address _asg) external returns (bool) {
        require(msg.sender == owner, "caller is not owner");
        require(isInitialized == false);

        ASG = _asg;

        isInitialized = true;

        return true;
    }

    function ASGCirculatingSupply() external view returns (uint256) {
        uint256 _totalSupply = IERC20(ASG).totalSupply();

        uint256 _circulatingSupply = _totalSupply.sub(getNonCirculatingASG());

        return _circulatingSupply;
    }

    function getNonCirculatingASG() public view returns (uint256) {
        uint256 _nonCirculatingASG;

        for (
            uint256 i = 0;
            i < nonCirculatingASGAddresses.length;
            i = i.add(1)
        ) {
            _nonCirculatingASG = _nonCirculatingASG.add(
                IERC20(ASG).balanceOf(nonCirculatingASGAddresses[i])
            );
        }

        return _nonCirculatingASG;
    }

    function setNonCirculatingASGAddresses(
        address[] calldata _nonCirculatingAddresses
    ) external returns (bool) {
        require(msg.sender == owner, "Sender is not owner");
        nonCirculatingASGAddresses = _nonCirculatingAddresses;

        return true;
    }

    function transferOwnership(address _owner) external returns (bool) {
        require(msg.sender == owner, "Sender is not owner");

        owner = _owner;

        return true;
    }
}