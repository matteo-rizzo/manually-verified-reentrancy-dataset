/**

 *Submitted for verification at Etherscan.io on 2019-04-29

*/



pragma solidity 0.5.6;











contract Manageable is Ownable {

    mapping(address => bool) public listOfManagers;



    modifier onlyManager() {

        require(listOfManagers[msg.sender], "");

        _;

    }



    function addManager(address _manager) public onlyOwner returns (bool success) {

        if (!listOfManagers[_manager]) {

            require(_manager != address(0), "");

            listOfManagers[_manager] = true;

            success = true;

        }

    }



    function removeManager(address _manager) public onlyOwner returns (bool success) {

        if (listOfManagers[_manager]) {

            listOfManagers[_manager] = false;

            success = true;

        }

    }



    function getInfo(address _manager) public view returns (bool) {

        return listOfManagers[_manager];

    }

}









/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







contract ProxyBonusContract is Manageable {

    using SafeMath for uint;



    IERC20 public token;



    address hourlyGame;



    constructor (

        address _token,

        address _hourlyGame

    )

    public

    {

        require(_token != address(0));

        require(_hourlyGame != address(0), "");



        token = IERC20(_token);

        hourlyGame = _hourlyGame;

    }



    function buyTickets(address _participant, uint _luckyBacksAmount) public {

        require(_luckyBacksAmount > 0, "");

        require(token.transferFrom(msg.sender, address(this), _luckyBacksAmount), "");



        uint amount = _luckyBacksAmount.div(10**18);



        iHourlyGame(hourlyGame).buyBonusTickets(

            _participant,

            amount,

            amount,

            amount,

            amount,

            amount,

            amount,

            amount

        );

    }



    function changeToken(address _token) public onlyManager {

        token = IERC20(_token);

    }

}



