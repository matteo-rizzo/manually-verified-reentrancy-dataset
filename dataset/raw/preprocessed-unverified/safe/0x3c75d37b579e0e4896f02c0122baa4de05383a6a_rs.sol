/**

 *Submitted for verification at Etherscan.io on 2019-01-27

*/



// hevm: flattened sources of contracts/Alchemist.sol

pragma solidity ^0.4.24;



////// contracts/openzeppelin/IERC20.sol

/* pragma solidity ^0.4.24; */



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





////// contracts/Alchemist.sol

/* pragma solidity ^0.4.24; */



/* import "./openzeppelin/IERC20.sol"; */



contract Alchemist {

    address public LEAD;

    address public GOLD;



    constructor(address _lead, address _gold) public {

        LEAD = _lead;

        GOLD = _gold;

    }



    function transmute(uint _mass) external {

        require(

            IERC20(LEAD).transferFrom(msg.sender, address(this), _mass),

            "LEAD transfer failed"

        );

        require(

            IERC20(GOLD).transfer(msg.sender, _mass),

            "GOLD transfer failed"

        );

    }

}