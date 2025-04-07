pragma solidity 0.4.25;

// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Claimable.sol

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

// File: contracts/utils/Adminable.sol

/**
 * @title Adminable.
 */
contract Adminable is Claimable {
    address[] public adminArray;

    struct AdminInfo {
        bool valid;
        uint256 index;
    }

    mapping(address => AdminInfo) public adminTable;

    event AdminAccepted(address indexed _admin);
    event AdminRejected(address indexed _admin);

    /**
     * @dev Reverts if called by any account other than one of the administrators.
     */
    modifier onlyAdmin() {
        require(adminTable[msg.sender].valid, "caller is illegal");
        _;
    }

    /**
     * @dev Accept a new administrator.
     * @param _admin The administrator's address.
     */
    function accept(address _admin) external onlyOwner {
        require(_admin != address(0), "administrator is illegal");
        AdminInfo storage adminInfo = adminTable[_admin];
        require(!adminInfo.valid, "administrator is already accepted");
        adminInfo.valid = true;
        adminInfo.index = adminArray.length;
        adminArray.push(_admin);
        emit AdminAccepted(_admin);
    }

    /**
     * @dev Reject an existing administrator.
     * @param _admin The administrator's address.
     */
    function reject(address _admin) external onlyOwner {
        AdminInfo storage adminInfo = adminTable[_admin];
        require(adminArray.length > adminInfo.index, "administrator is already rejected");
        require(_admin == adminArray[adminInfo.index], "administrator is already rejected");
        // at this point we know that adminArray.length > adminInfo.index >= 0
        address lastAdmin = adminArray[adminArray.length - 1]; // will never underflow
        adminTable[lastAdmin].index = adminInfo.index;
        adminArray[adminInfo.index] = lastAdmin;
        adminArray.length -= 1; // will never underflow
        delete adminTable[_admin];
        emit AdminRejected(_admin);
    }

    /**
     * @dev Get an array of all the administrators.
     * @return An array of all the administrators.
     */
    function getAdminArray() external view returns (address[] memory) {
        return adminArray;
    }

    /**
     * @dev Get the total number of administrators.
     * @return The total number of administrators.
     */
    function getAdminCount() external view returns (uint256) {
        return adminArray.length;
    }
}

// File: contracts/wallet_trading_limiter/interfaces/IWalletsTradingLimiterValueConverter.sol

/**
 * @title Wallets Trading Limiter Value Converter Interface.
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


// File: contracts/wallet_trading_limiter/WalletsTradingLimiterValueConverter.sol

/**
 * Details of usage of licenced software see here: https://www.sogur.com/software/readme_v1
 */

/**
 * @title Wallets Trading Limiter Value Converter.
 */
contract WalletsTradingLimiterValueConverter is IWalletsTradingLimiterValueConverter, Adminable {
    string public constant VERSION = "1.0.1";

    using SafeMath for uint256;

    /**
     * @dev price maximum resolution.
     * @notice Allow for sufficiently-high resolution.
     * @notice Prevents multiplication-overflow.
     */
    uint256 public constant MAX_RESOLUTION = 0x10000000000000000;

    uint256 public sequenceNum = 0;
    uint256 public priceN = 0;
    uint256 public priceD = 0;

    event PriceSaved(uint256 _priceN, uint256 _priceD);
    event PriceNotSaved(uint256 _priceN, uint256 _priceD);

    /**
     * @dev Set the price.
     * @param _sequenceNum The sequence-number of the operation.
     * @param _priceN The numerator of the price.
     * @param _priceD The denominator of the price.
     */
    function setPrice(uint256 _sequenceNum, uint256 _priceN, uint256 _priceD) external onlyAdmin {
        require(1 <= _priceN && _priceN <= MAX_RESOLUTION, "price numerator is out of range");
        require(1 <= _priceD && _priceD <= MAX_RESOLUTION, "price denominator is out of range");

        if (sequenceNum < _sequenceNum) {
            sequenceNum = _sequenceNum;
            priceN = _priceN;
            priceD = _priceD;
            emit PriceSaved(_priceN, _priceD);
        }
        else {
            emit PriceNotSaved(_priceN, _priceD);
        }
    }

    /**
     * @dev Get the current limiter worth of a given SGR amount.
     * @param _sgrAmount The amount of SGR to convert.
     * @return The equivalent limiter amount.
     */
    function toLimiterValue(uint256 _sgrAmount) external view returns (uint256) {
        assert(priceN > 0 && priceD > 0);
        return _sgrAmount.mul(priceN) / priceD;
    }
}