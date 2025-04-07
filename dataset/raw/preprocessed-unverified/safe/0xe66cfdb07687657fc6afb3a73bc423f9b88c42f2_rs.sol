/**

 *Submitted for verification at Etherscan.io on 2018-08-30

*/



pragma solidity 0.4.24;



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------













// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------







contract Crowdsale is Owned{

    using SafeMath for uint;

    uint public endDate;

    address public developer;

    address public marketing;

    address public kelly;

    address public company;

    uint public phaseOneEnd;

    uint public phaseTwoEnd;

    uint public phaseThreeEnd;

    token public CCC;

    

    event tokensBought(address _addr, uint _amount);

    constructor() public{

    phaseOneEnd = now + 3 days;

    phaseTwoEnd = now + 6 days;

    phaseThreeEnd = now + 9 days;

    CCC = token(0x4446B2551d7aCdD1f606Ef3Eed9a9af913AE3e51);

    developer = 0x215c6e1FaFa372E16CfD3cA7D223fc7856018793;

    company = 0x49BAf97cc2DF6491407AE91a752e6198BC109339;

    kelly = 0x36e8A1C0360B733d6a4ce57a721Ccf702d4008dE;

    marketing = 0x4DbADf088EEBc22e9A679f4036877B1F7Ce71e4f;

    }

    

    function() payable public{

        require(msg.value >= 0.4 ether);

        require(now < phaseThreeEnd);

        uint tokens;

        if (now <= phaseOneEnd) {

            tokens = msg.value * 12546;

        } else if (now > phaseOneEnd && now <= phaseTwoEnd) {

            tokens = msg.value * 12063;

        }else if( now > phaseTwoEnd && now <= phaseThreeEnd){

            tokens = msg.value * 11581;

        }

        CCC.transfer(msg.sender, tokens);

        emit tokensBought(msg.sender, tokens);

    }

    

    function safeWithdrawal() public onlyOwner {

        require(now >= phaseThreeEnd);

        uint amount = address(this).balance;

        uint devamount = amount/uint(100);

        uint devamtFinal = devamount*5;

        uint marketamtFinal = devamount*5;

        uint kellyamtFinal = devamount*5;

        uint companyamtFinal = devamount*85;

        developer.transfer(devamtFinal);

        marketing.transfer(marketamtFinal);

        company.transfer(companyamtFinal);

        kelly.transfer(kellyamtFinal);



        

    }

    



    function withdrawTokens() public onlyOwner{

        require(now >= phaseThreeEnd);

        uint Ownerbalance = CCC.balanceOf(this);

    	CCC.transfer(owner, Ownerbalance);

    	emit tokensCalledBack(Ownerbalance);



    }

    

}