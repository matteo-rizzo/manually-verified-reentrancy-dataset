/**

 *Submitted for verification at Etherscan.io on 2018-12-06

*/



pragma solidity 0.4.24;



// File: contracts/FreeDnaCardRepositoryInterface.sol







// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/Restricted.sol



contract Restricted is Ownable {

    mapping(address => bool) private addressIsAdmin;

    bool private isActive = true;



    modifier onlyAdmin() {

        require(addressIsAdmin[msg.sender] || msg.sender == owner);

        _;

    }



    modifier contractIsActive() {

        require(isActive);

        _;

    }



    function addAdmin(address adminAddress) public onlyOwner {

        addressIsAdmin[adminAddress] = true;

    }



    function removeAdmin(address adminAddress) public onlyOwner {

        addressIsAdmin[adminAddress] = false;

    }



    function pauseContract() public onlyOwner {

        isActive = false;

    }



    function activateContract() public onlyOwner {

        isActive = true;

    }

}



// File: contracts/GameData.sol



contract GameData {

    struct Country {       

        bytes2 isoCode;

        uint8 animalsCount;

        uint256[3] animalIds;

    }



    struct Animal {

        bool isSold;

        uint256 currentValue;

        uint8 rarity; // 0-4, rarity = stat range, higher rarity = better stats



        bytes32 name;         

        uint256 countryId; // country of origin



    }



    struct Dna {

        uint256 animalId; 

        uint8 effectiveness; //  1 - 100, 100 = same stats as a wild card

    }    

}



// File: contracts/FreeDnaCardRepository.sol



contract FreeDnaCardRepository is FreeDnaCardRepositoryInterface, GameData, Restricted {

    event NewAirdrop(

        address to,

        uint256 animalId

    );



    event NewGiveway(

        address to,

        uint256 animalId,

        uint8 effectiveness

    );



    uint8 private constant AIRDROP_EFFECTIVENESS = 10;



    uint256 private pendingGivewayCardCount;

    uint256 private airdropEndTimestamp;



    mapping (address => uint256[]) private addressDnaIds;

    mapping (address => bool) public addressIsDonator;



    Dna[] public dnas;



    constructor(

        uint256 _pendingGivewayCardCount,

        uint256 _airdropEndTimestamp

    ) public {

        pendingGivewayCardCount = _pendingGivewayCardCount;

        airdropEndTimestamp = _airdropEndTimestamp;

    }



    function addDonator(address donatorAddress) external onlyAdmin {

        addressIsDonator[donatorAddress] = true;

    }



    function deleteDonator(address donatorAddress) external onlyAdmin {

        delete addressIsDonator[donatorAddress];

    }



    function airdrop(address to, uint256 animalId) external contractIsActive {

        require(now <= airdropEndTimestamp, "airdrop ended");

        donateDna(to, animalId, AIRDROP_EFFECTIVENESS);

        emit NewAirdrop(to, animalId);

    }



    function giveaway(

        address to,

        uint256 animalId,

        uint8 effectiveness

    )

    external

    contractIsActive

    {

        require(pendingGivewayCardCount > 0);



        donateDna(to, animalId, effectiveness);

        pendingGivewayCardCount--;

        emit NewGiveway(to, animalId, effectiveness);

    }



    function getAddressDnaIds(address owner) external view returns(uint256[])

    {

        return addressDnaIds[owner];

    }



    function donateDna(

        address to,

        uint256 animalId,

        uint8 effectiveness

    )

    private

    contractIsActive

    {

        require(addressIsDonator[msg.sender], "donator not registered");



        uint256 id = dnas.length; // id is assigned before push

        Dna memory dna = Dna(animalId, effectiveness);



        // Donate the card

        dnas.push(dna);

        addressDnaIds[to].push(id);

    }

}