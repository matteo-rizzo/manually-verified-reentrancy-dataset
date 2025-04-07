/**

 *Submitted for verification at Etherscan.io on 2019-05-06

*/



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title BlockportDistributor

 * @dev This contract can be used to distribute ether to multiple addresses

 * at once. 

 */

contract BlockportDistributor {

    using SafeMath for uint256;



    event Distributed(address payable[] receivers, uint256 amount);



    /**

     * @dev Constructor

     */

    constructor () public {

    }



    /**

     * @dev payable fallback

     * dont accept pure ether: revert it.

     */

    function () external payable {

        revert();

    }



    /**

     * @dev distribute function, note that enough ether must be send (receivers.length * amount)

     * @param receivers Addresses who should all receive amount.

     * @param amount amount to distribute to each address, in wei.

     * @return bool success

     */

    function distribute(address payable[] calldata receivers, uint256 amount) external payable returns (bool success) {

        require(amount.mul(receivers.length) == msg.value);



        for (uint256 i = 0; i < receivers.length; i++) {

            receivers[i].transfer(amount);

        }

        emit Distributed(receivers, amount);

        return true;

    }

}