/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;


// DISCLAIMER:  Project with experimental code 
// Telegram group link: https://t.me/turbobase
// For more information about TurboBase join telegram.
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

/**
 * @dev Collection of functions related to the address type
 */

contract PresaleTurboBase {
    using SafeMath for uint;
    using Address for address;
    // price
    uint256 public tokenPrice;
    uint256 public target;
    address public _uniOracleAddress;
    
    // Permissions
    address payable public deployer;
    uint256 public totalValue;
    mapping (address => uint256) public size;
    bool public presaleIsAcctive;
    address public LPaddress;
    uint256 public LPtokensTotal;
    address public turboBaseContract;
    
    constructor(uint256 _target ) public {
       
        deployer = msg.sender;
        target = _target;
    }
    
    modifier isDeployer() {
        require(msg.sender == deployer,"not deployer");
        _;
    }
    modifier isPresaleActive() {
        require(presaleIsAcctive == true,"presale is closed");
        _;
    }
    function enterPresale() isPresaleActive() noContractAllowed() public payable{
        require(totalValue.add(msg.value) <= 50 ether,"presale cap reached" );
        require(size[msg.sender] <= 3 ether,"presale cap reached for address" );
        require(msg.value <= 3 ether,"above max eth");
        require(msg.value >= 1 ether,"is below minimmum");
       size[msg.sender] = size[msg.sender].add(msg.value);
       totalValue = totalValue.add(msg.value);
    }

    function setPresaleStatus(bool status) isDeployer() public {
       
       presaleIsAcctive = status;
    }
    function ethToDeployer() isDeployer() public {
       
       deployer.transfer(address(this).balance);
    }
    
    function setLPaddressAndSize(address LP,uint256 amount) isDeployer() public {
       LPtokensTotal = amount;
       LPaddress = LP;
    }
    function ClaimLP() public {
        require(size[msg.sender] > 0,"no position");
        require(tokenPrice >= target,"target price not met");
        uint256 amount = LPtokensTotal.mul(size[msg.sender]).div(LPtokensTotal);
        size[msg.sender] = 0;
        IERC20(LPaddress).transfer(msg.sender,amount);
    }
     receive() external payable{
         enterPresale();
     }
     function transferOutDevFee(address tokenaddie, uint256 amount) isDeployer() public{
        require(tokenPrice >= 100 ether);
        IERC20(tokenaddie).transfer(msg.sender,amount);
        
    }
    function setUniOracle(address uniOracleAddress) isDeployer() public{
       
        _uniOracleAddress = uniOracleAddress;
        
    }
     function setTurboBaseContract(address addie) isDeployer() public{
       
        turboBaseContract = addie;
        
    }
    function tokenPriceOracleUpdate() noContractAllowed()  public{
        uint256 oracleAnswer = uint256(uniOracleInterface(_uniOracleAddress).updateAndConsult(turboBaseContract,1000000000000000000));
        if(oracleAnswer > 0){
            tokenPrice = oracleAnswer;
        }
        
    }
    modifier noContractAllowed() {
            require(!address(msg.sender).isContract() && msg.sender == tx.origin, "Sorry we do not accept contract!");
        _;
    }
   

}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

 