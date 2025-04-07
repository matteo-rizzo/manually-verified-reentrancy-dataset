/**

 *Submitted for verification at Etherscan.io on 2019-01-05

*/



pragma solidity ^0.4.24;



// File: contracts\utils\SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts\FundCenter.sol



// This contract only keep user's deposit & withdraw records. 

// we use a private chain to maintain users' balance book. 

// All user's spending and earning records are kept in the private chain. 

contract FundCenter {

    using SafeMath for *;



    string constant public name = "FundCenter";

    string constant public symbol = "FundCenter";

    

    event BalanceRecharge(address indexed sender, uint256 amount, uint64 evented_at); // deposit

    event BalanceWithdraw(address indexed sender, uint256 amount, bytes txHash, uint64 evented_at); //withdraw



    uint lowestRecharge = 0.1 ether; // lowest deposit amount 

    uint lowestWithdraw = 0.1 ether; //lowest withdraw amount

    bool enable = true;

    address public CEO;

    address public COO;

    address public gameAddress; 



    mapping(address => uint) public recharges; // deposit records 

    mapping(address => uint) public withdraws; // withdraw records 



    modifier onlyCEO {

        require(CEO == msg.sender, "Only CEO can operate.");

        _;

    }



    modifier onlyCOO {

        require(COO == msg.sender, "Only COO can operate.");

        _;

    }

    

    modifier onlyEnable {

        require(enable == true, "The service is closed.");

        _;

    }



    constructor (address _COO) public {

        CEO = msg.sender;

        COO = _COO;

    }



    function recharge() public payable onlyEnable {

        require(msg.value >= lowestRecharge, "The minimum recharge amount does not meet the requirements.");

        recharges[msg.sender] = recharges[msg.sender].add(msg.value); // only records deposit amount. 

        emit BalanceRecharge(msg.sender, msg.value, uint64(now));

    }

    

    function() public payable onlyEnable {

        require(msg.sender == gameAddress, "only receive eth from game address"); 

    }

    

    function setGameAddress(address _gameAddress) public onlyCOO {

        gameAddress = _gameAddress; 

    }



    function withdrawBalanceFromServer(address _to, uint _amount, bytes _txHash) public onlyCOO onlyEnable {

        require(address(this).balance >= _amount, "Insufficient balance.");

        _to.transfer(_amount);

        withdraws[_to] = withdraws[_to].add(_amount); // record withdraw amount 

        emit BalanceWithdraw(_to, _amount, _txHash, uint64(now));

    }





    function withdrawBalanceFromAdmin(uint _amount) public onlyCOO {

        require(address(this).balance >= _amount, "Insufficient balance.");

        CEO.transfer(_amount);

    }



    function setLowestClaim(uint _lowestRecharge, uint _lowestWithdraw) public onlyCOO {

        lowestRecharge = _lowestRecharge;

        lowestWithdraw = _lowestWithdraw;

    }



    function setEnable(bool _enable) public onlyCOO {

        enable = _enable;

    }



    function transferCEO(address _CEOAddress) public onlyCEO {

        CEO = _CEOAddress;

    }



    function setCOO(address _COOAddress) public onlyCEO {

        COO = _COOAddress;

    }

}