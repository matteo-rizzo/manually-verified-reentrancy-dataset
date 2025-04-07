/**

 *Submitted for verification at Etherscan.io on 2019-05-01

*/



pragma solidity ^0.5.7;





// Send more than 1 ETH for 1002 Vokens, and get unused ETH refund automatically.

//   Use the current voken price of Voken Public-Sale.

//

// Conditions:

//   1. You have no Voken yet.

//   2. You are not in the whitelist yet.

//   3. Send more than 1 ETH (for balance verification).

//

// More info:

//   https://vision.network

//   https://voken.io

//

// Contact us:

//   [email protected]

//   [email protected]





/**

 * @title SafeMath for uint256

 * @dev Unsigned math operations with safety checks that revert on error.

 */







/**

 * @title Ownable

 */







/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

    bool private _paused;



    event Paused(address account);

    event Unpaused(address account);



    constructor () internal {

        _paused = false;

    }



    /**

     * @return Returns true if the contract is paused, false otherwise.

     */

    function paused() public view returns (bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused, "Paused.");

        _;

    }



    /**

     * @dev Called by a pauser to pause, triggers stopped state.

     */

    function setPaused(bool state) external onlyOwner {

        if (_paused && !state) {

            _paused = false;

            emit Unpaused(msg.sender);

        } else if (!_paused && state) {

            _paused = true;

            emit Paused(msg.sender);

        }

    }

}





/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */







/**

 * @title Voken interface

 */







/**

 * @title Voken Public-Sale interface

 */







/**

 * @title Get 1002 Voken

 */

contract Get1002Voken is Ownable, Pausable {

    using SafeMath256 for uint256;



    IVoken public VOKEN = IVoken(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);

    IVokenPublicSale public VOKEN_PUBLIC_SALE = IVokenPublicSale(0xAC873993E43A5AF7B39aB4A5a50ce1FbDb7191D3);



    uint256 private WEI_MIN = 1 ether;

    uint256 private VOKEN_PER_TXN = 1002000000; // 1002.000000 Voken



    uint256 private _txs;

    

    mapping (address => bool) _alreadyGot;



    event Tx(uint256 etherPrice, uint256 vokdnUsdPrice, uint256 weiUsed);



    /**

     * @dev Transaction counter

     */

    function txs() public view returns (uint256) {

        return _txs;

    }



    /**

     * @dev Get 1002 Voken and ETH refund.

     */

    function () external payable whenNotPaused {

        require(msg.value >= WEI_MIN);

        require(VOKEN.balanceOf(address(this)) >= VOKEN_PER_TXN);

        require(VOKEN.balanceOf(msg.sender) == 0);

        require(!VOKEN.inWhitelist(msg.sender));

        require(!_alreadyGot[msg.sender]);



        uint256 __etherPrice;

        uint256 __vokenUsdPrice;

        (__etherPrice, , , __vokenUsdPrice, , , , , , , ,) = VOKEN_PUBLIC_SALE.status();



        require(__etherPrice > 0);



        uint256 __usd = VOKEN_PER_TXN.mul(__vokenUsdPrice).div(1000000);

        uint256 __wei = __usd.mul(1 ether).div(__etherPrice);



        require(msg.value >= __wei);



        if (msg.value > __wei) {

            msg.sender.transfer(msg.value.sub(__wei));

            _receiver.transfer(__wei);

        }



        _txs = _txs.add(1);

        _alreadyGot[msg.sender] = true;

        emit Tx(__etherPrice, __vokenUsdPrice, __wei);



        assert(VOKEN.transfer(msg.sender, VOKEN_PER_TXN));

    }

}