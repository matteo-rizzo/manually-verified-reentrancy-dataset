/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



pragma solidity ^0.4.23;



/**

 * @title MerkleProof

 * @dev Merkle proof verification based on

 * https://github.com/ameensol/merkle-tree-solidity/blob/master/src/MerkleProof.sol

 */









contract Controlled {



    mapping(address => bool) public controllers;



    /// @notice The address of the controller is the only address that can call

    ///  a function with this modifier

    modifier onlyController { 

        require(controllers[msg.sender]); 

        _; 

    }



    address public controller;



    constructor() internal { 

        controllers[msg.sender] = true; 

        controller = msg.sender;

    }



    function changeControllerAccess(address _controller, bool _access) public onlyController {

        controllers[_controller] = _access;

    }



}







// Abstract contract for the full ERC 20 Token standard

// https://github.com/ethereum/EIPs/issues/20







contract SNTGiveaway is Controlled {

    

    mapping(address => bool) public sentToAddress;

    mapping(bytes5 => bool) public codeUsed;

    

    ERC20Token public SNT;

    

    uint public ethAmount;

    uint public sntAmount;

    bytes32 public root;

    

    event AddressFunded(address dest, bytes5 code, uint ethAmount, uint sntAmount);

    

    /// @notice Constructor

    /// @param _sntAddress address SNT contract address

    /// @param _ethAmount uint Amount of ETH in wei to send

    /// @param _sntAmount uint Amount of SNT in wei to send

    /// @param _root bytes32 Merkle tree root

    constructor(address _sntAddress, uint _ethAmount, uint _sntAmount, bytes32 _root) public {

        SNT = ERC20Token(_sntAddress);

        ethAmount = _ethAmount;

        sntAmount = _sntAmount;

        root = _root;

    }



    /// @notice Determine if a request to send SNT/ETH is valid based on merkle proof, and destination address

    /// @param _proof bytes32[] Merkle proof

    /// @param _code bytes5 Unhashed code

    /// @param _dest address Destination address

    function validRequest(bytes32[] _proof, bytes5 _code, address _dest) public view returns(bool) {

        return !sentToAddress[_dest] && !codeUsed[_code] && MerkleProof.verifyProof(_proof, root, keccak256(abi.encodePacked(_code)));

    }



    /// @notice Process request for SNT/ETH and send it to destination address

    /// @param _proof bytes32[] Merkle proof

    /// @param _code bytes5 Unhashed code

    /// @param _dest address Destination address

    function processRequest(bytes32[] _proof, bytes5 _code, address _dest) public onlyController {

        require(!sentToAddress[_dest] && !codeUsed[_code], "Funds already sent / Code already used");

        require(MerkleProof.verifyProof(_proof, root, keccak256(abi.encodePacked(_code))), "Invalid code");



        sentToAddress[_dest] = true;

        codeUsed[_code] = true;

        

        require(SNT.transfer(_dest, sntAmount), "Transfer did not work");

        _dest.transfer(ethAmount);

        

        emit AddressFunded(_dest, _code, ethAmount, sntAmount);

    }

    

    /// @notice Update configuration settings

    /// @param _ethAmount uint Amount of ETH in wei to send

    /// @param _sntAmount uint Amount of SNT in wei to send

    /// @param _root bytes32 Merkle tree root

    function updateSettings(uint _ethAmount, uint _sntAmount, bytes32 _root) public onlyController {

        ethAmount = _ethAmount;

        sntAmount = _sntAmount;

        root = _root;

        

    }



    function manualSend(address _dest, bytes5 _code) public onlyController {

        require(!sentToAddress[_dest] && !codeUsed[_code], "Funds already sent / Code already used");



        sentToAddress[_dest] = true;

        codeUsed[_code] = true;



        require(SNT.transfer(_dest, sntAmount), "Transfer did not work");

        _dest.transfer(ethAmount);

        

        emit AddressFunded(_dest, _code, ethAmount, sntAmount);

    }

    

    /// @notice Extract balance in ETH + SNT from the contract and destroy the contract

    function boom() public onlyController {

        uint sntBalance = SNT.balanceOf(address(this));

        require(SNT.transfer(msg.sender, sntBalance), "Transfer did not work");

        selfdestruct(msg.sender);

    }





    function() public payable {

          

    }



    

}