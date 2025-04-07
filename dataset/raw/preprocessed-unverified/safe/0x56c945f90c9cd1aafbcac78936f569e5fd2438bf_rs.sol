/**

 *Submitted for verification at Etherscan.io on 2018-12-10

*/



pragma solidity ^0.4.24;



// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: lib/CanReclaimToken.sol



/**

 * @title Contracts that should be able to recover tokens

 * @author SylTi

 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.

 * This will prevent any accidental loss of tokens.

 */

contract CanReclaimToken is Ownable {



  /**

   * @dev Reclaim all ERC20 compatible tokens

   * @param token ERC20 The address of the token contract

   */

  function reclaimToken(IERC20 token) external onlyOwner {

    if (address(token) == address(0)) {

      owner().transfer(address(this).balance);

      return;

    }

    uint256 balance = token.balanceOf(this);

    token.transfer(owner(), balance);

  }



}



// File: contracts/HeroUp.sol













contract HeroUp is Ownable, CanReclaimToken {

  event HeroUpgraded(uint tokenId, address owner);



  HEROES_OLD public heroesOld;

  HEROES_NEW public heroesNew;

  constructor (HEROES_OLD _heroesOld, HEROES_NEW _heroesNew) public {

    require(address(_heroesOld) != address(0));

    require(address(_heroesNew) != address(0));

    heroesOld = _heroesOld;

    heroesNew = _heroesNew;

  }



  function() public {}



  function setOld(HEROES_OLD _heroesOld) public onlyOwner {

    require(address(_heroesOld) != address(0));

    heroesOld = _heroesOld;

  }



  function setNew(HEROES_NEW _heroesNew) public onlyOwner {

    require(address(_heroesNew) != address(0));

    heroesNew = _heroesNew;

  }



  function upgrade(uint _tokenId) public {

    require(msg.sender == heroesOld.ownerOf(_tokenId));

    uint256 genes;

    uint32 level;

    uint256 lockedTo;

    uint16 lockId;



    //transfer old hero

    (genes,,,,,,level,lockedTo,lockId) = heroesOld.getCharacter(_tokenId);

    heroesOld.unlock(_tokenId, lockId);

    heroesOld.lock(_tokenId, 0, 999);

    heroesOld.transferFrom(msg.sender, address(this), _tokenId);

//    heroesOld.unlock(_tokenId, 999);



    //mint new hero

    heroesNew.mint(_tokenId, msg.sender, genes, level);



    emit HeroUpgraded(_tokenId, msg.sender);

  }

}