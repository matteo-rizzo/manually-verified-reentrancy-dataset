pragma solidity ^0.4.13;






/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract Platinum is Ownable {
  using SafeMath for uint256;
  using Strings for *;

  // ========= 宣告 =========
  string public version = "0.0.1";
  // 基本單位
  string public unit = "oz";
  // 總供給量
  uint256 public total;
  // 存貨
  struct Bullion {
    string index;
    string unit;
    uint256 amount;
    string ipfs;
  }
  bytes32[] public storehouseIndex;
  mapping (bytes32 => Bullion) public storehouse;
  // 掛勾貨幣
  address public token;
  // 匯率 1白金：白金幣
  uint256 public rate = 10;
  // PlatinumToken 實例
  PlatinumToken coin;





  // ========= 初始化 =========
  function Platinum() {

  }




  // ========= event =========
  event Stock (
    string index,
    string unit,
    uint256 amount,
    string ipfs,
    uint256 total
  );

  event Ship (
    string index,
    uint256 total
  );

  event Mint (
    uint256 amount,
    uint256 total
  );

  event Alchemy (
    uint256 amount,
    uint256 total
  );

  event Buy (
    string index,
    address from,
    uint256 fee,
    uint256 price
  );






  // ========= 擁有者方法 =========

  /**
   * 操作存貨-進貨
   *
   * 此方法執行：
   *  - 紀錄新增的白金，紀錄資訊：
   *    - index: 白金編號
   *    - unit: 白金單位
   *    - amount: 數量
   *    - ipfs: 白金證明URL
   *  - 增加白金總庫存數量，量為amount
   *
   * Requires:
   *  - 執行者須為owner
   *  - 白金編號index不能重複
   *  - 單位須等於目前合約所設定的單位
   *  - 量amount需大於0
   *
   * Returns:
   *  - bool: 執行成功時，回傳true
   *
   * Events:
   *  - Stock: 執行成功時觸發
   */
  function stock(string _index, string _unit, uint256 _amount, string _ipfs) onlyOwner returns (bool) {
    bytes32 _bindex = ConvertStringByte.stringToBytes32(_index);

    require(_amount > 0);
    require(_unit.toSlice().equals(unit.toSlice()));
    require(!(storehouse[_bindex].amount > 0));

    Bullion bullion = storehouse[_bindex];
    bullion.index = _index;
    bullion.unit = _unit;
    bullion.amount = _amount;
    bullion.ipfs = _ipfs;

    // 加入倉儲目錄
    storehouseIndex.push(_bindex);
    // 加入倉儲
    storehouse[_bindex] = bullion;

    // 增加總庫存
    total = total.add(_amount);

    Stock(bullion.index, bullion.unit, bullion.amount, bullion.ipfs, total);

    return true;
  }

  /**
   * 操作存貨-出貨
   *
   * 此方法執行：
   *  - 移除白金庫存
   *  - 減少白金總庫存量，量為白金庫存的數量
   *
   * Requires:
   *  - 執行者為owner
   *  - 白金編號index需存在於紀錄（已使用stock方法新增該庫存）
   *  - 白金總庫存需足夠，大於指定白金庫存的數量
   *
   * Returns:
   *  - bool: 執行成功時，回傳true
   *
   * Events:
   *  - Ship: 執行成功時觸發
   */
  function ship(string _index) onlyOwner returns (bool) {
    bytes32 _bindex = ConvertStringByte.stringToBytes32(_index);

    require(storehouse[_bindex].amount > 0);
    Bullion bullion = storehouse[_bindex];
    require(total.sub(bullion.amount) >= 0);

    uint256 tmpAmount = bullion.amount;

    for (uint256 index = 0; index < storehouseIndex.length; index++) {
      Bullion _bullion = storehouse[storehouseIndex[index]];
      if (_bullion.index.toSlice().equals(_index.toSlice())) {
        // 從倉儲目錄移除
        delete storehouseIndex[index];
      }
    }
    // 從倉儲移除
    delete storehouse[_bindex];
    // 減少總庫存
    total = total.sub(tmpAmount);

    Ship(bullion.index, total);

    return true;
  }

  /**
   * 鑄幣
   *
   * 此方法執行：
   *  - 增加白金代幣數量
   *  - 減少總白金庫存
   *
   * Requires:
   *  - 執行者為owner
   *  - 白金總庫存需足夠，即大於等於ptAmount
   *  - 白金代幣合約需已設定（setTokenAddress方法）
   *
   * Returns:
   *  - bool: 執行成功時，回傳true
   *
   * Events:
   *  - Mint: 執行成功時觸發
   */
  function mint(uint256 _ptAmount) onlyOwner returns (bool) {
    require(token != 0x0);

    uint256 amount = convert2PlatinumToken(_ptAmount);
    // 發送token的增加涵式
    bool produced = coin.produce(amount);
    require(produced);

    total = total.sub(_ptAmount);

    Mint(_ptAmount, total);

    return true;
  }

  /**
   * 煉金
   *
   * 此方法執行：
   *  - 減少白金代幣
   *  - 增加總白金庫存
   *
   * Requires:
   *  - 執行者為owner
   *  - 需已設定白金代幣合約（setTokenAddress方法）
   *  - 白金代幣owner所擁有的代幣足夠，即tokenAmount小於等於代幣owner的白金代幣數量
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   *
   * Events:
   *  - Alchemy: 執行成功時觸發
   */
  function alchemy(uint256 _tokenAmount) onlyOwner returns (bool) {
    require(token != 0x0);

    uint256 amount = convert2Platinum(_tokenAmount);
    bool reduced = coin.reduce(_tokenAmount);
    require(reduced);

    total = total.add(amount);

    Alchemy(amount, total);

    return true;
  }

  /**
   * 設定-匯率
   *
   * 匯率規則:
   *  - 白金數量 * 匯率 = 白金代幣數量
   *  - 白金代幣數量 / 匯率 = 白金數量
   *
   * Requires:
   *  - 執行者為owner
   *  - 匯率rate需大於0
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   */
  function setRate(uint256 _rate) onlyOwner returns (bool) {
    require(_rate > 0);

    rate = _rate;
    return true;
  }

  /**
   * 設定-Token地址
   *
   * 設定白金合約地址
   *
   * Requires:
   *  - 執行者為owner
   *  - 合約地址address不為0
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   */
  function setTokenAddress(address _address) onlyOwner returns (bool) {
    require(_address != 0x0);

    coin = PlatinumToken(_address);
    token = _address;
    return true;
  }

  /**
   * 購買金條
   *
   * 此方法執行：
   *  - 扣除buyer的白金代幣
   *  - 移除白金庫存，代表buyer已從庫存買走白金
   *
   * Requires:
   *  - 執行者為owner
   *  - 白金編號index需存在於紀錄（已使用stock方法新增該庫存）
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   *
   * Events:
   *  - Buy: 執行成功時觸發
   */
  function buy(string _index, address buyer) onlyOwner returns (bool) {
    require(token != 0x0);
    bytes32 _bindex = ConvertStringByte.stringToBytes32(_index);
    uint256 fee = coin.fee();
    require(storehouse[_bindex].amount > 0);

    Bullion bullion = storehouse[_bindex];
    uint256 tokenPrice = convert2PlatinumToken(bullion.amount);
    uint256 tokenPriceFee = tokenPrice.add(fee);

    // 轉帳
    bool transfered = coin.transferFrom(buyer, coin.owner(), tokenPriceFee);
    require(transfered);

    // 直接把剛剛賣出的價格煉金
    bool reduced = coin.reduce(tokenPrice);
    require(reduced);

    // 減少庫存
    for (uint256 index = 0; index < storehouseIndex.length; index++) {
      Bullion _bullion = storehouse[storehouseIndex[index]];
      if (_bullion.index.toSlice().equals(_index.toSlice())) {
        // 從倉儲目錄移除
        delete storehouseIndex[index];
      }
    }
    // 從倉儲移除
    delete storehouse[_bindex];

    Buy(_index, buyer, fee, tokenPrice);

    return true;
  }





  // ========= 公共方法 =========

  // 比率轉換-白金幣換白金
  function convert2Platinum(uint256 _amount) constant returns (uint256) {
    return _amount.div(rate);
  }

  // 比率轉換-白金換白金幣
  function convert2PlatinumToken(uint256 _amount) constant returns (uint256) {
    return _amount.mul(rate);
  }

  // 金條資訊
  function info(string _index) constant returns (string, string, uint256, string) {
    bytes32 _bindex = ConvertStringByte.stringToBytes32(_index);
    require(storehouse[_bindex].amount > 0);

    Bullion bullion = storehouse[_bindex];

    return (bullion.index, bullion.unit, bullion.amount, bullion.ipfs);
  }
}


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
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract PlatinumToken is Ownable, ERC20 {
  using SafeMath for uint256;
  // ========= 宣告 =========

  // 版本
  string public version = "0.0.1";
  // 名稱
  string public name;
  // 標記
  string public symbol;
  // 小數點位數
  uint256 public decimals;
  // 白金合約地址
  address public platinum;

  mapping (address => mapping (address => uint256)) allowed;
  mapping(address => uint256) balances;
  // 總供給量
  uint256 public totalSupply;
  // 手續費
  uint256 public fee = 10;

  // ========= 初始化 =========
  function PlatinumToken(
    uint256 initialSupply,
    string tokenName,
    uint8 decimalUnits,
    string tokenSymbol
    ) {
    balances[msg.sender] = initialSupply;
    totalSupply = initialSupply;
    name = tokenName;
    symbol = tokenSymbol;
    decimals = decimalUnits;
  }

  // ========= 權限控管 =========
  modifier isPlatinumContract() {
    require(platinum != 0x0);
    require(msg.sender == platinum);
    _;
  }

  modifier isOwnerOrPlatinumContract() {
    require(msg.sender != address(0) && (msg.sender == platinum || msg.sender == owner));
    _;
  }

  /**
   * 增產
   *
   *  此方法執行：
   *    - 增加owner的balance，量為指定的amount
   *    - 增加totalSupply，量為指定的amount
   *
   *  Requires:
   *    - 執行者為白金合約（可透過setPlatinumAddress方法設定）
   *    - amount須設定為0以上
   *
   *  Return:
   *    - bool: 執行成功回傳true
   */
  function produce(uint256 amount) isPlatinumContract returns (bool) {
    balances[owner] = balances[owner].add(amount);
    totalSupply = totalSupply.add(amount);

    return true;
  }

  /** 減產
   *
   *  此方法執行：
   *    - 減少owner的balance，量為指定的amount
   *    - 減少totalSupply，量為指定的amount
   *
   *  Requires:
   *    - 執行者為白金合約（可透過setPlatinumAddress方法設定）
   *    - amount須設定為0以上
   *    - owner的balance需大於等於指定的amount
   *    - totalSupply需大於等於指定的amount
   *
   *  Return:
   *    - bool: 執行成功回傳true
   */
  function reduce(uint256 amount) isPlatinumContract returns (bool) {
    require(balances[owner].sub(amount) >= 0);
    require(totalSupply.sub(amount) >= 0);

    balances[owner] = balances[owner].sub(amount);
    totalSupply = totalSupply.sub(amount);

    return true;
  }

  /**
   * 設定-白金合約地址
   *
   * 此方法執行：
   *  - 修改此合約所認識的白金合約地址，此地址決定能執行produce和reduce方法的合約
   *
   * Requires:
   *  - 執行者須為owner
   *  - 地址不能設為0
   *
   * Returns:
   *  - bool: 設定成功時回傳true
   */
  function setPlatinumAddress(address _address) onlyOwner returns (bool) {
    require(_address != 0x0);

    platinum = _address;
    return true;
  }

  /**
   * 設定-手續費
   *
   * 手續費規則：
   *  - 購買金條時，代幣量總量增加手續費為總扣除代幣總量
   *
   * Requires:
   *  - 執行者為owner
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   */
  function setFee(uint256 _fee) onlyOwner returns (bool) {
    require(_fee >= 0);

    fee = _fee;
    return true;
  }

  /**
   * 交易，轉移白金代幣
   *
   * 此方法執行：
   *  - 減少from的白金代幣，量為value
   *  - 增加to的白金代幣，量為value
   *
   * Requires:
   *  - 執行者為owner
   *
   * Returns:
   *  - bool: 執行成功回傳true
   *
   * Events:
   *  - Transfer: 執行成功時，觸發此事件
   */
  function transfer(address _to, uint256 _value) onlyOwner returns (bool) {
    balances[owner] = balances[owner].sub(_value);
    balances[_to] = balances[_to].add(_value);

    Transfer(owner, _to, _value);

    return true;
  }

  /**
   * 查詢白金代幣餘額
   *
   * Returns:
   *  - balance: 指定address的白金代幣餘額
   */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  /**
   * 轉帳
   *
   * 實際將approve過的token數量進行交易
   *
   * 此方法執行：
   *  - 交易指定數量的代幣
   *
   * Requires:
   *  - 交易的代幣數量value需大於0
   *  - allowed的代幣數量需大於value（allowed的代幣先由呼叫approve方法設定）
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   */
  function transferFrom(address _from, address _to, uint256 _value) isOwnerOrPlatinumContract returns (bool) {
    var _allowance = allowed[_from][owner];

    uint256 valueSubFee = _value.sub(fee);

    balances[_to] = balances[_to].add(valueSubFee);
    balances[_from] = balances[_from].sub(_value);
    balances[owner] = balances[owner].add(fee);
    allowed[_from][owner] = _allowance.sub(_value);

    Transfer(_from, _to, _value);

    return true;
  }

  /**
   * 轉帳 - 允許
   *
   * 允許一定數量的代幣可以轉帳至owner
   *
   * 欲修改允許值，需先執行此方法將value設為0，再執行一次此方法將value設為指定值
   *
   * 此方法操作：
   *  - 修改allowed值，紀錄sender允許轉帳value數量代幣給owner
   *  - allowed值有設定時，value須為0
   *  - allowed值未設定時，value不為0
   *
   * Returns:
   *  - bool: 執行成功，回傳true
   */
  function approve(address _dummy, uint256 _value) returns (bool) {
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][owner] == 0));

    allowed[msg.sender][owner] = _value;
    Approval(msg.sender, owner, _value);
    return true;
  }

  /**
   * 轉帳 - 查詢允許值
   *
   * Returns:
   *  - unit256: 允許值
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * 刪除合約
   *
   * 此方法呼叫合約內建的selfdestruct方法
   */
  function suicide() onlyOwner returns (bool) {
    selfdestruct(owner);
    return true;
  }
}