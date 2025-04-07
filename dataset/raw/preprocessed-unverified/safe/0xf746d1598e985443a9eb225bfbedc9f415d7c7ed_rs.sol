/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity 0.5.4;











/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





contract TokenReceiver is Ownable {

    IERC20 public token;



    event Receive(address from, uint invoiceID, uint amount);



    constructor (address _token) public {

        require(_token != address(0));



        token = IERC20(_token);

    }



    function receiveTokenWithInvoiceID(uint _invoiceID, uint _amount) public {

        require(token.transferFrom(msg.sender, address(this), _amount), "");

        

        emit Receive(msg.sender, _invoiceID, _amount);

    }



    function changeToken(address _token) public onlyOwner {

        token = IERC20(_token);

    }

    

    function reclaimToken(IERC20 _token, uint _amount) external onlyOwner {

        _token.transfer(owner, _amount);

    }

}