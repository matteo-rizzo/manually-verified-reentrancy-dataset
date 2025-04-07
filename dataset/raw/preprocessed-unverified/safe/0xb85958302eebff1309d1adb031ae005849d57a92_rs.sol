/**
 *Submitted for verification at Etherscan.io on 2020-01-16
*/

pragma solidity 0.5.10;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */



/**
  * @author @veronicaLC (Veronica Coutts) & @BenSchZA (Ben Scholtz)
  * @title  The interface for the curve functions.
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