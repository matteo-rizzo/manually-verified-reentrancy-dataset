/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

pragma solidity ^0.5.16;

/**
  * @title ArtDeco Finance
  *
  * @notice Contract: a ARTD FundPool to storein NFT 
  * 
  */







contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


/**
 * Utility library of inline functions on addresses
 */



contract ARTDfundpool is Governance{
    using SafeMath for uint256;
    using Address for address;

    address public ARTDaddress =  address(0xA23F8462d90dbc60a06B9226206bFACdEAD2A26F);
    address public valider = address(0x58F62d9B184BE5D7eE6881854DD16898Afe0cf90);
    address private _factory = address(0);
    
    event Approve(address newfactory, uint256 amount);
    event Newfactory(address newfactory);
      
    constructor() public {}

    function newfactory(address factory) public onlyGovernance
    {
        Validfactory _valid = Validfactory(valider);
        require( _valid.isValidfactory(factory), "Invalid factory");
        
        _factory = factory;
        
        emit Newfactory(factory);
    }

    function approve(address factory, uint256 amount) public 
    {
        Validfactory _valid = Validfactory(valider);
        require( _valid.isValidfactory(factory), "Invalid factory");

        Artd _artd =  Artd( ARTDaddress );
        _artd.approve( factory, amount );
        
        emit Approve(factory, amount);
    }
    
    function factory() external view returns (address) 
    {
        return _factory;   
    } 
    
    /**
    * @dev Gets the stored amount of the specified NFT ID.
    */
    function storeOf(uint256 nftId) external view returns (uint256) 
    {
        Nftfactory factory_x =  Nftfactory( _factory );
        return factory_x.currentStore(nftId);
    }

    /**
    * @dev return the total balances of this address
    */
    function totalBalance() external view returns (uint256) 
    {
        Artd _artd =  Artd( ARTDaddress );
        return _artd.balanceOf(address(this));
    }
    
}