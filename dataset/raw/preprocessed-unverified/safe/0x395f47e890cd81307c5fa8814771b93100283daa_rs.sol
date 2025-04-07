/**

 *Submitted for verification at Etherscan.io on 2019-01-15

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/helpers/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions". This adds two-phase

 * ownership control to OpenZeppelin's Ownable class. In this model, the original owner 

 * designates a new owner but does not actually transfer ownership. The new owner then accepts 

 * ownership and completes the transfer.

 */





// File: contracts/token/dataStorage/AllowanceSheet.sol



/**

* @title AllowanceSheet

* @notice A wrapper around an allowance mapping. 

*/

contract AllowanceSheet is Ownable {

    using SafeMath for uint256;



    mapping (address => mapping (address => uint256)) public allowanceOf;



    function addAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].add(_value);

    }



    function subAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].sub(_value);

    }



    function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = _value;

    }

}



// File: contracts/token/dataStorage/BalanceSheet.sol



/**

* @title BalanceSheet

* @notice A wrapper around the balanceOf mapping. 

*/

contract BalanceSheet is Ownable {

    using SafeMath for uint256;



    mapping (address => uint256) public balanceOf;

    uint256 public totalSupply;



    function addBalance(address _addr, uint256 _value) public onlyOwner {

        balanceOf[_addr] = balanceOf[_addr].add(_value);

    }



    function subBalance(address _addr, uint256 _value) public onlyOwner {

        balanceOf[_addr] = balanceOf[_addr].sub(_value);

    }



    function setBalance(address _addr, uint256 _value) public onlyOwner {

        balanceOf[_addr] = _value;

    }



    function addTotalSupply(uint256 _value) public onlyOwner {

        totalSupply = totalSupply.add(_value);

    }



    function subTotalSupply(uint256 _value) public onlyOwner {

        totalSupply = totalSupply.sub(_value);

    }



    function setTotalSupply(uint256 _value) public onlyOwner {

        totalSupply = _value;

    }

}



// File: contracts/token/dataStorage/TokenStorage.sol



/**

* @title TokenStorage

*/

contract TokenStorage {

    /**

        Storage

    */

    BalanceSheet public balances;

    AllowanceSheet public allowances;





    string public name;   //name of Token                

    uint8  public decimals;        //decimals of Token        

    string public symbol;   //Symbol of Token



    /**

    * @dev a TokenStorage consumer can set its storages only once, on construction

    *

    **/

    constructor (address _balances, address _allowances, string _name, uint8 _decimals, string _symbol) public {

        balances = BalanceSheet(_balances);

        allowances = AllowanceSheet(_allowances);



        name = _name;

        decimals = _decimals;

        symbol = _symbol;

    }



    /**

    * @dev claim ownership of balance sheet passed into constructor.

    **/

    function claimBalanceOwnership() public {

        balances.claimOwnership();

    }



    /**

    * @dev claim ownership of allowance sheet passed into constructor.

    **/

    function claimAllowanceOwnership() public {

        allowances.claimOwnership();

    }

}



// File: zos-lib/contracts/upgradeability/Proxy.sol



/**

 * @title Proxy

 * @dev Implements delegation of calls to other contracts, with proper

 * forwarding of return values and bubbling of failures.

 * It defines a fallback function that delegates all calls to the address

 * returned by the abstract _implementation() internal function.

 */

contract Proxy {

  /**

   * @dev Fallback function.

   * Implemented entirely in `_fallback`.

   */

  function () payable external {

    _fallback();

  }



  /**

   * @return The Address of the implementation.

   */

  function _implementation() internal view returns (address);



  /**

   * @dev Delegates execution to an implementation contract.

   * This is a low level function that doesn't return to its internal call site.

   * It will return to the external caller whatever the implementation returns.

   * @param implementation Address to delegate.

   */

  function _delegate(address implementation) internal {

    assembly {

      // Copy msg.data. We take full control of memory in this inline assembly

      // block because it will not return to Solidity code. We overwrite the

      // Solidity scratch pad at memory position 0.

      calldatacopy(0, 0, calldatasize)



      // Call the implementation.

      // out and outsize are 0 because we don't know the size yet.

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)



      // Copy the returned data.

      returndatacopy(0, 0, returndatasize)



      switch result

      // delegatecall returns 0 on error.

      case 0 { revert(0, returndatasize) }

      default { return(0, returndatasize) }

    }

  }



  /**

   * @dev Function that is run as the first thing in the fallback function.

   * Can be redefined in derived contracts to add functionality.

   * Redefinitions must call super._willFallback().

   */

  function _willFallback() internal {

  }



  /**

   * @dev fallback implementation.

   * Extracted to enable manual triggering.

   */

  function _fallback() internal {

    _willFallback();

    _delegate(_implementation());

  }

}



// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */





// File: zos-lib/contracts/upgradeability/UpgradeabilityProxy.sol



/**

 * @title UpgradeabilityProxy

 * @dev This contract implements a proxy that allows to change the

 * implementation address to which it will delegate.

 * Such a change is called an implementation upgrade.

 */

contract UpgradeabilityProxy is Proxy {

  /**

   * @dev Emitted when the implementation is upgraded.

   * @param implementation Address of the new implementation.

   */

  event Upgraded(address implementation);



  /**

   * @dev Storage slot with the address of the current implementation.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is

   * validated in the constructor.

   */

  bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;



  /**

   * @dev Contract constructor.

   * @param _implementation Address of the initial implementation.

   */

  constructor(address _implementation) public {

    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));



    _setImplementation(_implementation);

  }



  /**

   * @dev Returns the current implementation.

   * @return Address of the current implementation

   */

  function _implementation() internal view returns (address impl) {

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {

      impl := sload(slot)

    }

  }



  /**

   * @dev Upgrades the proxy to a new implementation.

   * @param newImplementation Address of the new implementation.

   */

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);

    emit Upgraded(newImplementation);

  }



  /**

   * @dev Sets the implementation address of the proxy.

   * @param newImplementation Address of the new implementation.

   */

  function _setImplementation(address newImplementation) private {

    require(AddressUtils.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");



    bytes32 slot = IMPLEMENTATION_SLOT;



    assembly {

      sstore(slot, newImplementation)

    }

  }

}



// File: contracts/token/TokenProxy.sol



/**

* @title TokenProxy

* @notice A proxy contract that serves the latest implementation of TokenProxy.

*/

contract TokenProxy is UpgradeabilityProxy, TokenStorage, Ownable {

    constructor(address _implementation, address _balances, address _allowances, string _name, uint8 _decimals, string _symbol) 

    UpgradeabilityProxy(_implementation) 

    TokenStorage(_balances, _allowances, _name, _decimals, _symbol) public {

    }



    /**

    * @dev Upgrade the backing implementation of the proxy.

    * Only the admin can call this function.

    * @param newImplementation Address of the new implementation.

    */

    function upgradeTo(address newImplementation) public onlyOwner {

        _upgradeTo(newImplementation);

    }



    /**

    * @return The address of the implementation.

    */

    function implementation() public view returns (address) {

        return _implementation();

    }

}