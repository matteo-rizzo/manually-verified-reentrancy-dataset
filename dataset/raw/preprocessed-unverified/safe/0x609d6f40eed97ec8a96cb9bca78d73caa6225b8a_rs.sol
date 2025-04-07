/**

 *Submitted for verification at Etherscan.io on 2019-06-06

*/



pragma solidity 0.5.9;





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */









/**

 * @title Claimable

 * @dev Claimable contract, where the ownership needs to be claimed.

 * This allows the new owner to accept the transfer.

 */

contract Claimable {

    address public owner;

    address public pendingOwner;



    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );



    /**

    * @dev The Claimable constructor sets the original `owner` of the contract to the sender

    * account.

    */

    constructor() public {

        owner = msg.sender;

    }



    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    /**

    * @dev Modifier throws if called by any account other than the pendingOwner.

    */

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);

        _;

    }



    /**

    * @dev Allows the current owner to set the pendingOwner address.

    * @param newOwner The address to transfer ownership to.

    */

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;

    }



    /**

    * @dev Allows the pendingOwner address to finalize the transfer.

    */

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);

        owner = pendingOwner;

        pendingOwner = address(0);

    }

}



/**

* @title Keeper

*

* @dev Implements the early investors' SWG tokens locking mechanism.

* To avoid momentary dumping SWG token, the Keeper holds the early

* investor's funds frozen until unFreezeStartDate. Between unFreezeStartDate

* and totalUnFreezeDate, the contract allows holder to withdraw amount

* proportional to time passed. After totalUnFreezeDate the funds get totally

* unlocked and the early investor can spend the entire amount at any moment.

*/

contract Keeper is Claimable {

    using SafeMath for uint256;

    IERC20 public token;

    // the date when withdrawals become possible

    uint256 public unFreezeStartDate;

    // the date when all funds get unfrozen

    uint256 public totalUnFreezeDate;

    // the records about individual balances

    mapping(address => uint256) public balances;

    // the records about already withdrawn amounts

    mapping(address => uint256) public withdrawnBalances;

    // the sum of registered balance

    uint256 public totalBalance;



    constructor(

        IERC20 _token,

        uint256 _unFreezeStartDate,

        uint256 _totalUnFreezeDate

    ) public {

        // solhint-disable-next-line not-rely-on-time

        require(_unFreezeStartDate >= block.timestamp);

        require(_totalUnFreezeDate > _unFreezeStartDate);

        token = _token;

        unFreezeStartDate = _unFreezeStartDate;

        totalUnFreezeDate = _totalUnFreezeDate;

    }



    /**

     * @dev Adds the individual holder's balance

     *

     * Called by the backend of payout engine per holder (after token got transferred on the Keeper)

     */

    function addBalance(address _to, uint256 _value) public onlyOwner {

        require(_to != address(0));

        require(_value > 0);

        require(totalBalance.add(_value)

                <= token.balanceOf(address(this)), "not enough tokens");

        balances[_to] = balances[_to].add(_value);

        totalBalance = totalBalance.add(_value);

    }



    /**

     * @dev Withdraws the allowed amount of tokens

     *

     * Called by the investor through Keeper Dapp or Etherscan write interface

     */

    function withdraw(address _to, uint256 _value) public {

        require(_to != address(0));

        require(_value > 0);

        require(unFreezeStartDate < now, "not unfrozen yet");

        require(

            (getUnfrozenAmount(msg.sender).sub(withdrawnBalances[msg.sender]))

            >= _value

        );

        withdrawnBalances[msg.sender] = withdrawnBalances[msg.sender].add(_value);

        totalBalance = totalBalance.sub(_value);

        token.transfer(_to, _value);

    }



    /**

     * @dev Shows the amount of tokens allowed to withdraw

     *

     * Called by the investor through Keeper Dapp or Etherscan write interface

     */

    function getUnfrozenAmount(address _holder) public view returns (uint256) {

        if (now > unFreezeStartDate) {

            if (now > totalUnFreezeDate) {

                // tokens are totally unfrozen

                return balances[_holder];

            }

            // tokens are partially unfrozen

            uint256 partialFreezePeriodLen =

                totalUnFreezeDate.sub(unFreezeStartDate);

            uint256 secondsSincePeriodStart = now.sub(unFreezeStartDate);

            uint256 amount = balances[_holder]

                .mul(secondsSincePeriodStart)

                .div(partialFreezePeriodLen);

            return amount;

        }

        // tokens are totally frozen

        return 0;

    }

}