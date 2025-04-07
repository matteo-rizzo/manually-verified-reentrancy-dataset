/**
 *Submitted for verification at Etherscan.io on 2021-09-03
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @dev String operations.
 */





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */




contract EncounterHelper is  Context {
        
        uint256 private uniqueId = (random("WORLDEATERUNIQUEID")%12000)+1;
        
        string[] private commonDescriptors = [
        "Empty",
        "Chilling",
        "Clammy",
        "cramped",
        "Rotten",
        "Rusty",
        "Deserted",
        "Gloomy",
        "Dark",
        "Bright",
        "Hot",
        "Slippery",
        "Slimy",
        "Sandy",
        "Cold",
        "Damp",
        "Fancy",
        "Remote",
        "Regal",
        "Small",
        "Big",
        "Charming",
        "Quiet",
        "Dirty",
        "Traditional",
        "Sunny",
        "Disgusting",
        "Stinking",
        "Draining"
    ];
    
        string[] private rareDescriptors = [
        "Filthy",
        "Frozen",
        "Decaying",
        "Neglected",
        "Weathered And Tough",
        "Magical",
        "Spongy and Wet",
        "Large And Bright",
        "Creepy",
        "Ancient",
        "Mystical",
        "Strange and Mysterious",
        "Ineffable",
        "Radiant"
    ];
    
        string[] private legendaryDescriptors = [
        "Dilapidated",
        "Petrifying",
        "Shadowy and Silent",
        "Twisted",
        "Repulsive",
        "Misty and Murky",
        "Glowing",
        "Enchanted"
    ];
    
        string[] private commonLocations = [
        "Dungeon",
        "Courtyard",
        "Forest",
        "Basement",
        "Room",
        "Field",
        "Meadows",
        "Dark closet",
        "General Store",
        "Swamp",
        "Vast Desert",
        "Goblin Valley",
        "Sewer Tunnel",
        "Ruined City",
        "Watch Tower",
        "Cave",
        "Empty Stairwell",
        "Mountain cave",
        "Goblin encampment",
        "Town Market",
        "Wooded Grove",
        "Coastal Clearing"
    ];
    
        string[] private rareLocations = [
        "Tower",
        "Abandoned Village",
        "Iron Woods",
        "Elven Forest",
        "Dark Plains",
        "High Castle",
        "Wizard Tower",
        "Abandoned Castle",
        "Toll Bridge",
        "Magical Island",
        "Lighthouse",
        "Forge",
        "Volcano Tube",
        "Wistful Wild",
        "Lair of a Giant",
        "Badland Highway"
    ];
    
        string[] private legendaryLocations = [
        "Hidden Temple",
        "Giant Castle",
        "Enchanted Dungeon",
        "Gold Bank",
        "Bustling Barracks",
        "Mighty Citadel",
        "Sacred Sanctuary",
        "Fungal Forrest",
        "Place Between Time",
        "Astral Plane",
        "Pocket Dimension",
        "Ghost Ship"
    ];
    
        string[] private uniqueLocations = [
        'The Edge of Time and Space'
    ];
    
        string[] private commonCreatures = [
        "Goblin",
        "Troll",
        "Wolf",
        "Wizard",
        "Spider",
        "Zombie",
        "City Guard",
        "Cave slime",
        "Thug",
        "Troll Runt",
        "Dwarf",
        "Mugger",
        "Grizzly Bear",
        "Giant Spider",
        "Wild Dog",
        "Wraith",
        "Minotaur",
        "Ghoul",
        "Mudskipper",
        "Giant Scorpion",
        "Giant Rat",
        "Sphinx",
        "Vampire",
        "Basilisks",
        "Orc"
    ];
    
        string[] private rareCreatures = [
        "Hobgoblin",
        "Seething Devil",
        "Hellhound",
        "Cyclops",
        "Ice Dragon",
        "Fire Dragon",
        "Skeleton Dragon",
        "Werewolf",
        "Great Demon",
        "Mummy",
        "Abyssal Demon",
        "ice Prince",
        "Scarab Swarm",
        "High Priest",
        "Gargoyle",
        "Night Shifter",
        "High Elf",
        "Night Elf"
    ];
    
        string[] private legendaryCreatures = [
        "Yeti",
        "Lich King",
        "Kraken",
        "Dark Wyvern",
        "Revenant Beast",
        "Shadow Lord",
        "Onyx Warlord",
        "Zombie Lord",
        "Scarab Queen",
        "Wyvern of Undying"
    ];
    
        string[] private uniqueCreatures = [
        'The Great World Eater'
    ];
        
        string[] private creatureDescriptors = [
        'Supreme',
        'Exalted',
        'Enraged',
        'Diseased',
        'Gigantic',
        'Firey',
        'Ancient',
        'Cursed',
        'Flying',
        'Invisible',
        'Engulfed',
        'Frost'
    ];
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    //returns a location in svg format <text>output</text>
    function pluckLocation(uint256 tokenId) internal view returns (string memory,string memory, uint256) {
        uint256 rarity = 0;
        
        uint256 rand1 = random(string(abi.encodePacked("LOCATION", toString(tokenId))));
        uint256 rand2 = random(string(abi.encodePacked("LOCATIONDESCRIPTOR", toString(tokenId))));
        
        string memory location;
        string memory descriptor;
        
        uint256 locationRarity = rand1 % 100; //0-99
        
        if(locationRarity < 60)
        {
            //common
            rarity = rarity + 1;
            location = commonLocations[rand1 % commonLocations.length];
        }
        else if(locationRarity < 90)
        {
            //rare
            rarity = rarity + 5;
            location = rareLocations[rand1 % rareLocations.length];
        }
        else
        {
            //legendary
            rarity = rarity + 15;
            location = legendaryLocations[rand1 % legendaryLocations.length];
        }
        
        uint256 descriptorRarity = rand2 % 100;
        
        if(descriptorRarity < 60)
        {
            //common
            rarity = rarity + 1;
            descriptor = commonDescriptors[rand2 % commonDescriptors.length];
        }
        else if(descriptorRarity < 90)
        {
            //rare
            rarity = rarity + 5;
            descriptor = rareDescriptors[rand2 % rareDescriptors.length];
        }
        else
        {
            //legendary
            rarity = rarity + 15;
            descriptor = legendaryDescriptors[rand2 % legendaryDescriptors.length];
        }
        
        return (descriptor, location, rarity);
    }
    
    function pluckCreature(uint256 tokenId) internal view returns (string memory, string memory, uint256) {
        uint256 rarity = 0;
        
        uint256 rand1 = random(string(abi.encodePacked("CREATURE", toString(tokenId))));
        uint256 rand2 = random(string(abi.encodePacked("CREATUREMODIFIER", toString(tokenId))));
        
        string memory creature;
        string memory prefix = "";
        
        uint256 creatureRarity = rand1 % 100; //0-99
        
        if(creatureRarity < 60)
        {
            //common
            rarity = rarity + 1;
            creature = commonCreatures[rand1 % commonCreatures.length];
        }
        else if(creatureRarity < 90)
        {
            //rare
            rarity = rarity + 5;
            creature = rareCreatures[rand1 % rareCreatures.length];
        }
        else
        {
            //legendary
            rarity = rarity + 15;
            creature = legendaryCreatures[rand1 % legendaryCreatures.length];
        }
        
        if((rand2 % 100) < 10) //add a descriptr
        {
            rarity = rarity + 15;
            prefix = creatureDescriptors[rand2 % creatureDescriptors.length];
        }
        
        
        return (prefix, creature, rarity);
    }
    
    function getNumCreatures(uint256 tokenId) public view returns (uint256)
    {
        uint256 rand1 = random(string(abi.encodePacked("CREATURE", toString(tokenId))));
        
        uint256 numberRarity = rand1 % 100;
        
        if(numberRarity < 50)
        {
            return 2;
        }
        else if(numberRarity < 80)
        {
            return 3;
        }
        else if(numberRarity < 95)
        {
            return 4;
        }
        else
        {
            return 5;
        }
    }
    
    function getLocation(uint256 tokenId) public view returns (string memory, string memory, uint256)
    {
        return pluckLocation(tokenId);
    }
    
    function getCreature1(uint256 tokenId) public view returns (string memory,string memory, uint256)
    {
        return pluckCreature(tokenId+12345); //creature 1
    }
    
    function getCreature2(uint256 tokenId) public view returns (string memory,string memory, uint256)
    {
        return pluckCreature(tokenId+12345+12345); //creature 1
    }
    
    function getCreature3(uint256 tokenId) public view returns (string memory,string memory, uint256)
    {
        if (getNumCreatures(tokenId) < 3) return ("","", 0);
        return pluckCreature(tokenId+12345+12345+12345); //creature 1
    }
    
    function getCreature4(uint256 tokenId) public view returns (string memory,string memory, uint256)
    {
        if (getNumCreatures(tokenId) < 4) return ("","", 0);
        return pluckCreature(tokenId+12345+12345+12345+12345); //creature 1
    }
    
    function getCreature5(uint256 tokenId) public view returns (string memory,string memory, uint256)
    {
        if (getNumCreatures(tokenId) < 5) return ("","", 0);
        return pluckCreature(tokenId+12345+12345+12345+12345+12345); //creature 1
    }
    
    function getRarityValue(uint256 tokenId) public view returns (uint256)
    {
        (,,uint256 rarity0) = getLocation(tokenId);
        (,,uint256 rarity1) = getCreature1(tokenId);
        (,,uint256 rarity2) = getCreature2(tokenId);
        (,,uint256 rarity3) = getCreature3(tokenId);
        (,,uint256 rarity4) = getCreature4(tokenId);
        (,,uint256 rarity5) = getCreature5(tokenId);
        return rarity0+rarity1 + rarity2 + rarity3 + rarity4 + rarity5;
    }
    
    function getRarityLevel(uint256 tokenId) public view returns (string memory)
    {
        uint256 rarity = getRarityValue(tokenId);
        if(rarity < 20)
        {
            return("Common");
        }
        else if(rarity < 35)
        {
            return("Rare");
        }
        else if(rarity < 55)
        {
            return("Legendary");
        }
        else
        {
            return("Godlike");
        }
    }

    
    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    constructor()  {}
}