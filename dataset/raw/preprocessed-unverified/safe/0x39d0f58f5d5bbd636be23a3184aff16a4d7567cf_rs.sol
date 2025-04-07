/**
 *Submitted for verification at Etherscan.io on 2020-07-28
*/

pragma solidity 0.5.10;

/**
 * @title Node assignment contract
 */
contract NEST_NodeAssignment {
    
    using SafeMath for uint256;
    IBMapping mappingContract;                              //  Mapping contract
    IBNEST nestContract;                                    //  NEST contract
    SuperMan supermanContract;                              //  NestNode contract
    NEST_NodeSave nodeSave;                                 //  NestNode save contract
    NEST_NodeAssignmentData nodeAssignmentData;             //  NestNode data assignment contract

    /**
    * @dev Initialization method
    * @param map Voting contract address
    */
    constructor (address map) public {
        mappingContract = IBMapping(map); 
        nestContract = IBNEST(address(mappingContract.checkAddress("nest")));
        supermanContract = SuperMan(address(mappingContract.checkAddress("nestNode")));
        nodeSave = NEST_NodeSave(address(mappingContract.checkAddress("nestNodeSave")));
        nodeAssignmentData = NEST_NodeAssignmentData(address(mappingContract.checkAddress("nodeAssignmentData")));
    }
    
    /**
    * @dev Reset voting contract
    * @param map Voting contract address
    */
    function changeMapping(address map) public onlyOwner{
        mappingContract = IBMapping(map); 
        nestContract = IBNEST(address(mappingContract.checkAddress("nest")));
        supermanContract = SuperMan(address(mappingContract.checkAddress("nestNode")));
        nodeSave = NEST_NodeSave(address(mappingContract.checkAddress("nestNodeSave")));
        nodeAssignmentData = NEST_NodeAssignmentData(address(mappingContract.checkAddress("nodeAssignmentData")));
    }
    
    /**
    * @dev Deposit NEST token
    * @param amount Amount of deposited NEST
    */
    function bookKeeping(uint256 amount) public {
        require(amount > 0);
        require(nestContract.transferFrom(address(msg.sender), address(nodeSave), amount));
        nodeAssignmentData.addNest(amount);
    }
    
    // NestNode receive and settlement
    function nodeGet() public {
        require(address(msg.sender) == address(tx.origin));
        require(supermanContract.balanceOf(address(msg.sender)) > 0);
        uint256 allAmount = nodeAssignmentData.checkNodeAllAmount();
        uint256 amount = allAmount.sub(nodeAssignmentData.checkNodeLatestAmount(address(msg.sender)));
        uint256 getAmount = amount.mul(supermanContract.balanceOf(address(msg.sender))).div(1500);
        require(nestContract.balanceOf(address(nodeSave)) >= getAmount);
        nodeSave.turnOut(getAmount,address(msg.sender));
        nodeAssignmentData.addNodeLatestAmount(address(msg.sender),allAmount);
    }
    
    // NestNode transfer settlement
    function nodeCount(address fromAdd, address toAdd) public {
        require(address(supermanContract) == address(msg.sender));
        require(supermanContract.balanceOf(address(fromAdd)) > 0);
        uint256 allAmount = nodeAssignmentData.checkNodeAllAmount();
        uint256 amountFrom = allAmount.sub(nodeAssignmentData.checkNodeLatestAmount(address(fromAdd)));
        uint256 getAmountFrom = amountFrom.mul(supermanContract.balanceOf(address(fromAdd))).div(1500);
        if (nestContract.balanceOf(address(nodeSave)) >= getAmountFrom) {
            nodeSave.turnOut(getAmountFrom,address(fromAdd));
            nodeAssignmentData.addNodeLatestAmount(address(fromAdd),allAmount);
        }
        uint256 amountTo = allAmount.sub(nodeAssignmentData.checkNodeLatestAmount(address(toAdd)));
        uint256 getAmountTo = amountTo.mul(supermanContract.balanceOf(address(toAdd))).div(1500);
        if (nestContract.balanceOf(address(nodeSave)) >= getAmountTo) {
            nodeSave.turnOut(getAmountTo,address(toAdd));
            nodeAssignmentData.addNodeLatestAmount(address(toAdd),allAmount);
        }
    }
    
    // NestNode receivable amount
    function checkNodeNum() public view returns (uint256) {
         uint256 allAmount = nodeAssignmentData.checkNodeAllAmount();
         uint256 amount = allAmount.sub(nodeAssignmentData.checkNodeLatestAmount(address(msg.sender)));
         uint256 getAmount = amount.mul(supermanContract.balanceOf(address(msg.sender))).div(1500);
         return getAmount; 
    }
    
    // Administrator only
    modifier onlyOwner(){
        require(mappingContract.checkOwners(msg.sender));
        _;
    }
}

// Mapping contract
contract IBMapping {
    // Check address
	function checkAddress(string memory name) public view returns (address contractAddress);
	// Check whether an administrator
	function checkOwners(address man) public view returns (bool);
}

// NEST node save contract
contract NEST_NodeSave {
    function turnOut(uint256 amount, address to) public returns(uint256);
}

// NestNode assignment data contract
contract NEST_NodeAssignmentData {
    function addNest(uint256 amount) public;
    function addNodeLatestAmount(address add ,uint256 amount) public;
    function checkNodeAllAmount() public view returns (uint256);
    function checkNodeLatestAmount(address add) public view returns (uint256);
}

// NestNode contract


// NEST contract
contract IBNEST {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);
    function transfer( address to, uint256 value) external;
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);
    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
