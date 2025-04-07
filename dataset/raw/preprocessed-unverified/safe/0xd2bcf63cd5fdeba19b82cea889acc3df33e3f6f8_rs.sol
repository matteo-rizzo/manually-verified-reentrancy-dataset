/**

 *Submitted for verification at Etherscan.io on 2018-09-13

*/



pragma solidity ^0.4.20;





















contract HeroHelperSup

{

    address public m_Owner;

    address public m_Owner2;

    uint8 lvlCap = 20;



    bool public m_Paused;

    AbstractDatabase m_Database= AbstractDatabase(0x400d188e1c21d592820df1f2f8cf33b3a13a377e);

    BitGuildToken public tokenContract = BitGuildToken(0x7E43581b19ab509BCF9397a2eFd1ab10233f27dE); // Predefined PLAT token address

    address public bitGuildAddress = 0x6ca511eE4aF4f98eA6A4C99ab79D86C450B89955;

    mapping(uint32 => uint)  public timeLimitPerStockHeroID;

    using SafeMath for uint256;

    using SafeMath32 for uint32;

    using SafeMath16 for uint16;

    using SafeMath8 for uint8;



    modifier OnlyOwner(){

        require(msg.sender == m_Owner || msg.sender == m_Owner2);

        _;

    }



    modifier onlyOwnerOf(uint _hero_id) {

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, _hero_id));

        require(ownership.m_Owner == msg.sender);

        _;

    }



    address constant NullAddress = 0;



    uint256 constant GlobalCategory = 0;



    //Hero

    uint256 constant HeroCategory = 1;

    uint256 constant HeroStockCategory = 2;

    uint256 constant InventoryHeroCategory = 3;



    uint256 constant OwnershipHeroCategory = 10;

    uint256 constant OwnershipItemCategory = 11;

    uint256 constant OwnershipAbilitiesCategory = 12;



    //Market

    uint256 constant ProfitFundsCategory = 14;

    uint256 constant WithdrawalFundsCategory = 15;

    uint256 constant HeroMarketCategory = 16;



    //Action

    uint256 constant ActionCategory = 20;

    uint256 constant MissionCategory = 17;

    uint256 constant ActionHeroCategory = 18;



    //ReferalCategory

    uint256 constant ReferalCategory = 237;



    using Serializer for Serializer.DataComponent;



    function ChangeAddressHeroTime(uint32 HeroStockID,uint timeLimit) public OnlyOwner()

    {

        timeLimitPerStockHeroID[HeroStockID] = timeLimit;

    }

    

    function ChangeOwner(address new_owner) public OnlyOwner(){

        m_Owner = new_owner;

    }



    function ChangeOwner2(address new_owner) public OnlyOwner(){

        m_Owner2 = new_owner;

    }



    function ChangeDatabase(address db) public OnlyOwner(){

        m_Database = AbstractDatabase(db);

    }



    function HeroHelperSup() public{

        m_Owner = msg.sender;

        m_Paused = true;

    }



    function changeLvlCap(uint8 newLvl) public OnlyOwner(){

        lvlCap = newLvl;

    }



    function GetHeroStockStats(uint16 stockhero_id) public view returns (uint64 price,uint8 stars,uint8 mainOnePosition,uint8 mainTwoPosition,uint16 stock,uint8 class){

        LibStructs.StockHero memory stockhero = GetHeroStock(stockhero_id);

        price = stockhero.price;

        stars = stockhero.stars;

        mainOnePosition = stockhero.mainOnePosition;

        mainTwoPosition = stockhero.mainTwoPosition;

        stock = stockhero.stock;

        class = stockhero.class;



    }

    function GetHeroStock(uint16 stockhero_id)  private view returns (LibStructs.StockHero){

        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, stockhero_id));

        return stockhero;

    }



    function GetHeroCount(address _owner) public view returns (uint32){

        return uint32(m_Database.Load(_owner, HeroCategory, 0));

    }

    function GetHero(uint32 hero_id) public view returns(uint16[14] values){



        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));

        bytes32 base = m_Database.Load(NullAddress, ActionHeroCategory, hero_id);

        LibStructs.Action memory action = LibStructs.DeserializeAction( base );



        uint8 actStat = 0;

        uint16 minLeft = 0;

        if(uint32(base) != 0){

            if(action.cooldown > now){

                actStat = 1;

                minLeft = uint16( (action.cooldown - now).div(60 seconds));

            }

        }

        values = [hero.stockID,uint16(hero.rarity),hero.hp,hero.atk,hero.def,hero.agi,hero.intel,hero.lvl,hero.isForSale,hero.cHp,hero.xp,action.actionID,uint16(actStat),minLeft];



    }



    function receiveApproval(address _sender, uint256 _value, BitGuildToken _tokenContract, bytes _extraData) public {

        require(_tokenContract == tokenContract);

        require(_tokenContract.transferFrom(_sender, address(m_Database), _value));

        require(_extraData.length != 0);



        uint16 hero_id = uint16(_bytesToUint(_extraData));



        BuyStockHeroP1(hero_id,5,_value,_sender);

    }



    function _bytesToUint(bytes _b) public pure returns(uint256) {

        uint256 number;

        for (uint i=0; i < _b.length; i++) {

            number = number + uint(_b[i]) * (2**(8 * (_b.length - (i+1))));

        }

        return number;

    }



    event heroLeveledUp(address sender, uint32 hero_id);

    event BuyStockHeroEvent(address indexed buyer, uint32 stock_id, uint32 hero_id);



    function BuyStockHeroP1(uint16 stock_id,uint8 rarity,uint256 _value,address _sender) internal {



        LibStructs.StockHero memory prehero = GetHeroStock(stock_id);

        uint256 valuePrice = prehero.price;

        valuePrice = valuePrice.mul( 25000000000000000000 );



        require(_value  == valuePrice  && now < timeLimitPerStockHeroID[stock_id] && prehero.stars >= 4);



        BuyStockHeroP2(_sender,stock_id,rarity,valuePrice);



    }

    function BuyStockHeroP2(address target,uint16 stock_id,uint8 rarity,uint valuePrice) internal{



        uint256 inventory_count;

        LibStructs.StockHero memory prehero = GetHeroStock(stock_id);

        LibStructs.Hero memory hero = buyHero(prehero,stock_id,rarity);

        GlobalTypes.Global memory global = GlobalTypes.DeserializeGlobal(m_Database.Load(NullAddress, GlobalCategory, 0));



        global.m_LastHeroId = global.m_LastHeroId.add(1);

        uint32 next_hero_id = global.m_LastHeroId;

        inventory_count = GetInventoryHeroCount(target);



        inventory_count = inventory_count.add(1);





        OwnershipTypes.Ownership memory ownership;

        ownership.m_Owner = target;

        ownership.m_OwnerInventoryIndex = uint32(inventory_count.sub(1));



        m_Database.Store(target, InventoryHeroCategory, inventory_count, bytes32(next_hero_id)); // coloca na posiçao nova o heroi

        m_Database.Store(target, InventoryHeroCategory, 0, bytes32(inventory_count)); // coloco na posiçao zero o count do mapping :) admira te



        m_Database.Store(NullAddress, HeroCategory, next_hero_id, LibStructs.SerializeHero(hero));

        m_Database.Store(NullAddress, OwnershipHeroCategory, next_hero_id, OwnershipTypes.SerializeOwnership(ownership));

        m_Database.Store(NullAddress, GlobalCategory, 0, GlobalTypes.SerializeGlobal(global));



        divProfit(valuePrice);



        BuyStockHeroEvent(target, stock_id, next_hero_id);





    }



    function divProfit(uint _value) internal{



        uint256 profit_funds = uint256(m_Database.Load(bitGuildAddress, WithdrawalFundsCategory, 0));

        profit_funds = profit_funds.add(_value.div(10).mul(3));//30%

        m_Database.Store(bitGuildAddress, WithdrawalFundsCategory, 0, bytes32(profit_funds));



        profit_funds = uint256(m_Database.Load(NullAddress, ProfitFundsCategory, 0));

        profit_funds = profit_funds.add(_value.div(10).mul(7));//70%

        m_Database.Store(NullAddress, ProfitFundsCategory, 0, bytes32(profit_funds));



    }



    function GetTimeNow() view public returns (uint256){

               return now;

    }

    

    function GetInventoryHeroCount(address target) view public returns (uint256){

        require(target != address(0));



        uint256 inventory_count = uint256(m_Database.Load(target, InventoryHeroCategory, 0));



        return inventory_count;

    }

    function GetInventoryHero(address target, uint256 start_index) view public returns (uint32[8] hero_ids){

        require(target != address(0));



        uint256 inventory_count = GetInventoryHeroCount(target);



        uint256 end = start_index.add(8);

        if (end > inventory_count)

            end = inventory_count;



        for (uint256 i = start_index; i < end; i++)

        {

            hero_ids[i - start_index] = uint32(uint256(m_Database.Load(target, InventoryHeroCategory, i.add(1) )));

        }

    }

    function buyHero(LibStructs.StockHero prehero,uint16 stock_id,uint8 rarity) internal returns(LibStructs.Hero hero){



        var mainStats = generateHeroStats(prehero,rarity);

        hero = assembleHero(mainStats,rarity,stock_id,1,0);

        return hero;



    }

    function assembleHero(uint16[5] _mainStats,uint8 _rarity,uint16 stock_id,uint8 lvl,uint16 xp) private pure returns(LibStructs.Hero){

        uint16 stockID = stock_id;

        uint8 rarity= _rarity;

        uint16 hp= _mainStats[0]; // Max Hp

        uint16 atk= _mainStats[1];

        uint16 def= _mainStats[2];

        uint16 agi= _mainStats[3];

        uint16 intel= _mainStats[4];

        uint16 cHp= _mainStats[0]; // Current Hp



        return LibStructs.Hero(stockID,rarity,hp,atk,def,agi,intel,cHp,0,lvl,xp);

    }



    function generateHeroStats(LibStructs.StockHero prehero,uint8 rarity) private view returns(uint16[5] ){



        uint32  goodPoints = 0;

        uint32  normalPoints = 0;

        uint8 i = 0;

        uint16[5] memory arrayStartingStat;

        i = i.add(1);

        uint32 points = prehero.stars.add(2).add(rarity);



        uint8[2] memory mainStats = [prehero.mainOnePosition,prehero.mainTwoPosition];//[prehero.hpMain,prehero.atkMain,prehero.defMain,prehero.agiMain,prehero.intelMain]; //prehero.mainStats;// warrior [true,true,false,false,false];



        goodPoints = points;

        normalPoints = 8;

        uint16[5] memory arr = [uint16(1),uint16(1),uint16(1),uint16(1),uint16(1)]; // 5

        arrayStartingStat = spreadStats(mainStats,arr,goodPoints,normalPoints,i);



        return arrayStartingStat;



    }

    function getRarity(uint8 i) private returns(uint8 result){



        result = uint8(m_Database.getRandom(100,i));

        if(result == 99){ // LENDARIO

            result = 5;

        }else if( result >= 54 && result <= 79  ){ // epico

            result = 2;

        }else if(result >= 80 && result <= 92){ // raro

            result = 3;

        }else if(result >= 93 && result <= 98){ // incomun

            result = 4;

        }else{ //

            result = 1; // commun

        }

        return ;

    }



    function spreadStats(uint8[2] mainStats,uint16[5]  arr,uint32 mainPoints,uint32 restPoints,uint index) private view returns(uint16[5]){

        uint32 i = 0;



        bytes32 blockx = block.blockhash(block.number.sub(1));

        uint256 _seed = uint256(sha3(blockx, m_Database.getRandom(100,uint8(i))));



        while(i < mainPoints){ // goodppoints 4



            uint8 position = uint8(( _seed / (10 ** index)) %10);

            if(position < 5){

                position = 0;

            }

            else{

                position = 1;

            }



            arr[mainStats[position]] = arr[mainStats[position]].add(1);

            i = i.add(1);

            index = index.add(1);



        }

        i=0;

        while(i < restPoints){ // outros  8



            uint8 positionz = uint8(( _seed / (10 ** index)) %5);

            arr[positionz] = arr[positionz].add(1);

            i = i.add(1);

            index = index.add(1);



        }



        return arr;

    }

    function levelUp(uint32 hero_id)  public onlyOwnerOf(hero_id) returns(uint16[5] )  {



        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));

        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, hero.stockID));



        require(hero.xp >= hero.lvl.mul(15) && hero.lvl.add(1) < lvlCap);

        uint8  normalPoints = 8;

        uint8 i = 0;

        uint16[5] memory arrayStartingStat = [hero.hp,hero.atk,hero.def,hero.agi,hero.intel];

        i = i.add(1);

        uint8 goodPoints = stockhero.stars.add(2).add(hero.rarity);



        uint8[2] memory mainStats = [stockhero.mainOnePosition,stockhero.mainTwoPosition];//[prehero.hpMain,prehero.atkMain,prehero.defMain,prehero.agiMain,prehero.intelMain]; //prehero.mainStats;// warrior [true,true,false,false,false];



        arrayStartingStat = spreadStats(mainStats,arrayStartingStat,goodPoints,normalPoints,i);

        saveStats( hero_id, arrayStartingStat,hero.rarity,hero.stockID,hero.lvl.add(1),hero.xp);



        return arrayStartingStat;



    }

    function getXpRequiredByHero(uint32 hero_id) public view returns(uint){

        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));

        return hero.lvl.mul(15);

    }

    function saveStats(uint32 hero_id,uint16[5]  arrStats,uint8 rarity,uint16 stock_id,uint8 lvl,uint16 lastXp) internal{



        uint16 remainingXp = lastXp.sub(lvl.sub(1).mul(15));

        LibStructs.Hero memory hero = assembleHero(arrStats,rarity,stock_id,lvl,remainingXp);

        m_Database.Store(NullAddress, HeroCategory, hero_id, LibStructs.SerializeHero(hero));

        heroLeveledUp(msg.sender,hero_id);



    }



    event heroReceivedXp(uint32 hero_id,uint16 addedXp);

    function giveXp(uint32 hero_id,uint16 _xp) public OnlyOwner(){



        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));

        hero.xp = hero.xp.add(_xp);

        m_Database.Store(NullAddress, HeroCategory, hero_id, LibStructs.SerializeHero(hero));

        heroLeveledUp(hero_id,_xp);



    }



}



contract BitGuildToken{

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success);

}



contract AbstractDatabase

{

    function() public payable;

    function ChangeOwner(address new_owner) public;

    function ChangeOwner2(address new_owner) public;

    function Store(address user, uint256 category, uint256 slot, bytes32 data) public;

    function Load(address user, uint256 category, uint256 index) public view returns (bytes32);

    function TransferFunds(address target, uint256 transfer_amount) public;

    function getRandom(uint256 upper, uint8 seed) public returns (uint256 number);

}