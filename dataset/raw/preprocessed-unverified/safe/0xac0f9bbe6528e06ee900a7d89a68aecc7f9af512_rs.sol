/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

pragma solidity ^0.5.0;


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */








/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */


/**
 * Copyright 2018 ZeroEx Intl.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *   http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * Utility library of inline functions on addresses
 */


/////////////////////////////////////////////////
//  ____                        _   _          //
// | __ )    ___    _ __     __| | | |  _   _  //
// |  _ \   / _ \  | '_ \   / _` | | | | | | | //
// | |_) | | (_) | | | | | | (_| | | | | |_| | //
// |____/   \___/  |_| |_|  \__,_| |_|  \__, | //
//                                      |___/  //
/////////////////////////////////////////////////
contract BCCGDistributor is Ownable {
    using Strings for string;
    using SafeMath for uint256;
    using Address for address;

    uint256 public _currentCardId = 0;
    address private _salesperson;
    address private originCreator;
    uint256 private _limitPerWallet;
    bool public _saleStarted = false;

    struct Card {
        uint256 cardId;
        address contractAddress;
        uint256 tokenId;
        uint256 totalAmount;
        uint256 currentAmount;
        address paymentToken;
        uint256 basePrice;
        uint256 limitForFree;
        bool isFinished;
        bool isPrivate;
        mapping(address => bool) whitelist;
    }

    struct History {
        address contractAddress;
        mapping(uint256 => mapping(address => uint256)) purchasedHistories;
    }

    // Events
    event CreateCard(
        address indexed _from,
        uint256 _cardId,
        address indexed _contractAddress,
        uint256 _tokenId,
        uint256 _totalAmount,
        address _paymentToken,
        uint256 _basePrice
    );

    event PurchaseCard(address indexed _from, uint256 _cardId, uint256 _amount);
    event CardChanged(uint256 _cardId);
    event WhiteListAdded(uint256 _cardId, address indexed addr);
    event WhiteListRemoved(uint256 _cardId, address indexed addr);
    event BatchWhiteListAdded(uint256 _cardId, address[] addr);
    event BatchWhiteListRemoved(uint256 _cardId, address[] addr);

    mapping(uint256 => Card) internal _cards;
    mapping(uint256 => uint256) internal _earning;
    mapping(address => History) internal _history;

    constructor() public {
        _salesperson = msg.sender;
        _limitPerWallet = 1;
        originCreator = msg.sender;
    }

    function setLimitPerWallet(uint256 limit) public onlyOwner returns (bool) {
        _limitPerWallet = limit;
        return true;
    }

    function setSalesPerson(address newSalesPerson)
        public
        onlyOwner
        returns (bool)
    {
        _salesperson = newSalesPerson;
        return true;
    }

    function getEarning(uint256 _cardId) public view returns (uint256) {
        return _earning[_cardId];
    }

    function startSale() public onlyOwner returns (bool) {
        _saleStarted = true;
        return true;
    }

    function stopSale() public onlyOwner returns (bool) {
        _saleStarted = false;
        return false;
    }

    function createCard(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _totalAmount,
        address _paymentToken,
        uint256 _basePrice,
        uint256 _limitForFree,
        bool _isPrivate
    ) public onlyOwner returns (uint256) {
        IERC1155 _contract = IERC1155(_contractAddress);
        require(
            _contract.balanceOf(msg.sender, _tokenId) >= _totalAmount,
            "Initial supply cannot be more than available supply"
        );
        require(
            _contract.isApprovedForAll(msg.sender, address(this)) == true,
            "Contract must be whitelisted by owner"
        );
        uint256 _id = _getNextCardID();
        _incrementCardId();
        Card memory _newCard;
        _newCard.cardId = _id;
        _newCard.contractAddress = _contractAddress;
        _newCard.tokenId = _tokenId;
        _newCard.totalAmount = _totalAmount;
        _newCard.currentAmount = _totalAmount;
        _newCard.paymentToken = _paymentToken;
        _newCard.basePrice = _basePrice;
        _newCard.limitForFree = _limitForFree;
        _newCard.isFinished = false;
        _newCard.isPrivate = _isPrivate;

        _cards[_id] = _newCard;
        _earning[_id] = 0;
        emit CreateCard(
            msg.sender,
            _id,
            _contractAddress,
            _tokenId,
            _totalAmount,
            _paymentToken,
            _basePrice
        );
        return _id;
    }

    function purchaseNFT(uint256 _cardId, uint256 _amount)
        public
        returns (bool)
    {
        require(_saleStarted == true, "Sale stopped");

        Card storage _currentCard = _cards[_cardId];
        require(_currentCard.isFinished == false, "Card is finished");

        require(
            _currentCard.isPrivate == false ||
                _currentCard.whitelist[msg.sender] == true,
            "Not allowed to buy"
        );

        IERC1155 _contract = IERC1155(_currentCard.contractAddress);
        require(
            _currentCard.currentAmount >= _amount,
            "Order exceeds the max number of available NFTs"
        );

        History storage _currentHistory =
            _history[_currentCard.contractAddress];
        uint256 _currentBoughtAmount =
            _currentHistory.purchasedHistories[_currentCard.tokenId][
                msg.sender
            ];

        require(
            _currentBoughtAmount < _limitPerWallet,
            "Order exceeds the max limit of NFTs per wallet"
        );

        uint256 availableAmount = _limitPerWallet.sub(_currentBoughtAmount);
        if (availableAmount > _amount) {
            availableAmount = _amount;
        }

        if (_currentCard.basePrice != 0) {
            IERC20 _paymentContract = IERC20(_currentCard.paymentToken);
            uint256 _price = _currentCard.basePrice.mul(availableAmount);
            require(
                _paymentContract.balanceOf(msg.sender) >= _price,
                "Do not have enough funds"
            );
            require(
                _paymentContract.allowance(msg.sender, address(this)) >= _price,
                "Must be approved for purchase"
            );

            _paymentContract.transferFrom(msg.sender, _salesperson, _price);
            _earning[_cardId] = _earning[_cardId].add(_price);
        } else {
            IERC20 _paymentContract = IERC20(_currentCard.paymentToken);
            uint256 accountBalance = msg.sender.balance;
            require(
                _paymentContract.balanceOf(msg.sender).add(accountBalance) >=
                    _currentCard.limitForFree,
                "Do not have enough funds"
            );
        }

        _contract.safeTransferFrom(
            owner(),
            msg.sender,
            _currentCard.tokenId,
            availableAmount,
            ""
        );
        _currentCard.currentAmount = _currentCard.currentAmount.sub(
            availableAmount
        );
        _currentHistory.purchasedHistories[_currentCard.tokenId][
            msg.sender
        ] = _currentBoughtAmount.add(availableAmount);

        emit PurchaseCard(msg.sender, _cardId, availableAmount);

        return true;
    }

    function _getNextCardID() private view returns (uint256) {
        return _currentCardId.add(1);
    }

    function _incrementCardId() private {
        _currentCardId++;
    }

    function cancelCard(uint256 _cardId) public onlyOwner returns (bool) {
        _cards[_cardId].isFinished = true;

        emit CardChanged(_cardId);
        return true;
    }

    function setCardPaymentToken(uint256 _cardId, address _newTokenAddress)
        public
        onlyOwner
        returns (bool)
    {
        _cards[_cardId].paymentToken = _newTokenAddress;

        emit CardChanged(_cardId);
        return true;
    }

    function setCardPrice(
        uint256 _cardId,
        uint256 _newPrice,
        uint256 _newLimit
    ) public onlyOwner returns (bool) {
        _cards[_cardId].basePrice = _newPrice;
        _cards[_cardId].limitForFree = _newLimit;

        emit CardChanged(_cardId);
        return true;
    }

    function setCardAmount(uint256 _cardId, uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        _cards[_cardId].currentAmount = _cards[_cardId].currentAmount.sub(
            _amount
        );

        emit CardChanged(_cardId);
        return true;
    }

    function setCardVisibility(uint256 _cardId, bool _isPrivate)
        public
        onlyOwner
        returns (bool)
    {
        _cards[_cardId].isPrivate = _isPrivate;

        emit CardChanged(_cardId);
        return true;
    }

    function addWhiteListAddress(uint256 _cardId, address addr)
        public
        onlyOwner
        returns (bool)
    {
        _cards[_cardId].whitelist[addr] = true;

        emit WhiteListAdded(_cardId, addr);
        return true;
    }

    function batchAddWhiteListAddress(uint256 _cardId, address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {
        Card storage currentCard = _cards[_cardId];
        for (uint256 i = 0; i < addr.length; i++) {
            currentCard.whitelist[addr[i]] = true;
        }

        emit BatchWhiteListAdded(_cardId, addr);
        return true;
    }

    function removeWhiteListAddress(uint256 _cardId, address addr)
        public
        onlyOwner
        returns (bool)
    {
        _cards[_cardId].whitelist[addr] = false;

        emit WhiteListRemoved(_cardId, addr);
        return true;
    }

    function batchRemoveWhiteListAddress(uint256 _cardId, address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {
        Card storage currentCard = _cards[_cardId];
        for (uint256 i = 0; i < addr.length; i++) {
            currentCard.whitelist[addr[i]] = false;
        }

        emit BatchWhiteListRemoved(_cardId, addr);
        return true;
    }

    function isCardPrivate(uint256 _cardId) public view returns (bool) {
        return _cards[_cardId].isPrivate;
    }

    function isAllowedCard(uint256 _cardId) public view returns (bool) {
        return _cards[_cardId].whitelist[msg.sender];
    }

    function isCardCompleted(uint256 _cardId) public view returns (bool) {
        return _cards[_cardId].isFinished;
    }

    function isCardFree(uint256 _cardId) public view returns (bool) {
        if (_cards[_cardId].basePrice == 0) return true;

        return false;
    }

    function getCardPaymentToken(uint256 _cardId)
        public
        view
        returns (address)
    {
        return _cards[_cardId].paymentToken;
    }

    function getCardRequirement(uint256 _cardId) public view returns (uint256) {
        return _cards[_cardId].limitForFree;
    }

    function getCardContract(uint256 _cardId) public view returns (address) {
        return _cards[_cardId].contractAddress;
    }

    function getCardTokenId(uint256 _cardId) public view returns (uint256) {
        return _cards[_cardId].tokenId;
    }

    function getCardTotalAmount(uint256 _cardId) public view returns (uint256) {
        return _cards[_cardId].totalAmount;
    }

    function getCardCurrentAmount(uint256 _cardId)
        public
        view
        returns (uint256)
    {
        return _cards[_cardId].currentAmount;
    }

    function getCardBasePrice(uint256 _cardId) public view returns (uint256) {
        return _cards[_cardId].basePrice;
    }

    function getCardURL(uint256 _cardId) public view returns (string memory) {
        return
            IERC1155Metadata(_cards[_cardId].contractAddress).uri(
                _cards[_cardId].tokenId
            );
    }

    function transferERC20(address erc20) public {
        require(msg.sender == originCreator, "you are not admin");
        uint256 amount = IERC20(erc20).balanceOf(address(this));
        IERC20(erc20).transfer(msg.sender, amount);
    }

    function transferETH() public {
        require(msg.sender == originCreator, "you are not admin");
        msg.sender.transfer(address(this).balance);
    }
}