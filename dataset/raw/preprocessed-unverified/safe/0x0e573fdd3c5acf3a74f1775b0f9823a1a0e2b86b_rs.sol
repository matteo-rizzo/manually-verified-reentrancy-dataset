/**
 *Submitted for verification at Etherscan.io on 2019-12-20
*/

pragma solidity ^0.5.13;
pragma experimental ABIEncoderV2;

contract XBullionTokenConfig {
    using Math64x64 for int128;

    string internal constant TOKEN_SYMBOL = "GOLD";
    string internal constant TOKEN_NAME = "xbullion token";
    uint8 internal constant TOKEN_DECIMALS = 8;

    uint256 private constant DECIMALS_FACTOR = 10**uint256(TOKEN_DECIMALS);
    uint256 internal constant TOKEN_INITIALSUPPLY = 0;

    uint256 internal constant TOKEN_MINTCAPACITY = 100 * DECIMALS_FACTOR;
    uint internal constant TOKEN_MINTPERIOD = 24 hours;

    function initialFeeTiers()
        internal
        pure
        returns (ERC20WithFees.FeeTier[] memory feeTiers)
    {
        feeTiers = new ERC20WithFees.FeeTier[](2);
        feeTiers[0] = ERC20WithFees.FeeTier({
            threshold: 0,
            fee: feeFromBPs(60)
        });
        feeTiers[1] = ERC20WithFees.FeeTier({
            threshold: 20000 * DECIMALS_FACTOR,
            fee: feeFromBPs(30)
        });
    }

    function initialTxFee()
        internal
        pure
        returns (int128)
    {
        return txFeeFromBPs(12);
    }

    function makeAddressSingleton(address _addr)
        internal
        pure
        returns (address[] memory addrs)
    {
        addrs = new address[](1);
        addrs[0] = _addr;
    }

    function feeFromBPs(uint _bps)
        internal
        pure
        returns (int128)
    {
        return Math64x64.fromUInt(_bps)
            .div(Math64x64.fromUInt(10000))
            .div(Math64x64.fromUInt(365))
            .div(Math64x64.fromUInt(86400));
    }

    function txFeeFromBPs(uint _bps)
        internal
        pure
        returns (int128)
    {
        return Math64x64.fromUInt(_bps)
            .div(Math64x64.fromUInt(10000));
    }
}

contract ERC20Interface {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function approve(address _spender, uint256 _amount) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _amount) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);

    function decimals() public view returns (uint8);
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function totalSupply() public view returns (uint256);
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




/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.
 */


contract BurnerRole {
    using AddressSet for AddressSet.addrset;

    AddressSet.addrset private burners;

    event BurnerAddition(address indexed addr);
    event BurnerRemoval(address indexed addr);

    modifier ifBurner(address _addr) {
        require(isBurner(_addr),
            "BurnerRole: specified account does not have the Burner role");
        _;
    }

    modifier onlyBurner() {
        require(isBurner(msg.sender),
            "BurnerRole: caller does not have the Burner role");
        _;
    }

    function getBurners()
        public
        view
        returns (address[] memory)
    {
        return burners.elements;
    }

    function isBurner(address _addr)
        public
        view
        returns (bool)
    {
        return burners.has(_addr);
    }

    function numBurners()
        public
        view
        returns (uint)
    {
        return burners.elements.length;
    }

    function _addBurner(address _addr)
        internal
    {
        require(burners.insert(_addr),
            "BurnerRole: duplicate bearer");
        emit BurnerAddition(_addr);
    }

    function _removeBurner(address _addr)
        internal
    {
        require(burners.remove(_addr),
            "BurnerRole: not a bearer");
        emit BurnerRemoval(_addr);
    }
}

contract ManagerRole {
    using AddressSet for AddressSet.addrset;

    AddressSet.addrset private managers;

    event ManagerAddition(address indexed addr);
    event ManagerRemoval(address indexed addr);

    modifier ifManager(address _addr) {
        require(isManager(_addr),
            "ManagerRole: specified account does not have the Manager role");
        _;
    }

    modifier onlyManager() {
        require(isManager(msg.sender),
            "ManagerRole: caller does not have the Manager role");
        _;
    }

    function getManagers()
        public
        view
        returns (address[] memory)
    {
        return managers.elements;
    }

    function isManager(address _addr)
        public
        view
        returns (bool)
    {
        return managers.has(_addr);
    }

    function numManagers()
        public
        view
        returns (uint)
    {
        return managers.elements.length;
    }

    function _addManager(address _addr)
        internal
    {
        require(managers.insert(_addr),
            "ManagerRole: duplicate bearer");
        emit ManagerAddition(_addr);
    }

    function _removeManager(address _addr)
        internal
    {
        require(managers.remove(_addr),
            "ManagerRole: not a bearer");
        emit ManagerRemoval(_addr);
    }
}

contract MinterRole {
    using AddressSet for AddressSet.addrset;

    AddressSet.addrset private minters;

    event MinterAddition(address indexed addr);
    event MinterRemoval(address indexed addr);

    modifier ifMinter(address _addr) {
        require(isMinter(_addr),
            "MinterRole: specified account does not have the Minter role");
        _;
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender),
            "MinterRole: caller does not have the Minter role");
        _;
    }

    function getMinters()
        public
        view
        returns (address[] memory)
    {
        return minters.elements;
    }

    function isMinter(address _addr)
        public
        view
        returns (bool)
    {
        return minters.has(_addr);
    }

    function numMinters()
        public
        view
        returns (uint)
    {
        return minters.elements.length;
    }

    function _addMinter(address _addr)
        internal
    {
        require(minters.insert(_addr),
            "MinterRole: duplicate bearer");
        emit MinterAddition(_addr);
    }

    function _removeMinter(address _addr)
        internal
    {
        require(minters.remove(_addr),
            "MinterRole: not a bearer");
        emit MinterRemoval(_addr);
    }
}

contract OwnerRole {
    using AddressSet for AddressSet.addrset;

    AddressSet.addrset private owners;

    event OwnerAddition(address indexed addr);
    event OwnerRemoval(address indexed addr);

    modifier onlyOwner() {
        require(isOwner(msg.sender),
            "OwnerRole: caller does not have the Owner role");
        _;
    }

    function getOwners()
        public
        view
        returns (address[] memory)
    {
        return owners.elements;
    }

    function isOwner(address _addr)
        public
        view
        returns (bool)
    {
        return owners.has(_addr);
    }

    function numOwners()
        public
        view
        returns (uint)
    {
        return owners.elements.length;
    }

    function _addOwner(address _addr)
        internal
    {
        require(owners.insert(_addr),
            "OwnerRole: duplicate bearer");
        emit OwnerAddition(_addr);
    }

    function _removeOwner(address _addr)
        internal
    {
        require(owners.remove(_addr),
            "OwnerRole: not a bearer");
        emit OwnerRemoval(_addr);
    }
}

contract MultiOwned is OwnerRole {
    uint constant public MAX_OWNER_COUNT = 50;

    struct Transaction {
        bytes data;
        bool executed;
    }

    mapping(bytes32 => Transaction) public transactions;
    mapping(bytes32 => mapping(address => bool)) internal confirmations;
    uint public required;

    event Confirmation(address indexed sender, bytes32 indexed transactionId);
    event Revocation(address indexed sender, bytes32 indexed transactionId);
    event Submission(bytes32 indexed transactionId);
    event Execution(bytes32 indexed transactionId);
    event ExecutionFailure(bytes32 indexed transactionId);
    event Requirement(uint required);

    modifier confirmed(bytes32 _transactionId, address _owner) {
        require(confirmations[_transactionId][_owner]);
        _;
    }

    modifier notConfirmed(bytes32 _transactionId, address _owner) {
        require(!confirmations[_transactionId][_owner]);
        _;
    }

    modifier notExecuted(bytes32 _transactionId) {
        require(!transactions[_transactionId].executed);
        _;
    }

    modifier onlySelf() {
        require(msg.sender == address(this));
        _;
    }

    modifier transactionExists(bytes32 _transactionId) {
        require(transactions[_transactionId].data.length != 0);
        _;
    }

    modifier validRequirement(uint _ownerCount, uint _required) {
        require(0 < _ownerCount
            && 0 < _required
            && _required <= _ownerCount
            && _ownerCount <= MAX_OWNER_COUNT);
        _;
    }

    constructor(address[] memory _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; ++i) {
            _addOwner(_owners[i]);
        }
        required = _required;
    }

    function addOwner(address _owner)
        public
        onlySelf
        validRequirement(numOwners() + 1, required)
    {
        _addOwner(_owner);
    }

    function addTransaction(bytes memory _data, uint _nonce)
        internal
        returns (bytes32 transactionId)
    {
        if (_nonce == 0) _nonce = block.number;
        transactionId = makeTransactionId(_data, _nonce);
        if (transactions[transactionId].data.length == 0) {
            transactions[transactionId] = Transaction({
                data: _data,
                executed: false
            });
            emit Submission(transactionId);
        }
    }

    function confirmTransaction(bytes32 _transactionId)
        public
        onlyOwner
        transactionExists(_transactionId)
        notConfirmed(_transactionId, msg.sender)
    {
        confirmations[_transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, _transactionId);
        executeTransaction(_transactionId);
    }

    function executeTransaction(bytes32 _transactionId)
        public
        onlyOwner
        confirmed(_transactionId, msg.sender)
        notExecuted(_transactionId)
    {
        if (isConfirmed(_transactionId)) {
            Transaction storage txn = transactions[_transactionId];
            txn.executed = true;
            (bool success,) = address(this).call(txn.data);
            if (success) {
                emit Execution(_transactionId);
            } else {
                emit ExecutionFailure(_transactionId);
                txn.executed = false;
            }
        }
    }

    function removeOwner(address _owner)
        public
        onlySelf
    {
        _removeOwner(_owner);
        if (required > numOwners()) {
            setRequirement(numOwners());
        }
    }

    function renounceOwner()
        public
        validRequirement(numOwners() - 1, required)
    {
        _removeOwner(msg.sender);
    }

    function replaceOwner(address _owner, address _newOwner)
        public
        onlySelf
    {
        _removeOwner(_owner);
        _addOwner(_newOwner);
    }

    function revokeConfirmation(bytes32 _transactionId)
        public
        onlyOwner
        confirmed(_transactionId, msg.sender)
        notExecuted(_transactionId)
    {
        confirmations[_transactionId][msg.sender] = false;
        emit Revocation(msg.sender, _transactionId);
    }

    function setRequirement(uint _required)
        public
        onlySelf
        validRequirement(numOwners(), _required)
    {
        required = _required;
        emit Requirement(_required);
    }

    function submitTransaction(bytes memory _data, uint _nonce)
        public
        returns (bytes32 transactionId)
    {
        transactionId = addTransaction(_data, _nonce);
        confirmTransaction(transactionId);
    }

    function getConfirmationCount(bytes32 _transactionId)
        public
        view
        returns (uint count)
    {
        address[] memory owners = getOwners();
        for (uint i = 0; i < numOwners(); ++i) {
            if (confirmations[_transactionId][owners[i]]) ++count;
        }
    }

    function getConfirmations(bytes32 _transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTmp = new address[](numOwners());
        uint count = 0;
        uint i;
        address[] memory owners = getOwners();
        for (i = 0; i < numOwners(); ++i) {
            if (confirmations[_transactionId][owners[i]]) {
                confirmationsTmp[count] = owners[i];
                ++count;
            }
        }
        _confirmations = new address[](count);
        for (i = 0; i < count; ++i) {
            _confirmations[i] = confirmationsTmp[i];
        }
    }

    function isConfirmed(bytes32 _transactionId)
        public
        view
        returns (bool)
    {
        address[] memory owners = getOwners();
        uint count = 0;
        for (uint i = 0; i < numOwners(); ++i) {
            if (confirmations[_transactionId][owners[i]]) ++count;
            if (count == required) return true;
        }
    }

    function makeTransactionId(bytes memory _data, uint _nonce)
        public
        pure
        returns (bytes32 transactionId)
    {
        transactionId = keccak256(abi.encode(_data, _nonce));
    }
}

contract ERC20 is ERC20Interface {
    using SafeMath for uint256;

    string  internal tokenName;
    string  internal tokenSymbol;
    uint8   internal tokenDecimals;
    uint256 internal tokenTotalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply)
        internal
    {
        tokenName = _name;
        tokenSymbol = _symbol;
        tokenDecimals = _decimals;
        _mint(msg.sender, _totalSupply);
    }

    function approve(address _spender, uint256 _amount)
        public
        returns (bool success)
    {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _delta)
        public
        returns (bool success)
    {
        _approve(msg.sender, _spender, allowed[msg.sender][_spender].sub(_delta));
        return true;
    }

    function increaseAllowance(address _spender, uint256 _delta)
        public
        returns (bool success)
    {
        _approve(msg.sender, _spender, allowed[msg.sender][_spender].add(_delta));
        return true;
    }

    function transfer(address _to, uint256 _amount)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount)
        public
        returns (bool success)
    {
        _transfer(_from, _to, _amount);
        _approve(_from, msg.sender, allowed[_from][msg.sender].sub(_amount));
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner)
        public
        view
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function decimals()
        public
        view
        returns (uint8)
    {
        return tokenDecimals;
    }

    function name()
        public
        view
        returns (string memory)
    {
        return tokenName;
    }

    function symbol()
        public
        view
        returns (string memory)
    {
        return tokenSymbol;
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return tokenTotalSupply;
    }

    function _approve(address _owner, address _spender, uint256 _amount)
        internal
    {
        allowed[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _burn(address _from, uint256 _amount)
        internal
    {
        balances[_from] = balances[_from].sub(_amount);
        tokenTotalSupply = tokenTotalSupply.sub(_amount);

        emit Transfer(_from, address(0), _amount);
        emit Burn(_from, _amount);
    }

    function _mint(address _to, uint256 _amount)
        internal
    {
        require(_to != address(0), "ERC20: mint to the zero address");
        require(_to != address(this), "ERC20: mint to token contract");

        tokenTotalSupply = tokenTotalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Transfer(address(0), _to, _amount);
        emit Mint(_to, _amount);
    }

    function _transfer(address _from, address _to, uint256 _amount)
        internal
    {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_to != address(this), "ERC20: transfer to token contract");

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
    }
}

contract ERC20WithFees is MultiOwned, ERC20 {
    using Math64x64 for int128;
    using SafeMath for uint256;
    using AddressSet for AddressSet.addrset;

    struct FeeTier {
        uint256 threshold;
        int128 fee; // fraction per second; positive 64.64 fixed point number
    }

    AddressSet.addrset internal holders;
    mapping(address => uint) internal lastCollected; // epoch timestamp of last management fee collection per holder
    FeeTier[] internal feeTiers; // Management fees per tier; tier thresholds increase monotonically; assumed non-empty with first threshold value equal to zero.
    int128 txFee; // Transfer fee ratio; positive 64.64 fixed point number

    event ManagementFeeCollected(address indexed addr, uint256 amount);
    event TransferFeeCollected(address indexed addr, uint256 amount);

    constructor(FeeTier[] memory _feeTiers, int128 _txFee)
        public
    {
        _setFeeTiers(_feeTiers);
        _setTxFee(_txFee);
    }

    function collectAll()
        public
        returns (uint256 count, uint256 amount)
    {
        for (; count < holders.elements.length; ++count) {
            amount += _collectFee(holders.elements[count]);
        }
    }

    function collectAll(uint256 _offset, uint256 _limit)
        public
        returns (uint256 count, uint256 amount)
    {
        for (; count < _limit && count.add(_offset) < holders.elements.length; ++count) {
            amount += _collectFee(holders.elements[count.add(_offset)]);
        }
    }

    function setFeeTiers(FeeTier[] memory _feeTiers)
        public
        onlySelf
    {
        _setFeeTiers(_feeTiers);
    }

    function setTxFee(int128 _txFee)
        public
        onlySelf
    {
        _setTxFee(_txFee);
    }

    function transferAll(address _to)
        public
        returns (bool success)
    {
        _transferAll(msg.sender, _to);
        return true;
    }

    function transferAllFrom(address _from, address _to)
        public
        returns (bool success)
    {
        uint256 amount = _transferAll(_from, _to);
        _approve(_from, msg.sender, allowed[_from][msg.sender].sub(amount));
        return true;
    }

    function holderCount()
        public
        view
        returns (uint)
    {
        return holders.elements.length;
    }

    function balanceOf(address _owner)
        public
        view
        returns (uint256 balance)
    {
        return balances[_owner].sub(_computeFee(_owner));
    }

    function _collectFee(address _from)
        internal
        returns (uint256 feeAmount)
    {
        if (balances[_from] != 0) {
            feeAmount = _computeFee(_from);
            if (feeAmount != 0) {
                balances[_from] = balances[_from].sub(feeAmount);
                tokenTotalSupply = tokenTotalSupply.sub(feeAmount);
                emit Transfer(_from, address(0), feeAmount);
                emit ManagementFeeCollected(_from, feeAmount);
            }
        }
        lastCollected[_from] = now;
    }

    function _collectTxFee(address _from, uint256 _amount)
        internal
        returns (uint256 txFeeAmount)
    {
        txFeeAmount = _computeTxFee(_amount);
        if (txFeeAmount != 0) {
            balances[_from] = balances[_from].sub(txFeeAmount);
            tokenTotalSupply = tokenTotalSupply.sub(txFeeAmount);
            emit Transfer(_from, address(0), txFeeAmount);
            emit TransferFeeCollected(_from, txFeeAmount);
        }
    }

    function _setFeeTiers(FeeTier[] memory _feeTiers)
        internal
    {
        require(_feeTiers.length > 0,
            "ERC20WithFees: empty fee schedule");
        require(_feeTiers[0].threshold == 0,
            "ERC20WithFees: nonzero threshold for bottom tier");
        require(Math64x64.fromUInt(0) <= _feeTiers[0].fee
            && _feeTiers[0].fee <= Math64x64.fromUInt(1),
            "ERC20WithFees: invalid fee value");
        for (uint i = 1; i < _feeTiers.length; ++i) {
            require(_feeTiers[i].threshold > _feeTiers[i-1].threshold,
                "ERC20WithFees: nonmonotonic threshold value");
            require(_feeTiers[i].fee < _feeTiers[i-1].fee,
                "ERC20WithFees: nonmonotonic fee value");
            require(Math64x64.fromUInt(0) <= _feeTiers[i].fee,
                "ERC20WithFees: invalid fee value");
        }

        delete feeTiers; // re-initializes to empty dynamic storage array
        for (uint i = 0; i < _feeTiers.length; ++i) {
            feeTiers.push(_feeTiers[i]);
        }
    }

    function _setTxFee(int128 _txFee)
        internal
    {
        require(Math64x64.fromUInt(0) <= _txFee
            && _txFee <= Math64x64.fromUInt(1),
            "ERC20WithFees: invalid transfer fee value");
        txFee = _txFee;
    }

    function _transfer(address _from, address _to, uint256 _amount)
        internal
    {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_to != address(this), "ERC20: transfer to token contract");

        // Collect accrued management fees from sender and recipient
        _collectFee(_from);
        _collectFee(_to);

        // Execute transfer
        super._transfer(_from, _to, _amount);

        // Collect transfer fee
        _collectTxFee(_to, _amount);

        // Update set of holders
        if (balances[_from] == 0) holders.remove(_from);
        if (balances[_to] > 0) holders.insert(_to);
    }

    function _transferAll(address _from, address _to)
        internal
        returns (uint256 amount)
    {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_to != address(this), "ERC20: transfer to token contract");

        // Collect accrued management fees from sender and recipient
        _collectFee(_from);
        _collectFee(_to);

        // Execute transfer
        amount = balances[_from];
        super._transfer(_from, _to, amount);

        // Collect transfer fee
        _collectTxFee(_to, amount);

        // Update set of holders
        holders.remove(_from);
        if (balances[_to] > 0) holders.insert(_to);
    }

    function _computeFee(address _addr)
        internal
        view
        returns (uint)
    {
        uint tier = 0;
        while (tier+1 < feeTiers.length && feeTiers[tier+1].threshold <= balances[_addr]) {
            ++tier;
        }
        uint duration = now - lastCollected[_addr];
        return Math64x64.fromUInt(1).sub(Math64x64.exp(Math64x64.fromInt(-1).mul(Math64x64.fromUInt(duration)).mul(feeTiers[tier].fee))).mulu(balances[_addr]);
    }

    function _computeTxFee(uint256 _amount)
        internal
        view
        returns (uint)
    {
        return txFee.mulu(_amount);
    }
}

contract ERC20Burnable is ERC20WithFees, BurnerRole, ManagerRole {
    function addBurner(address _addr)
        public
        onlyManager
    {
        _addBurner(_addr);
    }

    function addManager(address _addr)
        public
        onlySelf
    {
        _addManager(_addr);
    }

    function burn(uint256 _amount)
        public
        onlyBurner
        returns (bool success)
    {
        _burn(msg.sender, _amount);
        return true;
    }

    function burnFrom(address _from, uint256 _amount)
        public
        ifBurner(_from)
        returns (bool success)
    {
        _burn(_from, _amount);
        _approve(_from, msg.sender, allowed[_from][msg.sender].sub(_amount));
        return true;
    }

    function burnAll()
        public
        onlyBurner
        returns (bool success)
    {
        _burnAll(msg.sender);
        return true;
    }

    function burnAllFrom(address _from)
        public
        ifBurner(_from)
        returns (bool success)
    {
        uint256 amount = _burnAll(_from);
        _approve(_from, msg.sender, allowed[_from][msg.sender].sub(amount));
        return true;
    }

    function removeBurner(address _addr)
        public
        onlyManager
    {
        _removeBurner(_addr);
    }

    function removeManager(address _addr)
        public
        onlySelf
    {
        _removeManager(_addr);
    }

    function renounceManager()
        public
    {
        _removeManager(msg.sender);
    }

    function _burn(address _from, uint256 _amount)
        internal
    {
        _collectFee(_from);

        balances[_from] = balances[_from].sub(_amount);
        if (balances[_from] == 0) holders.remove(_from);
        tokenTotalSupply = tokenTotalSupply.sub(_amount);

        emit Transfer(_from, address(0), _amount);
        emit Burn(_from, _amount);
    }

    function _burnAll(address _from)
        internal
        returns (uint256 amount)
    {
        _collectFee(_from);

        amount = balances[_from];
        balances[_from] = 0;
        holders.remove(_from);
        tokenTotalSupply = tokenTotalSupply.sub(amount);

        emit Transfer(_from, address(0), amount);
        emit Burn(_from, amount);
    }
}

contract ERC20Mintable is XBullionTokenConfig, ERC20WithFees, MinterRole {
    uint256 public mintCapacity;
    uint256 public amountMinted;
    uint public mintPeriod;
    uint public mintPeriodStart;

    event MintCapacity(uint256 amount);
    event MintPeriod(uint duration);

    constructor(uint256 _mintCapacity, uint _mintPeriod)
        public
    {
        _setMintCapacity(_mintCapacity);
        _setMintPeriod(_mintPeriod);
    }

    function addMinter(address _addr)
        public
        onlySelf
    {
        _addMinter(_addr);
    }

    function mint(address _to, uint256 _amount)
        public
    {
        if (msg.sender != address(this)) {
            require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
            require(isUnderMintLimit(_amount), "ERC20: exceeds minting capacity");
        }
        _mint(_to, _amount);
    }

    function removeMinter(address _addr)
        public
        onlySelf
    {
        _removeMinter(_addr);
    }

    function renounceMinter()
        public
        returns (bool)
    {
        _removeMinter(msg.sender);
        return true;
    }

    function setMintCapacity(uint256 _amount)
        public
        onlySelf
    {
        _setMintCapacity(_amount);
    }

    function setMintPeriod(uint _duration)
        public
        onlySelf
    {
        _setMintPeriod(_duration);
    }

    function _mint(address _to, uint256 _amount)
        internal
    {
        require(_to != address(0), "ERC20: mint to the zero address");
        require(_to != address(this), "ERC20: mint to token contract");

        _collectFee(_to);
        if (now > mintPeriodStart + mintPeriod) {
            amountMinted = 0;
            mintPeriodStart = now;
        }
        amountMinted = amountMinted.add(_amount);
        tokenTotalSupply = tokenTotalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        if (balances[_to] > 0) holders.insert(_to);

        emit Transfer(address(0), _to, _amount);
        emit Mint(_to, _amount);
    }

    function _setMintCapacity(uint256 _amount)
        internal
    {
        mintCapacity = _amount;
        emit MintCapacity(_amount);
    }

    function _setMintPeriod(uint _duration)
        internal
    {
        require(_duration < (1 << 64),
                "ERC20: mint period must be less than 2^64 seconds");
        mintPeriod = _duration;
        emit MintPeriod(_duration);
    }

    function isUnderMintLimit(uint256 _amount)
        internal
        view
        returns (bool)
    {
        uint256 effAmountMinted = (now > mintPeriodStart + mintPeriod) ? 0 : amountMinted;
        if (effAmountMinted + _amount > mintCapacity
            || effAmountMinted + _amount < amountMinted) {
            return false;
        }
        return true;
    }

    function remainingMintCapacity()
        public
        view
        returns (uint256)
    {
        if (now > mintPeriodStart + mintPeriod)
            return mintCapacity;
        if (mintCapacity < amountMinted)
            return 0;
        return mintCapacity - amountMinted;
    }
}

contract XBullionToken is XBullionTokenConfig, ERC20Burnable, ERC20Mintable {
    constructor()
        MultiOwned(
            makeAddressSingleton(msg.sender),
            1)
        ERC20(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_DECIMALS,
            TOKEN_INITIALSUPPLY)
        ERC20WithFees(
            initialFeeTiers(),
            initialTxFee())
        ERC20Mintable(
            TOKEN_MINTCAPACITY,
            TOKEN_MINTPERIOD)
        public
    {}
}