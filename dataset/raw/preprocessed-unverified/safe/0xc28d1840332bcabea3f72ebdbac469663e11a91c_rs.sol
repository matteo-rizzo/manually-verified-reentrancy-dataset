/**

 *Submitted for verification at Etherscan.io on 2019-01-02

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: contracts/Collateral.sol



contract Collateral is Ownable {



    using SafeMath for SafeMath;

    using SafeERC20 for ERC20;



    address public BondAddress;

    address public DepositAddress; 

    address public VoceanAddress;  



    uint public DeductionRate;  

    uint public Total = 100;



    uint public AllowWithdrawAmount;



    ERC20 public BixToken;



    event SetBondAddress(address bond_address);

    event RefundAllCollateral(uint amount);

    event RefundPartCollateral(address addr, uint amount);

    event PayByBondContract(address addr, uint amount);

    event SetAllowWithdrawAmount(uint amount);

    event WithdrawBix(uint amount);



    constructor(address _DepositAddress, ERC20 _BixToken, address _VoceanAddress, uint _DeductionRate) public{

        require(_DeductionRate < 100);

        DepositAddress = _DepositAddress;

        BixToken = _BixToken;

        VoceanAddress = _VoceanAddress;

        DeductionRate = _DeductionRate;



    }



 

    function setBondAddress(address _BondAddress) onlyOwner public {

        BondAddress = _BondAddress;

        emit SetBondAddress(BondAddress);

    }







    function refundAllCollateral() public {

        require(msg.sender == BondAddress);

        uint current_bix = BixToken.balanceOf(address(this));



        if (current_bix > 0) {

            BixToken.transfer(DepositAddress, current_bix);



            emit RefundAllCollateral(current_bix);

        }





    }





    function refundPartCollateral() public {



        require(msg.sender == BondAddress);



        uint current_bix = BixToken.balanceOf(address(this));



        if (current_bix > 0) {

     

            uint refund_deposit_addr_amount = get_refund_deposit_addr_amount(current_bix);

            uint refund_vocean_addr_amount = get_refund_vocean_addr_amount(current_bix);



            BixToken.transfer(DepositAddress, refund_deposit_addr_amount);

            emit RefundPartCollateral(DepositAddress, refund_deposit_addr_amount);



            

            BixToken.transfer(VoceanAddress, refund_vocean_addr_amount);

            emit RefundPartCollateral(VoceanAddress, refund_vocean_addr_amount);

        }





    }



    function get_refund_deposit_addr_amount(uint current_bix) internal view returns (uint){

        return SafeMath.div(SafeMath.mul(current_bix, SafeMath.sub(Total, DeductionRate)), Total);

    }



    function get_refund_vocean_addr_amount(uint current_bix) internal view returns (uint){

        return SafeMath.div(SafeMath.mul(current_bix, DeductionRate), Total);

    }



  

    function pay_by_bond_contract(address addr, uint amount) public {

        require(msg.sender == BondAddress);

        BixToken.transfer(addr, amount);

        emit PayByBondContract(addr, amount);



    }





    function set_allow_withdraw_amount(uint amount) public {

        require(msg.sender == BondAddress);

        AllowWithdrawAmount = amount;

        emit SetAllowWithdrawAmount(amount);

    }



   

    function withdraw_bix() public {

        require(msg.sender == DepositAddress);

        require(AllowWithdrawAmount > 0);

        BixToken.transfer(msg.sender, AllowWithdrawAmount);



        AllowWithdrawAmount = 0;

        emit WithdrawBix(AllowWithdrawAmount);

    }



}