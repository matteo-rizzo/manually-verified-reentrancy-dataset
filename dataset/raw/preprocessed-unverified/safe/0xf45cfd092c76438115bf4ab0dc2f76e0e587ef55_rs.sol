/**
 *Submitted for verification at Etherscan.io on 2020-11-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

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


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract DONDIRewardCenter {
    using SafeERC20 for IERC20;

    IERC20 public dondi = IERC20(0x45Ed25A237B6AB95cE69aF7555CF8D7A2FfEE67c);
    
    address public fundAddress = address(0x32Ddc840B06D15f16713DEfbE29187c060641214);
    uint256 public cardCost = 500 * 10**18;
    uint32 public cardSupply = 0;
    address gov;

    mapping(uint32 => address) private cardOwners;
    mapping(address => uint32[]) private ownCardIds;
    
    constructor () {
        gov = msg.sender;
    }

    modifier onlyGov() {
        require(msg.sender == gov);
        _;
    }

    function transferOwnership(address owner)
        external
        onlyGov
    {
        gov = owner;
    }
    
    function setFundAddress(address newFundAddress)
        external
        onlyGov
    {
        fundAddress = newFundAddress;
    }
    
    function setCardCost(uint256 newCardCost)
        external
        onlyGov
    {
        cardCost = newCardCost;
    }

    function buyCard(uint32 cardId)
        external
    {
        require(cardId < cardSupply, "Card Not Exist!");
        require(cardOwners[cardId] == address(0), "Already Sold!");
        dondi.safeTransferFrom(msg.sender, fundAddress, cardCost);
        cardOwners[cardId] = msg.sender;
        ownCardIds[msg.sender].push(cardId);
    }

    function getSalableCardIds()
        external
        view
        returns(uint32[] memory, uint32)
    {
        uint32[] memory cardIds = new uint32[](cardSupply);
        uint32 i;
        uint32 length = 0;
        for (i = 0; i < cardSupply; i++) {
            if (cardOwners[i] == address(0)) {
                cardIds[length] = i;
                length++;
            }
        }
        return (cardIds, length);
    }
    
    function setCardSupply(uint32 newSupply)
        external
        onlyGov
    {
        cardSupply = newSupply;
    }

    function getOwnCardIds(address cardOwner)
        external
        view
        returns (uint32[] memory, uint32)
    {
        return (ownCardIds[cardOwner], uint32(ownCardIds[cardOwner].length));
    }

    function getCardOwner(uint32 cardId)
        external
        view
        returns (address)
    {
        return cardOwners[cardId];
    }
}

contract DONDINewRewardCenter {
    using SafeERC20 for IERC20;

    IERC20 public dondi = IERC20(0x45Ed25A237B6AB95cE69aF7555CF8D7A2FfEE67c);

    DONDIRewardCenter oldRewardCenter = DONDIRewardCenter(0x67F4c17aBd728084F0386E9Ac54b9e9D8bC145aB);
    
    address payable public fundAddress = 0x32Ddc840B06D15f16713DEfbE29187c060641214;
    uint256 public cardDondiCost = 2500 * 10 ** 18;
    uint256 public cardEthPartCost = 25 * 10 ** 15;
    uint256 public cardEthEntireCost = 25 * 10 ** 16;

    uint32 private cardSupply = 0;
    address gov;

    mapping(uint32 => address) private cardOwners;
    mapping(address => uint32[]) private ownCardIds;
    
    constructor () {
        gov = msg.sender;
    }

    modifier onlyGov() {
        require(msg.sender == gov);
        _;
    }

    function getCardSupply()
        external
        view
        returns (uint32)
    {
        return oldRewardCenter.cardSupply() + cardSupply;
    }

    function transferOwnership(address owner)
        external
        onlyGov
    {
        gov = owner;
    }
    
    function setFundAddress(address payable newFundAddress)
        external
        onlyGov
    {
        fundAddress = newFundAddress;
    }
    
    function setCardCost(uint256 newDondiCost, uint256 newEthPartCost, uint256 newEthEntireCost)
        external
        onlyGov
    {
        cardDondiCost = newDondiCost;
        cardEthPartCost = newEthPartCost;
        cardEthEntireCost = newEthEntireCost;
    }

    function buyCard(uint32 cardId, uint plan) // plan 0 : dondi + ETH, plan 1 : ETH
        external
        payable
    {
        require(plan < 2, "Wrong plan number!");
        require(cardId < cardSupply + oldRewardCenter.cardSupply(), "Card Not Exist!");
        require(cardId >= oldRewardCenter.cardSupply(), "Already Sold!");
        cardId -= oldRewardCenter.cardSupply();
        require(cardOwners[cardId] == address(0), "Already Sold!");
        if (plan == 0) {
            require(msg.value == cardEthPartCost, "Wrong ETH Cost!");
            dondi.safeTransferFrom(msg.sender, fundAddress, cardDondiCost);
            if (!fundAddress.send(cardEthPartCost)) {
                fundAddress.transfer(cardEthPartCost);
            }
        } else {
            require(msg.value == cardEthEntireCost, "Wrong ETH Cost!");
            if (!fundAddress.send(cardEthEntireCost)) {
                fundAddress.transfer(cardEthEntireCost);
            }
        }
        cardOwners[cardId] = msg.sender;
        ownCardIds[msg.sender].push(cardId + oldRewardCenter.cardSupply());
    }

    function getSalableCardIds()
        external
        view
        returns(uint32[] memory, uint32)
    {
        (uint32[] memory oldCardIds, uint32 oldLength) = oldRewardCenter.getSalableCardIds();
        uint32[] memory cardIds = new uint32[](cardSupply + oldLength);
        uint32 i;
        for (i = 0; i < oldLength; i++) {
            cardIds[i] = oldCardIds[i];
        }
        uint32 length = oldLength;
        for (i = 0; i < cardSupply; i++) {
            if (cardOwners[i] == address(0)) {
                cardIds[length] = oldRewardCenter.cardSupply() + i;
                length++;
            }
        }
        return (cardIds, length);
    }
    
    function setCardSupply(uint32 newSupply)
        external
        onlyGov
    {
        require(newSupply >= oldRewardCenter.cardSupply(), "too less card!");
        cardSupply = newSupply - oldRewardCenter.cardSupply();
    }

    function getOwnCardIds(address cardOwner)
        external
        view
        returns (uint32[] memory, uint32)
    {
        (uint32[] memory cardIds, uint32 length) = oldRewardCenter.getOwnCardIds(cardOwner);
        uint32[] memory newCardIds = new uint32[](length + ownCardIds[cardOwner].length);
        uint i;
        for (i = 0; i < length; i++) {
            newCardIds[i] = cardIds[i];
        }
        for (i = 0; i < ownCardIds[cardOwner].length; i++) {
            newCardIds[length] = ownCardIds[cardOwner][i];
            length++;
        }
        return (newCardIds, length);
    }

    function getCardOwner(uint32 cardId)
        external
        view
        returns (address)
    {
        if (cardId < oldRewardCenter.cardSupply()) {
            return oldRewardCenter.getCardOwner(cardId);
        } else {
            return cardOwners[cardId - oldRewardCenter.cardSupply()];
        }
    }
}