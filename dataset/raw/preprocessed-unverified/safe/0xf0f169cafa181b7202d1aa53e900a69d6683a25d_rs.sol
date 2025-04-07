pragma solidity ^0.4.19;

// File: contracts/BdpBaseData.sol

contract BdpBaseData {

	address public ownerAddress;

	address public managerAddress;

	address[16] public contracts;

	bool public paused = false;

	bool public setupCompleted = false;

	bytes8 public version;

}

// File: contracts/libraries/BdpContracts.sol



// File: contracts/BdpBase.sol

contract BdpBase is BdpBaseData {

	modifier onlyOwner() {
		require(msg.sender == ownerAddress);
		_;
	}

	modifier onlyAuthorized() {
		require(msg.sender == ownerAddress || msg.sender == managerAddress);
		_;
	}

	modifier whileContractIsActive() {
		require(!paused && setupCompleted);
		_;
	}

	modifier storageAccessControl() {
		require(
			(! setupCompleted && (msg.sender == ownerAddress || msg.sender == managerAddress))
			|| (setupCompleted && !paused && (msg.sender == BdpContracts.getBdpEntryPoint(contracts)))
		);
		_;
	}

	function setOwner(address _newOwner) external onlyOwner {
		require(_newOwner != address(0));
		ownerAddress = _newOwner;
	}

	function setManager(address _newManager) external onlyOwner {
		require(_newManager != address(0));
		managerAddress = _newManager;
	}

	function setContracts(address[16] _contracts) external onlyOwner {
		contracts = _contracts;
	}

	function pause() external onlyAuthorized {
		paused = true;
	}

	function unpause() external onlyOwner {
		paused = false;
	}

	function setSetupCompleted() external onlyOwner {
		setupCompleted = true;
	}

	function kill() public onlyOwner {
		selfdestruct(ownerAddress);
	}

}

// File: contracts/libraries/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: contracts/storage/BdpDataStorage.sol

contract BdpDataStorage is BdpBase {

	using SafeMath for uint256;

	struct Region {
		uint256 x1;
		uint256 y1;
		uint256 x2;
		uint256 y2;
		uint256 currentImageId;
		uint256 nextImageId;
		uint8[128] url;
		uint256 currentPixelPrice;
		uint256 blockUpdatedAt;
		uint256 updatedAt;
		uint256 purchasedAt;
		uint256 purchasedPixelPrice;
	}

	uint256 public lastRegionId = 0;

	mapping (uint256 => Region) public data;


	function getLastRegionId() view public returns (uint256) {
		return lastRegionId;
	}

	function getNextRegionId() public storageAccessControl returns (uint256) {
		lastRegionId = lastRegionId.add(1);
		return lastRegionId;
	}

	function deleteRegionData(uint256 _id) public storageAccessControl {
		delete data[_id];
	}

	function getRegionCoordinates(uint256 _id) view public returns (uint256, uint256, uint256, uint256) {
		return (data[_id].x1, data[_id].y1, data[_id].x2, data[_id].y2);
	}

	function setRegionCoordinates(uint256 _id, uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2) public storageAccessControl {
		data[_id].x1 = _x1;
		data[_id].y1 = _y1;
		data[_id].x2 = _x2;
		data[_id].y2 = _y2;
	}

	function getRegionCurrentImageId(uint256 _id) view public returns (uint256) {
		return data[_id].currentImageId;
	}

	function setRegionCurrentImageId(uint256 _id, uint256 _currentImageId) public storageAccessControl {
		data[_id].currentImageId = _currentImageId;
	}

	function getRegionNextImageId(uint256 _id) view public returns (uint256) {
		return data[_id].nextImageId;
	}

	function setRegionNextImageId(uint256 _id, uint256 _nextImageId) public storageAccessControl {
		data[_id].nextImageId = _nextImageId;
	}

	function getRegionUrl(uint256 _id) view public returns (uint8[128]) {
		return data[_id].url;
	}

	function setRegionUrl(uint256 _id, uint8[128] _url) public storageAccessControl {
		data[_id].url = _url;
	}

	function getRegionCurrentPixelPrice(uint256 _id) view public returns (uint256) {
		return data[_id].currentPixelPrice;
	}

	function setRegionCurrentPixelPrice(uint256 _id, uint256 _currentPixelPrice) public storageAccessControl {
		data[_id].currentPixelPrice = _currentPixelPrice;
	}

	function getRegionBlockUpdatedAt(uint256 _id) view public returns (uint256) {
		return data[_id].blockUpdatedAt;
	}

	function setRegionBlockUpdatedAt(uint256 _id, uint256 _blockUpdatedAt) public storageAccessControl {
		data[_id].blockUpdatedAt = _blockUpdatedAt;
	}

	function getRegionUpdatedAt(uint256 _id) view public returns (uint256) {
		return data[_id].updatedAt;
	}

	function setRegionUpdatedAt(uint256 _id, uint256 _updatedAt) public storageAccessControl {
		data[_id].updatedAt = _updatedAt;
	}

	function getRegionPurchasedAt(uint256 _id) view public returns (uint256) {
		return data[_id].purchasedAt;
	}

	function setRegionPurchasedAt(uint256 _id, uint256 _purchasedAt) public storageAccessControl {
		data[_id].purchasedAt = _purchasedAt;
	}

	function getRegionUpdatedAtPurchasedAt(uint256 _id) view public returns (uint256 _updatedAt, uint256 _purchasedAt) {
		return (data[_id].updatedAt, data[_id].purchasedAt);
	}

	function getRegionPurchasePixelPrice(uint256 _id) view public returns (uint256) {
		return data[_id].purchasedPixelPrice;
	}

	function setRegionPurchasedPixelPrice(uint256 _id, uint256 _purchasedPixelPrice) public storageAccessControl {
		data[_id].purchasedPixelPrice = _purchasedPixelPrice;
	}

	function BdpDataStorage(bytes8 _version) public {
		ownerAddress = msg.sender;
		managerAddress = msg.sender;
		version = _version;
	}

}

// File: contracts/storage/BdpImageStorage.sol

contract BdpImageStorage is BdpBase {

	using SafeMath for uint256;

	struct Image {
		address owner;
		uint256 regionId;
		uint256 currentRegionId;
		mapping(uint16 => uint256[1000]) data;
		mapping(uint16 => uint16) dataLength;
		uint16 partsCount;
		uint16 width;
		uint16 height;
		uint16 imageDescriptor;
		uint256 blurredAt;
	}

	uint256 public lastImageId = 0;

	mapping(uint256 => Image) public images;


	function getLastImageId() view public returns (uint256) {
		return lastImageId;
	}

	function getNextImageId() public storageAccessControl returns (uint256) {
		lastImageId = lastImageId.add(1);
		return lastImageId;
	}

	function createImage(address _owner, uint256 _regionId, uint16 _width, uint16 _height, uint16 _partsCount, uint16 _imageDescriptor) public storageAccessControl returns (uint256) {
		require(_owner != address(0) && _width > 0 && _height > 0 && _partsCount > 0 && _imageDescriptor > 0);
		uint256 id = getNextImageId();
		images[id].owner = _owner;
		images[id].regionId = _regionId;
		images[id].width = _width;
		images[id].height = _height;
		images[id].partsCount = _partsCount;
		images[id].imageDescriptor = _imageDescriptor;
		return id;
	}

	function imageExists(uint256 _imageId) view public returns (bool) {
		return _imageId > 0 && images[_imageId].owner != address(0);
	}

	function deleteImage(uint256 _imageId) public storageAccessControl {
		require(imageExists(_imageId));
		delete images[_imageId];
	}

	function getImageOwner(uint256 _imageId) public view returns (address) {
		require(imageExists(_imageId));
		return images[_imageId].owner;
	}

	function setImageOwner(uint256 _imageId, address _owner) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].owner = _owner;
	}

	function getImageRegionId(uint256 _imageId) public view returns (uint256) {
		require(imageExists(_imageId));
		return images[_imageId].regionId;
	}

	function setImageRegionId(uint256 _imageId, uint256 _regionId) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].regionId = _regionId;
	}

	function getImageCurrentRegionId(uint256 _imageId) public view returns (uint256) {
		require(imageExists(_imageId));
		return images[_imageId].currentRegionId;
	}

	function setImageCurrentRegionId(uint256 _imageId, uint256 _currentRegionId) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].currentRegionId = _currentRegionId;
	}

	function getImageData(uint256 _imageId, uint16 _part) view public returns (uint256[1000]) {
		require(imageExists(_imageId));
		return images[_imageId].data[_part];
	}

	function setImageData(uint256 _imageId, uint16 _part, uint256[] _data) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].dataLength[_part] = uint16(_data.length);
		for (uint256 i = 0; i < _data.length; i++) {
			images[_imageId].data[_part][i] = _data[i];
		}
	}

	function getImageDataLength(uint256 _imageId, uint16 _part) view public returns (uint16) {
		require(imageExists(_imageId));
		return images[_imageId].dataLength[_part];
	}

	function setImageDataLength(uint256 _imageId, uint16 _part, uint16 _dataLength) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].dataLength[_part] = _dataLength;
	}

	function getImagePartsCount(uint256 _imageId) view public returns (uint16) {
		require(imageExists(_imageId));
		return images[_imageId].partsCount;
	}

	function setImagePartsCount(uint256 _imageId, uint16 _partsCount) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].partsCount = _partsCount;
	}

	function getImageWidth(uint256 _imageId) view public returns (uint16) {
		require(imageExists(_imageId));
		return images[_imageId].width;
	}

	function setImageWidth(uint256 _imageId, uint16 _width) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].width = _width;
	}

	function getImageHeight(uint256 _imageId) view public returns (uint16) {
		require(imageExists(_imageId));
		return images[_imageId].height;
	}

	function setImageHeight(uint256 _imageId, uint16 _height) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].height = _height;
	}

	function getImageDescriptor(uint256 _imageId) view public returns (uint16) {
		require(imageExists(_imageId));
		return images[_imageId].imageDescriptor;
	}

	function setImageDescriptor(uint256 _imageId, uint16 _imageDescriptor) public storageAccessControl {
		require(imageExists(_imageId));
		images[_imageId].imageDescriptor = _imageDescriptor;
	}

	function getImageBlurredAt(uint256 _imageId) view public returns (uint256) {
		return images[_imageId].blurredAt;
	}

	function setImageBlurredAt(uint256 _imageId, uint256 _blurredAt) public storageAccessControl {
		images[_imageId].blurredAt = _blurredAt;
	}

	function imageUploadComplete(uint256 _imageId) view public returns (bool) {
		require(imageExists(_imageId));
		for (uint16 i = 1; i <= images[_imageId].partsCount; i++) {
			if(images[_imageId].data[i].length == 0) {
				return false;
			}
		}
		return true;
	}

	function BdpImageStorage(bytes8 _version) public {
		ownerAddress = msg.sender;
		managerAddress = msg.sender;
		version = _version;
	}

}

// File: contracts/storage/BdpPriceStorage.sol

contract BdpPriceStorage is BdpBase {

	uint64[1001] public pricePoints;

	uint256 public pricePointsLength = 0;

	address public forwardPurchaseFeesTo = address(0);

	address public forwardUpdateFeesTo = address(0);


	function getPricePointsLength() view public returns (uint256) {
		return pricePointsLength;
	}

	function getPricePoint(uint256 _i) view public returns (uint256) {
		return pricePoints[_i];
	}

	function setPricePoints(uint64[] _pricePoints) public storageAccessControl {
		pricePointsLength = 0;
		appendPricePoints(_pricePoints);
	}

	function appendPricePoints(uint64[] _pricePoints) public storageAccessControl {
		for (uint i = 0; i < _pricePoints.length; i++) {
			pricePoints[pricePointsLength++] = _pricePoints[i];
		}
	}

	function getForwardPurchaseFeesTo() view public returns (address) {
		return forwardPurchaseFeesTo;
	}

	function setForwardPurchaseFeesTo(address _forwardPurchaseFeesTo) public storageAccessControl {
		forwardPurchaseFeesTo = _forwardPurchaseFeesTo;
	}

	function getForwardUpdateFeesTo() view public returns (address) {
		return forwardUpdateFeesTo;
	}

	function setForwardUpdateFeesTo(address _forwardUpdateFeesTo) public storageAccessControl {
		forwardUpdateFeesTo = _forwardUpdateFeesTo;
	}

	function BdpPriceStorage(bytes8 _version) public {
		ownerAddress = msg.sender;
		managerAddress = msg.sender;
		version = _version;
	}

}

// File: contracts/libraries/BdpCalculator.sol



// File: contracts/storage/BdpOwnershipStorage.sol

contract BdpOwnershipStorage is BdpBase {

	using SafeMath for uint256;

	// Mapping from token ID to owner
	mapping (uint256 => address) public tokenOwner;

	// Mapping from token ID to approved address
	mapping (uint256 => address) public tokenApprovals;

	// Mapping from owner to the sum of owned area
	mapping (address => uint256) public ownedArea;

	// Mapping from owner to list of owned token IDs
	mapping (address => uint256[]) public ownedTokens;

	// Mapping from token ID to index of the owner tokens list
	mapping(uint256 => uint256) public ownedTokensIndex;

	// All tokens list tokens ids
	uint256[] public tokenIds;

	// Mapping from tokenId to index of the tokens list
	mapping (uint256 => uint256) public tokenIdsIndex;


	function getTokenOwner(uint256 _tokenId) view public returns (address) {
		return tokenOwner[_tokenId];
	}

	function setTokenOwner(uint256 _tokenId, address _owner) public storageAccessControl {
		tokenOwner[_tokenId] = _owner;
	}

	function getTokenApproval(uint256 _tokenId) view public returns (address) {
		return tokenApprovals[_tokenId];
	}

	function setTokenApproval(uint256 _tokenId, address _to) public storageAccessControl {
		tokenApprovals[_tokenId] = _to;
	}

	function getOwnedArea(address _owner) view public returns (uint256) {
		return ownedArea[_owner];
	}

	function setOwnedArea(address _owner, uint256 _area) public storageAccessControl {
		ownedArea[_owner] = _area;
	}

	function incrementOwnedArea(address _owner, uint256 _area) public storageAccessControl returns (uint256) {
		ownedArea[_owner] = ownedArea[_owner].add(_area);
		return ownedArea[_owner];
	}

	function decrementOwnedArea(address _owner, uint256 _area) public storageAccessControl returns (uint256) {
		ownedArea[_owner] = ownedArea[_owner].sub(_area);
		return ownedArea[_owner];
	}

	function getOwnedTokensLength(address _owner) view public returns (uint256) {
		return ownedTokens[_owner].length;
	}

	function getOwnedToken(address _owner, uint256 _index) view public returns (uint256) {
		return ownedTokens[_owner][_index];
	}

	function setOwnedToken(address _owner, uint256 _index, uint256 _tokenId) public storageAccessControl {
		ownedTokens[_owner][_index] = _tokenId;
	}

	function pushOwnedToken(address _owner, uint256 _tokenId) public storageAccessControl returns (uint256) {
		ownedTokens[_owner].push(_tokenId);
		return ownedTokens[_owner].length;
	}

	function decrementOwnedTokensLength(address _owner) public storageAccessControl {
		ownedTokens[_owner].length--;
	}

	function getOwnedTokensIndex(uint256 _tokenId) view public returns (uint256) {
		return ownedTokensIndex[_tokenId];
	}

	function setOwnedTokensIndex(uint256 _tokenId, uint256 _tokenIndex) public storageAccessControl {
		ownedTokensIndex[_tokenId] = _tokenIndex;
	}

	function getTokenIdsLength() view public returns (uint256) {
		return tokenIds.length;
	}

	function getTokenIdByIndex(uint256 _index) view public returns (uint256) {
		return tokenIds[_index];
	}

	function setTokenIdByIndex(uint256 _index, uint256 _tokenId) public storageAccessControl {
		tokenIds[_index] = _tokenId;
	}

	function pushTokenId(uint256 _tokenId) public storageAccessControl returns (uint256) {
		tokenIds.push(_tokenId);
		return tokenIds.length;
	}

	function decrementTokenIdsLength() public storageAccessControl {
		tokenIds.length--;
	}

	function getTokenIdsIndex(uint256 _tokenId) view public returns (uint256) {
		return tokenIdsIndex[_tokenId];
	}

	function setTokenIdsIndex(uint256 _tokenId, uint256 _tokenIdIndex) public storageAccessControl {
		tokenIdsIndex[_tokenId] = _tokenIdIndex;
	}

	function BdpOwnershipStorage(bytes8 _version) public {
		ownerAddress = msg.sender;
		managerAddress = msg.sender;
		version = _version;
	}

}

// File: contracts/libraries/BdpOwnership.sol

/**
 * Ownership manager
 * Does not check if the caller is allowed to call functions
 * State changing methods are not intended to be called from controller
 */


// File: contracts/libraries/BdpImage.sol



// File: contracts/libraries/BdpCrud.sol

