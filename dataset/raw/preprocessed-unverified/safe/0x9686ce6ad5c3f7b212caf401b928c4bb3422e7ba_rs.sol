/**
 *Submitted for verification at Etherscan.io on 2021-04-16
*/

// Sources flattened with hardhat v2.1.2 https://hardhat.org

// File contracts/common/interfaces.sol

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;











// Aave Protocol Data Provider








struct AaveDataRaw {
    address targetDsa;
    uint[] supplyAmts;
    uint[] variableBorrowAmts;
    uint[] stableBorrowAmts;
    address[] supplyTokens;
    address[] borrowTokens;
}


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


contract DSMath {
    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(x, y);
    }

    function sub(uint x, uint y) internal virtual pure returns (uint z) {
        z = SafeMath.sub(x, y);
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.mul(x, y);
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.div(x, y);
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }
}

abstract contract Stores {

    /**
    * @dev Return ethereum address
    */
    address constant internal ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
    * @dev Return Wrapped ETH address
    */
    address constant internal wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /**
    * @dev Return memory variable address
    */
    MemoryInterface constant internal instaMemory = MemoryInterface(0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F);

    /**
    * @dev Get Uint value from InstaMemory Contract.
    */
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : instaMemory.getUint(getId);
    }

    /**
    * @dev Set Uint value in InstaMemory Contract.
    */
    function setUint(uint setId, uint val) virtual internal {
        if (setId != 0) instaMemory.setUint(setId, val);
    }

}


abstract contract Helpers is DSMath, Stores {

    /**
     * @dev Insta Aave migrator contract
    */
    AaveMigratorInterface constant internal migrator = AaveMigratorInterface(address(0xA0557234eB7b3c503388202D3768Cfa2f1AE9Dc2));

    /**
     * @dev Aave Data Provider
    */
    AaveDataProviderInterface constant internal aaveData = AaveDataProviderInterface(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
}

contract Events {
    event LogAaveV2Migrate(
        address indexed user,
        address indexed targetDsa,
        address[] supplyTokens,
        address[] borrowTokens
    );
}

contract AaveMigrateResolver is Helpers, Events {

    function migrate(
        address targetDsa,
        address[] memory supplyTokens,
        address[] memory borrowTokens,
        uint[] memory variableBorrowAmts,
        uint[] memory stableBorrowAmts,
        uint[] memory supplyAmts,
        uint ethAmt // if ethAmt is > 0 then use migrateWithflash
    ) external payable {
        require(supplyTokens.length > 0, "0-length-not-allowed");
        require(supplyTokens.length == supplyAmts.length, "invalid-length");
        require(borrowTokens.length == variableBorrowAmts.length && borrowTokens.length  == stableBorrowAmts.length, "invalid-length");
        require(targetDsa != address(0), "invalid-address");

        AaveDataRaw memory data;

        data.targetDsa = targetDsa;
        data.supplyTokens = supplyTokens;
        data.borrowTokens = borrowTokens;
        data.variableBorrowAmts = variableBorrowAmts;
        data.stableBorrowAmts = stableBorrowAmts;
        data.supplyAmts = supplyAmts;

        for (uint i = 0; i < data.supplyTokens.length; i++) {
            address _token = data.supplyTokens[i] == ethAddr ? wethAddr : data.supplyTokens[i];
            data.supplyTokens[i] = _token;
            (address _aToken, ,) = aaveData.getReserveTokensAddresses(_token);
            ATokenInterface _aTokenContract = ATokenInterface(_aToken);

            if (data.supplyAmts[i] == uint(-1)) {
                data.supplyAmts[i] = _aTokenContract.balanceOf(address(this));
            }

            _aTokenContract.approve(address(migrator), data.supplyAmts[i]);
        }

        if (ethAmt > 0) {
            migrator.migrateWithFlash(data, ethAmt);
        } else {
            migrator.migrate(data);
        }

        emit LogAaveV2Migrate(msg.sender, data.targetDsa, data.supplyTokens, data.borrowTokens);
    }

}

contract ConnectAaveV2PolygonMigrator is AaveMigrateResolver {

    /**
     * @dev Connector Details
    */
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 90);
    }

    string constant public name = "Aave-V2-Polygon-Migrator-v1";
}