/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

pragma solidity ^0.5.16;

/**
  * @title ArtDeco Finance
  *
  * @notice Valid NFT-Factory Contract
  * 
  */
  
  

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */



/**
 * Utility library of inline functions on addresses
 */


contract proxyvalid is  Ownable 
{
    using SafeMath for uint256;
    using Address for address;
    
    address public _nextproxy =  address(0);
    address[] public _validfactorylist;

    constructor() public {
    }
    
    function setProxy( address _proxy ) external onlyOwner
    {
         require ( _proxy != address(0) );
        _nextproxy = _proxy;
    }
    
    function clearProxy() external onlyOwner
    {
         _nextproxy =  address(0);
    }
    
    function setValidFactory( address[] calldata _factorylist ) external onlyOwner
    {
        if( _nextproxy != address(0) )
        {
            Proxy _next =  Proxy(_nextproxy);
            _next.setValidFactory( _factorylist );
        }
        else
        {
            _validfactorylist = _factorylist;
        }
    }
    
    function addValidFactory( address _newfactory ) external onlyOwner
    {
        require ( _newfactory != address(0) );
        if( _nextproxy != address(0) )
        {
            Proxy _next =  Proxy(_nextproxy);
            _next.addValidFactory( _newfactory );
        }
        else
        {
             _validfactorylist.push( _newfactory );
        }
    }

    function removeFactory( address _oldfactory ) external onlyOwner
    {
        require ( _oldfactory != address(0) );
        if( _nextproxy != address(0) )
        {
            Proxy _next =  Proxy(_nextproxy);
            _next.removeFactory( _oldfactory );
        }
        else
        {
            for (uint i = 0; i < _validfactorylist.length; i++) {
                if( _validfactorylist[i] == _oldfactory )
                {
                      delete _validfactorylist[i];
                }
            }
             
        }
    }
    
    function isValidfactory( address _factory ) public view returns (bool) 
    {
        require ( _factory != address(0) );
        if( _nextproxy != address(0) )
        {
            Proxy _next =  Proxy(_nextproxy);
            return _next.isValidfactory( _factory );
        }
        else
        {
            for (uint i = 0; i < _validfactorylist.length; i++) {
                    if( _factory == _validfactorylist[i] )
                    {
                        return true;
                    }
            }
            return false;
        }
    }
    
}