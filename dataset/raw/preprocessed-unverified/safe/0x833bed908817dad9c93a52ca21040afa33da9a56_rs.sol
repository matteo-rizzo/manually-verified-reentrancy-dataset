/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

contract Unbonded is OwnableUpgradeSafe {
            
    using SafeMath for uint256;

    uint public TGE;
    uint public constant month = 30 days;
    uint constant decimals = 18;
    uint constant decMul = uint(10) ** decimals;
    
    address public communityAddress;

    uint public constant PRIVATE_POOL = 10000000 * decMul;
    uint public constant COMMUNITY_POOL = 12000000 * decMul;
    
    uint public currentPrivatePool = PRIVATE_POOL;
    uint public currentCommunityPool = COMMUNITY_POOL;
    
    IERC20 public token;
    
    mapping(address => uint) public privateWhitelist;

    constructor(address _communityAddress) public {
        __Ownable_init_unchained();

        communityAddress = _communityAddress;
    }

    /**
     * @dev Sets the Plutus ERC-20 token contract address
     */
    function setTokenContract(address _tokenAddress) public onlyOwner {
        token = IERC20(_tokenAddress);
    }

    /**
     * @dev Sets the current TGE from where the vesting period will be counted. Can be used only if TGE is zero.
     */
    function setTGE() public onlyOwner {
        require(TGE == 0, "TGE has already been set");
        TGE = now;
    }
    
    /**
     * @dev Sets each address from `addresses` as the key and each balance
     * from `balances` to the privateWhitelist. Can be used only by an owner.
     */
    function addToWhitelist(address[] memory addresses, uint[] memory balances) public onlyOwner {
        require(addresses.length == balances.length, "Invalid request length");
        
        for(uint i = 0; i < addresses.length; i++) {
            privateWhitelist[addresses[i]] = balances[i];
        }
    }
    
    /**
     * @dev claim private tokens from the contract balance.
     * `amount` means how many tokens must be claimed.
     * Can be used only by an owner or by any whitelisted person
     */
    function claimPrivateTokens(uint amount) public {
        require(privateWhitelist[msg.sender] > 0, "Sender is not whitelisted");
        require(privateWhitelist[msg.sender] >= amount, "Exceeded token amount");
        require(currentPrivatePool >= amount, "Exceeded private pool");
        
        currentPrivatePool = currentPrivatePool.sub(amount);
        
        privateWhitelist[msg.sender] = privateWhitelist[msg.sender].sub(amount);
        token.transfer(msg.sender, amount);
    }
    
    /**
     * @dev claim community tokens from the contract balance.
     * Can be used only by an owner or from communityAddress
     */
    function claimCommunityTokens() public {
        require(msg.sender == communityAddress || msg.sender == owner(), "Unauthorised sender");
        require(TGE > 0, "TGE must be set");
        
        // No vesting period
        uint amount = 0;
        if (now >= TGE  && currentCommunityPool == COMMUNITY_POOL) {
                currentCommunityPool -= 4800000*decMul;
                amount += 4800000*decMul;
        }

        if (now >= TGE + 1*month && currentCommunityPool == COMMUNITY_POOL - 4800000*decMul) {
                currentCommunityPool -= 1200000*decMul;
                amount += 1200000*decMul;
        }

        if (now >= TGE + 2*month && currentCommunityPool == COMMUNITY_POOL - 6000000*decMul) {
                currentCommunityPool -= 1200000*decMul;
                amount += 1200000*decMul;
        }

        if (now >= TGE + 3*month && currentCommunityPool == COMMUNITY_POOL - 7200000*decMul) {
                currentCommunityPool -= 1200000*decMul;
                amount += 1200000*decMul;
        }
        if (now >= TGE + 4*month && currentCommunityPool == COMMUNITY_POOL - 8400000*decMul) {
                currentCommunityPool -= 1200000*decMul;
                amount += 1200000*decMul;
        }
        if (now >= TGE + 5*month && currentCommunityPool == COMMUNITY_POOL - 9600000*decMul) {
                currentCommunityPool -= 1200000*decMul;
                amount += 1200000*decMul;
        }
        if (now >= TGE + 6*month && currentCommunityPool == COMMUNITY_POOL - 10800000*decMul) {
                currentCommunityPool -= 1200000*decMul;
                amount += 1200000*decMul;
        }
        
        // 25% each 6 months
        require(amount > 0, "nothing to claim");

        token.transfer(communityAddress, amount);
    }
}