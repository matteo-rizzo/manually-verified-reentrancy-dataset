pragma solidity ^0.4.18;

/* ==================================================================== */

/* Copyright (c) 2018 The MagicAcademy Project.  All rights reserved.

/* 

/* https://www.magicacademy.io One of the world's first idle strategy games of blockchain 

/*  

/* authors [email protected]/[email protected]

/*                 

/* ==================================================================== */









contract CardsRead {

  using SafeMath for SafeMath;



  CardsInterface public cards;

  GameConfigInterface public schema;

  address owner;

  



  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  function CardsRead() public {

    owner = msg.sender;

  }

    //setting configuration

  function setConfigAddress(address _address) external onlyOwner {

    schema = GameConfigInterface(_address);

  }



     //setting configuration

  function setCardsAddress(address _address) external onlyOwner {

    cards = CardsInterface(_address);

  }



  // get normal cardlist;

  function getNormalCardList(address _owner) external view returns(uint256[],uint256[]){

    uint256 startId;

    uint256 endId;

    (startId,endId) = schema.productionCardIdRange(); 

    uint256 len = SafeMath.add(SafeMath.sub(endId,startId),1);

    uint256[] memory itemId = new uint256[](len);

    uint256[] memory itemNumber = new uint256[](len);



    uint256 i;

    while (startId <= endId) {

      itemId[i] = startId;

      itemNumber[i] = cards.getOwnedCount(_owner,startId);

      i++;

      startId++;

      }   

    return (itemId, itemNumber);

  }



  // get normal cardlist;

  function getBattleCardList(address _owner) external view returns(uint256[],uint256[]){

    uint256 startId;

    uint256 endId;

    (startId,endId) = schema.battleCardIdRange();

    uint256 len = SafeMath.add(SafeMath.sub(endId,startId),1);

    uint256[] memory itemId = new uint256[](len);

    uint256[] memory itemNumber = new uint256[](len);



    uint256 i;

    while (startId <= endId) {

      itemId[i] = startId;

      itemNumber[i] = cards.getOwnedCount(_owner,startId);

      i++;

      startId++;

      }   

    return (itemId, itemNumber);

  }



  // get upgrade cardlist;

  function getUpgradeCardList(address _owner) external view returns(uint256[],uint256[]){

    uint256 startId;

    uint256 endId;

    (startId, endId) = schema.upgradeIdRange();

    uint256 len = SafeMath.add(SafeMath.sub(endId,startId),1);

    uint256[] memory itemId = new uint256[](len);

    uint256[] memory itemNumber = new uint256[](len);



    uint256 i;

    while (startId <= endId) {

      itemId[i] = startId;

      itemNumber[i] = cards.getUpgradesOwned(_owner,startId);

      i++;

      startId++;

      }   

    return (itemId, itemNumber);

  }



    //get up value

  function getUpgradeValue(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) external view returns (

    uint256 productionGain ,uint256 preValue,uint256 afterValue) {

    if (cards.getOwnedCount(player,unitId) == 0) {

      if (upgradeClass == 0) {

        productionGain = upgradeValue * 10;

        preValue = schema.unitCoinProduction(unitId);

        afterValue   = preValue + productionGain;

      } else if (upgradeClass == 1){

        productionGain = upgradeValue * schema.unitCoinProduction(unitId);

        preValue = schema.unitCoinProduction(unitId);

        afterValue   = preValue + productionGain;

      } 

    }else { // >= 1

      if (upgradeClass == 0) {

        productionGain = (cards.getOwnedCount(player,unitId) * upgradeValue * (10 + cards.getUnitCoinProductionMultiplier(player,unitId)));

        preValue = cards.getUintCoinProduction(player,unitId);

        afterValue   = preValue + productionGain;

     } else if (upgradeClass == 1) {

        productionGain = (cards.getOwnedCount(player,unitId) * upgradeValue * (schema.unitCoinProduction(unitId) + cards.getUnitCoinProductionIncreases(player,unitId)));

        preValue = cards.getUintCoinProduction(player,unitId);

        afterValue   = preValue + productionGain;

     }

    }

  }



 // To display on website

  function getGameInfo() external view returns (uint256,  uint256, uint256, uint256, uint256, uint256, uint256[], uint256[], uint256[]){  

    uint256 startId;

    uint256 endId;

    (startId,endId) = schema.productionCardIdRange();

    uint256 len = SafeMath.add(SafeMath.sub(endId,startId),1); 

    uint256[] memory units = new uint256[](len);

        

    uint256 i;

    while (startId <= endId) {

      units[i] = cards.getOwnedCount(msg.sender,startId);

      i++;

      startId++;

    }

      

    (startId,endId) = schema.battleCardIdRange();

    len = SafeMath.add(SafeMath.sub(endId,startId),1);

    uint256[] memory battles = new uint256[](len);

    

    i=0; //reset for battle cards

    while (startId <= endId) {

      battles[i] = cards.getOwnedCount(msg.sender,startId);

      i++;

      startId++;

    }

        

    // Reset for upgrades

    i = 0;

    (startId, endId) = schema.upgradeIdRange();

    len = SafeMath.add(SafeMath.sub(endId,startId),1);

    uint256[] memory upgrades = new uint256[](len);



    while (startId <= endId) {

      upgrades[i] = cards.getUpgradesOwned(msg.sender,startId);

      i++;

      startId++;

    }

    return (

    cards.getTotalEtherPool(1), 

    cards.getJadeProduction(msg.sender),

    cards.balanceOf(msg.sender), 

    cards.coinBalanceOf(msg.sender,1),

    cards.getTotalJadeProduction(),

    cards.getNextSnapshotTime(), 

    units, battles,upgrades

    );

  }

}



