/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

/**
__                  _    _
/ _\_ __   __ _ _ __| | _| | ___
\ \| '_ \ / _` | '__| |/ / |/ _ \
_\ \ |_) | (_| | |  |   <| |  __/
\__/ .__/ \__,_|_|  |_|\_\_|\___|
  |_|


Sparkle is the world's first redistributive currency.

Sparkle! offers an alternative to economies based on income inequality by
creating a currency that proportionally redistributes two percent of every
transaction to each person in the economy.

Put simply: When the rich spend, the poor receive a share.

Sparkle is minted via an anti-speculative system whereby the smart contract
maintains a stable buy price of 1 ETH = 9700 SPRK and sell price of
10000 SPRK = .97 ETH until 400,000,000 SPRK have been minted.

Once 400 million Sparkle are in circulation, the buy function of this contract
is disabled and no more SPRK will be minted until supply drops below the
threshold. The sell function remains active to preserve a minimum value of
10,000 SPRK equals .97 ETH.

Everyone can mint Sparkle! by sending ETH to this contract.

Everyone can earn ETH by selling Sparkle! to this contract.

Everyone starts with free Sparkle!: by entering into the economy of Sparkle!
you will automatically receive your share of the transaction taxes collected.

Sparkle! is an activist experiment created by Micah White and released on
September 17, 2019 to commemorate the eighth anniversary of Occupy Wall Street.

SPARKLE! IS:

• Autonomous — Sparkle! has no kill switch or pause function.

• Adversarial — Sparkle! is an act of protest that offers an alternative.

• Experimental — Sparkle! tests new economic laws that could form the basis for
                 an activist society.

• Anti-speculative — Sparkle! fights currency speculation and is backed by a
                      verifiable reserve of ETH that guarantees as a
                      minimum value.

*/

pragma solidity ^0.5.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Sparkle is ERC20Detailed {

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    event SparkleRedistribution(address from, uint amount);
    event Mint(address to, uint amount);
    event Sell(address from, uint amount);

    uint256 public constant MAX_SUPPLY = 400000000 * 10 ** 18; // 40000 ETH of Sparkle
    uint256 public constant PERCENT = 100; // 100%
    uint256 public constant TAX = 2; // 2%
    uint256 public constant COST_PER_TOKEN = 1e14; // 1 Sparkle = .0001 ETH
    address payable creator = 0x4C3cC1D2229CBD17D26ec984F2E1b9bD336cBf69;

    uint256 private _tobinsCollected;
    uint256 private _totalSupply;
    mapping (address => uint256) private _tobinsClaimed; // Internal accounting

    constructor() public ERC20Detailed("Sparkle!", "SPRK", 18) {}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function tobinsCollected() public view returns (uint256) {
        return _tobinsCollected;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (_totalSupply == 0) return 0;

        uint256 unclaimed = _tobinsCollected.sub(_tobinsClaimed[owner]);
        uint256 floatingSupply = _totalSupply.sub(_tobinsCollected);
        uint256 redistribution = _balances[owner].mul(unclaimed).div(floatingSupply);

        return _balances[owner].add(redistribution);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0));

        uint256 taxAmount = value.mul(TAX).div(PERCENT);

        _balances[msg.sender] = balanceOf(msg.sender).sub(value).sub(taxAmount);
        _balances[to] = balanceOf(to).add(value);

        _tobinsClaimed[msg.sender] = _tobinsCollected;
        _tobinsClaimed[to] = _tobinsCollected;
        _tobinsCollected = _tobinsCollected.add(taxAmount);

        emit Transfer(msg.sender, to, value);
        emit SparkleRedistribution(msg.sender, taxAmount);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        uint256 taxAmount = value.mul(TAX).div(PERCENT);

        _balances[from] = balanceOf(from).sub(value).sub(taxAmount);
        _balances[to] = balanceOf(to).add(value);

        _tobinsClaimed[from] = _tobinsCollected;
        _tobinsClaimed[to] = _tobinsCollected;
        _tobinsCollected = _tobinsCollected.add(taxAmount);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);
        emit SparkleRedistribution(from, taxAmount);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function () external payable {
        mintSparkle();
    }

    function mintSparkle() public payable returns (bool) {
        uint256 amount = msg.value.mul(10 ** 18).div(COST_PER_TOKEN);
        require(_totalSupply.add(amount) <= MAX_SUPPLY);

        uint256 taxAmount = amount.mul(TAX).div(PERCENT);
        uint256 creatorAmount = amount.mul(1).div(PERCENT);
        uint256 buyerAmount = amount.sub(taxAmount).sub(creatorAmount);

        _balances[msg.sender] = balanceOf(msg.sender).add(buyerAmount);
        _balances[creator]= balanceOf(creator).add(creatorAmount);

        _totalSupply = _totalSupply.add(amount);

        _tobinsClaimed[msg.sender] = _tobinsCollected;
        _tobinsClaimed[creator] = _tobinsCollected;
        _tobinsCollected = _tobinsCollected.add(taxAmount);

        emit Mint(msg.sender, buyerAmount);
        emit SparkleRedistribution(msg.sender, taxAmount);

        return true;
    }

    function sellSparkle(uint256 amount) public returns (bool) {
        require(amount > 0 && balanceOf(msg.sender) >= amount);

        uint256 reward = amount.mul(COST_PER_TOKEN).div(10 ** 18);

        uint256 creatorAmount = reward.mul(3).div(PERCENT);
        uint256 sellerAmount = reward.sub(creatorAmount);

        _balances[msg.sender] = balanceOf(msg.sender).sub(amount);
        _tobinsClaimed[msg.sender] = _tobinsCollected;

        _totalSupply = _totalSupply.sub(amount);

        creator.transfer(creatorAmount);
        msg.sender.transfer(sellerAmount);

        emit Sell(msg.sender, amount);

        return true;
    }


}