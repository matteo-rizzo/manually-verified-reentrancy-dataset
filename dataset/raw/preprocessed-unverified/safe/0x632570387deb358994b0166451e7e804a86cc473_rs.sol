// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;













contract StrategyProxy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    Proxy constant public proxy = Proxy(0xF147b8125d2ef93FB6965Db97D6746952a133934);
    address constant public mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address constant public crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address constant public gauge = address(0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB);
    address constant public y = address(0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1);
    
    mapping(address => bool) public strategies;
    address public governance;
    
    constructor() public {
        governance = msg.sender;
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function approveStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        strategies[_strategy] = true;
    }
    
    function revokeStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        strategies[_strategy] = false;
    }
    
    function lock() external {
        proxy.increaseAmount(IERC20(crv).balanceOf(address(proxy)));
    }
    
    function vote(address _gauge, uint _amount) public {
        require(strategies[msg.sender], "!strategy");
        proxy.execute(gauge, 0, abi.encodeWithSignature("vote_for_gauge_weights(address,uint256)",_gauge,_amount));
    }
    
    function max() external {
        require(strategies[msg.sender], "!strategy");
        vote(y,10000);
    }
    
    function withdraw(address _gauge, address _token, uint _amount) public returns (uint) {
        require(strategies[msg.sender], "!strategy");
        uint _before = IERC20(_token).balanceOf(address(proxy));
        proxy.execute(_gauge, 0, abi.encodeWithSignature("withdraw(uint256)",_amount));
        uint _after = IERC20(_token).balanceOf(address(proxy));
        uint _net = _after.sub(_before);
        proxy.execute(_token, 0, abi.encodeWithSignature("transfer(address,uint256)",msg.sender,_net));
        return _net;
    }
    
    function balanceOf(address _gauge) public view returns (uint) {
        return IERC20(_gauge).balanceOf(address(proxy));
    }
    
    function withdrawAll(address _gauge, address _token) external returns (uint) {
        require(strategies[msg.sender], "!strategy");
        return withdraw(_gauge, _token, balanceOf(_gauge));
    }
    
    function deposit(address _gauge, address _token) external {
        uint _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(address(proxy), _balance);
        
        _balance = IERC20(_token).balanceOf(address(proxy));
        proxy.execute(_token, 0, abi.encodeWithSignature("approve(address,uint256)",_gauge,0));
        proxy.execute(_token, 0, abi.encodeWithSignature("approve(address,uint256)",_gauge,_balance));
        proxy.execute(_gauge, 0, abi.encodeWithSignature("deposit(uint256)",_balance));
    }
    
    function harvest(address _gauge) external {
        require(strategies[msg.sender], "!strategy");
        uint _before = IERC20(crv).balanceOf(address(proxy));
        Mintr(mintr).mint_for(_gauge, address(proxy));
        uint _after = IERC20(crv).balanceOf(address(proxy));
        uint _balance = _after.sub(_before);
        proxy.execute(crv, 0, abi.encodeWithSignature("transfer(address,uint256)",msg.sender,_balance));
    }
}