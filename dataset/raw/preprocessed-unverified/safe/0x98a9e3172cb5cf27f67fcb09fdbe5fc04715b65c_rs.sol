/**

 *Submitted for verification at Etherscan.io on 2018-09-26

*/



pragma solidity 0.4.24;



// File: contracts/ZTXInterface.sol



contract ZTXInterface {

    function transferOwnership(address _newOwner) public;

    function mint(address _to, uint256 amount) public returns (bool);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function unpause() public;

}



// File: zeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/ZTXOwnershipHolder.sol



/**

 * @title ZTXOwnershipHolder - Sole responsibility is to hold and transfer ZTX ownership

 * @author Gustavo Guimaraes - <[email protected]>

 * @author Timo Hedke - <[email protected]>

 */

contract ZTXOwnershipHolder is Ownable {



      /**

     * @dev Constructor for the airdrop contract

     * @param _ztx ZTX contract address

     * @param newZuluOwner New ZTX owner address

     */

    function transferZTXOwnership(address _ztx, address newZuluOwner) external onlyOwner{

        ZTXInterface(_ztx).transferOwnership(newZuluOwner);

    }

}