/**
 *Submitted for verification at Etherscan.io on 2021-07-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;


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
    constructor () internal { }
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * _Available since v3.1._
 */




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


contract EggPurchase is Ownable, IERC1155Receiver {
    using SafeMath for uint256;
    
    uint256 public nftid;
    // address => purchaseId => timestamp
    mapping(address => mapping(uint256 => uint256)) private userPurchased;
    mapping(address => uint256) private userNextPurchasedId;
    address public eggAddress;
    bool public active = false;
    uint256 public startTimestamp;
    address payable private devWallet;
    
    struct SalePeriod {
        uint256 duration;
        uint256 price;
        uint256 eggAmount;
        uint256 eggsSoldThisRound;
    }
    
    SalePeriod[] public salePeriods;
    
    constructor(address _eggAddress, uint256 _nftid, address payable _devWallet) public {
        eggAddress = _eggAddress;
        nftid = _nftid;
        devWallet = _devWallet;
    }
    
    function setActive(bool isActive) public onlyOwner {
        active = isActive;
    }
    
    function setDevWallet(address payable dev) public onlyOwner {
        devWallet = dev;
    }
    
    function initiateSale(uint256 _startTimestamp) public onlyOwner {
        
        if(_startTimestamp == 0) {
            startTimestamp = now;
        } else {
            startTimestamp = _startTimestamp;
        }
        
        active = true;
    }
    
    
    /*
        24h = 86400, 0.111 ether = 111*10**15
        
        Planned sale setup:
        [86400,86400,86400,86400,86400,86400,86400,86400,86400,86400,86400,86400,86400,86400]
        [111,111,222,222,333,333,444,444,555,555,444,333,222,111]
        [15,15,15,15,15,15,15,15,15,15,15,15,15,15]
        [111,111,111,111,111,111,111,111,111,111,0,0,0,0]
    */
    
    function setSalePeriods(uint256[] memory _duration, uint256[] memory _priceBase, uint256[] memory additionalDecimals, uint256[] memory _eggAmount) public onlyOwner {
        
        delete salePeriods;
        
        for (uint256 i = 0; i < _duration.length; i++) {
            salePeriods.push(SalePeriod(_duration[i], _priceBase[i].mul(10**additionalDecimals[i]), _eggAmount[i], 0));
        }
        
    }
    
    // returns: id, current price, total amount of eggs sold, total eggs available (until now)
    function getSaleRoundInfo() public view returns (uint256, uint256, uint256, uint256) {
        
        uint256 lastTimestamp = startTimestamp;
        uint256 totalEggsSold = 0;
        uint256 totalEggsAvailable = 0;
        
        for (uint256 i = 0; i < salePeriods.length; i++) {     
            SalePeriod storage salePeriod = salePeriods[i];
            lastTimestamp = lastTimestamp.add(salePeriod.duration);
            totalEggsSold = totalEggsSold.add(salePeriod.eggsSoldThisRound);
            totalEggsAvailable = totalEggsAvailable.add(salePeriod.eggAmount);
            
            if(now <= lastTimestamp) {
                return (i, salePeriod.price, totalEggsSold, totalEggsAvailable);
            }
        }
        
        return (0,0,totalEggsSold,0);
        
    }
    
    function getUserPurchased(address buyer, uint256 id) public view returns (uint256) {
        return userPurchased[buyer][id];
    }
    
    function getUserNextPurchasedId(address buyer) public view returns (uint256) {
        return userNextPurchasedId[buyer];
    }
    
    function userBought24h(address buyer) public view returns (uint256) {
        
        uint256 maxRange = 0;
        uint256 bought24h = 0;
        
        if(userNextPurchasedId[buyer] >= 5) {
            maxRange = 5;
        } else {
            maxRange = userNextPurchasedId[buyer];
        }
        
        
        for(uint256 i=1; i<=maxRange; i++) {
            if(userPurchased[buyer][userNextPurchasedId[buyer].sub(i)].add(24*60*60) >= now) {
                bought24h++;
            }
        }
        
        return bought24h;
    }

    function purchase() public payable {
        purchase(1);
    }

    function purchase(uint256 amount) public payable {
        
        require(active == true && startTimestamp <= now, "Cannot buy: Sale not active yet");
        
        (uint256 currentRoundId, uint256 currentPrice, uint256 totalEggsSold, uint256 totalEggsAvailable) = getSaleRoundInfo();
        
        require(totalEggsAvailable > totalEggsSold, "Eggs sold out. Try again during the next round.");
        uint256 eggsAvailableNow = totalEggsAvailable.sub(totalEggsSold);
        
        require(msg.value == currentPrice * amount, "You need to send the exact NFT price");
        require(amount > 0, "Why would you want zero eggs");
        require(amount <= 5, "You cannot buy more than 5 Eggs at once");
        require(amount <= eggsAvailableNow, "You cannot buy more than the available amount");
        require(userBought24h(msg.sender).add(amount) <= 5, "You cannot purchase more than 5 NFTs in 24h");
        require(IERC1155(eggAddress).balanceOf(address(this), nftid) > amount, "Cannot buy: not enough Eggs!");
        
        salePeriods[currentRoundId].eggsSoldThisRound = salePeriods[currentRoundId].eggsSoldThisRound.add(amount);
        
        IERC1155(eggAddress).safeTransferFrom(address(this), msg.sender, nftid, amount, "");
        if(devWallet != address(0)) {
            devWallet.transfer(msg.value);
        }
        
        for(uint256 i = 0; i < amount; i++) {
            userPurchased[msg.sender][userNextPurchasedId[msg.sender]] = now;
            userNextPurchasedId[msg.sender] = userNextPurchasedId[msg.sender] + 1;
        }
    }
    
    function withdrawEggs(address _to) public onlyOwner {
        uint256 amount = IERC1155(eggAddress).balanceOf(address(this), nftid);
        IERC1155(eggAddress).safeTransferFrom(address(this), _to, nftid, amount, "");
    }
    
    function withdrawEther(address payable _to, uint256 _amount) public onlyOwner {
        _to.transfer(_amount);
    }

    function withdrawTokens(address _token, address _to, uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(_token);
        token.transfer(_to, _amount);
    }
    
    
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns(bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
    
    
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external returns(bytes4) {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
    
}