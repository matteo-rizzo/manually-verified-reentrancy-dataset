/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity 0.5.10;






contract BridgeVault is Ownable {
    event EthTransferred(address indexed to, uint256 amount);

    function () payable external {

    }

    function multiSend(address _token, address[] memory _addresses, uint256[] memory _amounts) public onlyOwner {
        require(_addresses.length == _amounts.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            IERC20(_token).transfer(_addresses[i], _amounts[i]);
        }
    }
    
    function send(address _token, address _address, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(_address, _amount);
    }

    function transferEth(address payable to, uint256 amount) public onlyOwner {
        address(to).transfer(amount);
        emit EthTransferred(to, amount);
    }
}