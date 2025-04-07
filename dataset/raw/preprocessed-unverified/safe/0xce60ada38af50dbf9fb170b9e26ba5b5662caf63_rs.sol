/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

/**
 *Submitted for verification at Etherscan.io on 2020-06-21
*/

pragma solidity ^0.5.16;

/**
*
* VOMER.net
*
**/

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
        require(initializing || isConstructor() || !initialized);

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

contract ERC20Token
{
    function decimals() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}




/**
 * @dev Collection of functions related to the address type,
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */





contract OldShareholderVomer {
    function getInfo(address investor) view public returns (uint256 totalFunds, uint256 pendingReward, uint256 totalProfit, uint256 contractBalance);
}



contract ShareholderVomer
{
    function getTokenRate(address token) view public returns (uint256);
    function addDepositTokens(address[] calldata userAddress, uint256[] calldata amountTokens) external;
    function setupRef(address userAddress, address refAddress) external;
}

contract ExchangeVMR is Initializable
{
    using SafeMath for uint256;
    using UniversalERC20 for ERC20Token;

    address payable public owner;
    address payable public newOwnerCandidate;

    address tokenAddressETH;
    ShareholderVomer main;
    uint256 tokenMaxAmount;

    mapping(address => bool) public admins;

    uint256 minEthAmount;

    uint256 public fundsLockedtoWithdraw;
    uint256 public dateUntilFundsLocked;

    modifier onlyOwner()
    {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyAdminOrOwner()
    {
        assert(msg.sender == owner || admins[msg.sender]);
        _;
    }

    function initialize() initializer public {
//        tokenAddressETH = address(0x0000000000000000000000000000000000000000);
//        main = ShareholderVomer(0xE1f5c6FD86628E299955a84f44E2DFCA47aAaaa4);
//        minEthAmount = 0.01 ether;
//        owner = 0xBeEF483F3dbBa7FC428ebe37060e5b9561219E3d;
    }

    // function changeTokenAddressEth(address _newTokenAddressETH) onlyOwner public {
    //    tokenAddressETH = _newTokenAddressETH;
    // }

    function setMinEthAmount(uint256 _newMinEthAmountInWei) onlyAdminOrOwner public {
        minEthAmount = _newMinEthAmountInWei;
    }
    function setTotalMaxAmount(uint256 _newMaxAmountInWei) onlyAdminOrOwner public {
        tokenMaxAmount = _newMaxAmountInWei;
    }

    function setAdmin(address newAdmin, bool activate) onlyOwner public {
        admins[newAdmin] = activate;
    }

    function withdraw(uint256 amount)  public onlyOwner {
        if (dateUntilFundsLocked > now) require(address(this).balance.sub(amount) > fundsLockedtoWithdraw);
        owner.transfer(amount);
    }

    function changeOwnerCandidate(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
    }

    // function for transfer any token from contract
    function transferTokens (address token, address target, uint256 amount) onlyOwner public
    {
        ERC20Token(token).universalTransfer(target, amount);
    }

    event TokensSent(address indexed target, uint256 amount);
    
    uint256 public tokenRate;
    
    function setTokenRate(uint256 _newTokenRateInInteger) onlyAdminOrOwner public {
        tokenRate = _newTokenRateInInteger;
    }
    
    function calcAmountTokens(uint256 amountEther) view public returns (uint256) {
        require(tokenRate != 0, "Token rate not set");
        return amountEther.mul(tokenRate);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {
        assembly {
            addr := mload(add(bys,20))
        }
    }

    function () payable external
    {
        require(msg.sender == tx.origin); // prevent bots to interact with contract

        if (msg.sender == owner) return;

        require(msg.value >= minEthAmount && msg.value > 0, "Min amount ether required");

        uint256 amountTokens = calcAmountTokens(msg.value);
        require(amountTokens < tokenMaxAmount, "Tokens amount overflow");

        uint256[] memory tokens = new uint256[](1);
        tokens[0] = amountTokens;
        address[] memory addresses = new address[](1);
        addresses[0] = address(msg.sender);
        main.addDepositTokens(addresses, tokens);
        emit TokensSent(msg.sender, amountTokens);

        if (msg.data.length == 20) {
            address refAddress = bytesToAddress(msg.data);
            main.setupRef(msg.sender, refAddress);
        }
    }
}