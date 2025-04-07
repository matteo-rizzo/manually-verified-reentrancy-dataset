/**

 *Submitted for verification at Etherscan.io on 2019-03-30

*/



pragma solidity ^0.5.7;



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: eth-token-recover/contracts/TokenRecover.sol



/**

 * @title TokenRecover

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Allow to recover any ERC20 sent into the contract for error

 */

contract TokenRecover is Ownable {



    /**

     * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.

     * @param tokenAddress The token contract address

     * @param tokenAmount Number of tokens to be sent

     */

    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {

        IERC20(tokenAddress).transfer(owner(), tokenAmount);

    }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/utils/Address.sol



/**

 * Utility library of inline functions on addresses

 */





// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol



/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract TokenTimelock {

    using SafeERC20 for IERC20;



    // ERC20 basic token contract being held

    IERC20 private _token;



    // beneficiary of tokens after they are released

    address private _beneficiary;



    // timestamp when token release is enabled

    uint256 private _releaseTime;



    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {

        // solhint-disable-next-line not-rely-on-time

        require(releaseTime > block.timestamp);

        _token = token;

        _beneficiary = beneficiary;

        _releaseTime = releaseTime;

    }



    /**

     * @return the token being held.

     */

    function token() public view returns (IERC20) {

        return _token;

    }



    /**

     * @return the beneficiary of the tokens.

     */

    function beneficiary() public view returns (address) {

        return _beneficiary;

    }



    /**

     * @return the time when the tokens are released.

     */

    function releaseTime() public view returns (uint256) {

        return _releaseTime;

    }



    /**

     * @notice Transfers tokens held by timelock to beneficiary.

     */

    function release() public {

        // solhint-disable-next-line not-rely-on-time

        require(block.timestamp >= _releaseTime);



        uint256 amount = _token.balanceOf(address(this));

        require(amount > 0);



        _token.safeTransfer(_beneficiary, amount);

    }

}



// File: contracts/MBMTimelock.sol



/**

 * @title MBMTimelock

 * @dev Extends from TokenTimelock which is a token holder contract that will allow a

 *  beneficiary to extract the tokens after a given release time

 */

contract MBMTimelock is TokenTimelock {



    // A text string to add a note

    string private _note;



    /**

     * @param token Address of the token being distributed

     * @param beneficiary Who will receive the tokens after they are released

     * @param releaseTime Timestamp when token release is enabled

     * @param note A text string to add a note

     */

    constructor(

        IERC20 token,

        address beneficiary,

        uint256 releaseTime,

        string memory note

    )

        public

        TokenTimelock(token, beneficiary, releaseTime)

    {

        _note = note;

    }



    /**

     * @return the timelock note.

     */

    function note() public view returns (string memory) {

        return _note;

    }

}



// File: contracts/MBMLockBuilder.sol



/**

 * @title MBMLockBuilder

 * @dev This contract will allow a owner to create new MBMTimelock

 */

contract MBMLockBuilder is TokenRecover {

    using SafeERC20 for IERC20;



    event LockCreated(address indexed timelock, address indexed beneficiary, uint256 releaseTime, uint256 amount);



    // ERC20 basic token contract being held

    IERC20 private _token;



    /**

     * @param token Address of the token being distributed

     */

    constructor(IERC20 token) public {

        require(address(token) != address(0));



        _token = token;

    }



    /**

     * @param beneficiary Who will receive the tokens after they are released

     * @param releaseTime Timestamp when token release is enabled

     * @param amount The number of tokens to be locked for this contract

     * @param note A text string to add a note

     */

    function createLock(

        address beneficiary,

        uint256 releaseTime,

        uint256 amount,

        string calldata note

    )

        external

        onlyOwner

    {

        MBMTimelock lock = new MBMTimelock(_token, beneficiary, releaseTime, note);



        emit LockCreated(address(lock), beneficiary, releaseTime, amount);



        if (amount > 0) {

            _token.safeTransfer(address(lock), amount);

        }

    }



    /**

     * @return the token being held.

     */

    function token() public view returns (IERC20) {

        return _token;

    }

}