/**
 *Submitted for verification at Etherscan.io on 2021-05-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;


// 


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


// 
contract LowOrbitERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address private _owner;
    address private _stakingContract;
    bool _feesActivated = false;
    bool _burnPaused = false;

    mapping(address => bool) _excludedFeesAddress;

    constructor () {
        _owner = msg.sender;
        _name = "Low Orbit Crypto Cannon";
        _symbol = "LOCC";

        // Give all tokens to the owner
        _totalSupply = 1000 * (10 ** 18);
        _balances[msg.sender] += _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "LOCC: RESTRICTED_OWNER");
        _;
    }

    function setStakingContract(address newAddr) public onlyOwner returns (bool) {
        _stakingContract = newAddr;
        return true;
    }

    function setFeesActivated(bool value) public onlyOwner returns (bool) {
        _feesActivated = value;
        return true;
    }

    function setBurnPaused(bool value) public onlyOwner returns (bool) {
        _burnPaused = value;
        return true;
    }

    function setExcludedFeesAddr(address addr, bool value) public onlyOwner returns (bool) {
        _excludedFeesAddress[addr] = value;
        return true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: amount 0 not allowed");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        if(_feesActivated && !_excludedFeesAddress[sender]) {
            uint256 burnAmount = amount.div(100).mul(5);
            uint256 stakingAmount = amount.div(100).mul(5);
            uint256 amountSubFees = amount.sub(burnAmount).sub(stakingAmount);

            // Transfert to the recipient
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] += amountSubFees;
            emit Transfer(sender, recipient, amountSubFees);

            // Burn fees
            if(!_burnPaused) {
                _burn(sender, burnAmount);
            }
            else {
                if(_stakingContract != address(0)) {
                    _balances[_stakingContract] += burnAmount;
                }
            }

            // Transfert to the staking contract and call the pulsator
            _balances[_stakingContract] += stakingAmount;
            if(_stakingContract != address(0)) {
                if(_burnPaused) {
                    ILowOrbitPropulsor(_stakingContract).pulse(stakingAmount.add(burnAmount));
                    emit Transfer(sender, _stakingContract, stakingAmount.add(burnAmount));
                }
                else {
                    ILowOrbitPropulsor(_stakingContract).pulse(stakingAmount);
                    emit Transfer(sender, _stakingContract, stakingAmount);
                }
            }
            else {
                _burn(sender, burnAmount);
            }
        }
        else {
            // Transfert to the recipient
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}