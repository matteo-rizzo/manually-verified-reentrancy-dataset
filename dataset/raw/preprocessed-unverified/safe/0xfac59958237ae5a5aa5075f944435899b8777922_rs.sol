/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

pragma solidity ^0.5.17;







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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}






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
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


contract IGunToken is IERC721 {
    function exists(uint256 tokenId) external view returns (bool);

    function claimAllocation(address to, uint16 size, uint8 category) external returns (uint);
}

contract GunPreOrder is Ownable, ApproveAndCallFallBack {
    using BytesLib for bytes;
    using SafeMath for uint256;
    
    //Event for when a bulk buy order has been placed
    event consumerBulkBuy(uint8 category, uint256 quanity, address reserver);
    //Event for when a gun has been bought
    event GunsBought(uint256 gunId, address owner, uint8 category);
    //Event for when ether is taken out of this contract
    event Withdrawal(uint256 amount);

    //Default referal commision percent
    uint256 public constant COMMISSION_PERCENT = 5;
    
    //Whether category is open
    mapping(uint8 => bool) public categoryExists;
    mapping(uint8 => bool) public categoryOpen;
    mapping(uint8 => bool) public categoryKilled;
    
    //The additional referal commision percent for any given referal address (default is 0)
    mapping(address => uint256) internal commissionRate;
    
    //How many guns in a given category an address has reserved
    mapping(uint8 => mapping(address => uint256)) public categoryReserveAmount;
    
    //Opensea buy address
    address internal constant OPENSEA = 0x5b3256965e7C3cF26E11FCAf296DfC8807C01073;

    //The percent increase and percent base for a given category
    mapping(uint8 => uint256) public categoryPercentIncrease;
    mapping(uint8 => uint256) public categoryPercentBase;

    //Price of a givevn category in USD WEI
    mapping(uint8 => uint256) public categoryPrice;
    
    //The percent of ether required for buying in BZN
    mapping(uint8 => uint256) public requiredEtherPercent;
    mapping(uint8 => uint256) public requiredEtherPercentBase;
    bool public allowCreateCategory = true;
    bool public allowEthPayment = true;

    //The gun token contract
    IGunToken public token;
    //The gun factory contract
    GunFactory internal factory;
    //The BZN contract
    ERC20Burnable internal bzn;
    //The Maker ETH/USD price feed
    ETHFeed public ethFeed;
    BZNFeed public bznFeed;
    //The gamepool address
    address internal gamePool;
    
    //Require the skinned/regular shop to be opened
    modifier ensureShopOpen(uint8 category) {
        require(categoryExists[category], "Category doesn't exist!");
        require(categoryOpen[category], "Category is not open!");
        _;
    }
    
    //Allow a function to accept ETH payment
    modifier payInETH(address referal, uint8 category, address new_owner, uint16 quanity) {
        require(allowEthPayment, "ETH Payments are disabled");
        uint256 usdPrice;
        uint256 totalPrice;
        (usdPrice, totalPrice) = priceFor(category, quanity);
        require(usdPrice > 0, "Price not yet set");
        
        categoryPrice[category] = usdPrice; //Save last price
        
        uint256 price = convert(totalPrice, false);
        
        require(msg.value >= price, "Not enough Ether sent!");
        
        _;
        
        if (msg.value > price) {
            uint256 change = msg.value - price;

            msg.sender.transfer(change);
        }
        
        if (referal != address(0)) {
            require(referal != msg.sender, "The referal cannot be the sender");
            require(referal != tx.origin, "The referal cannot be the tranaction origin");
            require(referal != new_owner, "The referal cannot be the new owner");

            //The commissionRate map adds any partner bonuses, or 0 if a normal user referral
            uint256 totalCommision = COMMISSION_PERCENT + commissionRate[referal];

            uint256 commision = (price * totalCommision) / 100;
            
            address payable _referal = address(uint160(referal));

            _referal.transfer(commision);
        }

    }
    
    //Allow function to accept BZN payment
    modifier payInBZN(address referal, uint8 category, address payable new_owner, uint16 quanity) {
        uint256[] memory prices = new uint256[](4); //Hack to work around local var limit (usdPrice, bznPrice, commision, totalPrice)
        (prices[0], prices[3]) = priceFor(category, quanity);
        require(prices[0] > 0, "Price not yet set");
            
        categoryPrice[category] = prices[0];
        
        prices[1] = convert(prices[3], true); //Convert the totalPrice to BZN

        //The commissionRate map adds any partner bonuses, or 0 if a normal user referral
        if (referal != address(0)) {
            prices[2] = (prices[1] * (COMMISSION_PERCENT + commissionRate[referal])) / 100;
        }
        
        uint256 requiredEther = (convert(prices[3], false) * requiredEtherPercent[category]) / requiredEtherPercentBase[category];
        
        require(msg.value >= requiredEther, "Buying with BZN requires some Ether!");
        
        bzn.burnFrom(new_owner, (((prices[1] - prices[2]) * 30) / 100));
        bzn.transferFrom(new_owner, gamePool, prices[1] - prices[2] - (((prices[1] - prices[2]) * 30) / 100));
        
        _;
        
        if (msg.value > requiredEther) {
            new_owner.transfer(msg.value - requiredEther);
        }
        
        if (referal != address(0)) {
            require(referal != msg.sender, "The referal cannot be the sender");
            require(referal != tx.origin, "The referal cannot be the tranaction origin");
            require(referal != new_owner, "The referal cannot be the new owner");
            
            bzn.transferFrom(new_owner, referal, prices[2]);
            
            prices[2] = (requiredEther * (COMMISSION_PERCENT + commissionRate[referal])) / 100;
            
            address payable _referal = address(uint160(referal));

            _referal.transfer(prices[2]);
        }
    }

    //Constructor
    constructor(
        address tokenAddress,
        address tokenFactory,
        address gp,
        address ethfeed,
        address bzn_address
    ) public {
        token = IGunToken(tokenAddress);

        factory = GunFactory(tokenFactory);
        
        ethFeed = ETHFeed(ethfeed);
        bzn = ERC20Burnable(bzn_address);

        gamePool = gp;

        //Set percent increases
        categoryPercentIncrease[1] = 100035;
        categoryPercentBase[1] = 100000;
        
        categoryPercentIncrease[2] = 100025;
        categoryPercentBase[2] = 100000;
        
        categoryPercentIncrease[3] = 100015;
        categoryPercentBase[3] = 100000;
        
        commissionRate[OPENSEA] = 10;
    }
    
    function createCategory(uint8 category) public onlyOwner {
        require(allowCreateCategory);
        
        categoryExists[category] = true;
    }
    
    function disableCreateCategories() public onlyOwner {
        allowCreateCategory = false;
    }

    function toggleETHPayment(bool enable) public onlyOwner {
        allowEthPayment = enable;
    }
    
    //Set the referal commision rate for an address
    function setCommission(address referral, uint256 percent) public onlyOwner {
        require(percent > COMMISSION_PERCENT);
        require(percent < 95);
        percent = percent - COMMISSION_PERCENT;
        
        commissionRate[referral] = percent;
    }
    
    //Set the price increase/base for skinned or regular guns
    function setPercentIncrease(uint256 increase, uint256 base, uint8 category) public onlyOwner {
        require(increase > base);
        
        categoryPercentIncrease[category] = increase;
        categoryPercentBase[category] = base;
    }
    
    function setEtherPercent(uint256 percent, uint256 base, uint8 category) public onlyOwner {
        requiredEtherPercent[category] = percent;
        requiredEtherPercentBase[category] = base;
    }
    
    function killCategory(uint8 category) public onlyOwner {
        require(!categoryKilled[category]);
        
        categoryOpen[category] = false;
        categoryKilled[category] = true;
    }

    //Open/Close the skinned or regular guns shop
    function setShopState(uint8 category, bool open) public onlyOwner {
        require(category == 1 || category == 2 || category == 3);
        require(!categoryKilled[category]);
        require(categoryExists[category]);
        
        categoryOpen[category] = open;
    }

    /**
     * Set the price for any given category in USD.
     */
    function setPrice(uint8 category, uint256 price, bool inWei) public onlyOwner {
        uint256 multiply = 1e18;
        if (inWei) {
            multiply = 1;
        }
        
        categoryPrice[category] = price * multiply;
    }

    /**
    Withdraw the amount from the contract's balance. Only the contract owner can execute this function
    */
    function withdraw(uint256 amount) public onlyOwner {
        uint256 balance = address(this).balance;

        require(amount <= balance, "Requested to much");
        
        address payable _owner = address(uint160(owner()));
        
        _owner.transfer(amount);

        emit Withdrawal(amount);
    }
    
    function setBZNFeedContract(address new_bzn_feed) public onlyOwner {
        bznFeed = BZNFeed(new_bzn_feed);
    }

    function setEtherFeedContract(address new_eth_feed) public onlyOwner {
        ethFeed = ETHFeed(new_eth_feed);
    }
    
    //Buy many skinned or regular guns with BZN. This will reserve the amount of guns and allows the new_owner to invoke claimGuns for free
    function buyWithBZN(address referal, uint8 category, address payable new_owner, uint16 quanity) ensureShopOpen(category) payInBZN(referal, category, new_owner, quanity) public payable returns (bool) {
        factory.mintFor(new_owner, quanity, category);
            
        return true;
    }
    
    //Buy many skinned or regular guns with ETH. This will reserve the amount of guns and allows the new_owner to invoke claimGuns for free
    function buyWithEther(address referal, uint8 category, address new_owner, uint16 quanity) ensureShopOpen(category) payInETH(referal, category, new_owner, quanity) public payable returns (bool) {
        factory.mintFor(new_owner, quanity, category);
        
        return true;
    }
    
    function convert(uint256 usdValue, bool isBZN) public view returns (uint256) {
        if (isBZN) {
            return bznFeed.convert(usdValue);
        } else {
            uint256 priceForEtherInUsdWei = ethFeed.priceForEtherInUsdWei();
            
            return usdValue / (priceForEtherInUsdWei / 1e18);
        }
    }
    
    /**
    Get the price for skinned or regular guns in USD (wei)
    */
    function priceFor(uint8 category, uint16 quanity) public view returns (uint256, uint256) {
        require(quanity > 0);
        uint256 percent = categoryPercentIncrease[category];
        uint256 base = categoryPercentBase[category];

        uint256 currentPrice = categoryPrice[category];
        uint256 nextPrice = currentPrice;
        uint256 totalPrice = 0;
        //We can't use exponents because we'll overflow quickly
        //Only for loop :(
        for (uint i = 0; i < quanity; i++) {
            nextPrice = (currentPrice * percent) / base;
            
            currentPrice = nextPrice;
            
            totalPrice += nextPrice;
        }

        //Return the next price, as this is the true price
        return (nextPrice, totalPrice);
    }

    //Determine if a tokenId exists (has been sold)
    function sold(uint256 _tokenId) public view returns (bool) {
        return token.exists(_tokenId);
    }
    
    function receiveApproval(address from, uint256 tokenAmount, address tokenContract, bytes memory data) public payable returns (bool) {
        address referal;
        uint8 category;
        uint16 quanity;
        
        (referal, category, quanity) = abi.decode(data, (address, uint8, uint16));
        
        require(quanity >= 1);
        
        address payable _from = address(uint160(from)); 
        
        buyWithBZN(referal, category, _from, quanity);
        
        return true;
    }
}

contract GunFactory is Ownable {
    using strings for *;
    
    uint8 public constant PREMIUM_CATEGORY = 1;
    uint8 public constant MIDGRADE_CATEGORY = 2;
    uint8 public constant REGULAR_CATEGORY = 3;
    uint256 public constant ONE_MONTH = 2628000;
    
    uint256 public mintedGuns = 0;
    address preOrderAddress;
    IGunToken token;
    
    mapping(uint8 => uint256) internal gunsMintedByCategory;
    mapping(uint8 => uint256) internal totalGunsMintedByCategory;
    
    mapping(uint8 => uint256) internal firstMonthLimit;
    mapping(uint8 => uint256) internal secondMonthLimit;
    mapping(uint8 => uint256) internal thirdMonthLimit;
    
    uint256 internal startTime;
    mapping(uint8 => uint256) internal currentMonthEnd;
    uint256 internal monthOneEnd;
    uint256 internal monthTwoEnd;

    modifier onlyPreOrder {
        require(msg.sender == preOrderAddress, "Not authorized");
        _;
    }

    modifier isInitialized {
        require(preOrderAddress != address(0), "No linked preorder");
        require(address(token) != address(0), "No linked token");
        _;
    }
    
    constructor() public {
        firstMonthLimit[PREMIUM_CATEGORY] = 5000;
        firstMonthLimit[MIDGRADE_CATEGORY] = 20000;
        firstMonthLimit[REGULAR_CATEGORY] = 30000;
        
        secondMonthLimit[PREMIUM_CATEGORY] = 2500;
        secondMonthLimit[MIDGRADE_CATEGORY] = 10000;
        secondMonthLimit[REGULAR_CATEGORY] = 15000;
        
        thirdMonthLimit[PREMIUM_CATEGORY] = 600;
        thirdMonthLimit[MIDGRADE_CATEGORY] = 3000;
        thirdMonthLimit[REGULAR_CATEGORY] = 6000;
        
        startTime = block.timestamp;
        monthOneEnd = startTime + ONE_MONTH;
        monthTwoEnd = startTime + ONE_MONTH + ONE_MONTH;
        
        currentMonthEnd[PREMIUM_CATEGORY] = monthOneEnd;
        currentMonthEnd[MIDGRADE_CATEGORY] = monthOneEnd;
        currentMonthEnd[REGULAR_CATEGORY] = monthOneEnd;
    }

    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (v != 0) {
            bstr[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }
        
        return string(bstr);
    }

    function mintFor(address newOwner, uint16 size, uint8 category) public onlyPreOrder isInitialized returns (uint256) {
        GunPreOrder preOrder = GunPreOrder(preOrderAddress);
        require(preOrder.categoryExists(category), "Invalid category");
        
        require(!hasReachedLimit(category), "The monthly limit has been reached");
        
        token.claimAllocation(newOwner, size, category);
        
        mintedGuns += size;
        
        gunsMintedByCategory[category] = gunsMintedByCategory[category] + size;
        totalGunsMintedByCategory[category] = totalGunsMintedByCategory[category] + size;
    }
    
    function hasReachedLimit(uint8 category) internal returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 limit = currentLimit(category);
        
        uint256 monthEnd = currentMonthEnd[category];
        
        //If the current block time is greater than or equal to the end of the month
        if (currentTime >= monthEnd) {
            //It's a new month, reset all limits
            //gunsMintedByCategory[PREMIUM_CATEGORY] = 0;
            //gunsMintedByCategory[MIDGRADE_CATEGORY] = 0;
            //gunsMintedByCategory[REGULAR_CATEGORY] = 0;
            gunsMintedByCategory[category] = 0;
            
            //Set next month end to be equal one month in advance
            //do this while the current time is greater than the next month end
            while (currentTime >= monthEnd) {
                monthEnd = monthEnd + ONE_MONTH;
            }
            
            //Finally, update the limit
            limit = currentLimit(category);
            currentMonthEnd[category] = monthEnd;
        }
        
        //Check if the limit has been reached
        return gunsMintedByCategory[category] >= limit;
    }
    
    function reachedLimit(uint8 category) public view returns (bool) {
        uint256 limit = currentLimit(category);
        
        return gunsMintedByCategory[category] >= limit;
    }
    
    function currentLimit(uint8 category) public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 limit;
        if (currentTime < monthOneEnd) {
            limit = firstMonthLimit[category];
        } else if (currentTime < monthTwoEnd) {
            limit = secondMonthLimit[category];
        } else {
            limit = thirdMonthLimit[category];
        }
        
        return limit;
    }
    
    function setCategoryLimit(uint8 category, uint256 firstLimit, uint256 secondLimit, uint256 thirdLimit) public onlyOwner {
        require(firstMonthLimit[category] == 0);
        require(secondMonthLimit[category] == 0);
        require(thirdMonthLimit[category] == 0);
        
        firstMonthLimit[category] = firstLimit;
        secondMonthLimit[category] = secondLimit;
        thirdMonthLimit[category] = thirdLimit;
    }
    
    /**
    Attach the preOrder that will be receiving tokens being marked for sale by the
    sellCar function
    */
    function attachPreOrder(address dst) public onlyOwner {
        require(preOrderAddress == address(0));
        require(dst != address(0));

        //Enforce that address is indeed a preorder
        GunPreOrder preOrder = GunPreOrder(dst);

        preOrderAddress = address(preOrder);
    }

    /**
    Attach the token being used for things
    */
    function attachToken(address dst) public onlyOwner {
        require(address(token) == address(0));
        require(dst != address(0));

        //Enforce that address is indeed a preorder
        IGunToken ct = IGunToken(dst);

        token = ct;
    }
}