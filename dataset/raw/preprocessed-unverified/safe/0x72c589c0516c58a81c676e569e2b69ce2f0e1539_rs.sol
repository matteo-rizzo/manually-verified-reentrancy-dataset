/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.5.0;

/**
 * @title - PreSale DOBI Exchange PO8
 * 
 * ©°©¤©´      ©°©¤©¤©´            ©°©¤©¤©Ð©¤©Ð©¤©¤©Ð©¤©¤©´    ©°©¤©´   ©°©´
 * ©¦©à©À©Ð©Ð©¤©´  ©¦©¤©¤©à©¤©´©°©´©°©¤©´     ©¸©´©´©¦©¦©¦©°©´©À©¦©¦©¼    ©¦©Ð©à©Ð©Ð©¤©È©¸©Ð©¤©´©°©¤©Ð©Ð©¤©Ð©¤©´
 * ©¦©°©È©°©È©Ø©È  ©À©¤©¤©¦©à©¸©È©¸©È©Ø©È     ©°©Ø©¼©¦©¦©¦©°©´©À©¦©¦©´    ©¦©Ø©à©¦©È©¤©È©¦©¦©à©¸©È©¦©¦©¦©à©¦©Ø©È
 * ©¸©¼©¸©¼©¸©¤©¼  ©¸©¤©¤©Ø©¤©¤©Ø©¤©Ø©¤©¼     ©¸©¤©¤©Ø©¤©Ø©¤©¤©Ø©¤©¤©¼    ©¸©¤©Ø©Ø©Ø©¤©Ø©Ø©Ø©¤©¤©Ø©Ø©¤©à©´©À©¤©¼
 *                                                        ©¸©¤©¼
 * ---
 * POWERED BY
 *  __    ___   _     ___  _____  ___     _     ___
 * / /`  | |_) \ \_/ | |_)  | |  / / \   | |\ |  ) )
 * \_\_, |_| \  |_|  |_|    |_|  \_\_/   |_| \| _)_)
 *
 * https://skullys.co/
 **/
 
 



contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        _paused = true;
        emit Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused returns (bool) {
        _paused = false;
        emit Unpause();
        return true;
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public;
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract PreSaleDOBIExchangePO8 is Pausable {
    using SafeMath for uint256;
    ERC20 public po8Token;

    uint256 public exchangeRate; // base-on ETH/USDT value
    
    event ExchangeRateUpdated(uint256 newExchangeRate);
    event PO8Bought(address indexed buyer, uint256 ethValue, uint256 po8Receive);
    
    // Delegate constructor
    constructor(uint256 _exchangeRate, address po8Address) public {
        exchangeRate = _exchangeRate;
        ERC20 po8 = ERC20(po8Address);
        po8Token = po8;
    }
    
    function setPO8TokenContractAdress(address po8Address) external onlyOwner returns (bool) {
        ERC20 po8 = ERC20(po8Address);
        po8Token = po8;
        return true;
    }
    
    // @dev The Owner can set the new exchange rate between ETH and PO8 token.
    function setExchangeRate(uint256 _newExchangeRate) external onlyUpdater returns (uint256) {
        exchangeRate = _newExchangeRate;

        emit ExchangeRateUpdated(_newExchangeRate);

        return _newExchangeRate;
    }
    
    function buyPO8() external payable whenNotPaused {
        require(msg.value >= 1e4 wei);
        
        uint256 totalTokenTransfer = (msg.value.mul(exchangeRate)).mul(2);
        
        po8Token.transferFrom(owner, msg.sender, totalTokenTransfer);
        
        emit PO8Bought(msg.sender, msg.value, totalTokenTransfer);
    }
    
    // @dev Allows the owner to capture the balance available to the contract.
    function withdrawBalance() external onlyOwner {
        uint256 balance = address(this).balance;

        owner.transfer(balance);
    }
    
    //@dev contract prevent transfer accident ether from user.
    function () external {
        revert();
    }
    
    function getBackERC20Token(address tokenAddress) external onlyOwner {
        ERC20 token = ERC20(tokenAddress);
        token.transfer(owner, token.balanceOf(address(this)));
    }
}