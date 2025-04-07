/**
 *Submitted for verification at Etherscan.io on 2019-09-19
*/

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


contract AutionRecord is Ownable{

    event Join(address owner, uint256 userid, uint256 amount, uint256 round );
    event Reword(address owner, uint256 userid, uint256 amount, uint256 round);
    event Auctoin(uint256 round, uint256 amount, uint256 bgtime, uint256 edtime, uint256 num);

    function join(address owner, uint256 userid, uint256 amount, uint256 round ) external onlyOwner{
        emit Join(owner, userid, amount, round );
    }

    function reword(address owner, uint256 userid, uint256 amount, uint256 round ) external onlyOwner{
        emit Reword(owner, userid, amount, round );
    }

    function auctoin(uint256 round, uint256 amount, uint256 bgtime, uint256 edtime, uint256 num) external onlyOwner{
        emit Auctoin(round, amount, bgtime, edtime, num);
    }
}