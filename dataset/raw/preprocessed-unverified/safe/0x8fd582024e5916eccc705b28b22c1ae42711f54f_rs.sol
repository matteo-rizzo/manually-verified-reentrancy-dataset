pragma solidity 0.6.12;// SPDX-License-Identifier: MIT



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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








contract Vesting is Ownable {
    uint256 public startDate;
    uint256 internal constant periodLength = 30 days;
    uint256[35] public cumulativeAmountsToVest;
    uint256 public totalPercentages;
    IERC20 internal token;

    struct Recipient {
        uint256 withdrawnAmount;
        uint256 withdrawPercentage;
    }

    uint256 public totalRecipients;
    mapping(address => Recipient) public recipients;

    event LogStartDateSet(address setter, uint256 startDate);
    event LogRecipientAdded(address recipient, uint256 withdrawPercentage);
    event LogTokensClaimed(address recipient, uint256 amount);

    /*
     * Note: Percentages will be provided in thousands to represent 3 digits after the decimal point.
     * Ex. 10% = 10000
     */
    modifier onlyValidPercentages(uint256 _percentage) {
        require(
            _percentage < 100000,
            "Provided percentage should be less than 100%"
        );
        require(
            _percentage > 0,
            "Provided percentage should be greater than 0"
        );
        _;
    }

    /**
     * @param _tokenAddress The address of the ALBT token
     * @param _cumulativeAmountsToVest The cumulative amounts for each vesting period
     */
    constructor(
        address _tokenAddress,
        uint256[35] memory _cumulativeAmountsToVest
    ) public {
        require(
            _tokenAddress != address(0),
            "Token Address can't be zero address"
        );
        token = IERC20(_tokenAddress);
        cumulativeAmountsToVest = _cumulativeAmountsToVest;
    }

    /**
     * @dev Function that sets the start date of the Vesting
     * @param _startDate The start date of the veseting presented as a timestamp
     */
    function setStartDate(uint256 _startDate) public onlyOwner {
        require(_startDate >= now, "Start Date can't be in the past");

        startDate = _startDate;
        emit LogStartDateSet(address(msg.sender), _startDate);
    }

    /**
     * @dev Function add recipient to the vesting contract
     * @param _recipientAddress The address of the recipient
     * @param _withdrawPercentage The percentage that the recipient should receive in each vesting period
     */
    function addRecipient(
        address _recipientAddress,
        uint256 _withdrawPercentage
    ) public onlyOwner onlyValidPercentages(_withdrawPercentage) {
        require(
            _recipientAddress != address(0),
            "Recepient Address can't be zero address"
        );
        totalPercentages = totalPercentages + _withdrawPercentage;
        require(totalPercentages <= 100000, "Total percentages exceeds 100%");
        totalRecipients++;

        recipients[_recipientAddress] = Recipient(0, _withdrawPercentage);
        emit LogRecipientAdded(_recipientAddress, _withdrawPercentage);
    }

    /**
     * @dev Function add  multiple recipients to the vesting contract
     * @param _recipients Array of recipient addresses. The arrya length should be less than 230, otherwise it will overflow the gas limit
     * @param _withdrawPercentages Corresponding percentages of the recipients
     */
    function addMultipleRecipients(
        address[] memory _recipients,
        uint256[] memory _withdrawPercentages
    ) public onlyOwner {
        require(
            _recipients.length < 230,
            "The recipients must be not more than 230"
        );
        require(
            _recipients.length == _withdrawPercentages.length,
            "The two arryas are with different length"
        );
        for (uint256 i; i < _recipients.length; i++) {
            addRecipient(_recipients[i], _withdrawPercentages[i]);
        }
    }

    /**
     * @dev Function that withdraws all available tokens for the current period
     */
    function claim() public {
        require(startDate != 0, "The vesting hasn't started");
        require(now >= startDate, "The vesting hasn't started");

        (uint256 owedAmount, uint256 calculatedAmount) = calculateAmounts();
        recipients[msg.sender].withdrawnAmount = calculatedAmount;
        bool result = token.transfer(msg.sender, owedAmount);
        require(result, "The claim was not successful");
        emit LogTokensClaimed(msg.sender, owedAmount);
    }

    /**
     * @dev Function that returns the amount that the user can withdraw at the current period.
     * @return _owedAmount The amount that the user can withdraw at the current period.
     */
    function hasClaim() public view returns (uint256 _owedAmount) {
        if (now <= startDate) {
            return 0;
        }

        (uint256 owedAmount, uint256 _) = calculateAmounts();
        return owedAmount;
    }

    function calculateAmounts()
        internal
        view
        returns (uint256 _owedAmount, uint256 _calculatedAmount)
    {
        uint256 period = (now - startDate) / (periodLength);
        if (period >= cumulativeAmountsToVest.length) {
            period = cumulativeAmountsToVest.length - 1;
        }
        uint256 calculatedAmount = PercentageCalculator.div(
            cumulativeAmountsToVest[period],
            recipients[msg.sender].withdrawPercentage
        );
        uint256 owedAmount = calculatedAmount -
            recipients[msg.sender].withdrawnAmount;

        return (owedAmount, calculatedAmount);
    }
}