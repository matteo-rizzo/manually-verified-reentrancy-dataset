/**

 *Submitted for verification at Etherscan.io on 2018-09-13

*/



pragma solidity ^0.4.19;























contract HeroHelperBuy

{

    address public m_Owner;

    address public partner1;

    uint8 public percent1;

    address public partner2;

    uint8 public percent2;



    bool public m_Paused;

    AbstractDatabase m_Database= AbstractDatabase(0x400d188e1c21d592820df1f2f8cf33b3a13a377e);

    BitGuildToken public tokenContract = BitGuildToken(0x7E43581b19ab509BCF9397a2eFd1ab10233f27dE); // Predefined PLAT token address

    address public bitGuildAddress = 0x6ca511eE4aF4f98eA6A4C99ab79D86C450B89955;

    mapping(address => bool)  public trustedContracts;

    using SafeMath for uint256;

    using SafeMath32 for uint32;

    using SafeMath16 for uint16;

    using SafeMath8 for uint8;



    modifier OnlyOwner(){

        require(msg.sender == m_Owner || trustedContracts[msg.sender]);

        _;

    }



    modifier onlyOwnerOf(uint _hero_id) {

        OwnershipTypes.Ownership memory ownership = OwnershipTypes.DeserializeOwnership(m_Database.Load(NullAddress, OwnershipHeroCategory, _hero_id));

        require(ownership.m_Owner == msg.sender);

        _;

    }

    

    function ChangeAddressTrust(address contract_address,bool trust_flag) public OnlyOwner()

    {

        trustedContracts[contract_address] = trust_flag;

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



    function ChangePartners(address _partner1,uint8 _percent1,address _partner2,uint8 _percent2) public OnlyOwner(){

        partner1 = _partner1;

        percent1 = _percent1;

        partner2 = _partner2;

        percent2 = _percent2;

    }

    function ChangeDatabase(address db) public OnlyOwner(){

        m_Database = AbstractDatabase(db);

    }

    // function ChangeHeroHelperOraclize(address new_heroOraclize) public OnlyOwner(){

    //     m_HeroHelperOraclize = AbstractHeroHelperOraclize(new_heroOraclize);

    // }

    function HeroHelperBuy() public{

        m_Owner = msg.sender;

        m_Paused = true;

    }



    

    function GetHeroStock(uint16 stockhero_id)  private view returns (LibStructs.StockHero){

        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, stockhero_id));

        return stockhero;

    }

    

    function GetHeroStockPrice(uint16 stockhero_id)  public view returns (uint){

        LibStructs.StockHero memory stockhero = LibStructs.DeserializeStockHero(m_Database.Load(NullAddress, HeroStockCategory, stockhero_id));

        return stockhero.price;

    }



    function GetHeroCount(address _owner) public view returns (uint32){

        return uint32(m_Database.Load(_owner, HeroCategory, 0));

    }

    

    function receiveApproval(address _sender, uint256 _value, BitGuildToken _tokenContract, bytes _extraData) public {

        require(_tokenContract == tokenContract);

        require(_tokenContract.transferFrom(_sender, address(m_Database), _value));

        require(_extraData.length != 0);

          

        uint16 hero_id = uint16(_bytesToUint(_extraData));    

        

        BuyStockHeroP1(hero_id,_value,_sender);

    }

    

    event BuyStockHeroEvent(address indexed buyer, uint32 stock_id, uint32 hero_id);

    event showValues(uint256 _value,uint256 _price,uint256 _stock,uint256 hero_id);

    function _bytesToUint(bytes _b) public pure returns(uint256) {

        uint256 number;

        for (uint i=0; i < _b.length; i++) {

            number = number + uint(_b[i]) * (2**(8 * (_b.length - (i+1))));

        }

        return number;

    }

    function BuyStockHeroP1(uint16 stock_id,uint256 _value,address _sender) internal {

        

        LibStructs.StockHero memory prehero = GetHeroStock(stock_id);

        uint256 finneyPrice = prehero.price;

        finneyPrice = finneyPrice.mul( 1000000000000000000 );

        showValues(_value, finneyPrice,prehero.stock,stock_id);

        

        require(_value  == finneyPrice && prehero.stock > 0);

        

        

        BuyStockHeroP2(_sender,stock_id,m_Database.getRandom(100,uint8(_sender)));

        

    }

    function giveHeroRandomRarity(address target,uint16 stock_id,uint random) public OnlyOwner(){

        BuyStockHeroP2(target,stock_id,random);

    }

    function BuyStockHeroP2(address target,uint16 stock_id,uint random) internal{

        

        uint256 inventory_count;

        LibStructs.StockHero memory prehero = GetHeroStock(stock_id);

        LibStructs.Hero memory hero = buyHero(prehero,stock_id,random);

        GlobalTypes.Global memory global = GlobalTypes.DeserializeGlobal(m_Database.Load(NullAddress, GlobalCategory, 0));



        uint256 finneyPrice = prehero.price*1000000000000000000;

        prehero.stock = prehero.stock.sub(1);



        global.m_LastHeroId = global.m_LastHeroId.add(1);

        uint32 next_hero_id = global.m_LastHeroId;

        inventory_count = GetInventoryHeroCount(target);



        inventory_count = inventory_count.add(1);





        OwnershipTypes.Ownership memory ownership;

        ownership.m_Owner = target;

        ownership.m_OwnerInventoryIndex = uint32(inventory_count.sub(1));



        m_Database.Store(target, InventoryHeroCategory, inventory_count, bytes32(next_hero_id)); // coloca na posiçao nova o heroi

        m_Database.Store(target, InventoryHeroCategory, 0, bytes32(inventory_count)); // coloco na posiçao zero o count do mapping :) admira te



        m_Database.Store(NullAddress, HeroStockCategory, stock_id, LibStructs.SerializeStockHero(prehero));

        m_Database.Store(NullAddress, HeroCategory, next_hero_id, LibStructs.SerializeHero(hero));

        m_Database.Store(NullAddress, OwnershipHeroCategory, next_hero_id, OwnershipTypes.SerializeOwnership(ownership));

        m_Database.Store(NullAddress, GlobalCategory, 0, GlobalTypes.SerializeGlobal(global));

       

        divProfit(finneyPrice);



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



    function GetInventoryHeroCount(address target) view public returns (uint256){

        require(target != address(0));



        uint256 inventory_count = uint256(m_Database.Load(target, InventoryHeroCategory, 0));



        return inventory_count;

    }

    

    function buyHero(LibStructs.StockHero prehero,uint16 stock_id,uint random) internal returns(LibStructs.Hero hero){

        

        uint8 rarity = 1;

        if(random == 99){ // comum

            rarity = 5;

        }else if( random >= 54 && random <= 79  ){ // incomun

            rarity = 2;

        }else if(random >= 80 && random <= 92){ // raro

            rarity = 3;

        }else if(random >= 93 && random <= 98){ // epico

            rarity = 4;

        }else{

            rarity = 1;

        }

        

        uint16[5] memory mainStats = generateHeroStats(prehero,rarity);

        hero = assembleHero(mainStats,rarity,stock_id);

        return hero;



    }

    

    function assembleHero(uint16[5] _mainStats,uint8 _rarity,uint16 stock_id) private pure returns(LibStructs.Hero){

        uint16 stockID = stock_id;

        uint8 rarity= _rarity;

        uint16 hp= _mainStats[0]; // Max Hp

        uint16 atk= _mainStats[1];

        uint16 def= _mainStats[2];

        uint16 agi= _mainStats[3];

        uint16 intel= _mainStats[4];

        uint16 cHp= _mainStats[0]; // Current Hp

        //others

        uint8 critic= 0;

        uint8 healbonus= 0;

        uint8 atackbonus= 0;

        uint8 defensebonus= 0;



        return LibStructs.Hero(stockID,rarity,hp,atk,def,agi,intel,cHp,0,1,0);

    }



    function generateHeroStats(LibStructs.StockHero prehero, uint8 rarity) private view returns(uint16[5] ){



        uint32  goodPoints = 0;

        uint32  normalPoints = 0;

        uint8 i = 0;

        uint16[5] memory arrayStartingStat;

        i = i.add(1);

        //uint8 rarity = getRarity(i);

        uint32 points = prehero.stars.add(2).add(rarity);



        uint8[2] memory mainStats = [prehero.mainOnePosition,prehero.mainTwoPosition];//[prehero.hpMain,prehero.atkMain,prehero.defMain,prehero.agiMain,prehero.intelMain]; //prehero.mainStats;// warrior [true,true,false,false,false];



        goodPoints = points;

        normalPoints = 8;

        arrayStartingStat = spreadStats(mainStats,goodPoints,normalPoints,i);



        return arrayStartingStat;



    }

   



    function spreadStats(uint8[2] mainStats,uint32 mainPoints,uint32 restPoints,uint index) private view returns(uint16[5]){

        uint32 i = 0;

        uint16[5] memory arr = [uint16(1),uint16(1),uint16(1),uint16(1),uint16(1)]; // 5

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