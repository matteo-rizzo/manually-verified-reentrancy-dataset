/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity ^0.4.24;



// https://github.com/ethereum/EIPs/issues/20









contract PTToDaiConversionRate {

    function recordImbalance(

        ERC20 token,

        int buyAmount,

        uint rateUpdateBlock,

        uint currentBlock

    )

        public {

            // do nothing

        }



    function getRate(ERC20 token, uint currentBlockNumber, bool buy, uint qty) public view returns(uint) {

        if(token != 0x094c875704c14783049DDF8136E298B3a099c446) return 0;

        if(buy) return 0;

        



        uint slippageRate;

        uint expectedRate;

        (expectedRate,slippageRate) = KyberProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755).

                getExpectedRate(ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),

                                ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359),

                                (10**17 * qty) / 10**18);

        return (10**18 * 10**18/ expectedRate) + 1;

    }    

}