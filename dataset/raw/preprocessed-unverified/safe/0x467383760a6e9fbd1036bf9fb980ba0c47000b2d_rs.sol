/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

pragma solidity 0.4.26;








contract ENSResolver {
  function addr(bytes32 node) public view returns (address);
}











contract ChainlinkClient {
  using Chainlink for Chainlink.Request;
  using SafeMath for uint256;

  uint256 constant internal LINK = 10**18;
  uint256 constant private AMOUNT_OVERRIDE = 0;
  address constant private SENDER_OVERRIDE = 0x0;
  uint256 constant private ARGS_VERSION = 1;
  bytes32 constant private ENS_TOKEN_SUBNAME = keccak256("link");
  bytes32 constant private ENS_ORACLE_SUBNAME = keccak256("oracle");
  address constant private LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private ens;
  bytes32 private ensNode;
  LinkTokenInterface private link;
  ChainlinkRequestInterface private oracle;
  uint256 private requests = 1;
  mapping(bytes32 => address) private pendingRequests;

  event ChainlinkRequested(bytes32 indexed id);
  event ChainlinkFulfilled(bytes32 indexed id);
  event ChainlinkCancelled(bytes32 indexed id);

  
  function buildChainlinkRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionSignature
  ) internal pure returns (Chainlink.Request memory) {
    Chainlink.Request memory req;
    return req.initialize(_specId, _callbackAddress, _callbackFunctionSignature);
  }

  
  function sendChainlinkRequest(Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32)
  {
    return sendChainlinkRequestTo(oracle, _req, _payment);
  }

  
  function sendChainlinkRequestTo(address _oracle, Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(this, requests));
    _req.nonce = requests;
    pendingRequests[requestId] = _oracle;
    emit ChainlinkRequested(requestId);
    
    requests += 1;

    return requestId;
  }

  
  function cancelChainlinkRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  )
    internal
  {
    ChainlinkRequestInterface requested = ChainlinkRequestInterface(pendingRequests[_requestId]);
    delete pendingRequests[_requestId];
    emit ChainlinkCancelled(_requestId);
    requested.cancelOracleRequest(_requestId, _payment, _callbackFunc, _expiration);
  }

  
  function setChainlinkOracle(address _oracle) internal {
    oracle = ChainlinkRequestInterface(_oracle);
  }

  
  function setChainlinkToken(address _link) internal {
    link = LinkTokenInterface(_link);
  }

  
  function setPublicChainlinkToken() internal {
    setChainlinkToken(PointerInterface(LINK_TOKEN_POINTER).getAddress());
  }

  
  function chainlinkTokenAddress()
    internal
    view
    returns (address)
  {
    return address(link);
  }

  
  function chainlinkOracleAddress()
    internal
    view
    returns (address)
  {
    return address(oracle);
  }

  
  function addChainlinkExternalRequest(address _oracle, bytes32 _requestId)
    internal
    notPendingRequest(_requestId)
  {
    pendingRequests[_requestId] = _oracle;
  }

  
  function useChainlinkWithENS(address _ens, bytes32 _node)
    internal
  {
    ens = ENSInterface(_ens);
    ensNode = _node;
    bytes32 linkSubnode = keccak256(abi.encodePacked(ensNode, ENS_TOKEN_SUBNAME));
    ENSResolver resolver = ENSResolver(ens.resolver(linkSubnode));
    setChainlinkToken(resolver.addr(linkSubnode));
    updateChainlinkOracleWithENS();
  }

  
  function updateChainlinkOracleWithENS()
    internal
  {
    bytes32 oracleSubnode = keccak256(abi.encodePacked(ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver resolver = ENSResolver(ens.resolver(oracleSubnode));
    setChainlinkOracle(resolver.addr(oracleSubnode));
  }

  
  function encodeRequest(Chainlink.Request memory _req)
    private
    view
    returns (bytes memory)
  {
    return abi.encodeWithSelector(
      oracle.oracleRequest.selector,
      SENDER_OVERRIDE, 
      AMOUNT_OVERRIDE, 
      _req.id,
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      ARGS_VERSION,
      _req.buf.buf);
  }

  
  function validateChainlinkCallback(bytes32 _requestId)
    internal
    recordChainlinkFulfillment(_requestId)
    
  {}

  
  modifier recordChainlinkFulfillment(bytes32 _requestId) {
    
    delete pendingRequests[_requestId];
    emit ChainlinkFulfilled(_requestId);
    _;
  }

  
  modifier notPendingRequest(bytes32 _requestId) {
    require(pendingRequests[_requestId] == address(0), "Request is already pending");
    _;
  }
}

contract DSMath {
    
    

    function add(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }
    
    function div(uint256 x, uint256 y) pure internal returns (uint256 z) {
        require(y > 0);
        z = x / y;
    }
    
    function min(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    


    function hadd(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert(y > 0);
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    

    function imin(int256 x, int256 y) pure internal returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) pure internal returns (int256 z) {
        return x >= y ? x : y;
    }

    

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) view internal returns (uint128 z) {
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) pure internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract Oracle is DSMath {
    uint32  constant public DELAY = 900; 
    uint128 constant public prem = 1100000000000000000; 
    uint128 constant public turn = 1010000000000000000; 

    MedianizerInterface med; 

    uint32 public expiry;
    uint32 public timeout;
    uint128 assetPrice;
    uint128 public paymentTokenPrice;
    uint256 rewardAmount;

    mapping(bytes32 => AsyncRequest) asyncRequests;

    
    struct AsyncRequest {
        address rewardee;
        uint128 payment;
        uint128 disbursement;
        ERC20 token;
        bool assetPriceSet;
        bool paymentTokenPriceSet;
    }

    event SetAssetPrice(bytes32 queryId, uint128 assetPrice_, uint32 expiry_);

    event SetPaymentTokenPrice(bytes32 queryId, uint128 paymentTokenPrice_);

    event Reward(bytes32 queryId);

    
    function peek() public view returns (bytes32,bool) {
        return (bytes32(uint(assetPrice)), now < expiry);
    }

    
    function read() public view returns (bytes32) {
        assert(now < expiry);
        return bytes32(uint(assetPrice));
    }

    
    function setAssetPrice(bytes32 queryId, uint128 assetPrice_, uint32 expiry_) internal {
        asyncRequests[queryId].disbursement = 0;
        if (assetPrice_ >= wmul(assetPrice, turn) || assetPrice_ <= wdiv(assetPrice, turn)) {
            asyncRequests[queryId].disbursement = asyncRequests[queryId].payment;
        }
        assetPrice = assetPrice_;
        expiry = expiry_;
        med.poke();
        asyncRequests[queryId].assetPriceSet = true;
        if (asyncRequests[queryId].paymentTokenPriceSet) {reward(queryId);}

        emit SetAssetPrice(queryId, assetPrice_, expiry_);
    }

    
    function setPaymentTokenPrice(bytes32 queryId, uint128 paymentTokenPrice_) internal {
        paymentTokenPrice = paymentTokenPrice_;
        asyncRequests[queryId].paymentTokenPriceSet = true;
        if (asyncRequests[queryId].assetPriceSet) {reward(queryId);}

        emit SetPaymentTokenPrice(queryId, paymentTokenPrice_);
    }

    
    function reward(bytes32 queryId) internal {
        rewardAmount = wmul(wmul(paymentTokenPrice, asyncRequests[queryId].disbursement), prem);
        if (asyncRequests[queryId].token.balanceOf(address(this)) >= rewardAmount && asyncRequests[queryId].disbursement > 0) {
            require(asyncRequests[queryId].token.transfer(asyncRequests[queryId].rewardee, rewardAmount), "Oracle.reward: token transfer failed");
        }
        delete(asyncRequests[queryId]);

        emit Reward(queryId);
    }

    
    function setMaxReward(uint256 maxReward_) public;

    
    function setGasLimit(uint256 gasLimit_) public;
}

contract ChainLink is ChainlinkClient, Oracle {
    ERC20 link;
    uint256 maxReward; 

    bytes32 public lastQueryId;

    uint256 public constant DEFAULT_LINK_PAYMENT = 2 * LINK; 
    uint256 public constant ORACLE_EXPIRY = 12 hours; 

    mapping(bytes32 => bytes32) linkIdToQueryId;

    event Update(uint128 payment_, ERC20 token_);

    event ReturnAssetPrice(bytes32 requestId_, uint256 price_);

    event ReturnPaymentTokenPrice(bytes32 requestId_, uint256 price_);

    event Reward(bytes32 queryId);

    
    constructor(MedianizerInterface med_, ERC20 link_, address oracle_) public {
        med = med_;
        link = link_;
        setChainlinkToken(address(link_));
        setChainlinkOracle(oracle_);
        asyncRequests[lastQueryId].payment = uint128(DEFAULT_LINK_PAYMENT);
    }

    
    function bill() public view returns (uint256) {
        return asyncRequests[lastQueryId].payment;
    }

    
    function update(uint128 payment_, ERC20 token_) public { 
        require(uint32(now) > timeout, "ChainLink.update: now is less than timeout");
        require(link.transferFrom(msg.sender, address(this), uint(payment_)), "ChainLink.update: failed to transfer link from msg.sender");
        bytes32 queryId = getAssetPrice(payment_);
        lastQueryId = queryId;
        bytes32 linkId = getPaymentTokenPrice(payment_, queryId);
        linkIdToQueryId[linkId] = queryId;
        asyncRequests[queryId].rewardee = msg.sender;
        asyncRequests[queryId].payment = payment_;
        asyncRequests[queryId].token = token_;
        timeout = uint32(now) + DELAY;

        emit Update(payment_, token_);
    }

    function getAssetPrice(uint128) internal returns (bytes32);

    function getPaymentTokenPrice(uint128, bytes32) internal returns (bytes32);

    
    function returnAssetPrice(bytes32 requestId_, uint256 price_) public recordChainlinkFulfillment(requestId_) {
        setAssetPrice(requestId_, uint128(price_), uint32(now + ORACLE_EXPIRY));

        emit ReturnAssetPrice(requestId_, price_);
    }

    
    function returnPaymentTokenPrice(bytes32 requestId_, uint256 price_) public recordChainlinkFulfillment(requestId_) {
        setPaymentTokenPrice(linkIdToQueryId[requestId_], uint128(price_));

        emit ReturnPaymentTokenPrice(requestId_, price_);
    }

    
    function reward(bytes32 queryId) internal {
        rewardAmount = wmul(wmul(paymentTokenPrice, asyncRequests[queryId].disbursement), prem);
        if (asyncRequests[queryId].token.balanceOf(address(this)) >= min(maxReward, rewardAmount) && asyncRequests[queryId].disbursement > 0) {
            require(asyncRequests[queryId].token.transfer(asyncRequests[queryId].rewardee, min(maxReward, rewardAmount)), "ChainLink.reward: token transfer failed");
        }

        emit Reward(queryId);
    }

    
    function setMaxReward(uint256 maxReward_) public {
        require(msg.sender == address(med), "ChainLink.setMaxReward: msg.sender isn't medianizer address");
        maxReward = maxReward_;
    }

    
    function setGasLimit(uint256) public {
        require(msg.sender == address(med), "Oraclize.setGasLimit: msg.sender isn't medianizer address");
    }
}

contract CoinMarketCap is ChainLink {
    
    bytes32 constant UINT256_MUL_JOB = bytes32("f1805afed6a0482bb43702692ff9e061");

    
    

    
    constructor(MedianizerInterface med_, ERC20 link_, address oracle_) public ChainLink(med_, link_, oracle_) {}

    
    function getAssetPrice(uint128 payment_) internal returns (bytes32 queryId) {
        Chainlink.Request memory req = buildChainlinkRequest(UINT256_MUL_JOB, this, this.returnAssetPrice.selector);
        req.add("sym", "BTC");
        req.add("convert", "USD");
        string[] memory path = new string[](5);
        path[0] = "data";
        path[1] = "BTC";
        path[2] = "quote";
        path[3] = "USD";
        path[4] = "price";
        req.addStringArray("copyPath", path);
        req.addInt("times", WAD); 
        queryId = sendChainlinkRequest(req, div(payment_, 2)); 
    }

    
    function getPaymentTokenPrice(uint128 payment_, bytes32 queryId) internal returns (bytes32) {
        Chainlink.Request memory req = buildChainlinkRequest(UINT256_MUL_JOB, this, this.returnPaymentTokenPrice.selector);
        req.add("sym", "LINK");
        req.add("convert", "USD");
        string[] memory path = new string[](5);
        path[0] = "data";
        path[1] = "LINK";
        path[2] = "quote";
        path[3] = "USD";
        path[4] = "price";
        req.addStringArray("copyPath", path);
        req.addInt("times", WAD); 
        bytes32 linkId = sendChainlinkRequest(req, div(payment_, 2)); 
        linkIdToQueryId[linkId] = queryId;
        return linkId;
    }
}