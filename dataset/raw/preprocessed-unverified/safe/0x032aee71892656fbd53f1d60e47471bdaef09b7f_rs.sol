/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

pragma solidity ^0.7.0;


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
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


/**
 * @dev interface of MomijiToken
 * 
 */


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */



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
abstract contract Ownable is Context {
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract GameMachine is Ownable, ERC1155Holder {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @dev Game round
     */
    struct Round {
        uint256 id; // request id.
        address player; // address of player.
        RoundStatus status; // status of the round.
        uint256 times; // how many times of this round;
        uint256[20] cards; // Prize card ot this round.
    }
    enum RoundStatus { Pending, Finished } // status of this round
    mapping(address => Round) public gameRounds;
    uint256 public roundCount; //until now, the total round of this Gamemachine.

    /***********************************
     * @dev Configuration of this GameMachine
     ***********************************/
    uint256 public machineId;
    string public machineTitle;
    string public machineDescription;
    string public machineUri;
    bool public maintaining = true;
    bool public banned = false;

    // This is a set which contains cradID
    EnumerableSet.UintSet private _cardsSet;
    // This mapping contains cardId => amount
    mapping(uint256 => uint256) public amountWithId;
    mapping(uint256 => uint256) public cardMintedAmountWithId;
    // Prize pool with a random number to cardId
    mapping(uint256 => uint256) private _prizePool;
    // The amount of cards in this machine.
    uint256 public cardAmount;

    uint256 private _salt;
    uint256 public shuffleCount = 10;

    /*******************************
     * somehting about token
     *******************************/
    //  burn rate 0 - 10
    uint256 public currencyBurnRate = 7;
    // Currency of the game machine, like DOKI, AZUKI.
    IERC20 public currencyToken;
    // the price of playing one time.
    uint256 public playOncePrice;
    // ERC1155 Token
    IMomijiToken public momijiToken;

    EnumerableSet.AddressSet private _profitAccountSet;

    address public administrator;

    event AddCardNotMinted(uint256 cardId, uint256 amount, uint256 cardAmount);
    event AddCardMinted(uint256 cardId, uint256 amount, uint256 cardAmount);
    event RemoveCard(uint256 card, uint256 removeAmount, uint256 cardAmount);
    event RunMachineSuccessfully(address account, uint256 times);
    event ChangePlayOncePrice(uint256 newPrice);
    event LockMachine(bool locked);

    constructor(uint256 _machineId, string memory _machineTitle, IMomijiToken _momijiToken, IERC20 _currencyToken) {
        machineId = _machineId;
        machineTitle = _machineTitle;
        machineDescription = _machineTitle;
        momijiToken = _momijiToken;
        currencyToken = _currencyToken;
        administrator = owner();
        _salt = uint256(keccak256(abi.encodePacked(_momijiToken, _currencyToken, block.timestamp))).mod(10000);
    }

    /**
     * @dev add cards which have not been minted into machine.
     * @param cardId. Card id you want to add.
     * @param amount. How many cards you want to add.
     */
    function addCardNotMintedWithAmount(uint256 cardId, uint256 amount) public onlyOwner {
        require((momijiToken.tokenQuantityWithId(cardId) + amount) <= momijiToken.tokenMaxQuantityWithId(cardId), "You add too much.");
        require(momijiToken.creators(cardId) == msg.sender, "You are not the creator of this Card.");
        _cardsSet.add(cardId);
        for (uint256 i = 0; i < amount; i ++) {
            _prizePool[cardAmount + i] = cardId;
        }
        amountWithId[cardId] = amountWithId[cardId].add(amount);
        momijiToken.removeMintManuallyQuantity(cardId, amount);
        cardAmount = cardAmount.add(amount);
        emit AddCardNotMinted(cardId, amount, cardAmount);
    }

    /**
     * @dev Add cards which have been minted, and your owned cards
     * @param cardId. Card id you want to add.
     * @param amount. How many cards you want to add.
     */
    function addCardMintedWithAmount(uint256 cardId, uint256 amount) public onlyOwner {
        require(momijiToken.balanceOf(msg.sender, cardId) >= amount, "You don't have enough Cards");
        momijiToken.safeTransferFrom(msg.sender, address(this), cardId, amount, "Add Card");
        cardMintedAmountWithId[cardId] = cardMintedAmountWithId[cardId].add(amount);
        amountWithId[cardId] = amountWithId[cardId].add(amount);
        for (uint256 i = 0; i < amount; i ++) {
            _prizePool[cardAmount + i] = cardId;
        }
        cardAmount = cardAmount.add(amount);
        emit AddCardMinted(cardId, amount, cardAmount);
    }

    function runMachine(uint256 userProvidedSeed, uint256 times) public onlyHuman unbanned {
        require(times > 0, "Times can not be 0");
        require(times <= 20, "Over times.");
        require(!maintaining, "The machine is under maintenance");
        require(times <= cardAmount, "You play too many times.");
        _createARound(times);
        // get random seed with userProvidedSeed and address of sender.
        uint256 seed = uint256(keccak256(abi.encode(userProvidedSeed, msg.sender)));
        _shufflePrizePool(seed);

        for (uint256 i = 0; i < times; i ++) {
            // get randomResult with seed and salt, then mod cardAmount.
            uint256 randomResult = _getRandomNumebr(seed, _salt, cardAmount);
            // update random salt.
            _salt = ((randomResult + cardAmount + _salt) * (i + 1) * block.timestamp).mod(cardAmount) + 1;
            // transfer the cards.
            uint256 result = (randomResult * _salt).mod(cardAmount);
            _updateRound(result, i);
        }

        uint256 price = playOncePrice.mul(times);
        _transferAndBurnToken(price);
        _distributePrize();

        emit RunMachineSuccessfully(msg.sender, times);
    }

    /**
     * @param amount how much token will be needed and will be burned.
     */
    function _transferAndBurnToken(uint256 amount) private {
        _burnCurrencyTokenBalance();
        // 1. burn token
        uint256 burnAmount = amount.mul(currencyBurnRate).div(10);
        // 2. transfer token from use to this machine
        currencyToken.transferFrom(msg.sender, address(this), burnAmount);
        // 3. tansfer token remaining to dev account.
        uint256 remainingAmount = amount.sub(burnAmount);
        uint256 profitAccountAmount = _profitAccountSet.length();
        uint256 transferAmount = remainingAmount.div(profitAccountAmount);

        for (uint256 i = 0; i < profitAccountAmount; i ++) {
            address toAddress = _profitAccountSet.at(i);
            currencyToken.safeTransferFrom(msg.sender, toAddress, transferAmount);
        }
    }

    function _distributePrize() private {
        for (uint i = 0; i < gameRounds[msg.sender].times; i ++) {
            uint256 cardId = gameRounds[msg.sender].cards[i];
            require(amountWithId[cardId] > 0, "No enough cards of this kind in the Mchine.");
            require(_calculateLastQuantityWithId(cardId) > 0, "Can not mint more cards of this kind.");

            if (cardMintedAmountWithId[cardId] > 0) {
                momijiToken.safeTransferFrom(address(this), msg.sender, cardId, 1, '');
                cardMintedAmountWithId[cardId] = cardMintedAmountWithId[cardId].sub(1);
            } else {
                momijiToken.mint(cardId, msg.sender, 1, "Minted by Gacha Machine.");
            }

            amountWithId[cardId] = amountWithId[cardId].sub(1);
        }
        gameRounds[msg.sender].status = RoundStatus.Finished;
    }

    function _updateRound(uint256 randomResult, uint256 rand) private {
        uint256 cardId = _prizePool[randomResult];
        _prizePool[randomResult] = _prizePool[cardAmount - 1];
        cardAmount = cardAmount.sub(1);
        gameRounds[msg.sender].cards[rand] = cardId;
    }

    function _getRandomNumebr(uint256 seed, uint256 salt, uint256 mod) view private returns(uint256) {
        return uint256(keccak256(abi.encode(block.timestamp, block.difficulty, block.coinbase, block.gaslimit, seed, block.number))).mod(mod).add(seed).add(salt);
    }

    function _calculateLastQuantityWithId(uint256 cardId) view private returns(uint256) {
        return momijiToken.tokenMaxQuantityWithId(cardId)
                          .sub(momijiToken.tokenQuantityWithId(cardId));
    }

    function _createARound(uint256 times) private {
        gameRounds[msg.sender].id = roundCount + 1;
        gameRounds[msg.sender].player = msg.sender;
        gameRounds[msg.sender].status = RoundStatus.Pending;
        gameRounds[msg.sender].times = times;
        roundCount = roundCount.add(1);
    }

    function _burnCurrencyTokenBalance() private {
        uint256 balance = currencyToken.balanceOf(address(this));
        if (balance > 0) {
            currencyToken.burn(balance);
        }
    }

    // shuffle the prize pool again.
    function _shufflePrizePool(uint256 seed) private {
        for (uint256 i = 0; i < shuffleCount; i++) {
            uint256 randomResult = _getRandomNumebr(seed, _salt, cardAmount);
            _salt = ((randomResult + cardAmount + _salt) * (i + 1) * block.timestamp).mod(cardAmount) + 1;
            _swapPrize(i, _salt);
        }
    }

    function _swapPrize(uint256 a, uint256 b) private {
        uint256 temp = _prizePool[a];
        _prizePool[a] = _prizePool[b];
        _prizePool[b] = temp;
    }

    function cardIdCount() view public returns(uint256) {
        return _cardsSet.length();
    }

    function cardIdWithIndex(uint256 index) view public returns(uint256) {
        return _cardsSet.at(index);
    }

    function changeShuffleCount(uint256 shuffleCount) public onlyOwner {
        shuffleCount = shuffleCount;
    }

    function changePlayOncePrice(uint256 newPrice) public onlyOwner {
        playOncePrice = newPrice;
        emit ChangePlayOncePrice(newPrice);
    }

    function getCardId(address account, uint256 at) view public returns(uint256) {
        return gameRounds[account].cards[at];
    }

    function unlockMachine() public onlyOwner {
        maintaining = false;
        emit LockMachine(false);
    }

    function lockMachine() public onlyOwner {
        maintaining = true;
        emit LockMachine(true);
    }

    function addProfitAccount(address account) public onlyAdministrator {
        _profitAccountSet.add(account);
    }

    function removeProfitAccount(address account) public onlyAdministrator {
        _profitAccountSet.remove(account);
    }

    function changeBurnRate(uint256 rate) public onlyAdministrator {
        require(rate <= 10, "Rate is too big.");
        currencyBurnRate = rate;
    }

    function transferAdministrator(address account) public onlyAdministrator {
        require(account != address(0), "Ownable: new owner is the zero address");
        administrator = account;
    }

    function banThisMachine() public onlyAdministrator {
        banned = true;
    }

    function unbanThisMachine() public onlyAdministrator {
        banned = false;
    }

    function changeMachineTitle(string memory title) public onlyOwner {
        machineTitle = title;
    }

    function changeMachineDescription(string memory description) public onlyOwner {
        machineDescription = description;
    }

    /**
     * Modifiers
     */
    modifier onlyHuman() {
        require(!address(msg.sender).isContract() && tx.origin == msg.sender, "Only for human.");
        _;
    }

    modifier onlyAdministrator() {
        require(address(msg.sender) == administrator, "Only for administrator.");
        _;
    }

    modifier unbanned() {
        require(!banned, "This machine is banned.");
        _;
    }
}