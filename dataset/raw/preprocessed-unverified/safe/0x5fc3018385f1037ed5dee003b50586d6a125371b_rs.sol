/**

 *Submitted for verification at Etherscan.io on 2018-09-08

*/



pragma solidity ^0.4.19;





















contract HeroHelper

{

    address public m_Owner;

    address public m_Owner2;



    bool public m_Paused;

    AbstractDatabase m_Database= AbstractDatabase(0x400d188e1c21d592820df1f2f8cf33b3a13a377e);

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



    function ChangeOwner(address new_owner) public OnlyOwner(){

        m_Owner = new_owner;

    }



    function ChangeOwner2(address new_owner) public OnlyOwner(){

        m_Owner2 = new_owner;

    }



    function ChangeDatabase(address db) public OnlyOwner(){

        m_Database = AbstractDatabase(db);

    }



    function HeroHelper() public{

        m_Owner = msg.sender;

        m_Paused = true;

    }



    function addHeroToCatalog(uint32 stock_id,uint16 _finneyCost,uint8 _stars,uint8 _mainOnePosition,uint8 _mainTwoPosition,uint16 _stock,uint8 _class) OnlyOwner() public {



        LibStructs.StockHero memory stockhero = LibStructs.StockHero( _finneyCost, _stars, _mainOnePosition, _mainTwoPosition,_stock,_class);

        m_Database.Store(NullAddress, HeroStockCategory, stock_id, LibStructs.SerializeStockHero(stockhero));



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



    function GetHeroStockPrice(uint16 stockhero_id)  public view returns (uint weiPrice){

        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, stockhero_id));

        return stockhero.price;

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





    function GetAuction(uint32 hero_id) view public returns (bool is_for_sale, address owner, uint128 price,uint16[14] herostats) {

        LibStructs.Hero memory hero = LibStructs.DeserializeHero(m_Database.Load(NullAddress, HeroCategory, hero_id));

        is_for_sale = hero.isForSale == 1;



        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, hero_id));

        owner = ownership.m_Owner;



        MarketTypes.MarketListing memory listing = MarketTypes.DeserializeMarketListing(m_Database.Load(NullAddress, HeroMarketCategory, hero_id));

        price = listing.m_Price;



        herostats = GetHero(hero_id);

    }



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

    function setHeroApproval(address _to, uint256 _tokenId);

    function getHeroApproval(uint256 _tokenId) public returns(address approved);

}