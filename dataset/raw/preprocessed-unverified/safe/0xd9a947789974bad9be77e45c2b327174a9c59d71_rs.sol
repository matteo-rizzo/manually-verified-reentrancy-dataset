// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

// File: SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: FrozenChecker.sol

/**
 * @title FrozenChecker
 * @dev Check account by frozen rules
 */


// File: FrozenValidator.sol



// File: YottaCoin.sol

contract YottaCoin {

    using SafeMath for uint256;
    using FrozenValidator for FrozenValidator.Validator;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    //--------------------------------  Basic Info  -------------------------------------//

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    //--------------------------------  Basic Info  -------------------------------------//


    //--------------------------------  Admin Info  -------------------------------------//

    address payable public admin;  //Admin address

    /**
     * @dev Change admin address
     * @param newAdmin New admin address
     */
    function changeAdmin(address payable newAdmin) public returns (bool)  {
        require(msg.sender == admin);
        require(newAdmin != address(0));
        uint256 balAdmin = balances[admin];
        balances[newAdmin] = balances[newAdmin].add(balAdmin);
        balances[admin] = 0;
        admin = newAdmin;
        emit Transfer(admin, newAdmin, balAdmin);
        return true;
    }

    //--------------------------------  Admin Info  -------------------------------------//


    //--------------------------  Events & Constructor  ------------------------------//
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed target, uint256 value);
    event Burn(address indexed target, uint256 value);

    // constructor
    constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = 0;
        admin = msg.sender;
        // balances[msg.sender] = 0;
        // emit Transfer(address(0x0), msg.sender, totalTokenSupply);
    }

    //--------------------------  Events & Constructor  ------------------------------//
    
    
    //-------------------------------  Mint & Burn  ----------------------------------//
    
    function mint(address target, uint256 value) public returns (bool) {
        require(msg.sender == admin);
        require(!frozenAccount[target]);
        require(block.timestamp > frozenTimestamp[target]);
        balances[target] = balances[target].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(target, value);
        emit Transfer(address(0), target, value);
        return true;
    }
    
    function burn(address target, uint256 value) public returns (bool) {
        require(msg.sender == admin);
        require(!frozenAccount[target]);
        require(block.timestamp > frozenTimestamp[target]);
        require(totalSupply>=value);
        require(balances[target].sub(value)>=validator.validate(target));
        balances[target] = balances[target].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(target, value);
        emit Transfer(target, address(0), value);
        return true;
    }

    //-------------------------------  Mint & Burn  ----------------------------------//
    

    //------------------------------ Account lock  -----------------------------------//

    // 同一个账户满足任意冻结条件均被冻结
    mapping (address => bool) frozenAccount; //无限期冻结的账户
    mapping (address => uint256) frozenTimestamp; // 有限期冻结的账户

    /**
     * 查询账户是否存在锁定时间戳
     */
    function getFrozenTimestamp(address _target) public view returns (uint256) {
        return frozenTimestamp[_target];
    }

    /**
     * 查询账户是否被锁定
     */
    function getFrozenAccount(address _target) public view returns (bool) {
        return frozenAccount[_target];
    }

    /**
     * 锁定账户
     */
    function freeze(address _target, bool _freeze) public returns (bool) {
        require(msg.sender == admin);
        require(_target != admin);
        frozenAccount[_target] = _freeze;
        return true;
    }

    /**
     * 通过时间戳锁定账户
     */
    function freezeWithTimestamp(address _target, uint256 _timestamp) public returns (bool) {
        require(msg.sender == admin);
        require(_target != admin);
        frozenTimestamp[_target] = _timestamp;
        return true;
    }

    /**
     * 批量锁定账户
     */
    function multiFreeze(address[] memory _targets, bool[] memory _freezes) public returns (bool) {
        require(msg.sender == admin);
        require(_targets.length == _freezes.length);
        uint256 len = _targets.length;
        require(len > 0);
        for (uint256 i = 0; i < len; i = i.add(1)) {
            address _target = _targets[i];
            require(_target != admin);
            bool _freeze = _freezes[i];
            frozenAccount[_target] = _freeze;
        }
        return true;
    }

    /**
     * 批量通过时间戳锁定账户
     */
    function multiFreezeWithTimestamp(address[] memory _targets, uint256[] memory _timestamps) public returns (bool) {
        require(msg.sender == admin);
        require(_targets.length == _timestamps.length);
        uint256 len = _targets.length;
        require(len > 0);
        for (uint256 i = 0; i < len; i = i.add(1)) {
            address _target = _targets[i];
            require(_target != admin);
            uint256 _timestamp = _timestamps[i];
            frozenTimestamp[_target] = _timestamp;
        }
        return true;
    }

    //------------------------------  Account lock  -----------------------------------//




    //--------------------------      Frozen rules      ------------------------------//

    FrozenValidator.Validator validator;

    function addRule(address addr, uint8 initPercent, uint256[] memory periods, uint8[] memory percents) public returns (bool) {
        require(msg.sender == admin);
        return validator.addRule(addr, initPercent, periods, percents);
    }

    function addTimeT(address addr, uint256 timeT) public returns (bool) {
        require(msg.sender == admin);
        return validator.addTimeT(addr, timeT);
    }

    function removeRule(address addr) public returns (bool) {
        require(msg.sender == admin);
        return validator.removeRule(addr);
    }

    //--------------------------      Frozen rules      ------------------------------//




    //-------------------------  Standard ERC20 Interfaces  --------------------------//

    function multiTransfer(address[] memory _tos, uint256[] memory _values) public returns (bool) {
        require(!frozenAccount[msg.sender]);
        require(block.timestamp > frozenTimestamp[msg.sender]);
        require(_tos.length == _values.length);
        uint256 len = _tos.length;
        require(len > 0);
        uint256 amount = 0;
        for (uint256 i = 0; i < len; i = i.add(1)) {
            amount = amount.add(_values[i]);
        }
        require(amount <= balances[msg.sender].sub(validator.validate(msg.sender)));
        for (uint256 j = 0; j < len; j = j.add(1)) {
            address _to = _tos[j];
            if (validator.containRule(msg.sender) && msg.sender != _to) {
                validator.addFrozenBalance(msg.sender, _to, _values[j]);
            }
            balances[_to] = balances[_to].add(_values[j]);
            balances[msg.sender] = balances[msg.sender].sub(_values[j]);
            emit Transfer(msg.sender, _to, _values[j]);
        }
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        transferfix(_to, _value);
        return true;
    }

    function transferfix(address _to, uint256 _value) public {
        require(!frozenAccount[msg.sender]);
        require(block.timestamp > frozenTimestamp[msg.sender]);
        require(balances[msg.sender].sub(_value) >= validator.validate(msg.sender));

        if (validator.containRule(msg.sender) && msg.sender != _to) {
            validator.addFrozenBalance(msg.sender, _to, _value);
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[_from]);
        require(block.timestamp > frozenTimestamp[_from]);
        require(_value <= balances[_from].sub(validator.validate(_from)));
        require(_value <= allowed[_from][msg.sender]);

        if (validator.containRule(_from) && _from != _to) {
            validator.addFrozenBalance(_from, _to, _value);
        }

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner]; //.sub(validator.validate(_owner));
    }

    //-------------------------  Standard ERC20 Interfaces  --------------------------//
    
    function lockedBalanceOf(address _target) public view returns (uint256) {
        return validator.validate(_target);
    }

    function kill() public {
        require(msg.sender == admin);
        selfdestruct(admin);
    }

}