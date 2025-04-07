/**

 *Submitted for verification at Etherscan.io on 2019-05-09

*/



pragma solidity 0.5.7;

pragma experimental ABIEncoderV2;





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */







contract IHumanity {

    function mint(address account, uint256 value) public;

    function totalSupply() public view returns (uint256);

}





/**

 * @title HumanityRegistry

 * @dev A list of Ethereum addresses that belong to unique humans as determined by Humanity governance.

 */

contract HumanityRegistry {



    mapping (address => bool) public humans;



    IHumanity public humanity;

    address public governance;



    constructor(IHumanity _humanity, address _governance) public {

        humanity = _humanity;

        governance = _governance;

    }



    function add(address who) public {

        require(msg.sender == governance, "HumanityRegistry::add: Only governance can add an identity");

        require(humans[who] == false, "HumanityRegistry::add: Address is already on the registry");



        _reward(who);

        humans[who] = true;

    }



    function remove(address who) public {

        require(

            msg.sender == governance || msg.sender == who,

            "HumanityRegistry::remove: Only governance or the identity owner can remove an identity"

        );

        delete humans[who];

    }



    function isHuman(address who) public view returns (bool) {

        return humans[who];

    }



    function _reward(address who) internal {

        uint totalSupply = humanity.totalSupply();



        if (totalSupply < 28000000e18) {

            humanity.mint(who, 30000e18); // 1 - 100

        } else if (totalSupply < 46000000e18) {

            humanity.mint(who, 20000e18); // 101 - 1000

        } else if (totalSupply < 100000000e18) {

            humanity.mint(who, 6000e18); // 1001 - 10000

        }



    }



}





/**

 * @title UniversalBasicIncome

 * @dev Dai that can be claimed by humans on the Human Registry.

 */

contract UniversalBasicIncome {

    using SafeMath for uint;



    HumanityRegistry public registry;

    IERC20 public dai;



    uint public constant MONTHLY_INCOME = 1e18; // 1 Dai

    uint public constant INCOME_PER_SECOND = MONTHLY_INCOME / 30 days;



    mapping (address => uint) public claimTimes;



    constructor(HumanityRegistry _registry, IERC20 _dai) public {

        registry = _registry;

        dai = _dai;

    }



    function claim() public {

        require(registry.isHuman(msg.sender), "UniversalBasicIncome::claim: You must be on the Humanity registry to claim income");



        uint income;

        uint time = block.timestamp;



        // If claiming for the first time, send 1 month of UBI

        if (claimTimes[msg.sender] == 0) {

            income = MONTHLY_INCOME;

        } else {

            income = time.sub(claimTimes[msg.sender]).mul(INCOME_PER_SECOND);

        }



        uint balance = dai.balanceOf(address(this));

        // If not enough Dai reserves, send the remaining balance

        uint actualIncome = balance < income ? balance : income;



        dai.transfer(msg.sender, actualIncome);

        claimTimes[msg.sender] = time;

    }



}