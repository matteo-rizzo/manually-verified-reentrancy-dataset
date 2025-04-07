/**

 *Submitted for verification at Etherscan.io on 2019-05-09

*/



pragma solidity 0.5.4;





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */



/**

* @title interface of ERC 20 token

* 

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



contract TokenVesting is Ownable{

    

    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    

    struct VestedToken{

        uint256 cliff;

        uint256 start;

        uint256 duration;

        uint256 releasedToken;

        uint256 totalToken;

        bool revoked;

    }

    

    mapping (address => VestedToken) public vestedUser; 

    

    // default Vesting parameter values

    uint256 private _cliff = 2592000; // 30 days period

    uint256 private _duration = 93312000; // for 3 years

    bool private _revoked = false;

    

    IERC20 public LCXToken;

    

    event TokenReleased(address indexed account, uint256 amount);

    event VestingRevoked(address indexed account);

    

    /**

     * @dev Its a modifier in which we authenticate the caller is owner or LCXToken Smart Contract

     */ 

    modifier onlyLCXTokenAndOwner() {

        require(msg.sender==owner() || msg.sender == address(LCXToken));

        _;

    }

    

    /**

     * @dev First we have to set token address before doing any thing 

     * @param token LCX Smart contract Address

     */

     

    function setTokenAddress(IERC20 token) public onlyOwner returns(bool){

        LCXToken = token;

        return true;

    }

    

    /**

     * @dev this will set the beneficiary with default vesting 

     * parameters ie, every month for 3 years

     * @param account address of the beneficiary for vesting

     * @param amount  totalToken to be vested

     */

     

     function setDefaultVesting(address account, uint256 amount) public onlyLCXTokenAndOwner returns(bool){

         _setDefaultVesting(account, amount);

         return true;

     }

     

     /**

      *@dev Internal function to set default vesting parameters

      */

      

     function _setDefaultVesting(address account, uint256 amount)  internal {

         require(account!=address(0));

         VestedToken storage vested = vestedUser[account];

         vested.cliff = _cliff;

         vested.start = block.timestamp;

         vested.duration = _duration;

         vested.totalToken = amount;

         vested.releasedToken = 0;

         vested.revoked = _revoked;

     }

     

     

     /**

     * @dev this will set the beneficiary with vesting 

     * parameters provided

     * @param account address of the beneficiary for vesting

     * @param amount  totalToken to be vested

     * @param cliff In seconds of one period in vesting

     * @param duration In seconds of total vesting 

     * @param startAt UNIX timestamp in seconds from where vesting will start

     */

     

     function setVesting(address account, uint256 amount, uint256 cliff, uint256 duration, uint256 startAt ) public onlyLCXTokenAndOwner  returns(bool){

         _setVesting(account, amount, cliff, duration, startAt);

         return true;

     }

     

     /**

      * @dev Internal function to set default vesting parameters

      * @param account address of the beneficiary for vesting

      * @param amount  totalToken to be vested

      * @param cliff In seconds of one period in vestin

      * @param duration In seconds of total vesting duration

      * @param startAt UNIX timestamp in seconds from where vesting will start

      *

      */

     

     function _setVesting(address account, uint256 amount, uint256 cliff, uint256 duration, uint256 startAt) internal {

         

         require(account!=address(0));

         require(cliff<=duration);

         VestedToken storage vested = vestedUser[account];

         vested.cliff = cliff;

         vested.start = startAt;

         vested.duration = duration;

         vested.totalToken = amount;

         vested.releasedToken = 0;

         vested.revoked = false;

     }



    /**

     * @notice Transfers vested tokens to beneficiary.

     * anyone can release their token 

     */

     

    function releaseMyToken() public returns(bool) {

        releaseToken(msg.sender);

        return true;

    }

    

     /**

     * @notice Transfers vested tokens to the given account.

     * @param account address of the vested user

     */

    function releaseToken(address account) public {

       require(account != address(0));

       VestedToken storage vested = vestedUser[account];

       uint256 unreleasedToken = _releasableAmount(account);  // total releasable token currently

       require(unreleasedToken>0);

       vested.releasedToken = vested.releasedToken.add(unreleasedToken);

       LCXToken.safeTransfer(account,unreleasedToken);

       emit TokenReleased(account, unreleasedToken);

    }

    

    /**

     * @dev Calculates the amount that has already vested but hasn't been released yet.

     * @param account address of user

     */

    function _releasableAmount(address account) internal view returns (uint256) {

        return _vestedAmount(account).sub(vestedUser[account].releasedToken);

    }



  

    /**

     * @dev Calculates the amount that has already vested.

     * @param account address of the user

     */

    function _vestedAmount(address account) internal view returns (uint256) {

        VestedToken storage vested = vestedUser[account];

        uint256 totalToken = vested.totalToken;

        if(block.timestamp <  vested.start.add(vested.cliff)){

            return 0;

        }else if(block.timestamp >= vested.start.add(vested.duration) || vested.revoked){

            return totalToken;

        }else{

            uint256 numberOfPeriods = (block.timestamp.sub(vested.start)).div(vested.cliff);

            return totalToken.mul(numberOfPeriods.mul(vested.cliff)).div(vested.duration);

        }

    }

    

    /**

     * @notice Allows the owner to revoke the vesting. Tokens already vested

     * remain in the contract, the rest are returned to the owner.

     * @param account address in which the vesting is revoked

     */

    function revoke(address account) public onlyOwner {

        VestedToken storage vested = vestedUser[account];

        require(!vested.revoked);

        uint256 balance = vested.totalToken;

        uint256 unreleased = _releasableAmount(account);

        uint256 refund = balance.sub(unreleased);

        vested.revoked = true;

        vested.totalToken = unreleased;

        LCXToken.safeTransfer(owner(), refund);

        emit VestingRevoked(account);

    }

    

    

    

    

}