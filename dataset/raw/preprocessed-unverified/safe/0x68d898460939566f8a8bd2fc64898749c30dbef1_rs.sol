/**

 *Submitted for verification at Etherscan.io on 2019-04-18

*/



pragma solidity ^0.5.7;



// Voken Early Investors Fund

//   Freezed till 2020-06-30 23:59:59, (timestamp 1593532799).

// 

// More info:

//   https://vision.network

//   https://voken.io

//

// Contact us:

//   [email protected]

//   [email protected]





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */







/**

 * @title Ownable

 */







/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */







/**

 * @title Voken Early Investors Fund

 */

contract VokenEarlyInvestorsFund is Ownable{

    using SafeMath for uint256;

    

    IERC20 public Voken;



    uint32 private _till = 1593532799;

    uint256 private _holdings;

    

    mapping (address => uint256) private _investors;



    event InvestorRegistered(address indexed account, uint256 amount);

    event Donate(address indexed account, uint256 amount);





    /**

     * @dev constructor

     */

    constructor() public {

        Voken = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);

    }



    /**

     * @dev Withdraw or Donate by any amount

     */

    function () external payable {

        if (now > _till && _investors[msg.sender] > 0) {

            assert(Voken.transfer(msg.sender, _investors[msg.sender]));

            _investors[msg.sender] = 0;

        }

        

        if (msg.value > 0) {

            emit Donate(msg.sender, msg.value);

        }

    }



    /**

     * @dev holdings amount

     */

    function holdings() public view returns (uint256) {

        return _holdings;

    }



    /**

     * @dev balance of the owner

     */

    function investor(address owner) public view returns (uint256) {

        return _investors[owner];

    }



    /**

     * @dev register an investor

     */

    function registerInvestor(address to, uint256 amount) external onlyOwner {

        _holdings = _holdings.add(amount);

        require(_holdings <= Voken.balanceOf(address(this)));

        _investors[to] = _investors[to].add(amount);

        emit InvestorRegistered(to, amount);

    }



    /**

     * @dev Rescue compatible ERC20 Token, except "Voken"

     *

     * @param tokenAddr ERC20 The address of the ERC20 token contract

     * @param receiver The address of the receiver

     * @param amount uint256

     */

    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {

        IERC20 _token = IERC20(tokenAddr);

        require(Voken != _token);

        require(receiver != address(0));

    

        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount);

        assert(_token.transfer(receiver, amount));

    }

}