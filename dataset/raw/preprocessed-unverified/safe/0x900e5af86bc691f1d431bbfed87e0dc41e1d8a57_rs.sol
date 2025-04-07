/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.2;
pragma experimental ABIEncoderV2;






// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

// 
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

// 
/**
 * @dev Collection of functions related to the address type
 */




contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    //rounds to zero if x*y < WAD / 2
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    //rounds to zero if x*y < WAD / 2
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    //rounds to zero if x*y < RAY / 2
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}



enum OptionType {Invalid, Put, Call}

abstract 

contract InstrumentStorageV1 is Initializable, Ownable, ReentrancyGuard {
    IRibbonFactory public factory;
    address public underlying;
    address public strikeAsset;
    address public collateralAsset;
    uint256 public expiry;
    string public name;
    string public symbol;
    mapping(address => OldInstrumentPosition[]) private _instrumentPositions;

    uint256[100] private __instrumentGap;

    struct OldInstrumentPosition {
        bool exercised;
        OptionType[] optionTypes;
        uint32[] optionIDs;
        uint256[] amounts;
        uint256[] strikePrices;
        string[] venues;
    }
}

enum Venues {Unknown, Hegic, OpynGamma}

contract InstrumentStorageV2 {
    struct InstrumentPosition {
        bool exercised;
        uint8 callVenue;
        uint8 putVenue;
        uint32 callOptionID;
        uint32 putOptionID;
        uint256 amount;
        uint256 callStrikePrice;
        uint256 putStrikePrice;
    }

    mapping(address => InstrumentPosition[]) instrumentPositions;

    /**
     * @notice Returns the symbol of the instrument
     * @param _account is the address which has opened InstrumentPositions
     */
    function numOfPositions(address _account) public view returns (uint256) {
        return instrumentPositions[_account].length;
    }

    function getInstrumentPositions(address account)
        external
        view
        returns (InstrumentPosition[] memory positions)
    {
        return instrumentPositions[account];
    }

    function instrumentPosition(address account, uint256 positionID)
        external
        view
        returns (InstrumentPosition memory position)
    {
        return instrumentPositions[account][positionID];
    }
}

enum PurchaseMethod {Invalid, Contract, ZeroEx}

struct OptionTerms {
    address underlying;
    address strikeAsset;
    address collateralAsset;
    uint256 expiry;
    uint256 strikePrice;
    OptionType optionType;
}

struct ZeroExOrder {
    address exchangeAddress;
    address buyTokenAddress;
    address sellTokenAddress;
    address allowanceTarget;
    uint256 protocolFee;
    uint256 makerAssetAmount;
    uint256 takerAssetAmount;
    bytes swapData;
}





// 
contract DebugLib {
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(x) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) private pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function bytes32ToString(bytes32 x) internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        for (uint256 j = 0; j < 32; j++) {
            bytes1 character = bytes1(bytes32(uint256(x) * 2**(8 * j)));
            if (character != 0) {
                bytesString[charCount] = character;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function getRevertMsg(bytes memory _returnData)
        internal
        pure
        returns (string memory)
    {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}

// 
contract RibbonVolatility is DSMath, InstrumentStorageV1, InstrumentStorageV2 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using ProtocolAdapter for IProtocolAdapter;

    bytes32 private constant hegicHash = keccak256(bytes("HEGIC"));
    bytes32 private constant opynHash = keccak256(bytes("OPYN_GAMMA"));

    event PositionCreated(
        address indexed account,
        uint256 indexed positionID,
        string[] venues,
        OptionType[] optionTypes,
        uint256 amount
    );
    event Exercised(
        address indexed account,
        uint256 indexed positionID,
        uint256 totalProfit,
        bool[] optionsExercised
    );

    receive() external payable {}

    function initialize(
        address _owner,
        address _factory,
        string memory _name,
        string memory _symbol,
        address _underlying,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _expiry
    ) public initializer {
        require(block.timestamp < _expiry, "Expiry has already passed");

        Ownable.initialize(_owner);
        factory = IRibbonFactory(_factory);
        name = _name;
        symbol = _symbol;
        expiry = _expiry;
        underlying = _underlying;
        strikeAsset = _strikeAsset;
        collateralAsset = _collateralAsset;
    }

    function cost(
        string[] memory venues,
        OptionType[] memory optionTypes,
        uint256[] memory amounts,
        uint256[] memory strikePrices
    ) public view returns (uint256 totalPremium) {
        for (uint256 i = 0; i < venues.length; i++) {
            address adapterAddress = factory.getAdapter(venues[i]);
            require(adapterAddress != address(0), "Adapter does not exist");
            IProtocolAdapter adapter = IProtocolAdapter(adapterAddress);

            if (adapter.purchaseMethod() == PurchaseMethod.ZeroEx) {
                continue;
            }

            bool exists =
                adapter.delegateOptionsExist(
                    OptionTerms(
                        underlying,
                        strikeAsset,
                        collateralAsset,
                        expiry,
                        strikePrices[i],
                        optionTypes[i]
                    )
                );
            require(exists, "Options does not exist");

            totalPremium += adapter.delegatePremium(
                OptionTerms(
                    underlying,
                    strikeAsset,
                    collateralAsset,
                    expiry,
                    strikePrices[i],
                    optionTypes[i]
                ),
                amounts[i]
            );
        }
    }

    function exerciseProfit(address account, uint256 positionID)
        external
        view
        returns (uint256)
    {
        InstrumentPosition storage position =
            instrumentPositions[account][positionID];

        if (position.exercised) return 0;

        uint256 profit = 0;

        uint8[] memory venues = new uint8[](2);
        venues[0] = position.callVenue;
        venues[1] = position.putVenue;

        for (uint256 i = 0; i < venues.length; i++) {
            string memory venue = getAdapterName(venues[i]);
            uint256 amount = position.amount;

            OptionType optionType;
            uint256 strikePrice;
            uint32 optionID;
            if (i == 0) {
                strikePrice = position.callStrikePrice;
                optionID = position.callOptionID;
                optionType = OptionType.Call;
            } else {
                strikePrice = position.putStrikePrice;
                optionID = position.putOptionID;
                optionType = OptionType.Put;
            }

            address adapterAddress = factory.getAdapter(venue);
            require(adapterAddress != address(0), "Adapter does not exist");
            IProtocolAdapter adapter = IProtocolAdapter(adapterAddress);
            address options =
                adapter.getOptionsAddress(
                    OptionTerms(
                        underlying,
                        strikeAsset,
                        collateralAsset,
                        expiry,
                        strikePrice,
                        optionType
                    )
                );

            bool exercisable = adapter.canExercise(options, optionID, amount);
            if (!exercisable) {
                continue;
            }

            profit += adapter.delegateExerciseProfit(options, optionID, amount);
        }
        return profit;
    }

    function canExercise(address account, uint256 positionID)
        external
        view
        returns (bool)
    {
        InstrumentPosition storage position =
            instrumentPositions[account][positionID];

        if (position.exercised) return false;

        bool eitherOneCanExercise = false;

        uint8[] memory venues = new uint8[](2);
        venues[0] = position.callVenue;
        venues[1] = position.putVenue;

        for (uint256 i = 0; i < venues.length; i++) {
            string memory venue = getAdapterName(venues[i]);
            uint256 strikePrice;
            uint32 optionID;
            OptionType optionType;
            if (i == 0) {
                strikePrice = position.callStrikePrice;
                optionID = position.callOptionID;
                optionType = OptionType.Call;
            } else {
                strikePrice = position.putStrikePrice;
                optionID = position.putOptionID;
                optionType = OptionType.Put;
            }

            address adapterAddress = factory.getAdapter(venue);
            require(adapterAddress != address(0), "Adapter does not exist");
            IProtocolAdapter adapter = IProtocolAdapter(adapterAddress);
            address options =
                adapter.getOptionsAddress(
                    OptionTerms(
                        underlying,
                        strikeAsset,
                        collateralAsset,
                        expiry,
                        strikePrice,
                        optionType
                    )
                );

            bool canExerciseOptions =
                adapter.canExercise(options, optionID, position.amount);

            if (canExerciseOptions) {
                eitherOneCanExercise = true;
            }
        }
        return eitherOneCanExercise;
    }

    /**
     * @notice Buy instrument and create the underlying options positions
     * @param venues array of venue names, e.g. "HEGIC", "OPYN_V1"
     * @param amount amount of contracts to purchase
     */
    function buyInstrument(
        string[] memory venues,
        OptionType[] memory optionTypes,
        uint256 amount,
        uint256[] memory strikePrices,
        bytes[] memory buyData
    ) public payable nonReentrant returns (uint256 positionID) {
        require(venues.length >= 2, "Must have 2 or more venue");
        require(optionTypes.length >= 2, "Must have 2 or more optionTypes");
        require(strikePrices.length >= 2, "Must have 2 or more strikePrices");
        require(buyData.length >= 2, "Must have 2 or more buyData");

        require(block.timestamp < expiry, "Cannot purchase after expiry");

        bool seenCall = false;
        bool seenPut = false;

        InstrumentPosition memory position;
        position.exercised = false;
        position.amount = amount;

        for (uint256 i = 0; i < venues.length; i++) {
            uint32 optionID =
                purchaseOptionAtVenue(
                    venues[i],
                    optionTypes[i],
                    amount,
                    strikePrices[i],
                    buyData[i]
                );

            if (!seenPut && optionTypes[i] == OptionType.Put) {
                position.callVenue = uint8(getVenueID(venues[i]));
                position.callStrikePrice = strikePrices[i];
                position.callOptionID = optionID;
                seenPut = true;
            } else if (!seenCall && optionTypes[i] == OptionType.Call) {
                position.putVenue = uint8(getVenueID(venues[i]));
                position.putStrikePrice = strikePrices[i];
                position.putOptionID = optionID;
                seenCall = true;
            }
        }

        positionID = instrumentPositions[msg.sender].length;
        instrumentPositions[msg.sender].push(position);

        factory.burnGasTokens();

        emit PositionCreated(
            msg.sender,
            positionID,
            venues,
            optionTypes,
            amount
        );
    }

    function purchaseOptionAtVenue(
        string memory venue,
        OptionType optionType,
        uint256 amount,
        uint256 strikePrice,
        bytes memory buyData
    ) private returns (uint32 optionID) {
        address adapterAddress = factory.getAdapter(venue);
        require(adapterAddress != address(0), "Adapter does not exist");
        IProtocolAdapter adapter = IProtocolAdapter(adapterAddress);

        require(optionType != OptionType.Invalid, "Invalid option type");

        PurchaseMethod purchaseMethod = adapter.purchaseMethod();

        require(
            purchaseMethod != PurchaseMethod.Invalid,
            "Invalid purchase method"
        );

        if (purchaseMethod == PurchaseMethod.Contract) {
            optionID = purchaseWithContract(
                adapter,
                optionType,
                amount,
                strikePrice
            );
        } else if (purchaseMethod == PurchaseMethod.ZeroEx) {
            purchaseWithZeroEx(adapter, optionType, strikePrice, buyData);
        }
    }

    function purchaseWithContract(
        IProtocolAdapter adapter,
        OptionType optionType,
        uint256 amount,
        uint256 strikePrice
    ) private returns (uint32 optionID) {
        OptionTerms memory optionTerms =
            OptionTerms(
                underlying,
                strikeAsset,
                collateralAsset,
                expiry,
                strikePrice,
                optionType
            );

        uint256 optionID256 = adapter.delegatePurchase(optionTerms, amount);
        optionID = uint32(optionID256);
    }

    function purchaseWithZeroEx(
        IProtocolAdapter adapter,
        OptionType optionType,
        uint256 strikePrice,
        bytes memory buyData
    ) private {
        OptionTerms memory optionTerms =
            OptionTerms(
                underlying,
                strikeAsset,
                collateralAsset,
                expiry,
                strikePrice,
                optionType
            );

        ZeroExOrder memory zeroExOrder = abi.decode(buyData, (ZeroExOrder));

        adapter.delegatePurchaseWithZeroEx(optionTerms, zeroExOrder);
    }

    function exercisePosition(uint256 positionID)
        public
        nonReentrant
        returns (uint256 totalProfit)
    {
        InstrumentPosition storage position =
            instrumentPositions[msg.sender][positionID];
        require(!position.exercised, "Already exercised");

        bool[] memory optionsExercised = new bool[](2);
        uint8[] memory venues = new uint8[](2);
        venues[0] = position.callVenue;
        venues[1] = position.putVenue;

        for (uint256 i = 0; i < venues.length; i++) {
            string memory adapterName = getAdapterName(venues[i]);
            IProtocolAdapter adapter =
                IProtocolAdapter(factory.getAdapter(adapterName));

            OptionType optionType;
            uint256 strikePrice;
            uint32 optionID;
            if (i == 0) {
                strikePrice = position.callStrikePrice;
                optionID = position.callOptionID;
                optionType = OptionType.Call;
            } else {
                strikePrice = position.putStrikePrice;
                optionID = position.putOptionID;
                optionType = OptionType.Put;
            }

            address optionsAddress =
                adapter.getOptionsAddress(
                    OptionTerms(
                        underlying,
                        strikeAsset,
                        collateralAsset,
                        expiry,
                        strikePrice,
                        optionType
                    )
                );

            require(optionsAddress != address(0), "Options address must exist");

            uint256 amount = position.amount;

            uint256 profit =
                adapter.delegateExerciseProfit(
                    optionsAddress,
                    optionID,
                    amount
                );
            if (profit > 0) {
                adapter.delegateExercise(
                    optionsAddress,
                    optionID,
                    amount,
                    msg.sender
                );
                optionsExercised[i] = true;
            } else {
                optionsExercised[i] = false;
            }
            totalProfit += profit;
        }
        position.exercised = true;

        emit Exercised(msg.sender, positionID, totalProfit, optionsExercised);
    }

    function getAdapterName(uint8 venueID)
        private
        pure
        returns (string memory)
    {
        if (venueID == uint8(Venues.Hegic)) {
            return "HEGIC";
        } else if (venueID == uint8(Venues.OpynGamma)) {
            return "OPYN_GAMMA";
        }
        return "";
    }

    function getVenueID(string memory venueName) private pure returns (Venues) {
        if (keccak256(bytes(venueName)) == hegicHash) {
            return Venues.Hegic;
        } else if (keccak256(bytes(venueName)) == opynHash) {
            return Venues.OpynGamma;
        }
        return Venues.Unknown;
    }
}