/**

 *Submitted for verification at Etherscan.io on 2019-03-25

*/



pragma solidity ^0.5.0;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// This interface allows contracts to query unverified prices.





contract Withdrawable is Ownable {

    // Withdraws ETH from the contract.

    function withdraw(uint amount) external onlyOwner {

        msg.sender.transfer(amount);

    }



    // Withdraws ERC20 tokens from the contract.

    function withdrawErc20(address erc20Address, uint amount) external onlyOwner {

        IERC20 erc20 = IERC20(erc20Address);

        require(erc20.transfer(msg.sender, amount));

    }

}



contract Testable is Ownable {



    // Is the contract being run on the test network. Note: this variable should be set on construction and never

    // modified.

    bool public isTest;



    uint private currentTime;



    constructor(bool _isTest) internal {

        isTest = _isTest;

        if (_isTest) {

            currentTime = now; // solhint-disable-line not-rely-on-time

        }

    }



    modifier onlyIfTest {

        require(isTest);

        _;

    }



    function setCurrentTime(uint _time) external onlyOwner onlyIfTest {

        currentTime = _time;

    }



    function getCurrentTime() public view returns (uint) {

        if (isTest) {

            return currentTime;

        } else {

            return now; // solhint-disable-line not-rely-on-time

        }

    }

}



// Implementation of PriceFeedInterface with the ability to push prices.

contract ManualPriceFeed is PriceFeedInterface, Withdrawable, Testable {



    using SafeMath for uint;



    // A single price update.

    struct PriceTick {

        uint timestamp;

        int price;

    }



    // Mapping from identifier to the latest price for that identifier.

    mapping(bytes32 => PriceTick) private prices;



    // Ethereum timestamp tolerance.

    // Note: this is technically the amount of time that a block timestamp can be *ahead* of the current time. However,

    // we are assuming that blocks will never get more than this amount *behind* the current time. The only requirement

    // limiting how early the timestamp can be is that it must have a later timestamp than its parent. However,

    // this bound will probably work reasonably well in both directions.

    uint constant private BLOCK_TIMESTAMP_TOLERANCE = 900;



    constructor(bool _isTest) public Testable(_isTest) {} // solhint-disable-line no-empty-blocks



    // Adds a new price to the series for a given identifier. The pushed publishTime must be later than the last time

    // pushed so far.

    function pushLatestPrice(bytes32 identifier, uint publishTime, int newPrice) external onlyOwner {

        require(publishTime <= getCurrentTime().add(BLOCK_TIMESTAMP_TOLERANCE));

        require(publishTime > prices[identifier].timestamp);

        prices[identifier] = PriceTick(publishTime, newPrice);

        emit PriceUpdated(identifier, publishTime, newPrice);

    }



    // Whether this feed has ever published any prices for this identifier.

    function isIdentifierSupported(bytes32 identifier) external view returns (bool isSupported) {

        isSupported = _isIdentifierSupported(identifier);

    }



    function latestPrice(bytes32 identifier) external view returns (uint publishTime, int price) {

        require(_isIdentifierSupported(identifier));

        publishTime = prices[identifier].timestamp;

        price = prices[identifier].price;

    }



    function _isIdentifierSupported(bytes32 identifier) private view returns (bool isSupported) {

        isSupported = prices[identifier].timestamp > 0;

    }

}