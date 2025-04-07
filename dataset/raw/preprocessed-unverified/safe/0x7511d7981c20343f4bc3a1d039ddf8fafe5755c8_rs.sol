/**
 *Submitted for verification at Etherscan.io on 2019-09-22
*/

pragma solidity =0.5.11;

// * Gods Unchained Raffle Token Exchange
//
// * Version 1.0
//
// * A dedicated contract for listing (selling) and buying raffle tokens.
//
// * https://gu.cards

contract ERC20Interface {
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

contract IERC20Interface {
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract RaffleToken is ERC20Interface, IERC20Interface {}

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


contract RaffleTokenExchange {
    using SafeMath for uint256;

    //////// V A R I A B L E S
    //
    // The raffle token contract
    //
    RaffleToken constant public raffleContract = RaffleToken(0x0C8cDC16973E88FAb31DD0FCB844DdF0e1056dE2);
    //
    // In case the exchange is paused.
    //
    bool public paused;
    //
    // Standard contract ownership.
    //
    address payable public owner;
    //
    // Next id for the next listing
    //
    uint256 public nextListingId;
    //
    // All raffle token listings mapped by id
    //
    mapping (uint256 => Listing) public listingsById;
    //
    // All purchases
    //
    mapping (uint256 => Purchase) public purchasesById;
    //
    // Next id for the next purche
    //
    uint256 public nextPurchaseId;

    //////// S T R U C T S
    //
    //  A listing of raffle tokens
    //
    struct Listing {
        //
        // price per token (in wei).
        //
        uint256 pricePerToken;
        //
        //
        // How many tokens? (Original Amount)
        //
        uint256 initialAmount;
        //
        // How many tokens left? (Maybe altered due to partial sales)
        //
        uint256 amountLeft;
        //
        // Listed by whom?
        //
        address payable seller;
        //
        // Active/Inactive listing?
        //
        bool active;
    }
    //
    //  A purchase of raffle tokens
    //
    struct Purchase {
        //
        // How many tokens?
        //
        uint256 totalAmount;
        //
        // total price payed
        //
        uint256 totalAmountPayed;
        //
        // When did the purchase happen?
        //
        uint256 timestamp;
    }

    //////// EVENTS
    //
    //
    //
    event Listed(uint256 id, uint256 pricePerToken, uint256 initialAmount, address seller);
    event Canceled(uint256 id);
    event Purchased(uint256 id, uint256 totalAmount, uint256 totalAmountPayed, uint256 timestamp);

    //////// M O D I F I E R S
    //
    // Invokable only by contract owner.
    //
    modifier onlyContractOwner {
        require(msg.sender == owner, "Function called by non-owner.");
        _;
    }
    //
    // Invokable only if exchange is not paused.
    //
    modifier onlyUnpaused {
        require(paused == false, "Exchange is paused.");
        _;
    }

    //////// C O N S T R U C T O R
    //
    constructor() public {
        owner = msg.sender;
        nextListingId = 916;
        nextPurchaseId = 344;
    }

    //////// F U N C T I O N S
    //
    // buyRaffle
    //
    function buyRaffle(uint256[] calldata amounts, uint256[] calldata listingIds) payable external onlyUnpaused {
        require(amounts.length == listingIds.length, "You have to provide amounts for every single listing!");
        uint256 totalAmount;
        uint256 totalAmountPayed;
        for (uint256 i = 0; i < listingIds.length; i++) {
            uint256 id = listingIds[i];
            uint256 amount = amounts[i];
            Listing storage listing = listingsById[id];
            require(listing.active, "Listing is not active anymore!");
            listing.amountLeft = listing.amountLeft.sub(amount);
            require(listing.amountLeft >= 0, "Amount left needs to be higher than 0.");
            if(listing.amountLeft == 0) { listing.active = false; }
            uint256 amountToPay = listing.pricePerToken * amount;
            listing.seller.transfer(amountToPay);
            totalAmountPayed = totalAmountPayed.add(amountToPay);
            totalAmount = totalAmount.add(amount);
            require(raffleContract.transferFrom(listing.seller, msg.sender, amount), 'Token transfer failed!');
        }
        require(totalAmountPayed <= msg.value, 'Overpayed!');
        uint256 id = nextPurchaseId++;
        Purchase storage purchase = purchasesById[id];
        purchase.totalAmount = totalAmount;
        purchase.totalAmountPayed = totalAmountPayed;
        purchase.timestamp = now;
        emit Purchased(id, totalAmount, totalAmountPayed, now);
    }
    //
    // Add listing
    //
    function addListing(uint256 initialAmount, uint256 pricePerToken) external onlyUnpaused {
        require(raffleContract.balanceOf(msg.sender) >= initialAmount, "Amount to sell is higher than balance!");
        require(raffleContract.allowance(msg.sender, address(this)) >= initialAmount, "Allowance is to small (increase allowance)!");
        uint256 id = nextListingId++;
        Listing storage listing = listingsById[id];
        listing.initialAmount = initialAmount;
        listing.amountLeft = initialAmount;
        listing.pricePerToken = pricePerToken;
        listing.seller = msg.sender;
        listing.active = true;
        emit Listed(id, listing.pricePerToken, listing.initialAmount, listing.seller);
    }
    //
    // Cancel listing
    //
    function cancelListing(uint256 id) external {
        Listing storage listing = listingsById[id];
        require(listing.active, "This listing was turned inactive already!");
        require(listing.seller == msg.sender || owner == msg.sender, "Only the listing owner or the contract owner can cancel the listing!");
        listing.active = false;
        emit Canceled(id);
    }
    //
    // Set paused
    //
    function setPaused(bool value) external onlyContractOwner {
        paused = value;
    }
    //
    // Funds withdrawal to cover operational costs
    //
    function withdrawFunds(uint256 withdrawAmount) external onlyContractOwner {
        owner.transfer(withdrawAmount);
    }
    //
    // Contract may be destroyed only when there is nothing else going on. 
    // All funds are transferred to contract owner.
    //
    function kill() external onlyContractOwner {
        selfdestruct(owner);
    }
}