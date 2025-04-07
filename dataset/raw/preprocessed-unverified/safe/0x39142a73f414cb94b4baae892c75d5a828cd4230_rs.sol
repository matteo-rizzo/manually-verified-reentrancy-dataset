pragma solidity ^0.4.18;

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies
/// & the implementation of "user permissions".




 
contract Crowdsale is Ownable {
    
    address public beneficiary = msg.sender;
    token public epm;
    
    uint256 public constant EXCHANGE_RATE = 25000; // 25000 EPM for ETH
    uint256 public constant DURATION = 71 days;
    uint256 public startTime = 0;
    uint256 public endTime = 0;
    
    uint public amount = 0;

    mapping(address => uint256) public balanceOf;
    
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     */
     
    function Crowdsale() {
        epm = token(0xc5594d84B996A68326d89FB35E4B89b3323ef37d);
        startTime = now;
        endTime = startTime + DURATION;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
     
    function () payable onlyDuringSale() {
        uint SenderAmount = msg.value;
        balanceOf[msg.sender] += SenderAmount;
        amount = amount + SenderAmount;
        epm.transfer(msg.sender, SenderAmount * EXCHANGE_RATE);
        FundTransfer(msg.sender,  SenderAmount * EXCHANGE_RATE, true);
    }

 /// @dev Throws if called when not during sale.
    modifier onlyDuringSale() {
        if (now < startTime || now >= endTime) {
            throw;
        }

        _;
    }
    
    function Withdrawal() onlyOwner {
            if (amount > 0) {
                    if (beneficiary.send(amount)) {
                        FundTransfer(msg.sender, amount, false);
                        amount = 0;
                    } else {
                        balanceOf[beneficiary] = amount;
                }
            }

    }
}