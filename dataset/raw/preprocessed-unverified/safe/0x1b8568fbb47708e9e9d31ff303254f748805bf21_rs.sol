/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

abstract contract FlashLoanArbiter {
    function canBorrow (address borrower) public virtual returns (bool);
}

abstract contract FlashLoanReceiver {
    function execute (address caller) public virtual;
}

abstract contract LachesisLike {
    function cut(address token) public virtual view returns (bool, bool);

    function measure(
        address token,
        bool valid,
        bool burnable
    ) public virtual;
}


abstract contract Burnable {
    function burn (uint amount) public virtual;
    function symbol() public virtual pure returns (string memory);
    function burn (address holder, uint amount) public virtual;
}




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */













/// @dev Wrapped Ether v10 (WETH10) is an Ether (ETH) ERC-20 wrapper. You can `deposit` ETH and obtain an WETH10 balance which can then be operated as an ERC-20 token. You can
/// `withdraw` ETH from WETH10, which will then burn WETH10 token in your wallet. The amount of WETH10 token in any wallet is always identical to the
/// balance of ETH deposited minus the ETH withdrawn with that specific wallet.
interface IWETH10 is IERC20, IERC2612, IERC3156FlashLender {

    /// @dev Returns current amount of flash-minted WETH10 token.
    function flashMinted() external view returns(uint256);

    /// @dev `msg.value` of ETH sent to this contract grants caller account a matching increase in WETH10 token balance.
    /// Emits {Transfer} event to reflect WETH10 token mint of `msg.value` from zero address to caller account.
    function deposit() external payable;

    /// @dev `msg.value` of ETH sent to this contract grants `to` account a matching increase in WETH10 token balance.
    /// Emits {Transfer} event to reflect WETH10 token mint of `msg.value` from zero address to `to` account.
    function depositTo(address to) external payable;

    /// @dev Burn `value` WETH10 token from caller account and withdraw matching ETH to the same.
    /// Emits {Transfer} event to reflect WETH10 token burn of `value` to zero address from caller account. 
    /// Requirements:
    ///   - caller account must have at least `value` balance of WETH10 token.
    function withdraw(uint256 value) external;

    /// @dev Burn `value` WETH10 token from caller account and withdraw matching ETH to account (`to`).
    /// Emits {Transfer} event to reflect WETH10 token burn of `value` to zero address from caller account.
    /// Requirements:
    ///   - caller account must have at least `value` balance of WETH10 token.
    function withdrawTo(address payable to, uint256 value) external;

    /// @dev Burn `value` WETH10 token from account (`from`) and withdraw matching ETH to account (`to`).
    /// Emits {Approval} event to reflect reduced allowance `value` for caller account to spend from account (`from`),
    /// unless allowance is set to `type(uint256).max`
    /// Emits {Transfer} event to reflect WETH10 token burn of `value` to zero address from account (`from`).
    /// Requirements:
    ///   - `from` account must have at least `value` balance of WETH10 token.
    ///   - `from` account must have approved caller to spend at least `value` of WETH10 token, unless `from` and caller are the same account.
    function withdrawFrom(address from, address payable to, uint256 value) external;

    /// @dev `msg.value` of ETH sent to this contract grants `to` account a matching increase in WETH10 token balance,
    /// after which a call is executed to an ERC677-compliant contract with the `data` parameter.
    /// Emits {Transfer} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// For more information on *transferAndCall* format, see https://github.com/ethereum/EIPs/issues/677.
    function depositToAndCall(address to, bytes calldata data) external payable returns (bool);

    /// @dev Sets `value` as allowance of `spender` account over caller account's WETH10 token,
    /// after which a call is executed to an ERC677-compliant contract with the `data` parameter.
    /// Emits {Approval} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// For more information on approveAndCall format, see https://github.com/ethereum/EIPs/issues/677.
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);

    /// @dev Moves `value` WETH10 token from caller's account to account (`to`), 
    /// after which a call is executed to an ERC677-compliant contract with the `data` parameter.
    /// A transfer to `address(0)` triggers an ETH withdraw matching the sent WETH10 token in favor of caller.
    /// Emits {Transfer} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// Requirements:
    ///   - caller account must have at least `value` WETH10 token.
    /// For more information on transferAndCall format, see https://github.com/ethereum/EIPs/issues/677.
    function transferAndCall(address to, uint value, bytes calldata data) external returns (bool);
}





/// @dev Wrapped Ether v10 (WETH10) is an Ether (ETH) ERC-20 wrapper. You can `deposit` ETH and obtain an WETH10 balance which can then be operated as an ERC-20 token. You can
/// `withdraw` ETH from WETH10, which will then burn WETH10 token in your wallet. The amount of WETH10 token in any wallet is always identical to the
/// balance of ETH deposited minus the ETH withdrawn with that specific wallet.
contract WETH10 is IWETH10 {

    string public constant name = "WETH10";
    string public constant symbol = "WETH10";
    uint8  public override constant decimals = 18;

    bytes32 public immutable CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /// @dev Records amount of WETH10 token owned by account.
    mapping (address => uint256) public override balanceOf;

    /// @dev Records current ERC2612 nonce for account. This value must be included whenever signature is generated for {permit}.
    /// Every successful call to {permit} increases account's nonce by one. This prevents signature from being used multiple times.
    mapping (address => uint256) public override nonces;

    /// @dev Records number of WETH10 token that account (second) will be allowed to spend on behalf of another account (first) through {transferFrom}.
    mapping (address => mapping (address => uint256)) public override allowance;

    /// @dev Current amount of flash-minted WETH10 token.
    uint256 public override flashMinted;
    
    /// @dev Returns the total supply of WETH10 token as the ETH held in this contract.
    function totalSupply() external view override returns(uint256) {
        return address(this).balance + flashMinted;
    }

    /// @dev Fallback, `msg.value` of ETH sent to this contract grants caller account a matching increase in WETH10 token balance.
    /// Emits {Transfer} event to reflect WETH10 token mint of `msg.value` from zero address to caller account.
    receive() external payable {
        // _mintTo(msg.sender, msg.value);
        balanceOf[msg.sender] += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /// @dev `msg.value` of ETH sent to this contract grants caller account a matching increase in WETH10 token balance.
    /// Emits {Transfer} event to reflect WETH10 token mint of `msg.value` from zero address to caller account.
    function deposit() external override payable {
        // _mintTo(msg.sender, msg.value);
        balanceOf[msg.sender] += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /// @dev `msg.value` of ETH sent to this contract grants `to` account a matching increase in WETH10 token balance.
    /// Emits {Transfer} event to reflect WETH10 token mint of `msg.value` from zero address to `to` account.
    function depositTo(address to) external override payable {
        // _mintTo(to, msg.value);
        balanceOf[to] += msg.value;
        emit Transfer(address(0), to, msg.value);
    }

    /// @dev `msg.value` of ETH sent to this contract grants `to` account a matching increase in WETH10 token balance,
    /// after which a call is executed to an ERC677-compliant contract with the `data` parameter.
    /// Emits {Transfer} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// For more information on *transferAndCall* format, see https://github.com/ethereum/EIPs/issues/677.
    function depositToAndCall(address to, bytes calldata data) external override payable returns (bool success) {
        // _mintTo(to, msg.value);
        balanceOf[to] += msg.value;
        emit Transfer(address(0), to, msg.value);

        return ITransferReceiver(to).onTokenTransfer(msg.sender, msg.value, data);
    }

    /// @dev Return the amount of WETH10 token that can be flash-lent.
    function maxFlashLoan(address token) external view override returns (uint256) {
        return token == address(this) ? type(uint112).max - flashMinted : 0; // Can't underflow
    }

    /// @dev Return the fee (zero) for flash-lending an amount of WETH10 token.
    function flashFee(address token, uint256) external view override returns (uint256) {
        require(token == address(this), "WETH: flash mint only WETH10");
        return 0;
    }

    /// @dev Flash lends `value` WETH10 token to the receiver address.
    /// By the end of the transaction, `value` WETH10 token will be burned from the receiver.
    /// The flash-minted WETH10 token is not backed by real ETH, but can be withdrawn as such up to the ETH balance of this contract.
    /// Arbitrary data can be passed as a bytes calldata parameter.
    /// Emits {Approval} event to reflect reduced allowance `value` for this contract to spend from receiver account (`receiver`),
    /// unless allowance is set to `type(uint256).max`
    /// Emits two {Transfer} events for minting and burning of the flash-minted amount.
    /// Returns boolean value indicating whether operation succeeded.
    /// Requirements:
    ///   - `value` must be less or equal to type(uint112).max.
    ///   - The total of all flash loans in a tx must be less or equal to type(uint112).max.
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 value, bytes calldata data) external override returns(bool) {
        require(token == address(this), "WETH: flash mint only WETH10");
        require(value <= type(uint112).max, "WETH: individual loan limit exceeded");
        flashMinted = flashMinted + value;
        require(flashMinted <= type(uint112).max, "WETH: total loan limit exceeded");
        
        // _mintTo(address(receiver), value);
        balanceOf[address(receiver)] += value;
        emit Transfer(address(0), address(receiver), value);

        require(
            receiver.onFlashLoan(msg.sender, address(this), value, 0, data) == CALLBACK_SUCCESS,
            "WETH: flash loan failed"
        );
        
        // _decreaseAllowance(address(receiver), address(this), value);
        uint256 allowed = allowance[address(receiver)][address(this)];
        if (allowed != type(uint256).max) {
            require(allowed >= value, "WETH: request exceeds allowance");
            uint256 reduced = allowed - value;
            allowance[address(receiver)][address(this)] = reduced;
            emit Approval(address(receiver), address(this), reduced);
        }

        // _burnFrom(address(receiver), value);
        uint256 balance = balanceOf[address(receiver)];
        require(balance >= value, "WETH: burn amount exceeds balance");
        balanceOf[address(receiver)] = balance - value;
        emit Transfer(address(receiver), address(0), value);
        
        flashMinted = flashMinted - value;
        return true;
    }

    /// @dev Burn `value` WETH10 token from caller account and withdraw matching ETH to the same.
    /// Emits {Transfer} event to reflect WETH10 token burn of `value` to zero address from caller account. 
    /// Requirements:
    ///   - caller account must have at least `value` balance of WETH10 token.
    function withdraw(uint256 value) external override {
        // _burnFrom(msg.sender, value);
        uint256 balance = balanceOf[msg.sender];
        require(balance >= value, "WETH: burn amount exceeds balance");
        balanceOf[msg.sender] = balance - value;
        emit Transfer(msg.sender, address(0), value);

        // _transferEther(msg.sender, value);        
        (bool success, ) = msg.sender.call{value: value}("");
        require(success, "WETH: ETH transfer failed");
    }

    /// @dev Burn `value` WETH10 token from caller account and withdraw matching ETH to account (`to`).
    /// Emits {Transfer} event to reflect WETH10 token burn of `value` to zero address from caller account.
    /// Requirements:
    ///   - caller account must have at least `value` balance of WETH10 token.
    function withdrawTo(address payable to, uint256 value) external override {
        // _burnFrom(msg.sender, value);
        uint256 balance = balanceOf[msg.sender];
        require(balance >= value, "WETH: burn amount exceeds balance");
        balanceOf[msg.sender] = balance - value;
        emit Transfer(msg.sender, address(0), value);

        // _transferEther(to, value);        
        (bool success, ) = to.call{value: value}("");
        require(success, "WETH: ETH transfer failed");
    }

    /// @dev Burn `value` WETH10 token from account (`from`) and withdraw matching ETH to account (`to`).
    /// Emits {Approval} event to reflect reduced allowance `value` for caller account to spend from account (`from`),
    /// unless allowance is set to `type(uint256).max`
    /// Emits {Transfer} event to reflect WETH10 token burn of `value` to zero address from account (`from`).
    /// Requirements:
    ///   - `from` account must have at least `value` balance of WETH10 token.
    ///   - `from` account must have approved caller to spend at least `value` of WETH10 token, unless `from` and caller are the same account.
    function withdrawFrom(address from, address payable to, uint256 value) external override {
        if (from != msg.sender) {
            // _decreaseAllowance(from, msg.sender, value);
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "WETH: request exceeds allowance");
                uint256 reduced = allowed - value;
                allowance[from][msg.sender] = reduced;
                emit Approval(from, msg.sender, reduced);
            }
        }
        
        // _burnFrom(from, value);
        uint256 balance = balanceOf[from];
        require(balance >= value, "WETH: burn amount exceeds balance");
        balanceOf[from] = balance - value;
        emit Transfer(from, address(0), value);

        // _transferEther(to, value);        
        (bool success, ) = to.call{value: value}("");
        require(success, "WETH: Ether transfer failed");
    }

    /// @dev Sets `value` as allowance of `spender` account over caller account's WETH10 token.
    /// Emits {Approval} event.
    /// Returns boolean value indicating whether operation succeeded.
    function approve(address spender, uint256 value) external override returns (bool) {
        // _approve(msg.sender, spender, value);
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }

    /// @dev Sets `value` as allowance of `spender` account over caller account's WETH10 token,
    /// after which a call is executed to an ERC677-compliant contract with the `data` parameter.
    /// Emits {Approval} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// For more information on approveAndCall format, see https://github.com/ethereum/EIPs/issues/677.
    function approveAndCall(address spender, uint256 value, bytes calldata data) external override returns (bool) {
        // _approve(msg.sender, spender, value);
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        
        return IApprovalReceiver(spender).onTokenApproval(msg.sender, value, data);
    }

    /// @dev Sets `value` as allowance of `spender` account over `owner` account's WETH10 token, given `owner` account's signed approval.
    /// Emits {Approval} event.
    /// Requirements:
    ///   - `deadline` must be timestamp in future.
    ///   - `v`, `r` and `s` must be valid `secp256k1` signature from `owner` account over EIP712-formatted function arguments.
    ///   - the signature must use `owner` account's current nonce (see {nonces}).
    ///   - the signer cannot be zero address and must be `owner` account.
    /// For more information on signature format, see https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP section].
    /// WETH10 token implementation adapted from https://github.com/albertocuestacanada/ERC20Permit/blob/master/contracts/ERC20Permit.sol.
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(block.timestamp <= deadline, "WETH: Expired permit");

        uint256 chainId;
        assembly {chainId := chainid()}
        bytes32 DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)));

        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline));

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                hashStruct));

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0) && signer == owner, "WETH: invalid permit");

        // _approve(owner, spender, value);
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /// @dev Moves `value` WETH10 token from caller's account to account (`to`).
    /// A transfer to `address(0)` triggers an ETH withdraw matching the sent WETH10 token in favor of caller.
    /// Emits {Transfer} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// Requirements:
    ///   - caller account must have at least `value` WETH10 token.
    function transfer(address to, uint256 value) external override returns (bool) {
        // _transferFrom(msg.sender, to, value);
        if (to != address(0)) { // Transfer
            uint256 balance = balanceOf[msg.sender];
            require(balance >= value, "WETH: transfer amount exceeds balance");

            balanceOf[msg.sender] = balance - value;
            balanceOf[to] += value;
            emit Transfer(msg.sender, to, value);
        } else { // Withdraw
            uint256 balance = balanceOf[msg.sender];
            require(balance >= value, "WETH: burn amount exceeds balance");
            balanceOf[msg.sender] = balance - value;
            emit Transfer(msg.sender, address(0), value);
            
            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }
        
        return true;
    }

    /// @dev Moves `value` WETH10 token from account (`from`) to account (`to`) using allowance mechanism.
    /// `value` is then deducted from caller account's allowance, unless set to `type(uint256).max`.
    /// A transfer to `address(0)` triggers an ETH withdraw matching the sent WETH10 token in favor of caller.
    /// Emits {Approval} event to reflect reduced allowance `value` for caller account to spend from account (`from`),
    /// unless allowance is set to `type(uint256).max`
    /// Emits {Transfer} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// Requirements:
    ///   - `from` account must have at least `value` balance of WETH10 token.
    ///   - `from` account must have approved caller to spend at least `value` of WETH10 token, unless `from` and caller are the same account.
    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        if (from != msg.sender) {
            // _decreaseAllowance(from, msg.sender, value);
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "WETH: request exceeds allowance");
                uint256 reduced = allowed - value;
                allowance[from][msg.sender] = reduced;
                emit Approval(from, msg.sender, reduced);
            }
        }
        
        // _transferFrom(from, to, value);
        if (to != address(0)) { // Transfer
            uint256 balance = balanceOf[from];
            require(balance >= value, "WETH: transfer amount exceeds balance");

            balanceOf[from] = balance - value;
            balanceOf[to] += value;
            emit Transfer(from, to, value);
        } else { // Withdraw
            uint256 balance = balanceOf[from];
            require(balance >= value, "WETH: burn amount exceeds balance");
            balanceOf[from] = balance - value;
            emit Transfer(from, address(0), value);
        
            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }
        
        return true;
    }

    /// @dev Moves `value` WETH10 token from caller's account to account (`to`), 
    /// after which a call is executed to an ERC677-compliant contract with the `data` parameter.
    /// A transfer to `address(0)` triggers an ETH withdraw matching the sent WETH10 token in favor of caller.
    /// Emits {Transfer} event.
    /// Returns boolean value indicating whether operation succeeded.
    /// Requirements:
    ///   - caller account must have at least `value` WETH10 token.
    /// For more information on transferAndCall format, see https://github.com/ethereum/EIPs/issues/677.
    function transferAndCall(address to, uint value, bytes calldata data) external override returns (bool) {
        // _transferFrom(msg.sender, to, value);
        if (to != address(0)) { // Transfer
            uint256 balance = balanceOf[msg.sender];
            require(balance >= value, "WETH: transfer amount exceeds balance");

            balanceOf[msg.sender] = balance - value;
            balanceOf[to] += value;
            emit Transfer(msg.sender, to, value);
        } else { // Withdraw
            uint256 balance = balanceOf[msg.sender];
            require(balance >= value, "WETH: burn amount exceeds balance");
            balanceOf[msg.sender] = balance - value;
            emit Transfer(msg.sender, address(0), value);
        
            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }

        return ITransferReceiver(to).onTokenTransfer(msg.sender, value, data);
    }
}



/*
    Scarcity is the bonding curve token that underpins Behodler functionality
    Scarcity burns on transfer and also exacts a fee outside of Behodler.
 */
contract Scarcity is IERC20, Ownable {
    using SafeMath for uint256;
    event Mint(address sender, address recipient, uint256 value);
    event Burn(uint256 value);

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    address public migrator;

    struct BurnConfig {
        uint256 transferFee; // percentage expressed as number betewen 1 and 1000
        uint256 burnFee; // percentage expressed as number betewen 1 and 1000
        address feeDestination;
    }

    BurnConfig public config;

    function configureScarcity(
        uint256 transferFee,
        uint256 burnFee,
        address feeDestination
    ) public onlyOwner {
        require(config.transferFee + config.burnFee < 1000);
        config.transferFee = transferFee;
        config.burnFee = burnFee;
        config.feeDestination = feeDestination;
    }

    function getConfiguration()
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        return (config.transferFee, config.burnFee, config.feeDestination);
    }

    function setMigrator(address m) public onlyOwner {
        migrator = m;
    }

    function name() public pure returns (string memory) {
        return "Scarcity";
    }

    function symbol() public pure returns (string memory) {
        return "SCX";
    }

    function decimals() public override pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function burn(uint256 value) external returns (bool) {
        burn(msg.sender, value);
        return true;
    }

    function burn(address holder, uint256 value) internal {
        balances[holder] = balances[holder].sub(
            value,
            "SCARCITY: insufficient funds"
        );
        _totalSupply = _totalSupply.sub(value);
        emit Burn(value);
    }

    function mint(address recipient, uint256 value) internal {
        balances[recipient] = balances[recipient].add(value);
        _totalSupply = _totalSupply.add(value);
        emit Mint(msg.sender, recipient, value);
    }

    function migrateMint(address recipient, uint256 value) public {
        require(msg.sender == migrator, "SCARCITY: Migration contract only");
        mint(recipient, value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //outside of Behodler, Scarcity transfer incurs a fee.
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(
            sender != address(0),
            "Scarcity: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "Scarcity: transfer to the zero address"
        );

        uint256 feeComponent = config.transferFee.mul(amount).div(1000);
        uint256 burnComponent = config.burnFee.mul(amount).div(1000);
        _totalSupply = _totalSupply.sub(burnComponent);
        emit Burn(burnComponent);

        balances[config.feeDestination] = balances[config.feeDestination].add(
            feeComponent
        );

        balances[sender] = balances[sender].sub(
            amount,
            "Scarcity: transfer amount exceeds balance"
        );

        balances[recipient] = balances[recipient].add(
            amount.sub(feeComponent.add(burnComponent))
        );
        emit Transfer(sender, recipient, amount);
    }

    function applyBurnFee(address token, uint256 amount,bool proxyBurn)
        internal
        returns (uint256)
    {
        uint256 burnAmount = config.burnFee.mul(amount).div(1000);
        Burnable bToken = Burnable(token);
        if (proxyBurn) {
            bToken.burn(address(this), burnAmount);
        } else {
            bToken.burn(burnAmount);
        }

        return burnAmount;
    }
}



/*To following code is sourced from the ABDK library for assistance in dealing with precision logarithms in Ethereum.
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 * Source: https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L366
 */


/*
	Behodler orchestrates trades using an omnischedule bonding curve.
	The name is inspired by the Beholder of D&D, a monster with multiple arms ending in eyes peering in all directions.
	The Behodler is a smart contract that can see the prices of all tokens simultaneously without need for composition or delay.
	The hodl part of Behodler refers to the fact that with every trade of a token pair, the liquidity pool of each token held by Behodler increases

    Behodler 1 performed square root calculations which are gas intensive for fixed point arithmetic algorithms.
    To save gas, Behodler2 never performs square root calculations. It just checks the numbers passed in by the user and reverts if needs be.
    This techique is called invariant checking and offloads maximum calculation to clients while guaranteeing no cheating is possible.
    In Behodler 1 some operations were duplicated. For instance, a swap was a scarcity purchase followed by a scarcity sale. Instead, cutting out
    the middle scarcity allows the factor scaling to be dropped altogether.

    By bringing Scarcity, Janus, Kharon and Behodler together in one contract, Behodler 2 avoids the EXT_CALL gas fees and can take gas saving shortcuts with Scarcity
    transfers. The drawback to this approach is less flexibility with fees in the way that Kharon allowed.

    Behodler 2 now has Flashloan support. Instead of charging a liquidity growing fee, Behodler 2 requires the user fulfil some requirement
    such as holding an NFT or staking Scarcity. This allows for zero fee flash loans that are front runner resistant and
    allows a secondary flashloan market to evolve.
 */
contract Behodler is Scarcity {
    using SafeMath for uint256;
    using ABDK for int128;
    using ABDK for uint256;
    using AddressBalanceCheck for address;

    event LiquidityAdded(
        address sender,
        address token,
        uint256 tokenValue,
        uint256 scx
    );
    event LiquidityWithdrawn(
        address recipient,
        address token,
        uint256 tokenValue,
        uint256 scx
    );
    event Swap(
        address sender,
        address inputToken,
        address outputToken,
        uint256 inputValue,
        uint256 outputValue
    );

    struct WeidaiTokens {
        address dai;
        address reserve;
        address weiDai;
    }

    struct PrecisionFactors {
        uint8 swapPrecisionFactor;
        uint8 maxLiquidityExit; //percentage as number between 1 and 100
    }

    WeidaiTokens WD;
    PrecisionFactors safetyParameters;
    address public Weth;
    address public Lachesis;
    address pyroTokenLiquidityReceiver;
    FlashLoanArbiter public arbiter;
    address private inputSender;
    bool[3] unlocked;

    constructor() {
        safetyParameters.swapPrecisionFactor = 30; //approximately a billion
        safetyParameters.maxLiquidityExit = 90;
        for (uint8 i = 0; i < 3; i++) unlocked[i] = true;
    }

    function setSafetParameters(
        uint8 swapPrecisionFactor,
        uint8 maxLiquidityExit
    ) external onlyOwner {
        safetyParameters.swapPrecisionFactor = swapPrecisionFactor;
        safetyParameters.maxLiquidityExit = maxLiquidityExit;
    }

    function getMaxLiquidityExit() public view returns (uint8) {
        return safetyParameters.maxLiquidityExit;
    }

    function seed(
        address weth,
        address lachesis,
        address flashLoanArbiter,
        address _pyroTokenLiquidityReceiver,
        address weidaiReserve,
        address dai,
        address weiDai
    ) external onlyOwner {
        Weth = weth;
        Lachesis = lachesis;
        arbiter = FlashLoanArbiter(flashLoanArbiter);
        pyroTokenLiquidityReceiver = _pyroTokenLiquidityReceiver;
        WD.reserve = weidaiReserve;
        WD.dai = dai;
        WD.weiDai = weiDai;
    }

    //Logarithmic growth can get quite flat beyond the first chunk. We divide input amounts by
    uint256 public constant MIN_LIQUIDITY = 1e12;

    mapping(address => bool) public tokenBurnable;
    mapping(address => bool) public validTokens;
    mapping(address => bool) public whiteListUsers; // can trade on tokens that are disabled

    modifier onlyLachesis {
        require(msg.sender == Lachesis);
        _;
    }

    modifier onlyValidToken(address token) {
        require(
            whiteListUsers[msg.sender] ||
                validTokens[token] ||
                (token != address(0) && token == Weth),
            "BEHODLER: token invalid"
        );
        _;
    }

    modifier determineSender(address inputToken) {
        if (msg.value > 0) {
            require(
                inputToken == Weth,
                "BEHODLER: Eth only valid for Weth trades."
            );
            inputSender = address(this);
        } else {
            inputSender = msg.sender;
        }
        _;
    }

    enum Slot {Swap, Add, Withdraw}

    modifier lock(Slot slot) {
        uint256 index = uint256(slot);
        require(unlocked[index], "BEHODLER: Reentrancy guard active.");
        unlocked[index] = false;
        _;
        unlocked[index] = true;
    }

    /*
   Let config.burnFee be b.
    Let F = 1-b
    Let input token be I and Output token be O
    _i is initial and _f is final. Eg. I_i is initial input token balance
    The swap equation, when simplified, is given by
    √F(√I_f - √I_i) = (√O_i - √O_f)/(F)
    However, the gradient of square root becomes untenable when
    the value of tokens diverge too much. The gradient favours the addition of low
    value tokens disportionately. A gradient that favours tokens equally is given by
    a log. The lowest gas implementation is base 2.
    The new swap equation is thus
    log(I_f) - log(I_i) = log(O_i) - log(O_f)

    Technical note on ETH handling: we don't duplicate functions for accepting Eth as an input. Instead we wrap on receipt
    and apply a reentrancy guard. The determineSender modifier fixes an isse in Behodler 1 which required the user to approve
    both sending and receiving Eth because of the nature of Weth deposit and withdraw functionality.
 */
    function swap(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount
    )
        external
        payable
        determineSender(inputToken)
        onlyValidToken(inputToken)
        lock(Slot.Swap)
        returns (bool success)
    {
        uint256 initialInputBalance = inputToken.tokenBalance();
        if (inputToken == Weth) {
            if (IERC20(Weth).balanceOf(msg.sender) >= inputAmount) {
                Weth.transferIn(msg.sender, inputAmount);
            } else {
                require(
                    msg.value == inputAmount,
                    "BEHODLER: Insufficient Ether sent"
                );
                IWETH10(Weth).deposit{value: msg.value}();
            }
        } else {
            inputToken.transferIn(inputSender, inputAmount);
        }

        uint256 netInputAmount =
            inputAmount.sub(burnToken(inputToken, inputAmount));
        uint256 initialOutputBalance = outputToken.tokenBalance();
        require(
            outputAmount.mul(100).div(initialOutputBalance) <=
                safetyParameters.maxLiquidityExit,
            "BEHODLER: liquidity withdrawal too large."
        );
        uint256 finalInputBalance = initialInputBalance.add(netInputAmount);
        uint256 finalOutputBalance = initialOutputBalance.sub(outputAmount);

        //new scope to avoid stack too deep errors.
        {
            //if the input balance after adding input liquidity is 1073741824 bigger than the initial balance, we revert.
            uint256 inputRatio =
                (initialInputBalance << safetyParameters.swapPrecisionFactor)
                    .div(finalInputBalance);
            uint256 outputRatio =
                (finalOutputBalance << safetyParameters.swapPrecisionFactor)
                    .div(initialOutputBalance);

            require(
                inputRatio != 0 && inputRatio == outputRatio,
                "BEHODLER: swap invariant."
            );
        }

        require(
            finalOutputBalance >= MIN_LIQUIDITY,
            "BEHODLER: min liquidity."
        );

        if (outputToken == Weth) {
            address payable sender = msg.sender;
            IWETH10(Weth).withdrawTo(sender, outputAmount);
        } else {
            outputToken.transferOut(msg.sender, outputAmount);
        }

        emit Swap(
            msg.sender,
            inputToken,
            outputToken,
            inputAmount,
            outputAmount
        );
        success = true;
    }

    /*
        ΔSCX = log(FinalBalance) - log(InitialBalance)

        The choice of base for the log isn't relevant from a mathematical point of view
        but from a computational point of view, base 2 is the cheapest for obvious reasons.
        "What I told you was true, from a certain point of view." - Obi-Wan Kenobi
     */
    function addLiquidity(address inputToken, uint256 amount)
        external
        payable
        determineSender(inputToken)
        onlyValidToken(inputToken)
        lock(Slot.Add)
        returns (uint256 deltaSCX)
    {
        uint256 initialBalance =
            uint256(inputToken.shiftedBalance(MIN_LIQUIDITY).fromUInt());
        if (inputToken == Weth) {
            if (IERC20(Weth).balanceOf(msg.sender) >= amount) {
                Weth.transferIn(msg.sender, amount);
            } else {
                require(
                    msg.value == amount,
                    "BEHODLER: Insufficient Ether sent"
                );
                IWETH10(Weth).deposit{value: msg.value}();
            }
        } else {
            inputToken.transferIn(inputSender, amount);
        }
        uint256 netInputAmount =
            uint256(
                amount
                    .sub(burnToken(inputToken, amount))
                    .div(MIN_LIQUIDITY)
                    .fromUInt()
            );

        uint256 finalBalance = uint256(initialBalance.add(netInputAmount));
        require(
            uint256(finalBalance) >= MIN_LIQUIDITY,
            "BEHODLER: min liquidity."
        );
        deltaSCX = uint256(
            finalBalance.log_2() -
                (initialBalance > 1 ? initialBalance.log_2() : 0)
        );
        mint(msg.sender, deltaSCX);
        emit LiquidityAdded(msg.sender, inputToken, amount, deltaSCX);
    }

    /*
        ΔSCX =  log(InitialBalance) - log(FinalBalance)
        tokensToRelease = InitialBalance -FinalBalance
        =>FinalBalance =  InitialBalance - tokensToRelease
        Then apply logs and deduct SCX from msg.sender

        The choice of base for the log isn't relevant from a mathematical point of view
        but from a computational point of view, base 2 is the cheapest for obvious reasons.
        "From my point of view, the Jedi are evil" - Darth Vader
     */
    function withdrawLiquidity(address outputToken, uint256 tokensToRelease)
        external
        payable
        determineSender(outputToken)
        onlyValidToken(outputToken)
        lock(Slot.Withdraw)
        returns (uint256 deltaSCX)
    {
        uint256 initialBalance = outputToken.tokenBalance();
        uint256 finalBalance = initialBalance.sub(tokensToRelease);
        require(finalBalance > MIN_LIQUIDITY, "BEHODLER: min liquidity");
        require(
            tokensToRelease.mul(100).div(initialBalance) <=
                safetyParameters.maxLiquidityExit,
            "BEHODLER: liquidity withdrawal too large."
        );

        uint256 logInitial = initialBalance.log_2();
        uint256 logFinal = finalBalance.log_2();

        deltaSCX = logInitial - (finalBalance > 1 ? logFinal : 0);
        uint256 scxBalance = balances[msg.sender];

        if (deltaSCX > scxBalance) {
            //rounding errors in scx creation and destruction. Err on the side of holders
            uint256 difference = deltaSCX - scxBalance;
            if ((difference * 10000) / deltaSCX == 0) deltaSCX = scxBalance;
        }
        burn(msg.sender, deltaSCX);

        if (outputToken == Weth) {
            address payable sender = msg.sender;
            IWETH10(Weth).withdrawTo(sender, tokensToRelease);
        } else {
            outputToken.transferOut(msg.sender, tokensToRelease);
        }
        emit LiquidityWithdrawn(
            msg.sender,
            outputToken,
            tokensToRelease,
            deltaSCX
        );
    }

    /*
        ΔSCX =  log(InitialBalance) - log(FinalBalance)
        tokensToRelease = InitialBalance -FinalBalance
        =>FinalBalance =  InitialBalance - tokensToRelease
        Then apply logs and deduct SCX from msg.sender

        The choice of base for the log isn't relevant from a mathematical point of view
        but from a computational point of view, base 2 is the cheapest for obvious reasons.
        "From my point of view, the Jedi are evil" - Darth Vader
     */
    function withdrawLiquidityFindSCX(
        address outputToken,
        uint256 tokensToRelease,
        uint256 scx,
        uint256 passes
    ) external view returns (uint256) {
        uint256 upperBoundary = outputToken.tokenBalance();
        uint256 lowerBoundary = 0;

        for (uint256 i = 0; i < passes; i++) {
            uint256 initialBalance = outputToken.tokenBalance();
            uint256 finalBalance = initialBalance.sub(tokensToRelease);

            uint256 logInitial = initialBalance.log_2();
            uint256 logFinal = finalBalance.log_2();

            int256 deltaSCX =
                int256(logInitial - (finalBalance > 1 ? logFinal : 0));
            int256 difference = int256(scx) - deltaSCX;
            // if (difference**2 < 1000000) return tokensToRelease;
            if (difference == 0) return tokensToRelease;
            if (difference < 0) {
                // too many tokens requested
                upperBoundary = tokensToRelease - 1;
            } else {
                //too few tokens requested
                lowerBoundary = tokensToRelease + 1;
            }
            tokensToRelease =
                ((upperBoundary - lowerBoundary) / 2) +
                lowerBoundary; //bitshift
            tokensToRelease = tokensToRelease > initialBalance
                ? initialBalance
                : tokensToRelease;
        }
        return tokensToRelease;
    }

    //TODO: possibly comply with the flash loan standard https://eips.ethereum.org/EIPS/eip-3156
    // - however, the more I reflect on this, the less keen I am due to gas and simplicity
    //example: a user must hold 10% of SCX total supply or user must hold an NFT
    //The initial arbiter will have no constraints.
    //The flashloan system on behodler is inverted. Instead of being able to borrow any individual token,
    //the borrower asks for SCX. Theoretically you can borrow more SCX than currently exists so long
    //as you can think of a clever way to pay it back.
    //Note: Borrower doesn't have to send scarcity back, they just need to have high enough balance.
    function grantFlashLoan(uint256 amount, address flashLoanContract)
        external
    {
        require(
            arbiter.canBorrow(msg.sender),
            "BEHODLER: cannot borrow flashloan"
        );
        balances[flashLoanContract] = balances[flashLoanContract].add(amount);
        FlashLoanReceiver(flashLoanContract).execute(msg.sender); 
        balances[flashLoanContract] = balances[flashLoanContract].sub(
            amount,
            "BEHODLER: Flashloan repayment failed"
        );
    }

    //useful for when we want the ability to add tokens without trading. For instance, the initial liquidity queueing event.
    function setWhiteListUser(address user, bool whiteList) external onlyOwner {
        whiteListUsers[user] = whiteList;
    }

    function burnToken(address token, uint256 amount)
        private
        returns (uint256 burnt)
    {
        if (token == WD.weiDai) {
            burnt = applyBurnFee(token, amount, true);
        } else if (tokenBurnable[token])
            burnt = applyBurnFee(token, amount, false);
        else if (token == WD.dai) {
            burnt = config.burnFee.mul(amount).div(1000);
            token.transferOut(WD.reserve, burnt);
        } else {
            burnt = config.burnFee.mul(amount).div(1000);
            token.transferOut(pyroTokenLiquidityReceiver, burnt);
        }
    }

    function setValidToken(
        address token,
        bool valid,
        bool burnable
    ) external onlyLachesis {
        validTokens[token] = valid;
        tokenBurnable[token] = burnable;
    }
}