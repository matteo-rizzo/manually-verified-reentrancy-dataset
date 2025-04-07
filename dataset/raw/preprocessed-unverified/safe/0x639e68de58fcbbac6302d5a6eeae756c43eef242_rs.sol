/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity 0.4.25;









/**

* @title -Name Filter- v0.1.9

*/







/**

 * Math operations with safety checks

 */

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





contract CelebrityGame is Ownable {

    using SafeMath for *;

    using NameFilter for string;



    string constant public gameName = "Celebrity Game";



    // fired whenever a card is created

    event LogNewCard(string name, uint256 id);

    // fired whenever a player is registered

    event LogNewPlayer(string name, uint256 id);



    //just for isStartEnable modifier

    bool private isStart = false;

    uint256 private roundId = 0;



    struct Card {

        bytes32 name;           // card owner name

        uint256 fame;           // The number of times CARDS were liked

        uint256 fameValue;      // The charge for the current card to be liked once

        uint256 notorious;      // The number of times CARDS were disliked

        uint256 notoriousValue; // The charge for the current card to be disliked once

    }



    struct CardForPlayer {

        uint256 likeCount;      // The number of times the player likes it

        uint256 dislikeCount;   // The number of times the player disliked it

    }



    struct CardWinner {

        bytes32  likeWinner;

        bytes32  dislikeWinner;

    }



    Card[] public cards;

    bytes32[] public players;



    mapping (uint256 => mapping (uint256 => mapping ( uint256 => CardForPlayer))) public playerCard;      // returns cards of this player like or dislike by playerId and roundId and cardId

    mapping (uint256 => mapping (uint256 => CardWinner)) public cardWinnerMap; // (roundId => (cardId => winner)) returns winner by roundId and cardId

    mapping (uint256 => Card[]) public rounCardMap;                            // returns Card info by roundId



    mapping (bytes32 => uint256) private plyNameXId;                           // (playerName => Id) returns playerId by playerName

    mapping (bytes32 => uint256) private cardNameXId;                          // (cardName => Id) returns cardId by cardName

    mapping (bytes32 => bool) private cardIsReg;                               // (cardName => cardCount) returns cardCount by cardName£¬just for createCard function

    mapping (bytes32 => bool) private playerIsReg;                             // (playerName => isRegister) returns registerInfo by playerName, just for registerPlayer funciton

    mapping (uint256 => bool) private cardIdIsReg;                             // (cardId => card info) returns card info by cardId

    mapping (uint256 => bool) private playerIdIsReg;                           // (playerId => id) returns player index of players by playerId

    mapping (uint256 => uint256) private cardIdXSeq;

    mapping (uint256 => uint256) private playerIdXSeq;



    /**

	 * @dev used to make sure no one can interact with contract until it has been started

	 */

    modifier isStartEnable {

        require(isStart == true);

        _;

    }

	/**

	 * the contract  precision is 1000

	 */

    constructor() public {

        string[8]  memory names= ["SatoshiNakamoto","CZ","HeYi","LiXiaolai","GuoHongcai","VitalikButerin","StarXu","ByteMaster"];

        uint256[8] memory _ids = [uint256(183946248739),536269148721,762415028463,432184367532,398234673241,264398721023,464325189620,217546321806];

        for (uint i = 0; i < 8; i++){

             string  memory _nameString = names[i];

             uint256 _id = _ids[i];

             bytes32 _name = _nameString.nameFilter();

             require(cardIsReg[_name] == false);

             uint256 _seq = cards.push(Card(_name, 1, 1000, 1, 1000)) - 1;

             cardIdXSeq[_id] = _seq;

             cardNameXId[_name] = _id;

             cardIsReg[_name] = true;

            cardIdIsReg[_id] = true;

        }



    }

    /**

	 * @dev use this function to create card.

	 * - must pay some create fees.

	 * - name must be unique

	 * - max length of 32 characters long

	 * @param _nameString owner desired name for card

	 * @param _id card id

	 * (this might cost a lot of gas)

	 */

    function createCard(string _nameString, uint256 _id) public onlyOwner() {

        require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked("")));



        bytes32 _name = _nameString.nameFilter();

        require(cardIsReg[_name] == false);

        uint256 _seq = cards.push(Card(_name, 1, 1000, 1, 1000)) - 1;

        cardIdXSeq[_id] = _seq;

        cardNameXId[_name] = _id;

        cardIsReg[_name] = true;

        cardIdIsReg[_id] = true;

        emit LogNewCard(_nameString, _id);

    }



    /**

	 * @dev use this function to register player.

	 * - must pay some register fees.

	 * - name must be unique

	 * - name cannot be null

	 * - max length of 32 characters long

	 * @param _nameString team desired name for player

	 * @param _id player id

	 * (this might cost a lot of gas)

	 */

    function registerPlayer(string _nameString, uint256 _id)  external {

        require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked("")));



        bytes32 _name = _nameString.nameFilter();

        require(playerIsReg[_name] == false);

        uint256 _seq = players.push(_name) - 1;

        playerIdXSeq[_id] = _seq;

        plyNameXId[_name] = _id;

        playerIsReg[_name] = true;

        playerIdIsReg[_id] = true;



        emit LogNewPlayer(_nameString, _id);

    }



    /**

	 * @dev this function for One player likes the CARD once.

	 * @param _cardId must be returned when creating CARD

	 * @param _playerId must be returned when registering player

	 * (this might cost a lot of gas)

	 */

    function likeCelebrity(uint256 _cardId, uint256 _playerId) external isStartEnable {

        require(cardIdIsReg[_cardId] == true, "sorry create this card first");

        require(playerIdIsReg[_playerId] == true, "sorry register the player name first");



        Card storage queryCard = cards[cardIdXSeq[_cardId]];

        queryCard.fame = queryCard.fame.add(1);

        queryCard.fameValue = queryCard.fameValue.add(queryCard.fameValue / 100*1000);



        playerCard[_playerId][roundId][_cardId].likeCount == (playerCard[_playerId][roundId][_cardId].likeCount).add(1);

        cardWinnerMap[roundId][_cardId].likeWinner = players[playerIdXSeq[_playerId]];

    }



    /**

	 * @dev this function for One player dislikes the CARD once.

	 * @param _cardId must be returned when creating CARD

	 * @param _playerId must be created when registering player

	 * (this might cost a lot of gas)

	 */

    function dislikeCelebrity(uint256 _cardId, uint256 _playerId) external isStartEnable {

        require(cardIdIsReg[_cardId] == true, "sorry create this card first");

        require(playerIdIsReg[_playerId] == true, "sorry register the player name first");



        Card storage queryCard = cards[cardIdXSeq[_cardId]];

        queryCard.notorious = queryCard.notorious.add(1);

        queryCard.notoriousValue = queryCard.notoriousValue.add(queryCard.notoriousValue / 100*1000);



        playerCard[_playerId][roundId][_cardId].dislikeCount == (playerCard[_playerId][roundId][_cardId].dislikeCount).add(1);

        cardWinnerMap[roundId][_cardId].dislikeWinner = players[playerIdXSeq[_playerId]];

    }



    /**

	 * @dev use this function to reset card properties.

	 * - must be called when game is not started by team.

	 * @param _id must be returned when creating CARD

	 * (this might cost a lot of gas)

	 */

    function reset(uint256 _id) external onlyOwner() {

        require(isStart == false);



        Card storage queryCard = cards[cardIdXSeq[_id]];

        queryCard.fame = 1;

        queryCard.fameValue = 1000;

        queryCard.notorious = 1;

        queryCard.notoriousValue = 1000;

    }



    /**

	 * @dev use this function to start the game.

	 * - must be called by owner.

	 * (this might cost a lot of gas)

	 */

    function gameStart() external onlyOwner() {

        isStart = true;

        roundId = roundId.add(1);

    }



    /**

	 * @dev use this function to end the game. Just for emergency control by owner

	 * (this might cost a lot of gas)

	 */

    function gameEnd() external onlyOwner() {

        isStart = false;

        rounCardMap[roundId] = cards;

    }



    /**

	 * @dev use this function to get CARDS count

	 * @return Total all CARDS in the current game

	 */

    function getCardsCount() public view returns(uint256) {

        return cards.length;

    }



    /**

	 * @dev use this function to get CARDS id by its name.

	 * @param _nameString must be created when creating CARD

	 * @return the card id

	 */

    function getCardId(string _nameString) public view returns(uint256) {

        bytes32 _name = _nameString.nameFilter();

        require(cardIsReg[_name] == true, "sorry create this card first");

        return cardNameXId[_name];

    }



    /**

	 * @dev use this function to get player id by the name.

	 * @param _nameString must be created when creating CARD

	 * @return the player id

	 */

    function getPlayerId(string _nameString) public view returns(uint256) {

        bytes32 _name = _nameString.nameFilter();

        require(playerIsReg[_name] == true, "sorry register the player name first");

        return plyNameXId[_name];

    }



    /**

	 * @dev use this function to get player bet count.

	 * @param _playerName must be created when registering player

	 * @param _roundId must be a game that has already started

	 * @param _cardName the player id must be created when creating CARD

	 * @return likeCount

	 * @return dislikeCount

	 */

    function getPlayerBetCount(string _playerName, uint256 _roundId, string _cardName) public view returns(uint256 likeCount, uint256 dislikeCount) {

        bytes32 _cardNameByte = _cardName.nameFilter();

        require(cardIsReg[_cardNameByte] == false);



        bytes32 _playerNameByte = _playerName.nameFilter();

        require(playerIsReg[_playerNameByte] == false);

        return (playerCard[plyNameXId[_playerNameByte]][_roundId][cardNameXId[_cardNameByte]].likeCount, playerCard[plyNameXId[_playerNameByte]][_roundId][cardNameXId[_cardNameByte]].dislikeCount);

    }

}