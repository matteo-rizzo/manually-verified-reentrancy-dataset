/**
 *Submitted for verification at Etherscan.io on 2019-08-30
*/

/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------
file:       ArbRewarder.sol
version:    1.0
author:     justwanttoknowathing
checked:    Clinton Ennis, Jackson Chan
date:       2019-05-01

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------
The Synthetix ArbRewarder Contract for fixing the sETH/ETH peg

Allows a user to send ETH to the contract via addEth()
- If the sETH/ETH ratio is below 99/100 & there is sufficient SNX
remaining in the contract at the current exchange rate.
- Convert the ETH to sETH via Uniswap up to the 99/100 ratio or the ETH is exhausted
- Convert the sETH to SNX at the current exchange rate.
- Send the SNX to the wallet that sent the ETH

-----------------------------------------------------------------
*/

/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       Owned.sol
version:    1.1
author:     Anton Jurisevic
            Dominic Romanowski

date:       2018-2-26

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

An Owned contract, to be inherited by other contracts.
Requires its owner to be explicitly set in the constructor.
Provides an onlyOwner access modifier.

To change owner, the current owner must nominate the next owner,
who then has to accept the nomination. The nomination can be
cancelled before it is accepted by the new owner by having the
previous owner change the nomination (setting it to 0).

-----------------------------------------------------------------
*/

pragma solidity 0.4.25;

/**
 * @title A contract with an owner.
 * @notice Contract ownership can be transferred by first nominating the new owner,
 * who must then accept the ownership, which prevents accidental incorrect ownership transfers.
 */


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       SelfDestructible.sol
version:    1.2
author:     Anton Jurisevic

date:       2018-05-29

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

This contract allows an inheriting contract to be destroyed after
its owner indicates an intention and then waits for a period
without changing their mind. All ether contained in the contract
is forwarded to a nominated beneficiary upon destruction.

-----------------------------------------------------------------
*/


/**
 * @title A contract that can be destroyed by its owner after a delay elapses.
 */
contract SelfDestructible is Owned {
    
    uint public initiationTime;
    bool public selfDestructInitiated;
    address public selfDestructBeneficiary;
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    /**
     * @dev Constructor
     * @param _owner The account which controls this contract.
     */
    constructor(address _owner)
        Owned(_owner)
        public
    {
        require(_owner != address(0), "Owner must not be zero");
        selfDestructBeneficiary = _owner;
        emit SelfDestructBeneficiaryUpdated(_owner);
    }

    /**
     * @notice Set the beneficiary address of this contract.
     * @dev Only the contract owner may call this. The provided beneficiary must be non-null.
     * @param _beneficiary The address to pay any eth contained in this contract to upon self-destruction.
     */
    function setSelfDestructBeneficiary(address _beneficiary)
        external
        onlyOwner
    {
        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    /**
     * @notice Begin the self-destruction counter of this contract.
     * Once the delay has elapsed, the contract may be self-destructed.
     * @dev Only the contract owner may call this.
     */
    function initiateSelfDestruct()
        external
        onlyOwner
    {
        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    /**
     * @notice Terminate and reset the self-destruction timer.
     * @dev Only the contract owner may call this.
     */
    function terminateSelfDestruct()
        external
        onlyOwner
    {
        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    /**
     * @notice If the self-destruction delay has elapsed, destroy this contract and
     * remit any ether it owns to the beneficiary address.
     * @dev Only the contract owner may call this.
     */
    function selfDestruct()
        external
        onlyOwner
    {
        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        address beneficiary = selfDestructBeneficiary;
        emit SelfDestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       Pausable.sol
version:    1.0
author:     Kevin Brown

date:       2018-05-22

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

This contract allows an inheriting contract to be marked as
paused. It also defines a modifier which can be used by the
inheriting contract to prevent actions while paused.

-----------------------------------------------------------------
*/


/**
 * @title A contract that can be paused by its owner
 */
contract Pausable is Owned {
    
    uint public lastPauseTime;
    bool public paused;

    /**
     * @dev Constructor
     * @param _owner The account which controls this contract.
     */
    constructor(address _owner)
        Owned(_owner)
        public
    {
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused)
        external
        onlyOwner
    {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;
        
        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = now;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */



/*

-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       SafeDecimalMath.sol
version:    2.0
author:     Kevin Brown
            Gavin Conway
date:       2018-10-18

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

A library providing safe mathematical operations for division and
multiplication with the capability to round or truncate the results
to the nearest increment. Operations can return a standard precision
or high precision decimal. High precision decimals are useful for
example when attempting to calculate percentages or fractions
accurately.

-----------------------------------------------------------------
*/


/**
 * @title Safely manipulate unsigned fixed-point decimals at a given precision level.
 * @dev Functions accepting uints in this contract and derived contracts
 * are taken to be such fixed point decimals of a specified precision (either standard
 * or high).
 */



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20 {
    function totalSupply() public view returns (uint);

    function balanceOf(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    // ERC20 Optional
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);

    event Transfer(
      address indexed from,
      address indexed to,
      uint value
    );

    event Approval(
      address indexed owner,
      address indexed spender,
      uint value
    );
}


/**
 * @title ExchangeRates interface
 */


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------
file:       ArbRewarder.sol
version:    1.0
author:     justwanttoknowathing
checked:    Clinton Ennis, Jackson Chan
date:       2019-05-01

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------
The Synthetix ArbRewarder Contract for fixing the sETH/ETH peg

Allows a user to send ETH to the contract via addEth()
- If the sETH/ETH ratio is below 99/100 & there is sufficient SNX
remaining in the contract at the current exchange rate.
- Convert the ETH to sETH via Uniswap up to the 99/100 ratio or the ETH is exhausted
- Convert the sETH to SNX at the current exchange rate.
- Send the SNX to the wallet that sent the ETH

-----------------------------------------------------------------
*/


contract ArbRewarder is SelfDestructible, Pausable {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    /* How far off the peg the pool must be to allow its ratio to be pushed up or down
     * by this contract, thus granting the caller arbitrage rewards.
     * Parts-per-hundred-thousand: 100 = 1% */
    uint off_peg_min = 100;

    /* Additional slippage we'll allow on top of the uniswap trade
     * Parts-per-hundred-thousand: 100 = 1%
     * Example: 95 sETH, 100 ETH, buy 1 sETH -> expected: 1.03857 ETH
     * After acceptable_slippage:  1.02818 ETH */
    uint acceptable_slippage = 100;

    /* How long we'll let a uniswap transaction sit before it becomes invalid
     * In seconds. Prevents miners holding our transaction and using it later. */
    uint max_delay = 600;

    /* Divisor for off_peg_min and acceptable_slippage */
    uint constant divisor = 10000;

    /* Contract Addresses */
    address public seth_exchange_addr = 0x4740C758859D4651061CC9CDEFdBa92BDc3a845d;
    address public snx_erc20_addr = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;

    IExchangeRates public synthetix_rates = IExchangeRates(0x457eec906f9Dcb609b9F2c7dC0f58E182F24C350);
    IUniswapExchange public seth_uniswap_exchange = IUniswapExchange(seth_exchange_addr);

    IERC20 public seth_erc20 = IERC20(0xAb16cE44e6FA10F3d5d0eC69EB439c6815f37a24);
    IERC20 public snx_erc20 = IERC20(snx_erc20_addr);

    
    /* ========== CONSTRUCTOR ========== */

    /**
     * @dev Constructor
     */
    constructor(address _owner)
        /* Owned is initialised in SelfDestructible */
        SelfDestructible(_owner)
        Pausable(_owner)
        public
    {}

    /* ========== SETTERS ========== */

    function setParams(uint _acceptable_slippage, uint _max_delay, uint _off_peg_min) external onlyOwner {
        require(_off_peg_min < divisor, "_off_peg_min less than divisor");
        require(_acceptable_slippage < divisor, "_acceptable_slippage less than divisor");
        acceptable_slippage = _acceptable_slippage;
        max_delay = _max_delay;
        off_peg_min = _off_peg_min;
    }

    function setSynthetix(address _address) external onlyOwner {
        snx_erc20_addr = _address;
        snx_erc20 = IERC20(snx_erc20_addr);
    }

    function setSynthETHAddress(address _seth_erc20_addr, address _seth_exchange_addr) external onlyOwner {
        seth_exchange_addr = _seth_exchange_addr;
        seth_uniswap_exchange = IUniswapExchange(seth_exchange_addr);

        seth_erc20 = IERC20(_seth_erc20_addr);
        seth_erc20.approve(seth_exchange_addr, uint(-1));
    }

    function setExchangeRates(address _synxthetix_rates_addr) external onlyOwner {
        synthetix_rates = IExchangeRates(_synxthetix_rates_addr);
    }

    /* ========== OWNER ONLY ========== */

    function recoverETH(address to_addr) external onlyOwner {
        to_addr.transfer(address(this).balance);
    }

    function recoverERC20(address erc20_addr, address to_addr) external onlyOwner {
        IERC20 erc20_interface = IERC20(erc20_addr);
        erc20_interface.transfer(to_addr, erc20_interface.balanceOf(address(this)));
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    /**
     * Here the caller gives us some ETH. We convert the ETH->sETH  and reward the caller with SNX worth
     * the value of the sETH received from the earlier swap.
     */
    function addEth() public payable
        rateNotStale("ETH")
        rateNotStale("SNX")
        notPaused
        returns (uint reward_tokens)
    {
        /* Ensure there is enough more sETH than ETH in the Uniswap pool */
        uint seth_in_uniswap = seth_erc20.balanceOf(seth_exchange_addr);
        uint eth_in_uniswap = seth_exchange_addr.balance;
        require(eth_in_uniswap.divideDecimal(seth_in_uniswap) < uint(divisor-off_peg_min).divideDecimal(divisor), "sETH/ETH ratio is too high");

        /* Get maximum ETH we'll convert for caller */
        uint max_eth_to_convert = maxConvert(eth_in_uniswap, seth_in_uniswap, divisor, divisor-off_peg_min);
        uint eth_to_convert = min(msg.value, max_eth_to_convert);
        uint unspent_input = msg.value - eth_to_convert;

        /* Actually swap ETH for sETH */
        uint min_seth_bought = expectedOutput(seth_uniswap_exchange, eth_to_convert);
        uint tokens_bought = seth_uniswap_exchange.ethToTokenSwapInput.value(eth_to_convert)(min_seth_bought, now + max_delay);

        /* Reward caller */
        reward_tokens = rewardCaller(tokens_bought, unspent_input);
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function rewardCaller(uint bought, uint unspent_input)
        private
        returns
        (uint reward_tokens)
    {
        uint snx_rate = synthetix_rates.rateForCurrency("SNX");
        uint eth_rate = synthetix_rates.rateForCurrency("ETH");

        reward_tokens = eth_rate.multiplyDecimal(bought).divideDecimal(snx_rate);
        snx_erc20.transfer(msg.sender, reward_tokens);

        if(unspent_input > 0) {
            msg.sender.transfer(unspent_input);
        }
    }

    function expectedOutput(IUniswapExchange exchange, uint input) private view returns (uint output) {
        output = exchange.getTokenToEthInputPrice(input);
        output = applySlippage(output);
    }

    function applySlippage(uint input) private view returns (uint output) {
        output = input - (input * (acceptable_slippage / divisor));
    }

    /**
     * maxConvert determines how many tokens need to be swapped to bring a market to a n:d ratio
     * This can be derived by solving a system of equations.
     *
     * First, we know that once we're done balanceA and balanceB should be related by our ratio:
     *
     * n * (A + input) = d * (B - output)
     *
     * From Uniswap's code, we also know how input and output are related:
     *
     * output = (997*input*B) / (1000*A + 997*input)
     *
     * So:
     *
     * n * (A + input) = d * (B - ((997*input*B) / (1000*A + 997*input)))
     *
     * Solving for input (given n>d>0 and B>A>0):
     *
     * input = (sqrt((A * (9*A*n + 3988000*B*d)) / n) - 1997*A) / 1994
     */
    function maxConvert(uint a, uint b, uint n, uint d) private pure returns (uint result) {
        result = (sqrt((a * (9*a*n + 3988000*b*d)) / n) - 1997*a) / 1994;
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function min(uint a, uint b) private pure returns (uint result) {
        result = a > b ? b : a;
    }

    /* ========== MODIFIERS ========== */

    modifier rateNotStale(bytes4 currencyKey) {
        require(!synthetix_rates.rateIsStale(currencyKey), "Rate stale or not a synth");
        _;
    }
}

contract IUniswapExchange {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}