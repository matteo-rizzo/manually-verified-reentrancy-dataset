/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

/**
 * @dev Collection of functions related to the address type
 */



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

contract YENc is Initializable {
    string public constant name = "YEN Coin";
    string public constant symbol = "YENC";
    string public constant version = "1";
    uint8 public constant decimals = 18;

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    mapping(address => bool) public admins;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    uint256 private totalSupply_;

    modifier onlyAdmins() {
        require(admins[msg.sender] == true, "yenc/only-admin");
        _;
    }

    function initialize(uint256 _initialSupply) public initializer {
        totalSupply_ = _initialSupply;
        balances[msg.sender] = totalSupply_;
        admins[msg.sender] = true;
    }

    function isAdmin(address _address) public view returns (bool) {
        return admins[_address];
    }

    function addAdmin(address _address) public onlyAdmins {
        admins[_address] = true;
    }

    function removeAdmin(address _address) public onlyAdmins {
        require(msg.sender != _address, "yenc/self-remove");
        admins[_address] = false;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender], "yenc/excessive-transfer");

        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[owner], "yenc/excessive-transferFrom");
        require(numTokens <= allowed[owner][msg.sender], "yenc/above-allowance");

        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;
        balances[buyer] = balances[buyer] + numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function mint(address account, uint256 value) public onlyAdmins returns (bool) {
        require(account != address(0));

        totalSupply_ = totalSupply_ + value;
        balances[account] = balances[account] + value;
        emit Transfer(address(0), account, value);
        return true;
    }

    function burn(address account, uint256 value) public onlyAdmins returns (bool) {
        require(account != address(0));

        totalSupply_ = totalSupply_ - value;
        balances[account] = balances[account] - value;
        emit Transfer(account, address(0), value);
        return true;
    }
}