/**
 *Submitted for verification at Etherscan.io on 2021-02-23
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
    constructor() public {
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
 * @dev Required interface of an ERC721 compliant contract.
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


// SPDX-License-Identifier: MIT
/////////////////////////////////////////////////
//  ____                        _   _          //
// | __ )    ___    _ __     __| | | |  _   _  //
// |  _ \   / _ \  | '_ \   / _` | | | | | | | //
// | |_) | | (_) | | | | | | (_| | | | | |_| | //
// |____/   \___/  |_| |_|  \__,_| |_|  \__, | //
//                                      |___/  //
/////////////////////////////////////////////////
contract BondlySwap is Ownable {
    using Strings for string;
    using SafeMath for uint256;
    using Address for address;

    // TokenType Definition
    enum TokenType {T20, T1155, T721}

    // SwapType Definition
    enum SwapType {TimedSwap, FixedSwap}

    struct Collection {
        address[] cardContractAddrs;
        uint256[] cardTokenIds; // amount for T20
        TokenType[] tokenTypes;
        uint256 nLength;
        address collectionOwner;
    }

    struct BSwap {
        uint256 totalAmount;
        uint256 currentAmount;
        Collection maker;
        bool isPrivate;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        SwapType swapType;
        Collection target;
        uint256 nAllowedBiddersLength;
        mapping(address => bool) allowedBidders;
    }

    mapping(uint256 => BSwap) private listings;
    uint256 public listIndex;

    uint256 public platformFee;
    address payable public feeCollector;
    uint256 public t20Fee;

    address private originCreator;

    // apply 0 fee to our NFTs
    mapping(address => bool) public whitelist;

    mapping(address => bool) public supportTokens;

    bool private emergencyStop;

    event AddedNewToken(address indexed tokenAddress);
    event BatchAddedNewToken(address[] tokenAddress);
    event NFTListed(uint256 listId, address indexed lister);
    event ListVisibilityChanged(uint256 listId, bool isPrivate);
    event ListEndTimeChanged(uint256 listId, uint256 endTime);
    event NFTSwapped(uint256 listId, address indexed buyer, uint256 count);
    event NFTClosed(uint256 listId, address indexed closer);

    event WhiteListAdded(address indexed addr);
    event WhiteListRemoved(address indexed addr);
    event BatchWhiteListAdded(address[] addr);
    event BatchWhiteListRemoved(address[] addr);

    constructor() public {
        originCreator = msg.sender;
        emergencyStop = false;
        listIndex = 0;

        platformFee = 1;
        feeCollector = msg.sender;
        t20Fee = 5;
    }

    modifier onlyNotEmergency() {
        require(emergencyStop == false, "BSwap: emergency stop");
        _;
    }

    modifier onlyValidList(uint256 listId) {
        require(listIndex >= listId, "Bswap: list not found");
        _;
    }

    modifier onlyListOwner(uint256 listId) {
        require(
            listings[listId].maker.collectionOwner == msg.sender || isOwner(),
            "Bswap: not your list"
        );
        _;
    }

    function _addNewToken(address contractAddr)
        public
        onlyOwner
        returns (bool)
    {
        require(
            supportTokens[contractAddr] == false,
            "BSwap: already supported"
        );
        supportTokens[contractAddr] = true;

        emit AddedNewToken(contractAddr);
        return true;
    }

    function _batchAddNewToken(address[] memory contractAddrs)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < contractAddrs.length; i++) {
            require(
                supportTokens[contractAddrs[i]] == false,
                "BSwap: already supported"
            );
            supportTokens[contractAddrs[i]] = true;
        }

        emit BatchAddedNewToken(contractAddrs);
        return true;
    }

    function _sendToken(
        TokenType tokenType,
        address contractAddr,
        uint256 tokenId,
        address from,
        address to
    ) internal {
        if (tokenType == TokenType.T1155) {
            IERC1155(contractAddr).safeTransferFrom(from, to, tokenId, 1, "");
        } else if (tokenType == TokenType.T721) {
            IERC721(contractAddr).safeTransferFrom(from, to, tokenId, "");
        } else {
            IERC20(contractAddr).transferFrom(from, to, tokenId);
        }
    }

    function createSwap(
        uint256[] memory arrTokenTypes,
        address[] memory arrContractAddr,
        uint256[] memory arrTokenIds,
        uint256 swapType,
        uint256 endTime,
        bool _isPrivate,
        address[] memory bidders,
        uint256 batchCount
    ) public payable onlyNotEmergency {
        bool isWhitelisted = false;

        require(
            arrContractAddr.length == arrTokenIds.length &&
                arrTokenIds.length == arrTokenTypes.length,
            "BSwap: array lengths are different"
        );
        require(
            arrContractAddr.length > 1,
            "BSwap: expected more than 1 desire"
        );
        require(batchCount >= 1, "BSwap: expected more than 1 count");
        for (uint256 i = 0; i < arrTokenTypes.length; i++) {
            require(
                supportTokens[arrContractAddr[i]] == true,
                "BSwap: not supported"
            );

            if (isWhitelisted == false) {
                isWhitelisted = whitelist[arrContractAddr[i]];
            }

            if (i == 0) {
                if (arrTokenTypes[i] == uint256(TokenType.T1155)) {
                    IERC1155 _t1155Contract = IERC1155(arrContractAddr[i]);
                    require(
                        _t1155Contract.balanceOf(msg.sender, arrTokenIds[i]) >=
                            batchCount,
                        "BSwap: Do not have nft"
                    );
                    require(
                        _t1155Contract.isApprovedForAll(
                            msg.sender,
                            address(this)
                        ) == true,
                        "BSwap: Must be approved"
                    );
                } else if (arrTokenTypes[i] == uint256(TokenType.T721)) {
                    IERC721 _t721Contract = IERC721(arrContractAddr[i]);
                    require(
                        _t721Contract.ownerOf(arrTokenIds[i]) == msg.sender,
                        "BSwap: Do not have nft"
                    );
                    require(
                        batchCount == 1,
                        "BSwap: Don't support T721 Batch Swap"
                    );
                    require(
                        _t721Contract.isApprovedForAll(
                            msg.sender,
                            address(this)
                        ) == true,
                        "BSwap: Must be approved"
                    );
                }
            }
        }

        if (isWhitelisted == false) {
            uint256 _fee = msg.value;
            require(_fee >= platformFee.mul(10**16), "BSwap: out of fee");

            feeCollector.transfer(_fee);
        }

        address _makerContract = arrContractAddr[0];
        uint256 _makerTokenId = arrTokenIds[0];
        TokenType _makerTokenType = TokenType(arrTokenTypes[0]);

        // maker config
        Collection memory _maker;
        _maker.nLength = 1;
        _maker.collectionOwner = msg.sender;
        _maker.cardContractAddrs = new address[](1);
        _maker.cardTokenIds = new uint256[](1);
        _maker.tokenTypes = new TokenType[](1);
        _maker.cardContractAddrs[0] = _makerContract;
        _maker.cardTokenIds[0] = _makerTokenId;
        _maker.tokenTypes[0] = _makerTokenType;

        // target config
        Collection memory _target;
        uint256 _targetLength = arrTokenTypes.length - 1;
        _target.nLength = _targetLength;
        _target.collectionOwner = address(0);
        _target.cardContractAddrs = new address[](_targetLength);
        _target.cardTokenIds = new uint256[](_targetLength);
        _target.tokenTypes = new TokenType[](_targetLength);
        for (uint256 i = 0; i < _targetLength; i++) {
            _target.cardContractAddrs[i] = arrContractAddr[i + 1];
            _target.cardTokenIds[i] = arrTokenIds[i + 1];
            _target.tokenTypes[i] = TokenType(arrTokenTypes[i + 1]);
        }

        uint256 _id = _getNextListID();
        _incrementListId();
        BSwap storage list = listings[_id];

        list.totalAmount = batchCount;
        list.currentAmount = batchCount;
        list.maker = _maker;
        list.target = _target;
        list.isPrivate = _isPrivate;
        list.startTime = block.timestamp;
        list.endTime = block.timestamp + endTime;
        list.isActive = true;
        list.swapType = SwapType(swapType);
        list.nAllowedBiddersLength = bidders.length;
        for (uint256 i = 0; i < bidders.length; i++) {
            list.allowedBidders[bidders[i]] = true;
        }

        emit NFTListed(_id, msg.sender);
    }

    function swapNFT(uint256 listId, uint256 batchCount)
        public
        payable
        onlyValidList(listId)
        onlyNotEmergency
    {
        require(batchCount >= 1, "BSwap: expected more than 1 count");

        // maker config
        BSwap storage list = listings[listId];
        Collection memory _target = list.target;
        Collection memory _maker = list.maker;
        address lister = _maker.collectionOwner;

        bool isWhitelisted = false;

        require(
            list.isActive == true && list.currentAmount > 0,
            "BSwap: list is closed"
        );
        require(
            list.currentAmount >= batchCount,
            "BSwap: exceed current supply"
        );
        require(
            list.swapType == SwapType.FixedSwap ||
                list.endTime > block.timestamp,
            "BSwap: time is over"
        );
        require(
            list.isPrivate == false || list.allowedBidders[msg.sender] == true,
            "Bswap: not whiltelisted"
        );

        for (uint256 i = 0; i < _target.tokenTypes.length; i++) {
            if (isWhitelisted == false) {
                isWhitelisted = whitelist[_target.cardContractAddrs[i]];
            }

            if (_target.tokenTypes[i] == TokenType.T1155) {
                IERC1155 _t1155Contract =
                    IERC1155(_target.cardContractAddrs[i]);
                require(
                    _t1155Contract.balanceOf(
                        msg.sender,
                        _target.cardTokenIds[i]
                    ) > 0,
                    "BSwap: Do not have nft"
                );
                require(
                    _t1155Contract.isApprovedForAll(
                        msg.sender,
                        address(this)
                    ) == true,
                    "BSwap: Must be approved"
                );
                _t1155Contract.safeTransferFrom(
                    msg.sender,
                    lister,
                    _target.cardTokenIds[i],
                    batchCount,
                    ""
                );
            } else if (_target.tokenTypes[i] == TokenType.T721) {
                IERC721 _t721Contract = IERC721(_target.cardContractAddrs[i]);
                require(
                    batchCount == 1,
                    "BSwap: Don't support T721 Batch Swap"
                );
                require(
                    _t721Contract.ownerOf(_target.cardTokenIds[i]) ==
                        msg.sender,
                    "BSwap: Do not have nft"
                );
                require(
                    _t721Contract.isApprovedForAll(msg.sender, address(this)) ==
                        true,
                    "BSwap: Must be approved"
                );
                _t721Contract.safeTransferFrom(
                    msg.sender,
                    lister,
                    _target.cardTokenIds[i],
                    ""
                );
            } else {
                IERC20 _t20Contract = IERC20(_target.cardContractAddrs[i]);
                uint256 tokenAmount = _target.cardTokenIds[i].mul(batchCount);
                require(
                    _t20Contract.balanceOf(msg.sender) >= tokenAmount,
                    "BSwap: Do not enough funds"
                );
                require(
                    _t20Contract.allowance(msg.sender, address(this)) >=
                        tokenAmount,
                    "BSwap: Must be approved"
                );

                // T20 fee
                uint256 amountToPlatform = tokenAmount.mul(t20Fee).div(100);
                uint256 amountToLister = tokenAmount.sub(amountToPlatform);
                _t20Contract.transferFrom(
                    msg.sender,
                    feeCollector,
                    amountToPlatform
                );
                _t20Contract.transferFrom(msg.sender, lister, amountToLister);
            }
        }

        if (isWhitelisted == false) {
            isWhitelisted = whitelist[_maker.cardContractAddrs[0]];
        }

        if (isWhitelisted == false) {
            uint256 _fee = msg.value;
            require(_fee >= platformFee.mul(10**16), "BSwap: out of fee");

            feeCollector.transfer(_fee);
        }

        _sendToken(
            _maker.tokenTypes[0],
            _maker.cardContractAddrs[0],
            _maker.cardTokenIds[0],
            lister,
            msg.sender
        );

        list.currentAmount = list.currentAmount.sub(batchCount);
        if (list.currentAmount == 0) {
            list.isActive = false;
        }

        emit NFTSwapped(listId, msg.sender, batchCount);
    }

    function closeList(uint256 listId)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {
        BSwap storage list = listings[listId];
        list.isActive = false;

        emit NFTClosed(listId, msg.sender);
        return true;
    }

    function setVisibility(uint256 listId, bool _isPrivate)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {
        BSwap storage list = listings[listId];
        list.isPrivate = _isPrivate;

        emit ListVisibilityChanged(listId, _isPrivate);
        return true;
    }

    function increaseEndTime(uint256 listId, uint256 amount)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {
        BSwap storage list = listings[listId];
        list.endTime = list.endTime.add(amount);

        emit ListEndTimeChanged(listId, list.endTime);
        return true;
    }

    function decreaseEndTime(uint256 listId, uint256 amount)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {
        BSwap storage list = listings[listId];
        require(
            list.endTime.sub(amount) > block.timestamp,
            "BSwap: can't revert time"
        );
        list.endTime = list.endTime.sub(amount);

        emit ListEndTimeChanged(listId, list.endTime);
        return true;
    }

    function addWhiteListAddress(address addr) public onlyOwner returns (bool) {
        whitelist[addr] = true;

        emit WhiteListAdded(addr);
        return true;
    }

    function batchAddWhiteListAddress(address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < addr.length; i++) {
            whitelist[addr[i]] = true;
        }

        emit BatchWhiteListAdded(addr);
        return true;
    }

    function removeWhiteListAddress(address addr)
        public
        onlyOwner
        returns (bool)
    {
        whitelist[addr] = false;

        emit WhiteListRemoved(addr);
        return true;
    }

    function batchRemoveWhiteListAddress(address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < addr.length; i++) {
            whitelist[addr[i]] = false;
        }

        emit BatchWhiteListRemoved(addr);
        return true;
    }

    function _setPlatformFee(uint256 _fee) public onlyOwner returns (uint256) {
        platformFee = _fee;
        return platformFee;
    }

    function _setFeeCollector(address payable addr)
        public
        onlyOwner
        returns (bool)
    {
        feeCollector = addr;
        return true;
    }

    function _setT20Fee(uint256 _fee) public onlyOwner returns (uint256) {
        t20Fee = _fee;
        return t20Fee;
    }

    function getOfferingTokens(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (
            TokenType[] memory,
            address[] memory,
            uint256[] memory
        )
    {
        BSwap storage list = listings[listId];
        Collection memory maker = list.maker;
        address[] memory cardContractAddrs =
            new address[](maker.cardContractAddrs.length);
        TokenType[] memory tokenTypes =
            new TokenType[](maker.tokenTypes.length);
        uint256[] memory cardTokenIds =
            new uint256[](maker.cardTokenIds.length);
        for (uint256 i = 0; i < maker.cardContractAddrs.length; i++) {
            cardContractAddrs[i] = maker.cardContractAddrs[i];
            tokenTypes[i] = maker.tokenTypes[i];
            cardTokenIds[i] = maker.cardTokenIds[i];
        }
        return (tokenTypes, cardContractAddrs, cardTokenIds);
    }

    function getDesiredTokens(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (
            TokenType[] memory,
            address[] memory,
            uint256[] memory
        )
    {
        BSwap storage list = listings[listId];
        Collection memory target = list.target;
        address[] memory cardContractAddrs =
            new address[](target.cardContractAddrs.length);
        TokenType[] memory tokenTypes =
            new TokenType[](target.tokenTypes.length);
        uint256[] memory cardTokenIds =
            new uint256[](target.cardTokenIds.length);
        for (uint256 i = 0; i < target.cardContractAddrs.length; i++) {
            cardContractAddrs[i] = target.cardContractAddrs[i];
            tokenTypes[i] = target.tokenTypes[i];
            cardTokenIds[i] = target.cardTokenIds[i];
        }
        return (tokenTypes, cardContractAddrs, cardTokenIds);
    }

    function isAvailable(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {
        BSwap storage list = listings[listId];
        Collection memory maker = list.maker;
        address lister = maker.collectionOwner;
        for (uint256 i = 0; i < maker.cardContractAddrs.length; i++) {
            if (maker.tokenTypes[i] == TokenType.T1155) {
                IERC1155 _t1155Contract = IERC1155(maker.cardContractAddrs[i]);
                if (
                    _t1155Contract.balanceOf(lister, maker.cardTokenIds[i]) == 0
                ) {
                    return false;
                }
            } else if (maker.tokenTypes[i] == TokenType.T721) {
                IERC721 _t721Contract = IERC721(maker.cardContractAddrs[i]);
                if (_t721Contract.ownerOf(maker.cardTokenIds[i]) != lister) {
                    return false;
                }
            }
        }

        return true;
    }

    function isWhitelistedToken(address addr)
        public
        view
        returns (bool)
    {
        return whitelist[addr];
    }

    function isSupportedToken(address addr)
        public
        view
        returns (bool)
    {
        return supportTokens[addr];
    }

    function isAcive(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {
        BSwap memory list = listings[listId];

        return
            list.isActive &&
            (list.swapType == SwapType.FixedSwap ||
                list.endTime > block.timestamp);
    }

    function isPrivate(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {
        return listings[listId].isPrivate;
    }

    function getSwapType(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {
        return uint256(listings[listId].swapType);
    }

    function getEndingTime(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {
        return listings[listId].endTime;
    }

    function getTotalAmount(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {
        return listings[listId].totalAmount;
    }

    function getCurrentAmount(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {
        return listings[listId].currentAmount;
    }

    function getStartTime(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {
        return listings[listId].startTime;
    }

    function getPeriod(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {
        if (listings[listId].endTime <= block.timestamp) return 0;

        return listings[listId].endTime.sub(block.timestamp);
    }

    function isAllowedForList(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {
        return listings[listId].allowedBidders[msg.sender];
    }

    function getOwnerOfList(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (address)
    {
        return listings[listId].maker.collectionOwner;
    }

    function _getNextListID() private view returns (uint256) {
        return listIndex.add(1);
    }

    function _incrementListId() private {
        listIndex = listIndex.add(1);
    }

    function transferERC20(address erc20) public {
        require(msg.sender == originCreator, "BSwap: you are not admin");
        uint256 amount = IERC20(erc20).balanceOf(address(this));
        IERC20(erc20).transfer(msg.sender, amount);
    }

    function transferETH() public {
        require(msg.sender == originCreator, "BSwap: you are not admin");
        msg.sender.transfer(address(this).balance);
    }
}