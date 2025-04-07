pragma solidity ^0.4.11;





/// @title Loopring Refund Program
/// @author Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="442f2b2a23282d252a2304282b2b34362d2a236a2b3623">[email&#160;protected]</a>>.
/// For more information, please visit https://loopring.org.
contract BatchTransferContract {
    using SafeMath for uint;
    using Math for uint;

    address public owner;

    function BatchTransferContract(address _owner) public {
        owner = _owner;
    }

    function () payable {
        // do nothing.
    }

    function batchRefund(address[] investors, uint[] ethAmounts) public payable {
        require(msg.sender == owner);
        require(investors.length > 0);
        require(investors.length == ethAmounts.length);

        uint total = 0;
        for (uint i = 0; i < investors.length; i++) {
            total += ethAmounts[i];
        }

        require(total <= this.balance);

        for (i = 0; i < investors.length; i++) {
            if (ethAmounts[i] > 0) {
                investors[i].transfer(ethAmounts[i]);
            }
        }
    }

    function drain(uint ethAmount) public payable {
        require(msg.sender == owner);

        uint amount = ethAmount.min256(this.balance);
        if (amount > 0) {
          owner.transfer(amount);
        }
    }
}