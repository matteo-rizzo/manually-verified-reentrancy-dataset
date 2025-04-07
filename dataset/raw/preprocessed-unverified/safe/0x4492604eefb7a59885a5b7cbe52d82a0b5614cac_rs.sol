/**

 *Submitted for verification at Etherscan.io on 2019-01-24

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





// File: openzeppelin-solidity/contracts/lifecycle/Destructible.sol



/**

 * @title Destructible

 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.

 */

contract Destructible is Ownable {

  /**

   * @dev Transfers the current balance to the owner and terminates the contract.

   */

  function destroy() public onlyOwner {

    selfdestruct(owner);

  }



  function destroyAndSend(address _recipient) public onlyOwner {

    selfdestruct(_recipient);

  }

}



// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyOwner whenNotPaused {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    paused = false;

    emit Unpause();

  }

}



// File: openzeppelin-solidity/contracts/ownership/Contactable.sol



/**

 * @title Contactable token

 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their

 * contact information.

 */

contract Contactable is Ownable {



  string public contactInformation;



  /**

    * @dev Allows the owner to set a string with their contact information.

    * @param _info The contact information to attach to the contract.

    */

  function setContactInformation(string _info) public onlyOwner {

    contactInformation = _info;

  }

}



// File: monetha-utility-contracts/contracts/Restricted.sol



/** @title Restricted

 *  Exposes onlyMonetha modifier

 */

contract Restricted is Ownable {



    //MonethaAddress set event

    event MonethaAddressSet(

        address _address,

        bool _isMonethaAddress

    );



    mapping (address => bool) public isMonethaAddress;



    /**

     *  Restrict methods in such way, that they can be invoked only by monethaAddress account.

     */

    modifier onlyMonetha() {

        require(isMonethaAddress[msg.sender]);

        _;

    }



    /**

     *  Allows owner to set new monetha address

     */

    function setMonethaAddress(address _address, bool _isMonethaAddress) onlyOwner public {

        isMonethaAddress[_address] = _isMonethaAddress;



        emit MonethaAddressSet(_address, _isMonethaAddress);

    }

}



// File: monetha-loyalty-contracts/contracts/IMonethaVoucher.sol







// File: contracts/GenericERC20.sol



/**

* @title GenericERC20 interface

*/

contract GenericERC20 {

    function totalSupply() public view returns (uint256);



    function decimals() public view returns(uint256);



    function balanceOf(address _who) public view returns (uint256);



    function allowance(address _owner, address _spender)

        public view returns (uint256);

        

    // Return type not defined intentionally since not all ERC20 tokens return proper result type

    function transfer(address _to, uint256 _value) public;



    function approve(address _spender, uint256 _value)

        public returns (bool);



    function transferFrom(address _from, address _to, uint256 _value)

        public returns (bool);



    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}



// File: contracts/MonethaGateway.sol



/**

 *  @title MonethaGateway

 *

 *  MonethaGateway forward funds from order payment to merchant's wallet and collects Monetha fee.

 */

contract MonethaGateway is Pausable, Contactable, Destructible, Restricted {



    using SafeMath for uint256;



    string constant VERSION = "0.6";



    /**

     *  Fee permille of Monetha fee.

     *  1 permille (бы) = 0.1 percent (%)

     *  15бы = 1.5%

     */

    uint public constant FEE_PERMILLE = 15;





    uint public constant PERMILLE_COEFFICIENT = 1000;



    /**

     *  Address of Monetha Vault for fee collection

     */

    address public monethaVault;



    /**

     *  Account for permissions managing

     */

    address public admin;



    /**

     * Monetha voucher contract

     */

    IMonethaVoucher public monethaVoucher;



    /**

     *  Max. discount permille.

     *  10 permille = 1 %

     */

    uint public MaxDiscountPermille;



    event PaymentProcessedEther(address merchantWallet, uint merchantIncome, uint monethaIncome);

    event PaymentProcessedToken(address tokenAddress, address merchantWallet, uint merchantIncome, uint monethaIncome);

    event MonethaVoucherChanged(

        address indexed previousMonethaVoucher,

        address indexed newMonethaVoucher

    );

    event MaxDiscountPermilleChanged(uint prevPermilleValue, uint newPermilleValue);



    /**

     *  @param _monethaVault Address of Monetha Vault

     */

    constructor(address _monethaVault, address _admin, IMonethaVoucher _monethaVoucher) public {

        require(_monethaVault != 0x0);

        monethaVault = _monethaVault;



        setAdmin(_admin);

        setMonethaVoucher(_monethaVoucher);

        setMaxDiscountPermille(700); // 70%

    }



    /**

     *  acceptPayment accept payment from PaymentAcceptor, forwards it to merchant's wallet

     *      and collects Monetha fee.

     *  @param _merchantWallet address of merchant's wallet for fund transfer

     *  @param _monethaFee is a fee collected by Monetha

     */

    /**

     *  acceptPayment accept payment from PaymentAcceptor, forwards it to merchant's wallet

     *      and collects Monetha fee.

     *  @param _merchantWallet address of merchant's wallet for fund transfer

     *  @param _monethaFee is a fee collected by Monetha

     */

    function acceptPayment(address _merchantWallet,

        uint _monethaFee,

        address _customerAddress,

        uint _vouchersApply,

        uint _paybackPermille)

    external payable onlyMonetha whenNotPaused returns (uint discountWei){

        require(_merchantWallet != 0x0);

        uint price = msg.value;

        // Monetha fee cannot be greater than 1.5% of payment

        require(_monethaFee >= 0 && _monethaFee <= FEE_PERMILLE.mul(price).div(1000));



        discountWei = 0;

        if (monethaVoucher != address(0)) {

            if (_vouchersApply > 0 && MaxDiscountPermille > 0) {

                uint maxDiscountWei = price.mul(MaxDiscountPermille).div(PERMILLE_COEFFICIENT);

                uint maxVouchers = monethaVoucher.fromWei(maxDiscountWei);

                // limit vouchers to apply

                uint vouchersApply = _vouchersApply;

                if (vouchersApply > maxVouchers) {

                    vouchersApply = maxVouchers;

                }



                (, discountWei) = monethaVoucher.applyDiscount(_customerAddress, vouchersApply);

            }



            if (_paybackPermille > 0) {

                uint paybackWei = price.sub(discountWei).mul(_paybackPermille).div(PERMILLE_COEFFICIENT);

                if (paybackWei > 0) {

                    monethaVoucher.applyPayback(_customerAddress, paybackWei);

                }

            }

        }



        uint merchantIncome = price.sub(_monethaFee);



        _merchantWallet.transfer(merchantIncome);

        monethaVault.transfer(_monethaFee);



        emit PaymentProcessedEther(_merchantWallet, merchantIncome, _monethaFee);

    }



    /**

     *  acceptTokenPayment accept token payment from PaymentAcceptor, forwards it to merchant's wallet

     *      and collects Monetha fee.

     *  @param _merchantWallet address of merchant's wallet for fund transfer

     *  @param _monethaFee is a fee collected by Monetha

     *  @param _tokenAddress is the token address

     *  @param _value is the order value

     */

    function acceptTokenPayment(

        address _merchantWallet,

        uint _monethaFee,

        address _tokenAddress,

        uint _value

    )

    external onlyMonetha whenNotPaused

    {

        require(_merchantWallet != 0x0);



        // Monetha fee cannot be greater than 1.5% of payment

        require(_monethaFee >= 0 && _monethaFee <= FEE_PERMILLE.mul(_value).div(1000));



        uint merchantIncome = _value.sub(_monethaFee);



        GenericERC20(_tokenAddress).transfer(_merchantWallet, merchantIncome);

        GenericERC20(_tokenAddress).transfer(monethaVault, _monethaFee);



        emit PaymentProcessedToken(_tokenAddress, _merchantWallet, merchantIncome, _monethaFee);

    }



    /**

     *  changeMonethaVault allows owner to change address of Monetha Vault.

     *  @param newVault New address of Monetha Vault

     */

    function changeMonethaVault(address newVault) external onlyOwner whenNotPaused {

        monethaVault = newVault;

    }



    /**

     *  Allows other monetha account or contract to set new monetha address

     */

    function setMonethaAddress(address _address, bool _isMonethaAddress) public {

        require(msg.sender == admin || msg.sender == owner);



        isMonethaAddress[_address] = _isMonethaAddress;



        emit MonethaAddressSet(_address, _isMonethaAddress);

    }



    /**

     *  setAdmin allows owner to change address of admin.

     *  @param _admin New address of admin

     */

    function setAdmin(address _admin) public onlyOwner {

        require(_admin != address(0));

        admin = _admin;

    }



    /**

     *  setAdmin allows owner to change address of Monetha voucher contract. If set to 0x0 address, discounts and paybacks are disabled.

     *  @param _monethaVoucher New address of Monetha voucher contract

     */

    function setMonethaVoucher(IMonethaVoucher _monethaVoucher) public onlyOwner {

        if (monethaVoucher != _monethaVoucher) {

            emit MonethaVoucherChanged(monethaVoucher, _monethaVoucher);

            monethaVoucher = _monethaVoucher;

        }

    }



    /**

     *  setMaxDiscountPermille allows Monetha to change max.discount percentage

     *  @param _maxDiscountPermille New value of max.discount (in permille)

     */

    function setMaxDiscountPermille(uint _maxDiscountPermille) public onlyOwner {

        require(_maxDiscountPermille <= PERMILLE_COEFFICIENT);

        emit MaxDiscountPermilleChanged(MaxDiscountPermille, _maxDiscountPermille);

        MaxDiscountPermille = _maxDiscountPermille;

    }

}