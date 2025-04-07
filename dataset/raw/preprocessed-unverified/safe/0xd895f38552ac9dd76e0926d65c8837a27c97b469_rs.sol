/**
 *Submitted for verification at Etherscan.io on 2021-07-21
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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





contract CSDCrowdsale is Context, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
 
    // The token being sold
    IERC20 internal _token;
 
    // Address where funds are collected
    address payable internal _wallet;
 
    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 internal _rate;
    uint256 internal initialrate;
 
    // Amount of wei raised
    uint256 internal _weiRaised;

    uint256 public maxAmountToBuyPerTransaction = 10**6 * 10**18;
    uint256 public maxAmountToSell = 10**3 * 10**6 * 10**18;
    uint256 public totalAmount;
    uint256 public step;
    uint256 public sellAmount;

    mapping(address => uint256) public holders;
 
    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
 
    constructor (uint256 tokenrate, address payable fundswallet, IERC20 tokenAddress, uint256 amount) {
        require(tokenrate > 0, "Crowdsale: rate is 0");
        require(fundswallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(tokenAddress) != address(0), "Crowdsale: token is the zero address");
        require(amount > 0, "Crowdsale: token amount is zero");
 
        _rate = tokenrate;
        initialrate = tokenrate;
        _wallet = fundswallet;
        _token = tokenAddress;
        totalAmount = amount;
        step = 1;
        sellAmount = 0;
    }
 
    receive () external payable {
        buyTokens(_msgSender());
    }
 
    /**
     * @return the token being sold.
     */
    function token() public view returns (IERC20) {
        return _token;
    }
 
    /**
     * @return the address where funds are collected.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
    }
 
    /**
     * @return the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }
 
    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function setFundsWallet(address payable fundswallet) external onlyOwner {
        _wallet = fundswallet;
    }

    function setMaxAmountToBuyPerTransaction(uint256 _amount) external onlyOwner {
        maxAmountToBuyPerTransaction = _amount;
    }

    function setMaxAmountToSell(uint256 _amount) external onlyOwner {
        maxAmountToSell = _amount;
    }

    function setRate(uint256 fundsrate) external onlyOwner {
        _rate = fundsrate;
    }
 
    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
 
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        validatePurchase(beneficiary, tokens);
 
        // update state
        _weiRaised = _weiRaised.add(weiAmount);
 
        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        holders[beneficiary] = holders[beneficiary].add(tokens);
 
        _updatePurchasingState(tokens);
 
        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }
 
    function validatePurchase(address beneficiary, uint256 tokenAmount) internal view {
        require(tokenAmount <= maxAmountToBuyPerTransaction, "Crowdsale: Buy amount exceeds the maxBuyPerTransactionAmount.");
        require(holders[beneficiary].add(tokenAmount) <= maxAmountToSell, "Crowdsale: Buy total amount exceeds the maxAmountToSell.");
        this;
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }
 
    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        // solhint-disable-previous-line no-empty-blocks
    }
 
    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }
 
    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }
 
    function _updatePurchasingState(uint256 tokenAmount) internal {
        sellAmount = sellAmount.add(tokenAmount);
        if (sellAmount >= totalAmount.div(10).mul(step)) {
            step = step.add(1);
            _rate = _rate.sub(initialrate.div(4));
            if (sellAmount >= totalAmount.div(10).mul(step)) {
                step = step.add(1);
                _rate = _rate.sub(initialrate.div(4));
            }
        }
    }
 
    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
 
    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }

    function sendToken(address toAddress, uint256 amount) public onlyOwner {
        _deliverTokens(toAddress, amount);
        _updatePurchasingState(amount);
    }
}