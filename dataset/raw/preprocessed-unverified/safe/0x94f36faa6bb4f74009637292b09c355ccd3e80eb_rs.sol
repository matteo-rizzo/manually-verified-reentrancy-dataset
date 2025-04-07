pragma solidity 0.6.0;

/**
 * @title Price contract
 * @dev Price check and call
 */
contract Nest_3_OfferPrice{
    using SafeMath for uint256;
    using address_make_payable for address;
    using SafeERC20 for ERC20;
    
    Nest_3_VoteFactory _voteFactory;                                //  Voting contract
    ERC20 _nestToken;                                               //  NestToken
    Nest_NToken_TokenMapping _tokenMapping;                         //  NToken mapping
    Nest_3_OfferMain _offerMain;                                    //  Offering main contract
    Nest_3_Abonus _abonus;                                          //  Bonus pool
    address _nTokeOfferMain;                                        //  NToken offering main contract
    address _destructionAddress;                                    //  Destruction contract address
    address _nTokenAuction;                                         //  NToken auction contract address
    struct PriceInfo {                                              //  Block price
        uint256 ethAmount;                                          //  ETH amount
        uint256 erc20Amount;                                        //  Erc20 amount
        uint256 frontBlock;                                         //  Last effective block
        address offerOwner;                                         //  Offering address
    }
    struct TokenInfo {                                              //  Token offer information
        mapping(uint256 => PriceInfo) priceInfoList;                //  Block price list, block number => block price
        uint256 latestOffer;                                        //  Latest effective block
    }
    uint256 destructionAmount = 0 ether;                            //  Amount of NEST to destroy to call prices
    uint256 effectTime = 0 days;                                    //  Waiting time to start calling prices
    mapping(address => TokenInfo) _tokenInfo;                       //  Token offer information
    mapping(address => bool) _blocklist;                            //  Block list
    mapping(address => uint256) _addressEffect;                     //  Effective time of address to call prices 
    mapping(address => bool) _offerMainMapping;                     //  Offering contract mapping
    uint256 _priceCost = 0.01 ether;                                //  Call price fee

    //  Real-time price  token, ETH amount, erc20 amount
    event NowTokenPrice(address a, uint256 b, uint256 c);
    
    /**
    * @dev Initialization method
    * @param voteFactory Voting contract address
    */
    constructor (address voteFactory) public {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap;
        _offerMain = Nest_3_OfferMain(address(voteFactoryMap.checkAddress("nest.v3.offerMain")));
        _nTokeOfferMain = address(voteFactoryMap.checkAddress("nest.nToken.offerMain"));
        _abonus = Nest_3_Abonus(address(voteFactoryMap.checkAddress("nest.v3.abonus")));
        _destructionAddress = address(voteFactoryMap.checkAddress("nest.v3.destruction"));
        _nestToken = ERC20(address(voteFactoryMap.checkAddress("nest")));
        _tokenMapping = Nest_NToken_TokenMapping(address(voteFactoryMap.checkAddress("nest.nToken.tokenMapping")));
        _nTokenAuction = address(voteFactoryMap.checkAddress("nest.nToken.tokenAuction"));
        _offerMainMapping[address(_offerMain)] = true;
        _offerMainMapping[address(_nTokeOfferMain)] = true;
    }
    
    /**
    * @dev Modify voting contract
    * @param voteFactory Voting contract address
    */
    function changeMapping(address voteFactory) public onlyOwner {
        Nest_3_VoteFactory voteFactoryMap = Nest_3_VoteFactory(address(voteFactory));
        _voteFactory = voteFactoryMap;                                   
        _offerMain = Nest_3_OfferMain(address(voteFactoryMap.checkAddress("nest.v3.offerMain")));
        _nTokeOfferMain = address(voteFactoryMap.checkAddress("nest.nToken.offerMain"));
        _abonus = Nest_3_Abonus(address(voteFactoryMap.checkAddress("nest.v3.abonus")));
        _destructionAddress = address(voteFactoryMap.checkAddress("nest.v3.destruction"));
        _nestToken = ERC20(address(voteFactoryMap.checkAddress("nest")));
        _tokenMapping = Nest_NToken_TokenMapping(address(voteFactoryMap.checkAddress("nest.nToken.tokenMapping")));
        _nTokenAuction = address(voteFactoryMap.checkAddress("nest.nToken.tokenAuction"));
        _offerMainMapping[address(_offerMain)] = true;
        _offerMainMapping[address(_nTokeOfferMain)] = true;
    }
    
    /**
    * @dev Initialize token price charge parameters
    * @param tokenAddress Token address
    */
    function addPriceCost(address tokenAddress) public {
       
    }
    
    /**
    * @dev Add price
    * @param ethAmount ETH amount
    * @param tokenAmount Erc20 amount
    * @param endBlock Effective price block
    * @param tokenAddress Erc20 address
    * @param offerOwner Offering address
    */
    function addPrice(uint256 ethAmount, uint256 tokenAmount, uint256 endBlock, address tokenAddress, address offerOwner) public onlyOfferMain{
        // Add effective block price information
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        PriceInfo storage priceInfo = tokenInfo.priceInfoList[endBlock];
        priceInfo.ethAmount = priceInfo.ethAmount.add(ethAmount);
        priceInfo.erc20Amount = priceInfo.erc20Amount.add(tokenAmount);
        if (endBlock != tokenInfo.latestOffer) {
            // If different block offer
            priceInfo.frontBlock = tokenInfo.latestOffer;
            tokenInfo.latestOffer = endBlock;
        }
    }
    
    /**
    * @dev Price modification in taker orders
    * @param ethAmount ETH amount
    * @param tokenAmount Erc20 amount
    * @param tokenAddress Token address 
    * @param endBlock Block of effective price
    */
    function changePrice(uint256 ethAmount, uint256 tokenAmount, address tokenAddress, uint256 endBlock) public onlyOfferMain {
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        PriceInfo storage priceInfo = tokenInfo.priceInfoList[endBlock];
        priceInfo.ethAmount = priceInfo.ethAmount.sub(ethAmount);
        priceInfo.erc20Amount = priceInfo.erc20Amount.sub(tokenAmount);
    }
    
    /**
    * @dev Update and check the latest price
    * @param tokenAddress Token address
    * @return ethAmount ETH amount
    * @return erc20Amount Erc20 amount
    * @return blockNum Price block
    */
    function updateAndCheckPriceNow(address tokenAddress) public payable returns(uint256 ethAmount, uint256 erc20Amount, uint256 blockNum) {
        require(checkUseNestPrice(address(msg.sender)));
        mapping(uint256 => PriceInfo) storage priceInfoList = _tokenInfo[tokenAddress].priceInfoList;
        uint256 checkBlock = _tokenInfo[tokenAddress].latestOffer;
        while(checkBlock > 0 && (checkBlock >= block.number || priceInfoList[checkBlock].ethAmount == 0)) {
            checkBlock = priceInfoList[checkBlock].frontBlock;
        }
        require(checkBlock != 0);
        PriceInfo memory priceInfo = priceInfoList[checkBlock];
        address nToken = _tokenMapping.checkTokenMapping(tokenAddress);
        if (nToken == address(0x0)) {
            _abonus.switchToEth.value(_priceCost)(address(_nestToken));
        } else {
            _abonus.switchToEth.value(_priceCost)(address(nToken));
        }
        if (msg.value > _priceCost) {
            repayEth(address(msg.sender), msg.value.sub(_priceCost));
        }
        emit NowTokenPrice(tokenAddress,priceInfo.ethAmount, priceInfo.erc20Amount);
        return (priceInfo.ethAmount,priceInfo.erc20Amount, checkBlock);
    }
    
    /**
    * @dev Update and check the latest price-internal use
    * @param tokenAddress Token address
    * @return ethAmount ETH amount
    * @return erc20Amount Erc20 amount
    */
    function updateAndCheckPricePrivate(address tokenAddress) public view onlyOfferMain returns(uint256 ethAmount, uint256 erc20Amount) {
        mapping(uint256 => PriceInfo) storage priceInfoList = _tokenInfo[tokenAddress].priceInfoList;
        uint256 checkBlock = _tokenInfo[tokenAddress].latestOffer;
        while(checkBlock > 0 && (checkBlock >= block.number || priceInfoList[checkBlock].ethAmount == 0)) {
            checkBlock = priceInfoList[checkBlock].frontBlock;
        }
        if (checkBlock == 0) {
            return (0,0);
        }
        PriceInfo memory priceInfo = priceInfoList[checkBlock];
        return (priceInfo.ethAmount,priceInfo.erc20Amount);
    }
    
    /**
    * @dev Update and check the effective price list
    * @param tokenAddress Token address
    * @param num Number of prices to check
    * @return uint256[] price list
    */
    function updateAndCheckPriceList(address tokenAddress, uint256 num) public payable returns (uint256[] memory) {
        require(checkUseNestPrice(address(msg.sender)));
        mapping(uint256 => PriceInfo) storage priceInfoList = _tokenInfo[tokenAddress].priceInfoList;
        // Extract data
        uint256 length = num.mul(3);
        uint256 index = 0;
        uint256[] memory data = new uint256[](length);
        uint256 checkBlock = _tokenInfo[tokenAddress].latestOffer;
        while(index < length && checkBlock > 0){
            if (checkBlock < block.number && priceInfoList[checkBlock].ethAmount != 0) {
                // Add return data
                data[index++] = priceInfoList[checkBlock].ethAmount;
                data[index++] = priceInfoList[checkBlock].erc20Amount;
                data[index++] = checkBlock;
            }
            checkBlock = priceInfoList[checkBlock].frontBlock;
        }
        require(length == data.length);
        // Allocation
        address nToken = _tokenMapping.checkTokenMapping(tokenAddress);
        if (nToken == address(0x0)) {
            _abonus.switchToEth.value(_priceCost)(address(_nestToken));
        } else {
            _abonus.switchToEth.value(_priceCost)(address(nToken));
        }
        if (msg.value > _priceCost) {
            repayEth(address(msg.sender), msg.value.sub(_priceCost));
        }
        return data;
    }
    
    // Activate the price checking function
    function activation() public {
        _nestToken.safeTransferFrom(address(msg.sender), _destructionAddress, destructionAmount);
        _addressEffect[address(msg.sender)] = now.add(effectTime);
    }
    
    // Transfer ETH
    function repayEth(address accountAddress, uint256 asset) private {
        address payable addr = accountAddress.make_payable();
        addr.transfer(asset);
    }
    
    // Check block price - user account only
    function checkPriceForBlock(address tokenAddress, uint256 blockNum) public view returns (uint256 ethAmount, uint256 erc20Amount) {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        TokenInfo storage tokenInfo = _tokenInfo[tokenAddress];
        return (tokenInfo.priceInfoList[blockNum].ethAmount, tokenInfo.priceInfoList[blockNum].erc20Amount);
    }    
    
    // Check real-time price - user account only
    function checkPriceNow(address tokenAddress) public view returns (uint256 ethAmount, uint256 erc20Amount, uint256 blockNum) {
        require(address(msg.sender) == address(tx.origin), "It can't be a contract");
        mapping(uint256 => PriceInfo) storage priceInfoList = _tokenInfo[tokenAddress].priceInfoList;
        uint256 checkBlock = _tokenInfo[tokenAddress].latestOffer;
        while(checkBlock > 0 && (checkBlock >= block.number || priceInfoList[checkBlock].ethAmount == 0)) {
            checkBlock = priceInfoList[checkBlock].frontBlock;
        }
        if (checkBlock == 0) {
            return (0,0,0);
        }
        PriceInfo storage priceInfo = priceInfoList[checkBlock];
        return (priceInfo.ethAmount,priceInfo.erc20Amount, checkBlock);
    }
    
    // Check whether the price-checking functions can be called
    function checkUseNestPrice(address target) public view returns (bool) {
        if (!_blocklist[target] && _addressEffect[target] < now && _addressEffect[target] != 0) {
            return true;
        } else {
            return false;
        }
    }
    
    // Check whether the address is in the blocklist
    function checkBlocklist(address add) public view returns(bool) {
        return _blocklist[add];
    }
    
    // Check the amount of NEST to destroy to call prices
    function checkDestructionAmount() public view returns(uint256) {
        return destructionAmount;
    }
    
    // Check the waiting time to start calling prices
    function checkEffectTime() public view returns (uint256) {
        return effectTime;
    }
    
    // Check call price fee
    function checkPriceCost() public view returns (uint256) {
        return _priceCost;
    }
    
    // Modify the blocklist 
    function changeBlocklist(address add, bool isBlock) public onlyOwner {
        _blocklist[add] = isBlock;
    }
    
    // Amount of NEST to destroy to call price-checking functions
    function changeDestructionAmount(uint256 amount) public onlyOwner {
        destructionAmount = amount;
    }
    
    // Modify the waiting time to start calling prices
    function changeEffectTime(uint256 num) public onlyOwner {
        effectTime = num;
    }
    
    // Modify call price fee
    function changePriceCost(uint256 num) public onlyOwner {
        _priceCost = num;
    }

    // Offering contract only
    modifier onlyOfferMain(){
        require(_offerMainMapping[address(msg.sender)], "No authority");
        _;
    }
    
    // Vote administrators only
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender), "No authority");
        _;
    }
}

// Voting contract


// NToken mapping contract


// NEST offer main contract


// Bonus pool contract










