/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

pragma solidity ^0.6.0;

















contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}

contract Helpers is DSMath {

    /**
     * @dev Return ethereum address
     */
    function getAddressETH() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return InstaEvent Address.
     */
    function getEventAddr() internal pure returns (address) {
        return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; // InstaEvent Address
    }

    /**
     * @dev Return Memory Variable Address
     */
    function getMemoryAddr() internal pure returns (address) {
        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
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
     * @dev Connector Details.
     */
    function connectorID() public pure returns(uint model, uint id) {
        (model, id) = (1, 55);
    }

    // /**
    //  * @dev emit event on event contract
    //  */
    // function emitEvent(bytes32 eventCode, bytes memory eventData) internal {
    //     (uint model, uint id) = connectorID();
    //     EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
    // }
}

contract ImportHelper is Helpers {
    /**
     * @dev Return InstaDApp Mapping Address
     */
    function getMappingAddr() internal pure returns (address) {
        return 0xe81F70Cc7C0D46e12d70efc60607F16bbD617E88; // InstaMapping Address
    }

    /**
     * @dev Return CETH Address
     */
    function getCETHAddr() internal pure returns (address) {
        return 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    }

    /**
     * @dev Return Compound Comptroller Address
     */
    function getComptrollerAddress() internal pure returns (address) {
        return 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }

   /**
     * @dev enter compound market
     */
    function enterMarkets(address[] memory cErc20) internal {
        ComptrollerInterface(getComptrollerAddress()).enterMarkets(cErc20);
    }
}

contract ImportResolver is ImportHelper {

    event LogCompoundImport(
        address user,
        address[] cTokens,
        uint[] cTknBals,
        uint[] borrowBals
    );

    function _borrow(CTokenInterface[] memory ctokenContracts, uint[] memory amts, uint _length) internal {
        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                require(ctokenContracts[i].borrow(amts[i]) == 0, "borrow-failed-collateral?");
            }
        }
    }

    function _paybackOnBehalf(
        address userAddress,
        CTokenInterface[] memory ctokenContracts,
        uint[] memory amts,
        uint _length
    ) internal {
        address cethAddr = getCETHAddr();
        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                if (address(ctokenContracts[i]) == cethAddr) {
                     CETHInterface(cethAddr).repayBorrowBehalf.value(amts[i])(userAddress);
                } else {
                    require(ctokenContracts[i].repayBorrowBehalf(userAddress, amts[i]) == 0, "repayOnBehalf-failed");
                }
            }
        }
    }

    function _transferCtokens(
        address userAccount,
        CTokenInterface[] memory ctokenContracts,
        uint[] memory amts,
        uint _length
    ) internal {
        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                require(ctokenContracts[i].transferFrom(userAccount, address(this), amts[i]), "ctoken-transfer-failed-allowance?");
            }
        }
    }

    function importCompound(address userAccount, address[] calldata tokens) external payable {
        require(DSAInterface(address(this)).isAuth(userAccount), "user-account-not-auth");

        uint _length = tokens.length;
        require(_length > 0, "0-tokens-not-allowed");


        address[] memory ctokens = new address[](_length);
        uint[] memory borrowAmts = new uint[](_length);
        uint[] memory ctokensBal = new uint[](_length);
        CTokenInterface[] memory ctokenContracts = new CTokenInterface[](_length);

        InstaMapping instaMapping = InstaMapping(getMappingAddr());

        for (uint i = 0; i < _length; i++) {
            ctokens[i] = instaMapping.cTokenMapping(tokens[i]);

            require(ctokens[i] != address(0), "no-ctoken-mapping");
            ctokenContracts[i] = CTokenInterface(ctokens[i]);

            ctokensBal[i] = ctokenContracts[i].balanceOf(userAccount);
            borrowAmts[i] = ctokenContracts[i].borrowBalanceCurrent(userAccount);
            if (ctokens[i] != getCETHAddr() && borrowAmts[i] > 0) {
                TokenInterface(tokens[i]).approve(ctokens[i], borrowAmts[i]);
            }
        }

        enterMarkets(ctokens);
        _borrow(ctokenContracts, borrowAmts, _length);
        _paybackOnBehalf(userAccount, ctokenContracts, borrowAmts, _length);
        _transferCtokens(userAccount, ctokenContracts, ctokensBal, _length);

        emit LogCompoundImport(userAccount, ctokens, ctokensBal, borrowAmts);
    }
}

contract ConnectCompoundImport is ImportResolver {
    string public name = "Compound-Import-v2.0";
}