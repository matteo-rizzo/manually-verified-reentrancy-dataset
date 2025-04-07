/**

 *Submitted for verification at Etherscan.io on 2019-02-19

*/



pragma solidity 0.5.3;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Raffle is Ownable {

    using SafeMath for uint256;

    

    uint256 public _ticketPrice;

    uint256 public _totalParticipants;

    address payable _fundStorage;

    mapping(uint256 => address) _participants;

    

    event RaffleEnded(address winner);

    

    constructor() public {

        _ticketPrice = 0.05 ether;

        _fundStorage = msg.sender;

        _totalParticipants = 0;

    }

    

    function setTicketPrice(uint256 ticketPrice) public onlyOwner {

        require(ticketPrice > 0);

        _ticketPrice = ticketPrice;

    }

    

    function _buyTicket(address participantAddress) internal {

        _participants[_totalParticipants] = participantAddress;

        _totalParticipants += 1;

    }

    

    function pickWinner() public onlyOwner {

        uint256 winnerId = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.number, block.gaslimit))) % _totalParticipants;

        address winnerAddress = _participants[winnerId];

        emit RaffleEnded(winnerAddress);

        resetRaffle();

    }

    

    function resetRaffle() internal onlyOwner {

        _totalParticipants = 0;

        _fundStorage.transfer(address(this).balance);

    }

    

    function () external payable {

        require(msg.value == _ticketPrice, "INCORRECT AMOUNT OF ETH");

        _buyTicket(msg.sender);

    }

}