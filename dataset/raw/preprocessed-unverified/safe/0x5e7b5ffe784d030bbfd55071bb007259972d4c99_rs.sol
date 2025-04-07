/**
 *Submitted for verification at Etherscan.io on 2021-04-20
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

pragma solidity ^0.6.0;








abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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



contract ClaimContract is Ownable{

    using MerkleProof for bytes;
    uint256 claimIteration = 0;
    address ERC20_CONTRACT;
    bytes32 public merkleRoot;
    mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;
    
    event Claimed(uint256 index, address sender, uint256 amount);

    constructor(address contractAddress) public Ownable(){
        ERC20_CONTRACT = contractAddress;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimIteration][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimIteration][claimedWordIndex] = claimedBitMap[claimIteration][claimedWordIndex] | (1 << claimedBitIndex);
    }

    function updateMerkleRootHash(bytes32 root) public onlyOwner{
        merkleRoot=root;
        claimIteration++;
    }   

    function updateContractAddress(address contractAddress) public onlyOwner{
        ERC20_CONTRACT = contractAddress;
    } 

    function fundsInContract() public view returns(uint256){
        return IERC20(ERC20_CONTRACT).balanceOf(address(this));
    }

    function withdrawALT() public onlyOwner{
        IERC20(ERC20_CONTRACT).transfer(msg.sender,IERC20(ERC20_CONTRACT).balanceOf(address(this)));
    }

    function claim(uint256 index,address account,uint256 amount, bytes32[] calldata merkleProof) external{
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20(ERC20_CONTRACT).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }
}