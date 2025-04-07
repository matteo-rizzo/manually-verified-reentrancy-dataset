// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenSale is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    address payable public contributionAddress;
    uint256 public minimumPurchase;
    uint256 public maximumPurchase;
    uint256 public tokenPerEther;
    uint256 public tokenDecimal;
    
    constructor() {
        token = IERC20(0x2E6E152d29053B6337E434bc9bE17504170f8a5B);
        contributionAddress = 0xddff4999ba44dDd10dE81BbEDeA36bEDd306e341;
        minimumPurchase = 0.5 ether;
        maximumPurchase = 10 ether;
        tokenDecimal = 10 ** 18;
        tokenPerEther = tokenDecimal.mul(20);
    }
    
    receive() external payable {
        buyToken();
    }
    
    function buyToken() public payable {
        uint256 etherAmount = msg.value;
        address payable investor = _msgSender();
    
        require(etherAmount >= minimumPurchase, "Amount received is less than minimum purchase allowed");
        require(etherAmount <= maximumPurchase, "Amount received exceeds maximum purchase allowed");
        
        uint256 totalToken = calculateTotalBuy(etherAmount);
        
        require(token.balanceOf(address(this)) >= totalToken, "Token balance is not enough for exchange");
        token.transfer(investor, totalToken);
        contributionAddress.transfer(etherAmount);
    }
    
    function calculateTotalBuy(uint256 _amount) internal view returns(uint256) {
        return _amount.mul(tokenPerEther).div(tokenDecimal);
    }
    
    function setTokenPerEther(uint256 _amount) external onlyOwner {
        tokenPerEther = _amount;
    }
    
    function setContributionAddress(address payable _address) external onlyOwner {
        contributionAddress = _address;
    }
    
    function setMinimumPurchase(uint256 _value) external onlyOwner {
        minimumPurchase = _value;
    }
    
    function setMaximumPurchase(uint256 _value) external onlyOwner {
        maximumPurchase = _value;
    }
    
    function setDecimals(uint256 _decimal) external onlyOwner {
        tokenDecimal = 10 ** _decimal;
    }
    
    function setTokenContract(IERC20 _token) external onlyOwner {
        token = _token;
    }
    
    function setSaleDetails(IERC20 _token, uint256 _decimal, uint256 _amountPerEther, uint256 _minimumPurchase, uint256 _maximumPurchase, address payable _address) external onlyOwner {
        token = _token;
        tokenDecimal = 10 ** _decimal;
        tokenPerEther = _amountPerEther;
        minimumPurchase = _minimumPurchase;
        maximumPurchase = _maximumPurchase;
        contributionAddress = _address;
    }
    
    function withdrawEther() external onlyOwner {
        uint256 balance = address(this).balance;
        
        require(balance > 0, "Balance is zero");
        
        address payable _owner = payable(owner());
        _owner.transfer(balance);
    }
    
    function withdrawToken(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        
        require(balance > 0, "Not enough token balance");
    
        _token.transfer(owner(), balance);
    } 
}