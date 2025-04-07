/**
 *Submitted for verification at Etherscan.io on 2021-03-05
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.15;















contract Controller {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public governance;
	address public timelock;
    address public rewards;
    mapping(address => address) public vaults;
    mapping(address => address) public strategies;
    mapping(address => mapping(address => address)) public converters;

    constructor() public {
        governance = tx.origin;
		timelock = tx.origin;
        rewards = tx.origin; 
    }
	
	function setRewardsAddress(address _rewards) public {
        require(msg.sender == timelock, "!timelock");
        rewards = _rewards;
    }
	
	function setTimeLock(address _timelock) public 
    {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setVault(address _token, address _vault) public {
        require(msg.sender == governance, "!governance");
        vaults[_token] = _vault;
    }
    
    function setConverter(address _input, address _output, address _converter) public {
        require(msg.sender == governance, "!governance");
        converters[_input][_output] = _converter;
    }
    
    function setStrategy(address _token, address _strategy) public {
        require(msg.sender == timelock, "!timelock");
        address _current = strategies[_token];
        if (_current != address(0)) {
           Strategy(_current).withdrawAll();
        }
        strategies[_token] = _strategy;
    }
	
	function delStrategy(address _token) public {
        require(msg.sender == governance, "!governance");
        strategies[_token] = address(0);
    }
    
    //
    function earn(address _token, uint _amount) public {
        address _strategy = strategies[_token];
        address _want = Strategy(_strategy).want();
        if (_want != _token) {
            address converter = converters[_token][_want];
            IERC20(_token).safeTransfer(converter, _amount);
            _amount = Converter(converter).convert(_strategy);
            IERC20(_want).safeTransfer(_strategy, _amount);
        } else {
            IERC20(_token).safeTransfer(_strategy, _amount);
        }
        Strategy(_strategy).deposit();
    }
    
    function balanceOf(address _token) external view returns (uint) {
        return Strategy(strategies[_token]).balanceOf();
    }
    
    function withdrawAll(address _token) public {
        require(msg.sender == governance, "!governance");
        Strategy(strategies[_token]).withdrawAll();
    }


    function withdraw(address _token, uint _amount) public {
        require(msg.sender == vaults[_token], "!vault");
        Strategy(strategies[_token]).withdraw(_amount);
    }
}