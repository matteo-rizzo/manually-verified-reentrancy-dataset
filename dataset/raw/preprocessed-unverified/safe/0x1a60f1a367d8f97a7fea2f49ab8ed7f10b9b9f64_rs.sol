/**
 *Submitted for verification at Etherscan.io on 2021-04-06
*/

pragma solidity =0.6.6;

/**
 * Math operations with safety checks
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */









contract UsdgMarket is Ownable{
    using SafeMath for uint;

    uint oneEth = 1000000000000000000;
    uint8  public buyTokenRate = 100;
    uint8  public saleTokenRate = 100;

    IUniswapV2Router01 public uniswapRouter;
    ERC20 public usdg;

    address[] pathEth2Usdg;
    address public upgradedAddress;
    bool public upgraded = false;

    event BuyToken(address indexed from,uint inValue, uint outValue);
    event SaleToken(address indexed from,uint inValue, uint outValue);
    event GovWithdrawEth(address indexed to, uint256 value);
    event GovWithdrawToken(address indexed to, uint256 value);

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'Market: EXPIRED');
        _;
    }

    constructor(address _usdg, address _usdt, address _uniswap)public {
        _setPath(_usdg,_usdt,_uniswap);
    }

    function _setPath(address _usdg, address _usdt,address _uniswap)private {
        uniswapRouter = IUniswapV2Router01(_uniswap);
        address _weth = uniswapRouter.WETH();
        usdg = ERC20(_usdg);
        pathEth2Usdg.push(_weth);
        pathEth2Usdg.push(_usdt);
    }

    function getEthPrice()public view returns (uint balance) {
        uint[] memory amounts = uniswapRouter.getAmountsOut( oneEth, pathEth2Usdg);
        return amounts[1];
    }
    function _getAmountsOutToken(uint value, uint8 rate) private view returns (uint balance) {
        uint rs = getEthPrice();  
        rs = rs.mul(value).div(oneEth);
        if(rate > 0){
            rs = rs.mul(rate).div(100);
        }
        rs = rs.mul(1000); 
        return rs;
    }

    function _getAmountsOutEth(uint value, uint8 rate) private view returns (uint balance) {
        uint ePrice = getEthPrice();   
        uint uPrice = oneEth.div(ePrice);  
        uint rs = uPrice.mul(value);
        if(rate > 0){
            rs = rs.mul(rate).div(100);
        }
        rs = rs.div(1000); 
        return rs;
    }

    function getAmountsOutToken(uint _value) public view returns (uint balance) {
        uint amount;
        if (upgraded) {
            amount = UpgradedPriceAble(upgradedAddress).getAmountsOutToken(_value,buyTokenRate);
        } else {
            amount = _getAmountsOutToken(_value,buyTokenRate);
        }
        return amount;
    }

    function getAmountsOutEth(uint _value) public view returns (uint balance) {
        uint amount;
        if (upgraded) {
            amount = UpgradedPriceAble(upgradedAddress).getAmountsOutToken(_value,saleTokenRate);
        } else {
            amount = _getAmountsOutEth(_value,saleTokenRate);
        }
        return amount;
    }

    function buyTokenSafe(uint amountOutMin,  uint deadline)payable ensure(deadline) public {
        require(msg.value > 0, "!value");
        uint amount = getAmountsOutToken(msg.value);
        require(amount >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        uint balanced = usdg.balanceOf(address(this));
        require(balanced >= amount, "!contract balanced");
        usdg.transfer(msg.sender, amount);
        BuyToken(msg.sender,msg.value, amount);
    }

    function saleTokenSafe(uint256 _value,uint amountOutMin,  uint deadline) ensure(deadline) public {
        require(_value > 0, "!value");
        uint amount = getAmountsOutEth(_value);
        require(amount >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        msg.sender.transfer(amount);
        uint allowed = usdg.allowance(msg.sender,address(this));
        uint balanced = usdg.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        usdg.transferFrom( msg.sender,address(this), _value);
        SaleToken(msg.sender,_value, amount);
    }

    function buyToken()payable  public {
        require(msg.value > 0, "!value");
        uint amount = getAmountsOutToken(msg.value);
        uint balanced = usdg.balanceOf(address(this));
        require(balanced >= amount, "!contract balanced");
        usdg.transfer(msg.sender, amount);
        BuyToken(msg.sender,msg.value, amount);
    }

    function saleToken(uint256 _value) public {
        require(_value > 0, "!value");
        uint amount = getAmountsOutEth(_value);
        msg.sender.transfer(amount);
        uint allowed = usdg.allowance(msg.sender,address(this));
        uint balanced = usdg.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        usdg.transferFrom( msg.sender,address(this), _value);
        SaleToken(msg.sender,_value, amount);
    }

    function govWithdrawToken(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");

        usdg.transfer( msg.sender, _amount);
        emit GovWithdrawToken(msg.sender, _amount);
    }

    function govWithdrawEth(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        msg.sender.transfer(_amount);
        emit GovWithdrawEth(msg.sender, _amount);
    }

    function changeRates(uint8 _buyTokenRate, uint8 _saleTokenRate)onlyOwner public {
        require(201 > buyTokenRate, "_buyTokenRate big than 200");
        require(201 > _saleTokenRate, "_saleTokenRate big than 200");
        buyTokenRate = _buyTokenRate;
        saleTokenRate = _saleTokenRate;
    }

    fallback() external payable {}
}