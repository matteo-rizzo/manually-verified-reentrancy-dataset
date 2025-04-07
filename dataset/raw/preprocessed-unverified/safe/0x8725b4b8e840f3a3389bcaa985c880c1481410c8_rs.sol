/**
 *Submitted for verification at Etherscan.io on 2021-06-14
*/

// SPDX-License-Identifier: No License
pragma solidity 0.6.6;

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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
 

/**
 * @dev Collection of functions related to the address type
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract BurnCrowdsale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //===============================================//
    //          Contract Variables                   //
    //===============================================//

    
    // Start time 06/14/2021 @ 2:30pm (GMT) //
    uint256 public constant CROWDSALE_START_TIME = 1623767400;
    
    //Minimum contribution is 0.015 ETH
    uint256 public constant MIN_CONTRIBUTION = 15000000000000000;
    
    //Maximum contribution is 1.5 ETH
    uint256 public constant MAX_CONTRIBUTION = 1500000000000000000;

    // Contributions state
    mapping(address => uint256) public contributions;
    mapping(address => bool) public claimed;
    
    // Note whitelisted addresses
    mapping(address => bool) public whitelisted;

    // Total wei raised (BNB)
    uint256 public weiRaised;
    
    //Whether the user can claim or not
    bool public canClaim;
    
    bool public saleOnForPublic;

    // Pointer to the BurnToken
    IERC20 public burnToken;

    // How many burns do we send per ETH contributed.
    uint256 public BurnsPerBnb;

    
    //===============================================//
    //                 Constructor                   //
    //===============================================//
    constructor(uint256 _burnsPerBnb) public Ownable() {
        BurnsPerBnb = _burnsPerBnb;
    }
    
    
    //===============================================//
    //                   Events                      //
    //===============================================//
    event TokenPurchase(
        address indexed beneficiary,
        uint256 weiAmount,
        uint256 tokenAmount
    );
    
    event TokenTransfer(
        address indexed beneficiary,
        uint256 weiAmount,
        uint256 tokenAmount
    );
    
    event LogUserAdded (address _user);

    //===============================================//
    //                   Methods                     //
    //===============================================//

    // Main entry point for buying into the Pre-Sale. Contract Receives $BNB
    function purchaseBURNTokens() external payable {
          // Validations.
            require(
                msg.sender != address(0),
                "BurnsCrowdsale: beneficiary is the zero address"
            );
            require(whitelisted[msg.sender] || saleOnForPublic, "Sorry the sale is yet not open for general public");
            
            require(isOpen() == true, "Crowdsale has not yet started");
            require(!canClaim, "Sale is over");
            
            require(msg.value >= MIN_CONTRIBUTION, "BurnsCrowdsale: minimum contribution is 0.1 BNB");
            require(contributions[msg.sender] + msg.value <= MAX_CONTRIBUTION, "BurnsCrowdsale: maximum contribution is 10 BNB");
            
            // If we've passed validations, let's get them $BURNs
            _buyTokens(msg.sender);
      
    }

    /**
     * Function to calculate how burn `weiAmount` can the sender purchase
     * based on total available cap for this round, and how burn eth they've contributed.
     *
     * At the end of the function we refund the remaining ETH not used for purchase.
     */
    function _buyTokens(address beneficiary) internal {
        
        _buyTokens(beneficiary, msg.value);

    }

    /**
     * Function that perform the actual transfer of $BURNs
     */
    function _buyTokens(address beneficiary, uint256 weiAmount) internal {
        
        // Update how much wei we have raised
        weiRaised = weiRaised.add(weiAmount);
        // Update how much wei has this address contributed
        contributions[beneficiary] = contributions[beneficiary].add(weiAmount);
    }
    
    function claimTokens() public {
        require(!claimed[msg.sender],"You have already claimed your tokens");
        require(canClaim, "Claim of tokens is not activated, please wait!");
        
        uint256 contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "You haven't contributed anything");

        // Calculate how many $BURNs can be bought with that wei amount
        uint256 tokenAmount = _getTokenAmount(contributedAmount);
        
        claimed[msg.sender] = true;
        
        // Transfer the $BURNs to the beneficiary
        burnToken.safeTransfer(msg.sender, tokenAmount);

        // Create an event for this purchase
        emit TokenTransfer(msg.sender, contributedAmount, tokenAmount);
    }

    // Calculate how many $BURNs do they get given the amount of wei
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256)
    {
        return weiAmount.mul(BurnsPerBnb).div(10e17);
    }
    
    function getTokenCountForUser(address _userAddress) public view returns (uint256){
        
        uint256 contributedAmount = contributions[_userAddress];
        // Calculate how many $BURNs can be bought with that amount
        uint256 tokenAmount = _getTokenAmount(contributedAmount);
        
        return tokenAmount;
    }
    
    
    

    /*************************** CONTROL FUNCTIONS **************************************/
    
    
    
    // Add many users in one go to the whitelist
    function addManyUsersToWhitelist(address[] memory users)public onlyOwner {
        
        require(users.length < 500,"limit exceeded");

        for (uint8 index = 0; index < users.length; index++) {

             whitelisted[users[index]] = true;

             emit LogUserAdded(users[index]);

        }
    }

    // Is the sale open now?
    function isOpen() public view returns (bool) {
        return now >= CROWDSALE_START_TIME;
    }

    function changeManyBnbRate(uint256 _newRate) public onlyOwner returns(bool) {
        require(_newRate != 0, "New Rate can't be 0");
        BurnsPerBnb = _newRate;
        return true;
    }
    
    function openSaleForAll() public onlyOwner {
        require(!saleOnForPublic,"already open");
        saleOnForPublic = true;
    }
    
    function activateClaim() public onlyOwner{
        require(!canClaim, "already activated");
        canClaim = true;
    }
    
    function addTokenAddress(IERC20 _burnToken)public onlyOwner{
        burnToken = _burnToken;
    }
    
    function takeOutRemainingTokens() public onlyOwner {
        burnToken.safeTransfer(msg.sender, burnToken.balanceOf(address(this)));
    }
    
    function takeOutFundingRaised()public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
}