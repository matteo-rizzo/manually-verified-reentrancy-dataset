/**
 *Submitted for verification at Etherscan.io on 2021-08-24
*/

pragma solidity ^0.6.6;





contract Hold{

    modifier onlyController { 
        require(msg.sender == controller); 
        _; 
    }

    address public controller;
    
    constructor () public {
        controller = msg.sender;
    }

    function changeController(address _newController) public onlyController {
        controller = _newController;
    }


    function proxy(address token, address recipient,uint amount) public onlyController returns(bool) {
        IERC20 TOKEN = IERC20(token);
        bool succ = TOKEN.transfer(recipient, amount);
        require(succ);
        return true;
    }
}