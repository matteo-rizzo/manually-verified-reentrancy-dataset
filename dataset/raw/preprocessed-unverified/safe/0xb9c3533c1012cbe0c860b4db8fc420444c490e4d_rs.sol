/**
 *Submitted for verification at Etherscan.io on 2020-04-29
*/

pragma solidity ^0.6.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */





contract UniswapOTC {
    address public owner;
    address public exchangeAddress;
    address public tokenAddress;

    uint256 public totalClients;
    address[] public clients;
    mapping (address => bool) public clientExists;
    
    mapping (address => uint256) public clientEthBalances;      //Client ETH balance
    mapping (address => uint256) public clientMinTokens;        //Client Limit Order
    mapping (address => uint256) public clientTokenBalances;    //Client Token balance
    mapping (address => uint256) public clientTokenFees;        //Total OTC Fees
    mapping (address => uint256) public purchaseTimestamp;        //Withdrawal timestamp
    uint256 constant ONE_DAY_SECONDS = 86400;
    uint256 constant FIVE_MINUTE_SECONDS = 300;
    
    mapping(address => bool) public triggerAddresses;           //Bot Trigger Addresses

    IERC20 token;
    IUniswapExchange exchange;

    //Min volume values
    uint256 public minEthLimit;     //Min Volume
    uint256 public maxTokenPerEth;  //Min Price
    
    constructor(address _exchangeAddress, uint256 _minEthLimit, uint256 _maxTokenPerEth) public {
        exchange = IUniswapExchange(_exchangeAddress);
        exchangeAddress = _exchangeAddress;
        tokenAddress = exchange.tokenAddress();
        token = IERC20(tokenAddress);
        owner = msg.sender;
        minEthLimit = _minEthLimit;
        maxTokenPerEth = _maxTokenPerEth;
        totalClients = 0;
    }

    /**
     * @dev OTC Provider. Gives right to fee withdrawal.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    /**
     * @dev Authorized Purchase Trigger addresses for mempool bot.
     */
    modifier onlyTrigger() {
        require(msg.sender == owner || triggerAddresses[msg.sender], "Unauthorized");
        _;
    }

    /**
     * @dev Trigger Uniswap contract, drains client's ETH balance.
     *      Computes fee as spread between execution price and limit price.
     */
    function executeLimitOrder(address _client, uint256 deadline)
        public
        onlyTrigger
        returns (uint256, uint256)
    {
        //Avoids Uniswap Assert Failure when no liquidity (gas saving)
        require(token.balanceOf(exchangeAddress) > 0, "No liquidity on Uniswap!"); //27,055 Gas

        uint256 ethBalance = clientEthBalances[_client];
        uint256 tokensBought = exchange.getEthToTokenInputPrice(ethBalance);
        uint256 minTokens = clientMinTokens[_client];

        require(tokensBought >= minTokens, "Purchase amount below min tokens!"); //27,055 Gas

        uint256 spreadFee = tokensBought - minTokens;
        //Tokens bought, set balance 0
        clientEthBalances[_client] = 0; //Reset state
        clientMinTokens[_client] = 0; //Reset state
        clientTokenBalances[_client] += minTokens;  //Add to balance
        clientTokenFees[_client] += spreadFee;      //Add to balance
        purchaseTimestamp[_client] = block.timestamp + ONE_DAY_SECONDS;

        //Call Uniswap contract
        exchange.ethToTokenSwapInput.value(ethBalance)(
            tokensBought,
            deadline
        );

        return (minTokens, spreadFee);
    }

    /**
     * @dev Add Trigger address.
     */
    function setTriggerAddress(address _address, bool _authorized)
        public
        onlyOwner
    {
        triggerAddresses[_address] = _authorized;
    }

    /**
     * @dev Get max limit price.
     */
    function getMaxTokens(uint256 _etherAmount)
        public
        view
        returns (uint256)
    {
        return _etherAmount * maxTokenPerEth;
    }

    /**
     * @dev Fund contract and set limit price (in the form of min purchased tokens).
     * Excess value is refunded to sender in the case of a re-balancing.
     */
    function setLimitOrder(uint256 _tokenAmount, uint256 _etherAmount)
        public
        payable
    {
        require(_etherAmount >= minEthLimit, "Insufficient ETH volume");
        require(_tokenAmount <= maxTokenPerEth  * _etherAmount, "Excessive token per ETH");
        require(_etherAmount == clientEthBalances[msg.sender] + msg.value, "Balance must equal purchase eth amount.");

        if (!clientExists[msg.sender]) {
            clientExists[msg.sender] = true;
            clients.push(msg.sender);
            totalClients += 1;
        }
        
        //Increment client balance
        clientEthBalances[msg.sender] += msg.value;
        clientMinTokens[msg.sender] = _tokenAmount;
    }


    /**
     * @dev Return if purchase would be autherized at current prices
     */
    function canPurchase(address _client)
        public
        view
        returns (bool)
    {
        //Avoids Uniswap Assert Failure when no liquidity (gas saving)
        if (token.balanceOf(exchangeAddress) == 0) {
            return false;
        }

        uint256 ethBalance = clientEthBalances[_client];
        if (ethBalance == 0) {
            return false;
        }
        
        uint256 tokensBought = exchange.getEthToTokenInputPrice(ethBalance);
        uint256 minTokens = clientMinTokens[_client];

        //Only minimum amount of tokens
        return tokensBought >= minTokens;
    }

    /**
     * @dev Withdraw OTC provider fee tokens.
     */
    function withdrawFeeTokens(address _client) public onlyOwner {
        require(clientTokenFees[_client] > 0, "No fees!");
        require(block.timestamp > purchaseTimestamp[_client], "Wait for client withdrawal.");

        uint256 sendFees = clientTokenFees[_client];
        clientTokenFees[_client] = 0;

        token.transfer(msg.sender, sendFees);
    }

    /**
     * @dev Withdraw OTC client purchased tokens.
     */
    function withdrawClientTokens() public {
        require(clientTokenBalances[msg.sender] > 0, "No tokens!");

        uint256 sendTokens = clientTokenBalances[msg.sender];
        clientTokenBalances[msg.sender] = 0;
        purchaseTimestamp[msg.sender] = block.timestamp + FIVE_MINUTE_SECONDS;  //Unlock in 5minutes

        token.transfer(msg.sender, sendTokens);
    }
    

    /**
     * @dev Withdraw OTC client ether.
     */
    function withdrawEther() public {
        require(clientEthBalances[msg.sender] > 0, "No ETH balance!");

        uint256 sendEth = clientEthBalances[msg.sender];
        clientEthBalances[msg.sender] = 0;

        payable(msg.sender).transfer(sendEth);
    }

    /**
     * @dev Get eth balance of contract.
     */
    function contractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Get token balance of contract
     */
    function contractTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

}