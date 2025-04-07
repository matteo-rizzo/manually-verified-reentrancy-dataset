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

    mapping(uint256 => address) _participants;

    

    event RaffleEnded(address winner);

    

    constructor() public {

        _ticketPrice = 0.05 ether;

        _totalParticipants = 0;

    }

    

    function setTicketPrice(uint256 ticketPrice) public onlyOwner {

        require(ticketPrice > 0);

        _ticketPrice = ticketPrice;

    }

    

    function _buyTicket(address participantAddress) internal {

        _participants[_totalParticipants] = participantAddress;

        _totalParticipants += 1;

        

        if (_totalParticipants == 21) {

            uint256 winnerId = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.number, block.gaslimit))) % _totalParticipants;

            address payable winnerAddress = address(uint160(_participants[winnerId]));

            _totalParticipants = 0;

            emit RaffleEnded(winnerAddress);

            winnerAddress.transfer(20 * 0.05 ether);

            address payable ownerAddress = address(uint160(_owner));

            ownerAddress.transfer(0.05 ether);

        }

    }

    

    function () external payable {

        require(msg.value == _ticketPrice, "INCORRECT AMOUNT OF ETH");

        _buyTicket(msg.sender);

    }

}