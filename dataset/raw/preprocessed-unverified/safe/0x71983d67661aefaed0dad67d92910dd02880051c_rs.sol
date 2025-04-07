/**

 *Submitted for verification at Etherscan.io on 2019-07-18

*/



pragma solidity 0.4.24;



// IPCO Token Pool



















contract TokenPool is ITokenPool, Ownable {

    using SafeMath for uint256;



    IERC20 public token;

    bool public completed = false;



    mapping(uint128 => uint256) private balances;

    uint256 public allocated = 0;



    event FundsAllocated(uint128 indexed account, uint256 value);

    event FundsWithdrawn(uint128 indexed account, address indexed to, uint256 value);



    constructor(address tokenAddress) public {

        token = IERC20(tokenAddress);

    }



    /**

     * @return The balance of the account in pool

     */

    function balanceOf(uint128 account) public view returns (uint256) {

        return balances[account];

    }



    /**

     * Token allocation function

     * @dev should be called after every token deposit to allocate these token to the account

     */

    function allocate(uint128 account, uint256 value) public onlyOwner {

        require(!completed, "Pool is already completed");

        assert(unallocated() >= value);

        allocated = allocated.add(value);

        balances[account] = balances[account].add(value);

        emit FundsAllocated(account, value);

    }



    /**

     * Allows withdrawal of tokens and dividends from temporal storage to the wallet

     * @dev transfers corresponding amount of dividend in ETH

     */

    function withdraw(uint128 account, address to, uint256 value) public onlyOwner {

        balances[account] = balances[account].sub(value);

        uint256 balance = address(this).balance;

        uint256 dividend = balance.mul(value).div(allocated);

        allocated = allocated.sub(value);

        token.transfer(to, value);

        if (dividend > 0) {

            to.transfer(dividend);

        }

        emit FundsWithdrawn(account, to, value);

    }



    /**

     * Concludes allocation of tokens and serves as a drain for unallocated tokens

     */

    function complete() public onlyOwner {

        completed = true;

        token.transfer(msg.sender, unallocated());

    }



    /**

     * Fallback function enabling deposit of dividends in ETH

     * @dev dividend has to be deposited only after pool completion, as additional token

     *      allocations after the deposit would skew shares

     */

    function () public payable {

        require(completed, "Has to be completed first");

    }



    /**

     * @return Amount of unallocated tokens in the pool

     */

    function unallocated() internal view returns (uint256) {

        return token.balanceOf(this).sub(allocated);

    }

}