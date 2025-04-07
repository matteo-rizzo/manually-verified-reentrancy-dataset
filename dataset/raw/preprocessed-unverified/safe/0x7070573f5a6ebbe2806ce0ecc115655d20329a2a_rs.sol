/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;












contract Market is Ownable {
    using EnumerableSet for EnumerableSet.Bytes32Set ;
    using EnumerableMap for EnumerableMap.UintToB32Map;
    
    struct Coin {
        address tokenAddress;
        string symbol;
        string name;
        bool active;
    }
    mapping (uint256 => Coin) public tradeCoins;
    
    struct Trade {
        uint256 indexedBy;
        address nftAddress;
        address seller;
        address buyer;
        uint256 assetId;
        uint256 start;
        uint256 end;
        uint256 stime;
        uint256 price;
        uint256 coinIndex;
        bool active; 
    }
    
    mapping (address => bool) public authorizedERC721;
    mapping (uint256 => bytes32) public tradeIndex;
    mapping (bytes32 => Trade) public trades;

    EnumerableMap.UintToB32Map private tradesMap;
    mapping (address => EnumerableSet.Bytes32Set) private userTrades;
    
    uint256 nextTrade;
    FeesContract feesContract;
    address payable walletAddress;
    
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
        
        walletAddress = payable(0xAD334543437EF71642Ee59285bAf2F4DAcBA613F);
        

    }
    
    function createTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end) public {
        require(authorizedERC721[_nftAddress] == true, "Unauthorized asset");
        require(tradeCoins[_coinIndex].active == true, "Invalid payment coin");
        require(_end == 0 || _end > block.timestamp, "Invalid end time");
        IERC721 nftContract = IERC721(_nftAddress);
        require(nftContract.ownerOf(_assetId) == msg.sender, "Only asset owner can sell");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Market needs operator approval");
        insertTrade(_nftAddress, _assetId, _price, _coinIndex, _end);
    }
    
    function insertTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end) private {
        Trade memory trade = Trade(nextTrade, _nftAddress, msg.sender, address(0x0), _assetId, block.timestamp, _end, 0, _price, _coinIndex, true);
        bytes32 tradeHash = keccak256(abi.encode(_nftAddress, _assetId, nextTrade));
        tradeIndex[nextTrade] = tradeHash;
        trades[tradeHash] = trade;
        tradesMap.set(nextTrade, tradeHash);
        userTrades[msg.sender].add(tradeHash);
        nextTrade += 1;
    }
    
    function allTradesCount() public view returns (uint256 count) {
        return (nextTrade);
    }

    function tradesCount() public view returns (uint256 count) {
        return (tradesMap.length());
    }
    
    function _getTrade(bytes32 _tradeId) private view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 start, uint256 end, uint256 soldDate, uint256 price, uint256 coinIndex, bool active) {
        Trade memory _trade = trades[_tradeId];
        return (
        _trade.indexedBy,
        _trade.nftAddress,
        _trade.seller,
        _trade.buyer,
        _trade.assetId,
        _trade.start,
        _trade.end,
        _trade.stime,
        _trade.price,
        _trade.coinIndex,
        _trade.active
        );

    }

    function getTrade(bytes32 _tradeId) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 start, uint256 end, uint256 soldDate, uint256 price, uint256 coinIndex, bool active) {
        return _getTrade(_tradeId);
    }
    
    function getTradeByIndex(uint256 _index) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 start, uint256 end, uint256 soldDate, uint256 price, uint256 coinIndex, bool active) {
        (, bytes32 tradeId) = tradesMap.at(_index);
        return _getTrade(tradeId);
    }

    function parseBytes(bytes memory data) private pure returns (bytes32){
        bytes32 parsed;
        assembly {parsed := mload(add(data, 32))}
        return parsed;
    }
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public returns (bool success) {
        bytes32 _tradeId = parseBytes(_extraData);
        Trade memory trade = trades[_tradeId];
        require(tradeCoins[trade.coinIndex].tokenAddress == _token, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(_value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByToken(trade.seller, tradeCoins[trade.coinIndex].tokenAddress , _value);
            IERC20Token erc20Token = IERC20Token(_token);  
            if (tradeFee > 0) {
                require(erc20Token.transferFrom(_from, trade.seller, (trade.price-tradeFee)), "ERC20 transfer fail");
                require(erc20Token.transferFrom(_from, walletAddress, (tradeFee)), "ERC20 transfer fail");
            } else {
                require(erc20Token.transferFrom(_from, trade.seller, (trade.price)), "ERC20 transfer fail");
            }
            executeTrade(_tradeId, _from, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function buyWithEth(bytes32 _tradeId) public payable returns (bool success) {
        Trade memory trade = trades[_tradeId];
        require(trade.coinIndex == 1, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(msg.value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByEth(trade.seller, msg.value);
            if (tradeFee > 0) {
                walletAddress.transfer(msg.value);
            }
            payable(trade.seller).transfer(msg.value-tradeFee);
            executeTrade(_tradeId, msg.sender, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function executeTrade(bytes32 _tradeId, address _buyer, address _seller, address _contract, uint256 _assetId) private {
        IERC721 nftToken = IERC721(_contract);
        nftToken.safeTransferFrom(_seller, _buyer, _assetId);
        trades[_tradeId].buyer = _buyer;
        trades[_tradeId].active = false;
        trades[_tradeId].stime = block.timestamp;
        userTrades[_seller].remove(_tradeId);
        tradesMap.remove(trades[_tradeId].indexedBy);
    }
    
    function verifyTrade(bytes32 _tradeId, address _seller, address _contract, uint256 _assetId, uint256 _endTime) private returns (bool _valid) {
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

    function cancelTrade(bytes32 _tradeId) public returns (bool success) {
        Trade memory trade = trades[_tradeId];
        require(trade.seller == msg.sender, "Only asset seller can cancel the trade");
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
        return true;
    }

    function adminCancelTrade(bytes32 _tradeId) public onlyOwner {
        Trade memory trade = trades[_tradeId];
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
    }
    
    function tradesCountOf(address _from) public view returns (uint256 _count) {
        return (userTrades[_from].length());
    }
    
    function tradeOfByIndex(address _from, uint256 _index) public view returns (bytes32 _trade) {
        return (userTrades[_from].at(_index));
    }
    
    function addCoin(uint256 _coinIndex, address _tokenAddress, string memory _tokenSymbol, string memory _tokenName, bool _active) public onlyOwner {
        tradeCoins[_coinIndex].tokenAddress = _tokenAddress;
        tradeCoins[_coinIndex].symbol = _tokenSymbol;
        tradeCoins[_coinIndex].name = _tokenName;
        tradeCoins[_coinIndex].active = _active;
    }

    function autorizenft(address _nftAddress) public onlyOwner {
        authorizedERC721[_nftAddress] = true;
    }
    
    function deautorizenft(address _nftAddress) public onlyOwner {
        authorizedERC721[_nftAddress] = false;
    }
    
    function setFeesContract(address _contract) public onlyOwner {
        feesContract = FeesContract(_contract);
    }
    
    function setWallet(address _wallet) public onlyOwner {
        walletAddress = payable(_wallet);
    }
    
}