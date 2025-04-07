/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;




contract ZoraProxyStorage {

    address public implementation;
    address public admin;

    modifier onlyAdmin() {
        require(
            admin == msg.sender,
            "ZoraProxyStorage: only admin"
        );
        _;
    }
}

contract PermittableUpgradeSafe is ZoraProxyStorage {

    /* ============ Variables ============ */

    bytes32 public DOMAIN_SEPARATOR;

    mapping (address => uint256) public permitNonces;

    /* ============ Constants ============ */

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    /* ============ Constructor ============ */

    function configure(
        string memory name,
        string memory version
    )
    public
    onlyAdmin
    {
        DOMAIN_SEPARATOR = initDomainSeparator(name, version);
    }

    /**
     * @dev Initializes EIP712 DOMAIN_SEPARATOR based on the current contract and chain ID.
     */
    function initDomainSeparator(
        string memory name,
        string memory version
    )
    internal
    returns (bytes32)
    {
        uint256 chainID;
        /* solium-disable-next-line */
        assembly {
            chainID := chainid()
        }

        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainID,
                address(this)
            )
        );
    }

    /**
    * @dev Approve by signature.
    *
    * Adapted from Uniswap's UniswapV2ERC20 and MakerDAO's Dai contracts:
    * https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol
    * https://github.com/makerdao/dss/blob/master/src/dai.sol
    */
    function _permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
    public
    virtual
    {

        require(
            deadline == 0 || deadline >= block.timestamp,
            "Permittable: Permit expired"
        );

        require(
            spender != address(0),
            "Permittable: spender cannot be 0x0"
        );

        require(
            value > 0,
            "Permittable: approval value must be greater than 0"
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        permitNonces[owner]++,
                        deadline
                    )
                )
            ));

        address recoveredAddress = ecrecover(digest, v, r, s);

        require(
            recoveredAddress != address(0) && owner == recoveredAddress,
            "Permittable: Signature invalid"
        );

    }

}





contract BaseERC20UpgradeSafe is ZoraProxyStorage, IERC20 {
    using SafeMath for uint256;

    // ============ Variables ============

    string internal _name;
    string internal _symbol;
    uint256 internal _supply;
    uint8 internal _decimals;

    mapping (address => uint256) private  _balances;
    mapping (address => mapping(address => uint256)) private _allowances;

    function configure(
        string memory name,
        string memory symbol,
        uint8 decimals
    )
        public
        onlyAdmin
    {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    // ============ Public Functions ============

    function symbol()
        public
        view
        returns (string memory)
    {
        return _symbol;
    }

    function name()
        public
        view
        returns (string memory)
    {
        return _name;
    }

    function decimals()
        public
        virtual
        view
        returns (uint8)
    {
        return _decimals;
    }

    function totalSupply()
        public
        override
        view
        returns (uint256)
    {
        return _supply;
    }

    function balanceOf(
        address who
    )
        public
        override
        view returns (uint256)
    {
        return _balances[who];
    }

    function allowance(
        address owner,
        address spender
    )
        public
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    // ============ Internal Functions ============

    function _mint(address to, uint256 value) internal {
        require(to != address(0), "Cannot mint to zero address");

        _balances[to] = _balances[to].add(value);
        _supply = _supply.add(value);

        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        require(from != address(0), "Cannot burn to zero");

        _balances[from] = _balances[from].sub(value);
        _supply = _supply.sub(value);

        emit Transfer(from, address(0), value);
    }

    // ============ Token Functions ============

    function transfer(
        address to,
        uint256 value
    )
        public
        override
        virtual
        returns (bool)
    {
        if (_balances[msg.sender] >= value) {
            _balances[msg.sender] = _balances[msg.sender].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(msg.sender, to, value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        virtual
        returns (bool)
    {
        if (
            _balances[from] >= value &&
            _allowances[from][msg.sender] >= value
        ) {
            _balances[to] = _balances[to].add(value);
            _balances[from] = _balances[from].sub(value);
            _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(
                value
            );
            emit Transfer(from, to, value);
            return true;
        } else {
            return false;
        }
    }

    function approve(
        address spender,
        uint256 value
    )
        public
        override
        returns (bool)
    {
        return _approve(msg.sender, spender, value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    )
        internal
        returns (bool)
    {
        _allowances[owner][spender] = value;

        emit Approval(
            owner,
            spender,
            value
        );

        return true;
    }
}

contract ZoraTokenStorageV1 {
    uint256 public STARTING_SUPPLY;
}

// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract OwnableUpgradeSafe is ZoraProxyStorage, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function configure() public onlyAdmin {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BondingToken is ZoraProxyStorage, BaseERC20UpgradeSafe, OwnableUpgradeSafe, PermittableUpgradeSafe, ZoraTokenStorageV1 {
    function configure(
        string memory name,
        string memory symbol,
        uint8 decimals,
        string memory version,
        uint256 supply
    ) public onlyAdmin {

        // BaseERC20
        BaseERC20UpgradeSafe.configure(name, symbol, decimals);

        // Ownable
        OwnableUpgradeSafe.configure();

        // Permittable
        PermittableUpgradeSafe.configure(name, version);

        // TODO should this be moved out so we don't accidentally mint twice?
        // Custom
        _mint(msg.sender, supply);
        STARTING_SUPPLY = supply;
    }

    /* ============ View Functions ============ */

    function startingSupply()
        public
        view
        returns (uint256)
    {
        return STARTING_SUPPLY;
    }

    /* ============ Public Fuctions ============ */

    /**
    * @dev Approve by signature.
    *
    * Adapted from Uniswap's UniswapV2ERC20 and MakerDAO's Dai contracts:
    * https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol
    * https://github.com/makerdao/dss/blob/master/src/dai.sol
    */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
    {
        _permit(
            owner,
            spender,
            value,
            deadline,
            v,
            r,
            s
        );
        _approve(owner, spender, value);
    }

    /**
     * @dev Mint tokens
     *
     * @param to The address to mint tokens to
     * @param value The number of tokens to burn
     */
    function mint(
        address to,
        uint256 value
    )
        public
        onlyOwner
    {
        _mint(to, value);
    }

    /**
     * @dev Burn tokens when redemptions occur
     *
     * @param from The address to burn tokens from
     * @param value The number of tokens to burn
     */
    function burn(
        address from,
        uint256 value
    )
        public
        onlyOwner
    {
        _burn(from, value);
    }

}