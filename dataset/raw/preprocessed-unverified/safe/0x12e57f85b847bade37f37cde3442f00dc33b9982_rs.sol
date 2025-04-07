/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Kevin Park, Email: [emailÂ protected], Twitter: @tenQkp, Telegram: @freeparkingcapital Discord: tenQ#3843
* www.fruitful.fi
* https://twitter.com/FruitfulFi
* www.loveboat.exchange
* https://twitter.com/LoveBoatDEX
* fruitful.eth
* Credit: Nick Mudge
*
* DiamondLove: A multichain decentralized protocol for trading and providing rewards.
* 
* Implementation of an ERC20 governance token that can govern itself and a project
* using the Diamond Standard.
/******************************************************************************/

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






// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds






contract DiamondCutFacet is IDiamondCut {
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = LibDiamond.addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        LibDiamond.initializeDiamondCut(_init, _calldata);
    }
}

contract DiamondLoupe is IDiamondLoupe, IERC165 {
    // Diamond Loupe Functions
    ////////////////////////////////////////////////////////////////////
    /// These functions are expected to be called frequently by tools.

    /// @notice Gets all facets and their selectors.
    /// @return facets_ Facet
    function facets() external view override returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facets_ = new Facet[](ds.selectorCount);
        uint8[] memory numFacetSelectors = new uint8[](ds.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;
        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facetAddress_ = address(bytes20(ds.facets[selector]));
                bool continueLoop = false;
                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facets_[facetIndex].facetAddress == facetAddress_) {
                        facets_[facetIndex].functionSelectors[numFacetSelectors[facetIndex]] = selector;
                        // probably will never have more than 256 functions from one facet contract
                        require(numFacetSelectors[facetIndex] < 255);
                        numFacetSelectors[facetIndex]++;
                        continueLoop = true;
                        break;
                    }
                }
                if (continueLoop) {
                    continueLoop = false;
                    continue;
                }
                facets_[numFacets].facetAddress = facetAddress_;
                facets_[numFacets].functionSelectors = new bytes4[](ds.selectorCount);
                facets_[numFacets].functionSelectors[0] = selector;
                numFacetSelectors[numFacets] = 1;
                numFacets++;
            }
        }
        for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
            uint256 numSelectors = numFacetSelectors[facetIndex];
            bytes4[] memory selectors = facets_[facetIndex].functionSelectors;
            // setting the number of selectors
            assembly {
                mstore(selectors, numSelectors)
            }
        }
        // setting the number of facets
        assembly {
            mstore(facets_, numFacets)
        }
    }

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return _facetFunctionSelectors The selectors associated with a facet address.
    function facetFunctionSelectors(address _facet) external view override returns (bytes4[] memory _facetFunctionSelectors) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numSelectors;
        _facetFunctionSelectors = new bytes4[](ds.selectorCount);
        uint256 selectorIndex;
        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facet = address(bytes20(ds.facets[selector]));
                if (_facet == facet) {
                    _facetFunctionSelectors[numSelectors] = selector;
                    numSelectors++;
                }
            }
        }
        // Set the number of selectors in the array
        assembly {
            mstore(_facetFunctionSelectors, numSelectors)
        }
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddresses_ = new address[](ds.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;
        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facetAddress_ = address(bytes20(ds.facets[selector]));
                bool continueLoop = false;
                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facetAddress_ == facetAddresses_[facetIndex]) {
                        continueLoop = true;
                        break;
                    }
                }
                if (continueLoop) {
                    continueLoop = false;
                    continue;
                }
                facetAddresses_[numFacets] = facetAddress_;
                numFacets++;
            }
        }
        // Set the number of facet addresses in the array
        assembly {
            mstore(facetAddresses_, numFacets)
        }
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddress_ = address(bytes20(ds.facets[_functionSelector]));
    }

    // This implements ERC-165.
    function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[_interfaceId];
    }
}

contract LoveToken {
    /**
     * @dev Returns the name of the token.
     */
    function name() public pure returns (string memory) {
        return "Love";
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure returns (string memory) {
        return "LOVE";
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public pure returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return LibGovStorage.governanceStorage().totalSupply;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param _account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address _account) external view returns (uint256) {
        return LibGovStorage.governanceStorage().balances[_account];
    }

    /// @notice Minimum time between mints
    uint32 public constant minimumTimeBetweenMints = 1 days * 365;

    /// @notice Cap on the percentage of totalSupply that can be minted at each mint
    uint8 public constant mintCap = 2;

    /// @notice An event thats emitted when the loveMinter address is changed
    event MinterChanged(address loveMinter, address newMinter);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function mintingAllowedAfter() public view returns (uint256) {
        return LibGovStorage.governanceStorage().mintingAllowedAfter;
    }

    /**
     * @notice Change the loveMinter address
     * @param _loveMinter The address of the new loveMinter
     */
    function setMinter(address _loveMinter) external {
        require(msg.sender == LibGovStorage.governanceStorage().loveMinter, "Love:setMinter: only the minter can change the minter address");

        emit MinterChanged(LibGovStorage.governanceStorage().loveMinter, _loveMinter);
        LibGovStorage.governanceStorage().loveMinter = _loveMinter;
    }

    /**
     * @notice Mint new tokens
     * @param _dst The address of the destination account
     * @param _rawAmount The number of tokens to be minted
     */
    function mint(address _dst, uint256 _rawAmount) external {
        require(msg.sender == LibGovStorage.governanceStorage().loveMinter, "Love:mint: only the minter can mint");
        require(block.timestamp >= LibGovStorage.governanceStorage().mintingAllowedAfter, "Love:mint: minting not allowed yet");
        require(_dst != address(0), "Love:mint: cannot transfer to the zero address");

        // record the mint
        LibGovStorage.governanceStorage().mintingAllowedAfter = SafeMath.add(block.timestamp, minimumTimeBetweenMints);

        // mint the amount
        uint96 amount = safe96(_rawAmount, "Love:mint: amount exceeds 96 bits");
        require(
            amount <= SafeMath.div(SafeMath.mul(LibGovStorage.governanceStorage().totalSupply, mintCap), 100),
            "Love:mint: exceeded mint cap"
        );
        LibGovStorage.governanceStorage().totalSupply = safe96(
            SafeMath.add(LibGovStorage.governanceStorage().totalSupply, amount),
            "Love:mint: totalSupply exceeds 96 bits"
        );

        // transfer the amount to the recipient
        LibGovStorage.governanceStorage().balances[_dst] = add96(
            LibGovStorage.governanceStorage().balances[_dst],
            amount,
            "Love:mint: transfer amount overflows"
        );
        emit Transfer(address(0), _dst, amount);
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param _to The address of the destination account
     * @param _value The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address _to, uint256 _value) external returns (bool) {
        uint96 value = safe96(_value, "Love:transfer: value exceeds 96 bits");
        _transferFrom(msg.sender, _to, value);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param _from The address of the source account
     * @param _to The address of the destination account
     * @param _rawValue The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _rawValue
    ) external returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = LibGovStorage.governanceStorage().approved[_from][spender];
        uint96 value = safe96(_rawValue, "Love: value exceeds 96 bits");

        if (spender != _from && spenderAllowance != type(uint96).max) {
            uint96 newSpenderAllowance = sub96(spenderAllowance, value, "Love:transferFrom: value exceeds spenderAllowance");
            LibGovStorage.governanceStorage().approved[_from][spender] = newSpenderAllowance;
            emit Approval(_from, spender, newSpenderAllowance);
        }

        _transferFrom(_from, _to, value);
        return true;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint96 _value
    ) internal {
        require(_from != address(0), "Love:_transferFrom: transfer from the zero address");
        require(_to != address(0), "Love:_transferFrom: transfer to the zero address");
        require(_value <= LibGovStorage.governanceStorage().balances[_from], "Love:_transferFrom: transfer amount exceeds balance");
        LibGovStorage.governanceStorage().balances[_from] = sub96(
            LibGovStorage.governanceStorage().balances[_from],
            _value,
            "Love:_transferFrom: value exceeds balance"
        );
        LibGovStorage.governanceStorage().balances[_to] = add96(
            LibGovStorage.governanceStorage().balances[_to],
            _value,
            "Love:_transferFrom: value overflows"
        );
        emit Transfer(_from, _to, _value);
    }

    /**
     * @notice Approve `_spender` to transfer up to `_rawValue` from `src`
     * @dev This will overwrite the approval _rawValue for `_spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param _spender The address of the account which may transfer tokens
     * @param _rawValue The number of tokens that are approved
     * returns success whether or not the approval succeeded
     */
    function approve(address _spender, uint256 _rawValue) external returns (bool success) {
        uint96 value = safe96(_rawValue, "Love: value exceeds 96 bits");
        LibGovStorage.governanceStorage().approved[msg.sender][_spender] = value;
        emit Approval(msg.sender, _spender, value);
        success = true;
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
}

contract DiamondLove {
    /// @dev Placing these events here in order to emit the ERC20 standard Transfer event at DiamondLove contract deployment
    /// @notice An event thats emitted when the loveMinter address is changed
    event MinterChanged(address loveMinter, address newMinter);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        // Set total supply cap. The token supply cannot grow past this.
        gs.totalSupplyCap = 100_000_000e18;
        gs.totalSupply = 1_000_000e18;
        gs.loveMinter = 0x287300059f50850d098b974AbE59106c4F52c989; // Initial address with the permission to mint Love tokens.
        emit MinterChanged(address(0), gs.loveMinter);
        gs.loveBoat = 0x287300059f50850d098b974AbE59106c4F52c989; // The address the token genesis minting will be sent to.

        // No minting is allowed for about a year after the contract is deployed. Only 2% of the total supply can be minted every year.
        gs.mintingAllowedAfter = block.timestamp + (1 days * 365);

        // Initially mint tokens to gs.loveBoat. This is the Fruitful Labs EOA. The vesting contract will be deployed on Polygon L2.
        gs.balances[gs.loveBoat] = gs.totalSupply;
        emit Transfer(address(0), gs.loveBoat, gs.balances[gs.loveBoat]);

        // Set DiamondLove contract owner
        LibDiamond.setContractOwner(0x287300059f50850d098b974AbE59106c4F52c989);

        // Deploy facets
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupe diamondLoupe = new DiamondLoupe();
        LoveToken loveToken = new LoveToken();

        // Create array of facet cuts (DiamondCutFacet, DiamondLoupe, LoveToken)
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // Add DiamondCutFacet
        bytes4[] memory funcSDiamondCut = new bytes4[](1);
        funcSDiamondCut[0] = DiamondCutFacet.diamondCut.selector;

        cut[0] = IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Add, funcSDiamondCut);

        // Add DiamondLoupe
        bytes4[] memory funcSDiamondLoupe = new bytes4[](5);
        funcSDiamondLoupe[0] = IDiamondLoupe.facetFunctionSelectors.selector;
        funcSDiamondLoupe[1] = IDiamondLoupe.facets.selector;
        funcSDiamondLoupe[2] = IDiamondLoupe.facetAddress.selector;
        funcSDiamondLoupe[3] = IDiamondLoupe.facetAddresses.selector;
        funcSDiamondLoupe[4] = IERC165.supportsInterface.selector;

        cut[1] = IDiamondCut.FacetCut(address(diamondLoupe), IDiamondCut.FacetCutAction.Add, funcSDiamondLoupe);

        // Add LoveToken
        bytes4[] memory funcSLoveToken = new bytes4[](11);
        funcSLoveToken[0] = LoveToken.name.selector;
        funcSLoveToken[1] = LoveToken.symbol.selector;
        funcSLoveToken[2] = LoveToken.decimals.selector;
        funcSLoveToken[3] = LoveToken.totalSupply.selector;
        funcSLoveToken[4] = LoveToken.balanceOf.selector;
        funcSLoveToken[5] = LoveToken.mintingAllowedAfter.selector;
        funcSLoveToken[6] = LoveToken.setMinter.selector;
        funcSLoveToken[7] = LoveToken.mint.selector;
        funcSLoveToken[8] = LoveToken.transfer.selector;
        funcSLoveToken[9] = LoveToken.transferFrom.selector;
        funcSLoveToken[10] = LoveToken.approve.selector;

        cut[2] = IDiamondCut.FacetCut(address(loveToken), IDiamondCut.FacetCutAction.Add, funcSLoveToken);

        LibDiamond.diamondCut(cut, address(0), new bytes(0));

        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), "DiamondLove: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}