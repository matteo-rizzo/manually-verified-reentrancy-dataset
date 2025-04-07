/**
 *Submitted for verification at Etherscan.io on 2019-09-05
*/

pragma solidity ^0.5.0;






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
* @title Tellor Community Sale
* @dev This contract allows for the sale of Tributes to early miners
*/

contract TellorCommunitySale{
    using SafeMath for uint256;

    /*Variables*/
    uint public tribPrice;
    uint public endDate;
    uint public saleAmount;
    address public tellorAddress;
    address payable public owner;
    TokenInterface tellor;

    mapping(address => uint) saleByAddress;

    /*Events*/
    event NewPrice(uint _price);
    event NewAddress(address _newAddress, uint _amount);
    event NewSale(address _buyer,uint _amount);


    /*Constructor*/
    /*
    * @dev This sets the sale period to 7 days, and the TellorMaster address for the interface
    * @param _Tellor is the TellorMaster address
    */
    constructor(address _Tellor) public {
        owner = msg.sender;
        endDate = now + 7 days;
        tellorAddress = _Tellor;
        tellor = TokenInterface(_Tellor);
    }


    /**
    * @dev Allows the contract owner(Tellor) to set the price per Tribute
    * @param _price per Tribute
    */
    function setPrice(uint _price) external {
        require(msg.sender == owner);
        tribPrice = _price;
        emit NewPrice(_price);
    }


    /**
    * @dev Allows the contract owner(Tellor) to add approved addresses for the sale
    * It only allows for each address to be approved once and it checks that this contract contains 
    * enough Tellor Tributes available before authorizing
    * @param _address of approved party
    * @param _amount of tokens authorized for the party to buy
    */
    function enterAddress(address _address, uint _amount) external {
        require(msg.sender == owner);
        require(checkThisAddressTokens()/1e18 >= saleAmount.add(_amount));
        saleAmount += _amount;
        saleByAddress[_address] += _amount;
        emit NewAddress(_address,_amount);
    }


    /**
    * @dev Allows the contract owner(Tellor) to withdraw any Tributes left on this contract
    * after the sale's end date
    */
    function withdrawTokens() external{
        require(msg.sender == owner);
        require(now > endDate);
        tellor.transfer(owner,tellor.balanceOf(address(this)));
    }


    /**
    * @dev Allows the contract owner(Tellor) to withdraw ETH from this contract
    */
    function withdrawETH() external{
        require(msg.sender == owner);
        address(owner).transfer(address(this).balance);
    }
    

    /**
    * @dev Allows the approved addresses to pay ETH and withdraw the authorized number of Tributes
    */
    function () external payable{
        require (saleByAddress[msg.sender] > 0);
        require(msg.value >= tribPrice.mul(saleByAddress[msg.sender]));//are decimals an issue?
        tellor.transfer(msg.sender,saleByAddress[msg.sender]*1e18); 
        emit NewSale(msg.sender,saleByAddress[msg.sender]);
        saleByAddress[msg.sender] = 0;
    }    


    /*Getters*/

    /**
    * @dev Gets the amount of Tributes authorized for the specified address
    * @param _address of approved party
    */
    function getSaleByAddress(address _address) external view returns(uint){
        return saleByAddress[_address];
    }


    /**
    * @dev Checks if this contract has enough Tributes before approving more addresses 
    */
    function checkThisAddressTokens() public view returns(uint){
        return tellor.balanceOf(address(this));
    }


    /**
    * @dev Gives the user the price for their assigned tokens
    */
    function priceForUserTokens(address _address) public view returns(uint){
        return tribPrice.mul(saleByAddress[_address]);
    }
}