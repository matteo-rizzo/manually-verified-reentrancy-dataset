pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/



contract BitmarkPaymentGateway is Ownable {
    using SafeMath for uint256;

    event SettleFund(address _targetContract, uint256 amount);

    address public masterWallet;
    bool public paused;

    /* main function */
    function BitmarkPaymentGateway(address _masterWallet) public {
        paused = false;
        masterWallet = _masterWallet;
    }

    function SetMasterWallet(address _newWallet) public onlyOwner {
        masterWallet = _newWallet;
    }

    function PausePayment() public onlyOwner {
        paused = true;
    }

    function ResumePayment() public onlyOwner {
        paused = false;
    }

    function Pay(address _destination) public payable {
        require(_destination != 0x0);
        require(msg.value > 0);
        require(!paused);
        masterWallet.transfer(msg.value.div(9));
        _destination.call.value(msg.value.div(9).mul(8))();

        SettleFund(_destination, msg.value);
    }

    function () public {}
}