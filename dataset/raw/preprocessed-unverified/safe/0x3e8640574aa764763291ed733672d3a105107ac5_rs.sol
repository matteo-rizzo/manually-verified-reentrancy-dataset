/**

 *Submitted for verification at Etherscan.io on 2018-11-24

*/



pragma solidity 0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/ownership/Claimable.sol



/**

 * @title Claimable

 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.

 * This allows the new owner to accept the transfer.

 */

contract Claimable is Ownable {

  address public pendingOwner;



  /**

   * @dev Modifier throws if called by any account other than the pendingOwner.

   */

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);

    _;

  }



  /**

   * @dev Allows the current owner to set the pendingOwner address.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol



/**

 * @title Contracts that should be able to recover tokens

 * @author SylTi

 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.

 * This will prevent any accidental loss of tokens.

 */

contract CanReclaimToken is Ownable {

  using SafeERC20 for ERC20Basic;



  /**

   * @dev Reclaim all ERC20Basic compatible tokens

   * @param _token ERC20Basic The address of the token contract

   */

  function reclaimToken(ERC20Basic _token) external onlyOwner {

    uint256 balance = _token.balanceOf(this);

    _token.safeTransfer(owner, balance);

  }



}



// File: contracts/utils/OwnableContract.sol



// empty block is used as this contract just inherits others.

contract OwnableContract is CanReclaimToken, Claimable { } /* solhint-disable-line no-empty-blocks */



// File: contracts/utils/IndexedMapping.sol







// File: contracts/factory/MembersInterface.sol







// File: contracts/factory/Members.sol



contract Members is MembersInterface, OwnableContract {



    address public custodian;



    using IndexedMapping for IndexedMapping.Data;

    IndexedMapping.Data internal merchants;



    constructor(address _owner) public {

        require(_owner != address(0), "invalid _owner address");

        owner = _owner;

    }



    event CustodianSet(address indexed custodian);



    function setCustodian(address _custodian) external onlyOwner returns (bool) {

        require(_custodian != address(0), "invalid custodian address");

        custodian = _custodian;



        emit CustodianSet(_custodian);

        return true;

    }



    event MerchantAdd(address indexed merchant);



    function addMerchant(address merchant) external onlyOwner returns (bool) {

        require(merchant != address(0), "invalid merchant address");

        require(merchants.add(merchant), "merchant add failed");



        emit MerchantAdd(merchant);

        return true;

    } 



    event MerchantRemove(address indexed merchant);



    function removeMerchant(address merchant) external onlyOwner returns (bool) {

        require(merchant != address(0), "invalid merchant address");

        require(merchants.remove(merchant), "merchant remove failed");



        emit MerchantRemove(merchant);

        return true;

    }



    function isCustodian(address addr) external view returns (bool) {

        return (addr == custodian);

    }



    function isMerchant(address addr) external view returns (bool) {

        return merchants.exists(addr);

    }



    function getMerchant(uint index) external view returns (address) {

        return merchants.getValue(index);

    }



    function getMerchants() external view returns (address[]) {

        return merchants.getValueList();

    }

}