/**
 *Submitted for verification at Etherscan.io on 2021-02-01
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-11
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-13
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;











/*

 A strategy must implement the following calls;
 
 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()
 
 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller
 
*/










contract StrategyFortube {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); //usdc
    address constant public output = address(0x1FCdcE58959f536621d76f5b7FfB955baa5A672F); //for
    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // used for for <> weth <> usdc route

    address constant public yfii = address(0x3BEDb00Cc64655a3ed60d21B8DFCc8463ad62bCF);


    address constant public fortube = address(0xdE7B3b2Fe0E7b4925107615A5b199a4EB40D9ca9);//主合约.
    address constant public fortube_reward = address(0xF8Df2E6E46AC00Cdf3616C4E35278b7704289d82); //领取奖励的合约

    
    uint public strategyfee = 100;
    uint public fee = 300;
    uint public burnfee = 500;
    uint public callfee = 100;
    uint constant public max = 1000;

    uint public withdrawalFee = 0;
    uint constant public withdrawalMax = 10000;
    
    address public governance;
    address public strategyDev;
    address public controller;
    address public burnAddress = 0x5b3DabeEef7B346763689Dd776656d385803b824;

    string public getName;

    address[] public swap2YFIIRouting;
    address[] public swap2TokenRouting;
    
    
    constructor() public {
        governance = msg.sender;
        controller = 0xf90031e3030820b431f04C728aDE7199bA7Ff0B8;
        getName = string(
            abi.encodePacked("yfam:Strategy:", 
                abi.encodePacked(IERC20(want).name(),"The Force Token"
                )
            ));
        swap2YFIIRouting = [output,want,weth,yfii]; //for usdt weth yfii
        swap2TokenRouting = [output,want]; //for usdt
        doApprove();
        strategyDev = tx.origin;
    }

    function doApprove () public{
        IERC20(output).safeApprove(unirouter, 0);
        IERC20(output).safeApprove(unirouter, uint(-1));
    }
    
    
    function deposit() public {
        uint _want = IERC20(want).balanceOf(address(this));
        address _controller = For(fortube).controller();
        if (_want > 0) {
            IERC20(want).safeApprove(_controller, 0);
            IERC20(want).safeApprove(_controller, _want);
            For(fortube).deposit(want,_want);
        }
        
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        
        uint _fee = 0;
        if (withdrawalFee>0){
            _fee = _amount.mul(withdrawalFee).div(withdrawalMax);        
            IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
        }
        
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance,"!governance");
        _withdrawAll();
        
        
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }
    
    function _withdrawAll() internal {
        address _controller = For(fortube).controller();
        IFToken fToken = IFToken(IBankController(_controller).getFTokeAddress(want));
        uint b = fToken.balanceOf(address(this));
        For(fortube).withdraw(want,b);
    }
    
    function harvest() public {
        require(msg.sender == strategyDev,"!");
        ForReward(fortube_reward).claimReward();
        doswap();
        dosplit();//分yfii
        deposit();
    }

    function doswap() internal {
        uint256 _2token = IERC20(output).balanceOf(address(this)).mul(90).div(100); //90%
        uint256 _2yfii = IERC20(output).balanceOf(address(this)).mul(10).div(100);  //10%
        UniswapRouter(unirouter).swapExactTokensForTokens(_2token, 0, swap2TokenRouting, address(this), now.add(1800));
        UniswapRouter(unirouter).swapExactTokensForTokens(_2yfii, 0, swap2YFIIRouting, address(this), now.add(1800));
    }
    function dosplit() internal{
        uint b = IERC20(yfii).balanceOf(address(this));
        uint _fee = b.mul(fee).div(max);
        uint _callfee = b.mul(callfee).div(max);
        uint _burnfee = b.mul(burnfee).div(max);
        IERC20(yfii).safeTransfer(Controller(controller).rewards(), _fee); //3%  3% team 
        IERC20(yfii).safeTransfer(msg.sender, _callfee); //call fee 1%
        IERC20(yfii).safeTransfer(burnAddress, _burnfee); //burn fee 5%

        if (strategyfee >0){
            uint _strategyfee = b.mul(strategyfee).div(max); //1%
            IERC20(yfii).safeTransfer(strategyDev, _strategyfee);
        }
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        For(fortube).withdrawUnderlying(want,_amount);
        return _amount;
    }
    
    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }
    
    function balanceOfPool() public view returns (uint) {
        address _controller = For(fortube).controller();
        IFToken fToken = IFToken(IBankController(_controller).getFTokeAddress(want));
        return fToken.calcBalanceOfUnderlying(address(this));
    }
    
    
    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfPool());
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
    function setFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        fee = _fee;
    }
    function setStrategyFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        strategyfee = _fee;
    }
    function setCallFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        callfee = _fee;
    }
    function setBurnFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        burnfee = _fee;
    }
    function setBurnAddress(address _burnAddress) public{
        require(msg.sender == governance, "!governance");
        burnAddress = _burnAddress;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        require(_withdrawalFee <=100,"fee >= 1%"); //max:1%
        withdrawalFee = _withdrawalFee;
    }
    function setSwap2YFII(address[] memory _path) public{
        require(msg.sender == governance, "!governance");
        swap2YFIIRouting = _path;
    }
    function setSwap2Token(address[] memory _path) public{
        require(msg.sender == governance, "!governance");
        swap2TokenRouting = _path;
    }
}