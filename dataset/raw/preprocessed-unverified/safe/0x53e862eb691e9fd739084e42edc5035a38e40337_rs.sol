/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity 0.5.3;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title PaymentDistributor

 * @dev distributes all the received funds between project wallets and team members. 

 */

contract PaymentDistributor is Ownable {

    using SafeMath for uint256;



    event PaymentReleased(address to, uint256 amount);

    event PaymentReceived(address from, uint256 amount);



    // timestamp when fund backup release is enabled

    uint256 private _backupReleaseTime;



    uint256 private _totalReleased;

    mapping(address => uint256) private _released;



    uint256 private constant step1Fund = uint256(5000) * 10 ** 18;



    address payable private _beneficiary0;

    address payable private _beneficiary1;

    address payable private _beneficiary2;

    address payable private _beneficiary3;

    address payable private _beneficiary4;

    address payable private _beneficiaryBackup;



    /**

     * @dev Constructor

     */

    constructor (address payable beneficiary0, address payable beneficiary1, address payable beneficiary2, address payable beneficiary3, address payable beneficiary4, address payable beneficiaryBackup, uint256 backupReleaseTime) public {

        _beneficiary0 = beneficiary0;

        _beneficiary1 = beneficiary1;

        _beneficiary2 = beneficiary2;

        _beneficiary3 = beneficiary3;

        _beneficiary4 = beneficiary4;

        _beneficiaryBackup = beneficiaryBackup;

        _backupReleaseTime = backupReleaseTime;

    }



    /**

     * @dev payable fallback

     */

    function () external payable {

        emit PaymentReceived(msg.sender, msg.value);

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

     * @return the beneficiary0 of the Payments.

     */

    function beneficiary0() public view returns (address) {

        return _beneficiary0;

    }



    /**

     * @return the beneficiary1 of the Payments.

     */

    function beneficiary1() public view returns (address) {

        return _beneficiary1;

    }



    /**

     * @return the beneficiary2 of the Payments.

     */

    function beneficiary2() public view returns (address) {

        return _beneficiary2;

    }



    /**

     * @return the beneficiary3 of the Payments.

     */

    function beneficiary3() public view returns (address) {

        return _beneficiary3;

    }



    /**

     * @return the beneficiary4 of the Payments.

     */

    function beneficiary4() public view returns (address) {

        return _beneficiary4;

    }



    /**

     * @return the beneficiaryBackup of Payments.

     */

    function beneficiaryBackup() public view returns (address) {

        return _beneficiaryBackup;

    }



    /**

     * @return the time when Payments are released to the beneficiaryBackup wallet.

     */

    function backupReleaseTime() public view returns (uint256) {

        return _backupReleaseTime;

    }



    /**

     * @dev send to one of the beneficiarys' addresses.

     * @param account Whose the fund will be send to.

     * @param amount Value in wei to be sent

     */

    function sendToAccount(address payable account, uint256 amount) internal {

        require(amount > 0, 'The amount must be greater than zero.');



        _released[account] = _released[account].add(amount);

        _totalReleased = _totalReleased.add(amount);



        account.transfer(amount);

        emit PaymentReleased(account, amount);

    }



    /**

     * @dev distributes the amount between team's wallets 

     * which are created for different purposes.

     * @param amount Value in wei to send to the wallets.

     */

    function release(uint256 amount) onlyOwner public{

        require(address(this).balance >= amount, 'Balance must be greater than or equal to the amount.');

        uint256 _value = amount;

        if (_released[_beneficiary0] < step1Fund) {

            if (_released[_beneficiary0].add(_value) > step1Fund){

                uint256 _remainValue = step1Fund.sub(_released[_beneficiary0]);

                _value = _value.sub(_remainValue);

                sendToAccount(_beneficiary0, _remainValue);

            }

            else {

                sendToAccount(_beneficiary0, _value);

                _value = 0;

            }

        }



        if (_value > 0) {

            uint256 _value1 = _value.mul(10).div(100);          //10%

            uint256 _value2 = _value.mul(7020).div(10000);      //70.2%

            uint256 _value3 = _value.mul(1080).div(10000);      //10.8%

            uint256 _value4 = _value.mul(9).div(100);           //9%

            sendToAccount(_beneficiary1, _value1);

            sendToAccount(_beneficiary2, _value2);

            sendToAccount(_beneficiary3, _value3);

            sendToAccount(_beneficiary4, _value4);

        }

    }    



    /**

     * @dev transfer the amount to the beneficiaryBackup wallet

     * which are created for different purposes.

     * @param amount Value in wei to send to the backup wallet.

     */

    function releaseBackup(uint256 amount) onlyOwner public{

        require(address(this).balance >= amount, 'Balance must be greater than or equal to the amount.');

        require(block.timestamp >= backupReleaseTime(), 'The transfer is possible only 2 months after the ICO.');

        sendToAccount(_beneficiaryBackup, amount);

    }

}