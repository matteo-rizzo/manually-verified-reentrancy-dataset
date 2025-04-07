/**
 *Submitted for verification at Etherscan.io on 2020-10-25
*/

pragma solidity 0.5.16;

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}







contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply; 

    constructor() public {
        _balances[msg.sender] = _totalSupply;
    }
 
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}




contract PositiveToken is ERC20,Ownable  {
  /* ERC20 constants */
  string internal _name; 
  string internal _symbol;
  uint8 internal _decimals;

  bytes16 internal _price;
  uint256 private _bank = 0; 
  uint256 private _tokens;

  bytes16 internal PRICE_DECIMALS; 

  uint256 internal _C; 
  uint256 internal _Cr; 
  uint256 internal _Ca; 
  uint256 internal _Cg;
  bool private Initialize = false; 

  mapping (address=>address) private registred;
  mapping (address=>address) private reff;
  uint256 private _userInContract;

  event Price(uint256 totalSupply,uint256 value);
  event Diff(uint256 diff);

  function name() external view returns(string memory){
    return _name;
  }
  function symbol() external view returns(string memory){
    return _symbol;
  }
  function decimals() external view returns(uint8){
    return _decimals;
  }

  function bank() external view returns(uint256){
    return _bank;
  }

  function price() external view returns(uint256) {
    bytes16 uint_price = ABDKMathQuad.mul(_price,PRICE_DECIMALS); // float price * 10**18
    return(ABDKMathQuad.toUInt(uint_price)); // return uint price 
  }

  function getCommission() external view returns (uint256, uint256, uint256, uint256){
    return(_C,_Cr,_Ca,_Cg);
  }

  function getCommissionTotal() external view returns(uint256){
    return _C;
  }

  function getCommissionRef() external view returns(uint256){
    return _Cr;
  }

  function getCommissionAdmin() external view returns(uint256){
    return _Ca;
  }

  function getCommissionCost() external view returns(uint256){
    return _Cg;
  }

  function setCommission(uint256 _newC, uint256 _newCr, uint256 _newCa) external onlyOwner {
    require(_newC > 0, "Trigon: newC is 0");
    require(_newC < 100, "Trigon: newC > 100");
    require(_newC.sub(_newCr.add(_newCa)) >= 2, "Trigon: newC - (newCr + newCa) <= 2"); // x/2 > 0
    require(_newC.sub(_newCr.add(_newCa)) % 2 == 0, "Trigon: newC - (newCr + newCa) not shared"); // x%2 = 0 
    _C = _newC;
    _Cr = _newCr;
    _Ca = _newCa;
    _Cg = _newC.sub(_newCr.add(_newCa));
    _Cg = _Cg.div(2);
  }

  function isRegisterd(address addr) external view returns(bool) {
    if(registred[addr] == address(0)) {
      return false;
    }
    return true;
  }    

  function isInitialize() external view returns(bool){
    return Initialize;
  }

  function getRef(address addr) external view returns(address) {
    return reff[addr];
  }

  function getUserInContract() external view returns(uint256) {
    return _userInContract;
  }

  function init() external payable onlyOwner returns(bool) {
    require(Initialize == false, "Trigon: Initialize is true");
    require(msg.value > 10**15, "Trigon: eth value < 10^15 Wei"); // init price 0.001 Eth = 10**15 Wei
    bytes16 _adm_add_tmp = ABDKMathQuad.div( ABDKMathQuad.fromUInt(msg.value), _price);
    uint256 _adm_add = ABDKMathQuad.toUInt(_adm_add_tmp);
    _mint(msg.sender, _adm_add);
    _tokens = _tokens.add(_adm_add);

    _bank = _bank.add(msg.value);

    _price = ABDKMathQuad.div( ABDKMathQuad.fromUInt(_bank),ABDKMathQuad.fromUInt(_tokens));
    bytes16 uint_price = ABDKMathQuad.mul(_price,PRICE_DECIMALS); // float price * 10**18

    emit Price(_tokens,ABDKMathQuad.toUInt(uint_price));

    Initialize = true;
    registred[address(0)] = admin;
    registred[msg.sender] = admin;
    reff[msg.sender] = admin;
    return Initialize;
  }

  function buytoken(address _refferer) external payable {
    require(Initialize == true, "Trigon: Initialize is false");
    require(_refferer != msg.sender, "Trigon: self-refferer");
    require(msg.value > 10**15, "Trigon: eth value < 10^15 Wei"); // init price 0.001
        
    _refferer = registred[_refferer];
      // by default 0
    if(_refferer == address(0)) {
      _refferer = admin;
    }

    uint256 _100_precent = 100;
    uint256 _part_virtual = _100_precent.sub(_Cg);
    uint256 _part_us = _100_precent.add(_Ca).add(_Cr);

    bytes16 _pre_virtual_tokens = ABDKMathQuad.div( ABDKMathQuad.fromUInt(msg.value), _price);
    uint256 _pre_virtual_tokens_int = ABDKMathQuad.toUInt(_pre_virtual_tokens);
    uint256 _virtual_tokens_int = _pre_virtual_tokens_int.mul(_part_virtual).div(100);
    uint256 _us_add = _virtual_tokens_int.mul(100).mul(100).div(_part_us).div(100);

    uint256 _ref_add = _us_add.mul(_Cr).div(100); // % us_tokens
    uint256 _adm_add = _us_add.mul(_Ca).div(100); // % us_tokens

    require(_pre_virtual_tokens_int >=  _us_add + _ref_add + _adm_add, "N < Na + Nr + Nu");
    uint256 diff_div = _pre_virtual_tokens_int - (_us_add + _ref_add + _adm_add);
    emit Diff(diff_div);

    _mint(msg.sender,_us_add);
    _tokens = _tokens.add(_us_add);

    _mint(_refferer,_ref_add);
    _tokens = _tokens.add(_ref_add);

    _mint(admin,_adm_add);
    _tokens = _tokens.add(_adm_add);

    _bank = _bank.add(msg.value);

    _price = ABDKMathQuad.div( ABDKMathQuad.fromUInt(_bank),ABDKMathQuad.fromUInt(_tokens));
    bytes16 uint_price = ABDKMathQuad.mul(_price,PRICE_DECIMALS); 

    emit Price(_tokens,ABDKMathQuad.toUInt(uint_price));

    if(registred[msg.sender] == address(0)) {
      registred[msg.sender] = msg.sender;
      _userInContract = _userInContract.add(1);
    }
    reff[msg.sender] = _refferer;
  }

  function sell(uint256 selltokens) external payable {
    require(Initialize == true, "Trigon: Initialize is false");
    require(selltokens > 0, "Trigon: sell tokens is zero");
    _burn(msg.sender, selltokens);

    uint256 _100_precent = 100;
    uint256 _part_us = _100_precent.sub(_Cg);
    bytes16 _part_mul_us = ABDKMathQuad.div( ABDKMathQuad.fromUInt(_part_us),ABDKMathQuad.fromUInt(100) ); 
    bytes16 _us_sub_tmp = ABDKMathQuad.mul(_part_mul_us,ABDKMathQuad.fromUInt(selltokens));
    bytes16 _us_sub = ABDKMathQuad.mul(_us_sub_tmp,_price);
    uint256 _withdraw =  ABDKMathQuad.toUInt(_us_sub);
    
    _bank = _bank.sub(_withdraw);
    _tokens = _tokens.sub(selltokens);

    _price = ABDKMathQuad.div( ABDKMathQuad.fromUInt(_bank),ABDKMathQuad.fromUInt(_tokens));
    bytes16 uint_price = ABDKMathQuad.mul(_price,PRICE_DECIMALS); // float price * 10**18  

    emit Price(_tokens,ABDKMathQuad.toUInt(uint_price));

    msg.sender.transfer(_withdraw);
  }

}

contract Trigon is PositiveToken {
  constructor()
    public {
      _name = "Trigon Token";
      _symbol = "TRGN";
      _decimals = 18;
      _price = ABDKMathQuad.div ( ABDKMathQuad.fromUInt(1), ABDKMathQuad.fromUInt(1000) ); // 0.001
      _C  = 20; 
      _Cr = 5; 
      _Ca = 5; 
      _Cg = _C.sub(_Cr.add(_Ca));
      _Cg = _Cg.div(2);
      uint256 t = 10**18;
      PRICE_DECIMALS = ABDKMathQuad.fromUInt(t);
  }

  function() external payable {}
}