/**

 *Submitted for verification at Etherscan.io on 2019-05-09

*/



pragma solidity 0.5.7;

pragma experimental ABIEncoderV2;





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */







/**

 * @title Faucet

 * @dev Mine Humanity tokens into Uniswap.

 */

contract Faucet {

    using SafeMath for uint;



    uint public constant BLOCK_REWARD = 1e18;

    uint public START_BLOCK = block.number;

    uint public END_BLOCK = block.number + 5000000;



    IERC20 public humanity;

    address public auction;



    uint public lastMined = block.number;



    constructor(IERC20 _humanity, address _auction) public {

        humanity = _humanity;

        auction = _auction;

    }



    function mine() public {

        uint rewardBlock = block.number < END_BLOCK ? block.number : END_BLOCK;

        uint reward = rewardBlock.sub(lastMined).mul(BLOCK_REWARD);

        humanity.transfer(auction, reward);

        lastMined = block.number;

    }

}