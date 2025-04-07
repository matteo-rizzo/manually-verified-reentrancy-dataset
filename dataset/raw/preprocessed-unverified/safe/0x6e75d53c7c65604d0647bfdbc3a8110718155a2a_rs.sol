/**

 *Submitted for verification at Etherscan.io on 2019-04-16

*/



pragma solidity ^0.5.7;



// Voken Business Fund

// 

// More info:

//   https://vision.network

//   https://voken.io

//

// Contact us:

//   [email protected]

//   [email protected]





/**

 * @title Ownable

 */







/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */







/**

 * @title Voken Business Fund

 */

contract VokenBusinessFund is Ownable{

    IERC20 public Voken;



    event Donate(address indexed account, uint256 amount);



    /**

     * @dev constructor

     */

    constructor() public {

        Voken = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);

    }



    /**

     * @dev donate

     */

    function () external payable {

        emit Donate(msg.sender, msg.value);

    }



    /**

     * @dev transfer Voken

     */

    function transferVoken(address to, uint256 amount) external onlyOwner {

        assert(Voken.transfer(to, amount));

    }



    /**

     * @dev batch transfer

     */

    function batchTransfer(address[] memory accounts, uint256[] memory values) public onlyOwner {

        require(accounts.length == values.length);

        for (uint256 i = 0; i < accounts.length; i++) {

            assert(Voken.transfer(accounts[i], values[i]));

        }

    }

}