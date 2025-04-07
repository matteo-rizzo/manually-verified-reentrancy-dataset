/**
 *Submitted for verification at Etherscan.io on 2021-02-16
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: IStrategy



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: SharerV3.sol

//for version 0.3.1 or above of base strategy

contract SharerV3 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    event ContributorsSet(address indexed strategy, address[] contributors, uint256[] numOfShares);
    event Distribute(address indexed strategy, uint256 totalDistributed);

    struct Contributor {
        address contributor;
        uint256 numOfShares;
    }
    mapping(address => Contributor[]) public shares;
    address public strategistMs;
    address public pendingStrategistMs;


    constructor() public {
        strategistMs = msg.sender;
    }

    function changeStratMs(address _ms) external {
        require(msg.sender == strategistMs);
        pendingStrategistMs = _ms;
    }

    function acceptStratMs() external {
        require(msg.sender == pendingStrategistMs);
        strategistMs = pendingStrategistMs;
    }

    function viewContributors(address strategy) public view returns (Contributor[] memory){
       return shares[strategy];
    }

    // Contributors for a strategy are set all at once, not on individual basis.
    // Initialization of contributors list for any strategy can be done by anyone. Afterwards, only Strategist MS can call this
    // If sum of total shares set < 1,000, any remainder of shares will go to strategist multisig
    function setContributors(address strategy, address[] calldata _contributors, uint256[] calldata _numOfShares) public {
        require(_contributors.length == _numOfShares.length, "length not the same");

        require(shares[strategy].length == 0 || msg.sender == strategistMs, "Only Strat MS can overwrite");

        delete shares[strategy];
        uint256 totalShares = 0;

        for(uint256 i = 0; i < _contributors.length; i++ ){
            totalShares = totalShares.add(_numOfShares[i]);
            shares[strategy].push(Contributor(_contributors[i], _numOfShares[i]));
        }
        require(totalShares <= 1000, "share total more than 100%");
        emit ContributorsSet(strategy, _contributors, _numOfShares);
    }


    function distribute(address _strategy) public{
        IStrategy strategy = IStrategy(_strategy);
        IERC20 reward =  IERC20(strategy.vault());
        
        uint256 totalRewards = reward.balanceOf(_strategy);
        if(totalRewards <= 1000){
           return;
        }
        uint256 remainingRewards = totalRewards;

        Contributor[] memory contributorsT = shares[_strategy];
        for(uint256 i = 0; i < contributorsT.length; i++ ){
                address cont = contributorsT[i].contributor;
                uint256 share = totalRewards.mul(contributorsT[i].numOfShares).div(1000);
                reward.safeTransferFrom(_strategy, cont, share);
                remainingRewards -= share;
        }
        reward.safeTransferFrom(_strategy, strategistMs, remainingRewards);
        emit Distribute(_strategy, totalRewards);
    }

    function checkBalance(address _strategy) public view returns(uint256){
        IStrategy strategy = IStrategy(_strategy);
        IERC20 reward =  IERC20(strategy.vault());
        return reward.balanceOf(_strategy);
    }
}