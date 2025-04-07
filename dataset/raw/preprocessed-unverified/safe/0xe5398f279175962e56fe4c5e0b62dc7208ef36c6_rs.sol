/**
 *Submitted for verification at Etherscan.io on 2020-12-17
*/

pragma solidity ^0.6.0;




/**
 * @dev Collection of functions related to the address type
 */












contract Stores {

    /**
     * @dev Return ethereum address
     */
    function getEthAddr() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return memory variable address
     */
    function getMemoryAddr() internal pure returns (address) {
        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
    }

    /**
     * @dev Return InstaEvent Address.
     */
    function getEventAddr() internal pure returns (address) {
        return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; // InstaEvent Address
    }

    /**
     * @dev Get Uint value from InstaMemory Contract.
     */
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
    }

    /**
     * @dev Set Uint value in InstaMemory Contract.
     */
    function setUint(uint setId, uint val) internal {
        if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
    }

    /**
     * @dev emit event on event contract
     */
    function emitEvent(bytes32 eventCode, bytes memory eventData) internal {
        (uint model, uint id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
    }

    /**
     * @dev Connector Details.
     */
    function connectorID() public pure returns(uint model, uint id) {
        (model, id) = (1, 68);
    }

}

contract DSMath {
    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }


    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

}



contract BasicResolver is Stores {
    event LogDeposit(address indexed erc20, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogWithdraw(address indexed erc20, uint256 tokenAmt, address indexed to, uint256 getId, uint256 setId);

    using SafeERC20 for IERC20;

    /**
     * @dev Deposit Assets To Smart Account.
     * @param erc20 Token Address.
     * @param tokenAmt Token Amount.
     * @param getId Get Storage ID.
     * @param setId Set Storage ID.
     */
    function deposit(address erc20, uint tokenAmt, uint getId, uint setId) public payable {
        uint amt = getUint(getId, tokenAmt);
        if (erc20 != getEthAddr()) {
            IERC20 token = IERC20(erc20);
            amt = amt == uint(-1) ? token.balanceOf(msg.sender) : amt;
            token.safeTransferFrom(msg.sender, address(this), amt);
        } else {
            require(msg.value == amt || amt == uint(-1), "invalid-ether-amount");
            amt = msg.value;
        }
        setUint(setId, amt);

        emit LogDeposit(erc20, amt, getId, setId);

        bytes32 _eventCode = keccak256("LogDeposit(address,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(erc20, amt, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }

   /**
     * @dev Withdraw Assets To Smart Account.
     * @param erc20 Token Address.
     * @param tokenAmt Token Amount.
     * @param to Withdraw token address.
     * @param getId Get Storage ID.
     * @param setId Set Storage ID.
     */
    function withdraw(
        address erc20,
        uint tokenAmt,
        address payable to,
        uint getId,
        uint setId
    ) public payable {
        // require(AccountInterface(address(this)).isAuth(to), "invalid-to-address");
        uint amt = getUint(getId, tokenAmt);
        if (erc20 == getEthAddr()) {
            amt = amt == uint(-1) ? address(this).balance : amt;
            to.transfer(amt);
        } else {
            IERC20 token = IERC20(erc20);
            amt = amt == uint(-1) ? token.balanceOf(address(this)) : amt;
            token.safeTransfer(to, amt);
        }
        setUint(setId, amt);

        emit LogWithdraw(erc20, amt, to, getId, setId);

        bytes32 _eventCode = keccak256("LogWithdraw(address,uint256,address,uint256,uint256)");
        bytes memory _eventParam = abi.encode(erc20, amt, to, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }
}

contract ConnectBasic is BasicResolver {
    string public constant name = "Basic-v1.2";
}