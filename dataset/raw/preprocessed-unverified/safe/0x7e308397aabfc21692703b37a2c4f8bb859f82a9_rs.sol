/**
 *Submitted for verification at Etherscan.io on 2021-05-16
*/

pragma solidity =0.6.6;
/**
合约1，4种token换Bc
参数:
0x9DaAfE4c2db3Af141BE9E0be5b4f38C89471E02d

*/
/**
 * Math operations with safety checks
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */







contract bcMarket is Ownable{
    using SafeMath for uint;

    ERC20 public bc;
    ERC20 public usdg;
    ERC20 public usdt;
    ERC20_Returns public usdc;
    ERC20_Returns public dai;
    Oracle public oracle;

    uint  usdgDecimals = 9;
    uint  usdtDecimals = 6;
    uint  usdcDecimals = 6;
    uint  daiDecimals = 18;

    event SaleToken(address indexed token, address indexed from,uint inValue, uint outValue);
    event GovWithdrawToken(address indexed token, address indexed to, uint256 value);

    constructor(address _oracle, address _usdg, address _usdt,address _usdc, address _dai,address _bc)public {
        oracle = Oracle(_oracle);
        usdg = ERC20(_usdg);
        usdt = ERC20(_usdt);
        usdc = ERC20_Returns(_usdc);
        dai = ERC20_Returns(_dai);
        bc = ERC20(_bc);
    }

    function getPrice() public view returns (uint){
        return oracle.usdgToBc();
    }

    function swapUsdg(uint256 _value) public {
        ERC20 token = usdg;
        uint decimals = usdgDecimals;
        require(_value > 0, "!value");

        uint allowed = token.allowance(msg.sender,address(this));
        uint balanced = token.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        token.transferFrom( msg.sender,address(this), _value);

        uint price = getPrice();
        uint amount = _value.mul(price).div(10 ** decimals);
        bc.transfer( msg.sender, amount);

        SaleToken(address(token),msg.sender,_value, amount);
    }
    function swapUsdt(uint256 _value) public {
        ERC20 token = usdt;
        uint decimals = usdtDecimals;
        require(_value > 0, "!value");

        uint allowed = token.allowance(msg.sender,address(this));
        uint balanced = token.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        token.transferFrom( msg.sender,address(this), _value);

        uint price = getPrice();
        uint amount = _value.mul(price).div(10 ** decimals);
        bc.transfer( msg.sender, amount);

        SaleToken(address(token),msg.sender,_value, amount);
    }
    function swapUsdc(uint256 _value) public {
        ERC20_Returns token = usdc;
        uint decimals = usdcDecimals;
        require(_value > 0, "!value");

        uint allowed = token.allowance(msg.sender,address(this));
        uint balanced = token.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        token.transferFrom( msg.sender,address(this), _value);

        uint price = getPrice();
        uint amount = _value.mul(price).div(10 ** decimals);
        bc.transfer( msg.sender, amount);

        SaleToken(address(token),msg.sender,_value, amount);
    }
    function swapDai(uint256 _value) public {
        ERC20_Returns token = dai;
        uint decimals = daiDecimals;
        require(_value > 0, "!value");

        uint allowed = token.allowance(msg.sender,address(this));
        uint balanced = token.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        token.transferFrom( msg.sender,address(this), _value);

        uint price = getPrice();
        uint amount = _value.mul(price).div(10 ** decimals);
        bc.transfer( msg.sender, amount);

        SaleToken(address(token),msg.sender,_value, amount);
    }

    function govWithdraUsdt(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        usdt.transfer( msg.sender, _amount);
        emit GovWithdrawToken(address(usdt), msg.sender, _amount);
    }
    function govWithdraUsdg(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        usdg.transfer( msg.sender, _amount);
        emit GovWithdrawToken(address(usdg), msg.sender, _amount);
    }
    function govWithdraUsdc(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        usdc.transfer( msg.sender, _amount);
        emit GovWithdrawToken(address(usdc), msg.sender, _amount);
    }
    function govWithdraDai(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        dai.transfer( msg.sender, _amount);
        emit GovWithdrawToken(address(dai), msg.sender, _amount);
    }

    function govWithdraBc(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        bc.transfer( msg.sender, _amount);
        emit GovWithdrawToken(address(bc), msg.sender, _amount);
    }

    function setOracle(address _oracle)onlyOwner public {
        oracle = Oracle(_oracle);
    }
}