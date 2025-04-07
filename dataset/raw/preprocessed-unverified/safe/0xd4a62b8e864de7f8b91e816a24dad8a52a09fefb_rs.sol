/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

pragma solidity 0.5.7;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


contract MerkleAirdrop is Ownable {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    uint public constant cap = 10000;
    bytes32 public merkleRoot;
    uint256 public vestingTimeInSeconds;
    uint256 public startTimestamp = 0;
    uint256 public minimumSwapPercentage;

    IERC20 public tokenContract = 
        IERC20(0x147faF8De9d8D8DAAE129B187F0D02D819126750);

    mapping (address => bool) spent;
    event Claimed(
        address indexed beneficiary,
        address indexed sender, 
        uint256 claimed, 
        uint256 unclaimed
    );

    event TokenChanged(
        address sender,
        address tokenAddress
    );

    event RootChanged(
        address sender,
        bytes32 merkleRoot
    );

    event VestingTimeChanged(
        address sender,
        uint256 vestingTimeInSeconds
    );

    event StartTimestampChanged(
        address sender,
        uint256 startTimestamp
    );

    constructor(bytes32 _merkleRoot, uint256 _vestingTimeInSeconds, uint256 _minimumSwapPercentage) public {
        merkleRoot = _merkleRoot;
        vestingTimeInSeconds = _vestingTimeInSeconds;
        minimumSwapPercentage = _minimumSwapPercentage;
    }

    function setTokenContract(address _tokenAddress) external onlyOwner {
        tokenContract = IERC20(_tokenAddress);
        emit TokenChanged(msg.sender, _tokenAddress);
    }

    function setRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
        emit RootChanged(msg.sender, _merkleRoot);
    }

    function setVestingTime(uint256 _vestingTimeInSeconds) external onlyOwner {
        vestingTimeInSeconds = _vestingTimeInSeconds;
        emit VestingTimeChanged(msg.sender, _vestingTimeInSeconds);
    }

    function setStartTimestamp(uint256 _startTimestamp) external onlyOwner {
        require(_startTimestamp >= block.timestamp, 'Start timestamp can not be higher than current timestamp');
        startTimestamp = _startTimestamp;
        emit StartTimestampChanged(msg.sender, _startTimestamp);
    }

    function isAddressAlreadyClaimed(address who) external view returns (bool) {
        return spent[who];
    }

    function claimRestTokensAndDestruct() external onlyOwner {
        address payable payableOwner = address(uint160(owner()));
        tokenContract.transfer(owner(), tokenContract.balanceOf(address(this)));
        selfdestruct(payableOwner);
    }

    function sendRestTokensAndDestruct(address payable recipient) external onlyOwner {
        tokenContract.transfer(recipient, tokenContract.balanceOf(address(this)));
        selfdestruct(recipient);
    }

    function getTokensByMerkleProof(bytes32[] calldata _proof, address _who, uint256 _amount) external returns(uint256) {
        require(!spent[_who], "User has already retrieved its tokens");
        require(_amount > 0, "Amount is 0 or less");
        require(msg.sender == _who, "Message sender is not recipient");
        require(startTimestamp > 0, "Start timestamp is not set");

        return verifyAndSendTokens(_proof, _who, _amount, _who);
    }

    function getTokensByMerkleProofFrom(bytes32[] calldata _proof, bytes calldata signature, address _who, uint256 _amount) external returns(uint256) {
        require(!spent[_who], "User has already retrieved its tokens");
        require(_amount > 0, "Amount is 0 or less");
        bytes32 ethHash = keccak256(abi.encodePacked(msg.sender)).toEthSignedMessageHash();
        require(ethHash.recover(signature) == _who, "Signature is not correct");
        require(startTimestamp > 0, "Start timestamp is not set");

        return verifyAndSendTokens(_proof, _who, _amount, msg.sender);
    }

    function getVestingPercentage() public view returns (uint256) {

        uint _startTimestamp = startTimestamp;
        if(_startTimestamp == 0) {
            return 0;
        }
        
        uint _cap = cap;
        uint256 contractDeployedTime = block.timestamp - _startTimestamp;

        if (contractDeployedTime >= vestingTimeInSeconds){
            return _cap;
        }

        uint256 percentageContractDeployedTime = 
            (contractDeployedTime.mul(_cap)).div(vestingTimeInSeconds);
        

        uint256 biQuadraticPercentage = 
            (percentageContractDeployedTime
                .mul(percentageContractDeployedTime)
                .mul(percentageContractDeployedTime)
                .mul(percentageContractDeployedTime)
                .div(1000000000000)
            ).add(minimumSwapPercentage);
        
        // Not covered by solcover. Probably unreachable code
        if (biQuadraticPercentage > _cap) {
            biQuadraticPercentage = _cap;
        }
        return biQuadraticPercentage;
    }

    function verifyAndSendTokens(bytes32[] memory _proof, address _who, uint256 _amount, address recipient) private returns(uint256){
        //Generating proof
        bytes32 computedHash = keccak256(abi.encodePacked(_who, _amount));

        for (uint i = 0; i < _proof.length; i++) {
            bytes32 proofElement = _proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        //Verify proof
        require(computedHash == merkleRoot, "Bad proof given");

        spent[_who] = true;
        uint256 biQuadraticPercentage = getVestingPercentage();
        uint256 mainTokensUser = (_amount.mul(biQuadraticPercentage)).div(cap);
        uint256 mainTokensLeft = _amount.sub(mainTokensUser);
        tokenContract.transfer(recipient, mainTokensUser);
        if (mainTokensLeft > 0) {
            tokenContract.transfer(owner(), mainTokensLeft);
        }
        emit Claimed(_who, msg.sender, mainTokensUser, mainTokensLeft);
        return mainTokensUser;
    }
}

contract MerkleAirdropFinal is MerkleAirdrop {
    constructor() MerkleAirdrop(bytes32(0), 365 days, 500) public {}
}