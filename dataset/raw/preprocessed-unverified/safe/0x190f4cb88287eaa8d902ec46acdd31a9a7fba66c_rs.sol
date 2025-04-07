/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.25;



contract IStdToken {

    function balanceOf(address _owner) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

}



contract EtheramaCommon {

    

    //main adrministrators of the Etherama network

    mapping(address => bool) private _administrators;



    //main managers of the Etherama network

    mapping(address => bool) private _managers;



    

    modifier onlyAdministrator() {

        require(_administrators[msg.sender]);

        _;

    }



    modifier onlyAdministratorOrManager() {

        require(_administrators[msg.sender] || _managers[msg.sender]);

        _;

    }

    

    constructor() public {

        _administrators[msg.sender] = true;

    }

    

    

    function addAdministator(address addr) onlyAdministrator public {

        _administrators[addr] = true;

    }



    function removeAdministator(address addr) onlyAdministrator public {

        _administrators[addr] = false;

    }



    function isAdministrator(address addr) public view returns (bool) {

        return _administrators[addr];

    }



    function addManager(address addr) onlyAdministrator public {

        _managers[addr] = true;

    }



    function removeManager(address addr) onlyAdministrator public {

        _managers[addr] = false;

    }

    

    function isManager(address addr) public view returns (bool) {

        return _managers[addr];

    }

}





contract EtheramaGasPriceLimit is EtheramaCommon {

    

    uint256 public MAX_GAS_PRICE = 0 wei;

    

    event onSetMaxGasPrice(uint256 val);    

    

    //max gas price modifier for buy/sell transactions in order to avoid a "front runner" vulnerability.

    //It is applied to all network contracts

    modifier validGasPrice(uint256 val) {

        require(val > 0);

        _;

    }

    

    constructor(uint256 maxGasPrice) public validGasPrice(maxGasPrice) {

        setMaxGasPrice(maxGasPrice);

    } 

    

    

    //only main administators or managers can set max gas price

    function setMaxGasPrice(uint256 val) public validGasPrice(val) onlyAdministratorOrManager {

        MAX_GAS_PRICE = val;

        

        emit onSetMaxGasPrice(val);

    }

}



// Core contract for Etherama network

contract EtheramaCore is EtheramaGasPriceLimit {

    

    uint256 constant public MAGNITUDE = 2**64;



    // Max and min amount of tokens which can be bought or sold. There are such limits because of math precision

    uint256 constant public MIN_TOKEN_DEAL_VAL = 0.1 ether;

    uint256 constant public MAX_TOKEN_DEAL_VAL = 1000000 ether;



    // same same for ETH

    uint256 constant public MIN_ETH_DEAL_VAL = 0.001 ether;

    uint256 constant public MAX_ETH_DEAL_VAL = 200000 ether;

    

    // percent of a transaction commission which is taken for Big Promo bonus

    uint256 public _bigPromoPercent = 5 ether;



    // percent of a transaction commission which is taken for Quick Promo bonus

    uint256 public _quickPromoPercent = 5 ether;



    // percent of a transaction commission which is taken for Etherama DEV team

    uint256 public _devRewardPercent = 15 ether;

    

    // percent of a transaction commission which is taken for Token Owner. 

    uint256 public _tokenOwnerRewardPercent = 30 ether;



    // percent of a transaction commission which is taken for share reward. Each token holder receives a small reward from each buy or sell transaction proportionally his holding. 

    uint256 public _shareRewardPercent = 25 ether;



    // percent of a transaction commission which is taken for a feraral link owner. If there is no any referal then this part of commission goes to share reward.

    uint256 public _refBonusPercent = 20 ether;



    // interval of blocks for Big Promo bonus. It means that a user which buy a bunch of tokens for X ETH in that particular block will receive a special bonus 

    uint128 public _bigPromoBlockInterval = 9999;



    // same same for Quick Promo

    uint128 public _quickPromoBlockInterval = 100;

    

    // minimum eth amount of a purchase which is required to participate in promo.

    uint256 public _promoMinPurchaseEth = 1 ether;

    

    // minimum eth purchase which is required to get a referal link.

    uint256 public _minRefEthPurchase = 0.5 ether;



    // percent of fee which is supposed to distribute.

    uint256 public _totalIncomeFeePercent = 100 ether;



    // current collected big promo bonus

    uint256 public _currentBigPromoBonus;

    // current collected quick promo bonus

    uint256 public _currentQuickPromoBonus;

    

    uint256 public _devReward;



    

    uint256 public _initBlockNum;



    mapping(address => bool) private _controllerContracts;

    mapping(uint256 => address) private _controllerIndexer;

    uint256 private _controllerContractCount;

    

    //user token balances per data contracts

    mapping(address => mapping(address => uint256)) private _userTokenLocalBalances;

    //user reward payouts per data contracts

    mapping(address => mapping(address => uint256)) private _rewardPayouts;

    //user ref rewards per data contracts

    mapping(address => mapping(address => uint256)) private _refBalances;

    //user won quick promo bonuses per data contracts

    mapping(address => mapping(address => uint256)) private _promoQuickBonuses;

    //user won big promo bonuses per data contracts

    mapping(address => mapping(address => uint256)) private _promoBigBonuses;  

    //user saldo between buys and sels in eth per data contracts

    mapping(address => mapping(address => uint256)) private _userEthVolumeSaldos;  



    //bonuses per share per data contracts

    mapping(address => uint256) private _bonusesPerShare;

    //buy counts per data contracts

    mapping(address => uint256) private _buyCounts;

    //sell counts per data contracts

    mapping(address => uint256) private _sellCounts;

    //total volume eth per data contracts

    mapping(address => uint256) private _totalVolumeEth;

    //total volume tokens per data contracts

    mapping(address => uint256) private _totalVolumeToken;



    

    event onWithdrawUserBonus(address indexed userAddress, uint256 ethWithdrawn); 





    modifier onlyController() {

        require(_controllerContracts[msg.sender]);

        _;

    }

    

    constructor(uint256 maxGasPrice) EtheramaGasPriceLimit(maxGasPrice) public { 

         _initBlockNum = block.number;

    }

    

    function getInitBlockNum() public view returns (uint256) {

        return _initBlockNum;

    }

    

    function addControllerContract(address addr) onlyAdministrator public {

        _controllerContracts[addr] = true;

        _controllerIndexer[_controllerContractCount] = addr;

        _controllerContractCount = SafeMath.add(_controllerContractCount, 1);

    }



    function removeControllerContract(address addr) onlyAdministrator public {

        _controllerContracts[addr] = false;

    }

    

    function changeControllerContract(address oldAddr, address newAddress) onlyAdministrator public {

         _controllerContracts[oldAddr] = false;

         _controllerContracts[newAddress] = true;

    }

    

    function setBigPromoInterval(uint128 val) onlyAdministrator public {

        _bigPromoBlockInterval = val;

    }



    function setQuickPromoInterval(uint128 val) onlyAdministrator public {

        _quickPromoBlockInterval = val;

    }

    

    function addBigPromoBonus() onlyController payable public {

        _currentBigPromoBonus = SafeMath.add(_currentBigPromoBonus, msg.value);

    }

    

    function addQuickPromoBonus() onlyController payable public {

        _currentQuickPromoBonus = SafeMath.add(_currentQuickPromoBonus, msg.value);

    }

    

    

    function setPromoMinPurchaseEth(uint256 val) onlyAdministrator public {

        _promoMinPurchaseEth = val;

    }

    

    function setMinRefEthPurchase(uint256 val) onlyAdministrator public {

        _minRefEthPurchase = val;

    }

    

    function setTotalIncomeFeePercent(uint256 val) onlyController public {

        require(val > 0 && val <= 100 ether);



        _totalIncomeFeePercent = val;

    }

        

    

    // set reward persentages of buy/sell fee. Token owner cannot take more than 40%.

    function setRewardPercentages(uint256 tokenOwnerRewardPercent, uint256 shareRewardPercent, uint256 refBonusPercent, uint256 bigPromoPercent, uint256 quickPromoPercent) onlyAdministrator public {

        require(tokenOwnerRewardPercent <= 40 ether);

        require(shareRewardPercent <= 100 ether);

        require(refBonusPercent <= 100 ether);

        require(bigPromoPercent <= 100 ether);

        require(quickPromoPercent <= 100 ether);



        require(tokenOwnerRewardPercent + shareRewardPercent + refBonusPercent + _devRewardPercent + _bigPromoPercent + _quickPromoPercent == 100 ether);



        _tokenOwnerRewardPercent = tokenOwnerRewardPercent;

        _shareRewardPercent = shareRewardPercent;

        _refBonusPercent = refBonusPercent;

        _bigPromoPercent = bigPromoPercent;

        _quickPromoPercent = quickPromoPercent;

    }    

    

    

    function payoutQuickBonus(address userAddress) onlyController public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _promoQuickBonuses[dataContractAddress][userAddress] = SafeMath.add(_promoQuickBonuses[dataContractAddress][userAddress], _currentQuickPromoBonus);

        _currentQuickPromoBonus = 0;

    }

    

    function payoutBigBonus(address userAddress) onlyController public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _promoBigBonuses[dataContractAddress][userAddress] = SafeMath.add(_promoBigBonuses[dataContractAddress][userAddress], _currentBigPromoBonus);

        _currentBigPromoBonus = 0;

    }



    function addDevReward() onlyController payable public {

        _devReward = SafeMath.add(_devReward, msg.value);

    }    

    

    function withdrawDevReward() onlyAdministrator public {

        uint256 reward = _devReward;

        _devReward = 0;



        msg.sender.transfer(reward);

    }

    

    function getBlockNumSinceInit() public view returns(uint256) {

        return block.number - getInitBlockNum();

    }



    function getQuickPromoRemainingBlocks() public view returns(uint256) {

        uint256 d = getBlockNumSinceInit() % _quickPromoBlockInterval;

        d = d == 0 ? _quickPromoBlockInterval : d;



        return _quickPromoBlockInterval - d;

    }



    function getBigPromoRemainingBlocks() public view returns(uint256) {

        uint256 d = getBlockNumSinceInit() % _bigPromoBlockInterval;

        d = d == 0 ? _bigPromoBlockInterval : d;



        return _bigPromoBlockInterval - d;

    } 

    

    

    function getBonusPerShare(address dataContractAddress) public view returns(uint256) {

        return _bonusesPerShare[dataContractAddress];

    }

    

    function getTotalBonusPerShare() public view returns (uint256 res) {

        for (uint256 i = 0; i < _controllerContractCount; i++) {

            res = SafeMath.add(res, _bonusesPerShare[Etherama(_controllerIndexer[i]).getDataContractAddress()]);

        }          

    }

    

    

    function addBonusPerShare() onlyController payable public {

        EtheramaData data = Etherama(msg.sender)._data();

        uint256 shareBonus = (msg.value * MAGNITUDE) / data.getTotalTokenSold();

        

        _bonusesPerShare[address(data)] = SafeMath.add(_bonusesPerShare[address(data)], shareBonus);

    }        

 

    function getUserRefBalance(address dataContractAddress, address userAddress) public view returns(uint256) {

        return _refBalances[dataContractAddress][userAddress];

    }

    

    function getUserRewardPayouts(address dataContractAddress, address userAddress) public view returns(uint256) {

        return _rewardPayouts[dataContractAddress][userAddress];

    }    



    function resetUserRefBalance(address userAddress) onlyController public {

        resetUserRefBalance(Etherama(msg.sender).getDataContractAddress(), userAddress);

    }

    

    function resetUserRefBalance(address dataContractAddress, address userAddress) internal {

        _refBalances[dataContractAddress][userAddress] = 0;

    }

    

    function addUserRefBalance(address userAddress) onlyController payable public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _refBalances[dataContractAddress][userAddress] = SafeMath.add(_refBalances[dataContractAddress][userAddress], msg.value);

    }



    function addUserRewardPayouts(address userAddress, uint256 val) onlyController public {

        addUserRewardPayouts(Etherama(msg.sender).getDataContractAddress(), userAddress, val);

    }    



    function addUserRewardPayouts(address dataContractAddress, address userAddress, uint256 val) internal {

        _rewardPayouts[dataContractAddress][userAddress] = SafeMath.add(_rewardPayouts[dataContractAddress][userAddress], val);

    }



    function resetUserPromoBonus(address userAddress) onlyController public {

        resetUserPromoBonus(Etherama(msg.sender).getDataContractAddress(), userAddress);

    }

    

    function resetUserPromoBonus(address dataContractAddress, address userAddress) internal {

        _promoQuickBonuses[dataContractAddress][userAddress] = 0;

        _promoBigBonuses[dataContractAddress][userAddress] = 0;

    }

    

    

    function trackBuy(address userAddress, uint256 volEth, uint256 volToken) onlyController public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _buyCounts[dataContractAddress] = SafeMath.add(_buyCounts[dataContractAddress], 1);

        _userEthVolumeSaldos[dataContractAddress][userAddress] = SafeMath.add(_userEthVolumeSaldos[dataContractAddress][userAddress], volEth);

        

        trackTotalVolume(dataContractAddress, volEth, volToken);

    }



    function trackSell(address userAddress, uint256 volEth, uint256 volToken) onlyController public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _sellCounts[dataContractAddress] = SafeMath.add(_sellCounts[dataContractAddress], 1);

        _userEthVolumeSaldos[dataContractAddress][userAddress] = SafeMath.sub(_userEthVolumeSaldos[dataContractAddress][userAddress], volEth);

        

        trackTotalVolume(dataContractAddress, volEth, volToken);

    }

    

    function trackTotalVolume(address dataContractAddress, uint256 volEth, uint256 volToken) internal {

        _totalVolumeEth[dataContractAddress] = SafeMath.add(_totalVolumeEth[dataContractAddress], volEth);

        _totalVolumeToken[dataContractAddress] = SafeMath.add(_totalVolumeToken[dataContractAddress], volToken);

    }

    

    function getBuyCount(address dataContractAddress) public view returns (uint256) {

        return _buyCounts[dataContractAddress];

    }

    

    function getTotalBuyCount() public view returns (uint256 res) {

        for (uint256 i = 0; i < _controllerContractCount; i++) {

            res = SafeMath.add(res, _buyCounts[Etherama(_controllerIndexer[i]).getDataContractAddress()]);

        }         

    }

    

    function getSellCount(address dataContractAddress) public view returns (uint256) {

        return _sellCounts[dataContractAddress];

    }

    

    function getTotalSellCount() public view returns (uint256 res) {

        for (uint256 i = 0; i < _controllerContractCount; i++) {

            res = SafeMath.add(res, _sellCounts[Etherama(_controllerIndexer[i]).getDataContractAddress()]);

        }         

    }



    function getTotalVolumeEth(address dataContractAddress) public view returns (uint256) {

        return _totalVolumeEth[dataContractAddress];

    }

    

    function getTotalVolumeToken(address dataContractAddress) public view returns (uint256) {

        return _totalVolumeToken[dataContractAddress];

    }



    function getUserEthVolumeSaldo(address dataContractAddress, address userAddress) public view returns (uint256) {

        return _userEthVolumeSaldos[dataContractAddress][userAddress];

    }

    

    function getUserTotalEthVolumeSaldo(address userAddress) public view returns (uint256 res) {

        for (uint256 i = 0; i < _controllerContractCount; i++) {

            res = SafeMath.add(res, _userEthVolumeSaldos[Etherama(_controllerIndexer[i]).getDataContractAddress()][userAddress]);

        } 

    }

    

    function getTotalCollectedPromoBonus() public view returns (uint256) {

        return SafeMath.add(_currentBigPromoBonus, _currentQuickPromoBonus);

    }



    function getUserTotalPromoBonus(address dataContractAddress, address userAddress) public view returns (uint256) {

        return SafeMath.add(_promoQuickBonuses[dataContractAddress][userAddress], _promoBigBonuses[dataContractAddress][userAddress]);

    }

    

    function getUserQuickPromoBonus(address dataContractAddress, address userAddress) public view returns (uint256) {

        return _promoQuickBonuses[dataContractAddress][userAddress];

    }

    

    function getUserBigPromoBonus(address dataContractAddress, address userAddress) public view returns (uint256) {

        return _promoBigBonuses[dataContractAddress][userAddress];

    }



    

    function getUserTokenLocalBalance(address dataContractAddress, address userAddress) public view returns(uint256) {

        return _userTokenLocalBalances[dataContractAddress][userAddress];

    }

  

    

    function addUserTokenLocalBalance(address userAddress, uint256 val) onlyController public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _userTokenLocalBalances[dataContractAddress][userAddress] = SafeMath.add(_userTokenLocalBalances[dataContractAddress][userAddress], val);

    }

    

    function subUserTokenLocalBalance(address userAddress, uint256 val) onlyController public {

        address dataContractAddress = Etherama(msg.sender).getDataContractAddress();

        _userTokenLocalBalances[dataContractAddress][userAddress] = SafeMath.sub(_userTokenLocalBalances[dataContractAddress][userAddress], val);

    }



  

    function getUserReward(address dataContractAddress, address userAddress, bool incShareBonus, bool incRefBonus, bool incPromoBonus) public view returns(uint256 reward) {

        EtheramaData data = EtheramaData(dataContractAddress);

        

        if (incShareBonus) {

            reward = data.getBonusPerShare() * data.getActualUserTokenBalance(userAddress);

            reward = ((reward < data.getUserRewardPayouts(userAddress)) ? 0 : SafeMath.sub(reward, data.getUserRewardPayouts(userAddress))) / MAGNITUDE;

        }

        

        if (incRefBonus) reward = SafeMath.add(reward, data.getUserRefBalance(userAddress));

        if (incPromoBonus) reward = SafeMath.add(reward, data.getUserTotalPromoBonus(userAddress));

        

        return reward;

    }

    

    //user's total reward from all the tokens on the table. includes share reward + referal bonus + promo bonus

    function getUserTotalReward(address userAddress, bool incShareBonus, bool incRefBonus, bool incPromoBonus) public view returns(uint256 res) {

        for (uint256 i = 0; i < _controllerContractCount; i++) {

            address dataContractAddress = Etherama(_controllerIndexer[i]).getDataContractAddress();

            

            res = SafeMath.add(res, getUserReward(dataContractAddress, userAddress, incShareBonus, incRefBonus, incPromoBonus));

        }

    }

    

    //current user's reward

    function getCurrentUserReward(bool incRefBonus, bool incPromoBonus) public view returns(uint256) {

        return getUserTotalReward(msg.sender, true, incRefBonus, incPromoBonus);

    }

 

    //current user's total reward from all the tokens on the table

    function getCurrentUserTotalReward() public view returns(uint256) {

        return getUserTotalReward(msg.sender, true, true, true);

    }

    

    //user's share bonus from all the tokens on the table

    function getCurrentUserShareBonus() public view returns(uint256) {

        return getUserTotalReward(msg.sender, true, false, false);

    }

    

    //current user's ref bonus from all the tokens on the table

    function getCurrentUserRefBonus() public view returns(uint256) {

        return getUserTotalReward(msg.sender, false, true, false);

    }

    

    //current user's promo bonus from all the tokens on the table

    function getCurrentUserPromoBonus() public view returns(uint256) {

        return getUserTotalReward(msg.sender, false, false, true);

    }

    

    //is ref link available for the user

    function isRefAvailable(address refAddress) public view returns(bool) {

        return getUserTotalEthVolumeSaldo(refAddress) >= _minRefEthPurchase;

    }

    

    //is ref link available for the current user

    function isRefAvailable() public view returns(bool) {

        return isRefAvailable(msg.sender);

    }

    

     //Withdraws all of the user earnings.

    function withdrawUserReward() public {

        uint256 reward = getRewardAndPrepareWithdraw();

        

        require(reward > 0);

        

        msg.sender.transfer(reward);

        

        emit onWithdrawUserBonus(msg.sender, reward);

    }



    //gather all the user's reward and prepare it to withdaw

    function getRewardAndPrepareWithdraw() internal returns(uint256 reward) {

        

        for (uint256 i = 0; i < _controllerContractCount; i++) {



            address dataContractAddress = Etherama(_controllerIndexer[i]).getDataContractAddress();

            

            reward = SafeMath.add(reward, getUserReward(dataContractAddress, msg.sender, true, false, false));



            // add share reward to payouts

            addUserRewardPayouts(dataContractAddress, msg.sender, reward * MAGNITUDE);



            // add ref bonus

            reward = SafeMath.add(reward, getUserRefBalance(dataContractAddress, msg.sender));

            resetUserRefBalance(dataContractAddress, msg.sender);

            

            // add promo bonus

            reward = SafeMath.add(reward, getUserTotalPromoBonus(dataContractAddress, msg.sender));

            resetUserPromoBonus(dataContractAddress, msg.sender);

        }

        

        return reward;

    }

    

    //withdaw all the remamining ETH if there is no one active contract. We don't want to leave them here forever

    function withdrawRemainingEthAfterAll() onlyAdministrator public {

        for (uint256 i = 0; i < _controllerContractCount; i++) {

            if (Etherama(_controllerIndexer[i]).isActive()) revert();

        }

        

        msg.sender.transfer(address(this).balance);

    }



    

    

    function calcPercent(uint256 amount, uint256 percent) public pure returns(uint256) {

        return SafeMath.div(SafeMath.mul(SafeMath.div(amount, 100), percent), 1 ether);

    }



    //Converts real num to uint256. Works only with positive numbers.

    function convertRealTo256(int128 realVal) public pure returns(uint256) {

        int128 roundedVal = RealMath.fromReal(RealMath.mul(realVal, RealMath.toReal(1e12)));



        return SafeMath.mul(uint256(roundedVal), uint256(1e6));

    }



    //Converts uint256 to real num. Possible a little loose of precision

    function convert256ToReal(uint256 val) public pure returns(int128) {

        uint256 intVal = SafeMath.div(val, 1e6);

        require(RealMath.isUInt256ValidIn64(intVal));

        

        return RealMath.fraction(int64(intVal), 1e12);

    }    

}



// Data contract for Etherama contract controller. Data contract cannot be changed so no data can be lost. On the other hand Etherama controller can be replaced if some error is found.

contract EtheramaData {



    address public _tokenContractAddress;

    

    // token price in the begining

    uint256 constant public TOKEN_PRICE_INITIAL = 0.001 ether;

    // a percent of the token price which adds/subs each _priceSpeedInterval tokens

    uint64 constant public PRICE_SPEED_PERCENT = 5;

    // Token price speed interval. For instance, if PRICE_SPEED_PERCENT = 5 and PRICE_SPEED_INTERVAL = 10000 it means that after 10000 tokens are bought/sold  token price will increase/decrease for 5%.

    uint64 constant public PRICE_SPEED_INTERVAL = 10000;

    // lock-up period in days. Until this period is expeired nobody can close the contract or withdraw users' funds

    uint64 constant public EXP_PERIOD_DAYS = 365;



    

    mapping(address => bool) private _administrators;

    uint256 private  _administratorCount;



    uint64 public _initTime;

    uint64 public _expirationTime;

    uint256 public _tokenOwnerReward;

    

    uint256 public _totalSupply;

    int128 public _realTokenPrice;



    address public _controllerAddress = address(0x0);



    EtheramaCore public _core;



    uint256 public _initBlockNum;

    

    bool public _hasMaxPurchaseLimit = false;

    

    IStdToken public _token;



    //only main contract

    modifier onlyController() {

        require(msg.sender == _controllerAddress);

        _;

    }



    constructor(address coreAddress) public {

        require(coreAddress != address(0x0));



        _core = EtheramaCore(coreAddress);

        _initBlockNum = block.number;

    }

    

    function init(address tokenContractAddress) public {

        require(_controllerAddress == address(0x0));

        require(tokenContractAddress != address(0x0));

        require(EXP_PERIOD_DAYS > 0);

        require(RealMath.isUInt64ValidIn64(PRICE_SPEED_PERCENT) && PRICE_SPEED_PERCENT > 0);

        require(RealMath.isUInt64ValidIn64(PRICE_SPEED_INTERVAL) && PRICE_SPEED_INTERVAL > 0);

        

        

        _controllerAddress = msg.sender;



        _token = IStdToken(tokenContractAddress);

        _initTime = uint64(now);

        _expirationTime = _initTime + EXP_PERIOD_DAYS * 1 days;

        _realTokenPrice = _core.convert256ToReal(TOKEN_PRICE_INITIAL);

    }

    

    function isInited()  public view returns(bool) {

        return (_controllerAddress != address(0x0));

    }

    

    function getCoreAddress()  public view returns(address) {

        return address(_core);

    }

    



    function setNewControllerAddress(address newAddress) onlyController public {

        _controllerAddress = newAddress;

    }





    

    function getPromoMinPurchaseEth() public view returns(uint256) {

        return _core._promoMinPurchaseEth();

    }



    function addAdministator(address addr) onlyController public {

        _administrators[addr] = true;

        _administratorCount = SafeMath.add(_administratorCount, 1);

    }



    function removeAdministator(address addr) onlyController public {

        _administrators[addr] = false;

        _administratorCount = SafeMath.sub(_administratorCount, 1);

    }



    function getAdministratorCount() public view returns(uint256) {

        return _administratorCount;

    }

    

    function isAdministrator(address addr) public view returns(bool) {

        return _administrators[addr];

    }



    

    function getCommonInitBlockNum() public view returns (uint256) {

        return _core.getInitBlockNum();

    }

    

    

    function resetTokenOwnerReward() onlyController public {

        _tokenOwnerReward = 0;

    }

    

    function addTokenOwnerReward(uint256 val) onlyController public {

        _tokenOwnerReward = SafeMath.add(_tokenOwnerReward, val);

    }

    

    function getCurrentBigPromoBonus() public view returns (uint256) {

        return _core._currentBigPromoBonus();

    }        

    



    function getCurrentQuickPromoBonus() public view returns (uint256) {

        return _core._currentQuickPromoBonus();

    }    



    function getTotalCollectedPromoBonus() public view returns (uint256) {

        return _core.getTotalCollectedPromoBonus();

    }    



    function setTotalSupply(uint256 val) onlyController public {

        _totalSupply = val;

    }

    

    function setRealTokenPrice(int128 val) onlyController public {

        _realTokenPrice = val;

    }    

    

    

    function setHasMaxPurchaseLimit(bool val) onlyController public {

        _hasMaxPurchaseLimit = val;

    }

    

    function getUserTokenLocalBalance(address userAddress) public view returns(uint256) {

        return _core.getUserTokenLocalBalance(address(this), userAddress);

    }

    

    function getActualUserTokenBalance(address userAddress) public view returns(uint256) {

        return SafeMath.min(getUserTokenLocalBalance(userAddress), _token.balanceOf(userAddress));

    }  

    

    function getBonusPerShare() public view returns(uint256) {

        return _core.getBonusPerShare(address(this));

    }

    

    function getUserRewardPayouts(address userAddress) public view returns(uint256) {

        return _core.getUserRewardPayouts(address(this), userAddress);

    }

    

    function getUserRefBalance(address userAddress) public view returns(uint256) {

        return _core.getUserRefBalance(address(this), userAddress);

    }

    

    function getUserReward(address userAddress, bool incRefBonus, bool incPromoBonus) public view returns(uint256) {

        return _core.getUserReward(address(this), userAddress, true, incRefBonus, incPromoBonus);

    }

    

    function getUserTotalPromoBonus(address userAddress) public view returns(uint256) {

        return _core.getUserTotalPromoBonus(address(this), userAddress);

    }

    

    function getUserBigPromoBonus(address userAddress) public view returns(uint256) {

        return _core.getUserBigPromoBonus(address(this), userAddress);

    }



    function getUserQuickPromoBonus(address userAddress) public view returns(uint256) {

        return _core.getUserQuickPromoBonus(address(this), userAddress);

    }



    function getRemainingTokenAmount() public view returns(uint256) {

        return _token.balanceOf(_controllerAddress);

    }



    function getTotalTokenSold() public view returns(uint256) {

        return _totalSupply - getRemainingTokenAmount();

    }   

    

    function getUserEthVolumeSaldo(address userAddress) public view returns(uint256) {

        return _core.getUserEthVolumeSaldo(address(this), userAddress);

    }



}





contract Etherama {



    IStdToken public _token;

    EtheramaData public _data;

    EtheramaCore public _core;





    bool public isActive = false;

    bool public isMigrationToNewControllerInProgress = false;

    bool public isActualContractVer = true;

    address public migrationContractAddress = address(0x0);

    bool public isMigrationApproved = false;



    address private _creator = address(0x0);

    



    event onTokenPurchase(address indexed userAddress, uint256 incomingEth, uint256 tokensMinted, address indexed referredBy);

    

    event onTokenSell(address indexed userAddress, uint256 tokensBurned, uint256 ethEarned);

    

    event onReinvestment(address indexed userAddress, uint256 ethReinvested, uint256 tokensMinted);

    

    event onWithdrawTokenOwnerReward(address indexed toAddress, uint256 ethWithdrawn); 



    event onWinQuickPromo(address indexed userAddress, uint256 ethWon);    

   

    event onWinBigPromo(address indexed userAddress, uint256 ethWon);    





    // only people with tokens

    modifier onlyContractUsers() {

        require(getUserLocalTokenBalance(msg.sender) > 0);

        _;

    }

    



    // administrators can:

    // -> change minimal amout of tokens to get a ref link.

    // administrators CANNOT:

    // -> take funds

    // -> disable withdrawals

    // -> kill the contract

    // -> change the price of tokens

    // -> suspend the contract

    modifier onlyAdministrator() {

        require(isCurrentUserAdministrator());

        _;

    }

    

    //core administrator can only approve contract migration after its code review

    modifier onlyCoreAdministrator() {

        require(_core.isAdministrator(msg.sender));

        _;

    }



    // only active state of the contract. Administator can activate it, but canncon deactive untill lock-up period is expired.

    modifier onlyActive() {

        require(isActive);

        _;

    }



    // maximum gas price for buy/sell transactions to avoid "front runner" vulnerability.   

    modifier validGasPrice() {

        require(tx.gasprice <= _core.MAX_GAS_PRICE());

        _;

    }

    

    // eth value must be greater than 0 for purchase transactions

    modifier validPayableValue() {

        require(msg.value > 0);

        _;

    }

    

    modifier onlyCoreContract() {

        require(msg.sender == _data.getCoreAddress());

        _;

    }



    // tokenContractAddress - tranding token address

    // dataContractAddress - data contract address where all the data is collected and separated from the controller

    constructor(address tokenContractAddress, address dataContractAddress) public {

        

        require(dataContractAddress != address(0x0));

        _data = EtheramaData(dataContractAddress);

        

        if (!_data.isInited()) {

            _data.init(tokenContractAddress);

            _data.addAdministator(msg.sender);

            _creator = msg.sender;

        }

        

        _token = _data._token();

        _core = _data._core();

    }







    function addAdministator(address addr) onlyAdministrator public {

        _data.addAdministator(addr);

    }



    function removeAdministator(address addr) onlyAdministrator public {

        _data.removeAdministator(addr);

    }



    // transfer ownership request of the contract to token owner from contract creator. The new administator has to accept ownership to finish the transferring.

    function transferOwnershipRequest(address addr) onlyAdministrator public {

        addAdministator(addr);

    }



    // accept transfer ownership.

    function acceptOwnership() onlyAdministrator public {

        require(_creator != address(0x0));



        removeAdministator(_creator);



        require(_data.getAdministratorCount() == 1);

    }

    

    // if there is a maximim purchase limit then a user can buy only amount of tokens which he had before, not more.

    function setHasMaxPurchaseLimit(bool val) onlyAdministrator public {

        _data.setHasMaxPurchaseLimit(val);

    }

        

    // activate the controller contract. After calling this function anybody can start trading the contrant's tokens

    function activate() onlyAdministrator public {

        require(!isActive);

        

        if (getTotalTokenSupply() == 0) setTotalSupply();

        require(getTotalTokenSupply() > 0);

        

        isActive = true;

        isMigrationToNewControllerInProgress = false;

    }



    // Close the contract and withdraw all the funds. The contract cannot be closed before lock up period is expired.

    function finish() onlyActive onlyAdministrator public {

        require(uint64(now) >= _data._expirationTime());

        

        _token.transfer(msg.sender, getRemainingTokenAmount());   

        msg.sender.transfer(getTotalEthBalance());

        

        isActive = false;

    }

    

    //Converts incoming eth to tokens

    function buy(address refAddress, uint256 minReturn) onlyActive validGasPrice validPayableValue public payable returns(uint256) {

        return purchaseTokens(msg.value, refAddress, minReturn);

    }



    //sell tokens for eth. before call this func you have to call "approve" in the ERC20 token contract

    function sell(uint256 tokenAmount, uint256 minReturn) onlyActive onlyContractUsers validGasPrice public returns(uint256) {

        if (tokenAmount > getCurrentUserLocalTokenBalance() || tokenAmount == 0) return 0;



        uint256 ethAmount = 0; uint256 totalFeeEth = 0; uint256 tokenPrice = 0;

        (ethAmount, totalFeeEth, tokenPrice) = estimateSellOrder(tokenAmount, true);

        require(ethAmount >= minReturn);



        subUserTokens(msg.sender, tokenAmount);



        msg.sender.transfer(ethAmount);



        updateTokenPrice(-_core.convert256ToReal(tokenAmount));



        distributeFee(totalFeeEth, address(0x0));



        _core.trackSell(msg.sender, ethAmount, tokenAmount);

       

        emit onTokenSell(msg.sender, tokenAmount, ethAmount);



        return ethAmount;

    }   





    //Fallback function to handle eth that was sent straight to the contract

    function() onlyActive validGasPrice validPayableValue payable external {

        purchaseTokens(msg.value, address(0x0), 1);

    }



    // withdraw token owner's reward

    function withdrawTokenOwnerReward() onlyAdministrator public {

        uint256 reward = getTokenOwnerReward();

        

        require(reward > 0);

        

        _data.resetTokenOwnerReward();



        msg.sender.transfer(reward);



        emit onWithdrawTokenOwnerReward(msg.sender, reward);

    }



    // prepare the contract for migration to another one in case of some errors or refining

    function prepareForMigration() onlyAdministrator public {

        require(!isMigrationToNewControllerInProgress);

        isMigrationToNewControllerInProgress = true;

    }



    // accept funds transfer to a new controller during a migration.

    function migrateFunds() payable public {

        require(isMigrationToNewControllerInProgress);

    }

    



    //HELPERS



    // max gas price for buy/sell transactions  

    function getMaxGasPrice() public view returns(uint256) {

        return _core.MAX_GAS_PRICE();

    }



    // max gas price for buy/sell transactions

    function getExpirationTime() public view returns (uint256) {

        return _data._expirationTime();

    }

            

    // time till lock-up period is expired 

    function getRemainingTimeTillExpiration() public view returns (uint256) {

        if (_data._expirationTime() <= uint64(now)) return 0;

        

        return _data._expirationTime() - uint64(now);

    }



    

    function isCurrentUserAdministrator() public view returns(bool) {

        return _data.isAdministrator(msg.sender);

    }



    //data contract address where all the data is holded

    function getDataContractAddress() public view returns(address) {

        return address(_data);

    }



    // get trading token contract address

    function getTokenAddress() public view returns(address) {

        return address(_token);

    }



    // request migration to new contract. After request Etherama dev team should review its code and approve it if it is OK

    function requestControllerContractMigration(address newControllerAddr) onlyAdministrator public {

        require(!isMigrationApproved);

        

        migrationContractAddress = newControllerAddr;

    }

    

    // Dev team gives a pervission to updagrade the contract after code review, transfer all the funds, activate new abilities or fix some errors.

    function approveControllerContractMigration() onlyCoreAdministrator public {

        isMigrationApproved = true;

    }

    

    //migrate to new controller contract in case of some mistake in the contract and transfer there all the tokens and eth. It can be done only after code review by Etherama developers.

    function migrateToNewNewControllerContract() onlyAdministrator public {

        require(isMigrationApproved && migrationContractAddress != address(0x0) && isActualContractVer);

        

        isActive = false;



        Etherama newController = Etherama(address(migrationContractAddress));

        _data.setNewControllerAddress(migrationContractAddress);



        uint256 remainingTokenAmount = getRemainingTokenAmount();

        uint256 ethBalance = getTotalEthBalance();



        if (remainingTokenAmount > 0) _token.transfer(migrationContractAddress, remainingTokenAmount); 

        if (ethBalance > 0) newController.migrateFunds.value(ethBalance)();

        

        isActualContractVer = false;

    }



    //total buy count

    function getBuyCount() public view returns(uint256) {

        return _core.getBuyCount(getDataContractAddress());

    }

    //total sell count

    function getSellCount() public view returns(uint256) {

        return _core.getSellCount(getDataContractAddress());

    }

    //total eth volume

    function getTotalVolumeEth() public view returns(uint256) {

        return _core.getTotalVolumeEth(getDataContractAddress());

    }   

    //total token volume

    function getTotalVolumeToken() public view returns(uint256) {

        return _core.getTotalVolumeToken(getDataContractAddress());

    } 

    //current bonus per 1 token in ETH

    function getBonusPerShare() public view returns (uint256) {

        return SafeMath.div(SafeMath.mul(_data.getBonusPerShare(), 1 ether), _core.MAGNITUDE());

    }    

    //token initial price in ETH

    function getTokenInitialPrice() public view returns(uint256) {

        return _data.TOKEN_PRICE_INITIAL();

    }



    function getDevRewardPercent() public view returns(uint256) {

        return _core._devRewardPercent();

    }



    function getTokenOwnerRewardPercent() public view returns(uint256) {

        return _core._tokenOwnerRewardPercent();

    }

    

    function getShareRewardPercent() public view returns(uint256) {

        return _core._shareRewardPercent();

    }

    

    function getRefBonusPercent() public view returns(uint256) {

        return _core._refBonusPercent();

    }

    

    function getBigPromoPercent() public view returns(uint256) {

        return _core._bigPromoPercent();

    }

    

    function getQuickPromoPercent() public view returns(uint256) {

        return _core._quickPromoPercent();

    }



    function getBigPromoBlockInterval() public view returns(uint256) {

        return _core._bigPromoBlockInterval();

    }



    function getQuickPromoBlockInterval() public view returns(uint256) {

        return _core._quickPromoBlockInterval();

    }



    function getPromoMinPurchaseEth() public view returns(uint256) {

        return _core._promoMinPurchaseEth();

    }





    function getPriceSpeedPercent() public view returns(uint64) {

        return _data.PRICE_SPEED_PERCENT();

    }



    function getPriceSpeedTokenBlock() public view returns(uint64) {

        return _data.PRICE_SPEED_INTERVAL();

    }



    function getMinRefEthPurchase() public view returns (uint256) {

        return _core._minRefEthPurchase();

    }    



    function getTotalCollectedPromoBonus() public view returns (uint256) {

        return _data.getTotalCollectedPromoBonus();

    }   



    function getCurrentBigPromoBonus() public view returns (uint256) {

        return _data.getCurrentBigPromoBonus();

    }  



    function getCurrentQuickPromoBonus() public view returns (uint256) {

        return _data.getCurrentQuickPromoBonus();

    }    



    //current token price

    function getCurrentTokenPrice() public view returns(uint256) {

        return _core.convertRealTo256(_data._realTokenPrice());

    }



    //contract's eth balance

    function getTotalEthBalance() public view returns(uint256) {

        return address(this).balance;

    }

    

    //amount of tokens which were funded to the contract initially

    function getTotalTokenSupply() public view returns(uint256) {

        return _data._totalSupply();

    }



    //amount of tokens which are still available for selling on the contract

    function getRemainingTokenAmount() public view returns(uint256) {

        return _token.balanceOf(address(this));

    }

    

    //amount of tokens which where sold by the contract

    function getTotalTokenSold() public view returns(uint256) {

        return getTotalTokenSupply() - getRemainingTokenAmount();

    }

    

    //user's token amount which were bought from the contract

    function getUserLocalTokenBalance(address userAddress) public view returns(uint256) {

        return _data.getUserTokenLocalBalance(userAddress);

    }

    

    //current user's token amount which were bought from the contract

    function getCurrentUserLocalTokenBalance() public view returns(uint256) {

        return getUserLocalTokenBalance(msg.sender);

    }    



    //is referal link available for the current user

    function isCurrentUserRefAvailable() public view returns(bool) {

        return _core.isRefAvailable();

    }





    function getCurrentUserRefBonus() public view returns(uint256) {

        return _data.getUserRefBalance(msg.sender);

    }

    

    function getCurrentUserPromoBonus() public view returns(uint256) {

        return _data.getUserTotalPromoBonus(msg.sender);

    }

    

    //max and min values of a deal in tokens

    function getTokenDealRange() public view returns(uint256, uint256) {

        return (_core.MIN_TOKEN_DEAL_VAL(), _core.MAX_TOKEN_DEAL_VAL());

    }

    

    //max and min values of a deal in ETH

    function getEthDealRange() public view returns(uint256, uint256) {

        uint256 minTokenVal; uint256 maxTokenVal;

        (minTokenVal, maxTokenVal) = getTokenDealRange();

        

        return ( SafeMath.max(_core.MIN_ETH_DEAL_VAL(), tokensToEth(minTokenVal, true)), SafeMath.min(_core.MAX_ETH_DEAL_VAL(), tokensToEth(maxTokenVal, true)) );

    }

    

    //user's total reward from all the tokens on the table. includes share reward + referal bonus + promo bonus

    function getUserReward(address userAddress, bool isTotal) public view returns(uint256) {

        return isTotal ? 

            _core.getUserTotalReward(userAddress, true, true, true) :

            _data.getUserReward(userAddress, true, true);

    }

    

    //price for selling 1 token. mostly useful only for frontend

    function get1TokenSellPrice() public view returns(uint256) {

        uint256 tokenAmount = 1 ether;



        uint256 ethAmount = 0; uint256 totalFeeEth = 0; uint256 tokenPrice = 0;

        (ethAmount, totalFeeEth, tokenPrice) = estimateSellOrder(tokenAmount, true);



        return ethAmount;

    }

    

    //price for buying 1 token. mostly useful only for frontend

    function get1TokenBuyPrice() public view returns(uint256) {

        uint256 ethAmount = 1 ether;



        uint256 tokenAmount = 0; uint256 totalFeeEth = 0; uint256 tokenPrice = 0;

        (tokenAmount, totalFeeEth, tokenPrice) = estimateBuyOrder(ethAmount, true);  



        return SafeMath.div(ethAmount * 1 ether, tokenAmount);

    }



    //calc current reward for holding @tokenAmount tokens

    function calcReward(uint256 tokenAmount) public view returns(uint256) {

        return (uint256) ((int256)(_data.getBonusPerShare() * tokenAmount)) / _core.MAGNITUDE();

    }  



    //esimate buy order by amount of ETH/tokens. returns tokens/eth amount after the deal, total fee in ETH and average token price

    function estimateBuyOrder(uint256 amount, bool fromEth) public view returns(uint256, uint256, uint256) {

        uint256 minAmount; uint256 maxAmount;

        (minAmount, maxAmount) = fromEth ? getEthDealRange() : getTokenDealRange();

        //require(amount >= minAmount && amount <= maxAmount);



        uint256 ethAmount = fromEth ? amount : tokensToEth(amount, true);

        require(ethAmount > 0);



        uint256 tokenAmount = fromEth ? ethToTokens(amount, true) : amount;

        uint256 totalFeeEth = calcTotalFee(tokenAmount, true);

        require(ethAmount > totalFeeEth);



        uint256 tokenPrice = SafeMath.div(ethAmount * 1 ether, tokenAmount);



        return (fromEth ? tokenAmount : SafeMath.add(ethAmount, totalFeeEth), totalFeeEth, tokenPrice);

    }

    

    //esimate sell order by amount of tokens/ETH. returns eth/tokens amount after the deal, total fee in ETH and average token price

    function estimateSellOrder(uint256 amount, bool fromToken) public view returns(uint256, uint256, uint256) {

        uint256 minAmount; uint256 maxAmount;

        (minAmount, maxAmount) = fromToken ? getTokenDealRange() : getEthDealRange();

        //require(amount >= minAmount && amount <= maxAmount);



        uint256 tokenAmount = fromToken ? amount : ethToTokens(amount, false);

        require(tokenAmount > 0);

        

        uint256 ethAmount = fromToken ? tokensToEth(tokenAmount, false) : amount;

        uint256 totalFeeEth = calcTotalFee(tokenAmount, false);

        require(ethAmount > totalFeeEth);



        uint256 tokenPrice = SafeMath.div(ethAmount * 1 ether, tokenAmount);

        

        return (fromToken ? ethAmount : tokenAmount, totalFeeEth, tokenPrice);

    }



    //returns max user's purchase limit in tokens if _hasMaxPurchaseLimit pamam is set true. If it is a user cannot by more tokens that hs already bought on some other exchange

    function getUserMaxPurchase(address userAddress) public view returns(uint256) {

        return _token.balanceOf(userAddress) - SafeMath.mul(getUserLocalTokenBalance(userAddress), 2);

    }

    //current urser's max purchase limit in tokens

    function getCurrentUserMaxPurchase() public view returns(uint256) {

        return getUserMaxPurchase(msg.sender);

    }



    //token owener collected reward

    function getTokenOwnerReward() public view returns(uint256) {

        return _data._tokenOwnerReward();

    }



    //current user's won promo bonuses

    function getCurrentUserTotalPromoBonus() public view returns(uint256) {

        return _data.getUserTotalPromoBonus(msg.sender);

    }



    //current user's won big promo bonuses

    function getCurrentUserBigPromoBonus() public view returns(uint256) {

        return _data.getUserBigPromoBonus(msg.sender);

    }

    //current user's won quick promo bonuses

    function getCurrentUserQuickPromoBonus() public view returns(uint256) {

        return _data.getUserQuickPromoBonus(msg.sender);

    }

   

    //amount of block since core contract is deployed

    function getBlockNumSinceInit() public view returns(uint256) {

        return _core.getBlockNumSinceInit();

    }



    //remaing amount of blocks to win a quick promo bonus

    function getQuickPromoRemainingBlocks() public view returns(uint256) {

        return _core.getQuickPromoRemainingBlocks();

    }

    //remaing amount of blocks to win a big promo bonus

    function getBigPromoRemainingBlocks() public view returns(uint256) {

        return _core.getBigPromoRemainingBlocks();

    } 

    

    

    // INTERNAL FUNCTIONS

    

    function purchaseTokens(uint256 ethAmount, address refAddress, uint256 minReturn) internal returns(uint256) {

        uint256 tokenAmount = 0; uint256 totalFeeEth = 0; uint256 tokenPrice = 0;

        (tokenAmount, totalFeeEth, tokenPrice) = estimateBuyOrder(ethAmount, true);

        require(tokenAmount >= minReturn);



        if (_data._hasMaxPurchaseLimit()) {

            //user has to have at least equal amount of tokens which he's willing to buy 

            require(getCurrentUserMaxPurchase() >= tokenAmount);

        }



        require(tokenAmount > 0 && (SafeMath.add(tokenAmount, getTotalTokenSold()) > getTotalTokenSold()));



        if (refAddress == msg.sender || !_core.isRefAvailable(refAddress)) refAddress = address(0x0);



        distributeFee(totalFeeEth, refAddress);



        addUserTokens(msg.sender, tokenAmount);



        // the user is not going to receive any reward for the current purchase

        _core.addUserRewardPayouts(msg.sender, _data.getBonusPerShare() * tokenAmount);



        checkAndSendPromoBonus(ethAmount);

        

        updateTokenPrice(_core.convert256ToReal(tokenAmount));

        

        _core.trackBuy(msg.sender, ethAmount, tokenAmount);



        emit onTokenPurchase(msg.sender, ethAmount, tokenAmount, refAddress);

        

        return tokenAmount;

    }



    function setTotalSupply() internal {

        require(_data._totalSupply() == 0);



        uint256 tokenAmount = _token.balanceOf(address(this));



        _data.setTotalSupply(tokenAmount);

    }





    function checkAndSendPromoBonus(uint256 purchaseAmountEth) internal {

        if (purchaseAmountEth < _data.getPromoMinPurchaseEth()) return;



        if (getQuickPromoRemainingBlocks() == 0) sendQuickPromoBonus();

        if (getBigPromoRemainingBlocks() == 0) sendBigPromoBonus();

    }



    function sendQuickPromoBonus() internal {

        _core.payoutQuickBonus(msg.sender);



        emit onWinQuickPromo(msg.sender, _data.getCurrentQuickPromoBonus());

    }



    function sendBigPromoBonus() internal {

        _core.payoutBigBonus(msg.sender);



        emit onWinBigPromo(msg.sender, _data.getCurrentBigPromoBonus());

    }



    function distributeFee(uint256 totalFeeEth, address refAddress) internal {

        addProfitPerShare(totalFeeEth, refAddress);

        addDevReward(totalFeeEth);

        addTokenOwnerReward(totalFeeEth);

        addBigPromoBonus(totalFeeEth);

        addQuickPromoBonus(totalFeeEth);

    }



    function addProfitPerShare(uint256 totalFeeEth, address refAddress) internal {

        uint256 refBonus = calcRefBonus(totalFeeEth);

        uint256 totalShareReward = calcTotalShareRewardFee(totalFeeEth);



        if (refAddress != address(0x0)) {

            _core.addUserRefBalance.value(refBonus)(refAddress);

        } else {

            totalShareReward = SafeMath.add(totalShareReward, refBonus);

        }



        if (getTotalTokenSold() == 0) {

            _data.addTokenOwnerReward(totalShareReward);

        } else {

            _core.addBonusPerShare.value(totalShareReward)();

        }

    }



    function addDevReward(uint256 totalFeeEth) internal {

        _core.addDevReward.value(calcDevReward(totalFeeEth))();

    }    

    

    function addTokenOwnerReward(uint256 totalFeeEth) internal {

        _data.addTokenOwnerReward(calcTokenOwnerReward(totalFeeEth));

    }  



    function addBigPromoBonus(uint256 totalFeeEth) internal {

        _core.addBigPromoBonus.value(calcBigPromoBonus(totalFeeEth))();

    }



    function addQuickPromoBonus(uint256 totalFeeEth) internal {

        _core.addQuickPromoBonus.value(calcQuickPromoBonus(totalFeeEth))();

    }   





    function addUserTokens(address user, uint256 tokenAmount) internal {

        _core.addUserTokenLocalBalance(user, tokenAmount);

        _token.transfer(msg.sender, tokenAmount);   

    }



    function subUserTokens(address user, uint256 tokenAmount) internal {

        _core.subUserTokenLocalBalance(user, tokenAmount);

        _token.transferFrom(user, address(this), tokenAmount);    

    }



    function updateTokenPrice(int128 realTokenAmount) public {

        _data.setRealTokenPrice(calc1RealTokenRateFromRealTokens(realTokenAmount));

    }



    function ethToTokens(uint256 ethAmount, bool isBuy) internal view returns(uint256) {

        int128 realEthAmount = _core.convert256ToReal(ethAmount);

        int128 t0 = RealMath.div(realEthAmount, _data._realTokenPrice());

        int128 s = getRealPriceSpeed();



        int128 tn =  RealMath.div(t0, RealMath.toReal(100));



        for (uint i = 0; i < 100; i++) {



            int128 tns = RealMath.mul(tn, s);

            int128 exptns = RealMath.exp( RealMath.mul(tns, RealMath.toReal(isBuy ? int64(1) : int64(-1))) );



            int128 tn1 = RealMath.div(

                RealMath.mul( RealMath.mul(tns, tn), exptns ) + t0,

                RealMath.mul( exptns, RealMath.toReal(1) + tns )

            );



            if (RealMath.abs(tn-tn1) < RealMath.fraction(1, 1e18)) break;



            tn = tn1;

        }



        return _core.convertRealTo256(tn);

    }



    function tokensToEth(uint256 tokenAmount, bool isBuy) internal view returns(uint256) {

        int128 realTokenAmount = _core.convert256ToReal(tokenAmount);

        int128 s = getRealPriceSpeed();

        int128 expArg = RealMath.mul(RealMath.mul(realTokenAmount, s), RealMath.toReal(isBuy ? int64(1) : int64(-1)));

        

        int128 realEthAmountFor1Token = RealMath.mul(_data._realTokenPrice(), RealMath.exp(expArg));

        int128 realEthAmount = RealMath.mul(realTokenAmount, realEthAmountFor1Token);



        return _core.convertRealTo256(realEthAmount);

    }



    function calcTotalFee(uint256 tokenAmount, bool isBuy) internal view returns(uint256) {

        int128 realTokenAmount = _core.convert256ToReal(tokenAmount);

        int128 factor = RealMath.toReal(isBuy ? int64(1) : int64(-1));

        int128 rateAfterDeal = calc1RealTokenRateFromRealTokens(RealMath.mul(realTokenAmount, factor));

        int128 delta = RealMath.div(rateAfterDeal - _data._realTokenPrice(), RealMath.toReal(2));

        int128 fee = RealMath.mul(realTokenAmount, delta);

        

        //commission for sells is a bit lower due to rounding error

        if (!isBuy) fee = RealMath.mul(fee, RealMath.fraction(95, 100));



        return _core.calcPercent(_core.convertRealTo256(RealMath.mul(fee, factor)), _core._totalIncomeFeePercent());

    }







    function calc1RealTokenRateFromRealTokens(int128 realTokenAmount) internal view returns(int128) {

        int128 expArg = RealMath.mul(realTokenAmount, getRealPriceSpeed());



        return RealMath.mul(_data._realTokenPrice(), RealMath.exp(expArg));

    }

    

    function getRealPriceSpeed() internal view returns(int128) {

        require(RealMath.isUInt64ValidIn64(_data.PRICE_SPEED_PERCENT()));

        require(RealMath.isUInt64ValidIn64(_data.PRICE_SPEED_INTERVAL()));

        

        return RealMath.div(RealMath.fraction(int64(_data.PRICE_SPEED_PERCENT()), 100), RealMath.toReal(int64(_data.PRICE_SPEED_INTERVAL())));

    }





    function calcTotalShareRewardFee(uint256 totalFee) internal view returns(uint256) {

        return _core.calcPercent(totalFee, _core._shareRewardPercent());

    }

    

    function calcRefBonus(uint256 totalFee) internal view returns(uint256) {

        return _core.calcPercent(totalFee, _core._refBonusPercent());

    }

    

    function calcTokenOwnerReward(uint256 totalFee) internal view returns(uint256) {

        return _core.calcPercent(totalFee, _core._tokenOwnerRewardPercent());

    }



    function calcDevReward(uint256 totalFee) internal view returns(uint256) {

        return _core.calcPercent(totalFee, _core._devRewardPercent());

    }



    function calcQuickPromoBonus(uint256 totalFee) internal view returns(uint256) {

        return _core.calcPercent(totalFee, _core._quickPromoPercent());

    }    



    function calcBigPromoBonus(uint256 totalFee) internal view returns(uint256) {

        return _core.calcPercent(totalFee, _core._bigPromoPercent());

    }        





}









//taken from https://github.com/NovakDistributed/macroverse/blob/master/contracts/RealMath.sol and a bit modified

