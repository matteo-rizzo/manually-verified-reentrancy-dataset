/**

 *Submitted for verification at Etherscan.io on 2019-03-01

*/



pragma solidity ^0.5.4;



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

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */





/**

 * @title MultiBeneficiariesTokenTimelock

 * @dev MultiBeneficiariesTokenTimelock is a token holder contract that will allow a

 * beneficiaries to extract the tokens after a given release time

 */

contract MultiBeneficiariesTokenTimelock {

    using SafeERC20 for IERC20;



    // ERC20 basic token contract being held

    IERC20 public token;



    // beneficiary of tokens after they are released

    address[] public beneficiaries;

    

    // token amounts of beneficiaries to be released

    uint256[] public tokenValues;



    // timestamp when token release is enabled

    uint256 public releaseTime;

    

    //Whether tokens have been distributed

    bool public distributed;



    constructor(

        IERC20 _token,

        address[] memory _beneficiaries,

        uint256[] memory _tokenValues,

        uint256 _releaseTime

    )

    public

    {

        require(_releaseTime > block.timestamp);

        releaseTime = _releaseTime;

        require(_beneficiaries.length == _tokenValues.length);

        beneficiaries = _beneficiaries;

        tokenValues = _tokenValues;

        token = _token;

        distributed = false;

    }



    /**

     * @notice Transfers tokens held by timelock to beneficiaries.

     */

    function release() public {

        require(block.timestamp >= releaseTime);

        require(!distributed);



        for (uint256 i = 0; i < beneficiaries.length; i++) {

            address beneficiary = beneficiaries[i];

            uint256 amount = tokenValues[i];

            require(amount > 0);

            token.safeTransfer(beneficiary, amount);

        }

        

        distributed = true;

    }

    

    /**

     * Returns the time remaining until release

     */

    function getTimeLeft() public view returns (uint256 timeLeft){

        if (releaseTime > block.timestamp) {

            return releaseTime - block.timestamp;

        }

        return 0;

    }

    

    /**

     * Reject ETH 

     */

    function() external payable {

        revert();

    }

}