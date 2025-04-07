/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.4.24;



/**

 * ERC20 contract interface.

 */

contract ERC20 {

    function totalSupply() public view returns (uint);

    function decimals() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title KyberNetwork

 * @dev Interface for KyberNetwork main contract.

 */

contract KyberNetwork {



    function getExpectedRate(

        ERC20 src,

        ERC20 dest,

        uint srcQty

    )

        public

        view

        returns (uint expectedRate, uint slippageRate);



    function trade(

        ERC20 src,

        uint srcAmount,

        ERC20 dest,

        address destAddress,

        uint maxDestAmount,

        uint minConversionRate,

        address walletId

    )

        public

        payable

        returns(uint);

}



/**

 * @title TokenPriceProvider

 * @dev Simple contract returning the price in ETH for ERC20 tokens listed on KyberNetworks. 

 * @author Olivier Van Den Biggelaar - <[emailÂ protected]>

 */

contract TokenPriceProvider {



    using SafeMath for uint256;



    // Mock token address for ETH

    address constant internal ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Address of Kyber's trading contract

    address constant internal KYBER_NETWORK_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;



    mapping(address => uint256) public cachedPrices;



    function syncPrice(ERC20 token) public {

        uint256 expectedRate;

        (expectedRate,) = kyberNetwork().getExpectedRate(token, ERC20(ETH_TOKEN_ADDRESS), 10000);

        cachedPrices[token] = expectedRate;

    }



    //

    // Convenience functions

    //



    function syncPriceForTokenList(ERC20[] tokens) public {

        for(uint16 i = 0; i < tokens.length; i++) {

            syncPrice(tokens[i]);

        }

    }



    /**

     * @dev Converts the value of _amount tokens in ether.

     * @param _amount the amount of tokens to convert (in 'token wei' twei)

     * @param _token the ERC20 token contract

     * @return the ether value (in wei) of _amount tokens with contract _token

     */

    function getEtherValue(uint256 _amount, address _token) public view returns (uint256) {

        uint256 decimals = ERC20(_token).decimals();

        uint256 price = cachedPrices[_token];

        return price.mul(_amount).div(10**decimals);

    }



    //

    // Internal

    //



    function kyberNetwork() internal view returns (KyberNetwork) {

        return KyberNetwork(KYBER_NETWORK_ADDRESS);

    }

}