/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract AerumCrowdsaleInterface {

    uint256 public tokensSold;

    uint256 public usdRaised;

    uint256 public weiRaised;

}



/**

 * @title Aerum crowdsale statistics contract

 */

contract AerumCrowdsaleStatistics is Ownable {

    using SafeMath for uint256;



    /**

     * @dev crowdsale Aerum crowdsale contract

     * @dev offchainTokensSold Off-chain tokens sold

     * @dev offchainUsdRaised Off-chain USD raised

     * @dev offchainWeiRaised Off-chain wei raised

     */

    AerumCrowdsaleInterface public crowdsale;

    uint256 public offchainTokensSold;

    uint256 public offchainUsdRaised;

    uint256 public offchainWeiRaised;



    /**

     * @param _crowdsale Aerum crowdsale contract

     * @param _offchainTokensSold Off-chain tokens sold

     * @param _offchainUsdRaised Off-chain USD raised

     * @param _offchainWeiRaised Off-chain wei raised

     */

    constructor(

        AerumCrowdsaleInterface _crowdsale,

        uint256 _offchainTokensSold,

        uint256 _offchainUsdRaised,

        uint256 _offchainWeiRaised)

    public {

        require(_crowdsale != address(0));



        crowdsale = _crowdsale;

        offchainTokensSold = _offchainTokensSold;

        offchainUsdRaised = _offchainUsdRaised;

        offchainWeiRaised = _offchainWeiRaised;

    }



    function setOffchainTokensSold(uint256 _tokens) external onlyOwner {

        offchainTokensSold = _tokens;

    }



    function setOffchainUsdRaised(uint256 _usd) external onlyOwner {

        offchainUsdRaised = _usd;

    }



    function setOffchainWeiRaised(uint256 _wei) external onlyOwner {

        offchainWeiRaised = _wei;

    }



    function setOffchainStatistics(uint256 _tokens, uint256 _usd, uint256 _wei) external onlyOwner {

        offchainTokensSold = _tokens;

        offchainUsdRaised = _usd;

        offchainWeiRaised = _wei;

    }



    function getTotalTokensSold() public view returns (uint256) {

        return offchainTokensSold.add(crowdsale.tokensSold());

    }



    function getTotalUsdRaised() public view returns (uint256) {

        return offchainUsdRaised.add(crowdsale.usdRaised());

    }



    function getTotalWeiRaised() public view returns (uint256) {

        return offchainWeiRaised.add(crowdsale.weiRaised());

    }



    function getTotalStatistics() external view returns (uint256, uint256, uint256) {

        return (getTotalTokensSold(), getTotalUsdRaised(), getTotalWeiRaised());

    }

}