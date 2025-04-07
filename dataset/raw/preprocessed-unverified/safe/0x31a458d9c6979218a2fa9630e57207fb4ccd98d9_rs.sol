/**
 *Submitted for verification at Etherscan.io on 2019-10-14
*/

pragma solidity ^0.5.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */



/**
 * @title Math
 * @dev Assorted math operations
 */



/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */



contract DepositorRole {
  using Roles for Roles.Role;

  event DepositorAdded(address indexed account);
  event DepositorRemoved(address indexed account);

  Roles.Role private depositors;

  constructor() internal {
    _addDepositor(msg.sender);
  }

  modifier onlyDepositor() {
    require(isDepositor(msg.sender));
    _;
  }

  function isDepositor(address account) public view returns (bool) {
    return depositors.has(account);
  }

  function addDepositor(address account) public onlyDepositor {
    _addDepositor(account);
  }

  function renounceDepositor() public {
    _removeDepositor(msg.sender);
  }

  function _addDepositor(address account) internal {
    depositors.add(account);
    emit DepositorAdded(account);
  }

  function _removeDepositor(address account) internal {
    depositors.remove(account);
    emit DepositorRemoved(account);
  }
}


contract TraderRole {
  using Roles for Roles.Role;

  event TraderAdded(address indexed account);
  event TraderRemoved(address indexed account);

  Roles.Role private traders;

  constructor() internal {
    _addTrader(msg.sender);
  }

  modifier onlyTrader() {
    require(isTrader(msg.sender));
    _;
  }

  function isTrader(address account) public view returns (bool) {
    return traders.has(account);
  }

  function addTrader(address account) public onlyTrader {
    _addTrader(account);
  }

  function renounceTrader() public {
    _removeTrader(msg.sender);
  }

  function _addTrader(address account) internal {
    traders.add(account);
    emit TraderAdded(account);
  }

  function _removeTrader(address account) internal {
    traders.remove(account);
    emit TraderRemoved(account);
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @notice Token bank contract
 * @dev To use Token Bank, mint ERC20 tokens for this contract
 */
contract TokenBank is Ownable, DepositorRole, TraderRole {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // this token bank contract will use this binded ERC20 token
    IERC20 public bindedToken;

    // use deposited[user] to get the deposited ERC20 tokens
    mapping(address => uint256) public deposited;

    // address of fee collector
    address public feeCollector;
   
    event TokenBinded(
        address indexed binder,
        address indexed previousToken,
        address indexed newToken
    );

    event FeeCollectorSet(
        address indexed setter,
        address indexed previousFeeCollector,
        address indexed newFeeCollector
    );

    event FeeCollected(
        address indexed collector,
        address indexed collectTo,
        uint256 amount
    );

    event Deposited(
        address indexed depositor,
        address indexed receiver,
        uint256 amount,
        uint256 balance
    );

    event BulkDeposited(
        address indexed trader,
        uint256 totalAmount,
        uint256 requestNum
    );

    event Withdrawn(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 fee,
        uint256 balance
    );

    event BulkWithdrawn(
        address indexed trader,
        uint256 requestNum
    );

    event Transferred(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 fee,
        uint256 balance
    );

    event BulkTransferred(
        address indexed trader,
        uint256 requestNum
    );

    /**
     * @param addrs addrs[0]: ERC20; addrs[1]: fee collector
     */
    constructor(
        address[] memory addrs
    )
        public
    {
        bindedToken = IERC20(addrs[0]);
        feeCollector = addrs[1];
    }

    /**
     * @param token Address of ERC20 token to bind for bank
     */
    function bindToken(address token) external onlyOwner {
        emit TokenBinded(msg.sender, address(bindedToken), token);
        bindedToken = IERC20(token);
    }

    /**
     * @param collector New fee collector
     */
    function setFeeCollector(address collector) external onlyOwner {
        emit FeeCollectorSet(msg.sender, feeCollector, collector);
        feeCollector = collector;
    }

    /**
     * @dev Collect fee from Token Bank to ERC20 token
     */
    function collectFee() external onlyOwner {
        uint256 amount = deposited[feeCollector];
        deposited[feeCollector] = 0;
        emit FeeCollected(msg.sender, feeCollector, amount);
        bindedToken.safeTransfer(feeCollector, amount);
    }

    /**
     * @notice Deposit ERC20 token to receiver address
     * @param receiver Address of who will receive the deposited tokens
     * @param amount Amount of ERC20 token to deposit
     */
    function depositTo(address receiver, uint256 amount) external onlyDepositor {
        deposited[receiver] = deposited[receiver].add(amount);
        emit Deposited(msg.sender, receiver, amount, deposited[receiver]);
        bindedToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice Bulk deposit tokens to multiple receivers
     * @param receivers Addresses of receivers
     * @param amounts Individual amounts to deposit for receivers
     */
    function bulkDeposit(
        address[] calldata receivers,
        uint256[] calldata amounts
    )
        external
        onlyDepositor
    {
        require(
            receivers.length == amounts.length,
            "Failed to bulk deposit due to illegal arguments."
        );

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i = i.add(1)) {
            // accumulate total amount of tokens to transfer in token bank
            totalAmount = totalAmount.add(amounts[i]);
            // deposit tokens to token bank accounts
            deposited[receivers[i]] = deposited[receivers[i]].add(amounts[i]);
            emit Deposited(
                msg.sender, 
                receivers[i], 
                amounts[i],
                deposited[receivers[i]]
            );
        }
        emit BulkDeposited(msg.sender, totalAmount, receivers.length);

        // if transfer fails, deposits will revert accordingly 
        bindedToken.safeTransferFrom(msg.sender, address(this), totalAmount);  
    }

    /**
     * @notice withdraw tokens from token bank to specific receiver
     * @param from Token will withdraw from this address
     * @param to Withdrawn token transfer to this address
     * @param amount Amount of ERC20 token to withdraw
     * @param fee Withdraw fee
     */
    function _withdraw(address from, address to, uint256 amount, uint256 fee) private {
        deposited[feeCollector] = deposited[feeCollector].add(fee);
        uint256 total = amount.add(fee);
        deposited[from] = deposited[from].sub(total);
        emit Withdrawn(from, to, amount, fee, deposited[from]);
        bindedToken.safeTransfer(to, amount);
    }

    /**
     * @notice Bulk withdraw tokens from token bank
     * @dev Withdraw request will handle by off-chain API
     * @dev Arguments must merge into arrays due to "Stack too deep" error
     * @param nums See ./docs/nums.bulkWithdraw.param
     * @param addrs See ./docs/addrs.bulkWithdraw.param
     * @param rsSigParams See ./docs/rsSigParams.bulkWithdraw.param
     */
    function bulkWithdraw(
        uint256[] calldata nums,
        address[] calldata addrs,
        bytes32[] calldata rsSigParams
    )
        external
        onlyTrader
    {
        // length of nums = 4 * withdraw requests
        uint256 total = nums.length.div(4);
        require(
            (total > 0) 
            && (total.mul(4) == nums.length)
            && (total.mul(2) == addrs.length)
            && (total.mul(2) == rsSigParams.length),
            "Failed to bulk withdraw due to illegal arguments."
        );

        // handle withdraw requests one after another
        for (uint256 i = 0; i < total; i = i.add(1)) {
            _verifyWithdrawSigner(
                addrs[i.mul(2)],               // withdraw from (also signder)
                addrs[(i.mul(2)).add(1)],      // withdraw to
                nums[i.mul(4)],                // withdraw amount
                nums[(i.mul(4)).add(1)],       // withdraw fee
                nums[(i.mul(4)).add(2)],       // withdraw timestamp
                nums[(i.mul(4)).add(3)],       // signature param: v
                rsSigParams[i.mul(2)],         // signature param: r
                rsSigParams[(i.mul(2)).add(1)] // signature param: s
            );

            _withdraw(
                addrs[i.mul(2)],          // withdraw from
                addrs[(i.mul(2)).add(1)], // withdraw to
                nums[i.mul(4)],           // withdraw amount
                nums[(i.mul(4)).add(1)]   // withdraw fee
            );
        }
        emit BulkWithdrawn(msg.sender, total);
    }

    /**
     * @notice Verify withdraw request signer
     * @dev Request signer must be owner of deposit account
     * @param from Token will withdraw from this address
     * @param to Token will withdraw into this address
     * @param amount Amount of token to withdraw
     * @param fee Withdraw fee
     * @param timestamp Withdraw request timestamp
     * @param v Signature parameter: v
     * @param r Signature parameter: r
     * @param s Signature parameter: s
     */
    function _verifyWithdrawSigner(
        address from,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 timestamp,
        uint256 v,
        bytes32 r,
        bytes32 s
    )
        private
        view
    {
        bytes32 hashed = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", 
                keccak256(
                    abi.encodePacked(
                        address(this), 
                        from, 
                        to, 
                        amount,
                        fee,
                        timestamp
                    )
                )
            )
        );

        require(
            ecrecover(hashed, uint8(v), r, s) == from,
            "Failed to withdraw due to request was not signed by singer."
        );
    }

    /**
     * @notice Bulk transfer tokens in token bank
     * @dev Transfer request will handle by off-chain API
     * @dev Arguments must merge into arrays due to "Stack too deep" error
     * @param nums See ./docs/nums.bulkTransfer.param
     * @param addrs See ./docs/addrs.bulkTransfer.param
     * @param rsSigParams See ./docs/rsSigParams.bulkTransfer.param
     */
    function bulkTransfer(
        uint256[] calldata nums,
        address[] calldata addrs,
        bytes32[] calldata rsSigParams
    )
        external
        onlyTrader
    {
        // length of nums = 4 * transfer requests
        uint256 total = nums.length.div(4);
        require(
            (total > 0) 
            && (total.mul(4) == nums.length)
            && (total.mul(2) == addrs.length)
            && (total.mul(2) == rsSigParams.length),
            "Failed to bulk transfer due to illegal arguments."
        );

        // handle transfer requests one after another
        for (uint256 i = 0; i < total; i = i.add(1)) {
            _verifyTransferSigner(
                addrs[i.mul(2)],               // transfer from (also signder)
                addrs[(i.mul(2)).add(1)],      // transfer to
                nums[i.mul(4)],                // transfer amount
                nums[(i.mul(4)).add(1)],       // transfer fee
                nums[(i.mul(4)).add(2)],       // transfer timestamp
                nums[(i.mul(4)).add(3)],       // signature param: v
                rsSigParams[i.mul(2)],         // signature param: r
                rsSigParams[(i.mul(2)).add(1)] // signature param: s
            );

            _transfer(
                addrs[i.mul(2)],          // transfer from
                addrs[(i.mul(2)).add(1)], // transfer to
                nums[i.mul(4)],           // transfer amount
                nums[(i.mul(4)).add(1)]   // transfer fee
            );
        }
        emit BulkTransferred(msg.sender, total);
    }

    /**
     * @dev Admin function: Transfer token in token bank
     * @param from Token transfer from this address
     * @param to Token transfer to this address
     * @param amount Amount of token to transfer
     * @param fee Transfer fee
     */
    function transfer(
        address from,
        address to,
        uint256 amount,
        uint256 fee
    )
        external
        onlyOwner
    {
        _transfer(from, to, amount, fee);
    }

    /**
     * @dev Transfer token in token bank
     * @param from Token transfer from this address
     * @param to Token transfer to this address
     * @param amount Amount of token to transfer
     * @param fee Transfer fee
     */
    function _transfer(
        address from,
        address to,
        uint256 amount,
        uint256 fee
    )
        private
    {
        require(to != address(0));
        uint256 total = amount.add(fee);
        require(total <= deposited[from]);
        deposited[from] = deposited[from].sub(total);
        deposited[feeCollector] = deposited[feeCollector].add(fee);
        deposited[to] = deposited[to].add(amount);
        emit Transferred(from, to, amount, fee, deposited[from]);
    }

    /**
     * @notice Verify transfer request signer
     * @dev Request signer must be owner of deposit account
     * @param from Token will transfer from this address
     * @param to Token will transfer into this address
     * @param amount Amount of token to transfer
     * @param fee Transfer fee
     * @param timestamp Transfer request timestamp
     * @param v Signature parameter: v
     * @param r Signature parameter: r
     * @param s Signature parameter: s
     */
    function _verifyTransferSigner(
        address from,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 timestamp,
        uint256 v,
        bytes32 r,
        bytes32 s
    )
        private
        view
    {
        bytes32 hashed = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", 
                keccak256(
                    abi.encodePacked(
                        address(this), 
                        from, 
                        to, 
                        amount,
                        fee,
                        timestamp
                    )
                )
            )
        );

        require(
            ecrecover(hashed, uint8(v), r, s) == from,
            "Failed to transfer due to request was not signed by singer."
        );
    }
}