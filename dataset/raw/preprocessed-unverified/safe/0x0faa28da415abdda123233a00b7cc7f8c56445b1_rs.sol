/**

 *Submitted for verification at Etherscan.io on 2018-12-11

*/



pragma solidity 0.4.25;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/Vesting.sol



/**

 * @title Vesting

 * @dev Vesting is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract Vesting is Ownable {

    using SafeERC20 for IERC20;

    using SafeMath for uint256;



    // ERC20 basic token contract being held

    IERC20 private _token;



    // Info holds all the relevant information to calculate the right amount for `release`

    struct Info {

        bool    known;          // Logs whether or not the address is known and eligible to receive tokens

        uint256 totalAmount;    // Total amount of tokens to receive

        uint256 receivedAmount; // Amount of tokens already received

        uint256 startTime;      // Starting time of vesting

        uint256 releaseTime;    // End time of vesting

    }



    // Mapping of an address to it's information

    mapping(address => Info) private _info;



    constructor(

        IERC20 token

    )

        public

    {

        _token = token;

    }

    

    /**

     * @notice Add beneficiaries to the contract, allowing them to withdraw tokens.

     * @param beneficiary The address associated with the beneficiary.

     * @param releaseTime The timestamp at which 100% of their allocation is freed up.

     * @param amount The amount of tokens they can receive in total.

     */

    function addBeneficiary(

        address beneficiary,

        uint256 startTime,

        uint256 releaseTime,

        uint256 amount

    )

        external

        onlyOwner

    {

        Info storage info = _info[beneficiary];

        require(!info.known, "This address is already known to the contract.");

        require(releaseTime > startTime, "Release time must be later than the start time.");

        require(releaseTime > block.timestamp, "End of vesting period must be somewhere in the future.");



        info.startTime = startTime; // Set starting time

        info.totalAmount = amount; // Set amount

        info.releaseTime = releaseTime; // Set release time

        info.known = true; // Prevent overwriting of address data

    }



    /**

     * @notice Remove a beneficiary from the contract, preventing them from 

     * retrieving tokens in the future.

     * @param beneficiary The address associated with the beneficiary.

     */

    function removeBeneficiary(address beneficiary) external onlyOwner {

        Info storage info = _info[beneficiary];

        require(info.known, "The address you are trying to remove is unknown to the contract");



        _release(beneficiary); // Release leftover tokens before removing the investor

        info.known = false;

        info.totalAmount = 0;

        info.receivedAmount = 0;

        info.startTime = 0;

        info.releaseTime = 0;

    }



    /**

     * @notice Withdraw tokens from the contract. This function is strictly

     * for the owner, intended to take out any leftovers if needed.

     * @param amount The amount of tokens to take out.

     */

    function withdraw(uint256 amount) external onlyOwner {

        _token.safeTransfer(owner(), amount);

    }



    /**

     * @notice Transfers tokens held by timelock to beneficiary.

     * This function will check if a caller is eligible to receive tokens

     * and if so, will then call the internal `_release` function.

     */

    function release() external {

        require(_info[msg.sender].known, "You are not eligible to receive tokens from this contract.");

        _release(msg.sender);

    }



    /**

     * @notice Simple function to return vesting information for a caller.

     * Callers can then validate if their information has been properly stored,

     * instead of trusting the contract owner.

     */

    function check() external view returns (uint256, uint256, uint256, uint256) {

        return (

            _info[msg.sender].totalAmount, 

            _info[msg.sender].receivedAmount,

            _info[msg.sender].startTime, 

            _info[msg.sender].releaseTime

        );

    }



    /**

     * @notice Internal function to release tokens to a beneficiary.

     * This function has been extended from the `release` function included in

     * `TokenTimelock.sol` included in the OpenZeppelin-solidity library, to allow

     * for a 'second-by-second' token vesting schedule. Since block timestamps

     * is the closest Solidity can get to reading the current time, this

     * mechanism is used.

     */

    function _release(address beneficiary) internal {

        Info storage info = _info[beneficiary];

        if (block.timestamp >= info.releaseTime) {

            uint256 remainingTokens = info.totalAmount.sub(info.receivedAmount);

            require(remainingTokens > 0, "No tokens left to take out.");



            // Since `safeTransfer` will throw upon failure, we can modify the state beforehand.

            info.receivedAmount = info.totalAmount;

            _token.safeTransfer(beneficiary, remainingTokens);

        } else if (block.timestamp > info.startTime) {

            // Calculate allowance

            uint256 diff = info.releaseTime.sub(info.startTime);

            uint256 tokensPerTick = info.totalAmount.div(diff);

            uint256 ticks = block.timestamp.sub(info.startTime);

            uint256 tokens = tokensPerTick.mul(ticks);

            uint256 receivableTokens = tokens.sub(info.receivedAmount);

            require(receivableTokens > 0, "No tokens to take out right now.");



            // Since `safeTransfer` will throw upon failure, we can modify the state beforehand.

            info.receivedAmount = info.receivedAmount.add(receivableTokens);

            _token.safeTransfer(beneficiary, receivableTokens);

        } else {

            // We could let SafeMath revert release calls if vesting has not started yet.

            // However, in the interest of clarity to contract callers, this error

            // message is added instead.

            revert("This address is not eligible to receive tokens yet.");

        }

    }

}