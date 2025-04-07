/**

 *Submitted for verification at Etherscan.io on 2019-05-09

*/



pragma solidity 0.5.7;

pragma experimental ABIEncoderV2;





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







contract IRegistry {

    function add(address who) public;

}





contract IUniswapExchange {

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 timestamp) public payable returns (uint256);

}





contract IGovernance {

    function proposeWithFeeRecipient(address feeRecipient, address target, bytes memory data) public returns (uint);

    function proposalFee() public view returns (uint);

}





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */







/**

 * @title HumanityApplicant

 * @dev Convenient interface for applying to the Humanity registry.

 */

contract HumanityApplicant {

    using SafeMath for uint;



    IGovernance public governance;

    IRegistry public registry;

    IERC20 public humanity;



    constructor(IGovernance _governance, IRegistry _registry, IERC20 _humanity) public {

        governance = _governance;

        registry = _registry;

        humanity = _humanity;

        humanity.approve(address(governance), uint(-1));

    }



    function applyFor(address who) public returns (uint) {

        uint fee = governance.proposalFee();

        uint balance = humanity.balanceOf(address(this));

        if (fee > balance) {

            require(humanity.transferFrom(msg.sender, address(this), fee.sub(balance)), "HumanityApplicant::applyFor: Transfer failed");

        }

        bytes memory data = abi.encodeWithSelector(registry.add.selector, who);

        return governance.proposeWithFeeRecipient(msg.sender, address(registry), data);

    }



}





/**

 * @title PayableHumanityApplicant

 * @dev Convenient interface for applying to the Humanity registry using Ether.

 */

contract PayableHumanityApplicant is HumanityApplicant {



    IUniswapExchange public exchange;



    constructor(IGovernance _governance, IRegistry _registry, IERC20 _humanity, IUniswapExchange _exchange) public

        HumanityApplicant(_governance, _registry, _humanity)

    {

        exchange = _exchange;

    }



    function () external payable {}



    function applyWithEtherFor(address who) public payable returns (uint) {

        // Exchange Ether for Humanity tokens

        uint fee = governance.proposalFee();

        exchange.ethToTokenSwapOutput.value(msg.value)(fee, block.timestamp);



        // Apply to the registry

        uint proposalId = applyFor(who);



        // Refund any remaining balance

        msg.sender.send(address(this).balance);



        return proposalId;

    }



}





/**

 * @title TwitterHumanityApplicant

 * @dev Convenient interface for applying to the Humanity registry using Twitter as proof of identity.

 */

contract TwitterHumanityApplicant is PayableHumanityApplicant {



    event Apply(uint indexed proposalId, address indexed applicant, string username);



    constructor(

        IGovernance _governance,

        IRegistry _registry,

        IERC20 _humanity,

        IUniswapExchange _exchange

    ) public

        PayableHumanityApplicant(_governance, _registry, _humanity, _exchange) {}



    function applyWithTwitter(string memory username) public returns (uint) {

        return applyWithTwitterFor(msg.sender, username);

    }



    function applyWithTwitterFor(address who, string memory username) public returns (uint) {

        uint proposalId = applyFor(who);

        emit Apply(proposalId, who, username);

        return proposalId;

    }



    function applyWithTwitterUsingEther(string memory username) public payable returns (uint) {

        return applyWithTwitterUsingEtherFor(msg.sender, username);

    }



    function applyWithTwitterUsingEtherFor(address who, string memory username) public payable returns (uint) {

        uint proposalId = applyWithEtherFor(who);

        emit Apply(proposalId, who, username);

        return proposalId;

    }



}