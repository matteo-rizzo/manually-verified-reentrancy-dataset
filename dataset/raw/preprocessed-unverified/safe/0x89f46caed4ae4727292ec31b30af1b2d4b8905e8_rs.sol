/**

 *Submitted for verification at Etherscan.io on 2019-05-29

*/



pragma solidity 0.5.2;



/*

"Crypto Casino 333" (c) v.1.0

Copyright (c) 2019 by -= 333ETH Team =-



THIS IS TEST CONTRACT!!! DO NOT PLACE BET!!!



* Web - https://333eth.io

* Telegram_channel - https://t.me/Ethereum333

* EN  Telegram_chat: https://t.me/Ethereum333_chat_en

* RU  Telegram_chat: https://t.me/Ethereum333_chat_ru

*



... Fortes fortuna juvat ...



The innovative totally fair gambling platform -

A unique symbiosis of the classic online casino system and the revolutionary possibilities of the blockchain, using the power of the Ethereum smart contract for 100% transparency.



"Crypto Casino 333" is the quintessence of fair winning opportunities for any participant on equal terms. The system and technologies are transparent due to the blockchain, which is really capable of meeting all your expectations.



... Alea jacta est ...



We start  project without ICO & provide the following guarantees:



- ABSOLUTE TRANSPARENCY -

The random number generator is based on an Ethereum Smart Contract which is completely public. This means that everyone can see everything that is occurring inside the servers of the casino.



- NO HUMAN FACTOR -

All transactions are processed automatically according to the smart contract algorithms.



- TOTAL PROTECTION & PRIVACY -

All transactions are processed anonymously inside smart contract.





- TOTALLY FINANCIAL PLEASURE -

Only 1% casino commission, 99% goes to payout wins. Instant automatic withdrawal of funds directly from the smart contract.



Copyright (c) 2019 by -= 333ETH Team =-

"Games People are playing"





THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



*/













































/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */



































contract Accessibility {

  enum AccessRank { None, Croupier, Games, Withdraw, Full }

  mapping(address => AccessRank) public admins;

  modifier onlyAdmin(AccessRank  r) {

    require(

      admins[msg.sender] == r || admins[msg.sender] == AccessRank.Full,

      "accessibility: access denied"

    );

    _;

  }

  event LogProvideAccess(address indexed whom, uint when,  AccessRank rank);



  constructor() public {

    admins[msg.sender] = AccessRank.Full;

    emit LogProvideAccess(msg.sender, now, AccessRank.Full);

  }

  

  function provideAccess(address addr, AccessRank rank) public onlyAdmin(AccessRank.Full) {

    require(admins[addr] != AccessRank.Full, "accessibility: cannot change full access rank");

    if (admins[addr] != rank) {

      admins[addr] = rank;

      emit LogProvideAccess(addr, now, rank);

    }

  }

}





contract Casino is Accessibility {

  using PaymentLib for PaymentLib.Payment;

  using RollGameLib for RollGameLib.Game;

  using SlotGameLib for SlotGameLib.Game;



  bytes32 private constant JACKPOT_LOG_MSG = "casino.jackpot";

  bytes32 private constant WITHDRAW_LOG_MSG = "casino.withdraw";

  bytes private constant JACKPOT_NONCE = "jackpot";

  uint private constant MIN_JACKPOT_MAGIC = 3333;

  uint private constant MAX_JACKPOT_MAGIC = 333333333;

  

  SlotGameLib.Game public slot;

  RollGameLib.Game public roll;

  enum Game {Slot, Roll}



  uint public extraJackpot;

  uint public jackpotMagic;



  modifier slotBetsWasHandled() {

    require(slot.lockedInBets == 0, "casino.slot: all bets should be handled");

    _;

  }



  event LogPayment(address indexed beneficiary, uint amount, bytes32 indexed message);

  event LogFailedPayment(address indexed beneficiary, uint amount, bytes32 indexed message);



  event LogJactpot(

    address indexed beneficiary, 

    uint amount, 

    bytes32 hostSeed,

    bytes32 clientSeed,

    uint jackpotMagic

  );



  event LogSlotNewBet(

    bytes32 indexed hostSeedHash,

    address indexed gambler,

    uint amount,

    address indexed referrer

  );



  event LogSlotHandleBet(

    bytes32 indexed hostSeedHash,

    address indexed gambler,

    bytes32 hostSeed,

    bytes32 clientSeed,

    bytes symbols,

    uint multiplierNum,

    uint multiplierDen,

    uint amount,

    uint winnings

  );



  event LogSlotRefundBet(

    bytes32 indexed hostSeedHash,

    address indexed gambler, 

    uint amount

  );



  event LogRollNewBet(

    bytes32 indexed hostSeedHash, 

    uint8 t,

    address indexed gambler, 

    uint amount,

    uint mask, 

    uint rollUnder,

    address indexed referrer

  );



  event LogRollRefundBet(

    bytes32 indexed hostSeedHash, 

    uint8 t,

    address indexed gambler, 

    uint amount

  );



  event LogRollHandleBet(

    bytes32 indexed hostSeedHash, 

    uint8 t,

    address indexed gambler, 

    bytes32 hostSeed, 

    bytes32 clientSeed, 

    uint roll, 

    uint multiplierNum, 

    uint multiplierDen,

    uint amount,

    uint winnings

  );



  constructor() public {

    jackpotMagic = MIN_JACKPOT_MAGIC;

    slot.minBetAmount = SlotGameLib.MinBetAmount();

    slot.maxBetAmount = SlotGameLib.MinBetAmount();

    roll.minBetAmount = RollGameLib.MinBetAmount();

    roll.maxBetAmount = RollGameLib.MinBetAmount();

  }



  function() external payable {}

  

  /**

  * @dev Place bet to roll game.

  * @param t The type of roll game.

  * @param mask Bitmask for special roll game`s type. User choice.

  * @param rollUnder Roll under for special roll game`s type. User choice.

  * @param referrer Address of the gambler`s referrer.

  * @param hostSeedHash keccak256(hostSeed). The roll game`s bet id.

  * @param v V of ECDSA signature from hostSeedHash.

  * @param r R of ECDSA signature from hostSeedHash.

  * @param s S of ECDSA signature from hostSeedHash.

  */

  function rollPlaceBet(

    RollGameLib.Type t, 

    uint16 mask, 

    uint8 rollUnder, 

    address referrer,

    uint sigExpirationBlock, 

    bytes32 hostSeedHash, 

    uint8 v, 

    bytes32 r, 

    bytes32 s

  ) 

    external payable

  {

    roll.placeBet(t, mask, rollUnder, referrer, sigExpirationBlock, hostSeedHash, v, r, s);

  }



  function rollBet(bytes32 hostSeedHash) 

    external 

    view 

    returns (

      RollGameLib.Type t,

      uint amount,

      uint mask,

      uint rollUnder,

      uint blockNumber,

      address payable gambler,

      bool exist

    ) 

  {

    RollGameLib.Bet storage b = roll.bets[hostSeedHash];

    t = b.t;

    amount = b.amount;

    mask = b.mask;

    rollUnder = b.rollUnder;

    blockNumber = b.blockNumber;

    gambler = b.gambler;

    exist = b.exist;  

  }



  function slotPlaceBet(

    address referrer,

    uint sigExpirationBlock,

    bytes32 hostSeedHash,

    uint8 v,

    bytes32 r,

    bytes32 s

  ) 

    external payable

  {

    slot.placeBet(referrer, sigExpirationBlock, hostSeedHash, v, r, s);

  }



  function slotBet(bytes32 hostSeedHash) 

    external 

    view 

    returns (

      uint amount,

      uint blockNumber,

      address payable gambler,

      bool exist

    ) 

  {

    SlotGameLib.Bet storage b = slot.bets[hostSeedHash];

    amount = b.amount;

    blockNumber = b.blockNumber;

    gambler = b.gambler;

    exist = b.exist;  

  }



  function slotSetReels(uint n, bytes calldata symbols) 

    external 

    onlyAdmin(AccessRank.Games) 

    slotBetsWasHandled 

  {

    slot.setReel(n, symbols);

  }



  function slotReels(uint n) external view returns (bytes memory) {

    return slot.reels[n];

  }



  function slotPayLine(uint n) external view returns (bytes memory symbols, uint num, uint den) {

    symbols = new bytes(slot.payTable[n].symbols.length);

    symbols = slot.payTable[n].symbols;

    num = slot.payTable[n].multiplier.num;

    den = slot.payTable[n].multiplier.den;

  }



  function slotSetPayLine(uint n, bytes calldata symbols, uint num, uint den) 

    external 

    onlyAdmin(AccessRank.Games) 

    slotBetsWasHandled 

  {

    slot.setPayLine(n, SlotGameLib.Combination(symbols, NumberLib.Number(num, den)));

  }



  function slotSpecialPayLine(uint n) external view returns (byte symbol, uint num, uint den, uint[] memory indexes) {

    indexes = new uint[](slot.specialPayTable[n].indexes.length);

    indexes = slot.specialPayTable[n].indexes;

    num = slot.specialPayTable[n].multiplier.num;

    den = slot.specialPayTable[n].multiplier.den;

    symbol = slot.specialPayTable[n].symbol;

  }



  function slotSetSpecialPayLine(

    uint n,

    byte symbol,

    uint num, 

    uint den, 

    uint[] calldata indexes

  ) 

    external 

    onlyAdmin(AccessRank.Games) 

    slotBetsWasHandled

  {

    SlotGameLib.SpecialCombination memory scomb = SlotGameLib.SpecialCombination(symbol, NumberLib.Number(num, den), indexes);

    slot.setSpecialPayLine(n, scomb);

  }



  function handleBet(Game game, bytes32 hostSeed, bytes32 clientSeed) external onlyAdmin(AccessRank.Croupier) {

    PaymentLib.Payment memory p; 

    p = game == Game.Slot ? slot.handleBet(hostSeed, clientSeed) : roll.handleBet(hostSeed, clientSeed);

    checkEnoughFundsForPay(p.amount);

    p.send();



    p = rollJackpot(p.beneficiary, hostSeed, clientSeed);

    if (p.amount == 0) {

      return;

    }

    checkEnoughFundsForPay(p.amount);

    p.send();

  }



  function refundBet(Game game, bytes32 hostSeedHash) external {

    PaymentLib.Payment memory p; 

    p = game == Game.Slot ? slot.refundBet(hostSeedHash) : roll.refundBet(hostSeedHash);

    checkEnoughFundsForPay(p.amount);

    p.send();

  }



  function setSecretSigner(Game game, address secretSigner) external onlyAdmin(AccessRank.Games) {

    address otherSigner = game == Game.Roll ? slot.secretSigner : roll.secretSigner;

    require(secretSigner != otherSigner, "casino: slot and roll secret signers must be not equal");

    game == Game.Roll ? roll.secretSigner = secretSigner : slot.secretSigner = secretSigner;

  }



  function setMinMaxBetAmount(Game game, uint min, uint max) external onlyAdmin(AccessRank.Games) {

    game == Game.Roll ? roll.setMinMaxBetAmount(min, max) : slot.setMinMaxBetAmount(min, max);

  }



  function kill(address payable beneficiary) 

    external 

    onlyAdmin(AccessRank.Full) 

  {

    require(lockedInBets() == 0, "casino: all bets should be handled");

    selfdestruct(beneficiary);

  }



  function rollJackpot(

    address payable beneficiary,

    bytes32 hostSeed,

    bytes32 clientSeed

  ) 

    private returns(PaymentLib.Payment memory p) 

  {

    if (Rnd.uintn(hostSeed, clientSeed, jackpotMagic, JACKPOT_NONCE) != 0) {

      return p;

    }

    p.beneficiary = beneficiary;

    p.amount = jackpot();

    p.message = JACKPOT_LOG_MSG;



    delete slot.jackpot;

    delete roll.jackpot;

    delete extraJackpot;

    emit LogJactpot(p.beneficiary, p.amount, hostSeed, clientSeed, jackpotMagic);

  }



  function increaseJackpot(uint amount) external onlyAdmin(AccessRank.Games) {

    checkEnoughFundsForPay(amount);

    extraJackpot += amount;

    // todo event?

  }



  function setJackpotMagic(uint magic) external onlyAdmin(AccessRank.Games) {

    require(MIN_JACKPOT_MAGIC <= magic && magic <= MAX_JACKPOT_MAGIC, "casino: invalid jackpot magic");

    jackpotMagic = magic;

    // todo event?

  }



  function withdraw(address payable beneficiary, uint amount) external onlyAdmin(AccessRank.Withdraw) {

    checkEnoughFundsForPay(amount);

    PaymentLib.Payment(beneficiary, amount, WITHDRAW_LOG_MSG).send();

  }



  function lockedInBets() public view returns(uint) {

    return slot.lockedInBets + roll.lockedInBets;

  }



  function jackpot() public view returns(uint) {

    return slot.jackpot + roll.jackpot + extraJackpot;

  }



  function freeFunds() public view returns(uint) {

    if (lockedInBets() + jackpot() >= address(this).balance ) {

      return 0;

    }

    return address(this).balance - lockedInBets() - jackpot();

  }



  function checkEnoughFundsForPay(uint amount) private view {

    require(freeFunds() >= amount, "casino: not enough funds");

  }

}