/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

pragma solidity =0.8.0;







contract ERC20ToBEP20Wrapper is Ownable {
    struct UnwrapInfo {
        uint amount;
        uint fee;
        uint bscNonce;
    }

    IERC20 public immutable NBU;
    uint public minWrapAmount;

    mapping(address => uint) public userWrapNonces;
    mapping(address => uint) public userUnwrapNonces;
    mapping(address => mapping(uint => uint)) public bscToEthUserUnwrapNonces;
    mapping(address => mapping(uint => uint)) public wraps;
    mapping(address => mapping(uint => UnwrapInfo)) public unwraps;

    event Wrap(address indexed user, uint indexed wrapNonce, uint amount);
    event Unwrap(address indexed user, uint indexed unwrapNonce, uint indexed bscNonce, uint amount, uint fee);
    event UpdateMinWrapAmount(uint indexed amount);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address token, address indexed to, uint amount);

    constructor(address nbu) {
        NBU = IERC20(nbu);
    }
    
    function wrap(uint amount) external {
        require(amount >= minWrapAmount, "ERC20ToBEP20Wrapper: Value too small");
        
        NBU.transferFrom(msg.sender, address(this), amount);
        uint userWrapNonce = ++userWrapNonces[msg.sender];
        wraps[msg.sender][userWrapNonce] = amount;
        emit Wrap(msg.sender, userWrapNonce, amount);
    }

    function unwrap(address user, uint amount, uint fee, uint bscNonce) external onlyOwner {
        require(user != address(0), "ERC20ToBEP20Wrapper: Can't be zero address");
        require(bscToEthUserUnwrapNonces[user][bscNonce] == 0, "ERC20ToBEP20Wrapper: Already processed");
        
        NBU.transfer(user, amount - fee);
        uint unwrapNonce = ++userUnwrapNonces[user];
        bscToEthUserUnwrapNonces[user][bscNonce] = unwrapNonce;
        unwraps[user][unwrapNonce].amount = amount;
        unwraps[user][unwrapNonce].fee = fee;
        unwraps[user][unwrapNonce].bscNonce = bscNonce;
        emit Unwrap(user, unwrapNonce, bscNonce, amount, fee);
    }

    //Admin functions
    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "ERC20ToBEP20Wrapper: Can't be zero address");
        require(amount > 0, "ERC20ToBEP20Wrapper: Should be greater than 0");
        TransferHelper.safeTransferETH(to, amount);
        emit Rescue(to, amount);
    }

    function rescue(address to, address token, uint256 amount) external onlyOwner {
        require(to != address(0), "ERC20ToBEP20Wrapper: Can't be zero address");
        require(amount > 0, "ERC20ToBEP20Wrapper: Should be greater than 0");
        TransferHelper.safeTransfer(token, to, amount);
        emit RescueToken(token, to, amount);
    }

    function updateMinWrapAmount(uint amount) external onlyOwner {
        require(amount > 0, "ERC20ToBEP20Wrapper: Should be greater than 0");
        minWrapAmount = amount;
        emit UpdateMinWrapAmount(amount);
    }
}