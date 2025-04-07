/**

 *Submitted for verification at Etherscan.io on 2019-01-14

*/



pragma solidity ^0.5.0;







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr 

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */





/**

 * @title Platform Contract

 * @dev http://www.puzzlebid.com/

 * @author PuzzleBID Game Team 

 * @dev Simon<[emailÂ protected]>

 */

contract Platform {



    using SafeMath for *;

    uint256 allTurnover; 

    mapping(bytes32 => uint256) turnover; 

    

    address payable private foundAddress; 

    TeamInterface private team; 



    constructor(address payable _foundAddress, address _teamAddress) public {

        require(

            _foundAddress != address(0) &&

            _teamAddress != address(0)

        );

        foundAddress = _foundAddress;

        team = TeamInterface(_teamAddress);

    }



    function() external payable {

        revert();

    }



    event OnUpgrade(address indexed _teamAddress);

    event OnDeposit(bytes32 _worksID, address indexed _address, uint256 _amount); 

    event OnUpdateTurnover(bytes32 _worksID, uint256 _amount);

    event OnUpdateAllTurnover(uint256 _amount);

    event OnUpdateFoundAddress(address indexed _sender, address indexed _address);

    event OnTransferTo(address indexed _receiver, uint256 _amount);



    modifier onlyAdmin() {

        require(team.isAdmin(msg.sender));

        _;

    }

    modifier onlyDev() {

        require(team.isDev(msg.sender));

        _;

    }



    function upgrade(address _teamAddress) external onlyAdmin() {

        require(_teamAddress != address(0));

        team = TeamInterface(_teamAddress);

        emit OnUpgrade(_teamAddress);

    }







    function getAllTurnover() external view returns (uint256) {

        return allTurnover;

    }



    function getTurnover(bytes32 _worksID) external view returns (uint256) {

        return turnover[_worksID];

    }



    function updateAllTurnover(uint256 _amount) external onlyDev() {

        allTurnover = allTurnover.add(_amount); 

        emit OnUpdateAllTurnover(_amount);

    }   



    function updateTurnover(bytes32 _worksID, uint256 _amount) external onlyDev() {

        turnover[_worksID] = turnover[_worksID].add(_amount); 

        emit OnUpdateTurnover(_worksID, _amount);

    }



    function updateFoundAddress(address payable _foundAddress) external onlyAdmin() {

        foundAddress = _foundAddress;

        emit OnUpdateFoundAddress(msg.sender, _foundAddress);

    }



    function deposit(bytes32 _worksID) external payable {

        require(_worksID != bytes32(0)); 

        emit OnDeposit(_worksID, msg.sender, msg.value);

    }



    function transferTo(address payable _receiver, uint256 _amount) external onlyDev() {

        require(_amount <= address(this).balance);

        _receiver.transfer(_amount);

        emit OnTransferTo(_receiver, _amount);

    }



    function getFoundAddress() external view returns (address payable) {

        return foundAddress;

    }



    function balances() external view onlyDev() returns (uint256) {

        return address(this).balance;

    }



}