/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: WARRewards.sol
*
* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward, uint256 _duration) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {
        rewardDistribution = _rewardDistribution;
    }
}

contract BettingV2 is IRewardDistributionRecipient{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping (string => BetNChoices) bets;
    string[] betIds;

    address payable uniswapAddress;
    address payable yieldwarsAddress;

    struct BetChoice {
        uint32 choiceId;
        uint256 value;
        bool isClaimed;
        uint256 ethEarnings;
        uint256 timestamp;
    }

    struct BetNChoices {
        string  id;
        uint256  endTime;
        uint256  lastClaimTime;
        string desc;

        bool  isPaused;
        bool  isCanceled;
        bool  isFinal;
        bool  isFeesClaimed;

        uint32  winner;

        mapping(address => BetChoice)  bets;
        address[] betters;
        mapping(uint32 => uint256)  pots;

        mapping(string => uint32)  stringChoiceToId;
        mapping(uint32 => string)  choiceIdToString;

        uint256 totalPot;
        string[] possibleChoices;
    }

    struct BetCreationRequest {
        string id;
        string desc;
        uint256 endTime;
        uint256 lastClaimTime;

        string[] choices;
    }

    event ETHBetChoice(address indexed user, uint256 amount, string betId, string choice);
    event EarningsPaid(string betId, address indexed user, uint256 ethEarnings);

    modifier checkStatus(BetNChoices memory bet) {
        require(!bet.isFinal, "battle is decided");
        require(!bet.isCanceled, "battle is canceled, claim your bet");
        require(!bet.isPaused, "betting not started");
        require(block.timestamp < bet.endTime, "betting has ended");
        _;
    }

    constructor(address _rewardDistribution, address payable _uniswapAddress, address payable _yieldwarsAddress) public {
        require(_uniswapAddress != address(0));
        require(_yieldwarsAddress != address(0));
        uniswapAddress = _uniswapAddress;
        yieldwarsAddress = _yieldwarsAddress;

        rewardDistribution = _rewardDistribution;    
    }


    function createBet(string calldata _id, string calldata _desc, uint256 _endTime, uint256 _lastClaimTime, string calldata choice1, string calldata choice2) external onlyRewardDistribution {

        string[] memory choices = new string[](2);
        choices[0] = choice1;
        choices[1] = choice2;

        BetCreationRequest memory req = BetCreationRequest({
            id: _id,
            endTime: _endTime,
            lastClaimTime: _lastClaimTime,
            choices: choices,
            desc: _desc
        });

        _createBet(req);
    }

    function _createBet(BetCreationRequest memory req) internal {
        BetNChoices storage bet = bets[req.id];
        require(keccak256(bytes(bet.id)) == keccak256(bytes("")), "Bet already exists");
        require(req.lastClaimTime > req.endTime, "lastClaimTime must be greater than endTime");

        bet.id = req.id;
        bet.endTime = req.endTime;
        bet.lastClaimTime = req.lastClaimTime;
        bet.desc = req.desc;
        for (uint32 i = 1; i <= req.choices.length; i++) {
            bet.stringChoiceToId[req.choices[i-1]] = i;
            bet.choiceIdToString[i] = req.choices[i-1];
        }
        bet.possibleChoices = req.choices;
        betIds.push(bet.id);
    }


    function ETHBet(string memory betId, string memory choice) public payable {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        ETHBetOnBet(bet, choice);
    }

    function pauseBetting(string calldata betId) external onlyRewardDistribution {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        bet.isPaused = true;
    }

    function unpauseBetting(string calldata betId) external onlyRewardDistribution {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        bet.isPaused = false;
    }

    function cancelBet(string calldata betId) external onlyRewardDistribution {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(!bet.isFinal, "battle is decided");
        bets[betId].isCanceled = true;
    }

    function finalizeBet(string calldata betId, string calldata choice) external onlyRewardDistribution {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");

        uint32 choiceId = bet.stringChoiceToId[choice];
        require(choiceId != 0, "Invalid choice");

        require(!bet.isFinal, "battle is decided");
        require(!bet.isCanceled, "battle is canceled");

        bet.winner = choiceId;
        bet.isFinal = true;
    }

    function transferFees(string calldata betId) external onlyRewardDistribution {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(bet.isFinal, "bet is not final");
        require(!bet.isFeesClaimed, "fees claimed");

        bet.isFeesClaimed = true;

        uint256 pot = bet.totalPot.sub(bet.pots[bet.winner]);
        uint256 ethFees = pot.mul(1e19).div(1e20).div(2);

        if (ethFees != 0) {
            _safeTransfer(uniswapAddress, ethFees);
            _safeTransfer(yieldwarsAddress, ethFees);
        }
    }

    function updateAddresses(address payable _uniswapAddress, address payable _yieldwarsAddress) external onlyRewardDistribution {
        require(_uniswapAddress != address(0));
        require(_yieldwarsAddress != address(0));
        uniswapAddress = _uniswapAddress;
        yieldwarsAddress = _yieldwarsAddress;
    }

    function _safeTransfer(address payable to, uint256 amount) internal {
        uint256 balance;
        balance = address(this).balance;
        if (amount > balance) {
            amount = balance;
        }
        Address.sendValue(to, amount);
    }

    function ETHBetOnBet(BetNChoices storage bet, string memory choice) private checkStatus(bet) {
        require(msg.value != 0, "no ether sent");

        uint32 choiceId = bet.stringChoiceToId[choice];
        require(choiceId != 0, "invalid choice string");

        BetChoice storage currentBet = bet.bets[msg.sender];
        if (currentBet.choiceId == 0) {
            currentBet.choiceId = choiceId;
        } else {
            require(currentBet.choiceId == choiceId, "Sorry. You already bet on the other side with ETH");
        }
        if (currentBet.value == 0) {
            // first bet for account
            bet.betters.push(msg.sender);
        }
        currentBet.value += msg.value;
        currentBet.timestamp = block.timestamp;
        bet.pots[choiceId] += msg.value;
        bet.totalPot += msg.value;
        emit ETHBetChoice(msg.sender, msg.value, bet.id, choice);
    }

    function computeEarned(BetNChoices storage bet, BetChoice memory accountBet) private view returns (uint256 ethEarnings) {
        uint256 winningPot = bet.pots[bet.winner];
        uint256 totalWinnings = bet.totalPot.sub(winningPot);
        if (bet.isCanceled) {
            ethEarnings = accountBet.value;
        } else if (accountBet.choiceId != bet.winner || accountBet.value == 0) {
            ethEarnings = 0;
        } else if (!bet.isFinal){
            ethEarnings = 0;
        } else {
            uint256 winnings = totalWinnings.mul(accountBet.value).div(winningPot);
            uint256 fee = winnings.mul(1e19).div(1e20);
            ethEarnings = winnings.sub(fee);
            ethEarnings = ethEarnings.add(accountBet.value);
        }
    }

    function earned(string memory betId, address account) public view returns (uint256 ) {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(bet.isFinal || bet.isCanceled, "Bet is not finished");
        BetChoice memory accountBet = bet.bets[account];
        return computeEarned(bet, accountBet);
    }

    function getRewards(string memory betId) public {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        require(bet.isFinal || bet.isCanceled, "battle not decided");

        BetChoice storage accountBet = bet.bets[msg.sender];

        uint256 ethEarnings = earned(betId, msg.sender);
        if (ethEarnings != 0) {
            require(!accountBet.isClaimed, "Rewards already claimed");
            accountBet.isClaimed = true;
            accountBet.ethEarnings = ethEarnings;
            _safeTransfer(msg.sender, ethEarnings);
        }
        emit EarningsPaid(betId, msg.sender, ethEarnings);
    }

    struct OutstandingReward {
        string betId;
        uint256 value;
    }

    function listOutstandingRewards(address account) public view returns (OutstandingReward[] memory) {
        uint rewardCount = 0;
        for (uint i; i < betIds.length; i++) {
            BetNChoices memory bet = bets[betIds[i]];
            if (bet.isFinal) {
                uint256 reward = earned(bet.id, account);
                if (reward > 0) {
                    rewardCount++;
                }
            }
        }
        OutstandingReward[] memory rewards = new OutstandingReward[](rewardCount);
        uint r = 0;
        for (uint i; i < betIds.length; i++) {
            BetNChoices memory bet = bets[betIds[i]];
            if (bet.isFinal) {
                uint256 reward = earned(bet.id, account);
                if (reward > 0) {
                    rewards[r] = OutstandingReward(bet.id, reward);
                    r++;
                }
            }
        }

        return rewards;
    }

    function rescueFunds() external onlyRewardDistribution {
        require(betIds.length > 0, "sanity check with betIds.length");
        for (uint i = 0; i < betIds.length; i ++) {
            BetNChoices storage bet = bets[betIds[i]];
            require(block.timestamp >= bet.lastClaimTime, "not allowed yet");
        }

        Address.sendValue(msg.sender, address(this).balance);
    }
    
    struct GetBetChoiceResponse {
        address account;
        string choiceId;
        uint256 value;
        bool isClaimed;
        uint256 ethEarnings;
        bool won;
        uint256 timestamp;
    }

    struct GetBetPotResponse {
        string choice;
        uint256 value;
    }

    struct GetBetResponse {
        string  id;
        uint256  endTime;
        uint256  lastClaimTime;
        string desc;

        bool  isPaused;
        bool  isCanceled;
        bool  isFinal;
        bool  isFeesClaimed;

        string  winner;
        uint256 totalPot;

        string[] possibleChoices;
        GetBetChoiceResponse[] bets;
        GetBetPotResponse[] pots;
    }

    function getBet(string memory betId) public view returns (GetBetResponse memory response) {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");

        response.id = bet.id;
        response.endTime = bet.endTime;
        response.lastClaimTime = bet.lastClaimTime;
        response.isPaused = bet.isPaused;
        response.isCanceled = bet.isCanceled;
        response.isFinal = bet.isFinal;
        response.isFeesClaimed = bet.isFeesClaimed;

        if (bet.winner != 0) {
            response.winner = bet.choiceIdToString[bet.winner];
        }
        response.totalPot = bet.totalPot;
        response.possibleChoices = bet.possibleChoices;

        GetBetChoiceResponse[] memory betsResponse = new GetBetChoiceResponse[](bet.betters.length);

        for (uint i = 0; i < bet.betters.length; i++) {
            address account = bet.betters[i];
            BetChoice memory accountBet = bet.bets[account];

            betsResponse[i] = serializeBetChoice(bet, accountBet, account);
        }
        response.bets = betsResponse;

        GetBetPotResponse[] memory potsResponse = new GetBetPotResponse[](bet.possibleChoices.length);

        for (uint32 i = 0; i < bet.possibleChoices.length; i++ ) {
            uint32 choiceId = i + 1;
            string memory choiceStr = bet.choiceIdToString[choiceId];
            potsResponse[i] = GetBetPotResponse({
                choice: choiceStr,
                value: bet.pots[choiceId]
            });
        }

        response.pots = potsResponse;
    }
    struct BetHistoryResponse {
        string betId;
        GetBetChoiceResponse data;
    }

    function getBetHistory(address account) public view returns (BetHistoryResponse[] memory) {
        uint resultSize = 0;
        for (uint betId = 0; betId < betIds.length; betId++) {
            BetNChoices storage bet = bets[betIds[betId]];
            BetChoice memory accountBet = bet.bets[account];
            if ((bet.isFinal || bet.isCanceled) && accountBet.choiceId != 0 && accountBet.value != 0) {
                resultSize ++;
            }
        }
        
        BetHistoryResponse[] memory response = new BetHistoryResponse[](resultSize);
        uint i = 0;
        for (uint betId = 0; betId < betIds.length; betId++) {
            BetNChoices storage bet = bets[betIds[betId]];
            BetChoice memory accountBet = bet.bets[account];
            if ((bet.isFinal || bet.isCanceled) && accountBet.choiceId != 0 && accountBet.value != 0) {
                response[i].betId = bet.id;
                response[i].data = serializeBetChoice(bet, accountBet, account);
                i++;
            }
        }
        return response;
    }

    function serializeBetChoice(BetNChoices storage bet, BetChoice memory accountBet, address account) internal view returns (GetBetChoiceResponse memory) {
        bool won = false;

        if (bet.isFinal && !bet.isCanceled && accountBet.choiceId == bet.winner) {
            won = true;
        }

       return GetBetChoiceResponse({
            account: account,
            choiceId: bet.choiceIdToString[accountBet.choiceId],
            value: accountBet.value,
            isClaimed: accountBet.isClaimed,
            ethEarnings: computeEarned(bet, accountBet),
            won: won,
            timestamp: accountBet.timestamp
        });
    }

    function getCurrentBet(string memory betId, address accountAddress) public view returns (GetBetChoiceResponse memory) {
        BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");
        BetChoice memory accountBet = bet.bets[accountAddress];
        require (accountBet.choiceId != 0 && accountBet.value != 0, "not found");

        return serializeBetChoice(bet, accountBet, accountAddress);
    }

    function getPots(string memory betId) public view returns (GetBetPotResponse[] memory) {
         BetNChoices storage bet = bets[betId];
        require(keccak256(bytes(bet.id)) == keccak256(bytes(betId)), "Invalid bet id");

        GetBetPotResponse[] memory potsResponse = new GetBetPotResponse[](bet.possibleChoices.length);

        for (uint32 i = 0; i < bet.possibleChoices.length; i++ ) {
            uint32 choiceId = i + 1;
            string memory choiceStr = bet.choiceIdToString[choiceId];
            potsResponse[i] = GetBetPotResponse({
                choice: choiceStr,
                value: bet.pots[choiceId]
            });
        }

        return potsResponse;
    }

    // unused
    function notifyRewardAmount(uint256 reward, uint256 _duration) external { return; }

}