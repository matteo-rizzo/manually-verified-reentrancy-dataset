/**

 *Submitted for verification at Etherscan.io on 2018-10-09

*/



pragma solidity ^0.4.24;



/*

    Sale(address ethwallet)   // this will send the received ETH funds to this address

  @author Yumerium Ltd

*/

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract YumeriumManager {

    function getYumerium(uint256 value, address sender) external returns (uint256);

}



contract Sale {

    uint public saleEnd1 = 1535846400 + 1 days; //9/3/2018 @ 12:00am (UTC)

    uint public saleEnd2 = saleEnd1 + 1 days; //9/4/2018 @ 12:00am (UTC)

    uint public saleEnd3 = saleEnd2 + 1 days; //9/5/2018 @ 12:00am (UTC)

    uint public saleEnd4 = 1539129600; //10/10/2018 @ 12:00am (UTC)

    uint256 public minEthValue = 10 ** 15; // 0.001 eth



    uint256 public totalPariticpants = 0;

    uint256 public adjustedValue = 0;

    mapping(address => Renowned) public renownedPlayers; // map for the player information

    mapping(bytes8 => address) public referral; // map for the player information

    

    using SafeMath for uint256;

    uint256 public maxSale;

    uint256 public totalSaled;

    

    YumeriumManager public manager;

    address public owner;



    event Contribution(address from, uint256 amount);



    constructor(address _manager_address) public {

        maxSale = 316906850 * 10 ** 8; 

        manager = YumeriumManager(_manager_address);

        owner = msg.sender;

    }



    function () external payable {

        buy("");

    }



    // CONTRIBUTE FUNCTION

    // converts ETH to TOKEN and sends new TOKEN to the sender

    function contribute(bytes8 referralCode) external payable {

        buy(referralCode);

    }

    

    function becomeRenown() public payable {

        generateRenown();

        owner.transfer(msg.value);

    }



    function generateRenown() private {

        require(!renownedPlayers[msg.sender].isRenowned, "You already registered as renowned!");

        bytes8 referralCode = bytes8(keccak256(abi.encodePacked(totalPariticpants + adjustedValue)));

        // check hash collision and regenerate hash value again

        while (renownedPlayers[referral[referralCode]].isRenowned)

        {

            adjustedValue = adjustedValue.add(1);

            referralCode = bytes8(keccak256(abi.encodePacked(totalPariticpants + adjustedValue)));

        }

        renownedPlayers[msg.sender].addr = msg.sender;

        renownedPlayers[msg.sender].referralCode = referralCode;

        renownedPlayers[msg.sender].isRenowned = true;

        referral[renownedPlayers[msg.sender].referralCode] = msg.sender;

        totalPariticpants = totalPariticpants.add(1);

    }

    

    function buy(bytes8 referralCode) internal {

        require(msg.value>=minEthValue);

        require(now < saleEnd4); // main sale postponed



        // distribution for referral

        uint256 remainEth = msg.value;

        if (referral[referralCode] != msg.sender && renownedPlayers[referral[referralCode]].isRenowned)

        {

            uint256 referEth = msg.value.mul(10).div(100);

            referral[referralCode].transfer(referEth);

            remainEth = remainEth.sub(referEth);

        }



        if (!renownedPlayers[msg.sender].isRenowned)

        {

            generateRenown();

        }

        

        uint256 amount = manager.getYumerium(msg.value, msg.sender);

        uint256 total = totalSaled.add(amount);

        owner.transfer(remainEth);

        

        require(total<=maxSale);

        

        totalSaled = total;

        

        emit Contribution(msg.sender, amount);

    }



    // change yumo address

    function changeManagerAddress(address _manager_address) external {

        require(msg.sender==owner, "You are not an owner!");

        manager = YumeriumManager(_manager_address);

    }

    // change yumo address

    function changeTeamWallet(address _team_address) external {

        require(msg.sender==owner, "You are not an owner!");

        owner = YumeriumManager(_team_address);

    }



    struct Renowned {

        bool isRenowned;

        address addr;

        bytes8 referralCode;

    }

}