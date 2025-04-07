pragma solidity ^0.6.0;





contract Stores {

  /**
   * @dev Return ethereum address
   */
  function getEthAddr() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
  }

  /**
   * @dev Return InstaEvent Address.
   */
  function getEventAddr() internal pure returns (address) {
    return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; // InstaEvent Address
  }

  /**
  * @dev Connector Details.
  */
  function connectorID() public view returns(uint model, uint id) {
    (model, id) = (1, 43);
  }

}





contract FlashLoanResolver is Stores {
    event LogDydxFlashLoan(address indexed token, uint256 tokenAmt);

    /**
        * @dev Return ethereum address
    */
    function getDydxLoanAddr() internal pure returns (address) {
        return address(0xf5b16af97B5CBa4Babe786238FF6016daE6bb890);
    }

    function getWethAddr() internal pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }

    /**
     * @dev Borrow Flashloan and Cast spells.
     * @param token Token Address.
     * @param tokenAmt Token Amount.
     * @param data targets & data for cast.
     */
    function borrowAndCast(address token, uint tokenAmt, bytes memory data) public payable {
        DydxFlashInterface DydxLoanContract = DydxFlashInterface(getDydxLoanAddr());

        AccountInterface(address(this)).enable(address(DydxLoanContract));

        address _token = token == getEthAddr() ? getWethAddr() : token;

        DydxLoanContract.initiateFlashLoan(_token, tokenAmt, data);

        AccountInterface(address(this)).disable(address(DydxLoanContract));

        emit LogDydxFlashLoan(token, tokenAmt);
        bytes32 _eventCode = keccak256("LogDydxFlashLoan(address,uint256)");
        bytes memory _eventParam = abi.encode(token, tokenAmt);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }
}

contract ConnectDydxFlashLoan is FlashLoanResolver {
    string public constant name = "dydx-flashloan-v1";
}