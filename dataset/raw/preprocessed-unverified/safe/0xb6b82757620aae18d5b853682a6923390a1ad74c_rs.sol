/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

/*
|| <$> Dai Savings Escrow (DSE) <$> || version 1

DEAR MSG.SENDER(S):

/ DSE is a project in beta.
// Please audit and use at your own risk.
/// Entry into DSE shall not create an attorney/client relationship.
//// Likewise, DSE should not be construed as legal advice or replacement for professional counsel.
///// STEAL THIS C0D3SL4W 

~presented by Open, ESQ || lexDAO LLC
*/

pragma solidity 0.5.14;

/***************
OPENZEPPELIN REFERENCE CONTRACTS - Context, Role, SafeMath, IERC20 
***************/
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


contract LexDAORole is Context {
    using Roles for Roles.Role;

    event LexDAOAdded(address indexed account);
    event LexDAORemoved(address indexed account);

    Roles.Role private _lexDAOs;
    
    constructor () internal {
        _addLexDAO(_msgSender());
    }

    modifier onlyLexDAO() {
        require(isLexDAO(_msgSender()), "LexDAORole: caller does not have the LexDAO role");
        _;
    }
    
    function isLexDAO(address account) public view returns (bool) {
        return _lexDAOs.has(account);
    }

    function addLexDAO(address account) public onlyLexDAO {
        _addLexDAO(account);
    }

    function renounceLexDAO() public {
        _removeLexDAO(_msgSender());
    }

    function _addLexDAO(address account) internal {
        _lexDAOs.add(account);
        emit LexDAOAdded(account);
    }

    function _removeLexDAO(address account) internal {
        _lexDAOs.remove(account);
        emit LexDAORemoved(account);
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 * @title Chai.money interface
 * @dev see https://github.com/dapphub/chai
 */
contract IChai {
    function transfer(address dst, uint wad) external returns (bool);
    // like transferFrom but dai-denominated
    function move(address src, address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
    function approve(address usr, uint wad) external returns (bool);
    function balanceOf(address usr) external returns (uint);

    // Approve by signature
    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

    function dai(address usr) external returns (uint wad);
    function dai(uint chai) external returns (uint wad);

    // wad is denominated in dai
    function join(address dst, uint wad) external;

    // wad is denominated in (1/chi) * dai
    function exit(address src, uint wad) public;

    // wad is denominated in dai
    function draw(address src, uint wad) external returns (uint chai);
}

/***************
DSE CONTRACT
***************/
contract DaiSavingsEscrow is LexDAORole {  
    using SafeMath for uint256;
    
    // $DAI details:
    address private daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IERC20 public dai = IERC20(daiAddress);
    
    // $CHAI details:
    address private chaiAddress = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    IChai public chai = IChai(chaiAddress);
    
    // <$> DSE <$> details:
    address private vault = address(this);
    address public proposedManager;
    address public manager;
    uint8 public version = 1;
    uint256 public dse; // index for registered escrows
    string public emoji = "⚔️";
    mapping (uint256 => Escrow) public escrow; 

    struct Escrow {  
        address client; 
        address provider;
        uint256 payment;
        uint256 wrap;
        uint256 termination;
        uint256 index;
        string details; 
        bool disputed; 
        bool released;
    }
    	
    // DSE Contract Events
    event Registered(address indexed client, address indexed provider, uint256 indexed index);  
    event Released(uint256 indexed index); 
    event Disputed(uint256 indexed index, string indexed details); 
    event Resolved(uint256 indexed index, string indexed details); 
    event ManagerProposed(address indexed proposedManager, string indexed details);
    event ManagerTransferred(address indexed manager, string indexed details);
    
    constructor () public {
        dai.approve(chaiAddress, uint(-1));
        manager = msg.sender;
    } 
    
    /***************
    ESCROW FUNCTIONS
    ***************/
    function register( // register $DAI escrow with DSR via $CHAI; arbitration via lexDAO
        address provider,
        uint256 payment, 
        uint256 termination,
        string memory details) public {
	    uint256 index = dse.add(1); 
	    dse = dse.add(1);
	    
	    dai.transferFrom(msg.sender, vault, payment); // deposit $DAI
        uint256 balance = chai.balanceOf(vault);
        chai.join(vault, payment); // wrap in $CHAI and store in DSRE vault
                
            escrow[index] = Escrow( 
                msg.sender, 
                provider,
                payment, 
                chai.balanceOf(vault).sub(balance),
                termination,
                index,
                details, 
                false, 
                false);
        
        emit Registered(msg.sender, provider, index); 
    }

    function dispute(uint256 index, string memory details) public {
        Escrow storage escr = escrow[index]; 
        require(escr.released == false); // program safety check / status
        require(now <= escr.termination); // program safety check / time
        require(msg.sender == escr.client || msg.sender == escr.provider); // program safety check / authorization

	    escr.disputed = true; 
	    
	    emit Disputed(index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256 providerAward, string memory details) public onlyLexDAO {
        Escrow storage escr = escrow[index];
	    uint256 lexFee = escr.payment.div(20); // calculates 5% lexDAO resolution fee
	    require(escr.disputed == true); // program safety check / status
	    require(clientAward.add(providerAward) == escr.payment.sub(lexFee)); // program safety check / economics
        require(msg.sender != escr.client); // program safety check / authorization / client cannot resolve own dispute 
        require(msg.sender != escr.provider); // program safety check / authorization / provider cannot resolve own dispute
	
	    chai.exit(vault, escr.wrap); // collect $DAI + interest from DSR
        uint256 receivedDai = dai.balanceOf(vault);
        uint256 interest = receivedDai.sub(escr.payment);
	
        dai.transfer(escr.client, clientAward); 
        dai.transfer(escr.provider, providerAward); 
    	dai.transfer(msg.sender, lexFee); 
    	dai.transfer(manager, interest);
    	
	    escr.released = true; 
	    
	    emit Resolved(index, details);
    }
    
    function release(uint256 index) public { 
    	Escrow storage escr = escrow[index];
	    require(escr.disputed == false); // program safety check / status
    	require(now <= escr.termination); // program safety check / time
    	require(msg.sender == escr.client); // program safety check / authorization
    	
    	chai.exit(vault, escr.wrap); // collect $DAI + interest from DSR
        uint256 receivedDai = dai.balanceOf(vault);
        uint256 interest = receivedDai.sub(escr.payment);

    	dai.transfer(escr.provider, escr.payment); 
    	dai.transfer(manager, interest);
        
        escr.released = true; 
        
	    emit Released(index); 
    }
    
    function withdraw(uint256 index) public { // client can withdraw if termination time passes
    	Escrow storage escr = escrow[index];
        require(escr.disputed == false); // program safety check / status
    	require(now >= escr.termination); // program safety check / time
    	require(msg.sender == escr.client); // program safety check / authorization
    	
    	chai.exit(vault, escr.wrap); // collect $DAI + interest from DSR
        uint256 receivedDai = dai.balanceOf(vault);
        uint256 interest = receivedDai.sub(escr.payment);
        
    	dai.transfer(escr.provider, escr.payment); 
    	dai.transfer(manager, interest);
        
        escr.released = true; 
        
	    emit Released(index); 
    }
    
    /***************
    MGMT FUNCTIONS
    ***************/
    function proposeManager(address _proposedManager, string memory details) public {
        require(msg.sender == manager);
        proposedManager = _proposedManager; // proposed DSE beneficiary account
        
        emit ManagerProposed(proposedManager, details);
    }
    
    function transferManager(string memory details) public {
        require(msg.sender == proposedManager);
        manager = msg.sender; // accepting DSE beneficiary account
        
        emit ManagerTransferred(manager, details);
    }
}