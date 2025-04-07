pragma solidity ^0.4.15;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4c3e29212f230c7e">[email&#160;protected]</a>Ï€.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be send to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
*/
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * Fixed crowdsale pricing - everybody gets the same price.
 */
contract PricingStrategy is HasNoEther {
    using SafeMath for uint;

    /* How many weis one token costs */
    uint256 public oneTokenInWei;

    address public crowdsaleAddress;

    function PricingStrategy(address _crowdsale) {
        crowdsaleAddress = _crowdsale;
    }

    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleAddress);
        _;
    }

    /**
     * Calculate the current price for buy in amount.
     *
     */
    function calculatePrice(uint256 _value, uint256 _decimals) public constant returns (uint) {
        uint256 multiplier = 10 ** _decimals;
        uint256 weiAmount = _value.mul(multiplier);
        uint256 tokens = weiAmount.div(oneTokenInWei);
        return tokens;
    }

    function setTokenPriceInWei(uint _oneTokenInWei) onlyCrowdsale public returns (bool) {
        oneTokenInWei = _oneTokenInWei;
        return true;
    }
}