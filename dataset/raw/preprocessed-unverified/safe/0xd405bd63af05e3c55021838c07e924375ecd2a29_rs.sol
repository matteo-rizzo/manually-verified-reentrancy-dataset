/**

 *Submitted for verification at Etherscan.io on 2018-11-11

*/



pragma solidity ^0.4.24;























contract Games {

    using SafeMath for int;

    using SafeMath for uint;



    mapping (uint => GameInterface) public games;



    /**

     * @dev constructor

     * @param gameContracts addresses of different game implementations.

     */

    constructor (address[] gameContracts) public {

        for (uint i = 0; i < gameContracts.length; i++) {

            // set first GameInterface to 0 0 => start with i + 1

            games[i + 1] = GameInterface(gameContracts[i]);

        }

    }



    /**

     * @dev Returns the max allowed bet for a specific game.

     * @param _gameType game identifier.

     * @param _num game specific bet number.

     * @param _bankRoll bank roll size.

     * @return max allowed bet.

     */

    function maxBet(uint8 _gameType, uint _num, uint _bankRoll) public view returns(uint) {

        uint maxBetVal = getGameImplementation(_gameType).maxBet(_num, _bankRoll);

        return maxBetVal.add(5e14).div(1e15).mul(1e15); // round to multiple of 0.001 Ether

    }



    /**

     * @dev Calculates the result of the bet.

     * @param _gameType game identifier.

     * @param _serverSeed server seed.

     * @param _userSeed user seed.

     * @param _num game specific bet number.

     * @return result number.

     */

    function resultNumber(uint8 _gameType, bytes32 _serverSeed, bytes32 _userSeed, uint _num) public view returns(uint) {

        return getGameImplementation(_gameType).resultNumber(_serverSeed, _userSeed, _num);

    }



    /**

     * @dev Calculates the user profit for the bet.

     * @param _gameType game identifier.

     * @param _num game specific bet number.

     * @param _betValue bet value.

     * @param _resultNum bet result.

     * @return user profit.

     */

    function userProfit(uint8 _gameType, uint _num, uint _betValue, uint _resultNum) public view returns(int) {

        uint betValue = _betValue / 1e9; // convert to gwei



        int res = getGameImplementation(_gameType).userProfit(_num, betValue, _resultNum);



        return res.mul(1e9); // convert to wei

    }



    /**

     * @dev Calculates the maximal posible user profit for the given bet.

     * @param _gameType game identifier.

     * @param _num game specific bet number e.g. 0 or 1 for RollADice.

     * @param _betValue bet value.

     * @return max user profit.

     */

    function maxUserProfit(uint8 _gameType, uint _num, uint _betValue) public view returns(int) {

        uint betValue = _betValue / 1e9; // convert to gwei



        int res = getGameImplementation(_gameType).maxUserProfit(_num, betValue);



        return res.mul(1e9); // convert to wei

    }



    /**

     * @dev Returns the game implementation contract for the given game type.

     * @param _gameType game identifier.

     * @return game implementation contract.

     */

    function getGameImplementation(uint8 _gameType) private view returns(GameInterface) {

        require(games[_gameType] != GameInterface(0), "Invalid game type");

        return games[_gameType];



    }

}



contract ConflictResolution is ConflictResolutionInterface, Games {

    using SafeCast for int;

    using SafeCast for uint;

    using SafeMath for int;

    using SafeMath for uint;



    uint public constant SERVER_TIMEOUT = 6 hours;

    uint public constant USER_TIMEOUT = 6 hours;



    uint public constant MIN_BET_VALUE = 1e13; /// min 0.00001 ether bet

    uint public constant MIN_BANKROLL = 15e18;



    int public constant NOT_ENDED_FINE = 1e15; /// 0.001 ether



    int public constant CONFLICT_END_FINE = 1e15; /// 0.001 ether



    int public constant MAX_BALANCE = int(MIN_BANKROLL / 2);



    modifier onlyValidBet(uint8 _gameType, uint _betNum, uint _betValue) {

        require(isValidBet(_gameType, _betNum, _betValue), "inv bet");

        _;

    }



    modifier onlyValidBalance(int _balance, uint _gameStake) {

        require(-_gameStake.castToInt() <= _balance && _balance <= MAX_BALANCE, "inv balance");

        _;

    }



    /**

     * @dev constructor

     * @param games the games specific contracts.

     */

    constructor(address[] games) Games(games) public {

        // Nothing to do

    }



    /**

     * @return Conflict end fine.

     */

    function conflictEndFine() public pure returns(int) {

        return CONFLICT_END_FINE;

    }



    /**

     * @return Max balance.

     */

    function maxBalance() public view returns(int) {

        return MAX_BALANCE;

    }



    /**

     * Calculate minimum needed house stake.

     */

    function minHouseStake(uint activeGames) public view returns(uint) {

        return  MathUtil.min(activeGames, 1) * MIN_BANKROLL;

    }



    /**

     * @dev Check if bet is valid.

     * @param _gameType Game type.

     * @param _betNum Number of bet.

     * @param _betValue Value of bet.

     * @return True if bet is valid false otherwise.

     */

    function isValidBet(uint8 _gameType, uint _betNum, uint _betValue) public view returns(bool) {

        bool validMinBetValue = MIN_BET_VALUE <= _betValue;

        bool validMaxBetValue = _betValue <= Games.maxBet(_gameType, _betNum, MIN_BANKROLL);

        return validMinBetValue && validMaxBetValue;

    }





    /**

     * @dev Calculates game result and returns new balance.

     * @param _gameType Type of game.

     * @param _betNum Bet number.

     * @param _betValue Value of bet.

     * @param _balance Current balance.

     * @param _serverSeed Server's seed of current round.

     * @param _userSeed User's seed of current round.

     * @return New game session balance.

     */

    function endGameConflict(

        uint8 _gameType,

        uint _betNum,

        uint _betValue,

        int _balance,

        uint _stake,

        bytes32 _serverSeed,

        bytes32 _userSeed

    )

        public

        view

        onlyValidBet(_gameType, _betNum, _betValue)

        onlyValidBalance(_balance, _stake)

        returns(int)

    {

        require(_serverSeed != 0 && _userSeed != 0, "inv seeds");



        int newBalance =  processBet(_gameType, _betNum, _betValue, _balance, _serverSeed, _userSeed);



        // user need to pay a fee when conflict ended.

        // this ensures a malicious, rich user can not just generate game sessions and then wait

        // for us to end the game session and then confirm the session status, so

        // we would have to pay a high gas fee without profit.

        newBalance = newBalance.sub(CONFLICT_END_FINE);



        // do not allow balance below user stake

        int stake = _stake.castToInt();

        if (newBalance < -stake) {

            newBalance = -stake;

        }



        return newBalance;

    }



    /**

     * @dev Force end of game if user does not respond. Only possible after a time period.

     * to give the user a chance to respond.

     * @param _gameType Game type.

     * @param _betNum Bet number.

     * @param _betValue Bet value.

     * @param _balance Current balance.

     * @param _stake User stake.

     * @param _endInitiatedTime Time server initiated end.

     * @return New game session balance.

     */

    function serverForceGameEnd(

        uint8 _gameType,

        uint _betNum,

        uint _betValue,

        int _balance,

        uint _stake,

        uint _endInitiatedTime

    )

        public

        view

        onlyValidBalance(_balance, _stake)

        returns(int)

    {

        require(_endInitiatedTime + SERVER_TIMEOUT <= block.timestamp, "too low timeout");

        require((_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0)

                || isValidBet(_gameType, _betNum, _betValue), "inv bet");





        // assume user has lost

        int newBalance = _balance.sub(_betValue.castToInt());



        // penalize user as he didn't end game

        newBalance = newBalance.sub(NOT_ENDED_FINE);



        // do not allow balance below user stake

        int stake = _stake.castToInt();

        if (newBalance < -stake) {

            newBalance = -stake;

        }



        return newBalance;

    }



    /**

     * @dev Force end of game if server does not respond. Only possible after a time period

     * to give the server a chance to respond.

     * @param _gameType Game type.

     * @param _betNum Bet number.

     * @param _betValue Value of bet.

     * @param _balance Current balance.

     * @param _endInitiatedTime Time server initiated end.

     * @return New game session balance.

     */

    function userForceGameEnd(

        uint8 _gameType,

        uint _betNum,

        uint _betValue,

        int _balance,

        uint  _stake,

        uint _endInitiatedTime

    )

        public

        view

        onlyValidBalance(_balance, _stake)

        returns(int)

    {

        require(_endInitiatedTime + USER_TIMEOUT <= block.timestamp, "too low timeout");

        require((_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0)

                || isValidBet(_gameType, _betNum, _betValue), "inv bet");



        int profit = 0;

        if (_gameType == 0 && _betNum == 0 && _betValue == 0 && _balance == 0) {

            // user cancelled game without playing

            profit = 0;

        } else {

            profit = Games.maxUserProfit(_gameType, _betNum, _betValue);

        }



        // penalize server as it didn't end game

        profit = profit.add(NOT_ENDED_FINE);



        return _balance.add(profit);

    }



    /**

     * @dev Calculate new balance after executing bet.

     * @param _gameType game type.

     * @param _betNum Bet Number.

     * @param _betValue Value of bet.

     * @param _balance Current balance.

     * @param _serverSeed Server's seed

     * @param _userSeed User's seed

     * return new balance.

     */

    function processBet(

        uint8 _gameType,

        uint _betNum,

        uint _betValue,

        int _balance,

        bytes32 _serverSeed,

        bytes32 _userSeed

    )

        public

        view

        returns (int)

    {

        uint resNum = Games.resultNumber(_gameType, _serverSeed, _userSeed, _betNum);

        int profit = Games.userProfit(_gameType, _betNum, _betValue, resNum);

        return _balance.add(profit);

    }

}