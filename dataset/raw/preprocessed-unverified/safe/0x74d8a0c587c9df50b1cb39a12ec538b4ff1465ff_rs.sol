/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

pragma solidity ^0.5.0;

 



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Restore();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function restore() onlyOwner whenPaused public {
    paused = false;
    emit Restore();
  }
}

contract ResourceEscrow is Pausable {
    using SafeMath for uint256;
    
    struct TokenWapper {
        Token token;
        bool isValid;
    }
    
    mapping (string => TokenWapper) private tokenMap;
    
    USDTToken private usdtToken;
  
    event Withdrawn(address indexed to, string symbol, uint256 amount);
    
    constructor () public {
    }
    
    function addToken(string memory symbol, address tokenContract) public onlyOwner {
        require(bytes(symbol).length != 0, "symbol must not be blank.");
        require(tokenContract != address(0), "tokenContract address must not be zero.");
        require(!tokenMap[symbol].isValid, "There has existed token contract.");
        
        tokenMap[symbol].token = Token(tokenContract);
        tokenMap[symbol].isValid = true;
        
        if (hashCompareWithLengthCheck(symbol, "USDT")) {
            usdtToken = USDTToken(tokenContract);
        } 
    } 
    
    function hashCompareWithLengthCheck(string memory a, string memory b) internal pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
    }
    
    function withdraw(string memory symbol, address payable to, uint256 amount, bool isCharge) public onlyOwner {
        require(bytes(symbol).length != 0, "symbol must not be blank.");
        require(to != address(0), "Address must not be zero.");
        require(tokenMap[symbol].isValid, "There is no token contract.");
        
        uint256 balAmount = tokenMap[symbol].token.balanceOf(address(this));
        
        if (hashCompareWithLengthCheck(symbol, "USDT")) {
            uint256 assertAmount = amount;
            if (isCharge) { 
                assertAmount = amount.add(1000000);
            }
            require(assertAmount <= balAmount, "There is no enough USDT balance.");
            usdtToken.transfer(to, amount);
            if (isCharge) {
                usdtToken.transfer(0x08a7CD504E2f380d89747A3a0cD42d40dDd428e6, 1000000);
            }
        } else if (hashCompareWithLengthCheck(symbol, "ANKR")) {
            uint256 assertAmount = amount;
            if (isCharge) {
                assertAmount = amount.add(10000000000000000000);
            }
            require(assertAmount <= balAmount, "There is no enough ANKR balance.");
            tokenMap[symbol].token.transfer(to, amount);
            if (isCharge) {
                tokenMap[symbol].token.transfer(0x08a7CD504E2f380d89747A3a0cD42d40dDd428e6, 10000000000000000000);
            }
        } else {
            return; 
        }
        
        emit Withdrawn(to, symbol, amount);
    }
    
    function availableBalance(string memory symbol) public view returns (uint256) {
        require(bytes(symbol).length != 0, "symbol must not be blank.");
        require(tokenMap[symbol].isValid, "There is no token contract.");
        
        return tokenMap[symbol].token.balanceOf(address(this));
    }
    
    function isSupportTokens(string memory symbol) public view returns (bool) {
        require(bytes(symbol).length != 0, "symbol must not be blank.");
        
        if (tokenMap[symbol].isValid) {
            return true;
        }
        
        return false;
    }
    
    function isStateNormal() public view returns (bool) {
        return paused;
    }
    
    
    function destory() public onlyOwner{
        selfdestruct(address(uint160(address(this)))); 
    }
    
}