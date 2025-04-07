pragma solidity 0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/*
 * @title MerkleProof
 * @dev Merkle proof verification
 * @note Based on https://github.com/ameensol/merkle-tree-solidity/blob/master/src/MerkleProof.sol
 */


/**
 * @title MerkleMine
 * @dev Token distribution based on providing Merkle proofs of inclusion in genesis state to generate allocation
 */
contract MerkleMine {
    using SafeMath for uint256;

    // ERC20 token being distributed
    ERC20 public token;
    // Merkle root representing genesis state which encodes token recipients
    bytes32 public genesisRoot;
    // Total amount of tokens that can be generated
    uint256 public totalGenesisTokens;
    // Total number of recipients included in genesis state
    uint256 public totalGenesisRecipients;
    // Amount of tokens per recipient allocation. Equal to `totalGenesisTokens` / `totalGenesisRecipients`
    uint256 public tokensPerAllocation;
    // Minimum ETH balance threshold for recipients included in genesis state
    uint256 public balanceThreshold;
    // Block number of genesis - used to determine which ETH accounts are included in the genesis state
    uint256 public genesisBlock;
    // Start block where a third party caller (not the recipient) can generate and split the allocation with the recipient
    // As the current block gets closer to `callerAllocationEndBlock`, the caller receives a larger precentage of the allocation
    uint256 public callerAllocationStartBlock;
    // From this block onwards, a third party caller (not the recipient) can generate and claim the recipient's full allocation
    uint256 public callerAllocationEndBlock;
    // Number of blocks in the caller allocation period as defined by `callerAllocationEndBlock` - `callerAllocationStartBlock`
    uint256 public callerAllocationPeriod;

    // Track if the generation process is started
    bool public started;

    // Track the already generated allocations for recipients
    mapping (address => bool) public generated;

    // Check that a recipient's allocation has not been generated
    modifier notGenerated(address _recipient) {
        require(!generated[_recipient]);
        _;
    }

    // Check that the generation period is started
    modifier isStarted() {
        require(started);
        _;
    }

    // Check that the generation period is not started
    modifier isNotStarted() {
        require(!started);
        _;
    }

    event Generate(address indexed _recipient, address indexed _caller, uint256 _recipientTokenAmount, uint256 _callerTokenAmount, uint256 _block);

    /**
     * @dev MerkleMine constructor
     * @param _token ERC20 token being distributed
     * @param _genesisRoot Merkle root representing genesis state which encodes token recipients
     * @param _totalGenesisTokens Total amount of tokens that can be generated
     * @param _totalGenesisRecipients Total number of recipients included in genesis state
     * @param _balanceThreshold Minimum ETH balance threshold for recipients included in genesis state
     * @param _genesisBlock Block number of genesis - used to determine which ETH accounts are included in the genesis state
     * @param _callerAllocationStartBlock Start block where a third party caller (not the recipient) can generate and split the allocation with the recipient
     * @param _callerAllocationEndBlock From this block onwards, a third party caller (not the recipient) can generate and claim the recipient's full allocation
     */
    function MerkleMine(
        address _token,
        bytes32 _genesisRoot,
        uint256 _totalGenesisTokens,
        uint256 _totalGenesisRecipients,
        uint256 _balanceThreshold,
        uint256 _genesisBlock,
        uint256 _callerAllocationStartBlock,
        uint256 _callerAllocationEndBlock
    )
        public
    {
        // Address of token contract must not be null
        require(_token != address(0));
        // Number of recipients must be non-zero
        require(_totalGenesisRecipients > 0);
        // Genesis block must be at or before the current block
        require(_genesisBlock <= block.number);
        // Start block for caller allocation must be after current block
        require(_callerAllocationStartBlock > block.number);
        // End block for caller allocation must be after caller allocation start block
        require(_callerAllocationEndBlock > _callerAllocationStartBlock);

        token = ERC20(_token);
        genesisRoot = _genesisRoot;
        totalGenesisTokens = _totalGenesisTokens;
        totalGenesisRecipients = _totalGenesisRecipients;
        tokensPerAllocation = _totalGenesisTokens.div(_totalGenesisRecipients);
        balanceThreshold = _balanceThreshold;
        genesisBlock = _genesisBlock;
        callerAllocationStartBlock = _callerAllocationStartBlock;
        callerAllocationEndBlock = _callerAllocationEndBlock;
        callerAllocationPeriod = _callerAllocationEndBlock.sub(_callerAllocationStartBlock);
    }

    /**
     * @dev Start the generation period - first checks that this contract's balance is equal to `totalGenesisTokens`
     * The generation period must not already be started
     */
    function start() external isNotStarted {
        // Check that this contract has a sufficient balance for the generation period
        require(token.balanceOf(this) >= totalGenesisTokens);

        started = true;
    }

    /**
     * @dev Generate a recipient's token allocation. Generation period must be started. Starting from `callerAllocationStartBlock`
     * a third party caller (not the recipient) can invoke this function to generate the recipient's token
     * allocation and claim a percentage of it. The percentage of the allocation claimed by the
     * third party caller is determined by how many blocks have elapsed since `callerAllocationStartBlock`.
     * After `callerAllocationEndBlock`, a third party caller can claim the full allocation
     * @param _recipient Recipient of token allocation
     * @param _merkleProof Proof of recipient's inclusion in genesis state Merkle root
     */
    function generate(address _recipient, bytes _merkleProof) external isStarted notGenerated(_recipient) {
        // Check the Merkle proof
        bytes32 leaf = keccak256(_recipient);
        // _merkleProof must prove inclusion of _recipient in the genesis state root
        require(MerkleProof.verifyProof(_merkleProof, genesisRoot, leaf));

        generated[_recipient] = true;

        address caller = msg.sender;

        if (caller == _recipient) {
            // If the caller is the recipient, transfer the full allocation to the caller/recipient
            require(token.transfer(_recipient, tokensPerAllocation));

            Generate(_recipient, _recipient, tokensPerAllocation, 0, block.number);
        } else {
            // If the caller is not the recipient, the token allocation generation
            // can only take place if we are in the caller allocation period
            require(block.number >= callerAllocationStartBlock);

            uint256 callerTokenAmount = callerTokenAmountAtBlock(block.number);
            uint256 recipientTokenAmount = tokensPerAllocation.sub(callerTokenAmount);

            if (callerTokenAmount > 0) {
                require(token.transfer(caller, callerTokenAmount));
            }

            if (recipientTokenAmount > 0) {
                require(token.transfer(_recipient, recipientTokenAmount));
            }

            Generate(_recipient, caller, recipientTokenAmount, callerTokenAmount, block.number);
        }
    }

    /**
     * @dev Return the amount of tokens claimable by a third party caller when generating a recipient's token allocation at a given block
     * @param _blockNumber Block at which to compute the amount of tokens claimable by a third party caller
     */
    function callerTokenAmountAtBlock(uint256 _blockNumber) public view returns (uint256) {
        if (_blockNumber < callerAllocationStartBlock) {
            // If the block is before the start of the caller allocation period, the third party caller can claim nothing
            return 0;
        } else if (_blockNumber >= callerAllocationEndBlock) {
            // If the block is at or after the end block of the caller allocation period, the third party caller can claim everything
            return tokensPerAllocation;
        } else {
            // During the caller allocation period, the third party caller can claim an increasing percentage
            // of the recipient's allocation based on a linear curve - as more blocks pass in the caller allocation
            // period, the amount claimable by the third party caller increases linearly
            uint256 blocksSinceCallerAllocationStartBlock = _blockNumber.sub(callerAllocationStartBlock);
            return tokensPerAllocation.mul(blocksSinceCallerAllocationStartBlock).div(callerAllocationPeriod);
        }
    }
}

/**
 * @title BytesUtil
 * @dev Utilities for extracting bytes from byte arrays
 * Functions taken from:
 * - https://github.com/ethereum/solidity-examples/blob/master/src/unsafe/Memory.sol
 * - https://github.com/ethereum/solidity-examples/blob/master/src/bytes/Bytes.sol
 */


/**
 * @title MultiMerkleMine
 * @dev The MultiMerkleMine contract is purely a convenience wrapper around an existing MerkleMine contract deployed on the blockchain.
 */
contract MultiMerkleMine {
	using SafeMath for uint256;

	/**
     * @dev Generates token allocations for multiple recipients. Generation period must be started.
     * @param _merkleMineContract Address of the deployed MerkleMine contract
     * @param _recipients Array of recipients
     * @param _merkleProofs Proofs for respective recipients constructed in the format: 
     *       [proof_1_size, proof_1, proof_2_size, proof_2, ... , proof_n_size, proof_n]
     */
	function multiGenerate(address _merkleMineContract, address[] _recipients, bytes _merkleProofs) public {
		MerkleMine mine = MerkleMine(_merkleMineContract);
		ERC20 token = ERC20(mine.token());

		require(
			block.number >= mine.callerAllocationStartBlock(),
			"caller allocation period has not started"
		);
		
		uint256 initialBalance = token.balanceOf(this);
		bytes[] memory proofs = new bytes[](_recipients.length);

		// Counter to keep track of position in `_merkleProofs` byte array
		uint256 i = 0;
		// Counter to keep track of index of each extracted Merkle proof
		uint256 j = 0;

		// Extract proofs
		while(i < _merkleProofs.length){
			uint256 proofSize = uint256(BytesUtil.readBytes32(_merkleProofs, i));

			require(
				proofSize % 32 == 0,
				"proof size must be a multiple of 32"
			);

			proofs[j] = BytesUtil.substr(_merkleProofs, i + 32, proofSize);

			i = i + 32 + proofSize;
			j++;
		}

		require(
			_recipients.length == j,
			"number of recipients != number of proofs"
		);

		for (uint256 k = 0; k < _recipients.length; k++) {
			// If recipient's token allocation has not been generated, generate the token allocation
			// Else, continue to the next recipient
			if (!mine.generated(_recipients[k])) {
				mine.generate(_recipients[k], proofs[k]);
			}
		}

		uint256 newBalanceSinceAllocation = token.balanceOf(this);
		uint256 callerTokensGenerated = newBalanceSinceAllocation.sub(initialBalance);

		// Transfer caller's portion of tokens generated by this function call 
		if (callerTokensGenerated > 0) {
			require(token.transfer(msg.sender, callerTokensGenerated));
		}
	}
}