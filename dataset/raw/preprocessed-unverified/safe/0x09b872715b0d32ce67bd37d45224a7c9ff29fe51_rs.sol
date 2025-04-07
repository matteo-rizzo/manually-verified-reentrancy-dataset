/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



pragma solidity ^0.5.8;



// Voken Airdrop Fund

//   Keep your ETH balance > (...)

//      See https://voken.io/en/latest/token/airdrop_via_contract.html

//

//   And call this contract (send 0 ETH here),

//   and you will receive 100-200 VNET Tokens immediately.

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

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */







/**

 * @title Voken Airdrop

 */

contract VokenAirdrop is Ownable {

    using SafeMath for uint256;



    IERC20 public Voken;



    uint256 private _wei_min;



    mapping(address => bool) public _airdopped;



    event Donate(address indexed account, uint256 amount);



    /**

     * @dev constructor

     */

    constructor() public {

        Voken = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);

    }



    /**

     * @dev receive ETH and send Vokens

     */

    function () external payable {

        require(_airdopped[msg.sender] != true);

        require(msg.sender.balance >= _wei_min);



        uint256 balance = Voken.balanceOf(address(this));

        require(balance > 0);



        uint256 vokenAmount = 100;

        vokenAmount = vokenAmount.add(uint256(keccak256(abi.encode(now, msg.sender, now))) % 100).mul(10 ** 6);

        

        if (vokenAmount <= balance) {

            assert(Voken.transfer(msg.sender, vokenAmount));

        } else {

            assert(Voken.transfer(msg.sender, balance));

        }

        

        if (msg.value > 0) {

            emit Donate(msg.sender, msg.value);

        }

    }



    /**

     * @dev set wei min

     */

    function setWeiMin(uint256 value) external onlyOwner {

        _wei_min = value;

    }

}