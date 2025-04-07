/**
 *Submitted for verification at Etherscan.io on 2021-07-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;


















contract Market {
    using EnumerableSet for EnumerableSet.Bytes32Set ;
    using EnumerableMap for EnumerableMap.UintToB32Map;
    using SafeERC20 for IERC20;
    
    struct Coin {
        bool active;
        address tokenAddress;
        string symbol;
        string name;
    }
    
    mapping (uint256 => Coin) public tradeCoins;
    
    struct Trade {
        uint256 indexedBy;
        bool active; 
        address nftAddress;
        address seller;
        address buyer;
        uint256 assetId;
        uint256 end;
        uint256 stime;
        uint256 price;
        uint256 coinIndex;
        
    }
    
    mapping (uint8 => address) public managers;
    mapping (bytes32 => bool) public executedTask;
    uint16 public taskIndex;
    
    mapping (address => bool) public authorizedERC721;
    mapping (uint256 => bytes32) public tradeIndex;
    mapping (bytes32 => Trade) public trades;
    mapping (bytes32 => bool) public tradingCheck;

    EnumerableMap.UintToB32Map private tradesMap;
    mapping (address => EnumerableSet.Bytes32Set) private userTrades;
    
    uint256 nextTrade;
    FeesContract feesContract;
    address payable walletAddress;
    
    modifier isManager() {
        require(managers[0] == msg.sender || managers[1] == msg.sender || managers[2] == msg.sender, "Not manager");
        _;
    }
    
    constructor() {
        // include ETH as coin
        tradeCoins[1].tokenAddress = address(0x0);
        tradeCoins[1].symbol = "ETH";
        tradeCoins[1].name = "Ethereum";
        tradeCoins[1].active = true;
        
        // include POLC as coin
        tradeCoins[2].tokenAddress = 0xaA8330FB2B4D5D07ABFE7A72262752a8505C6B37;
        tradeCoins[2].symbol = "POLC";
        tradeCoins[2].name = "Polka City Token";
        tradeCoins[2].active = true;
        
        // POlka City NFT 3D
        authorizedERC721[0xB20217bf3d89667Fa15907971866acD6CcD570C8] = true;
        // POlka City NFT
        authorizedERC721[0x57E9a39aE8eC404C08f88740A9e6E306f50c937f] = true;
        
        walletAddress = payable(0xf7A9F6001ff8b499149569C54852226d719f2D76);
        
        managers[0] = msg.sender;
        managers[1] = 0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec;
        managers[2] = 0xB1A951141F1b3A16824241f687C3741459E33225;
        
        feesContract = FeesContract(0xc10881fa05CE734336A153c72999eE91A287cC30);
    }
    
    function createTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end) public {
        require(authorizedERC721[_nftAddress] == true, "Unauthorized asset");
        require(tradeCoins[_coinIndex].active == true, "Invalid payment coin");
        require(_end == 0 || _end > block.timestamp, "Invalid end time");
        bytes32 atCheck = keccak256(abi.encode(_nftAddress, _assetId, msg.sender));
        require(tradingCheck[atCheck] == false, "This asset is already listed");
        IERC721 nftContract = IERC721(_nftAddress);
        require(nftContract.ownerOf(_assetId) == msg.sender, "Only asset owner can sell");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Market needs operator approval");
        insertTrade(_nftAddress, _assetId, _price, _coinIndex, _end, atCheck);
    }
    
    function insertTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end, bytes32 _atCheck) private {
        Trade memory trade = Trade(nextTrade, true, _nftAddress, msg.sender, address(0x0), _assetId, _end, block.timestamp, _price, _coinIndex);
        bytes32 tradeHash = keccak256(abi.encode(_nftAddress, _assetId, nextTrade));
        tradeIndex[nextTrade] = tradeHash;
        trades[tradeHash] = trade;
        tradesMap.set(nextTrade, tradeHash);
        userTrades[msg.sender].add(tradeHash);
        tradingCheck[_atCheck] == true;
        nextTrade += 1;
    }
    
    function allTradesCount() public view returns (uint256) {
        return (nextTrade);
    }

    function tradesCount() public view returns (uint256) {
        return (tradesMap.length());
    }
    
    function _getTrade(bytes32 _tradeId) private view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 end, uint256 sTime, uint256 price, uint256 coinIndex, bool active) {
        Trade memory _trade = trades[_tradeId];
        return (
        _trade.indexedBy,
        _trade.nftAddress,
        _trade.seller,
        _trade.buyer,
        _trade.assetId,
        _trade.end,
        _trade.stime,
        _trade.price,
        _trade.coinIndex,
        _trade.active
        );

    }

    function getTrade(bytes32 _tradeId) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 end, uint256 sTime, uint256 price, uint256 coinIndex, bool active) {
        return _getTrade(_tradeId);
    }
    
    function getTradeByIndex(uint256 _index) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 end, uint256 sTime, uint256 price, uint256 coinIndex, bool active) {
        (, bytes32 tradeId) = tradesMap.at(_index);
        return _getTrade(tradeId);
    }

    function parseBytes(bytes memory data) private pure returns (bytes32){
        bytes32 parsed;
        assembly {parsed := mload(add(data, 32))}
        return parsed;
    }
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public returns (bool) {
        bytes32 _tradeId = parseBytes(_extraData);
        Trade memory trade = trades[_tradeId];
        require(tradeCoins[trade.coinIndex].tokenAddress == _token, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(_value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByToken(trade.seller, tradeCoins[trade.coinIndex].tokenAddress , _value); 
            executeTrade(_tradeId, _from, trade.seller, trade.nftAddress, trade.assetId);
            IERC20 erc20Token = IERC20(_token); 
            if (tradeFee > 0) {
                erc20Token.safeTransferFrom(_from, walletAddress, (tradeFee));
                erc20Token.safeTransferFrom(_from, trade.seller, (trade.price-tradeFee));
            } else {
                erc20Token.safeTransferFrom(_from, trade.seller, (trade.price));
            }
            transferAsset(_from, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function buyWithEth(bytes32 _tradeId) public payable returns (bool) {
        Trade memory trade = trades[_tradeId];
        require(trade.coinIndex == 1, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(msg.value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByEth(trade.seller, msg.value);
            executeTrade(_tradeId, msg.sender, trade.seller, trade.nftAddress, trade.assetId);
            if (tradeFee > 0) {
              Address.sendValue(payable(walletAddress), tradeFee);
              Address.sendValue(payable(trade.seller),(msg.value-tradeFee));
            } else {
              Address.sendValue(payable(trade.seller),(msg.value));
            }
            transferAsset(msg.sender, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function executeTrade(bytes32 _tradeId, address _buyer, address _seller, address _contract, uint256 _assetId) private {
        trades[_tradeId].buyer = _buyer;
        trades[_tradeId].active = false;
        trades[_tradeId].stime = block.timestamp;
        userTrades[_seller].remove(_tradeId);
        tradesMap.remove(trades[_tradeId].indexedBy);
        tradingCheck[keccak256(abi.encode(_contract, _assetId, _seller))] = false;
    }
    
    function transferAsset(address _buyer, address _seller, address _contract, uint256 _assetId) private {
        IERC721 nftToken = IERC721(_contract);
        nftToken.safeTransferFrom(_seller, _buyer, _assetId);
    }
    
    function verifyTrade(bytes32 _tradeId, address _seller, address _contract, uint256 _assetId, uint256 _endTime) private returns (bool) {
        IERC721 nftToken = IERC721(_contract);
        address assetOwner = nftToken.ownerOf(_assetId);
        if (assetOwner != _seller || (_endTime > 0 && _endTime < block.timestamp)) {
            trades[_tradeId].active = false;
            userTrades[_seller].remove(_tradeId);
            tradesMap.remove(trades[_tradeId].indexedBy);
            return false;
        } else {
            return true;
        }
    }

    function cancelTrade(bytes32 _tradeId) public returns (bool) {
        Trade memory trade = trades[_tradeId];
        require(trade.seller == msg.sender, "Only asset seller can cancel the trade");
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
        tradingCheck[keccak256(abi.encode(trade.nftAddress, trade.assetId, trade.seller))] = false;
        return true;
    }

    function adminCancelTrade(bytes32 _tradeId, bytes memory _sig) public isManager {
        uint8 mId = 1;
        bytes32 taskHash = keccak256(abi.encode(_tradeId, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        Trade memory trade = trades[_tradeId];
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
        tradingCheck[keccak256(abi.encode(trade.nftAddress, trade.assetId, trade.seller))] = false;
    }
    
    function tradesCountOf(address _from) public view returns (uint256) {
        return (userTrades[_from].length());
    }
    
    function tradeOfByIndex(address _from, uint256 _index) public view returns (bytes32 _trade) {
        return (userTrades[_from].at(_index));
    }
    
    function addCoin(uint256 _coinIndex, address _tokenAddress, string memory _tokenSymbol, string memory _tokenName, bool _active, bytes memory _sig) public isManager {
        uint8 mId = 2;
        bytes32 taskHash = keccak256(abi.encode(_coinIndex, _tokenAddress, _tokenSymbol, _tokenName, _active, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        tradeCoins[_coinIndex].tokenAddress = _tokenAddress;
        tradeCoins[_coinIndex].symbol = _tokenSymbol;
        tradeCoins[_coinIndex].name = _tokenName;
        tradeCoins[_coinIndex].active = _active;
    }

    function authorizeNFT(address _nftAddress, bytes memory _sig) public isManager {
        uint8 mId = 3;
        bytes32 taskHash = keccak256(abi.encode(_nftAddress, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        authorizedERC721[_nftAddress] = true;
    }
    
    function deauthorizeNFT(address _nftAddress, bytes memory _sig) public isManager {
        uint8 mId = 4;
        bytes32 taskHash = keccak256(abi.encode(_nftAddress, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        authorizedERC721[_nftAddress] = false;
    }
    
    function setFeesContract(address _contract, bytes memory _sig) public isManager {
        uint8 mId = 5;
        bytes32 taskHash = keccak256(abi.encode(_contract, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        feesContract = FeesContract(_contract);
    }
    
    function setWallet(address _wallet, bytes memory _sig) public isManager  {
        uint8 mId = 6;
        bytes32 taskHash = keccak256(abi.encode(_wallet, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        walletAddress = payable(_wallet);
    }
    
    function verifyApproval(bytes32 _taskHash, bytes memory _sig) private {
        require(executedTask[_taskHash] == false, "Task already executed");
        address mSigner = ECDSA.recover(ECDSA.toEthSignedMessageHash(_taskHash), _sig);
        require(mSigner == managers[0] || mSigner == managers[1] || mSigner == managers[2], "Invalid signature"  );
        require(mSigner != msg.sender, "Signature from different managers required");
        executedTask[_taskHash] = true;
        taskIndex += 1;
    }
    
    function changeManager(address _manager, uint8 _index, bytes memory _sig) public isManager {
        require(_index >= 0 && _index <= 2, "Invalid index");
        uint8 mId = 100;
        bytes32 taskHash = keccak256(abi.encode(_manager, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        managers[_index] = _manager;
    }
    

}