/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */


contract Drop {
    using MerkleProof for bytes;
    using SafeERC20 for IERC20;

    struct DropData {
        uint256 startDate;
        uint256 endDate;
        uint256 tokenAmount;
        address owner;
        bool isActive;
    }

    address public factory;
    address public token;

    mapping(bytes32 => DropData) public dropData;
    mapping(bytes32 => mapping(uint256 => uint256)) private claimedBitMap;

    constructor() {
        factory = msg.sender;
    }

    modifier onlyFactory {
        require(msg.sender == factory, "DROP_ONLY_FACTORY");
        _;
    }

    function initialize(address tokenAddress) external onlyFactory {
        token = tokenAddress;
    }

    function addDropData(
        address owner,
        bytes32 merkleRoot,
        uint256 startDate,
        uint256 endDate,
        uint256 tokenAmount
    ) external onlyFactory {
        require(dropData[merkleRoot].startDate == 0, "DROP_EXISTS");
        require(endDate > block.timestamp, "DROP_INVALID_END_DATE");
        require(endDate > startDate, "DROP_INVALID_START_DATE");
        dropData[merkleRoot] = DropData(startDate, endDate, tokenAmount, owner, true);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        uint256 fee,
        address feeReceiver,
        bytes32 merkleRoot,
        bytes32[] calldata merkleProof
    ) external onlyFactory {
        DropData memory dd = dropData[merkleRoot];

        require(dd.startDate < block.timestamp, "DROP_NOT_STARTED");
        require(dd.endDate > block.timestamp, "DROP_ENDED");
        require(dd.isActive, "DROP_NOT_ACTIVE");
        require(!isClaimed(index, merkleRoot), "DROP_ALREADY_CLAIMED");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "DROP_INVALID_PROOF");

        // Calculate fees
        uint256 feeAmount = (amount * fee) / 10000;
        uint256 userReceivedAmount = amount - feeAmount;

        // Subtract from the drop amount
        dropData[merkleRoot].tokenAmount -= amount;

        // Mark it claimed and send the tokens.
        _setClaimed(index, merkleRoot);
        IERC20(token).safeTransfer(account, userReceivedAmount);
        
        if(feeAmount > 0) {
            IERC20(token).safeTransfer(feeReceiver, feeAmount);
        }
    }

    function withdraw(address account, bytes32 merkleRoot) external onlyFactory returns (uint256) {
        DropData memory dd = dropData[merkleRoot];
        require(dd.owner == account, "DROP_ONLY_OWNER");

        delete dropData[merkleRoot];

        IERC20(token).safeTransfer(account, dd.tokenAmount);
        return dd.tokenAmount;
    }

    function isClaimed(uint256 index, bytes32 merkleRoot) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[merkleRoot][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function pause(address account, bytes32 merkleRoot) external onlyFactory {
        DropData memory dd = dropData[merkleRoot];
        require(dd.owner == account, "NOT_OWNER");
        dropData[merkleRoot].isActive = false;
    }

    function unpause(address account, bytes32 merkleRoot) external onlyFactory {
        DropData memory dd = dropData[merkleRoot];
        require(dd.owner == account, "NOT_OWNER");
        dropData[merkleRoot].isActive = true;
    }

    function _setClaimed(uint256 index, bytes32 merkleRoot) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[merkleRoot][claimedWordIndex] = claimedBitMap[merkleRoot][claimedWordIndex] | (1 << claimedBitIndex);
    }
}





contract DropFactory is IDropFactory {
    using SafeERC20 for IERC20;

    uint256 public fee;
    address public feeReceiver;
    address public timelock;
    mapping(address => address) public drops;

    constructor(
        uint256 _fee,
        address _feeReceiver,
        address _timelock
    ) {
        fee = _fee;
        feeReceiver = _feeReceiver;
        timelock = _timelock;
    }

    modifier dropExists(address tokenAddress) {
        require(drops[tokenAddress] != address(0), "FACTORY_DROP_DOES_NOT_EXIST");
        _;
    }

    modifier onlyTimelock() {
        require(msg.sender == timelock, "FACTORY_ONLY_TIMELOCK");
        _;
    }

    function createDrop(address tokenAddress) external override {
        require(drops[tokenAddress] == address(0), "FACTORY_DROP_EXISTS");
        bytes memory bytecode = type(Drop).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tokenAddress));
        address dropAddress = Create2.deploy(0, salt, bytecode);
        Drop(dropAddress).initialize(tokenAddress);
        drops[tokenAddress] = dropAddress;
        emit DropCreated(dropAddress, tokenAddress);
    }

    function addDropData(
        uint256 tokenAmount,
        uint256 startDate,
        uint256 endDate,
        bytes32 merkleRoot,
        address tokenAddress
    ) external override dropExists(tokenAddress) {
        address dropAddress = drops[tokenAddress];
        IERC20(tokenAddress).safeTransferFrom(msg.sender, dropAddress, tokenAmount);
        Drop(dropAddress).addDropData(msg.sender, merkleRoot, startDate, endDate, tokenAmount);
        emit DropDataAdded(tokenAddress, merkleRoot, tokenAmount, startDate, endDate);
    }

    function claimFromDrop(
        address tokenAddress,
        uint256 index,
        uint256 amount,
        bytes32 merkleRoot,
        bytes32[] calldata merkleProof
    ) external override dropExists(tokenAddress) {
        Drop(drops[tokenAddress]).claim(index, msg.sender, amount, fee, feeReceiver, merkleRoot, merkleProof);
        emit DropClaimed(tokenAddress, index, msg.sender, amount, merkleRoot);
    }

    function multipleClaimsFromDrop(
        address tokenAddress,
        uint256[] calldata indexes,
        uint256[] calldata amounts,
        bytes32[] calldata merkleRoots,
        bytes32[][] calldata merkleProofs
    ) external override dropExists(tokenAddress) {
        uint256 tempFee = fee;
        address tempFeeReceiver = feeReceiver;
        for (uint256 i = 0; i < indexes.length; i++) {
            Drop(drops[tokenAddress]).claim(indexes[i], msg.sender, amounts[i], tempFee, tempFeeReceiver, merkleRoots[i], merkleProofs[i]);
            emit DropClaimed(tokenAddress, indexes[i], msg.sender, amounts[i], merkleRoots[i]);
        }
    }

    function withdraw(address tokenAddress, bytes32 merkleRoot) external override dropExists(tokenAddress) {
        uint256 withdrawAmount = Drop(drops[tokenAddress]).withdraw(msg.sender, merkleRoot);
        emit DropWithdrawn(tokenAddress, msg.sender, merkleRoot, withdrawAmount);
    }

    function updateFee(uint256 newFee) external override onlyTimelock {
        // max fee 20%
        require(newFee < 2000, "FACTORY_MAX_FEE_EXCEED");
        fee = newFee;
    }

    function updateFeeReceiver(address newFeeReceiver) external override onlyTimelock {
        feeReceiver = newFeeReceiver;
    }

    function pause(address tokenAddress, bytes32 merkleRoot) external override {
        Drop(drops[tokenAddress]).pause(msg.sender, merkleRoot);
        emit DropPaused(merkleRoot);
    }

    function unpause(address tokenAddress, bytes32 merkleRoot) external override {
        Drop(drops[tokenAddress]).unpause(msg.sender, merkleRoot);
        DropUnpaused(merkleRoot);
    }

    function getDropDetails(address tokenAddress, bytes32 merkleRoot)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            address,
            bool
        )
    {
        return Drop(drops[tokenAddress]).dropData(merkleRoot);
    }

    function isDropClaimed(
        address tokenAddress,
        uint256 index,
        bytes32 merkleRoot
    ) external view override dropExists(tokenAddress) returns (bool) {
        return Drop(drops[tokenAddress]).isClaimed(index, merkleRoot);
    }
}