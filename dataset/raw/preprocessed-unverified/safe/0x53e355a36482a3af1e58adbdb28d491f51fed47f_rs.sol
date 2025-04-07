/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.7.5;
// SPDX-License-Identifier: MIT





contract CouponTrader {
    using SafeMath for uint256;

    IESDS constant private ESDS = IESDS(0x443D2f2755DB5942601fa062Cc248aAA153313D3);
    IERC20 constant private USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    uint256 constant private HOUSE_RATE = 100; // 100 basis points (1%) -- fee taken by the house
    address constant private OPEN_SALE_INDICATOR = 0x0000000000000000000000000000000000000001; // if this is the "buyer" then anyone can buy
    address public house = 0xE1dba80BAc43407360c7b0175444893eBaA30098; // collector of house take
    
    struct Offer {
        address buyer;
        uint256 epoch;
        uint256 numCoupons;
        uint256 price; // in USDC -- recall that USD uses 6 decimals, not 18
    }
    
    mapping (address => Offer) private offerBySeller;
    
    event OfferSet(address indexed seller, address indexed buyer, uint256 indexed epoch, uint256 numCoupons, uint256 price);
    event SuccessfulTrade(address indexed seller, address indexed buyer, uint256 epoch, uint256 numCoupons, uint256 price);
    
    // @notice Allows a seller to set or update an offer
    // @notice Caller MUST have approved this contract to move their coupons before calling this function or else this will revert.
    // @dev Does some sanity checks to make sure the seller can hold up their end. This check 
    //    is for UX purposes only and can be bypassed trivially. It is not security critical.
    // @param _buyer The buyer who is allowed to take this offer. If the _buyer param is set to OPEN_SALE_INDICATOR then
    //    anyone can take this offer.
    // @param _epoch The epoch of the coupons to be sold.
    // @param _numCoupons The number of coupons to be sold.
    // @param _price The amount of USDC the buyer must pay to take this offer. Remember that USDC uses 6 decimal places, not 18.
    function setOffer(address _buyer, uint256 _epoch, uint256 _numCoupons, uint256 _price) external {
        // sanity checks
        require(ESDS.balanceOfCoupons(msg.sender, _epoch) >= _numCoupons, "seller doesn't have enough coupons at that epoch");
        require(ESDS.allowanceCoupons(msg.sender, address(this)) >= _numCoupons, "seller hasn't approved this contract to move enough coupons");
        require(_price > 0, "zero price");
        
        // store new offer
        Offer memory newOffer = Offer(_buyer, _epoch, _numCoupons, _price);
        offerBySeller[msg.sender] = newOffer;
        
        emit OfferSet(msg.sender, _buyer, _epoch, _numCoupons, _price);
    }
    
    // @notice A convenience function a seller can use to revoke their offer.
    function revokeOffer() external {
        delete offerBySeller[msg.sender];
        emit OfferSet(msg.sender, address(0), 0, 0, 0);
    }
    
    // @notice A getter for the offers
    // @param _seller The address of the seller whose offer we want to return.
    function getOffer(address _seller) external view returns (address, uint256, uint256, uint256) {
        Offer memory offer = offerBySeller[_seller];
        return (offer.buyer, offer.epoch, offer.numCoupons, offer.price);
    }
    
    // @notice Allows a buyer to take an offer.
    // @dev Partial fills are not supported.
    // @dev The buyer must have approved this contract to move enough USDC to pay for this purchase.
    // @param _seller The seller whose offer the caller wants to take.
    // @param _epoch The epoch of the coupons being bought (must match the seller's offer). 
    // @param _numCoupons The number of coupons being bought (must match the seller's offer).
    // @param _price The amount of USDC the buyer is paying (must match the seller's offer).
    function takeOffer(address _seller, uint256 _epoch, uint256 _numCoupons, uint256 _price) external {
        // get offer information
        Offer memory offer = offerBySeller[_seller];
        
        // check that the caller is authorized
        require(msg.sender == offer.buyer || offer.buyer == OPEN_SALE_INDICATOR, "unauthorized buyer");
        
        // check that the order details are correct (protects buyer from frontrunning by the seller)
        require(
            offer.epoch == _epoch &&
            offer.numCoupons == _numCoupons &&
            offer.price == _price,
            "order details do not match the seller's offer"
        );
        
        // delete the seller's offer (so this offer cannot be filled twice)
        delete offerBySeller[_seller];
        
        // compute house take and seller take (USDC)
        uint256 houseTake = offer.price.mul(HOUSE_RATE).div(10_000);
        uint256 sellerTake = offer.price.sub(houseTake);
        
        // pay the seller USDC
        require(USDC.transferFrom(msg.sender, _seller, sellerTake), "could not pay seller");
        
        // pay the house USDC
        require(USDC.transferFrom(msg.sender, house, houseTake), "could not pay house");
        
        // transfer the coupons to the buyer
        ESDS.transferCoupons(_seller, msg.sender, _epoch, _numCoupons); // @audit-ok reverts on failure
        
        // emit events
        emit SuccessfulTrade(_seller, msg.sender, _epoch, _numCoupons, _price);
        emit OfferSet(_seller, address(0), 0, 0, 0);
    }
    
    // @notice Allows house address to change the house address
    function changeHouseAddress(address _newAddress) external {
        require(msg.sender == house);
        house = _newAddress;
    }
    
}





