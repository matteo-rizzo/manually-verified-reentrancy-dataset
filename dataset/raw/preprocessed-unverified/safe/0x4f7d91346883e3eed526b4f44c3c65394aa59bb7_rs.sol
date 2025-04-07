/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

pragma solidity ^0.7.1;
//SPDX-License-Identifier: UNLICENSED

/* New ERC23 contract interface */



/**
* @title Contract that will work with ERC223 tokens.
*/










pragma experimental ABIEncoderV2;



/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */


/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */


/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */


/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */




/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */








interface IShyftKycContract is IErc20, IErc223, IErc223ReceivingContract {
    function balanceOf(address tokenOwner) external view override(IErc20, IErc223) returns (uint balance);
    function totalSupply() external view override(IErc20, IErc223) returns (uint);
    function transfer(address to, uint tokens) external override(IErc20, IErc223) returns (bool success);

    function getNativeTokenType() external view returns (uint256 result);

    function withdrawNative(address payable _to, uint256 _value) external returns (bool ok);
    function withdrawToExternalContract(address _to, uint256 _value) external returns (bool ok);
    function withdrawToShyftKycContract(address _shyftKycContractAddress, address _to, uint256 _value) external returns (bool ok);

    function migrateFromKycContract(address _to) external payable returns(bool result);
    function updateContract(address _addr) external returns (bool);

    function getBalanceBip32X(address _identifiedAddress, uint256 _bip32X_type) external view returns (uint256 balance);

    function getOnlyAcceptsKycInput(address _identifiedAddress) external view returns (bool result);
    function getOnlyAcceptsKycInputPermanently(address _identifiedAddress) external view returns (bool result);
}



/// @dev
/// | This contract manages the distribution contracts for the Shyft Network. It is built to enable a native-mode or erc20-mode distribution with specific distribution tables (with individual cycles with %'s and times).
/// | For each of the individuals allocated to, they have their own (potentially unique) distribution table, along with a potential cutoff (reduction) & the address which is managing that, as well as total distributed and any cliff/vesting information.
/// @notice
/// |  This function should be disabled before launch, but for testing purposes there is a requirement to be able to receive native fuel, so this is done in the most strict mode possible, by checking ownership before value transfer can occur.
/// |  receive() external payable {
/// |      if (msg.sender != owner) {
/// |          revert();
/// |      }
/// |  }
/// |
/// | As such, the grunt setup file ('root'/Gruntfile.js) performs some operations to mirror this file to 'root'/Tests/ShyftKycDistribution_OutputForTestCompatibility.sol whenever any "test" related Grunt command is executed.

contract ShyftKycDistribution {
    using SafeMath for uint256;

    /// @dev Event for new shyft total claimed. created.
    event EVT_shyftClaimed(address indexed recipient, uint256 indexed amountClaimed, uint256 totalAllocated, uint256 grandTotalClaimed, uint256 timeStamp);

    /// @dev Event for new allocation created.
    event EVT_newAllocation(address indexed recipient, uint256 totalAllocated, uint256 endCliff, uint256 endVesting, uint256 cutoffTokenAmount, address cutoffAdminAddress, bytes32 distributionTableHash);

    /// @dev Event for cutoff being triggered.
    event EVT_cutoffTriggered(address indexed recipient, uint256 modifiedAllocation, uint256 amountClaimed, uint256 remainingDistribution, uint256 tokensToReturnToCore);

    /// @dev Event for cutoff being triggered (for the "over allocated" case where a user has already withdrawn more tokens than would have been available post-cutoff).
    event EVT_cutoffTriggeredOverAllocated(address indexed recipient, uint256 modifiedAllocation, uint256 amountClaimed, uint256 overAllocatedDistribution, uint256 tokensToReturnToCore);

    /// @dev The kyc contract registry address for erc20 token transfer mode.
    address public kycContractRegistryAddress;

    /// @dev The decimal factor for calculations (saves gas if it's pre-set here).
    uint256 private constant decimalFactor = 10**uint256(18);

    /// @dev The initial supply. Needs to be hardcoded for launch.
    uint256 public constant INITIAL_SUPPLY = 322982495 * decimalFactor;

    /// @dev The total amount of tokens claimed.
    uint256 public totalClaimed;

    /// @dev The start time for this distribution contract.
    uint256 public startTime;

    /// @dev Struct for the distribution cycles, with time periods of starting, ending, percentage of tokens and a 64.64 floating point representation for the percentages.
    struct distributionCycle {
        uint256 timePeriodStart;
        uint256 timePeriodEnd;
        uint256 percentTokens;
        int128 percentTokens_fixedPoint;
    }

    /// @dev Struct for the Allocations with vesting, cutoff, and distribution table information.
    struct Allocation {
        uint256 endCliff;       // Tokens are locked until
        uint256 endVesting;     // This is when the tokens are fully unvested
        uint256 totalAllocated; // Total tokens allocated
        uint256 amountClaimed;  // Total tokens claimed
        uint256 cutoffTokenAmount;   // Amount of tokens reduced
        address cutoffAdminAddress;  // address that has the ability to trigger the cutoff
        bool    cutoffEnabled;     // whether the cutoff is enabled
        bytes32 distributionTableHash;
    }

    /// @dev Struct for the distribution table - if it exists, its string name, an array of the distribution cycles, an array of the total percentage (cumulative) at the end of the cycles.
    struct distributionTable {
        bool exists;
        string distributionTableName;

        distributionCycle[] cyclesArray;
        int128[] totalPercentAtEndOfCycleArray_fixedPoint;
    }

    /// @dev Mapping for keccak hash to distribution table.
    mapping(bytes32 => distributionTable) distributionHashToTableMapping;

    /// @dev Mapping for address to allocations.
    mapping (address => Allocation) public allocations;

    /// @dev Address for the any of the cutoff tokens to be transferred to.
    address payable public shyftCoreTokenAddress;

    /// @dev Whether this distribution contract is outputting to the Shyft KYC Contract token address.
    bool public transferTokenMode;

    /// @dev The owner of this contract.
    address owner;

    /// @param _transferTokenMode Whether this contract transfers tokens from the primary shyft kyc contract in the registry.
    /// @dev Constructor function - Sets the start time and token transfer mode. False equates to native, True equates to erc20 token transfer mode.
    constructor (bool _transferTokenMode) {
        startTime = block.timestamp;

        owner = msg.sender;
        transferTokenMode = _transferTokenMode;
    }

    /// @param _vestEndSeconds When the vest ends in seconds.
    /// @param _cycles An array of "distributionCycle"-formatted cycles.
    /// @param _totalPercentAtEndOfCycles_18DecimalPrecision An array of the total percentage of distribution at the end of the cycles (cumulative).
    /// @dev Internal method to assist setup up for a new distribution table with cycles and the total percentages of each cycle. Takes in a storage array and modifies it, erasing modifications if there's an error that was calculated.
    /// @return result
    ///    | 8 = (error) time period didn't start as the previous ended
    ///    | 7 = (error) time period is higher than full vesting days
    ///    | 6 = (error) time period does not end on the full vesting day
    ///    | 5 = (error) allocation cycle does not equal 100%
    ///    | 4 = (error) allocation cycle has zero percentage
    ///    | 3 = (error) allocation cycles do not match
    ///    | 0 = successfully calculated distribution table

    function calculateDistributionTable(distributionTable storage _distributionTable,
                                        uint256 _vestEndSeconds,
                                        distributionCycle[] memory _cycles,
                                        uint256[] memory _totalPercentAtEndOfCycles_18DecimalPrecision) internal returns (uint8 result) {
        distributionCycle memory prevCycle;
        uint8 errorCode;

        uint256 totalPercentFromCycles = 0;

        for (uint256 i = 0; i < _cycles.length; i++) {
            distributionCycle memory curCycle = _cycles[i];

            // take care of the first index
            if (i == 0) {
                if (curCycle.timePeriodStart != 0) {
                    //time period does not start immediately
                    errorCode = 9;
                    break;
                }
            } else {
                // always check for time alignment
                if (curCycle.timePeriodStart != prevCycle.timePeriodEnd) {
                    //time period didn't start as the previous ended
                    errorCode = 8;
                    break;
                }
                // take care of intermediate indexes
                if (i != _cycles.length - 1) {
                    if (curCycle.timePeriodEnd > _vestEndSeconds) {
                        //time period is higher than full vesting days
                        errorCode = 7;
                        break;
                    }
                } else {
                    //take care of the last index
                    if (curCycle.timePeriodEnd != _vestEndSeconds) {
                        //time period does not end on the full vesting day
                        errorCode = 6;
                        break;
                    }

                    if (totalPercentFromCycles.add(curCycle.percentTokens) != (decimalFactor)) {
                        //allocation cycle does not equal 100%
                        errorCode = 5;
                        break;
                    }
                }
            }

            if (_totalPercentAtEndOfCycles_18DecimalPrecision[i] == 0) {
                //allocation cycle has zero percentage
                errorCode = 4;
                break;
            }

            totalPercentFromCycles = totalPercentFromCycles.add(curCycle.percentTokens);

            if (i > 0) {
                if (_totalPercentAtEndOfCycles_18DecimalPrecision[i] != totalPercentFromCycles) {
                    //allocation cycles do not match
                    errorCode = 3;
                    break;
                }
            } else {
                if (_totalPercentAtEndOfCycles_18DecimalPrecision[i] != totalPercentFromCycles) {
                    //allocation cycles do not match
                    errorCode = 3;
                    break;
                }
            }

            prevCycle = curCycle;

            if (errorCode == 0) {
                curCycle.percentTokens_fixedPoint = ABDKMath64x64.div(ABDKMath64x64.fromUInt(curCycle.percentTokens), ABDKMath64x64.fromUInt(decimalFactor));

                _distributionTable.totalPercentAtEndOfCycleArray_fixedPoint.push(ABDKMath64x64.div(ABDKMath64x64.fromUInt(_totalPercentAtEndOfCycles_18DecimalPrecision[i]), ABDKMath64x64.fromUInt(decimalFactor)));
                _distributionTable.cyclesArray.push(curCycle);
            } else {
                //cleanup in case of an error
                delete _distributionTable.totalPercentAtEndOfCycleArray_fixedPoint;
                delete _distributionTable.cyclesArray;

                break;
            }
        }

        //return results of calculation
        return (errorCode);
    }

    /// @param _distributionTableName The name of this distribution table.
    /// @param _vestEndSeconds When the vest ends in seconds.
    /// @param _cycles An array of "distributionCycle"-formatted cycles.
    /// @param _totalPercentAtEndOfCycles_18DecimalPrecision An array of the total percentage of distribution at the end of the cycles (cumulative).
    /// @dev Sets up a new distribution table with cycles and the total percentages of each cycle.
    /// @return success
    ///    | true = set new distribution table
    ///    | false = error in distribution table
    /// @return result
    ///    | [uint256] = (success) distribution table keccak hash for further reference (in uint256 format)
    ///    | 9 = (error) time period does not start immediately
    ///    | 8 = (error) time period didn't start as the previous ended
    ///    | 7 = (error) time period is higher than full vesting days
    ///    | 6 = (error) time period does not end on the full vesting day
    ///    | 5 = (error) allocation cycle does not equal 100%
    ///    | 4 = (error) allocation cycle has zero percentage
    ///    | 3 = (error) allocation cycles do not match
    ///    | 2 = (error) distribution table already exists
    ///    | 1 = (error) lengths of inputs do not match
    ///    | 0 = (error) not owner

    function setupDistributionTable(string memory _distributionTableName,
                                    uint256 _vestEndSeconds,
                                    distributionCycle[] memory _cycles,
                                    uint256[] memory _totalPercentAtEndOfCycles_18DecimalPrecision) public returns (bool success, uint256 result) {
        if (msg.sender == owner) {
            if (_cycles.length == _totalPercentAtEndOfCycles_18DecimalPrecision.length) {
                bytes32 distributionTableHash = keccak256(abi.encodePacked(_distributionTableName));

                distributionTable storage newDistributionTable = distributionHashToTableMapping[distributionTableHash];

                if (newDistributionTable.exists != true) {

                    (uint8 errorCode) = calculateDistributionTable(newDistributionTable, _vestEndSeconds, _cycles, _totalPercentAtEndOfCycles_18DecimalPrecision);

                    if (errorCode == 0) {
                        newDistributionTable.exists = true;

                        newDistributionTable.distributionTableName = _distributionTableName;

                        //set new distribution table
                        return (true, uint256(distributionTableHash));
                    } else {
                        //error in distribution table, return error code
                        return (false, errorCode);
                    }
                } else {
                    //distribution table already exists
                    return (false, 2);
                }
            } else {
                //lengths of inputs do not match
                return (false, 1);
            }
        } else {
            //not owner
            return (false, 0);
        }
    }

    /// @param _recipient The address of the recipient.
    /// @param _totalAllocated The total tokens allocated.
    /// @param _endCliffDays The end of the cliff (in days).
    /// @param _endVestingDays The end of the vesting (in days).
    /// @param _cutoffTokenAmount The amount of tokens that can be reduced from this allocation if triggered by the cutoff address.
    /// @param _cutoffAdminAddress The address of the actor responsible for performing the cutoff (reduction) of the token allocation.
    /// @param _distributionTableHash The hash of the distribution table that this allocation follows.
    /// @dev Sets the allocation for a specific recipient with cliff, vest, potential reduction if cutoff is triggered, and the distribution table hash. Also blocks recipients from being added twice (referencing the distribution table hash) as an additional precautionary measure.
    /// @return result should be "1" if all is processed successfully.

    function setAllocation( address _recipient,
                            uint256 _totalAllocated,
                            uint256 _endCliffDays,
                            uint256 _endVestingDays,
                            uint256 _cutoffTokenAmount,
                            address _cutoffAdminAddress,
                            bytes32 _distributionTableHash) public returns (uint8 result) {
        require(msg.sender == owner);
        require(_recipient != address(0));
        require(allocations[_recipient].distributionTableHash == bytes32(0));
        require(_totalAllocated <= INITIAL_SUPPLY);
        require(_totalAllocated >= _cutoffTokenAmount);
        require(_endCliffDays <= _endVestingDays);

        Allocation storage a = allocations[_recipient];
        a.endCliff = startTime.add(_endCliffDays.mul(1 days));
        a.endVesting = startTime.add(_endVestingDays.mul(1 days));
        a.totalAllocated = _totalAllocated;
        a.cutoffTokenAmount = _cutoffTokenAmount;
        a.cutoffAdminAddress = _cutoffAdminAddress;
        a.distributionTableHash = _distributionTableHash;

        emit EVT_newAllocation(_recipient, _totalAllocated, _endCliffDays, _endVestingDays, _cutoffTokenAmount, _cutoffAdminAddress, _distributionTableHash);

        return 1;
    }

    /// @param _amount The amount of tokens to send to the Shyft Core address.
    /// @dev An internal function to add cutoff tokens back to the Shyft Core token pool.
    function addCutoffTokensToCore(uint256 _amount) internal {
        if (transferTokenMode == true) {
            IShyftKycContractRegistry kycContractRegistry = IShyftKycContractRegistry(kycContractRegistryAddress);

            //@note: only transfers out to the first contract, which has a balance outstanding of the totality of the
            // distribution amount.

            IShyftKycContract kycContract = IShyftKycContract(kycContractRegistry.getContractAddressOfVersion(0));

            bool contractTxSuccess = kycContract.transfer(shyftCoreTokenAddress, _amount);

            // need to revert due to transactional logic.
            if (contractTxSuccess == false) {
                revert();
            }
        } else {
            // not limiting gas here so you can transfer to contracts etc.
            (bool nativeTxSuccess, ) = shyftCoreTokenAddress.call{value: _amount}("");

            // need to revert due to transactional logic.
            if (nativeTxSuccess == false) {
                revert();
            }
        }
    }

    /// @param _recipient The address of the recipient.
    /// @dev | Triggers the cutoff (reduction in allocation) for this recipient. This must be called by the address that has been specified previously to be the administrator for this recipient. If there are any tokens remaining from the distribution (total-cutoff) those are returned to the Shyft Core pool.
    ///      | The algorithm is: "remaining = (total - cutoff) - withdrawn", as long as "withdrawn" is lower than the newly cutoff allocation, otherwise it'll return how many tokens are over-allocated.
    /// @return result
    ///    | 3 = set the cutoff for this recipient, still has distribution
    ///    | 2 = set the cutoff for this recipient, was over already over-allocated
    ///    | 1 = cutoff already triggered
    ///    | 0 = not the cutoff admin address designated for this recipient
    /// @return distributionFound if triggered, will return the remaining distribution

    function triggerCutoff(address _recipient) public returns (uint8 result, uint256 distributionFound) {
        if (allocations[_recipient].cutoffEnabled == false) {
            if (msg.sender == allocations[_recipient].cutoffAdminAddress) {
                allocations[_recipient].cutoffEnabled = true;

                uint256 modifiedAllocation = allocations[_recipient].totalAllocated.sub(allocations[_recipient].cutoffTokenAmount);

                if (allocations[_recipient].amountClaimed < modifiedAllocation) {
                    // gets under-allocated distribution
                    //
                    // scenario: user has claimed 600 of 1000 tokens already, with a 10% cutoff.
                    // cutoff reduced them to 900 tokens total. so return an under-allocated (900 - 600) amount.
                    //
                    // to calculate the tokens that should be returned to the shyft core treasury that handles cutoff
                    // tokens, we:
                    //
                    // 1. take the total amount minus the cutoff, which gives us the modified allocation.
                    // 2. we know that the tokens distributed already lower than this modified allocation.
                    // 3. we know that there will be further distributions to this user.
                    // 4. therefore the tokens returned to the shyft treasury would be: "modified allocation - claimed"

                    uint256 remainingAvailableDistribution = modifiedAllocation.sub(allocations[_recipient].amountClaimed);

                    uint256 tokensToReturnToCore = allocations[_recipient].cutoffTokenAmount;
                    addCutoffTokensToCore(tokensToReturnToCore);

                    emit EVT_cutoffTriggered(_recipient, modifiedAllocation, allocations[_recipient].amountClaimed, remainingAvailableDistribution, tokensToReturnToCore);

                    //set the cutoff for this recipient, still has distribution
                    return (3, remainingAvailableDistribution);
                } else {
                    // gets over-allocated distribution
                    //
                    // scenario: user has claimed 600 of 1000 tokens already, with a 50% cutoff.
                    // cutoff reduced them to 500 tokens total. so return an over-allocated (600 - 500) amount.
                    //
                    // to calculate the tokens that should be returned to the shyft core treasury that handles cutoff
                    // tokens, we:
                    // 1. take the total amount minus the cutoff, which gives us the modified allocation.
                    // 2. we know that the tokens distributed already are higher than this modified allocation.
                    // 3. we know that there will be no further distribution to this user.
                    // 4. therefore the tokens returned to the shyft treasury would be: "total - claimed"

                    uint256 overAllocatedDistribution = allocations[_recipient].amountClaimed.sub(modifiedAllocation);

                    uint256 tokensToReturnToCore = allocations[_recipient].totalAllocated.sub(allocations[_recipient].amountClaimed);
                    addCutoffTokensToCore(tokensToReturnToCore);

                    emit EVT_cutoffTriggeredOverAllocated(_recipient, modifiedAllocation, allocations[_recipient].amountClaimed, overAllocatedDistribution, tokensToReturnToCore);

                    //set the cutoff for this recipient, was over already over-allocated
                    return (2, overAllocatedDistribution);
                }
            } else {
                //cutoff already triggered
                return (1, 0);
            }
        } else {
            //not the cutoff admin address designated for this recipient
            return (0, 0);
        }
    }


    /// @param _recipient The address of the recipient.
    /// @param _currentDistributionTime The distribution time to calculate the cycle with.
    /// @dev Gets the current cycle number for the recipient at the specified distribution time.
    /// @return curCycle the current distribution cycle for this recipient at the specified distribution time.

    function getCurrentCycleNumber(address _recipient, uint256 _currentDistributionTime) public view returns(uint256 curCycle) {
        uint256 foundCycle = 0;

        distributionTable storage distTable = distributionHashToTableMapping[allocations[_recipient].distributionTableHash];

        // check whether the last cycle has already ended.
        if (distTable.cyclesArray[distTable.cyclesArray.length - 1].timePeriodEnd < _currentDistributionTime) {
            return distTable.cyclesArray.length - 1;
        } else {
            for (uint256 i = 0; i < distTable.cyclesArray.length; i++) {
                bool distributionCycleMatches = (distTable.cyclesArray[i].timePeriodStart < _currentDistributionTime &&
                                                 distTable.cyclesArray[i].timePeriodEnd >= _currentDistributionTime);

                if (distributionCycleMatches == true) {
                    foundCycle = i;
                    break;
                }
            }
        }

        return foundCycle;
    }

    /// @param _recipient The address of the recipient.
    /// @param _timePeriodStart The start of the time period to calculate.
    /// @param _timePeriodEnd The end of the time period to calculate.
    /// @param _percentTokens_fixedPoint The percentage (in 64.64 floating point format).
    /// @param _prevCyclesPercent The previous cycle's percentage (cumulative for all previous cycles).
    /// @param _referenceTime The reference time for the calculation.
    /// @dev An internal function to help calculate the new total to be able to be claimed.
    /// @return result the new total claimed

    function calculateNewTotal(address _recipient, uint256 _timePeriodStart, uint256 _timePeriodEnd, int128 _percentTokens_fixedPoint, int128 _prevCyclesPercent, uint256 _referenceTime) internal view returns(uint256 result) {
        int128 curCyclePercent = ABDKMath64x64.divi(int256(((_referenceTime.sub(allocations[_recipient].endCliff).sub(_timePeriodStart)))), int256(_timePeriodEnd.sub(_timePeriodStart)));

        int128 totalPercentOfUsersTokens = ABDKMath64x64.add(_prevCyclesPercent, ABDKMath64x64.mul(_percentTokens_fixedPoint, curCyclePercent));

        uint256 tokensAllocated = allocations[_recipient].totalAllocated;

        if (allocations[_recipient].cutoffEnabled == true) {
            tokensAllocated = tokensAllocated.sub(allocations[_recipient].cutoffTokenAmount);
        }

        bytes16 quadFrom64x64TotalPercentOfUsersTokens = ABDKMathQuad.from64x64(totalPercentOfUsersTokens);

        //@note: algo: newTotal = (_recipient's) totalAllocated * (_percentTokens_fixedPoint * (_prevCyclesPercent + curCyclePercent))
        uint256 newTotalClaimed = ABDKMathQuad.toUInt(ABDKMathQuad.mul(ABDKMathQuad.fromUInt(tokensAllocated), quadFrom64x64TotalPercentOfUsersTokens));

        //the new total claimed
        return newTotalClaimed;
    }

    /// @param _recipient The address of the recipient.
    /// @param _referenceTime The reference time for the calculation.
    /// @dev Gets the tokens available to be claimed for this recipient.
    /// @return result
    ///    | 3 = got tokens claimed
    ///    | 2 = already claimed all tokens possible thus far (requires more time to pass)
    ///    | 1 = already claimed all tokens possible
    ///    | 0 = block timestamp invalid
    /// @return tokensTransferred the amount of tokens transferred (in total, including previously claimed tokens)
    /// @return tokensReceived the amount of tokens received (total tokens - previously claimed)
    /// @return currentCycleNumber the current distribution cycle number for this recipient

    function getTokensAvailable(address _recipient, uint256 _referenceTime) public view returns (uint8 result, uint256 tokensTransferred, uint256 tokensReceived, uint256 currentCycleNumber) {
        if (_referenceTime > allocations[_recipient].endCliff) {
            uint256 tokensAllocated = allocations[_recipient].totalAllocated;

            if (allocations[_recipient].cutoffEnabled == true) {
                tokensAllocated = tokensAllocated.sub(allocations[_recipient].cutoffTokenAmount);
            }

            if (allocations[_recipient].amountClaimed < tokensAllocated) {
                uint256 newTotalClaimed;
                uint256 cycleNumber;

                //check whether the reference time is above the cliff + vest period, if so the calculations are simpler
                if (_referenceTime > allocations[_recipient].endVesting) {
                    newTotalClaimed = tokensAllocated.sub(allocations[_recipient].amountClaimed);

                    //it's the last cycle
                    distributionTable storage distTable = distributionHashToTableMapping[allocations[_recipient].distributionTableHash];
                    cycleNumber = distTable.cyclesArray.length - 1;
                } else {
                    // from start of cliff
                    cycleNumber = getCurrentCycleNumber(_recipient, _referenceTime.sub(allocations[_recipient].endCliff));

                    //default to zero percent for the first cycle
                    int128 prevCyclesPercent = 0;

                    distributionCycle storage curCycle = distributionHashToTableMapping[allocations[_recipient].distributionTableHash].cyclesArray[cycleNumber];

                    // integrate the previous total percents if cycleNumber > 0
                    if (cycleNumber > 0) {
                        prevCyclesPercent = distributionHashToTableMapping[allocations[_recipient].distributionTableHash].totalPercentAtEndOfCycleArray_fixedPoint[cycleNumber - 1];
                    }

                    newTotalClaimed = calculateNewTotal(_recipient, curCycle.timePeriodStart, curCycle.timePeriodEnd, curCycle.percentTokens_fixedPoint, prevCyclesPercent, _referenceTime);
                }

                // check whether the new total to be claimed is higher than the current amount claimed (can occur with cutoffs)
                if (newTotalClaimed > allocations[_recipient].amountClaimed) {
                    //got tokens claimed
                    return (3, newTotalClaimed, newTotalClaimed.sub(allocations[_recipient].amountClaimed), cycleNumber);
                } else {
                    //already claimed all tokens possible thus far (requires more time to pass)
                    return (2, newTotalClaimed, 0, cycleNumber);
                }
            } else {
                //already claimed all tokens possible
                return (1, 0, 0, 0);
            }
        } else {
            //block timestamp invalid
            return (0, 0, 0, 0);
        }
    }

    /// @param _recipient The address of the recipient.
    /// @dev Allows a user to claim their allocated tokens. *Any* address can perform the claim on *any* recipient for the purposes of abstracting the gas cost for those recipients (ie an external party can pay for the gas of the claim function, for their client).
    /// @notice In any case where there has been an attempt to transfer tokens, this function will revert() if there is an error in the sending/claiming process.
    /// @return success
    ///    | true = claimed tokens successfully
    ///    | false = error in sending, or preconditions not met (see "result")
    /// @return result
    ///    | (any number) = (success) the number of tokens that have been claimed
    ///    | 3 = (error) already claimed all available tokens from entire vesting period
    ///    | 2 = (error) block timestamp is lower than cliff
    ///    | 1 = (error) already claimed all tokens possible thus far (requires more time to pass)
    ///    | 0 = (error) could not get tokens allocated
    /// @return timeStamp the current block timestamp

    function claimTokens(address _recipient) public returns (bool success, uint256 result, uint256 timeStamp) {
        uint256 tokensAllocated = allocations[_recipient].totalAllocated;

        if (allocations[_recipient].cutoffEnabled == true) {
            tokensAllocated = tokensAllocated.sub(allocations[_recipient].cutoffTokenAmount);
        }

        if (allocations[_recipient].amountClaimed >= tokensAllocated) {
            //already claimed all available tokens from entire vesting period
            return (false, 3, 0);
        }

        if (block.timestamp < allocations[_recipient].endCliff) {
            //block timestamp is lower than cliff
            return (false, 2, 0);
        }

        require(block.timestamp >= startTime);

        // Calculate new claimed amounts
        uint256 newTotalClaimed;
        if (allocations[_recipient].endVesting > block.timestamp) {
            // get tokens available for distribution (including already allocated ones).
            (uint8 getTokensResult, uint256 tokensAvailable, , ) = getTokensAvailable(_recipient, block.timestamp);

            if (getTokensResult != 3) {
                if (getTokensResult == 2) {
                    //already claimed all tokens possible thus far (requires more time to pass)
                    return (false, 1, 0);
                } else {
                    //could not get tokens allocated
                    return (false, 0, 0);
                }
            } else {
                newTotalClaimed = tokensAvailable;
            }

        } else {
            // Transfer the total amount less previously claimed tokens
            newTotalClaimed = tokensAllocated;
        }

        // Amount to be transferred
        uint256 transferAmount = newTotalClaimed.sub(allocations[_recipient].amountClaimed);

        // Update allocations once transfer completed
        allocations[_recipient].amountClaimed = newTotalClaimed;

        totalClaimed = totalClaimed.add(transferAmount);

        if (transferTokenMode == true) {
            IShyftKycContractRegistry kycContractRegistry = IShyftKycContractRegistry(kycContractRegistryAddress);

            //@note: only transfers out to the first contract, which has a balance outstanding of the totality of the
            // distribution amount.

            IShyftKycContract kycContract = IShyftKycContract(kycContractRegistry.getContractAddressOfVersion(0));

            bool contractTxSuccess = kycContract.transfer(_recipient, transferAmount);

            // need to revert due to transactional logic.
            if (contractTxSuccess == false) {
                revert();
            }
        } else {
            // not limiting gas here so you can transfer to contracts etc.
            (bool nativeTxSuccess, ) = _recipient.call{value: transferAmount}("");

            // need to revert due to transactional logic.
            if (nativeTxSuccess == false) {
                revert();
            }
        }

        emit EVT_shyftClaimed(_recipient, transferAmount, newTotalClaimed, totalClaimed, block.timestamp);

        //claimed tokens successfully
        return (true, transferAmount, block.timestamp);
    }

    /// @param _address The address of the KYC contract registry.
    /// @dev Sets the KYC contract registry address so that (in the case where this is a token vs native fuel distribution) the claim process can correctly identify the contract it is distributing to.
    /// @return result
    ///    | true = set registry contract successfully
    ///    | false = has already been set, or not the owner

    function setKycContractRegistryAddress(address _address) public returns (bool result) {
        if (kycContractRegistryAddress == address(0) && msg.sender == owner) {
            kycContractRegistryAddress = _address;

            //set registry contract successfully
            return true;
        } else {

            //has already been set, or not the owner
            return false;
        }
    }

    /// @param _address The address of the Shyft Core token address.
    /// @dev Sets the Shyft Core token address so that any cutoff tokens are properly allocated back to a Shyft Core wallet.
    /// @return result
    ///    | true = set shyft core token address successfully
    ///    | false = has already been set, or not the owner

    function setShyftCoreTokenAddress(address payable _address) public returns (bool result) {
        if (shyftCoreTokenAddress == address(0) && msg.sender == owner) {
            shyftCoreTokenAddress = _address;

            //set shyft core token address successfully
            return true;
        } else {

            //has already been set, or not the owner
            return false;
        }
    }

    /// @dev Disables the ability of the Owner (initial deployer) of this contract to set any new allocations. The call can only be completed correctly by the Owner.
    /// @return result
    ///    | true = completed disabling new allocations
    ///    | false = not owner

    function disableSettingNewAllocations() public returns (bool result) {
        if (msg.sender == owner) {
            owner = address(0);

            // completed disabling new allocations
            return true;
        } else {
            // not owner
            return false;
        }
    }
}