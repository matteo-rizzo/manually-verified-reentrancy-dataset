// Dependency file: contracts/interface/IERC20.sol

//SPDX-License-Identifier: MIT
// pragma solidity >=0.5.0;




// Dependency file: contracts/interface/IWasabi.sol

// pragma solidity >=0.5.0;




// Dependency file: contracts/interface/IWasabiOffer.sol

// pragma solidity >=0.5.0;




// Root file: contracts/WasabiQuery.sol

pragma experimental ABIEncoderV2;
pragma solidity >=0.6.6;

// import 'contracts/interface/IERC20.sol';
// import 'contracts/interface/IWasabi.sol';
// import 'contracts/interface/IWasabiOffer.sol';

contract WasabiQuery {
    address public wasabi;
    address public owner;
    enum OfferState { Created, Opened, Taken, Paidback, Expired, Closed }

    struct OfferData {
        address tokenIn;
        address tokenOut;
        uint amountIn;
        uint amountOut;
        uint expire;
        uint interests;
        uint duration;
        uint state;
        uint feeRate;
        uint interestrate;
        uint wasabiReward;
        uint sushiReward;
        address owner;
        address taker;
    }

    event OwnerChanged(address indexed _oldOwner, address indexed _newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, 'Ownable: FORBIDDEN');
        _;
    }

    constructor(address _wasabi) public {
        owner = msg.sender;
        wasabi = _wasabi;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), 'Ownable: INVALID_ADDRESS');
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    function changeWasabi(address _wasabi) public onlyOwner {
        wasabi = _wasabi;
    }

    function iterateOffers(address _token, uint _start, uint _end) public view returns (address[] memory) {
        if (_start > _end) return iterateReverseOffers(_token, _start, _end);

        uint count = IWasabi(wasabi).getOfferLength(_token);
        if (_end >= count) _end = count;
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](_end-_start);
        uint index = 0;
        for (uint i = _start; i < _end; i++) {
            res[index] = IWasabi(wasabi).getOffer(_token, i);
            index++;
        }
        return res;
    }

    function iterateReverseOffers(address _token, uint _start, uint _end) public view returns (address[] memory) {
        uint count = IWasabi(wasabi).getOfferLength(_token);
        if (_start >= count) _start = count;
        require(_end <= _start && _end >= 0 && _start >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](_start-_end);
        if (_end == _start) return res;
        uint index = 0;
        uint len = 0;
        for (uint i = _start-1; i >= _end; i--) {
            res[index] = IWasabi(wasabi).getOffer(_token, i);
            index++;
            len++;
            if (len>=_start - _end) break;
        }
        return res;
    }

    function iterateUserOffers(uint _start, uint _end) public view returns (address[] memory) {
        if (_start > _end) return iterateReverseUserOffers(_start, _end);

        uint count = IWasabi(wasabi).getUserOffersLength(msg.sender);
        if (_end >= count) _end = count;
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](_end-_start);
        uint index = 0;
        for (uint i = _start; i < _end; i++) {
            res[index] = IWasabi(wasabi).getUserOffer(msg.sender, i);
            index++;
        }
        return res;
    }

    function iterateReverseUserOffers(uint _start, uint _end) public view returns (address[] memory) {
        uint count = IWasabi(wasabi).getUserOffersLength(msg.sender);
        if (_start >= count) _start = count;
        require(_end <= _start && _end >= 0 && _start >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](_start-_end);
        if (_end == _start) return res;
        uint index = 0;
        uint len = 0;
        for (uint i = _start-1; i >= _end; i--) {
            res[index] = IWasabi(wasabi).getUserOffer(msg.sender, i);
            index++;
            len++;
            if (len>=_start - _end) break;
        }
        return res;
    }

    function iterateTakerOffers(uint _start, uint _end) public view returns (address[] memory) {
        if (_start > _end) return iterateReverseTakerOffers(_start, _end);

        uint count = IWasabi(wasabi).getTakerOffersLength(msg.sender);
        if (_end >= count) _end = count;
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](count);
        uint index = 0;
        for (uint i = _start; i < _end; i++) {
            res[index] = IWasabi(wasabi).getTakerOffer(msg.sender, i);
            index++;
        }
        return res;
    }

    function iterateReverseTakerOffers(uint _start, uint _end) public view returns (address[] memory) {
        uint count = IWasabi(wasabi).getTakerOffersLength(msg.sender);
        if (_start >= count) _start = count;
        require(_end <= _start && _end >= 0 && _start >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](_start-_end);
        if (_end == _start) return res;
        uint index = 0;
        uint len = 0;
        for (uint i = _start-1; i >= _end; i--) {
            res[index] = IWasabi(wasabi).getTakerOffer(msg.sender, i);
            index++;
            len++;
            if (len>=_start - _end) break;
        }
        return res;
    }

    function getOfferInfo(address _offer) external view returns (OfferData memory offer) {
        (
            offer.tokenIn,
            offer.tokenOut,
            offer.amountIn,
            offer.amountOut,
            offer.expire,
            offer.interests,
            offer.duration
        ) = IWasabi(wasabi).offers(_offer);

        (offer.feeRate, offer.interestrate) = IWasabi(wasabi).getRateForOffer(_offer);
        offer.state = IWasabiOffer(_offer).state();
        if (offer.state == uint(OfferState.Taken) && block.number >= offer.expire) {
            offer.state = uint(OfferState.Expired);
        }
        offer.owner = IWasabiOffer(_offer).owner();
        offer.taker = IWasabiOffer(_offer).taker();

        offer.wasabiReward = IWasabiOffer(_offer).getEstimatedWasabi();
        offer.sushiReward = IWasabiOffer(_offer).getEstimatedSushi();
    }

    function iterateTokens(uint _start, uint _end) external view returns (address[] memory) {
        uint count = IWasabi(wasabi).getTokensLength();
        if (_end >= count) _end = count;
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        address[] memory res = new address[](_end-_start);
        uint index = 0;
        for (uint i = _start; i < _end; i++) {
            res[index] = IWasabi(wasabi).tokens(i);
            index++;
        }
        return res;
    }
}