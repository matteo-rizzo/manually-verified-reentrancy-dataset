/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity 0.5.3;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title TokenDistributor

 * @dev This contract is a token holder contract that will 

 * allow beneficiaries to release the tokens in ten six-months period intervals.

 */

contract TokenDistributor is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    event TokensReleased(address account, uint256 amount);



    // ERC20 basic token contract being held

    IERC20 private _token;



    // timestamp when token release is enabled

    uint256 private _releaseTime;



    uint256 private _totalReleased;

    mapping(address => uint256) private _released;



    // beneficiary of tokens that are released

    address private _beneficiary1;

    address private _beneficiary2;

    address private _beneficiary3;

    address private _beneficiary4;



    uint256 public releasePerStep = uint256(1000000) * 10 ** 18;



    /**

     * @dev Constructor

     */

    constructor (IERC20 token, uint256 releaseTime, address beneficiary1, address beneficiary2, address beneficiary3, address beneficiary4) public {

        _token = token;

        _releaseTime = releaseTime;

        _beneficiary1 = beneficiary1;

        _beneficiary2 = beneficiary2;

        _beneficiary3 = beneficiary3;

        _beneficiary4 = beneficiary4;

    }



    /**

     * @return the token being held.

     */

    function token() public view returns (IERC20) {

        return _token;

    }



    /**

     * @return the total amount already released.

     */

    function totalReleased() public view returns (uint256) {

        return _totalReleased;

    }



    /**

     * @return the amount already released to an account.

     */

    function released(address account) public view returns (uint256) {

        return _released[account];

    }



    /**

     * @return the beneficiary1 of the tokens.

     */

    function beneficiary1() public view returns (address) {

        return _beneficiary1;

    }



    /**

     * @return the beneficiary2 of the tokens.

     */

    function beneficiary2() public view returns (address) {

        return _beneficiary2;

    }



    /**

     * @return the beneficiary3 of the tokens.

     */

    function beneficiary3() public view returns (address) {

        return _beneficiary3;

    }



    /**

     * @return the beneficiary4 of the tokens.

     */

    function beneficiary4() public view returns (address) {

        return _beneficiary4;

    }



    /**

     * @return the time when the tokens are released.

     */

    function releaseTime() public view returns (uint256) {

        return _releaseTime;

    }



    /**

     * @dev Release one of the beneficiary's tokens.

     * @param account Whose tokens will be sent to.

     * @param amount Value in wei to send to the account.

     */

    function releaseToAccount(address account, uint256 amount) internal {

        require(amount != 0, 'The amount must be greater than zero.');



        _released[account] = _released[account].add(amount);

        _totalReleased = _totalReleased.add(amount);



        _token.safeTransfer(account, amount);

        emit TokensReleased(account, amount);

    }



    /**

     * @notice Transfers 1000000 tokens in each interval(six-months timelocks) to beneficiaries.

     */

    function release() onlyOwner public {

        require(block.timestamp >= releaseTime(), 'Teamï¿½s tokens can be released every six months.');



        uint256 _value1 = releasePerStep.mul(10).div(100);      //10%

        uint256 _value2 = releasePerStep.mul(68).div(100);      //68%

        uint256 _value3 = releasePerStep.mul(12).div(100);      //12%

        uint256 _value4 = releasePerStep.mul(10).div(100);      //10%



        _releaseTime = _releaseTime.add(180 days);



        releaseToAccount(_beneficiary1, _value1);

        releaseToAccount(_beneficiary2, _value2);

        releaseToAccount(_beneficiary3, _value3);

        releaseToAccount(_beneficiary4, _value4);

    }

}