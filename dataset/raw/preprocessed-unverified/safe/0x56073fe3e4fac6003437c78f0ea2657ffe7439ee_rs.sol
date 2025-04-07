/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

pragma solidity ^0.5.10;

contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

/// @title Interface for interacting with the MarbleCards Core contract created by the fine folks at Marble.Cards.
contract CardCore {

    // ERC-721 Standard
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function setApprovalForAll(address _operator, bool _approved) external;
    function approve(address _approved, uint256 _tokenId) external payable;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    // Metadata extensions
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    // Enumeration extensions
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}




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




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */





/**
 * @title Marble Dutch Auction Interface
 * @dev describes all externaly accessible functions neccessary to run Marble Auctions
 */



contract WMCMarketplace is Ownable {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

    /* ********** */
    /* DATA TYPES */
    /* ********** */

    /* ****** */
    /* EVENTS */
    /* ****** */

    event CardPurchasedWithWMC(uint256 cardId, uint256 wmcSpent);
    event DevFeeUpdated(uint256 newDevFee);

    /* ******* */
    /* STORAGE */
    /* ******* */



    /* ********* */
    /* CONSTANTS */
    /* ********* */

    // Mainnet
    address marbleCoreAddress = 0x1d963688FE2209A98dB35C67A041524822Cf04ff;
    address marbleAuctionAddress = 0x649EfF2dC5d9c5C641260C8B9BedE4770FCCF5E7;
    address wrappedCardsAddress = 0x8AedB297FED4b6884b808ee61fAf0837713670d0;
    address uniswapExchangeAddress = 0xA0db39d28dACeC1974f2a1F6Bac7d33F37C102eC;

    uint256 devFeeInBasisPoints = 375;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    function buyCardWithWMC(uint256 _cardId, uint256 _maxWMCWeiToSpend) external returns (bool) {
        // Transfer user WMC to sales contract for processing
        bool _WMCTransferToContract = IERC20(wrappedCardsAddress).transferFrom(msg.sender, address(this), _maxWMCWeiToSpend);
        // Verify transfer returns true, this should never fail
        require(_WMCTransferToContract, "WMC Transfer was unsuccessful");
        // Pass in the cardId and get the price in wei
        uint256 costInWei = getCurrentPrice(_cardId);
        // Swap WMC to ETH via the Uniswap exchange, adding a small amount for the dev fee
        uint256 tokensSold = UniswapExchangeInterface(uniswapExchangeAddress).tokenToEthSwapOutput(_computePriceWithDevFee(costInWei), _maxWMCWeiToSpend, ~uint256(0));
        // Send ETH to the Marble Auction account and send the card to this contract
        MarbleDutchAuctionInterface(marbleAuctionAddress).bid.value(costInWei)(_cardId);
        // Refund the excess WMC to the buyer that wasn't expended in the purchase.
        bool _WMCRefundToBuyer = IERC20(wrappedCardsAddress).transfer(msg.sender, _maxWMCWeiToSpend.sub(tokensSold));
        // The last function should return true, if it didn't something has gone horribly wrong and we need to revert everything we've done here.
        require(_WMCRefundToBuyer, "Error processing WMC refund.");
        // Transfer the purchased card from this contract to the sender account.
        CardCore(marbleCoreAddress).transferFrom(address(this), msg.sender, _cardId);
        // Tell everyone.
        emit CardPurchasedWithWMC(_cardId, tokensSold);
        return true;
    }

    // Alias for Auction.getCurrentPrice()
    function getCurrentPrice(uint256 _cardId) public view returns (uint256) {
        return MarbleDutchAuctionInterface(marbleAuctionAddress).getCurrentPrice(_cardId);
    }

    function totalAuctions() public view returns (uint256) {
        return MarbleDutchAuctionInterface(marbleAuctionAddress).totalAuctions();
    }

    function getAuction(uint256 _tokenId) public view returns (address seller, uint256 startingPrice,
        uint256 endingPrice, uint256 duration, uint256 startedAt, bool canBeCanceled) {
        return MarbleDutchAuctionInterface(marbleAuctionAddress).getAuction(_tokenId);
    }

    function isOnAuction(uint256 _tokenId) external view returns (bool isIndeed) {
        return MarbleDutchAuctionInterface(marbleAuctionAddress).isOnAuction(_tokenId);
    }

    function tokenOfSellerByIndex(address _seller, uint256 _index) public view returns (uint256) {
        return MarbleDutchAuctionInterface(marbleAuctionAddress).tokenOfSellerByIndex(_seller, _index);
    }

    function totalAuctionsBySeller(address _seller) public view returns (uint256) {
        return MarbleDutchAuctionInterface(marbleAuctionAddress).totalAuctionsBySeller(_seller);
    }

    // Uniswap view aliases
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought) {
        return UniswapExchangeInterface(uniswapExchangeAddress).getEthToTokenInputPrice(eth_sold);
    }

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold) {
        return UniswapExchangeInterface(uniswapExchangeAddress).getEthToTokenOutputPrice(tokens_bought);
    }

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought) {
        return UniswapExchangeInterface(uniswapExchangeAddress).getTokenToEthInputPrice(tokens_sold);
    }

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold) {
        return UniswapExchangeInterface(uniswapExchangeAddress).getTokenToEthOutputPrice(eth_bought);
    }

    // Not sure if marketplace contract will change in the future, so leaving the option here.
    function changeMarbleAuctionAddress(address _auctionContract) public onlyOwner returns (bool) {
        require(isContract(_auctionContract));
        marbleAuctionAddress = _auctionContract;
        return true;
    }

    function transferERC20(address _erc20Address, address _to, uint256 _value) external onlyOwner returns (bool) {
        return IERC20(_erc20Address).transfer(_to, _value);
    }

    function withdrawOwnerEarnings() external onlyOwner returns (bool) {
        msg.sender.transfer(address(this).balance);
        return true;
    }

    function updateFee(uint256 _newFee) external onlyOwner returns (bool) {
        devFeeInBasisPoints = _newFee;
        emit DevFeeUpdated(_newFee);
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    constructor() public {
        IERC20(wrappedCardsAddress).approve(uniswapExchangeAddress, ~uint256(0));
    }

    function() external payable {}

    function _computePriceWithDevFee(uint256 _costInWei) internal view returns (uint256) {
        return (_costInWei.mul(uint256(10000).add(devFeeInBasisPoints))).div(uint256(10000));
    }
}