/**

 *Submitted for verification at Etherscan.io on 2019-05-25

*/



pragma solidity ^0.4.24;



/**

 * @title Utility contract to allow pausing and unpausing of certain functions

 */

contract Pausable {



    event Pause(uint256 _timestammp);

    event Unpause(uint256 _timestamp);



    bool public paused = false;



    /**

    * @notice Modifier to make a function callable only when the contract is not paused.

    */

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");

        _;

    }



    /**

    * @notice Modifier to make a function callable only when the contract is paused.

    */

    modifier whenPaused() {

        require(paused, "Contract is not paused");

        _;

    }



   /**

    * @notice Called by the owner to pause, triggers stopped state

    */

    function _pause() internal whenNotPaused {

        paused = true;

        /*solium-disable-next-line security/no-block-members*/

        emit Pause(now);

    }



    /**

    * @notice Called by the owner to unpause, returns to normal state

    */

    function _unpause() internal whenPaused {

        paused = false;

        /*solium-disable-next-line security/no-block-members*/

        emit Unpause(now);

    }



}



/**

 * @title Interface that every module contract should implement

 */





/**

 * @title Interface for all security tokens

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Storage for Module contract

 * @notice Contract is abstract

 */

contract ModuleStorage {



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress) public {

        securityToken = _securityToken;

        factory = msg.sender;

        polyToken = IERC20(_polyAddress);

    }

    

    address public factory;



    address public securityToken;



    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";



    IERC20 public polyToken;



}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Interface that any module contract should implement

 * @notice Contract is abstract

 */

contract Module is IModule, ModuleStorage {



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress) public

    ModuleStorage(_securityToken, _polyAddress)

    {

    }



    //Allows owner, factory or permissioned delegate

    modifier withPerm(bytes32 _perm) {

        bool isOwner = msg.sender == Ownable(securityToken).owner();

        bool isFactory = msg.sender == factory;

        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");

        _;

    }



    modifier onlyOwner {

        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");

        _;

    }



    modifier onlyFactory {

        require(msg.sender == factory, "Sender is not factory");

        _;

    }



    modifier onlyFactoryOwner {

        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");

        _;

    }



    modifier onlyFactoryOrOwner {

        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");

        _;

    }



    /**

     * @notice used to withdraw the fee by the factory owner

     */

    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {

        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");

        return true;

    }



}



/**

 * @title Interface to be implemented by all STO modules

 */





/**

 * @title Storage layout for the STO contract

 */

contract STOStorage {



    mapping (uint8 => bool) public fundRaiseTypes;

    mapping (uint8 => uint256) public fundsRaised;



    // Start time of the STO

    uint256 public startTime;

    // End time of the STO

    uint256 public endTime;

    // Time STO was paused

    uint256 public pausedTime;

    // Number of individual investors

    uint256 public investorCount;

    // Address where ETH & POLY funds are delivered

    address public wallet;

     // Final amount of tokens sold

    uint256 public totalTokensSold;



}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Interface to be implemented by all STO modules

 */

contract STO is ISTO, STOStorage, Module, Pausable  {

    using SafeMath for uint256;



    enum FundRaiseType { ETH, POLY, SC }



    // Event

    event SetFundRaiseTypes(FundRaiseType[] _fundRaiseTypes);



    /**

     * @notice Returns funds raised by the STO

     */

    function getRaised(FundRaiseType _fundRaiseType) public view returns (uint256) {

        return fundsRaised[uint8(_fundRaiseType)];

    }



    /**

     * @notice Pause (overridden function)

     */

    function pause() public onlyOwner {

        /*solium-disable-next-line security/no-block-members*/

        require(now < endTime, "STO has been finalized");

        super._pause();

    }



    /**

     * @notice Unpause (overridden function)

     */

    function unpause() public onlyOwner {

        super._unpause();

    }



    function _setFundRaiseType(FundRaiseType[] _fundRaiseTypes) internal {

        // FundRaiseType[] parameter type ensures only valid values for _fundRaiseTypes

        require(_fundRaiseTypes.length > 0 && _fundRaiseTypes.length <= 3, "Raise type is not specified");

        fundRaiseTypes[uint8(FundRaiseType.ETH)] = false;

        fundRaiseTypes[uint8(FundRaiseType.POLY)] = false;

        fundRaiseTypes[uint8(FundRaiseType.SC)] = false;

        for (uint8 j = 0; j < _fundRaiseTypes.length; j++) {

            fundRaiseTypes[uint8(_fundRaiseTypes[j])] = true;

        }

        emit SetFundRaiseTypes(_fundRaiseTypes);

    }



    /**

    * @notice Reclaims ERC20Basic compatible tokens

    * @dev We duplicate here due to the overriden owner & onlyOwner

    * @param _tokenContract The address of the token contract

    */

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");

        IERC20 token = IERC20(_tokenContract);

        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(msg.sender, balance), "Transfer failed");

    }



    /**

    * @notice Reclaims ETH

    * @dev We duplicate here due to the overriden owner & onlyOwner

    */

    function reclaimETH() external onlyOwner {

        msg.sender.transfer(address(this).balance);

    }



}



/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



/**

 * @title STO module for standard capped crowdsale

 */

contract CappedSTO is STO, ReentrancyGuard {

    using SafeMath for uint256;



    // Determine whether users can invest on behalf of a beneficiary

    bool public allowBeneficialInvestments = false;

    // How many token units a buyer gets (multiplied by 10^18) per wei / base unit of POLY

    // If rate is 10^18, buyer will get 1 token unit for every wei / base unit of poly.

    uint256 public rate;

    //How many token base units this STO will be allowed to sell to investors

    // 1 full token = 10^decimals_of_token base units

    uint256 public cap;



    mapping (address => uint256) public investors;



    /**

    * Event for token purchase logging

    * @param purchaser who paid for the tokens

    * @param beneficiary who got the tokens

    * @param value weis paid for purchase

    * @param amount amount of tokens purchased

    */

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    event SetAllowBeneficialInvestments(bool _allowed);



    constructor (address _securityToken, address _polyAddress) public

    Module(_securityToken, _polyAddress)

    {

    }



    //////////////////////////////////

    /**

    * @notice fallback function ***DO NOT OVERRIDE***

    */

    function () external payable {

        buyTokens(msg.sender);

    }



    /**

     * @notice Function used to intialize the contract variables

     * @param _startTime Unix timestamp at which offering get started

     * @param _endTime Unix timestamp at which offering get ended

     * @param _cap Maximum No. of token base units for sale

     * @param _rate Token units a buyer gets multiplied by 10^18 per wei / base unit of POLY

     * @param _fundRaiseTypes Type of currency used to collect the funds

     * @param _fundsReceiver Ethereum account address to hold the funds

     */

    function configure(

        uint256 _startTime,

        uint256 _endTime,

        uint256 _cap,

        uint256 _rate,

        FundRaiseType[] _fundRaiseTypes,

        address _fundsReceiver

    )

    public

    onlyFactory

    {

        require(endTime == 0, "Already configured");

        require(_rate > 0, "Rate of token should be greater than 0");

        require(_fundsReceiver != address(0), "Zero address is not permitted");

        /*solium-disable-next-line security/no-block-members*/

        require(_startTime >= now && _endTime > _startTime, "Date parameters are not valid");

        require(_cap > 0, "Cap should be greater than 0");

        require(_fundRaiseTypes.length == 1, "It only selects single fund raise type");

        startTime = _startTime;

        endTime = _endTime;

        cap = _cap;

        rate = _rate;

        wallet = _fundsReceiver;

        _setFundRaiseType(_fundRaiseTypes);

    }



    /**

     * @notice This function returns the signature of configure function

     */

    function getInitFunction() public pure returns (bytes4) {

        return bytes4(keccak256("configure(uint256,uint256,uint256,uint256,uint8[],address)"));

    }



    /**

     * @notice Function to set allowBeneficialInvestments (allow beneficiary to be different to funder)

     * @param _allowBeneficialInvestments Boolean to allow or disallow beneficial investments

     */

    function changeAllowBeneficialInvestments(bool _allowBeneficialInvestments) public onlyOwner {

        require(_allowBeneficialInvestments != allowBeneficialInvestments, "Does not change value");

        allowBeneficialInvestments = _allowBeneficialInvestments;

        emit SetAllowBeneficialInvestments(allowBeneficialInvestments);

    }



    /**

      * @notice Low level token purchase ***DO NOT OVERRIDE***

      * @param _beneficiary Address performing the token purchase

      */

    function buyTokens(address _beneficiary) public payable nonReentrant {

        if (!allowBeneficialInvestments) {

            require(_beneficiary == msg.sender, "Beneficiary address does not match msg.sender");

        }



        require(!paused, "Should not be paused");

        require(fundRaiseTypes[uint8(FundRaiseType.ETH)], "Mode of investment is not ETH");



        uint256 weiAmount = msg.value;

        uint256 refund = _processTx(_beneficiary, weiAmount);

        weiAmount = weiAmount.sub(refund);



        _forwardFunds(refund);

    }



    /**

      * @notice low level token purchase

      * @param _investedPOLY Amount of POLY invested

      */

    function buyTokensWithPoly(uint256 _investedPOLY) public nonReentrant{

        require(!paused, "Should not be paused");

        require(fundRaiseTypes[uint8(FundRaiseType.POLY)], "Mode of investment is not POLY");

        uint256 refund = _processTx(msg.sender, _investedPOLY);

        _forwardPoly(msg.sender, wallet, _investedPOLY.sub(refund));

    }



    /**

    * @notice Checks whether the cap has been reached.

    * @return bool Whether the cap was reached

    */

    function capReached() public view returns (bool) {

        return totalTokensSold >= cap;

    }



    /**

     * @notice Return the total no. of tokens sold

     */

    function getTokensSold() public view returns (uint256) {

        return totalTokensSold;

    }



    /**

     * @notice Return the permissions flag that are associated with STO

     */

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](0);

        return allPermissions;

    }



    /**

     * @notice Return the STO details

     * @return Unixtimestamp at which offering gets start.

     * @return Unixtimestamp at which offering ends.

     * @return Number of token base units this STO will be allowed to sell to investors.

     * @return Token units a buyer gets(multiplied by 10^18) per wei / base unit of POLY

     * @return Amount of funds raised

     * @return Number of individual investors this STO have.

     * @return Amount of tokens get sold.

     * @return Boolean value to justify whether the fund raise type is POLY or not, i.e true for POLY.

     */

    function getSTODetails() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool) {

        return (

            startTime,

            endTime,

            cap,

            rate,

            (fundRaiseTypes[uint8(FundRaiseType.POLY)]) ? fundsRaised[uint8(FundRaiseType.POLY)]: fundsRaised[uint8(FundRaiseType.ETH)],

            investorCount,

            totalTokensSold,

            (fundRaiseTypes[uint8(FundRaiseType.POLY)])

        );

    }



    // -----------------------------------------

    // Internal interface (extensible)

    // -----------------------------------------

    /**

      * Processing the purchase as well as verify the required validations

      * @param _beneficiary Address performing the token purchase

      * @param _investedAmount Value in wei involved in the purchase

    */

    function _processTx(address _beneficiary, uint256 _investedAmount) internal returns(uint256 refund) {



        _preValidatePurchase(_beneficiary, _investedAmount);

        // calculate token amount to be created

        uint256 tokens;

        (tokens, refund) = _getTokenAmount(_investedAmount);

        _investedAmount = _investedAmount.sub(refund);



        // update state

        if (fundRaiseTypes[uint8(FundRaiseType.POLY)]) {

            fundsRaised[uint8(FundRaiseType.POLY)] = fundsRaised[uint8(FundRaiseType.POLY)].add(_investedAmount);

        } else {

            fundsRaised[uint8(FundRaiseType.ETH)] = fundsRaised[uint8(FundRaiseType.ETH)].add(_investedAmount);

        }

        totalTokensSold = totalTokensSold.add(tokens);



        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(msg.sender, _beneficiary, _investedAmount, tokens);

    }



    /**

    * @notice Validation of an incoming purchase.

      Use require statements to revert state when conditions are not met. Use super to concatenate validations.

    * @param _beneficiary Address performing the token purchase

    * @param _investedAmount Value in wei involved in the purchase

    */

    function _preValidatePurchase(address _beneficiary, uint256 _investedAmount) internal view {

        require(_beneficiary != address(0), "Beneficiary address should not be 0x");

        require(_investedAmount != 0, "Amount invested should not be equal to 0");

        /*solium-disable-next-line security/no-block-members*/

        require(now >= startTime && now <= endTime, "Offering is closed/Not yet started");

    }



    /**

    * @notice Source of tokens.

      Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

    * @param _beneficiary Address performing the token purchase

    * @param _tokenAmount Number of tokens to be emitted

    */

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {

        require(ISecurityToken(securityToken).mint(_beneficiary, _tokenAmount), "Error in minting the tokens");

    }



    /**

    * @notice Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

    * @param _beneficiary Address receiving the tokens

    * @param _tokenAmount Number of tokens to be purchased

    */

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

        if (investors[_beneficiary] == 0) {

            investorCount = investorCount + 1;

        }

        investors[_beneficiary] = investors[_beneficiary].add(_tokenAmount);



        _deliverTokens(_beneficiary, _tokenAmount);

    }



    /**

    * @notice Overrides to extend the way in which ether is converted to tokens.

    * @param _investedAmount Value in wei to be converted into tokens

    * @return Number of tokens that can be purchased with the specified _investedAmount

    * @return Remaining amount that should be refunded to the investor

    */

    function _getTokenAmount(uint256 _investedAmount) internal view returns (uint256 tokens, uint256 refund) {

        tokens = _investedAmount.mul(rate);

        tokens = tokens.div(uint256(10) ** 18);

        if (totalTokensSold.add(tokens) > cap) {

            tokens = cap.sub(totalTokensSold);

        }

        uint256 granularity = ISecurityToken(securityToken).granularity();

        tokens = tokens.div(granularity);

        tokens = tokens.mul(granularity);

        require(tokens > 0, "Cap reached");

        refund = _investedAmount.sub((tokens.mul(uint256(10) ** 18)).div(rate));

    }



    /**

    * @notice Determines how ETH is stored/forwarded on purchases.

    */

    function _forwardFunds(uint256 _refund) internal {

        wallet.transfer(msg.value.sub(_refund));

        msg.sender.transfer(_refund);

    }



    /**

     * @notice Internal function used to forward the POLY raised to beneficiary address

     * @param _beneficiary Address of the funds reciever

     * @param _to Address who wants to ST-20 tokens

     * @param _fundsAmount Amount invested by _to

     */

    function _forwardPoly(address _beneficiary, address _to, uint256 _fundsAmount) internal {

        polyToken.transferFrom(_beneficiary, _to, _fundsAmount);

    }



}