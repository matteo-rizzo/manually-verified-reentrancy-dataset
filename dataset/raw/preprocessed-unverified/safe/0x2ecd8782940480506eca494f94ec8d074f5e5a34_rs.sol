/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


contract Whitelist is Ownable {
    mapping (address => bool)       public  whitelist;

    constructor() public {
    }

    modifier whitelistOnly {
        require(whitelist[msg.sender], "MEMBERS_ONLY");
        _;
    }

    function addMember(address member)
        public
        onlyOwner
    {
        require(!whitelist[member], "ALREADY_EXISTS");
        whitelist[member] = true;
    }

    function removeMember(address member)
        public
        onlyOwner
    {
        require(whitelist[member], "NOT_EXISTS");
        whitelist[member] = false;
    }
}


/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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






contract ERC20Token {
    uint8   public decimals = 18;
    string  public name;
    string  public symbol;
    uint256 public totalSupply;

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    event  Approval(address indexed _owner, address indexed _spender, uint _value);
    event  Transfer(address indexed _from, address indexed _to, uint _value);

    constructor(
        string memory _name,
        string memory _symbol
    ) public {
        name = _name;
        symbol = _symbol;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad, "INSUFFICIENT_FUNDS");

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "NOT_ALLOWED");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}


contract MintableERC20Token is ERC20Token {
    using SafeMath for uint256;

    constructor(
        string memory _name,
        string memory _symbol
    )
        public
        ERC20Token(_name, _symbol)
    {}

    function _mint(address to, uint256 wad)
        internal
    {
        balanceOf[to] = balanceOf[to].add(wad);
        totalSupply = totalSupply.add(wad);

        emit Transfer(address(0), to, wad);
    }

    function _burn(address owner, uint256 wad)
        internal
    {
        balanceOf[owner] = balanceOf[owner].sub(wad);
        totalSupply = totalSupply.sub(wad);

        emit Transfer(owner, address(0), wad);
    }
}



contract IERC20Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
        external
        returns (bool);

    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    function totalSupply()
        external
        view
        returns (uint256);

    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}



contract MBFToken is
    MintableERC20Token,
    Ownable,
    Whitelist
{
    using SafeMath for uint256;
    using WadMath for uint256;
    using SafeERC20 for IERC20Token;

    // parameters
    uint256 constant             public   globalDecimals = 18;
    IERC20Token                  internal collateral;
    uint256                      public   maxSupply;

    bool                         public   finalized;
    uint256                      public   targetPrice;
    uint256                      public   totalProfit;
    uint256[]                    public   historyProfits;
    uint256[]                    public   historyTime;
    mapping (address => Account) public   accounts;

    // profit manager
    struct Account {
        uint256 profit;
        uint256 taken;
        uint256 settled;
    }

    // events
    event  Mint(address indexed _owner, uint256 _value);
    event  Burn(address indexed _owner, uint256 _value);
    event  Withdraw(address indexed _owner, uint256 _value);
    event  Pay(uint256 _value);

    constructor(
        address _collateralAddress,
        uint256 _maxSupply
    )
        public
        MintableERC20Token("P106 Token", "P106")
    {
        collateral = IERC20Token(_collateralAddress);
        maxSupply = _maxSupply;
        finalized = false;
    }

    function finalize()
        public
        onlyOwner
    {
        require(finalized == false, "CAN_ONLY_FINALIZE_ONCE");
        finalized = true;
        uint256 remaining = maxSupply.sub(totalSupply);
        _mint(owner(), remaining);

        emit Mint(owner(), remaining);
    }

    modifier beforeFinalized {
        require(finalized == false, "ALREADY_FINALIZED");
        _;
    }

    modifier afterFinalized {
        require(finalized == true, "NOT_FINALIZED");
        _;
    }

    function historyProfitsArray()
        public
        view
        returns (uint256[] memory)
    {
        return historyProfits;
    }

    function historyTimeArray()
        public
        view
        returns (uint256[] memory)
    {
        return historyTime;
    }

    function setTargetPrice(uint256 wad)
        public
        onlyOwner
    {
        require(wad > 0, "INVALID_RIG_PRICE");
        targetPrice = wad;
    }

    function pay(uint256 wad)
        public
        onlyOwner
        afterFinalized
    {
        totalProfit = totalProfit.add(wad);
        historyProfits.push(wad);
        historyTime.push(now);

        emit Pay(wad);
    }

    function unsettledProfitOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        if (totalProfit == accounts[beneficiary].settled) {
            return 0;
        }
        uint256 toSettle = totalProfit.sub(accounts[beneficiary].settled);
        return toSettle.wmul(balanceOf[beneficiary]).wdiv(maxSupply);
    }

    function profitOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        // unsettled { (total - settled) * balance / max } + settled { profit }
        return unsettledProfitOf(beneficiary) + accounts[beneficiary].profit;
    }

    function totalProfitOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        return accounts[beneficiary].taken.add(profitOf(beneficiary));
    }

    function adjustProfit(address beneficiary)
        internal
    {
        if (accounts[beneficiary].settled == totalProfit) {
            return;
        }
        accounts[beneficiary].profit = profitOf(beneficiary);
        accounts[beneficiary].settled = totalProfit;
    }

    function withdraw()
        public
    {
        require(msg.sender != address(0), "INVALID_ADDRESS");

        adjustProfit(msg.sender);
        require(accounts[msg.sender].profit > 0, "NO_PROFIT");

        uint256 available = accounts[msg.sender].profit;
        accounts[msg.sender].profit = 0;
        accounts[msg.sender].taken = accounts[msg.sender].taken.add(available);
        collateral.safeTransferFrom(owner(), msg.sender, available);

        emit Withdraw(msg.sender, available);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        adjustProfit(src);
        if (balanceOf[dst] == 0) {
            accounts[dst].settled = totalProfit;
        } else {
            adjustProfit(dst);
        }
        return super.transferFrom(src, dst, wad);
    }

    function join(uint256 wad)
        public
        whitelistOnly
        beforeFinalized
    {
        require(targetPrice > 0, "PRICE_NOT_INIT");
        require(wad > 0 && wad <= maxSupply.sub(totalSupply), "EXCEEDS_MAX_SUPPLY");

        uint256 joinPrice = wad.wmul(targetPrice);
        collateral.safeTransferFrom(msg.sender, owner(), joinPrice);
        _mint(msg.sender, wad);

        emit Mint(msg.sender, wad);
    }
}