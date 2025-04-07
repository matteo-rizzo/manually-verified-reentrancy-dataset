/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity ^0.6.12;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/
contract RewardsDistribution is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public rewardsToken;

    address[] public distributions;
    mapping(address => uint) public shares;

    event RewardDistributionAdded(uint index, address distribution, uint shares);
    event RewardDistributionUpdated(address distribution, uint shares);
    event RewardsDistributed(uint amount);

    modifier onlyRewardsToken() {
        require(msg.sender == address(rewardsToken) || msg.sender == owner(), "onlyRewardsToken");
        _;
    }

    constructor(address _rewardsToken) public {
        rewardsToken = _rewardsToken;
    }

    function addRewardDistribution(address _distribution, uint _shares) external onlyOwner {
        require(_distribution != address(0), "distribution");
        require(shares[_distribution] == 0, "shares");

        distributions.push(_distribution);
        shares[_distribution] = _shares;
        emit RewardDistributionAdded(distributions.length - 1, _distribution, _shares);
    }

    function updateRewardDistribution(address _distribution, uint _shares) public onlyOwner {
        require(_distribution != address(0), "distribution");
        require(_shares > 0, "shares");

        shares[_distribution] = _shares;
        emit RewardDistributionUpdated(_distribution, _shares);
    }

    function removeRewardDistribution(uint index) external onlyOwner {
        require(index <= distributions.length - 1, "index");

        delete shares[distributions[index]];
        delete distributions[index];
    }

    function distributeRewards(uint amount) external onlyRewardsToken returns (bool) {
        require(rewardsToken != address(0), "rewardsToken");
        require(amount > 0, "amount");
        require(IERC20(rewardsToken).balanceOf(address(this)) >= amount, "balance");

        uint remainder = amount;
        for (uint i = 0; i < distributions.length; i++) {
            address distribution = distributions[i];
            uint amountOfShares = sharesOf(distribution, amount);

            if (distribution != address(0) && amountOfShares != 0) {
                remainder = remainder.sub(amountOfShares);

                IERC20(rewardsToken).transfer(distribution, amountOfShares);
                bytes memory payload = abi.encodeWithSignature("notifyRewardAmount(uint256)", amountOfShares);
                distribution.call(payload);
            }
        }

        emit RewardsDistributed(amount);
        return true;
    }

    function totalShares() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < distributions.length; i++) {
            total = total.add(shares[distributions[i]]);
        }
        return total;
    }

    function sharesOf(address _distribution, uint _amount) public view returns (uint) {
        uint _totalShares = totalShares();
        if (_totalShares == 0) return 0;

        return _amount.mul(shares[_distribution]).div(_totalShares);
    }
}