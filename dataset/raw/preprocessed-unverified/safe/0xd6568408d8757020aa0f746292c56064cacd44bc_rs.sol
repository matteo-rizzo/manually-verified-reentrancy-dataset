/**
 *Submitted for verification at Etherscan.io on 2020-04-25
*/

// File: contracts/XIOPortal.sol

pragma solidity 0.5.8;

















contract Pausable is Ownable {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool _paused;

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


contract XIOPortal is Pausable, Initializable {
    using SafeMath for uint256;
    using SafeMath for uint32;

    uint256 interestRate;
    uint256 MAX_UINT;
    uint256 ONE_DAY;
    //stake restriction parameters
    uint256 stakeDays;
    uint256 xioQuantity;

    address public xioExchangeAddress;
    address public xioContractAddress;
    address public uniswapFactoryAddress;

    mapping(address => mapping(uint256 => StakerData)) public stakerData; //address to timestamp to data
    mapping(address => PortalData) public portalData; //address to data
    address[] portalAddresses; //history of portals

    //for testing
    uint256 ONE_MINUTE;
    mapping(address => bool) internal whiteListed;

    struct StakerData {
        uint256 quantity;
        uint256 durationTimestamp;
        uint256 boughAmount;
        bool unstaked;
        address outputTokenAddress;
        address staker;
    }

    struct PortalData {
        uint256 xioStaked;
        bool active;
        address tokenAddress;
        address tokenExchangeAddress;
    }

    event StakeCompleted(
        address staker,
        address outputTokenAddress,
        uint256 xioQuantity,
        uint256 timestamp,
        uint256 duration,
        uint256 altQuantity
    ); // When bought tokens are transferred to staker

    event Unstake(address to, uint256 value); // When tokens are withdrawn

    event PortalAdded(address tokenAddress, address exchangeAddress); // When portals are added

    event PortalRemoved(address tokenAddress); //When portals are removed

    event WhiteListerAdded(address whitelistAccount); //When whitelisters are added

    function initialize() public initializer {
        _paused = false;
        _owner = msg.sender;
        interestRate = 684931506849315;
        MAX_UINT = 2**256 - 1;
        ONE_DAY = 24 * 60 * 60;
        xioExchangeAddress = 0x7B6E5278a14d5318571d65aceD036d09c998C707;
        xioContractAddress = 0x0f7F961648aE6Db43C75663aC7E5414Eb79b5704;
        uniswapFactoryAddress = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
        ONE_MINUTE = 60;
        stakeDays = 15;
        xioQuantity = 5000000000000000000000;
    }

    /* @dev to get interest rate of the portal */
    function getInterestRate() public view returns (uint256) {
        return interestRate;
    }

    /* @dev to get exchange rate of XIO to ETH
     *  @param _amount, xio amount
     */
    function getXIOtoETH(uint256 _amount) public view returns (uint256) {
        return
            UniswapExchangeInterface(xioExchangeAddress)
                .getTokenToEthInputPrice(_amount);
    }

    /* @dev to get exchange rate of ETH to ALT
     *  @param _amount, xio amount
     *  @param _outputTokenAddressExchange, exchange address of output token on uniswap
     */
    function getETHtoALT(uint256 _amount, address _outputTokenAddressExchange)
        public
        view
        returns (uint256)
    {
        return
            UniswapExchangeInterface(_outputTokenAddressExchange)
                .getEthToTokenInputPrice(_amount);
    }

    /* @dev to get portal history
     */
    function getPortalHistory() public view returns (address[] memory) {
        return portalAddresses;
    }

    /* @dev to get number of days in the stake condition
     */
    function getDays() public view returns (uint256) {
        return stakeDays;
    }

    /* @dev to get number of xio quantity user can max stake
     */
    function getxioQuantity() public view returns (uint256) {
        return xioQuantity;
    }


    /* @dev stake function which calls uniswaps exchange to buy output tokens and send them to the user.
     *  @param _xioQuantity, xio interest generated upon the days (in wei)
     *  @param _tokensBought, how much tokens are bought from the uniswaps exchange (in wei)
     *  @param _outputTokenAddress, bought token ERC20 address
     *  @param _days, how much days he has staked (in days)
     */

    function stakeXIO(
        address _outputTokenAddress,
        uint256 _days,
        uint256 _xioQuantity,
        uint256 _tokensBought
    ) public whenNotPaused returns (uint256) {
        require(_days <= stakeDays, "Invalid Days"); // To check days
        require(_xioQuantity <= xioQuantity, "Invalid XIO quantity"); // To verify XIO quantity
        require(_outputTokenAddress != address(0), "0 address not allowed"); // To verify output token address
        require(
            portalData[_outputTokenAddress].tokenAddress != address(0),
            "Portal does not exists"
        ); // To verify portal info
        require(
            portalData[_outputTokenAddress].active == true,
            "Portal is not active"
        );
        require(whiteListed[msg.sender] == true, "Not whitelist address"); //To verify whitelisters

        portalData[_outputTokenAddress]
            .xioStaked = portalData[_outputTokenAddress].xioStaked.add(
            _xioQuantity
        );

        Token(xioContractAddress).transferFrom(
            msg.sender,
            address(this),
            _xioQuantity
        );

        uint256 soldXIO = (_xioQuantity.mul(interestRate).mul(_days)).div(
            1000000000000000000
        );

        uint256 bought = UniswapExchangeInterface(xioExchangeAddress)
            .tokenToTokenSwapInput(
            soldXIO,
            _tokensBought,
            1,
            1839591241,
            _outputTokenAddress
        );

        stakerData[msg.sender][block.timestamp] = StakerData(
            _xioQuantity,
            _days.mul(ONE_DAY),
            bought,
            false,
            _outputTokenAddress,
            msg.sender
        );

        Token(_outputTokenAddress).transfer(msg.sender, bought);
        emit StakeCompleted(
            msg.sender,
            _outputTokenAddress,
            _xioQuantity,
            block.timestamp,
            _days,
            bought
        );
        return bought;
    }

    /* @dev withdrwal function by which user can withdraw their staked xio
     *  @param _timestampArray , those staked timestamp who needs to be processed
     *  @param _amount , xio token quanity user has staked
     */

    function withdrawXIO(uint256[] memory _timestampArray, uint256 _amount)
        public
        whenNotPaused
    {
        require(_amount > 0, "Amount should be greater than 0");
        uint256 withdrawAmount = 0;
        for (uint256 i = 0; i < _timestampArray.length; i++) {
            require(
                    stakerData[msg.sender][_timestampArray[i]]
                        .durationTimestamp !=
                    0,
                "Nothing staked"
            );
            if (
                (_timestampArray[i]
                    .add(
                    stakerData[msg.sender][_timestampArray[i]].durationTimestamp
                ) <= block.timestamp) &&
                (stakerData[msg.sender][_timestampArray[i]].unstaked == false)
            ) {
                if (
                    _amount >
                    stakerData[msg.sender][_timestampArray[i]].quantity
                ) {
                    stakerData[msg.sender][_timestampArray[i]].unstaked = true;
                    _amount = _amount.sub(
                        stakerData[msg.sender][_timestampArray[i]].quantity
                    );
                    withdrawAmount = withdrawAmount.add(
                        stakerData[msg.sender][_timestampArray[i]].quantity
                    );
                    updatePortalData(
                        stakerData[msg.sender][_timestampArray[i]]
                            .outputTokenAddress,
                        stakerData[msg.sender][_timestampArray[i]].quantity
                    );
                    stakerData[msg.sender][_timestampArray[i]].quantity = 0;
                } else if (
                    _amount ==
                    stakerData[msg.sender][_timestampArray[i]].quantity
                ) {
                    stakerData[msg.sender][_timestampArray[i]].unstaked = true;
                    withdrawAmount = withdrawAmount.add(
                        stakerData[msg.sender][_timestampArray[i]].quantity
                    );
                    stakerData[msg.sender][_timestampArray[i]].quantity = 0;
                    updatePortalData(
                        stakerData[msg.sender][_timestampArray[i]]
                            .outputTokenAddress,
                        _amount
                    );
                    break;
                } else if (
                    _amount <
                    stakerData[msg.sender][_timestampArray[i]].quantity
                ) {
                    stakerData[msg.sender][_timestampArray[i]]
                        .quantity = stakerData[msg.sender][_timestampArray[i]]
                        .quantity
                        .sub(_amount);
                    withdrawAmount = withdrawAmount.add(_amount);
                    updatePortalData(
                        stakerData[msg.sender][_timestampArray[i]]
                            .outputTokenAddress,
                        _amount
                    );
                    break;
                }
            }
        }
        require(withdrawAmount != 0, "Not Transferred");
        Token(xioContractAddress).transfer(msg.sender, withdrawAmount);
        emit Unstake(msg.sender, withdrawAmount);
    }

    /* @dev incase of emergency owner can withdraw all the funds */
    function withdrawTokens() public onlyOwner whenNotPaused {
        uint256 balance = Token(xioContractAddress).balanceOf(address(this));
        Token(xioContractAddress).transfer(_owner, balance);
    }

    /* @dev to add portal into the contract
     *  @param _tokenAddress, address of output token
     */
    function addPortal(address _tokenAddress)
        public
        onlyOwner
        whenNotPaused
        returns (address)
    {
        require(_tokenAddress != address(0), "Zero address not allowed");
        require(
            checkPortalExists(_tokenAddress) == true,
            "Portal already exists"
        );
        address exchangeAddress = UniswapFactoryInterface(uniswapFactoryAddress)
            .getExchange(_tokenAddress);
        require(exchangeAddress != address(0));
        portalData[_tokenAddress] = PortalData(
            0,
            true,
            _tokenAddress,
            exchangeAddress
        );
        portalAddresses.push(_tokenAddress);
        emit PortalAdded(_tokenAddress, exchangeAddress);
        return exchangeAddress;
    }

    /* @dev to deactivate portal into the contract
     *  @param _tokenAddress, address of portal token
     */
    function deactivatePortal(address _tokenAddress)
        public
        onlyOwner
        whenNotPaused
        returns (bool)
    {
        require(
            portalData[_tokenAddress].tokenAddress != address(0),
            "Portal does not exist"
        );
        portalData[_tokenAddress].active = false;
        return false;
    }

    /* @dev to activate portal into the contract
     *  @param _tokenAddress, address of portal token
     */
    function activatePortal(address _tokenAddress)
        public
        onlyOwner
        whenNotPaused
        returns (bool)
    {
        require(
            portalData[_tokenAddress].tokenAddress != address(0),
            "Portal does not exist"
        );
        portalData[_tokenAddress].active = true;
        return true;
    }

    /* @dev to set interest rate. Can only be called by owner
     *  @param _rate, interest rate (in wei)
     */
    function setInterestRate(uint256 _rate)
        public
        onlyOwner
        whenNotPaused
        returns (uint256)
    {
        require(_rate != 0, "Rate connot be zero");
        interestRate = _rate;
        return interestRate;
    }

    /* @dev to set days. Can only be called by owner
     *  @param _days, days in number
     */
    function setDays(uint256 _days)
        public
        onlyOwner
        whenNotPaused
        returns (uint256)
    {
        require(_days != 0, "Rate connot be zero");
        stakeDays = _days;
        return stakeDays;
    }

    /* @dev to set xio quantity. Can only be called by owner
     *  @param _quantity, xio quantity (in wei)
     */
    function setXIOquantity(uint256 _quantity)
        public
        onlyOwner
        whenNotPaused
        returns (uint256)
    {
        require(_quantity > 0, "quantity connot be zero");
        xioQuantity = _quantity;
        return xioQuantity;
    }

    /* @dev to allow XIO exchange max XIO tokens from the portal, can only be called by owner */
    function allowXIO() public onlyOwner whenNotPaused {
        Token(xioContractAddress).approve(xioExchangeAddress, MAX_UINT);
    }

    /* @dev to add whitelist addresses // for front end feasiblity
     *  @param __staker, array of staker address
     */
    function addWhiteListAccount(address[] memory _staker)
        public
        onlyOwner
        whenNotPaused
    {
        for (uint8 i = 0; i < _staker.length; i++) {
            require(_staker[i] != address(0), "Zero address not allowed");
            whiteListed[_staker[i]] = true;
            emit WhiteListerAdded(_staker[i]);
        }
    }

    /* @dev to update exchange address
     *  @param _exchangeAddress, xio exchange address
     */
    function setXIOExchangeAddress(address _exchangeAddress)
        public
        onlyOwner
        whenNotPaused
        returns (address)
    {
        require(_exchangeAddress != address(0), "Zero address not allowed");
        xioExchangeAddress = _exchangeAddress;
        return xioExchangeAddress;
    }

    /* @dev to update factory address
     *  @param _factoryAddress, factory address of uniswap
     */
    function setUniswapFactoryAddress(address _factoryAddress)
        public
        onlyOwner
        whenNotPaused
        returns (address)
    {
        require(_factoryAddress != address(0), "Zero address not allowed");
        uniswapFactoryAddress = _factoryAddress;
        return uniswapFactoryAddress;
    }

    /* @dev to update portal data
     *  @param _outputTokenAddress, token address
     *  @param _amount, amount that will be minus from portal
     */
    function updatePortalData(address _outputTokenAddress, uint256 _amount)
        internal
    {
        portalData[_outputTokenAddress]
            .xioStaked = portalData[_outputTokenAddress].xioStaked.sub(_amount);
    }

    /* @dev to check portal if it already exists or not
     *  @param _tokenAddress, address of output token
     */
    function checkPortalExists(address _tokenAddress)
        internal
        view
        returns (bool)
    {
        return portalData[_tokenAddress].tokenAddress == address(0);
    }
}