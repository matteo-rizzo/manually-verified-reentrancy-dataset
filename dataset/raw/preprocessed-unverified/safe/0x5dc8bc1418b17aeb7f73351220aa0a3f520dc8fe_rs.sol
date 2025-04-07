pragma solidity ^0.4.24;







contract CRTLotto is Owned {

    uint public ticketPrice;

    uint public totalTickets;



    mapping(uint => address) public tickets;



    constructor() public {

        ticketPrice = 0.01 * 10 ** 18;

        totalTickets = 0;

    }

    

    function setTicketPrice(uint _ticketPrice) external onlyOwner {

        ticketPrice = _ticketPrice;

    }

    

    function() payable external {

        uint ethSent = msg.value;

        require(ethSent >= ticketPrice);

        

        tickets[totalTickets] = msg.sender;

        totalTickets += 1;

    }

    

    function resetLotto() external onlyOwner {

        totalTickets = 0;

    }

    

    function withdrawEth() external onlyOwner {

        owner.transfer(address(this).balance);

    }

}