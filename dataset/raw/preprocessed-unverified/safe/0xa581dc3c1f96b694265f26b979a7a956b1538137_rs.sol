/**
 *Submitted for verification at Etherscan.io on 2019-10-14
*/

pragma solidity 0.5.12;





contract ICErc20 {
    address public underlying;
    function mint(uint mintAmount) external returns (uint);
    function isCToken() external returns (bool);
    function exchangeRateCurrent() external returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);
    function redeem(uint amount) external returns (uint);
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "SafeMath: subtraction overflow");
        c = a - b;
    }

}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */




/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract CompoundFeeTransactionManager is Ownable, ReentrancyGuard, DSMath {
    
    IERC20 public token;
    ICErc20 public cToken;

    address public relayer;
    
    event NewRelayer(address _oldRelayer, address _newRelayer);
    event Mint(address indexed _sender, uint256 _value);
    event Redeem(address indexed _sender, uint256 _value);
    
    constructor (address _tokenAddress, address _cTokenAddress, address _relayer) public {
        require(_relayer != address(0));
        relayer = _relayer;
        cToken = ICErc20(_cTokenAddress);
        token = IERC20(_tokenAddress);
        require(cToken.isCToken());
        require(cToken.underlying() == _tokenAddress, "the underlying are different");
        
        token.approve(address(cToken), uint256(-1));
    }
    
    function mint(
        uint256 _value, 
        uint256 _fee, 
        bytes calldata _signature
    ) nonReentrant external {
        require(tx.origin == relayer, "Invalid transaction origin");
        Marmo marmo = Marmo(msg.sender);
        bytes32 hash = keccak256(
            abi.encodePacked(
                msg.sender,
                _value,
                _fee
            )
        );
        require(marmo.signer() == ECDSA.recover(hash, _signature), "Invalid signature");
    
        require(token.transferFrom(msg.sender, relayer, _fee), "the transferFrom method to relayer failed");
        require(token.transferFrom(msg.sender, address(this), _value), "Pull token failed");

        uint preMintBalance = cToken.balanceOf(address(this));
        require(cToken.mint(_value) == 0, "underlying mint failed");
        uint postMintBalance = cToken.balanceOf(address(this));

        uint mintedTokens = sub(postMintBalance, preMintBalance);
        require(cToken.transfer(msg.sender, mintedTokens), "The transfer method failed");
        
        emit Mint(msg.sender, mintedTokens);

    }
    
    function redeem(
        uint256 _value, 
        uint256 _fee, 
        bytes calldata _signature
    ) nonReentrant external {
        require(tx.origin == relayer, "Invalid transaction origin");
        Marmo marmo = Marmo(msg.sender);
        bytes32 hash = keccak256(
            abi.encodePacked(
                msg.sender,
                _value,
                _fee
            )
        );
        require(marmo.signer() == ECDSA.recover(hash, _signature), "Invalid signature");
        
        require(token.transferFrom(msg.sender, relayer, _fee));
    
        uint exchangeRate = cToken.exchangeRateCurrent();
        uint withdrawAmt = wdiv(_value, exchangeRate);
        
        require(cToken.transferFrom(msg.sender, address(this), withdrawAmt), "Pull token failed");
        uint preDaiBalance = token.balanceOf(address(this));
        require(cToken.redeem(withdrawAmt) == 0, "Underlying redeeming failed");
        uint postDaiBalance = token.balanceOf(address(this));

        uint redeemedDai = sub(postDaiBalance, preDaiBalance);

        token.transfer(msg.sender, redeemedDai);
        
        emit Redeem(msg.sender, redeemedDai);
    }
    
    function setRelayer(address _newRelayer) onlyOwner external {
        require(_newRelayer != address(0));
        emit NewRelayer(relayer, _newRelayer);
        relayer = _newRelayer;
    }
     
}