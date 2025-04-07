pragma solidity ^0.4.24;


/**
 * @title Eliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */



/**
 * @title Auction state channel
 */
contract AuctionChannel {
    
    // phase constants
    uint8 public constant PHASE_OPEN = 0;
    uint8 public constant PHASE_CHALLENGE = 1;
    uint8 public constant PHASE_CLOSED = 2;
    
    // auctioneer address
    address public auctioneer;

    // assistant address
    address public assistant;

    // current phase
    uint8 public phase;

    // minimum bid value
    uint256 public minBidValue;

    // challenge period in blocks
    uint256 public challengePeriod;

    // closing block number
    uint256 public closingBlock;

    // winner id
    bytes public winnerBidder;

    // winner bid value
    uint256 public winnerBidValue;


    /**
     * CONSTRUCTOR
     *
     * @dev Initialize the AuctionChannel
     * @param _auctioneer auctioneer address
     * @param _assistant assistant address
     * @param _challengePeriod challenge period in blocks
     * @param _minBidValue minimum winner bid value
     * @param _signatureAuctioneer signature of the auctioneer
     * @param _signatureAssistant signature of the assistant
     */ 
    constructor
    (
        address _auctioneer,
        address _assistant,
        uint256 _challengePeriod,
        uint256 _minBidValue,
        bytes _signatureAuctioneer,
        bytes _signatureAssistant
    )
        public
    {
        bytes32 _fingerprint = keccak256(
            abi.encodePacked(
                "openingAuctionChannel",
                _auctioneer,
                _assistant,
                _challengePeriod,
                _minBidValue
            )
        );

        _fingerprint = ECRecovery.toEthSignedMessageHash(_fingerprint);

        require(_auctioneer == ECRecovery.recover(_fingerprint, _signatureAuctioneer));
        require(_assistant == ECRecovery.recover(_fingerprint, _signatureAssistant));

        auctioneer = _auctioneer;
        assistant = _assistant;
        challengePeriod = _challengePeriod;
        minBidValue = _minBidValue;
    }
   
    /**
     * @dev Update winner bid
     * @param _isAskBid is it AskBid
     * @param _bidder bidder id
     * @param _bidValue bid value
     * @param _previousBidHash hash of the previous bid
     * @param _signatureAssistant signature of the assistant
     * @param _signatureAuctioneer signature of the auctioneer
     */
    function updateWinnerBid(
        bool _isAskBid,
        bytes _bidder,
        uint256 _bidValue,
        bytes _previousBidHash,
        bytes _signatureAssistant,
        bytes _signatureAuctioneer
    ) 
        external
    {
        tryClose();

        require(phase != PHASE_CLOSED);

        require(!_isAskBid);
        require(_bidValue > winnerBidValue);
        require(_bidValue >= minBidValue);

        bytes32 _fingerprint = keccak256(
            abi.encodePacked(
                "auctionBid",
                _isAskBid,
                _bidder,
                _bidValue,
                _previousBidHash
            )
        );

        _fingerprint = ECRecovery.toEthSignedMessageHash(_fingerprint);

        require(auctioneer == ECRecovery.recover(_fingerprint, _signatureAuctioneer));
        require(assistant == ECRecovery.recover(_fingerprint, _signatureAssistant));
        
        winnerBidder = _bidder;
        winnerBidValue = _bidValue;

        // start challenge period
        closingBlock = block.number + challengePeriod;
        phase = PHASE_CHALLENGE;  
    }

    /**
     * @dev Close the auction
     */
    function tryClose() public {
        if (phase == PHASE_CHALLENGE && block.number > closingBlock) {
            phase = PHASE_CLOSED;
        }
    }
}