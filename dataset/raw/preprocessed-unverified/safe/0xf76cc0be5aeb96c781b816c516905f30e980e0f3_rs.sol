/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-04
*/

/**
 * Source Code first verified at https://etherscan.io on Friday, July 20, 2018
 (UTC) */

pragma solidity ^0.4.26;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2дл.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancy_lock);
    reentrancy_lock = true;
    _;
    reentrancy_lock = false;
  }

}

/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 */





contract STMPackage is Ownable, ReentrancyGuard {
    using ECRecovery for bytes32;

    //mapping(bytes32 => Deal) public streamityTransfers;

    //constructor(address streamityContract) public {
    //    require(streamityContract != 0x0); 
    //}

    //struct Deal {
    //    uint256 value;
    //}

    event MultiTransfer(
        address _to,
        uint _amount
    );

    event BuyPackage(bytes32 _tradeId);
    
    function pay(bytes32 _tradeID, uint256 _value, bytes _sign) 
    external 
    payable 
    {
        require(msg.value > 0);
        require(msg.value == _value);
        bytes32 _hashDeal = keccak256(_tradeID,  msg.value);
        verifyDeal(_hashDeal, _sign);
        emit BuyPackage(_tradeID);
    }

    function verifyDeal(bytes32 _hashDeal, bytes _sign) private view {
        require(_hashDeal.recover(_sign) == owner); 
    }

    function withdrawToAddress(address _to, uint256 _amount) external onlyOwner {
        _to.transfer(_amount);
    }
    
    function multiTransfer(address[] _addresses, uint[] _amounts)
    external onlyOwner
    returns(bool)
    {
        for (uint i = 0; i < _addresses.length; i++) {
            _safeTransfer(_addresses[i], _amounts[i]);
            emit MultiTransfer(_addresses[i], _amounts[i]);
        }
        return true;
    }
    
    function _safeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.transfer(_amount);
    }
}