/**
 *Submitted for verification at Etherscan.io on 2020-01-16
*/

pragma solidity 0.5.10;

/**
  * @author @veronicaLC (Veronica Coutts)
  * @title  The interface for the market factory
  */



/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The interface for the market registry.
  */



/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The interface for the curve registry.
  */


/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The interface for the molecule vault
  */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */



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
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title Market
  */



/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  Storage and collection of market tax.
  * @notice The vault stores the tax from the market until the funding goal is
  *         reached, thereafter the creator may withdraw the funds. If the
  *         funding is not reached within the stipulated time-frame, or the
  *         creator terminates the market, the funding is sent back to the
  *         market to be re-distributed.
  * @dev    The vault pulls the mol tax directly from the molecule vault.
  */


/**
  * @author @veronicaLC (Veronica Coutts) & @BenSchZA (Ben Scholtz)
  * @title  The interface for the curve functions.
  */



// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------



/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */







/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  Creation and storage of project tokens, fills vault with fee.
  * @notice The market will send a portion of all collateral on mint to the
  *         vault to fill the funding rounds.
  * @dev    Checks with vault on every mint to ensure rounds are still active,
  *         goal has not been met, and that the round has not expired.
  */
contract Market is IMarket, IERC20 {
    // For math functions with overflow & underflow checks
    using SafeMath for uint256;

    // Allows market to be deactivated after funding
    bool internal active_ = true;
    // Vault that recives fee
    IVault internal creatorVault_;
    // Percentage of vault fee e.g. 20
    uint256 internal feeRate_;
    // Address of curve function
    ICurveFunctions internal curveLibrary_;
    // Underlying collateral token
    IERC20 internal collateralToken_;
    // Total minted tokens
    uint256 internal totalSupply_;
    // Decimal accuracy of token
    uint256 internal decimals_ = 18;

    // Allowances for spenders
    mapping(address => mapping (address => uint256)) internal allowed;
    // Balances of token holders
    mapping(address => uint256) internal balances;

    /**
	  * @notice	Sets the needed variables for the market
      * @param  _feeRate : The percentage for the fee i.e 20
      * @param  _creatorVault : The vault for fee to go to
      * @param  _curveLibrary : Math module.
      * @param  _collateralToken : The ERC20 collateral tokem
      */
    constructor(
        uint256 _feeRate,
        address _creatorVault,
        address _curveLibrary,
        address _collateralToken
    )
        public
    {
        // Sets the storage variables
        feeRate_ = _feeRate;
        creatorVault_ = IVault(_creatorVault);
        curveLibrary_ = ICurveFunctions(_curveLibrary);
        collateralToken_ = IERC20(_collateralToken);
    }

    /**
      * @notice Ensures the market's key functionality is only available when
      *         the market is active.
      */
    modifier onlyActive(){
        require(active_, "Market inactive");
        _;
    }

    /**
      * @notice Enaures a function is only callable by the vault.
      */
    modifier onlyVault(){
        require(msg.sender == address(creatorVault_), "Invalid requestor");
        _;
    }

    /**
      * @dev    Selling tokens back to the bonding curve for collateral.
      * @param  _numTokens: The number of tokens that you want to burn.
      */
    function burn(uint256 _numTokens) external onlyActive() returns(bool) {
        require(
            balances[msg.sender] >= _numTokens,
            "Not enough tokens available"
        );

        uint256 reward = rewardForBurn(_numTokens);

        totalSupply_ = totalSupply_.sub(_numTokens);
        balances[msg.sender] = balances[msg.sender].sub(_numTokens);

        require(
            collateralToken_.transfer(
                msg.sender,
                reward
            ),
            "Tokens not sent"
        );

        emit Transfer(msg.sender, address(0), _numTokens);
        emit Burn(msg.sender, _numTokens, reward);
        return true;
    }

    /**
      * @dev	We have modified the minting function to divert a portion of the
      *         collateral for the purchased tokens to the vault. 
      * @notice If a mint transaction exceeded the needed funding for the last
      *         round, the excess funds WILL NOT BE RETURNED TO SENDER. The
      *         Molecule Catalyst front end prevents this.
      *         The curve intergral code will reject any values that are too
      *         small or large, that could result in over/under flows.
      * @param  _to : Address to mint tokens to.
      * @param  _numTokens : The number of tokens you want to mint.
      */
    function mint(
        address _to,
        uint256 _numTokens
    )
        external
        onlyActive()
        returns(bool)
    {
        // Gets the price (in collateral) for the tokens
        uint256 priceForTokens = priceToMint(_numTokens);
        
        // Ensures there is no overflow
        require(priceForTokens > 0, "Tokens requested too low");

        // Works out how much fee needs to be sent to the vault
        uint256 fee = priceForTokens.mul(feeRate_).div(100);
        // Sends the collateral from the buyer to this market
        require(
            collateralToken_.transferFrom(
                msg.sender,
                address(this),
                priceForTokens
            ),
            "Collateral transfer failed"
        );
        // Sends the fee to the vault
        require(
            collateralToken_.transfer(
                address(creatorVault_),
                fee
            ),
            "Vault fee not transferred"
        );

        // Adds the tokens to the total supply
        totalSupply_ = totalSupply_.add(_numTokens);
        // Adds the tokens to the balance of the buyer
        balances[msg.sender] = balances[msg.sender].add(_numTokens);
        // Validates the funding with the vault
        require(
            creatorVault_.validateFunding(fee),
            "Funding validation failed"
        );
        // Works out the vaule of the tokens without the fee
        uint256 priceWithoutFee = priceForTokens.sub(fee);

        emit Transfer(address(0), _to, _numTokens);
        emit Mint(_to, _numTokens, priceWithoutFee, fee);
        return true;
    }

	    /**
      * @notice This function returns the amount of tokens one can receive for a
      *         specified amount of collateral token.
      * @param  _collateralTokenOffered : Amount of reserve token offered for
      *         purchase.
      * @return uint256 : The amount of tokens once can purchase with the
      *         specified collateral.
      */
    function collateralToTokenBuying(
        uint256 _collateralTokenOffered
    )
        external
        view
        returns(uint256)
    {
        // Works out the amount of collateral for fee
        uint256 fee = _collateralTokenOffered.mul(feeRate_).div(100);
        // Removes the fee amount from the collateral offered
        uint256 amountLessFee = _collateralTokenOffered.sub(fee);
        // Works out the inverse curve of the pool with the fee removed amount
        return _inverseCurveIntegral(
                _curveIntegral(totalSupply_).add(amountLessFee)
            ).sub(totalSupply_);
    }

    /**
      * @notice This function returns the amount of tokens needed to be burnt to
      *         withdraw a specified amount of reserve token.
      * @param  _collateralTokenNeeded : Amount of dai to be withdraw.
      */
    function collateralToTokenSelling(
        uint256 _collateralTokenNeeded
    )
        external
        view
        returns(uint256)
    {
        return uint256(
            totalSupply_.sub(
                _inverseCurveIntegral(
                    _curveIntegral(totalSupply_).sub(_collateralTokenNeeded)
                )
            )
        );
    }

    /**
      * @notice Total collateral backing the curve.
      * @return uint256 : Represents the total collateral backing the curve.
      */
    function poolBalance() external view returns (uint256){
        return collateralToken_.balanceOf(address(this));
    }

    /**
      * @dev 	The rate of fee the market pays towards the vault on token
	  *         purchases.
      */
    function feeRate() external view returns(uint256) {
        return feeRate_;
    }

    /**
      * @return	uint256 : The decimals set for the market
      */
    function decimals() external view returns(uint256) {
        return decimals_;
    }

    /**
      * @return	bool : The active stat of the market. Inactive markets have
	  *         ended.
      */
    function active() external view returns(bool){
        return active_;
    }

    /**
	  * @notice	Can only be called by this markets vault
      * @dev    Allows the market to end once all funds have been raised.
      *         Ends the market so that no more tokens can be bought or sold.
	  *			Tokens can still be transfered, or "withdrawn" for an enven
	  *			distribution of remaining collateral.
      */
    function finaliseMarket() public onlyVault() returns(bool) {
        require(active_, "Market deactivated");
        active_ = false;
        emit MarketTerminated();
        return true;
    }

    /**
      * @dev    Allows token holders to withdraw collateral in return for tokens
      * 		after the market has been finalised.
      * @param 	_amount: The amount of tokens they want to withdraw
      */
    function withdraw(uint256 _amount) public returns(bool) {
        // Ensures withdraw can only be called in an inactive market
        require(!active_, "Market not finalised");
        // Ensures the sender has enough tokens
        require(_amount <= balances[msg.sender], "Insufficient funds");
        // Ensures there are no anomaly withdraws that might break calculations
        require(_amount > 0, "Cannot withdraw 0");

        // Removes amount from user balance
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        // Gets the balance of the market (vault may send excess funding)
        uint256 balance = collateralToken_.balanceOf(address(this));

        // Performs a flat linear 100% collateralized sale
        uint256 collateralToTransfer = balance.mul(_amount).div(totalSupply_);
        // Removes token amount from the total supply
        totalSupply_ = totalSupply_.sub(_amount);

        // Ensures the sender is sent their collateral amount
        require(
            collateralToken_.transfer(msg.sender, collateralToTransfer),
            "Dai transfer failed"
        );

        emit Transfer(msg.sender, address(0), _amount);
        emit Burn(msg.sender, _amount, collateralToTransfer);

        return true;
    }

    /**
	  * @dev	Returns the required collateral amount for a volume of bonding
	  *			curve tokens.
      * @notice The curve intergral code will reject any values that are too
      *         small or large, that could result in over/under flows.
	  * @param	_numTokens: The number of tokens to calculate the price of
      * @return uint256 : The required collateral amount for a volume of bonding
      *         curve tokens.
      */
    function priceToMint(uint256 _numTokens) public view returns(uint256) {
        // Gets the balance of the market
        uint256 balance = collateralToken_.balanceOf(address(this));
        // Performs the curve intergral with the relavant vaules
        uint256 collateral = _curveIntegral(
                totalSupply_.add(_numTokens)
            ).sub(balance);
        // Sets the base unit for decimal shift
        uint256 baseUnit = 100;
        // Adds the fee amount
        uint256 result = collateral.mul(100).div(baseUnit.sub(feeRate_));
        return result;
    }

    /**
	  * @dev	Returns the required collateral amount for a volume of bonding
	  *			curve tokens
	  * @param	_numTokens: The number of tokens to work out the collateral
	  *			vaule of
      * @return uint256: The required collateral amount for a volume of bonding
      *         curve tokens
      */
    function rewardForBurn(uint256 _numTokens) public view returns(uint256) {
        // Gets the curent balance of the market
        uint256 poolBalanceFetched = collateralToken_.balanceOf(address(this));
        // Returns the pool balance minus the curve intergral of the removed
        // tokens
        return poolBalanceFetched.sub(
            _curveIntegral(totalSupply_.sub(_numTokens))
        );
    }

    /**
      * @dev    Calculate the integral from 0 to x tokens supply. Calls the
      *         curve integral function on the math library.
      * @param  _x : The number of tokens supply to integrate to.
      * @return he total supply in tokens, not wei.
      */
    function _curveIntegral(uint256 _x) internal view returns (uint256) {
        return curveLibrary_.curveIntegral(_x);
    }

    /**
      * @dev    Inverse integral to convert the incoming colateral value to
      *         token volume.
      * @param  _x : The volume to identify the root off
      */
    function _inverseCurveIntegral(uint256 _x) internal view returns(uint256) {
        return curveLibrary_.inverseCurveIntegral(_x);
    }

	//--------------------------------------------------------------------------
	// ERC20 functions
	//--------------------------------------------------------------------------

	/**
      * @notice Total number of tokens in existence
      * @return uint256: Represents the total supply of tokens in this market.
      */
    function totalSupply() external view returns (uint256) {
        return totalSupply_;
    }

	/**
      * @notice Gets the balance of the specified address.
      * @param  _owner : The address to query the the balance of.
      * @return  uint256 : Represents the amount owned by the passed address.
      */
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

	/**
      * @notice Gets the value of the current allowance specifed for that
      *         account.
      * @param  _owner: The account sending the funds.
      * @param  _spender: The account that will receive the funds.
	  * @return	uint256: representing the amount the spender can spend
      */
    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
      * @notice Approves transfers for a given address.
      * @param  _spender : The account that will receive the funds.
      * @param  _value : The value of funds accessed.
      * @return boolean : Indicating the action was successful.
      */
    function approve(
        address _spender,
        uint256 _value
    )
        external
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
      * @dev    Atomically increases the allowance granted to `spender` by the
      *         caller.
      * @notice This is an alternative to {approve} that can be used as a
      *         mitigation for problems described in {IERC20-approve}.
      */
    function increaseAllowance(
        address _spender,
        uint256 _addedValue
    )
        public
        returns(bool) 
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender]
            .add(_addedValue);
        emit Approval(msg.sender, _spender, _addedValue);
        return true;
    }

    /**
      * @dev    Atomically decreases the allowance granted to `spender` by the
      *         caller.
      * @notice This is an alternative to {approve} that can be used as a
      *         mitigation for problems described in {IERC20-approve}.
      */
    function decreaseAllowance(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns(bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender]
            .sub(_subtractedValue);
        emit Approval(msg.sender, _spender, _subtractedValue);
        return true;
    }

	/**
      * @notice Transfer tokens from one address to another.
      * @param  _from : The address which you want to send tokens from.
      * @param  _to : The address which you want to transfer to.
      * @param  _value : The amount of tokens to be transferred.
      */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_value <= balances[_from], "Requested amount exceeds balance");
        require(_value <= allowed[_from][msg.sender], "Allowance exceeded");
        require(_to != address(0), "Target account invalid");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

	/**
      * @notice Transfer ownership token from msg.sender to a specified address.
      * @param  _to : The address to transfer to.
      * @param  _value : The amount to be transferred.
      */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender], "Insufficient funds");
        require(_to != address(0), "Target account invalid");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}


/**
  * @title  ModifiedWhitelistAdminRole
  * @dev    WhitelistAdmins are responsible for assigning and removing 
  *         Whitelisted accounts.
  */
contract ModifiedWhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;
    // this is a uint8 rather than a 256 for storage. 
    uint8 internal noOfAdmins_;
    // Initial admin address 
    address internal initialAdmin_;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
        initialAdmin_ = msg.sender;
    }

    modifier onlyWhitelistAdmin() {
        require(
            isWhitelistAdmin(msg.sender), 
            "ModifiedWhitelistAdminRole: caller does not have the WhitelistAdmin role"
        );
        _;
    }

    /**
      * @dev    This allows for the initial admin added to have additional admin
      *         rights, such as removing another admin. 
      */
    modifier onlyInitialAdmin() {
        require(
            msg.sender == initialAdmin_,
            "Only initial admin may remove another admin"
        );
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin() {
        _addWhitelistAdmin(account);
    }

    /**
      * @dev    This allows the initial admin to replace themselves as the super
      *         admin.
      * @param  account: The address of the new super admin
      */
    function addNewInitialAdmin(address account) public onlyInitialAdmin() {
        if(!isWhitelistAdmin(account)) {
            _addWhitelistAdmin(account);
        }
        initialAdmin_ = account;
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    /**
      * @dev    Allows the super admin to remover other admins
      * @param  account: The address of the admin to be removed
      */
    function removeWhitelistAdmin(address account) public onlyInitialAdmin() {
        _removeWhitelistAdmin(account);
    }

    function _addWhitelistAdmin(address account) internal {
        if(!isWhitelistAdmin(account)) {
            noOfAdmins_ += 1;
        }
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        noOfAdmins_ -= 1;
        require(noOfAdmins_ >= 1, "Cannot remove all admins");
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    function getAdminCount() public view returns(uint8) {
        return noOfAdmins_;
    }
}








/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  Storage and collection of market fee.
  * @notice The vault stores the fee from the market until the funding goal is
  *         reached, thereafter the creator may withdraw the funds. If the
  *         funding is not reached within the stipulated time-frame, or the
  *         creator terminates the market, the funding is sent back to the
  *         market to be re-distributed.
  * @dev    The vault pulls the mol fee directly from the molecule vault.
  */
contract Vault is IVault, ModifiedWhitelistAdminRole {
    // For math functions with overflow & underflow checks
    using SafeMath for uint256;
    // For keep track of time in months
    using BokkyPooBahsDateTimeLibrary for uint256;

    // The vault benificiary
    address internal creator_;
    // Market feeds collateral to vault
    IMarket internal market_;
    // Underlying collateral token
    IERC20 internal collateralToken_;
    // Vault for molecule fee
    IMoleculeVault internal moleculeVault_;
    // Fee percentage for molecule fee, i.e 50
    uint256 internal moleculeFeeRate_;
    // The funding round that is active
    uint256 internal currentPhase_;
    // Offset for checking funding threshold
    uint256 internal outstandingWithdraw_;
    // The total number of funding rounds
    uint256 internal totalRounds_;
    // The total cumulative fee received from market
    uint256 internal cumulativeReceivedFee_;
    // If the vault has been initialized and has not reached its funding goal
    bool internal _active;
    
    // All funding phases information to their position in mapping
    mapping(uint256 => FundPhase) internal fundingPhases_;

    // Information stored about each phase
    struct FundPhase{
        uint256 fundingThreshold;   // Collateral limit to trigger funding
        uint256 cumulativeFundingThreshold; // The cumulative funding goals
        uint256 fundingRaised;      // The amount of funding raised
        uint256 phaseDuration;      // Period of time for round (start to end)
        uint256 startDate;
        FundingState state;         // State enum
    }

    /**
      * @dev    Checks the range of funding rounds (1-9). Gets the Molecule fee
      *         from the molecule vault directly.
      * @notice Any change in the fee rate in the Molecule Vault will not affect
      *         already deployed vaults. This was done to ensure transparency
      *         and trust in the fee rates.
      * @param  _fundingGoals: The collateral goal for each funding round.
      * @param  _phaseDurations: The time limit of each funding round.
      * @param  _creator: The creator
      * @param  _collateralToken: The ERC20 collateral token
      * @param  _moleculeVault: The molecule vault
      */
    constructor(
        uint256[] memory _fundingGoals,
        uint256[] memory _phaseDurations,
        address _creator,
        address _collateralToken,
        address _moleculeVault
    )
        public
        ModifiedWhitelistAdminRole()
    {
        require(_fundingGoals.length > 0, "No funding goals specified");
        require(_fundingGoals.length < 10, "Too many phases defined");
        require(
            _fundingGoals.length == _phaseDurations.length,
            "Invalid phase configuration"
        );

        // Storing variables in storage
        super.addNewInitialAdmin(_creator);
        outstandingWithdraw_ = 0;
        creator_ = _creator;
        collateralToken_ = IERC20(_collateralToken);
        moleculeVault_ = IMoleculeVault(_moleculeVault);
        moleculeFeeRate_ = moleculeVault_.feeRate();

        // Saving the funding rounds into storage
        uint256 loopLength = _fundingGoals.length;
        for(uint8 i = 0; i < loopLength; i++) {
            if(moleculeFeeRate_ == 0) {
                fundingPhases_[i].fundingThreshold = _fundingGoals[i];
            } else {
                // Works out the rounds fee
                uint256 withFee = _fundingGoals[i].add(
                    _fundingGoals[i].mul(moleculeFeeRate_).div(100)
                );
                // Saving the funding threshold with fee
                fundingPhases_[i].fundingThreshold = withFee;
            }
            // Setting the amount of funding raised so far
            fundingPhases_[i].fundingRaised = 0;
            // Setting the phase duration
            fundingPhases_[i].phaseDuration = _phaseDurations[i];
            // Counter for the total number of rounds
            totalRounds_ = totalRounds_.add(1);
        }

        // Sets the start time to the current time
        fundingPhases_[0].startDate = block.timestamp;
        // Setting the state of the current phase to started
        fundingPhases_[0].state = FundingState.STARTED;
        // Setting the storage of the current phase
        currentPhase_ = 0;
    }

    /**
      * @notice Ensures that only the market may call the function.
      */
    modifier onlyMarket() {
        require(msg.sender == address(market_), "Invalid requesting account");
        _;
    }

    /**
      * @notice Ensures that the vault gets initialized before use.
      */
    modifier isActive() {
        require(_active, "Vault has not been initialized.");
        _;
    }

    /**
      * @dev    Initialized the contract, sets up owners and gets the market
      *         address. This function exists because the Vault does not have
      *         an address until the constructor has finished running. The
      *         cumulative funding threshold is set here because of gas issues
      *         within the constructor.
      * @param _market: The market that will be sending this vault it's
      *         collateral.
      */
    function initialize(
        address _market
    )
        external
        onlyWhitelistAdmin()
        returns(bool)
    {
        require(_market != address(0), "Contracts initialized");
        // Stores the market in storage 
        market_ = IMarket(_market); 
        // Removes the market factory contract as an admin
        super.renounceWhitelistAdmin();

        // Adding all previous rounds funding goals to the cumulative goal
        for(uint8 i = 0; i < totalRounds_; i++) {
            if(i == 0) {
                fundingPhases_[i].cumulativeFundingThreshold.add(
                    fundingPhases_[i].fundingThreshold
                );
            }
            fundingPhases_[i].cumulativeFundingThreshold.add(
                fundingPhases_[i-1].cumulativeFundingThreshold
            );
        }
        _active = true;

        return true;
    }

    /**
      * @notice Allows the creator to withdraw a round of funding.
      * @dev    The withdraw function should be called after each funding round
      *         has been successfully filled. If the withdraw is called after the
      *         last round has ended, the market will terminate and any
      *         remaining funds will be sent to the market.
      * @return bool : The funding has successfully been transferred.
      */
    function withdraw()
        external
        isActive()
        onlyWhitelistAdmin()
        returns(bool)
    {
        require(outstandingWithdraw_ > 0, "No funds to withdraw");

        for(uint8 i; i <= totalRounds_; i++) {
            if(fundingPhases_[i].state == FundingState.PAID) {
                continue;
            } else if(fundingPhases_[i].state == FundingState.ENDED) {
                // Removes this rounds funding from the outstanding withdraw
                outstandingWithdraw_ = outstandingWithdraw_.sub(
                    fundingPhases_[i].fundingThreshold
                );
                // Sets the rounds funding to be paid
                fundingPhases_[i].state = FundingState.PAID;

                uint256 molFee = fundingPhases_[i].fundingThreshold
                    .mul(moleculeFeeRate_)
                    .div(moleculeFeeRate_.add(100));
                // Transfers the mol fee to the molecule vault
                require(
                    collateralToken_.transfer(address(moleculeVault_), molFee),
                    "Tokens not transfer"
                );

                // Working out the original funding goal without the mol fee
                uint256 creatorAmount = fundingPhases_[i].fundingThreshold
                    .sub(molFee);

                // Sending the creator their collateral amount
                require(
                    collateralToken_.transfer(msg.sender, creatorAmount),
                    "Tokens not transfer"
                );
                
                emit FundingWithdrawn(i, creatorAmount);
            } else {
                break;
            }
        }

        // This checks if the current round is the last round, if it is, it
        // terminates the market and sends all remaining funds to the market.
        if(
            fundingPhases_[currentPhase_].state == FundingState.NOT_STARTED
        ) {
            if(market_.active() && outstandingWithdraw_ == 0) {
                // This will transfer any remaining funding to the market
                terminateMarket();
            }
        }
        return true;
    }

    /**
      * @notice Allows the market to check that the funding round(s) have not
      *         been completed, and that the market is still open.
      * @dev    This function will terminate the market if the time for the
      *         round is exceeded. This will loose any funding the creator has
      *         not withdrawn.
      * @param  _receivedFunding: The amount of funding received
      * @return bool: Whether or not the funding is valid
      */
    function validateFunding(
        uint256 _receivedFunding
    )
        external
        isActive()
        onlyMarket()
        returns(bool)
    {
        require(
            fundingPhases_[currentPhase_].state == FundingState.STARTED,
            "Funding inactive"
        );

        // Works out the time the phase should end
        uint256 endOfPhase = fundingPhases_[currentPhase_].startDate
            .addMonths(fundingPhases_[currentPhase_].phaseDuration);
        // Invalidates mint in market if the rounds time has expired.
        if(endOfPhase <= block.timestamp) {
            terminateMarket();
            return false;
        }

        // Gets the balance of the vault against the collateral token
        uint256 balance = collateralToken_.balanceOf(address(this));
        // Adds the fee to the funding raised for this round
        fundingPhases_[currentPhase_]
            .fundingRaised = fundingPhases_[currentPhase_]
            .fundingRaised.add(_receivedFunding);
        // Adds received funding to the cumulative record of fee received
        cumulativeReceivedFee_.add(_receivedFunding);

        // Ensures the total fee received finishes the current round
        if(
            fundingPhases_[currentPhase_].cumulativeFundingThreshold <=
                cumulativeReceivedFee_ &&
            balance.sub(outstandingWithdraw_) >=
                fundingPhases_[currentPhase_].fundingThreshold
        ) {
            // Ensures that the round has been funded correctly
            assert(
                fundingPhases_[currentPhase_].fundingRaised >=
                fundingPhases_[currentPhase_].fundingThreshold
            );
            // end current round will check if there is excess funding and add
            // it to the next round, as well as incrementing the current round
            _endCurrentRound();
            // Checks if the funding raised is larger than this rounds goal
            if(
                fundingPhases_[currentPhase_].fundingRaised >
                fundingPhases_[currentPhase_].fundingThreshold
            ) {
                // Ends the round
                _endCurrentRound();
                // Ensures the received funding does not finish any other rounds
                do {
                    // checks if the next funding rounds cumulative funding goal
                    // is completed
                    if(
                        fundingPhases_[currentPhase_]
                            .cumulativeFundingThreshold <=
                            cumulativeReceivedFee_ &&
                        balance.sub(outstandingWithdraw_) >=
                        fundingPhases_[currentPhase_].fundingThreshold
                    ) {
                        _endCurrentRound();
                    } else {
                        break;
                    }
                } while(currentPhase_ < totalRounds_);
            }
        }
        return true;
    }

    /**
      * @dev    This function sends the vaults funds to the market, and sets the
      *         outstanding withdraw to 0.
      * @notice If this function is called before the end of all phases, all
      *         unclaimed (outstanding) funding will be sent to the market to be
      *         redistributed.
      */
    function terminateMarket()
        public
        isActive()
        onlyWhitelistAdmin()
    {
        uint256 remainingBalance = collateralToken_.balanceOf(address(this));
        // This ensures that if the creator has any outstanding funds, that
        // those funds do not get sent to the market.
        if(outstandingWithdraw_ > 0) {
            remainingBalance = remainingBalance.sub(outstandingWithdraw_);
        }
        // Transfers remaining balance to the market
        require(
            collateralToken_.transfer(address(market_), remainingBalance),
            "Transfering of funds failed"
        );
        // Finalizes market (stops buys/sells distributes collateral evenly)
        require(market_.finaliseMarket(), "Market termination error");
    }

    /**
      * @notice Returns all the details (relevant to external code) for a
      *         specific phase.
      * @param  _phase: The phase that you want the information of
      * @return uint256: The funding goal (including mol tax) of the round
      * @return uint256: The amount of funding currently raised for the round
      * @return uint256: The duration of the phase
      * @return uint256: The timestamp of the start date of the round
      * @return FundingState: The enum state of the round (see IVault)
      */
    function fundingPhase(
        uint256 _phase
    )
        public
        view
        returns(
            uint256,
            uint256,
            uint256,
            uint256,
            FundingState
        ) {
        return (
            fundingPhases_[_phase].fundingThreshold,
            fundingPhases_[_phase].fundingRaised,
            fundingPhases_[_phase].phaseDuration,
            fundingPhases_[_phase].startDate,
            fundingPhases_[_phase].state
        );
    }

    /**
	  * @return	uint256: The amount of funding that the creator has earned by
	  *			not withdrawn.
	  */
    function outstandingWithdraw() public view returns(uint256) {
        uint256 minusMolFee = outstandingWithdraw_
            .sub(outstandingWithdraw_
                .mul(moleculeFeeRate_)
                .div(moleculeFeeRate_.add(100))
            );
        return minusMolFee;
    }

    /**
      * @dev    The current active phase of funding
      * @return uint256: The current phase the project is in.
      */
    function currentPhase() public view returns(uint256) {
        return currentPhase_;
    }

    /**
      * @return uint256: The total number of rounds for this project.
      */
    function getTotalRounds() public view returns(uint256) {
        return totalRounds_;
    }

    /**
	  * @return	address: The address of the market that is funding this vault.
	  */
    function market() public view returns(address) {
        return address(market_);
    }

    /**
	  * @return	address: The address of the creator of this project.
	  */
    function creator() external view returns(address) {
        return creator_;
    }

    /**
      * @dev    Ends the round, increments to the next round, rolls-over excess
      *         funding, sets the start date of the next round, if there is one.
      */
    function _endCurrentRound() internal {
        // Setting active phase state to ended
        fundingPhases_[currentPhase_].state = FundingState.ENDED;
        // Works out the excess funding for the round
        uint256 excess = fundingPhases_[currentPhase_]
            .fundingRaised.sub(fundingPhases_[currentPhase_].fundingThreshold);
        // If there is excess, adds it to the next round
        if (excess > 0) {
            // Adds the excess funding into the next round.
            fundingPhases_[currentPhase_.add(1)]
                .fundingRaised = fundingPhases_[currentPhase_.add(1)]
                .fundingRaised.add(excess);
            // Setting the current rounds funding raised to the threshold
            fundingPhases_[currentPhase_]
                .fundingRaised = fundingPhases_[currentPhase_].fundingThreshold;
        }
        // Adding the funished rounds funding to the outstanding withdraw.
        outstandingWithdraw_ = outstandingWithdraw_
            .add(fundingPhases_[currentPhase_].fundingThreshold);
        // Incrementing the current phase
        currentPhase_ = currentPhase_ + 1;
        // Set the states the start time, starts the next round if there is one.
        if(fundingPhases_[currentPhase_].fundingThreshold > 0) {
            // Setting active phase state to Started
            fundingPhases_[currentPhase_].state = FundingState.STARTED;
            // This works out the end time of the previous round
            uint256 endTime = fundingPhases_[currentPhase_
                .sub(1)].startDate
                .addMonths(fundingPhases_[currentPhase_].phaseDuration);
            // This works out the remaining time
            uint256 remaining = endTime.sub(block.timestamp);
            // This sets the start date to the end date of the previous round
            fundingPhases_[currentPhase_].startDate = block.timestamp
                .add(remaining);
        }

        emit PhaseFinalised(
            currentPhase_.sub(1),
            fundingPhases_[currentPhase_.sub(1)].fundingThreshold
        );
    }
}




// import { WhitelistedRole } from "openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";





/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The creation and co-ordinated storage of markets (a vault and
  *         market).
  * @notice The market factory stores the addresses in the relevant registry.
  */
contract MarketFactory is IMarketFactory, ModifiedWhitelistAdminRole {
    //The molecule vault for molecule fee
    IMoleculeVault internal moleculeVault_;
    //The registry of all created markets
    IMarketRegistry internal marketRegistry_;
    //The registry of all curve types
    ICurveRegistry internal curveRegistry_;
    //The ERC20 collateral token contract address
    IERC20 internal collateralToken_;
    // Address of market deployer
    address internal marketCreator_;
    // The init function can only be called once 
    bool internal isInitialized_  = false;

    event NewApiAddressAdded(address indexed oldAddress, address indexed newAddress);

    modifier onlyAnAdmin() {
        require(isInitialized_, "Market factory has not been activated");
        require(
            isWhitelistAdmin(msg.sender) || msg.sender == marketCreator_,
            "Functionality restricted to whitelisted admin"
        );
        _;
    }

    /**
      * @dev    Sets variables for market deployments.
      * @param  _collateralToken Address of the ERC20 collateral token
      * @param  _moleculeVault   The address of the molecule fee vault
      * @param  _marketRegistry  Address of the registry of all markets
      * @param  _curveRegistry   Address of the registry of all curve types
      *         funding rounds.
      */
    constructor(
        address _collateralToken,
        address _moleculeVault,
        address _marketRegistry,
        address _curveRegistry
    )
        ModifiedWhitelistAdminRole()
        public
    {
        collateralToken_ = IERC20(_collateralToken);
        moleculeVault_ = IMoleculeVault(_moleculeVault);
        marketRegistry_ = IMarketRegistry(_marketRegistry);
        curveRegistry_ = ICurveRegistry(_curveRegistry);
    }

    /**
      * @notice Inits the market factory
      * @param  _admin The address of the admin contract manager
      * @param  _api The address of the backend market deployer
      */
    function init(
        address _admin,
        address _api
    )
        onlyWhitelistAdmin()
        public
    {
        super.addNewInitialAdmin(_admin);
        marketCreator_ = _api;
        super.renounceWhitelistAdmin();
        isInitialized_ = true;
    }

    function updateApiAddress(
        address _newApiPublicKey
    ) 
        onlyWhitelistAdmin() 
        public 
        returns(address)
    {
        address oldMarketCreator = marketCreator_;
        marketCreator_ = _newApiPublicKey;

        emit NewApiAddressAdded(oldMarketCreator, marketCreator_);
        return _newApiPublicKey;
    }

    /**
      * @notice This function allows for the creation of a new market,
      *         consisting of a curve and vault. If the creator address is the
      *         same as the deploying address the market the initialization of
      *         the market will fail.
      * @dev    Vyper cannot handle arrays of unknown length, and thus the
      *         funding goals and durations will only be stored in the vault,
      *         which is Solidity.
      * @param  _fundingGoals This is the amount wanting to be raised in each
      *         round, in collateral.
      * @param  _phaseDurations The time for each round in months. This number
      *         is covered into block time within the vault.
      * @param  _creator Address of the researcher.
      * @param  _curveType Curve selected.
      * @param  _feeRate The percentage of fee. e.g: 60
      */
    function deployMarket(
        uint256[] calldata _fundingGoals,
        uint256[] calldata _phaseDurations,
        address _creator,
        uint256 _curveType,
        uint256 _feeRate
    )
        external
        onlyAnAdmin()
    {
        // Breaks down the return of the curve data
        (address curveLibrary,, bool curveState) = curveRegistry_.getCurveData(
            _curveType
        );

        require(_feeRate > 0, "Fee rate too low");
        require(_feeRate < 100, "Fee rate too high");
        require(_creator != address(0), "Creator address invalid");
        require(curveState, "Curve inactive");
        require(curveLibrary != address(0), "Curve library invalid");
        
        address newVault = address(new Vault(
            _fundingGoals,
            _phaseDurations,
            _creator,
            address(collateralToken_),
            address(moleculeVault_)
        ));

        address newMarket = address(new Market(
            _feeRate,
            newVault,
            curveLibrary,
            address(collateralToken_)
        ));

        require(Vault(newVault).initialize(newMarket), "Vault not initialized");
        marketRegistry_.registerMarket(newMarket, newVault, _creator);
    }

    /**
      * @notice This function will only affect new markets, and will not update
      *         already created markets. This can only be called by an admin
      */
    function updateMoleculeVault(
        address _newMoleculeVault
    )
        public
        onlyWhitelistAdmin()
    {
        moleculeVault_ = IMoleculeVault(_newMoleculeVault);
    }

    /**
      * @return address: The address of the molecule vault
      */
    function moleculeVault() public view returns(address) {
        return address(moleculeVault_);
    }

    /**
      * @return address: The contract address of the market registry.
      */
    function marketRegistry() public view returns(address) {
        return address(marketRegistry_);
    }

    /**
      * @return address: The contract address of the curve registry
      */
    function curveRegistry() public view returns(address) {
        return address(curveRegistry_);
    }

    /**
      * @return address: The contract address of the collateral token
      */
    function collateralToken() public view returns(address) {
        return address(collateralToken_);
    }
}