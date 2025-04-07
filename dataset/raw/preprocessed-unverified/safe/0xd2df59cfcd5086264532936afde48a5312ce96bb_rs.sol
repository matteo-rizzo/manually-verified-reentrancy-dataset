/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity ^0.4.25;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









/**

* @title SafeMath

* @dev Math operations with safety checks that revert on error

*/









contract Auction is Ownable {

    

    using SafeMath for uint256;

    

    event bidPlaced(uint bid, address _address);

    event etherTransfered(uint amount, address _address);

    

    string _itemName;

    

    address _highestBidder;

    uint _highestBid;

    uint _minStep;

    uint _end;

    uint _start;

    

    constructor() public {

        

        _itemName = 'Pumpkinhead 1';

        _highestBid = 0;

        _highestBidder = address(this);

        

    				// 					    end

        // 23.10. 23:59pm UTC Pumpkinhead 1	1540339140

        // 27.10. 23:59pm UTC Pumpkinhead 2	1540684740

        // 31.10. 23:30pm UTC Pumpkinhead 3	1541028600

        // 31.10. 23:59pm UTC Frankie  		1541030340

        

        _end = 1540339140;

        _start = _end - 3 days;



        _minStep = 10000000000000000;



    }

    

    function queryBid() public view returns (string, uint, uint, address, uint, uint) {

        return (_itemName, _start, _highestBid, _highestBidder, _end, _highestBid+_minStep);

    }

    

    function placeBid() payable public returns (bool) {

        require(block.timestamp > _start, 'Auction not started');

        require(block.timestamp < _end, 'Auction ended');

        require(msg.value >= _highestBid.add(_minStep), 'Amount too low');



        uint _payout = _highestBid;

        _highestBid = msg.value;

        

        address _oldHighestBidder = _highestBidder;

        _highestBidder = msg.sender;

        

        if(_oldHighestBidder.send(_payout) == true) {

            emit etherTransfered(_payout, _oldHighestBidder);

        }

        

        emit bidPlaced(_highestBid, _highestBidder);

        

        return true;

    }

    

    function queryBalance() public view returns (uint) {

        return address(this).balance;

    }

    

    function weiToOwner(address _address) public contract_onlyOwner returns (bool success) {

        require(block.timestamp > _end, 'Auction not ended');



        _address.transfer(address(this).balance);

        

        return true;

    }

}