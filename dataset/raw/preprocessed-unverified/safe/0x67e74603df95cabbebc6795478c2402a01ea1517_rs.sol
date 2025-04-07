/**
 *Submitted for verification at Etherscan.io on 2021-05-27
*/

//SPDX-License-Identifier: Apache-2.0;
pragma solidity ^0.7.6;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


abstract contract ERC20Base is ERC20Interface {

    using SafeMath for uint256;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    uint256 public _totalSupply;

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        if (_balances[msg.sender] >= _value && _balances[_to].add(_value) > _balances[_to]) {
            _balances[msg.sender] = _balances[msg.sender].sub(_value);
            _balances[_to] = _balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        if (_balances[_from] >= _value && _allowances[_from][msg.sender] >= _value && _balances[_to].add(_value) > _balances[_to]) {
            _balances[_to] = _balances[_to].add(_value);
            _balances[_from] = _balances[_from].sub(_value);
            _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return _balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
      return _allowances[_owner][_spender];
    }
    
    function totalSupply() public override view returns (uint256 total) {
        return _totalSupply;
    }
}

contract WurstcoinNG is ERC20Base {
    
    using SafeMath for uint256;
    
    uint256 constant SUPPLY = 10000000;
    address immutable owner = msg.sender;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor () payable {
        require(SUPPLY > 0, "SUPPLY has to be greater than 0");
        
        _name = "Wurstcoin";
        _symbol = "WURST";
        _decimals = uint8(18);
        _totalSupply = SUPPLY.mul(10 ** uint256(decimals()));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(0x0000000000000000000000000000000000000000, msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}