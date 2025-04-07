// Created By BitDNS.vip
// contact : Presale Pool
// SPDX-License-Identifier: MIT

pragma solidity ^0.5.8;

// File: @openzeppelin/contracts/math/SafeMath.sol
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


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// File: @openzeppelin/contracts/utils/Address.sol
/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract PresalePool {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 public presale_token;
    IERC20 public currency_token;
    
    uint256 public totalSupply;
    uint256 public price;
    bool public canBuy;
    bool public canSell;
    uint256 public minBuyAmount = 1000 ether;
    uint256 constant PRICE_UNIT = 1e8;   
    mapping(address => uint256) public balanceOf;
    address private governance;

    event Buy(address indexed user, uint256 token_amount, uint256 currency_amount, bool send);
    event Sell(address indexed user, uint256 token_amount, uint256 currency_amount);
    
    constructor () public {
        governance = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == governance, "!governance");
        _;
    }

    function start(address _presale_token, address _currency_token, uint256 _price) public onlyOwner {
        require(_presale_token != address(0), "Token is non-contract");
        require(_presale_token != address(0) && _presale_token.isContract(), "Subscribe stoken is non-contract");
        require(_currency_token != address(0), "Token is non-contract");
        require(_currency_token != address(0) && _currency_token.isContract(), "Currency token is non-contract");

        presale_token = IERC20(_presale_token);
        currency_token = IERC20(_currency_token);
        price = _price;
        canBuy = true;
        canSell = false;
    }

    function buy(uint256 token_amount) public {
        require(canBuy, "Buy not start yet, please wait...");
        require(token_amount >= minBuyAmount, "Subscribe amount must be larger than 1000");
        //require(token_amount <= presale_token.balanceOf(address(this)), "The subscription quota is insufficient");
        
        uint256 currency_amount = token_amount * price / PRICE_UNIT;
        currency_token.safeTransferFrom(msg.sender, address(this), currency_amount);
        totalSupply = totalSupply.add(token_amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(token_amount);
        if (token_amount <= presale_token.balanceOf(address(this)))
        {
            presale_token.safeTransfer(msg.sender, token_amount);
        }
        
        emit Buy(msg.sender, token_amount, currency_amount, token_amount <= presale_token.balanceOf(address(this)));
    }

    function sell(uint256 token_amount) public {
        require(canSell, "Not end yet, please wait...");
        require(token_amount > 0, "Sell amount must be larger than 0");
        require(token_amount <= balanceOf[msg.sender], "Token balance is not enough");
        require(token_amount <= totalSupply, "Token balance is larger than totalSupply");
        
        uint256 currency_amount = token_amount * price / PRICE_UNIT;
        currency_token.safeTransfer(msg.sender, currency_amount);
        presale_token.safeTransferFrom(msg.sender, address(this), token_amount);
        totalSupply = totalSupply.sub(token_amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(token_amount);
        
        emit Sell(msg.sender, token_amount, currency_amount);
    }

    function end() public onlyOwner {
        canBuy = false;
        canSell = true;
    }

    function finish() public onlyOwner {
        canBuy = false;
        canSell = false;
    }

    function getback(address account) public onlyOwner {
        uint256 leftPresale = presale_token.balanceOf(address(this));
        if (leftPresale > 0) {
            presale_token.safeTransfer(account, leftPresale);
        }
        uint256 leftCurrency = currency_token.balanceOf(address(this));
        if (leftCurrency > 0) {
            currency_token.safeTransfer(account, leftCurrency);
        }
    }

    function setMinBuyAmount(uint256 amount) public onlyOwner {
        minBuyAmount = amount;
    }
}