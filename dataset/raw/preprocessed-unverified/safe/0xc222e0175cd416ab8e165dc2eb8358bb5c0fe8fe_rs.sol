/**

 *Submitted for verification at Etherscan.io on 2018-09-27

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract BONAWallet is Ownable {

    using SafeMath for uint256;



    // Address where funds are collected

    address public wallet = 0xeb949f18f5FF3c5175baA7EDc3412225a1d6A02C;

  

    // How many token units a buyer gets per wei

    uint256 public rate = 1100;



    // Minimum investment total in wei

    uint256 public minInvestment = 2E17;



    // Maximum investment total in wei

    uint256 public investmentUpperBounds = 2E21;



    // Hard cap in wei

    uint256 public hardcap = 1E23;



    // Amount of wei raised

    uint256 public weiRaised;



    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);

    event Whitelist(address whiteaddress);

    event Blacklist(address blackaddress);

    event ChangeRate(uint256 newRate);

    event ChangeMin(uint256 newMin);

    event ChangeMax(uint256 newMax);

    event ChangeHardCap(uint256 newHardCap);

    

    // -----------------------------------------

    // Crowdsale external interface

    // -----------------------------------------



    /**

     * @dev fallback function ***DO NOT OVERRIDE***

     */

    function () external payable {

        buyTokens(msg.sender);

    }



    /** Whitelist an address and set max investment **/

    mapping (address => bool) public whitelistedAddr;

    mapping (address => uint256) public totalInvestment;

  

    /** @dev whitelist an Address */

    function whitelistAddress(address[] buyer) external onlyOwner {

        for (uint i = 0; i < buyer.length; i++) {

            whitelistedAddr[buyer[i]] = true;

            address whitelistedbuyer = buyer[i];

        }

        emit Whitelist(whitelistedbuyer);

    }

  

    /** @dev black list an address **/

    function blacklistAddr(address[] buyer) external onlyOwner {

        for (uint i = 0; i < buyer.length; i++) {

            whitelistedAddr[buyer[i]] = false;

            address blacklistedbuyer = buyer[i];

        }

        emit Blacklist(blacklistedbuyer);

    }



    /**

     * @dev low level token purchase ***DO NOT OVERRIDE***

     * @param _beneficiary Address performing the token purchase

     */

    function buyTokens(address _beneficiary) public payable {



        uint256 weiAmount = msg.value;

        _preValidatePurchase(_beneficiary, weiAmount);



        // calculate token amount to be created

        uint256 tokens = _getTokenAmount(weiAmount);



        // update state

        weiRaised = weiRaised.add(weiAmount);



        emit TokenPurchase(msg.sender, weiAmount, tokens);



        _updatePurchasingState(_beneficiary, weiAmount);



        _forwardFunds();

    }



    /**

     * @dev Set the rate of how many units a buyer gets per wei

    */

    function setRate(uint256 newRate) external onlyOwner {

        rate = newRate;

        emit ChangeRate(rate);

    }



    /**

     * @dev Set the minimum investment in wei

    */

    function changeMin(uint256 newMin) external onlyOwner {

        minInvestment = newMin;

        emit ChangeMin(minInvestment);

    }



    /**

     * @dev Set the maximum investment in wei

    */

    function changeMax(uint256 newMax) external onlyOwner {

        investmentUpperBounds = newMax;

        emit ChangeMax(investmentUpperBounds);

    }



    /**

     * @dev Set the maximum investment in wei

    */

    function changeHardCap(uint256 newHardCap) external onlyOwner {

        hardcap = newHardCap;

        emit ChangeHardCap(hardcap);

    }



    // -----------------------------------------

    // Internal interface (extensible)

    // -----------------------------------------



    /**

     * @dev Validation of an incoming purchase. Use require statemens to revert state when conditions are not met. Use super to concatenate validations.

     * @param _beneficiary Address performing the token purchase

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {

        require(_beneficiary != address(0)); 

        require(_weiAmount != 0);

    

        require(_weiAmount >= minInvestment); // Revert if payment is less than minInvestment

        require(whitelistedAddr[_beneficiary]); // Revert if investor is not whitelisted

        require(totalInvestment[_beneficiary].add(_weiAmount) <= investmentUpperBounds); // Revert if the investor already

        // spent over investmentUpperBounds ETH investment or payment is greater than investmentUpperBounds

        require(weiRaised.add(_weiAmount) <= hardcap); // Revert if ICO campaign reached Hard Cap

    }





    /**

     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

     * @param _beneficiary Address receiving the tokens

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {

        totalInvestment[_beneficiary] = totalInvestment[_beneficiary].add(_weiAmount);

    }



    /**

     * @dev Override to extend the way in which ether is converted to tokens.

     * @param _weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified _weiAmount

     */

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {

        return _weiAmount.mul(rate);

    }



    /**

     * @dev Determines how ETH is stored/forwarded on purchases.

     */

    function _forwardFunds() internal {

        wallet.transfer(msg.value);

    }

}