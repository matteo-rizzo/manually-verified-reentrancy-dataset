pragma solidity ^ 0.5.16;



contract Context {
    constructor() internal {}
        // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns(address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;
    mapping(address => uint) private _balances;

    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxAmount = 21 * 10 ** 24;
    modifier canMint(uint amount) {
        require(amount + _totalSupply <= maxAmount);
        _;
    }

    function totalSupply() public view returns(uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns(uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns(uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) canMint(amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }
}







contract RaisableErc20 is ERC20, ERC20Detailed {
    uint public raisedethAmount;
    uint8 public maxStage = 129;
    uint8 public firstStageETHAmount = 80;
    uint8 public firstRoundMaxStage = 28;
    bool public raisePaused=false;
    uint public nowStage=1;
    function updateStage(uint raisedThisTime) internal returns(bool) {
        uint newRaisedethAmount=raisedethAmount+raisedThisTime;
        if (newRaisedethAmount >= getSumEthAmount(nowStage)) {
            nowStage+=1;
            raisedethAmount=newRaisedethAmount;
            updateStage(0);
        }
        else{
            raisedethAmount=newRaisedethAmount;
        }
        return true;
    }
    
    function getSumEthAmount(uint stage) internal view returns(uint){
        uint tempDecimal=uint(decimals());
        uint firstRoundTotalRaised=10360*10**tempDecimal;
        if (stage<=firstRoundMaxStage){
            return (10*stage**2+90*stage)*10**tempDecimal;
        }
        else if(stage>firstRoundMaxStage && stage<maxStage){
            uint secondRoundStage=stage-firstRoundMaxStage;
            return firstRoundTotalRaised+((259*secondRoundStage - secondRoundStage**2)*10**tempDecimal).div(2);
        }
        else{
            return firstRoundTotalRaised+7979*10**uint(decimals());
        }
    }
    function getCanBuyAmount(uint ethAmount) public view returns(uint) {
        require(ethAmount >= 100, 'division overflow');
        if (nowStage <= firstRoundMaxStage)
             return ethAmount*(42 * nowStage ** 2 + 43128 - 2352 * nowStage)/100;
        else if (nowStage > firstRoundMaxStage && nowStage < maxStage)
             return ethAmount*(maxStage + 1 - nowStage);
        else
            revert();
    }

    function addLiquidity() public payable {
        require(msg.value >= 100, 'division overflow');
        require(!raisePaused,'raise paused');
        if (nowStage < maxStage) {
            _mint(msg.sender, getCanBuyAmount(msg.value));
            updateStage(msg.value);
        } else {
            revert();
        }
    }
}
contract EMTC is RaisableErc20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;
    bool public canMintAirDrop = true;
    mapping(address => bool) public minters;
    address public governance;
    constructor() public ERC20Detailed("EMTC", "EMTC", 18) {
        governance = msg.sender;
    }
    modifier isGovernance(address _minter) {
        require(_minter==governance, "!governance");
        _;
    }
    function mint(address account, uint amount) public {
        require(minters[msg.sender], "!minter");
        _mint(account, amount);
    }

    function mintAirdrop(uint amount) public isGovernance(msg.sender) {
        require(canMintAirDrop, "can mint only once time for airdrop");
        _mint(address(this), amount);
        canMintAirDrop = false;
    }

    function addMinter(address _minter) public isGovernance(msg.sender) {
        minters[_minter] = true;
    }

    function removeMinter(address _minter) public isGovernance(msg.sender) {
        minters[_minter] = false;
    }

    function multipleAirdrop(address[] memory _receivers, uint256[] memory _values) public isGovernance(msg.sender) returns(bool res){
        uint cnt = _receivers.length;
        uint256 totalAmount = sumAsm(_values);
        require(cnt > 0 && cnt <= 50);
        require(balanceOf(address(this)) >= totalAmount);
        for (uint i = 0; i < cnt; i++) {
            _transfer(address(this),_receivers[i],_values[i]);
        }
        return true;
    }
    
    function setGovernance(address _governance) public isGovernance(msg.sender) {
        governance = _governance;
    }
    
    function getRaised(uint amount) public isGovernance(msg.sender) {
        if (!msg.sender.send(amount)) {
            revert();
        }
    }
    
    function stopRaise() public isGovernance(msg.sender) {
        raisePaused=true;
    }
    
    function sumAsm(uint[] memory _data) pure public returns (uint o_sum) {
        for (uint i = 0; i < _data.length; ++i) {
            assembly {
                o_sum := mload(add(add(_data, 0x20), mul(i, 0x20)))
            }
        }
    }
}