pragma solidity 0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */









/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract ERC20Extended is ERC20 {

    uint256 public decimals;

    string public name;

    string public symbol;



}



contract ComponentInterface {

    string public name;

    string public description;

    string public category;

    string public version;

}



contract ExchangeInterface is ComponentInterface {

    /*

     * @dev Checks if a trading pair is available

     * For ETH, use 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

     * @param address _sourceAddress The token to sell for the destAddress.

     * @param address _destAddress The token to buy with the source token.

     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.

     * @return boolean whether or not the trading pair is supported by this exchange provider

     */

    function supportsTradingPair(address _srcAddress, address _destAddress, bytes32 _exchangeId)

        external view returns(bool supported);



    /*

     * @dev Buy a single token with ETH.

     * @param ERC20Extended _token The token to buy, should be an ERC20Extended address.

     * @param uint _amount Amount of ETH used to buy this token. Make sure the value sent to this function is the same as the _amount.

     * @param uint _minimumRate The minimum amount of tokens to receive for 1 ETH.

     * @param address _depositAddress The address to send the bought tokens to.

     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.

     * @param address _partnerId If the exchange supports a partnerId, you can supply your partnerId here.

     * @return boolean whether or not the trade succeeded.

     */

    function buyToken

        (

        ERC20Extended _token, uint _amount, uint _minimumRate,

        address _depositAddress, bytes32 _exchangeId, address _partnerId

        ) external payable returns(bool success);



    /*

     * @dev Sell a single token for ETH. Make sure the token is approved beforehand.

     * @param ERC20Extended _token The token to sell, should be an ERC20Extended address.

     * @param uint _amount Amount of tokens to sell.

     * @param uint _minimumRate The minimum amount of ETH to receive for 1 ERC20Extended token.

     * @param address _depositAddress The address to send the bought tokens to.

     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.

     * @param address _partnerId If the exchange supports a partnerId, you can supply your partnerId here

     * @return boolean boolean whether or not the trade succeeded.

     */

    function sellToken

        (

        ERC20Extended _token, uint _amount, uint _minimumRate,

        address _depositAddress, bytes32 _exchangeId, address _partnerId

        ) external returns(bool success);

}



contract KyberNetworkInterface {



    function getExpectedRate(ERC20Extended src, ERC20Extended dest, uint srcQty)

        external view returns (uint expectedRate, uint slippageRate);



    function trade(

        ERC20Extended source,

        uint srcAmount,

        ERC20Extended dest,

        address destAddress,

        uint maxDestAmount,

        uint minConversionRate,

        address walletId)

        external payable returns(uint);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract OlympusExchangeAdapterInterface is Ownable {



    function supportsTradingPair(address _srcAddress, address _destAddress)

        external view returns(bool supported);



    function getPrice(ERC20Extended _sourceAddress, ERC20Extended _destAddress, uint _amount)

        external view returns(uint expectedRate, uint slippageRate);



    function sellToken

        (

        ERC20Extended _token, uint _amount, uint _minimumRate,

        address _depositAddress

        ) external returns(bool success);



    function buyToken

        (

        ERC20Extended _token, uint _amount, uint _minimumRate,

        address _depositAddress

        ) external payable returns(bool success);



    function enable() external returns(bool);

    function disable() external returns(bool);

    function isEnabled() external view returns (bool success);



    function setExchangeDetails(bytes32 _id, bytes32 _name) external returns(bool success);

    function getExchangeDetails() external view returns(bytes32 _name, bool _enabled);



}



contract ERC20NoReturn {

    uint256 public decimals;

    string public name;

    string public symbol;

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public;

    function approve(address spender, uint tokens) public;

    function transferFrom(address from, address to, uint tokens) public;



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



contract KyberNetworkAdapter is OlympusExchangeAdapterInterface{

    using SafeMath for uint256;



    KyberNetworkInterface public kyber;

    address public exchangeAdapterManager;

    bytes32 public exchangeId;

    bytes32 public name;

    ERC20Extended public constant ETH_TOKEN_ADDRESS = ERC20Extended(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    address public walletId = 0x09227deaeE08a5Ba9D6Eb057F922aDfAd191c36c;



    bool public adapterEnabled;



    modifier onlyExchangeAdapterManager() {

        require(msg.sender == address(exchangeAdapterManager));

        _;

    }



    constructor (KyberNetworkInterface _kyber, address _exchangeAdapterManager) public {

        require(address(_kyber) != 0x0);

        kyber = _kyber;

        exchangeAdapterManager = _exchangeAdapterManager;

        adapterEnabled = true;

    }



    function setExchangeAdapterManager(address _exchangeAdapterManager) external onlyOwner{

        exchangeAdapterManager = _exchangeAdapterManager;

    }



    function setExchangeDetails(bytes32 _id, bytes32 _name)

    external onlyExchangeAdapterManager returns(bool)

    {

        exchangeId = _id;

        name = _name;

        return true;

    }



    function getExchangeDetails()

    external view returns(bytes32 _name, bool _enabled)

    {

        return (name, adapterEnabled);

    }



    function getExpectAmount(uint eth, uint destDecimals, uint rate) internal pure returns(uint){

        return Utils.calcDstQty(eth, 18, destDecimals, rate);

    }



    function configAdapter(KyberNetworkInterface _kyber, address _walletId) external onlyOwner returns(bool success) {

        if(address(_kyber) != 0x0){

            kyber = _kyber;

        }

        if(_walletId != 0x0){

            walletId = _walletId;

        }

        return true;

    }



    function supportsTradingPair(address _srcAddress, address _destAddress) external view returns(bool supported){

        // Get price for selling one

        uint amount = ERC20Extended(_srcAddress) == ETH_TOKEN_ADDRESS ? 10**18 : 10**ERC20Extended(_srcAddress).decimals();

        uint price;

        (price,) = this.getPrice(ERC20Extended(_srcAddress), ERC20Extended(_destAddress), amount);

        return price > 0;

    }



    function enable() external onlyOwner returns(bool){

        adapterEnabled = true;

        return true;

    }



    function disable() external onlyOwner returns(bool){

        adapterEnabled = false;

        return true;

    }



    function isEnabled() external view returns (bool success) {

        return adapterEnabled;

    }



    function getPrice(ERC20Extended _sourceAddress, ERC20Extended _destAddress, uint _amount) external view returns(uint, uint){

        return kyber.getExpectedRate(_sourceAddress, _destAddress, _amount);

    }



    function buyToken(ERC20Extended _token, uint _amount, uint _minimumRate, address _depositAddress)

    external payable returns(bool) {

        if (address(this).balance < _amount) {

            return false;

        }

        require(msg.value == _amount);

        uint slippageRate;



        (, slippageRate) = kyber.getExpectedRate(ETH_TOKEN_ADDRESS, _token, _amount);

        if(slippageRate < _minimumRate){

            return false;

        }



        uint beforeTokenBalance = _token.balanceOf(_depositAddress);

        slippageRate = _minimumRate;

        kyber.trade.value(msg.value)(

            ETH_TOKEN_ADDRESS,

            _amount,

            _token,

            _depositAddress,

            2**256 - 1,

            slippageRate,

            walletId);



        require(_token.balanceOf(_depositAddress) > beforeTokenBalance);



        return true;

    }

    function sellToken(ERC20Extended _token, uint _amount, uint _minimumRate, address _depositAddress)

    external returns(bool success)

    {

        ERC20NoReturn(_token).approve(address(kyber), 0);

        ERC20NoReturn(_token).approve(address(kyber), _amount);

        uint slippageRate;

        (,slippageRate) = kyber.getExpectedRate(_token, ETH_TOKEN_ADDRESS, _amount);



        if(slippageRate < _minimumRate){

            return false;

        }

        slippageRate = _minimumRate;



        // uint beforeTokenBalance = _token.balanceOf(this);

        kyber.trade(

            _token,

            _amount,

            ETH_TOKEN_ADDRESS,

            _depositAddress,

            2**256 - 1,

            slippageRate,

            walletId);



        // require(_token.balanceOf(this) < beforeTokenBalance);

        // require((beforeTokenBalance - _token.balanceOf(this)) == _amount);



        return true;

    }



    function withdraw(uint amount) external onlyOwner {



        require(amount <= address(this).balance);



        uint sendAmount = amount;

        if (amount == 0){

            sendAmount = address(this).balance;

        }

        msg.sender.transfer(sendAmount);

    }



}