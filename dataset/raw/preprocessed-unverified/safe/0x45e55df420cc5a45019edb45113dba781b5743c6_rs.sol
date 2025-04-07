/**
 *Submitted for verification at Etherscan.io on 2021-07-22
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






contract dcStake is Ownable{
    using SafeMath for uint;

    mapping (address => uint) public dcoinRecords;
    mapping (address => uint) public ethRecords;
    uint burnRate;

    address public weth;
    address public usdt;
    address public usdg;
    ERC20 public dcoin;

    Oracle public oracle;

    event StakeChange( address indexed from,uint ethValue,uint dcoinValue, bool isBuy);
    event WithDraw( address indexed from,uint ethValue, uint returnDcoin, uint burnDcoin);

    event GovWithdraw(address indexed to, uint256 value);
    event GovWithdrawToken(address indexed to, uint256 value);

    constructor(address _oracle, address _usdg, address _usdt,address _weth, address _dcoin)public {
        oracle = Oracle(_oracle);
        usdg = _usdg;
        usdt = _usdt;
        weth = _weth;
        dcoin = ERC20(_dcoin);
    }

    function priceEth2DCoin(uint inValue) public view returns (uint){
        uint tmp = oracle.getUniOutput(inValue,weth,usdt);
        return  oracle.getUniOutput(tmp,usdg,address(dcoin));
    }

    function stakeWithEth() public payable{
        require(msg.value > 0, "!eth value");
        require(msg.value < 10 ether, "!eth value");
        uint needDcoin = priceEth2DCoin(msg.value);
        uint allowed = dcoin.allowance(msg.sender,address(this));
        uint balanced = dcoin.balanceOf(msg.sender);
        require(allowed >= needDcoin, "!allowed");
        require(balanced >= needDcoin, "!balanced");
        dcoin.transferFrom(msg.sender,address(this), needDcoin);

        dcoinRecords[msg.sender] = dcoinRecords[msg.sender].add(needDcoin);
        ethRecords[msg.sender]=ethRecords[msg.sender].add(msg.value);

        StakeChange(msg.sender,msg.value, needDcoin,true);
    }

    function withdraw() public {
        uint storedEth = ethRecords[msg.sender];
        require(storedEth > 0, "!stored");
        uint storedDcoin = dcoinRecords[msg.sender];
        uint burnDcoin = storedDcoin.mul(burnRate).div(100);
        uint returnDcoin = storedDcoin.sub(burnDcoin);
        ethRecords[msg.sender] = 0;
        dcoinRecords[msg.sender] = 0;
        dcoin.transfer( msg.sender, returnDcoin);
        dcoin.transfer( address(0), burnDcoin);
        msg.sender.transfer(storedEth);

        StakeChange(msg.sender,storedEth, storedDcoin,false);
    }

    function balanceOf(address _addr) public view returns (uint balance) {
        return ethRecords[_addr];
    }

    function setOracle(address _oracle)onlyOwner public {
        oracle = Oracle(_oracle);
    }

    function setBurnRate(uint _burnRate)onlyOwner public {
        require(_burnRate < 100, "!range");
        burnRate = _burnRate;
    }

    function govWithdrawEther(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        msg.sender.transfer(_amount);
        emit GovWithdraw(msg.sender, _amount);
    }

    function govWithdrawToken(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        dcoin.transfer(msg.sender, _amount);
        emit GovWithdrawToken(msg.sender, _amount);
    }
}