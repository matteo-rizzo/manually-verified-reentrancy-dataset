pragma solidity ^0.4.23;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */









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

   */

  function transferOwnership(address newOwner) public onlyOwner{

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() onlyPendingOwner public {

    OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}



contract ComissionList is Claimable {

  using SafeMath for uint256;



  struct Transfer {

    uint256 stat;

    uint256 perc;

  }



  mapping (string => Transfer) refillPaySystemInfo;

  mapping (string => Transfer) widthrawPaySystemInfo;



  Transfer transferInfo;



  event RefillCommisionIsChanged(string _paySystem, uint256 stat, uint256 perc);

  event WidthrawCommisionIsChanged(string _paySystem, uint256 stat, uint256 perc);

  event TransferCommisionIsChanged(uint256 stat, uint256 perc);



  // §å§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Ú§ß§æ§à§â§Þ§Ñ§è§Ú§ð §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §á§à§á§à§Ý§ß§ñ§Ö§Þ§à§Û §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í

  function setRefillFor(string _paySystem, uint256 _stat, uint256 _perc) public onlyOwner returns (uint256) {

    refillPaySystemInfo[_paySystem].stat = _stat;

    refillPaySystemInfo[_paySystem].perc = _perc;



    RefillCommisionIsChanged(_paySystem, _stat, _perc);

  }



  // §å§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Ú§ß§æ§à§â§Þ§Ñ§è§Ú§ð §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §ã§ß§Ú§Þ§Ñ§Ö§à§Þ§Û §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í

  function setWidthrawFor(string _paySystem,uint256 _stat, uint256 _perc) public onlyOwner returns (uint256) {

    widthrawPaySystemInfo[_paySystem].stat = _stat;

    widthrawPaySystemInfo[_paySystem].perc = _perc;



    WidthrawCommisionIsChanged(_paySystem, _stat, _perc);

  }



  // §å§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Ú§ß§æ§à§â§Þ§Ñ§è§Ú§ð §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ

  function setTransfer(uint256 _stat, uint256 _perc) public onlyOwner returns (uint256) {

    transferInfo.stat = _stat;

    transferInfo.perc = _perc;



    TransferCommisionIsChanged(_stat, _perc);

  }



  // §Ó§Ù§ñ§ä§î §á§â§à§è§Ö§ß§ä §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §á§à§á§à§Ý§ß§ñ§Ö§Þ§à§Û §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í

  function getRefillStatFor(string _paySystem) public view returns (uint256) {

    return refillPaySystemInfo[_paySystem].perc;

  }



  // §Ó§Ù§ñ§ä§î §æ§Ú§Ü§ã §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §á§à§á§à§Ý§ß§ñ§Ö§Þ§à§Û §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í

  function getRefillPercFor(string _paySystem) public view returns (uint256) {

    return refillPaySystemInfo[_paySystem].stat;

  }



  // §Ó§Ù§ñ§ä§î §á§â§à§è§Ö§ß§ä §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §ã§ß§Ú§Þ§Ñ§Ö§Þ§à§Û §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í

  function getWidthrawStatFor(string _paySystem) public view returns (uint256) {

    return widthrawPaySystemInfo[_paySystem].perc;

  }



  // §Ó§Ù§ñ§ä§î §æ§Ú§Ü§ã §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §ã§ß§Ú§Þ§Ñ§Ö§Þ§à§Û §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í

  function getWidthrawPercFor(string _paySystem) public view returns (uint256) {

    return widthrawPaySystemInfo[_paySystem].stat;

  }



  // §Ó§Ù§ñ§ä§î §á§â§à§è§Ö§ß§ä §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ

  function getTransferPerc() public view returns (uint256) {

    return transferInfo.perc;

  }

  

  // §Ó§Ù§ñ§ä§î §æ§Ú§Ü§ã §á§à §Ü§à§Þ§Ú§ã§ã§Ú§Ú §Õ§Ý§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ

  function getTransferStat() public view returns (uint256) {

    return transferInfo.stat;

  }



  // §â§Ñ§ã§ã§é§Ú§ä§Ñ§ä§î §Ü§à§Þ§Ú§ã§ã§Ú§ð §ã§à §ã§ß§ñ§ä§Ú§ñ §Õ§Ý§ñ §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í §Ú §ã§å§Þ§Þ§í

  function calcWidthraw(string _paySystem, uint256 _value) public view returns(uint256) {

    uint256 _totalComission;

    _totalComission = widthrawPaySystemInfo[_paySystem].stat + (_value / 100 ) * widthrawPaySystemInfo[_paySystem].perc;



    return _totalComission;

  }



  // §â§Ñ§ã§ã§é§Ú§ä§Ñ§ä§î §Ü§à§Þ§Ú§ã§ã§Ú§ð §ã §á§à§á§à§Ý§ß§Ö§ß§Ú§ñ §Õ§Ý§ñ §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í §Ú §ã§å§Þ§Þ§í

  function calcRefill(string _paySystem, uint256 _value) public view returns(uint256) {

    uint256 _totalComission;

    _totalComission = refillPaySystemInfo[_paySystem].stat + (_value / 100 ) * refillPaySystemInfo[_paySystem].perc;



    return _totalComission;

  }



  // §â§Ñ§ã§ã§é§Ú§ä§Ñ§ä§î §Ü§à§Þ§Ú§ã§ã§Ú§ð §ã §á§Ö§â§Ö§Ó§à§Õ§Ñ §Õ§Ý§ñ §á§Ý§Ñ§ä§×§Ø§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í §Ú §ã§å§Þ§Þ§í

  function calcTransfer(uint256 _value) public view returns(uint256) {

    uint256 _totalComission;

    _totalComission = transferInfo.stat + (_value / 100 ) * transferInfo.perc;



    return _totalComission;

  }

}