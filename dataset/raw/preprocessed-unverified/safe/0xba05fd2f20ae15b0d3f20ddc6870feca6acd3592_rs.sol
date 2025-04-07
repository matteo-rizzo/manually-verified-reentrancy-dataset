/**
 *Submitted for verification at Etherscan.io on 2021-09-05
*/

pragma solidity 0.8.6;




abstract contract IERC20WithCheckpointing {
    function balanceOf(address _owner) public view virtual returns (uint256);

    function balanceOfAt(address _owner, uint256 _blockNumber)
        public
        view
        virtual
        returns (uint256);

    function totalSupply() public view virtual returns (uint256);

    function totalSupplyAt(uint256 _blockNumber) public view virtual returns (uint256);
}

abstract contract IIncentivisedVotingLockup is IERC20WithCheckpointing {
    function getLastUserPoint(address _addr)
        external
        view
        virtual
        returns (
            int128 bias,
            int128 slope,
            uint256 ts
        );

    function createLock(uint256 _value, uint256 _unlockTime) external virtual;

    function withdraw() external virtual;

    function increaseLockAmount(uint256 _value) external virtual;

    function increaseLockLength(uint256 _unlockTime) external virtual;

    function eject(address _user) external virtual;

    function expireContract() external virtual;

    function claimReward() public virtual;

    function earned(address _account) public view virtual returns (uint256);
}





contract ModuleKeys {
    // Governance
    // ===========
    // keccak256("Governance");
    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    //keccak256("Staking");
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    //keccak256("ProxyAdmin");
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    // mStable
    // =======
    // keccak256("OracleHub");
    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    // keccak256("Manager");
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    //keccak256("Recollateraliser");
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    //keccak256("MetaToken");
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    // keccak256("SavingsManager");
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    // keccak256("Liquidator");
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
    // keccak256("InterestValidator");
    bytes32 internal constant KEY_INTEREST_VALIDATOR =
        0xc10a28f028c7f7282a03c90608e38a4a646e136e614e4b07d119280c5f7f839f;
}



abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    /**
     * @dev Initialization function for upgradable proxy contracts
     * @param _nexus Nexus contract address
     */
    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
    }

    /**
     * @dev Modifier to allow function calls only from the Governance.
     *      Governance is either Governor address or Governance address.
     */
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    /**
     * @dev Returns Governor address from the Nexus
     * @return Address of Governor Contract
     */
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    /**
     * @dev Returns Governance Module address from the Nexus
     * @return Address of the Governance (Phase 2)
     */
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    /**
     * @dev Return SavingsManager Module address from the Nexus
     * @return Address of the SavingsManager Module contract
     */
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }

    /**
     * @dev Return Liquidator Module address from the Nexus
     * @return  Address of the Liquidator Module contract
     */
    function _liquidator() internal view returns (address) {
        return nexus.getModule(KEY_LIQUIDATOR);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
// Internal
/**
 * @title  BoostDirectorV2
 * @author mStable
 * @notice Supports the directing of balance from multiple StakedToken contracts up to X accounts
 * @dev    Uses a bitmap to store the id's of a given users chosen vaults in a gas efficient manner.
 */
contract BoostDirectorV2 is IBoostDirector, ImmutableModule {
    event Directed(address user, address boosted);
    event RedirectedBoost(address user, address boosted, address replaced);
    event Whitelisted(address vaultAddress, uint8 vaultId);

    event StakedTokenAdded(address token);
    event StakedTokenRemoved(address token);

    event BalanceDivisorChanged(uint256 newDivisor);

    // Read the vMTA balance from here
    IERC20[] public stakedTokenContracts;

    // Whitelisted vaults set by governance (only these vaults can read balances)
    uint8 private vaultCount;
    // Vault address -> internal id for tracking
    mapping(address => uint8) public _vaults;
    // uint128 packed with up to 16 uint8's. Each uint is a vault ID
    mapping(address => uint128) public _directedBitmap;
    // Divisor for voting powers to make more reasonable in vault
    uint256 private balanceDivisor;

    /***************************************
                    ADMIN
    ****************************************/

    // Simple constructor
    constructor(address _nexus) ImmutableModule(_nexus) {
        balanceDivisor = 12;
    }

    /**
     * @dev Initialize function - simply sets the initial array of whitelisted vaults
     */
    function initialize(address[] calldata _newVaults) external {
        require(vaultCount == 0, "Already initialized");
        _whitelistVaults(_newVaults);
    }

    /**
     * @dev Adds a staked token to the list, if it does not yet exist
     */
    function addStakedToken(address _stakedToken) external onlyGovernor {
        uint256 len = stakedTokenContracts.length;
        for (uint256 i = 0; i < len; i++) {
            require(address(stakedTokenContracts[i]) != _stakedToken, "StakedToken already added");
        }
        stakedTokenContracts.push(IERC20(_stakedToken));

        emit StakedTokenAdded(_stakedToken);
    }

    /**
     * @dev Removes a staked token from the list
     */
    function removeStakedTkoen(address _stakedToken) external onlyGovernor {
        uint256 len = stakedTokenContracts.length;
        for (uint256 i = 0; i < len; i++) {
            // If we find it, then swap it with the last element and delete the end
            if (address(stakedTokenContracts[i]) == _stakedToken) {
                stakedTokenContracts[i] = stakedTokenContracts[len - 1];
                stakedTokenContracts.pop();
                emit StakedTokenRemoved(_stakedToken);
                return;
            }
        }
    }

    /**
     * @dev Sets the divisor, by which all balances will be scaled down
     */
    function setBalanceDivisor(uint256 _newDivisor) external onlyGovernor {
        require(_newDivisor != balanceDivisor, "No change in divisor");
        require(_newDivisor < 15, "Divisor too large");

        balanceDivisor = _newDivisor;

        emit BalanceDivisorChanged(_newDivisor);
    }

    /**
     * @dev Whitelist vaults - only callable by governance. Whitelists vaults, unless they
     * have already been whitelisted
     */
    function whitelistVaults(address[] calldata _newVaults) external override onlyGovernor {
        _whitelistVaults(_newVaults);
    }

    /**
     * @dev Takes an array of newVaults. For each, determines if it is already whitelisted.
     * If not, then increment vaultCount and same the vault with new ID
     */
    function _whitelistVaults(address[] calldata _newVaults) internal {
        uint256 len = _newVaults.length;
        require(len > 0, "Must be at least one vault");
        for (uint256 i = 0; i < len; i++) {
            uint8 id = _vaults[_newVaults[i]];
            require(id == 0, "Vault already whitelisted");

            vaultCount += 1;
            _vaults[_newVaults[i]] = vaultCount;

            emit Whitelisted(_newVaults[i], vaultCount);
        }
    }

    /***************************************
                      Vault
    ****************************************/

    /**
     * @dev Gets the balance of a user that has been directed to the caller (a vault).
     * If the user has not directed to this vault, or there are less than 6 directed,
     * then add this to the list
     * @param _user     Address of the user for which to get balance
     * @return bal      Directed balance
     */
    function getBalance(address _user) external override returns (uint256 bal) {
        // Get vault details
        uint8 id = _vaults[msg.sender];
        // If vault has not been whitelisted, just return zero
        if (id == 0) return 0;

        // Get existing bitmap and balance
        uint128 bitmap = _directedBitmap[_user];
        uint256 len = stakedTokenContracts.length;
        for (uint256 i = 0; i < len; i++) {
            bal += stakedTokenContracts[i].balanceOf(_user);
        }

        bal /= balanceDivisor;

        (bool isWhitelisted, uint8 count, ) = _indexExists(bitmap, id);

        if (isWhitelisted) return bal;

        if (count < 6) {
            _directedBitmap[_user] = _direct(bitmap, count, id);
            emit Directed(_user, msg.sender);
            return bal;
        }

        if (count >= 6) return 0;
    }

    /**
     * @dev Directs rewards to a vault, and removes them from the old vault. Provided
     * that old is active and the new vault is whitelisted.
     * @param _old     Address of the old vault that will no longer get boosted
     * @param _new     Address of the new vault that will get boosted
     * @param _pokeNew Bool to say if we should poke the boost on the new vault
     */
    function setDirection(
        address _old,
        address _new,
        bool _pokeNew
    ) external override {
        uint8 idOld = _vaults[_old];
        uint8 idNew = _vaults[_new];

        require(idOld > 0 && idNew > 0, "Vaults not whitelisted");

        uint128 bitmap = _directedBitmap[msg.sender];
        (bool isWhitelisted, uint8 count, uint8 pos) = _indexExists(bitmap, idOld);
        require(isWhitelisted && count >= 6, "No need to replace old");

        _directedBitmap[msg.sender] = _direct(bitmap, pos, idNew);

        IBoostedVaultWithLockup(_old).pokeBoost(msg.sender);

        if (_pokeNew) {
            IBoostedVaultWithLockup(_new).pokeBoost(msg.sender);
        }

        emit RedirectedBoost(msg.sender, _new, _old);
    }

    /**
     * @dev Resets the bitmap given the new _id for _pos. Takes each uint8 in seperate and re-compiles
     */
    function _direct(
        uint128 _bitmap,
        uint8 _pos,
        uint8 _id
    ) internal pure returns (uint128 newMap) {
        // bitmap          = ... 00000000 00000000 00000011 00001010
        // pos = 1, id = 1 = 00000001
        // step            = ... 00000000 00000000 00000001 00000000
        uint8 id;
        uint128 step;
        for (uint8 i = 0; i < 6; i++) {
            unchecked {
                // id is either the one that is passed, or existing
                id = _pos == i ? _id : uint8(_bitmap >> (i * 8));
                step = uint128(uint128(id) << (i * 8));
            }
            newMap |= step;
        }
    }

    /**
     * @dev Given a 128 bit bitmap packed with 8 bit ids, should be able to filter for specific ids by moving
     * the bitmap gradually to the right and reading each 8 bit section as a uint8.
     */
    function _indexExists(uint128 _bitmap, uint8 _target)
        internal
        pure
        returns (
            bool isWhitelisted,
            uint8 count,
            uint8 pos
        )
    {
        // bitmap   = ... 00000000 00000000 00000011 00001010 // positions 1 and 2 have ids 10 and 6 respectively
        // e.g.
        // i = 1: bitmap moves 8 bits to the right
        // bitmap   = ... 00000000 00000000 00000000 00000011 // reading uint8 should return 6
        uint8 id;
        for (uint8 i = 0; i < 6; i++) {
            unchecked {
                id = uint8(_bitmap >> (i * 8));
            }
            if (id > 0) count += 1;
            if (id == _target) {
                isWhitelisted = true;
                pos = i;
            }
        }
    }
}