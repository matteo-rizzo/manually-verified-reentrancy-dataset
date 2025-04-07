/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.24;



contract Forwarder {

    using SafeMath for *;



    string public name = "Forwarder";

    address private currentCorpBank1_ = 0xc95EFA676762BE92F70405B25214cd10616d0089;

    address private currentCorpBank2_ = 0xF29527437Eb2AE5Da10db32d49E27Cb22F04b875;

    address private currentCorpBank3_ = 0x19306Bfa01cB57A3F1E3CB80d2ACE2057661F41C;

    

    constructor() 

        public

    {

        //constructor does nothing.

    }

    

    function()

        public

        payable

    {

        // done so that if any one tries to dump eth into this contract, we can

        // just forward it to corp bank.

        if (currentCorpBank1_ != address(0) && currentCorpBank2_ != address(0) && currentCorpBank3_ != address(0))

            uint total = msg.value;

            uint div2 = (total/10).mul(3);

            uint div3 = (total/10).mul(4);

            uint div1 = (total.sub(div2)).sub(div3);

            currentCorpBank1_.transfer(div1);

            currentCorpBank2_.transfer(div2);

            currentCorpBank3_.transfer(div3);

    }

    

    function deposit()

        public 

        payable

        returns(bool)

    {

        require(msg.value > 0, "Forwarder Deposit failed - zero deposits not allowed");

        uint total = msg.value;

        uint div2 = (total/10).mul(3);

        uint div3 = (total/10).mul(4);

        uint div1 = (total.sub(div2)).sub(div3);

        currentCorpBank1_.transfer(div1);

        currentCorpBank2_.transfer(div2);

        currentCorpBank3_.transfer(div3);

        return(true);

    }



    function withdraw()

        public

        payable

    {

        require(msg.sender == currentCorpBank1_|| msg.sender == currentCorpBank2_ || msg.sender == currentCorpBank3_);

        uint total = address(this).balance;

        uint div2 = (total/10).mul(3);

        uint div3 = (total/10).mul(4);

        uint div1 = (total.sub(div2)).sub(div3);

        currentCorpBank1_.transfer(div1);

        currentCorpBank2_.transfer(div2);

        currentCorpBank3_.transfer(div3);

    }

}



