pragma solidity ^0.4.24;



contract MultiEthSender {
    using SafeMath for uint256;

    event Send(uint256 _amount, address indexed _receiver);

    function multiSendEth(uint256 amount, address[] list) public returns (bool){
        uint256 _userCount = list.length;

        require( address(this).balance > amount.mul(_userCount));

        for(uint256 _i = 0; _i < _userCount; _i++){
            list[_i].transfer(amount);
            emit Send(amount, list[_i]);
        }

        return true;
    }

    function() public payable{}
}