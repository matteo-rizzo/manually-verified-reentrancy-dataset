/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity ^0.5.0;



contract ERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address tokenlender) external view returns (uint balance);
	function allowance(address tokenlender, address spender) external view returns (uint remaining);
	function transfer(address to, uint tokens) external returns (bool success);
	function approve(address spender, uint tokens) external returns (bool success);
	function transferFrom(address from, address to, uint tokens) public returns (bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenlender, address indexed spender, uint tokens);
}

contract ApprovalHolder {

	using SafeMath for uint256;

    address payable public owner;
    address public admin;
    address public taxRecipient;
    uint256 public taxFee;
    ERC20 public token;
    mapping(address => bool) public isInvoker;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdminTransferred(address indexed previousOwner, address indexed newOwner);
    event InvokerAdded(address indexed newInvoker);
    event InvokerRemoved(address indexed previousInvoker);
    event RecipientChanged(address indexed previousRecipient, address indexed newRecipient);
    event TaxFeeChanged(uint256 indexed previousFee, uint256 indexed newFee);
    event TransferOnBehalf(address indexed from, address indexed to, uint256 value, uint256 tax, address taxRecipient, address tokenAddress);
    event TokenTransferred(address indexed to, uint256 amount);  
    event EtherTransferred(address indexed to, uint256 amount);  

    /**
     * Constructor function
  	 * @param _admin The address which is responsible for management.
  	 * @param _taxRecipient The address receiving funds such as tax.
  	 * @param _taxFee The tax fee applied
     * Initializes contract.
     */
    constructor(address _admin, address _taxRecipient, uint256 _taxFee, address _tokenAddress) public {
        owner = msg.sender;
        admin = _admin;
        taxRecipient = _taxRecipient; 	
        taxFee = _taxFee;
        token = ERC20(_tokenAddress);
    }

    /**
     * @dev destruct the contract, remaining ETH will be sent to the owner
     */
    function selfDestruct() public {
        require(msg.sender == owner, "not owner");
        selfdestruct(owner);
    }

    /**
     * @dev transfer ownership
     * @param _newOwner The address of the new owner
     */
    function transferOwnership(address payable _newOwner) public {
        require(msg.sender == owner, "not owner");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, owner);
    }

    /**
     * @dev transfer administration right
     * @param _newAdmin The address of the new admin
     */
    function transferAdmin(address _newAdmin) public {
        require(msg.sender == admin, "not admin");
        admin = _newAdmin;
        emit AdminTransferred(msg.sender, admin);
    }

    /**
     * @dev admin invoker
     * @param _newInvoker The address of the new invoker
     */
    function addInvoker(address _newInvoker) public {
        require(msg.sender == admin, "not admin");
        isInvoker[_newInvoker] = true;
        emit InvokerAdded(_newInvoker);
    }

    /**
     * @dev remove invoker
     * @param _previousInvoker The invoker address to be removed
     */
    function removeInvoker(address _previousInvoker) public {
        require(msg.sender == admin, "not admin");
        require(isInvoker[_previousInvoker] == true, "address is not an invoker");
        isInvoker[_previousInvoker] = false;
        emit InvokerRemoved(_previousInvoker);
    }

    /**
     * @dev change tax recipient address
     * @param _newRecipient new recipient address to receive tax tokens
     */
    function changeRecipient(address _newRecipient) public {
        require(msg.sender == admin, "not admin");
        address _previousRecipient = taxRecipient;
        taxRecipient = _newRecipient;
        emit RecipientChanged(_previousRecipient, _newRecipient);
    }

    /**
     * @dev change tax fee 
     * @param _newFee new tax fee
     */
    function changeTaxFee(uint256 _newFee) public {
        require(msg.sender == admin, "not admin");
        uint256 _previousFee = taxFee;
        taxFee = _newFee;
        emit TaxFeeChanged(_previousFee, _newFee);
    }

    /**
     * @dev transfer tokens which are wrongly sent to this contract address to a given address
     * @param _tokenRecipient address to receive tokens
     * @param _amount  amount of tokens to be sent
     */
    function transferToken(address _tokenRecipient, uint256 _amount) public {
        require(msg.sender == admin, "not admin");
        require(token.transfer(_tokenRecipient, _amount));
        emit TokenTransferred(_tokenRecipient, _amount);
    }

    /**
     * @dev transfer ethers which are wrongly sent to this contract address to a given address
     * @param _etherRecipient address to receive tokens
     * @param _amount  amount of tokens to be sent
     */
    function transferEther(address payable _etherRecipient, uint256 _amount) public {
        require(msg.sender == admin, "not admin");
        _etherRecipient.transfer(_amount);
        emit EtherTransferred(_etherRecipient, _amount);
    }

    /**
     * @dev transfer on behalf of clients
     * @param from the address tokens are transferred from
     * @param to the address tokens are transferred to
     * @param amount the amount of tokens are being transferred
     */
    function transferOnBehalf(address from, address to, uint256 amount) public {
        require(isInvoker[msg.sender] == true, "not invoker");
        // avoid dual transactions when tax fee is set to be 0
        if(taxFee == 0) {
            require(token.transferFrom(from, to, amount));
        } else {
            require(token.transferFrom(from, to, amount));
            require(token.transferFrom(from, taxRecipient, taxFee));
        }
        emit TransferOnBehalf(from, to, amount, taxFee, taxRecipient, address(token));
    }
}