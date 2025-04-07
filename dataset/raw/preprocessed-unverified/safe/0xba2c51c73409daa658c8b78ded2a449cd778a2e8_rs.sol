pragma solidity ^0.4.21;











contract Claimable is Ownable {

  address public pendingOwner;



  /**

   * @dev Modifier throws if called by any account other than the pendingOwner.

   */

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);

    _;

  }



  /**

   * @dev Allows the current owner to set the pendingOwner address.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner public {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() onlyPendingOwner public {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}



contract FlyDropToken is Claimable {

    using SafeMath for uint256;



    ERC20 public erc20tk = ERC20(0xFb5a551374B656C6e39787B1D3A03fEAb7f3a98E);

    bytes[] internal approveRecords;



    event ReceiveApproval(address _from, uint256 _value, address _token, bytes _extraData);



    /**

     * @dev receive approval from an ERC20 token contract, take a record

     *

     * @param _from address The address which you want to send tokens from

     * @param _value uint256 the amounts of tokens to be sent

     * @param _token address the ERC20 token address

     * @param _extraData bytes the extra data for the record

     */

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {

        // erc20tk = ERC20(_token);

        require(erc20tk.transferFrom(_from, this, _value)); // transfer tokens to this contract

        approveRecords.push(_extraData);

        emit ReceiveApproval(_from, _value, _token, _extraData);

    }



    /**

     * @dev Send tokens to other multi addresses in one function

     *

     * @param _destAddrs address The addresses which you want to send tokens to

     * @param _values uint256 the amounts of tokens to be sent

     */

    function multiSend(address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {

        require(_destAddrs.length == _values.length);



        uint256 i = 0;

        for (; i < _destAddrs.length; i = i.add(1)) {

            if (!erc20tk.transfer(_destAddrs[i], _values[i])) {

                break;

            }

        }



        return (i);

    }



    function changERC20(address _token) onlyOwner public {

        erc20tk = ERC20(_token);

    }



    /**

     * @dev Send tokens to other multi addresses in one function

     *

     * @param _from address The address which you want to send tokens from

     * @param _destAddrs address The addresses which you want to send tokens to

     * @param _values uint256 the amounts of tokens to be sent

     */

    function multiSendFrom(address _from, address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {

        require(_destAddrs.length == _values.length);



        uint256 i = 0;

        for (; i < _destAddrs.length; i = i.add(1)) {

            if (!erc20tk.transferFrom(_from, _destAddrs[i], _values[i])) {

                break;

            }

        }



        return (i);

    }



    /**

     * @dev get records about approval

     *

     * @param _ind uint the index of record

     */

    function getApproveRecord(uint _ind) onlyOwner public view returns (bytes) {

        require(_ind < approveRecords.length);



        return approveRecords[_ind];

    }

}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}