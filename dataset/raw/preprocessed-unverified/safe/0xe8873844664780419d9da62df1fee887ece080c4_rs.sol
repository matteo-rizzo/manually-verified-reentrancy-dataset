/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity ^0.5.0;























contract Mixer

{

    using MerkleTree for MerkleTree.Data;



    uint constant public AMOUNT = 1 ether;



    uint256[14] vk;

    uint256[] gammaABC;



    mapping (uint256 => bool) public nullifiers;

    mapping (address => uint256[]) public pendingDeposits;



    MerkleTree.Data internal tree;



    event CommitmentAdded(address indexed _fundingWallet, uint256 _leaf);

    event LeafAdded(uint256 _leaf, uint256 _leafIndex);



    constructor(uint256[14] memory in_vk, uint256[] memory in_gammaABC)

        public

    {

        vk = in_vk;

        gammaABC = in_gammaABC;

    }



    function getRoot()

        public

        view

        returns (uint256)

    {

        return tree.getRoot();

    }



    /**

    * Save a commitment (leaf) that needs to be funded later on

    */

    function commit(uint256 leaf, address fundingWallet)

        public

        payable

    {

        require(leaf > 0, "null leaf");

        pendingDeposits[fundingWallet].push(leaf);

        emit CommitmentAdded(fundingWallet, leaf);

        if (msg.value > 0) fundCommitment();

    }



    function fundCommitment() private {

        require(msg.value == AMOUNT, "wrong value");

        uint256[] storage leaves = pendingDeposits[msg.sender];

        require(leaves.length > 0, "commitment must be sent first");

        uint256 leaf = leaves[leaves.length - 1];

        leaves.length--;

        (, uint256 leafIndex) = tree.insert(leaf);

        emit LeafAdded(leaf, leafIndex);

    }



    /*

    * Used by the funding wallet to fund a previously saved commitment

    */

    function () external payable {

        fundCommitment();

    }



    // should not be used in production otherwise nullifier_secret would be shared with the node!

    function makeLeafHash(uint256 nullifier_secret, address wallet_address)

        external

        pure

        returns (uint256)

    {

        bytes32 digest = sha256(abi.encodePacked(nullifier_secret, uint256(wallet_address)));

        uint256 mask = uint256(-1) >> 4; // clear the first 4 bits to make sure we stay within the prime field

        return uint256(digest) & mask;

    }



    // should not be used in production otherwise nullifier_secret would be shared with the node!

    function makeNullifierHash(uint256 nullifier_secret)

        external

        pure

        returns (uint256)

    {

        uint256[] memory vals = new uint256[](2);

        vals[0] = nullifier_secret;

        vals[1] = nullifier_secret;

        return MiMC.Hash(vals, 0);

    }



    function getMerklePath(uint256 leafIndex)

        external

        view

        returns (uint256[15] memory out_path)

    {

        out_path = tree.getMerkleProof(leafIndex);

    }



    function isSpent(uint256 nullifier)

        public

        view

        returns (bool)

    {

        return nullifiers[nullifier];

    }



    function verifyProof(uint256 in_root, address in_wallet_address, uint256 in_nullifier, uint256[8] memory proof)

        public

        view

        returns (bool)

    {

        uint256[] memory snark_input = new uint256[](3);

        snark_input[0] = in_root;

        snark_input[1] = uint256(in_wallet_address);

        snark_input[2] = in_nullifier;



        return Verifier.verify(vk, gammaABC, proof, snark_input);

    }



    function withdraw(

        address payable in_withdraw_address,

        uint256 in_nullifier,

        uint256[8] memory proof

    )

        public

    {

        uint startGas = gasleft();

        require(!nullifiers[in_nullifier], "Nullifier used");

        require(verifyProof(getRoot(), in_withdraw_address, in_nullifier, proof), "Proof verification failed");



        nullifiers[in_nullifier] = true;



        uint gasUsed = startGas - gasleft() + 82775;

        in_withdraw_address.transfer(AMOUNT - gasUsed * tx.gasprice); // leaf withdrawal

        msg.sender.transfer(gasUsed * tx.gasprice); // relayer refund

    }



    function treeDepth() external pure returns (uint256) {

        return MerkleTree.treeDepth();

    }



    function getNextLeafIndex() external view returns (uint256) {

        return tree.getNextLeafIndex();

    }

}