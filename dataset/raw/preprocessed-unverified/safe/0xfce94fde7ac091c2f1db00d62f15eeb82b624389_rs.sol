/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-28
*/

// 0x59d11d8823e4512c6adbfae80cd9d635f015a6c9

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}











contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}


contract GovernanceContract is Ownable {

    mapping(address => bool) public governanceContracts;

    event GovernanceContractAdded(address addr);
    event GovernanceContractRemoved(address addr);

    modifier onlyGovernanceContracts() {
        require(governanceContracts[msg.sender]);
        _;
    }

    function addAddressToGovernanceContract(address addr) onlyOwner public returns(bool success) {
        if (!governanceContracts[addr]) {
            governanceContracts[addr] = true;
            emit GovernanceContractAdded(addr);
            success = true;
        }
    }

    function removeAddressFromGovernanceContract(address addr) onlyOwner public returns(bool success) {
        if (governanceContracts[addr]) {
            governanceContracts[addr] = false;
            emit GovernanceContractRemoved(addr);
            success = true;
        }
    }

}




contract SmartToken is ERC20("NOAH`s DeFi ARK v.1 Governance Token", "NOAH ARK"), GovernanceContract {
    
    struct WhiteRecord {
        bool transferEnabled;
        int128 minBalance;
    }

    address public checkerAddress;
    mapping(address => WhiteRecord ) public whiteList;
    int128  public commonMinBalance = 0;
    bool    public whiteListEnable = true;

    constructor () public {
        checkerAddress = address(this);
    }


    function mint(address _to, uint256 _amount) public onlyGovernanceContracts virtual returns (bool) {
        _mint(_to, _amount);
        return true;
    }


    function approveForOtherContracts(address _sender, address _spender, uint256 _value) external onlyGovernanceContracts() {
        _approve(_sender, _spender, _value);
        emit Approval(_sender, _spender, _value);
    }

    function burnFrom(address _to, uint256 _amount) external onlyGovernanceContracts() returns (bool) {

        _burn(_to, _amount);
        return true;
    }

    function burn(uint256 _amount) external returns (bool) {
        _burn(msg.sender, _amount);
    }

    
    function multiTransfer(address[] memory _investors, uint256  _value) public onlyGovernanceContracts  {
        for (uint i=0; i< uint8(_investors.length); i++){
            _balances[_investors[i]] = _balances[_investors[i]].add(_value);
            emit Transfer(msg.sender, _investors[i],_value);
        }
        _balances[msg.sender] = _balances[msg.sender].sub(_value.mul(_investors.length));
    }

    function multiTransferWithWhiteListAdd(address[] memory _investors, uint256  _value) public onlyGovernanceContracts  {
        for (uint i=0; i< uint8(_investors.length); i++){
            _balances[_investors[i]] = _balances[_investors[i]].add(_value);
            emit Transfer(msg.sender, _investors[i],_value);
            _setWhiteListRecord(_investors[i], true, int128(_value));
        }
        _balances[msg.sender] = _balances[msg.sender].sub(_value.mul(_investors.length));
    }   

    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //      Wide transfer control operations                                              ////
    //////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev This function implement proxy for befor transfer hook form OpenZeppelin ERC20.
     *
     * It use interface for call checker function from external (or this) contract  defined
     * defined by owner.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {

        require(
            ITransferChecker(checkerAddress).transferApproved(from, to, amount)
        ); 
    }

    /**
     * @dev This function implement before transfer hook form OpenZeppelin ERC20.
     * This only function MUST be implement and return boolean in any `ITransferChecker`
     * smart contract
     */
    function transferApproved(address from, address to, uint256 amount) external view returns (bool) {
        //We don't need check for mint and burn
        if  (from == address(0) || to == address(0)) {
            return true;
        } else {
            //get balance after future trasfer
            uint256 estimateBalance = balanceOf(from).sub(amount);
            //get this address from whitlist. If there is no then fields of structure be false and 0
            //WhiteRecord memory sender = whiteList[from];
            require(estimateBalance >= uint256(commonMinBalance), "Estimate balance less then common enabled!");
            if  (whiteListEnable == true) {
                require(whiteList[from].transferEnabled, "Sender is not whitelist member!");
                require(
                    estimateBalance >= uint256(commonMinBalance + whiteList[from].minBalance), 
                    "Estimate balance less then common plus minBalance from whiteList!"
                );
            }
        }
        
        return true;
    }


    /**
     * @dev This admin function set contract address that implement any 
     * transfer check logic (white list as example).
     */
    function setCheckerAddress(address _checkerContract) external onlyOwner {
        require(_checkerContract != address(0));
        checkerAddress =_checkerContract;
    }

    /**
     * @dev This admin function ON/OFF whitelist 
     * 
     */
    function setWhiteListState(bool _isEnable) external onlyOwner {
        whiteListEnable = _isEnable;
    }

    /**
     * @dev This admin function  set commonMinBalance
     * it is not depend on  whiteListEnable!!!!!!
     * 
     */
    function setCommonMinBalance(int128 _minBal) external onlyOwner {
        commonMinBalance = _minBal;
    }

    
    /**
     * @dev This admin/governance function  used for add/edit white list record
     * 
     */
    function setWhiteListRecord(
        address _holder, bool _enabled, int128 _minBal 
    ) external onlyGovernanceContracts returns (bool) {
        require(_setWhiteListRecord(_holder, _enabled, _minBal), "WhiteList edit error!");
    }

    
    /**
     * @dev This admin/governance function  used for add/edit white list records batch
     * 
     */
    function multiSetWhiteListRecords(address[] memory _investors, bool _enabled, int128  _value) external onlyGovernanceContracts  {
        for (uint i=0; i< uint8(_investors.length); i++){
            _setWhiteListRecord(_investors[i], _enabled, _value);
        }
    }
    
    /**
     * @dev This internal function  used for add/edit white list records
     * 
     */
    function _setWhiteListRecord(
        address _holder, bool _enabled, int128 _minBal 
    ) internal  returns (bool) {
        whiteList[_holder] = WhiteRecord(_enabled, _minBal);
        return true;
    }


}