/**

 *Submitted for verification at Etherscan.io on 2018-08-24

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract IcoStorage is Ownable {



    struct Project {

        bool isValue; // We now can know this is an initialized struct

        string name; // ICO company name

        address tokenAddress; // Token's smart contract address

        bool active;    // if true, this contract can be shown

    }



    mapping(address => Project) public projects;

    address[] public projectsAccts;



    function createProject(

        string _name,

        address _icoContractAddress,

        address _tokenAddress

    ) public onlyOwner returns (bool) {

        Project storage project  = projects[_icoContractAddress]; // Create new project



        project.isValue = true; // project is initilaized and not empty

        project.name = _name;

        project.tokenAddress = _tokenAddress;

        project.active = true;



        projectsAccts.push(_icoContractAddress);



        return true;

    }



    function getProject(address _icoContractAddress) public view returns (string, address, bool) {

        require(projects[_icoContractAddress].isValue);



        return (

            projects[_icoContractAddress].name,

            projects[_icoContractAddress].tokenAddress,

            projects[_icoContractAddress].active

        );

    }



    function activateProject(address _icoContractAddress) public onlyOwner returns (bool) {

        Project storage project  = projects[_icoContractAddress];

        require(project.isValue); // Check project exists



        project.active = true;



        return true;

    }



    function deactivateProject(address _icoContractAddress) public onlyOwner returns (bool) {

        Project storage project  = projects[_icoContractAddress];

        require(project.isValue); // Check project exists



        project.active = false;



        return false;

    }



    function getProjects() public view returns (address[]) {

        return projectsAccts;

    }



    function countProjects() public view returns (uint256) {

        return projectsAccts.length;

    }

}