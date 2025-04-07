pragma solidity ^0.4.19;

contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);
    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
    function getBeneficiary() external view returns(address);
}

contract SanctuaryInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isSanctuary() public pure returns (bool);

    /// @dev generate new warrior genes
    /// @param _heroGenes Genes of warrior that have completed dungeon
    /// @param _heroLevel Level of the warrior
    /// @return the genes that are supposed to be passed down to newly arisen warrior
    function generateWarrior(uint256 _heroGenes, uint256 _heroLevel, uint256 _targetBlock, uint256 _perkId) public returns (uint256);
}

contract PVPInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isPVPProvider() external pure returns (bool);
    
    function addTournamentContender(address _owner, uint256[] _tournamentData) external payable;
    function getTournamentThresholdFee() public view returns(uint256);
    
    function addPVPContender(address _owner, uint256 _packedWarrior) external payable;
    function getPVPEntranceFee(uint256 _levelPoints) external view returns(uint256);
}

contract PVPListenerInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isPVPListener() public pure returns (bool);
    function getBeneficiary() external view returns(address);
    
    function pvpFinished(uint256[] warriorData, uint256 matchingCount) public;
    function pvpContenderRemoved(uint256 _warriorId) public;
    function tournamentFinished(uint256[] packedContenders) public;
}

contract PermissionControll {
    // This facet controls access to contract that implements it. There are four roles managed here:
    //
    // - The Admin: The Admin can reassign admin and issuer roles and change the addresses of our dependent smart
    // contracts. It is also the only role that can unpause the smart contract. It is initially
    // set to the address that created the smart contract in the CryptoWarriorCore constructor.
    //
    // - The Bank: The Bank can withdraw funds from CryptoWarriorCore and its auction and battle contracts, and change admin role.
    //
    // - The Issuer: The Issuer can release gen0 warriors to auction.
    //
    // / @dev Emited when contract is upgraded
    event ContractUpgrade(address newContract);
    
    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public adminAddress;
    address public bankAddress;
    address public issuerAddress; 
    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;
    

    // / @dev Access modifier for Admin-only functionality
    modifier onlyAdmin(){
        require(msg.sender == adminAddress);
        _;
    }

    // / @dev Access modifier for Bank-only functionality
    modifier onlyBank(){
        require(msg.sender == bankAddress);
        _;
    }
    
    /// @dev Access modifier for Issuer-only functionality
    modifier onlyIssuer(){
    		require(msg.sender == issuerAddress);
        _;
    }
    
    modifier onlyAuthorized(){
        require(msg.sender == issuerAddress ||
            msg.sender == adminAddress ||
            msg.sender == bankAddress);
        _;
    }


    // / @dev Assigns a new address to act as the Bank. Only available to the current Bank.
    // / @param _newBank The address of the new Bank
    function setBank(address _newBank) external onlyBank {
        require(_newBank != address(0));
        bankAddress = _newBank;
    }

    // / @dev Assigns a new address to act as the Admin. Only available to the current Admin.
    // / @param _newAdmin The address of the new Admin
    function setAdmin(address _newAdmin) external {
        require(msg.sender == adminAddress || msg.sender == bankAddress);
        require(_newAdmin != address(0));
        adminAddress = _newAdmin;
    }
    
    // / @dev Assigns a new address to act as the Issuer. Only available to the current Issuer.
    // / @param _newIssuer The address of the new Issuer
    function setIssuer(address _newIssuer) external onlyAdmin{
        require(_newIssuer != address(0));
        issuerAddress = _newIssuer;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/
    // / @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused(){
        require(!paused);
        _;
    }

    // / @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused{
        require(paused);
        _;
    }

    // / @dev Called by any "Authorized" role to pause the contract. Used only when
    // /  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyAuthorized whenNotPaused{
        paused = true;
    }

    // / @dev Unpauses the smart contract. Can only be called by the Admin.
    // / @notice This is public rather than external so it can be called by
    // /  derived contracts.
    function unpause() public onlyAdmin whenPaused{
        // can't unpause if contract was upgraded
        paused = false;
    }
    
    
    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyAdmin whenPaused {
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }
}



contract PausableBattle is Ownable {
    event PausePVP(bool paused);
    event PauseTournament(bool paused);
    
    bool public pvpPaused = false;
    bool public tournamentPaused = false;
    
    /** PVP */
    modifier PVPNotPaused(){
        require(!pvpPaused);
        _;
    }

    modifier PVPPaused{
        require(pvpPaused);
        _;
    }

    function pausePVP() public onlyOwner PVPNotPaused {
        pvpPaused = true;
        PausePVP(true);
    }

    function unpausePVP() public onlyOwner PVPPaused {
        pvpPaused = false;
        PausePVP(false);
    }
    
    /** Tournament */
    modifier TournamentNotPaused(){
        require(!tournamentPaused);
        _;
    }

    modifier TournamentPaused{
        require(tournamentPaused);
        _;
    }

    function pauseTournament() public onlyOwner TournamentNotPaused {
        tournamentPaused = true;
        PauseTournament(true);
    }

    function unpauseTournament() public onlyOwner TournamentPaused {
        tournamentPaused = false;
        PauseTournament(false);
    }
    
}

contract Pausable is Ownable {
    event Pause();

    event Unpause();

    bool public paused = false;

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused(){
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused{
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}





contract CryptoWarriorBase is PermissionControll, PVPListenerInterface {

    /*** EVENTS ***/

    /// @dev The Arise event is fired whenever a new warrior comes into existence. This obviously
    ///  includes any time a warrior is created through the ariseWarrior method, but it is also called
    ///  when a new miner warrior is created.
    event Arise(address owner, uint256 warriorId, uint256 identity);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a warrior
    ///  ownership is assigned, including dungeon rewards.
    event Transfer(address from, address to, uint256 tokenId);

    /*** CONSTANTS ***/
    
	uint256 public constant IDLE = 0;
    uint256 public constant PVE_BATTLE = 1;
    uint256 public constant PVP_BATTLE = 2;
    uint256 public constant TOURNAMENT_BATTLE = 3;
    
    //max pve dungeon level
    uint256 public constant MAX_LEVEL = 25;
    //how many points is needed to get 1 level
    uint256 public constant POINTS_TO_LEVEL = 10;
    
    /// @dev A lookup table contains PVE dungeon level requirements, each time warrior
    /// completes dungeon, next level requirement is set, until 25lv (250points) is reached.
    uint32[6] public dungeonRequirements = [
        uint32(10),
        uint32(30),
        uint32(60),
        uint32(100),
        uint32(150),
        uint32(250)
    ];

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Warrior struct for all Warriors in existence. The ID
    ///  of each warrior is actually an index of this array.
    DataTypes.Warrior[] warriors;

    /// @dev A mapping from warrior IDs to the address that owns them. All warriors have
    ///  some valid owner address, even miner warriors are created with a non-zero owner.
    mapping (uint256 => address) public warriorToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownersTokenCount;

    /// @dev A mapping from warrior IDs to an address that has been approved to call
    ///  transferFrom(). Each Warrior can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public warriorToApproved;
    
    // Mapping from owner to list of owned token IDs
    mapping (address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;


    /// @dev The address of the ClockAuction contract that handles sales of warriors. This
    ///  same contract handles both peer-to-peer sales as well as the miner sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;
    
    
    /// @dev Assigns ownership of a specific warrior to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // When creating new warriors _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            _clearApproval(_tokenId);
            _removeTokenFrom(_from, _tokenId);
        }
        _addTokenTo(_to, _tokenId);
        
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }
    
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        // Since the number of warriors is capped to '1 000 000' we can't overflow this
        ownersTokenCount[_to]++;
        // transfer ownership
        warriorToOwner[_tokenId] = _to;
        
        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
    }
    
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        //
        ownersTokenCount[_from]--;
        
        warriorToOwner[_tokenId] = address(0);
        
        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = ownedTokens[_from].length - 1;
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];
    
        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
        
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list
        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }
    
    function _clearApproval(uint256 _tokenId) internal {
        if (warriorToApproved[_tokenId] != address(0)) {
            // clear any previously approved ownership exchange
            warriorToApproved[_tokenId] = address(0);
        }
    }
    
    function _createWarrior(uint256 _identity, address _owner, uint256 _cooldown, uint256 _level, uint256 _rating, uint256 _dungeonIndex)
        internal
        returns (uint256) {
        	    
        DataTypes.Warrior memory _warrior = DataTypes.Warrior({
            identity : _identity,
            cooldownEndBlock : uint64(_cooldown),
            level : uint64(_level),//uint64(10),
            rating : int64(_rating),//int64(100),
            action : uint32(IDLE),
            dungeonIndex : uint32(_dungeonIndex)//uint32(0)
        });
        uint256 newWarriorId = warriors.push(_warrior) - 1;
        
        // let's just be 100% sure we never let this happen.
        require(newWarriorId == uint256(uint32(newWarriorId)));
        
        // emit the arise event
        Arise(_owner, newWarriorId, _identity);
        
        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newWarriorId);

        return newWarriorId;
    }
    

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyAuthorized {
        secondsPerBlock = secs;
    }
}

contract WarriorTokenImpl is CryptoWarriorBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "CryptoWarriors";
    string public constant symbol = "CW";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9f40b779));

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /** @dev Checks if a given address is the current owner of the specified Warrior tokenId.
     * @param _claimant the address we are validating against.
     * @param _tokenId warrior id
     */
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return _claimant != address(0) && warriorToOwner[_tokenId] == _claimant;    
    }

    function _ownerApproved(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return _claimant != address(0) &&//0 address means token is burned 
        warriorToOwner[_tokenId] == _claimant && warriorToApproved[_tokenId] == address(0);    
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Warrior.
    /// @param _claimant the address we are confirming warrior is approved for.
    /// @param _tokenId warrior id
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return warriorToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Warriors on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        warriorToApproved[_tokenId] = _approved;
    }

    /// @notice Returns the number of Warriors(tokens) owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownersTokenCount[_owner];
    }

    /// @notice Transfers a Warrior to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoWarriors specifically) or your Warrior may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Warrior to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(address _to, uint256 _tokenId) external whenNotPaused {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any warriors (except very briefly
        // after a miner warrior is created and before it goes on auction).
        require(_to != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of warriors
        // through the allow + transferFrom flow.
        require(_to != address(saleAuction));
        // You can only send your own warrior.
        require(_owns(msg.sender, _tokenId));
        // Only idle warriors are allowed 
        require(warriors[_tokenId].action == IDLE);

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    /// @notice Grant another address the right to transfer a specific Warrior via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Warrior that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(address _to, uint256 _tokenId) external whenNotPaused {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));
        // Only idle warriors are allowed 
        require(warriors[_tokenId].action == IDLE);

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Warrior owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Warrior to be transfered.
    /// @param _to The address that should take ownership of the Warrior. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Warrior to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any warriors (except very briefly
        // after a miner warrior is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        // Only idle warriors are allowed 
        require(warriors[_tokenId].action == IDLE);

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Warriors currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint256) {
        return warriors.length;
    }

    /// @notice Returns the address currently assigned ownership of a given Warrior.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        require(_tokenId < warriors.length);
        owner = warriorToOwner[_tokenId];
    }

    /// @notice Returns a list of all Warrior IDs assigned to an address.
    /// @param _owner The owner whose Warriors we are interested in.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        return ownedTokens[_owner];
    }
    
    function tokensOfOwnerFromIndex(address _owner, uint256 _fromIndex, uint256 _count) external view returns(uint256[] memory ownerTokens) {
        require(_fromIndex < balanceOf(_owner));
        uint256[] storage tokens = ownedTokens[_owner];
        //        
        uint256 ownerBalance = ownersTokenCount[_owner];
        uint256 lenght = (ownerBalance - _fromIndex >= _count ? _count : ownerBalance - _fromIndex);
        //
        ownerTokens = new uint256[](lenght);
        for(uint256 i = 0; i < lenght; i ++) {
            ownerTokens[i] = tokens[_fromIndex + i];
        }
        
        return ownerTokens;
    }
    
    /**
     * @dev Internal function to burn a specific token
     * @dev Reverts if the token does not exist
     * @param _owner owner of the token to burn
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address _owner, uint256 _tokenId) internal {
        _clearApproval(_tokenId);
        _removeTokenFrom(_owner, _tokenId);
        
        Transfer(_owner, address(0), _tokenId);
    }

}

contract CryptoWarriorPVE is WarriorTokenImpl {
    uint256 internal constant MINER_PERK = 1;
    uint256 internal constant SUMMONING_SICKENESS = 12;
    
    uint256 internal constant PVE_COOLDOWN = 1 hours;
    uint256 internal constant PVE_DURATION = 15 minutes;
    
    
    /// @notice The payment required to use startPVEBattle().
    uint256 public pveBattleFee = 10 finney;
    uint256 public constant PVE_COMPENSATION = 2 finney;
    
	/// @dev The address of the sibling contract that is used to implement warrior generation algorithm.
    SanctuaryInterface public sanctuary;

    /** @dev PVEStarted event. Emitted every time a warrior enters pve battle
     *  @param owner Warrior owner
     *  @param dungeonIndex Started dungeon index 
     *  @param warriorId Warrior ID that started PVE dungeon
     *  @param battleEndBlock Block number, when started PVE dungeon will be completed
     */
    event PVEStarted(address owner, uint256 dungeonIndex, uint256 warriorId, uint256 battleEndBlock);

    /** @dev PVEFinished event. Emitted every time a warrior finishes pve battle
     *  @param owner Warrior owner
     *  @param dungeonIndex Finished dungeon index
     *  @param warriorId Warrior ID that completed dungeon
     *  @param cooldownEndBlock Block number, when cooldown on PVE battle entrance will be over
     *  @param rewardId Warrior ID which was granted to the owner as battle reward
     */
    event PVEFinished(address owner, uint256 dungeonIndex, uint256 warriorId, uint256 cooldownEndBlock, uint256 rewardId);

	/// @dev Update the address of the sanctuary contract, can only be called by the Admin.
    /// @param _address An address of a sanctuary contract instance to be used from this point forward.
    function setSanctuaryAddress(address _address) external onlyAdmin {
        SanctuaryInterface candidateContract = SanctuaryInterface(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSanctuary());

        // Set the new contract address
        sanctuary = candidateContract;
    }
    
    function areUnique(uint256[] memory _warriorIds) internal pure returns(bool) {
   	    uint256 length = _warriorIds.length;
   	    uint256 j;
        for(uint256 i = 0; i < length; i++) {
	        for(j = i + 1; j < length; j++) {
	            if (_warriorIds[i] == _warriorIds[j]) return false;
	        }
        }
        return true; 
   	}

    /// @dev Updates the minimum payment required for calling startPVE(). Can only
    ///  be called by the COO address.
    function setPVEBattleFee(uint256 _pveBattleFee) external onlyAdmin {
        require(_pveBattleFee > PVE_COMPENSATION);
        pveBattleFee = _pveBattleFee;
    }
    
    /** @dev Returns PVE cooldown, after each battle, the warrior receives a 
     *  cooldown on the next entrance to the battle, cooldown depends on current warrior level,
     *  which is multiplied by 1h. Special case: after receiving 25 lv, the cooldwon will be 14 days.
     *  @param _levelPoints warrior level */
    function getPVECooldown(uint256 _levelPoints) public pure returns (uint256) {
        uint256 level = CryptoUtils._getLevel(_levelPoints);
        if (level >= MAX_LEVEL) return (14 * 24 * PVE_COOLDOWN);//14 days
        return (PVE_COOLDOWN * level);
    }

    /** @dev Returns PVE duration, each battle have a duration, which depends on current warrior level,
     *  which is multiplied by 15 min. At the end of the duration, warrior is becoming eligible to receive
     *  battle reward (new warrior in shiny armor)
     *  @param _levelPoints warrior level points 
     */
    function getPVEDuration(uint256 _levelPoints) public pure returns (uint256) {
        return CryptoUtils._getLevel(_levelPoints) * PVE_DURATION;
    }
    
    /// @dev Checks that a given warrior can participate in PVE battle. Requires that the
    ///  current cooldown is finished and also checks that warrior is idle (does not participate in any action)
    ///  and dungeon level requirement is satisfied
    function _isReadyToPVE(DataTypes.Warrior _warrior) internal view returns (bool) {
        return (_warrior.action == IDLE) && //is idle
        (_warrior.cooldownEndBlock <= uint64(block.number)) && //no cooldown
        (_warrior.level >= dungeonRequirements[_warrior.dungeonIndex]);//dungeon level requirement is satisfied
    }
    
    /// @dev Internal utility function to initiate pve battle, assumes that all battle
    ///  requirements have been checked.
    function _triggerPVEStart(uint256 _warriorId) internal {
        // Grab a reference to the warrior from storage.
        DataTypes.Warrior storage warrior = warriors[_warriorId];
        // Set warrior current action to pve battle
        warrior.action = uint16(PVE_BATTLE);
        // Set battle duration
        warrior.cooldownEndBlock = uint64((getPVEDuration(warrior.level) / secondsPerBlock) + block.number);
        // Emit the pve battle start event.
        PVEStarted(msg.sender, warrior.dungeonIndex, _warriorId, warrior.cooldownEndBlock);
    }
    
    /// @dev Starts PVE battle for specified warrior, 
    /// after battle, warrior owner will receive reward (Warrior) 
    /// @param _warriorId A Warrior ready to PVE battle.
    function startPVE(uint256 _warriorId) external payable whenNotPaused {
		// Checks for payment.
        require(msg.value >= pveBattleFee);
		
		// Caller must own the warrior.
        require(_ownerApproved(msg.sender, _warriorId));

        // Grab a reference to the warrior in storage.
        DataTypes.Warrior storage warrior = warriors[_warriorId];

        // Check that the warrior exists.
        require(warrior.identity != 0);

        // Check that the warrior is ready to battle
        require(_isReadyToPVE(warrior));
        
        // All checks passed, let the battle begin!
        _triggerPVEStart(_warriorId);
        
        // Calculate any excess funds included in msg.value. If the excess
        // is anything worth worrying about, transfer it back to message owner.
        // NOTE: We checked above that the msg.value is greater than or
        // equal to the price so this cannot underflow.
        uint256 feeExcess = msg.value - pveBattleFee;

        // Return the funds. This is not susceptible 
        // to a re-entry attack because of _isReadyToPVE check
        // will fail
        msg.sender.transfer(feeExcess);
        //send battle fee to beneficiary
        bankAddress.transfer(pveBattleFee - PVE_COMPENSATION);
    }
    
    function _ariseWarrior(address _owner, DataTypes.Warrior storage _warrior) internal returns(uint256) {
        uint256 identity = sanctuary.generateWarrior(_warrior.identity, CryptoUtils._getLevel(_warrior.level), _warrior.cooldownEndBlock - 1, 0);
        return _createWarrior(identity, _owner, block.number + (PVE_COOLDOWN * SUMMONING_SICKENESS / secondsPerBlock), 10, 100, 0);
    }

	/// @dev Internal utility function to finish pve battle, assumes that all battle
    ///  finish requirements have been checked.
    function _triggerPVEFinish(uint256 _warriorId) internal {
        // Grab a reference to the warrior in storage.
        DataTypes.Warrior storage warrior = warriors[_warriorId];
        
        // Set warrior current action to idle
        warrior.action = uint16(IDLE);
        
        // Compute an estimation of the cooldown time in blocks (based on current level).
        // and miner perc also reduces cooldown time by 4 times
        warrior.cooldownEndBlock = uint64((getPVECooldown(warrior.level) / 
            CryptoUtils._getBonus(warrior.identity) / secondsPerBlock) + block.number);
        
        // cash completed dungeon index before increment
        uint256 dungeonIndex = warrior.dungeonIndex;
        // Increment the dungeon index, clamping it at 5, which is the length of the
        // dungeonRequirements array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas.
        if (dungeonIndex < 5) {
            warrior.dungeonIndex += 1;
        }
        
        address owner = warriorToOwner[_warriorId];
        // generate reward
        uint256 arisenWarriorId = _ariseWarrior(owner, warrior);
        //Emit event
        PVEFinished(owner, dungeonIndex, _warriorId, warrior.cooldownEndBlock, arisenWarriorId);
    }
    
    /**
     * @dev finishPVE can be called after battle time is over,
     * if checks are passed then battle result is computed,
     * and new warrior is awarded to owner of specified _warriord ID.
     * NB anyone can call this method, if they willing to pay the gas price
     */
    function finishPVE(uint256 _warriorId) external whenNotPaused {
        // Grab a reference to the warrior in storage.
        DataTypes.Warrior storage warrior = warriors[_warriorId];
        
        // Check that the warrior exists.
        require(warrior.identity != 0);
        
        // Check that warrior participated in PVE battle action
        require(warrior.action == PVE_BATTLE);
        
        // And the battle time is over
        require(warrior.cooldownEndBlock <= uint64(block.number));
        
        // When the all checks done, calculate actual battle result
        _triggerPVEFinish(_warriorId);
        
        //not susceptible to reetrance attack because of require(warrior.action == PVE_BATTLE)
        //and require(warrior.cooldownEndBlock <= uint64(block.number));
        msg.sender.transfer(PVE_COMPENSATION);
    }
    
    /**
     * @dev finishPVEBatch same as finishPVE but for multiple warrior ids.
     * NB anyone can call this method, if they willing to pay the gas price
     */
    function finishPVEBatch(uint256[] _warriorIds) external whenNotPaused {
        uint256 length = _warriorIds.length;
        //check max number of bach finish pve
        require(length <= 20);
        uint256 blockNumber = block.number;
        uint256 index;
        //all warrior ids must be unique
        require(areUnique(_warriorIds));
        //check prerequisites
        for(index = 0; index < length; index ++) {
            DataTypes.Warrior storage warrior = warriors[_warriorIds[index]];
			require(
		        // Check that the warrior exists.
			    warrior.identity != 0 &&
		        // Check that warrior participated in PVE battle action
			    warrior.action == PVE_BATTLE &&
		        // And the battle time is over
			    warrior.cooldownEndBlock <= blockNumber
			);
        }
        // When the all checks done, calculate actual battle result
        for(index = 0; index < length; index ++) {
            _triggerPVEFinish(_warriorIds[index]);
        }
        
        //not susceptible to reetrance attack because of require(warrior.action == PVE_BATTLE)
        //and require(warrior.cooldownEndBlock <= uint64(block.number));
        msg.sender.transfer(PVE_COMPENSATION * length);
    }
}

contract CryptoWarriorSanctuary is CryptoWarriorPVE {
    
    uint256 internal constant RARE = 3;
    
    function burnWarrior(uint256 _warriorId, address _owner) whenNotPaused external {
        require(msg.sender == address(sanctuary));
        
        // Caller must own the warrior.
        require(_ownerApproved(_owner, _warriorId));

        // Grab a reference to the warrior in storage.
        DataTypes.Warrior storage warrior = warriors[_warriorId];

        // Check that the warrior exists.
        require(warrior.identity != 0);

        // Check that the warrior is ready to battle
        require(warrior.action == IDLE);//is idle
        
        // Rarity of burned warrior must be less or equal RARE (3)
        require(CryptoUtils.getRarityValue(warrior.identity) <= RARE);
        // Warriors with MINER perc are not allowed to be berned
        require(CryptoUtils.getSpecialityValue(warrior.identity) < MINER_PERK);
        
        _burn(_owner, _warriorId);
    }
    
    function ariseWarrior(uint256 _identity, address _owner, uint256 _cooldown) whenNotPaused external returns(uint256){
        require(msg.sender == address(sanctuary));
        return _createWarrior(_identity, _owner, _cooldown, 10, 100, 0);
    }
    
}

contract CryptoWarriorPVP is CryptoWarriorSanctuary {
	
	PVPInterface public battleProvider;
	
	/// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setBattleProviderAddress(address _address) external onlyAdmin {
        PVPInterface candidateContract = PVPInterface(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isPVPProvider());

        // Set the new contract address
        battleProvider = candidateContract;
    }
    
    function _packPVPData(uint256 _warriorId, DataTypes.Warrior storage warrior) internal view returns(uint256){
        return CryptoUtils._packWarriorPvpData(warrior.identity, uint256(warrior.rating), 0, _warriorId, warrior.level);
    }
    
    function _triggerPVPSignUp(uint256 _warriorId, uint256 fee) internal {
        DataTypes.Warrior storage warrior = warriors[_warriorId];
    		
		uint256 packedWarrior = _packPVPData(_warriorId, warrior);
        
        // addPVPContender will throw if fee fails.
        battleProvider.addPVPContender.value(fee)(msg.sender, packedWarrior);
        
        warrior.action = uint16(PVP_BATTLE);
    }
    
    /*
     * @title signUpForPVP enqueues specified warrior to PVP
     * 
     * @dev When the owner enqueues his warrior for PvP, the warrior enters the waiting room.
     * Once every 15 minutes, we check the warriors in the room and select pairs. 
     * For those warriors to whom we found couples, fighting is conducted and the results 
     * are recorded in the profile of the warrior. 
     */
    function signUpForPVP(uint256 _warriorId) public payable whenNotPaused {//done
		// Caller must own the warrior.
        require(_ownerApproved(msg.sender, _warriorId));
        // Grab a reference to the warrior in storage.
        DataTypes.Warrior storage warrior = warriors[_warriorId];
        // sanity check
        require(warrior.identity != 0);

        // Check that the warrior is ready to battle
        require(warrior.action == IDLE);
        
        // Define the current price of the auction.
        uint256 fee = battleProvider.getPVPEntranceFee(warrior.level);
        
        // Checks for payment.
        require(msg.value >= fee);
        
        // All checks passed, put the warrior to the queue!
        _triggerPVPSignUp(_warriorId, fee);
        
        // Calculate any excess funds included in msg.value. If the excess
        // is anything worth worrying about, transfer it back to message owner.
        // NOTE: We checked above that the msg.value is greater than or
        // equal to the price so this cannot underflow.
        uint256 feeExcess = msg.value - fee;

        // Return the funds. This is not susceptible 
        // to a re-entry attack because of warrior.action == IDLE check
        // will fail
        msg.sender.transfer(feeExcess);
    }

    function _grandPVPWinnerReward(uint256 _warriorId) internal {
        DataTypes.Warrior storage warrior = warriors[_warriorId];
        // reward 1 level, add 10 level points
        uint256 level = warrior.level;
        if (level < (MAX_LEVEL * POINTS_TO_LEVEL)) {
            level = level + POINTS_TO_LEVEL;
			warrior.level = uint64(level > (MAX_LEVEL * POINTS_TO_LEVEL) ? (MAX_LEVEL * POINTS_TO_LEVEL) : level);
        }
		// give 100 rating for levelUp and 30 for win
		warrior.rating += 130;
		// mark warrior idle, so it can participate
		// in another actions
		warrior.action = uint16(IDLE);
    }

    function _grandPVPLoserReward(uint256 _warriorId) internal {
        DataTypes.Warrior storage warrior = warriors[_warriorId];
		// reward 0.5 level
		uint256 oldLevel = warrior.level;
		uint256 level = oldLevel;
		if (level < (MAX_LEVEL * POINTS_TO_LEVEL)) {
            level += (POINTS_TO_LEVEL / 2);
			warrior.level = uint64(level);
        }
		// give 100 rating for levelUp if happens and -30 for lose
		int256 newRating = warrior.rating + (CryptoUtils._getLevel(level) > CryptoUtils._getLevel(oldLevel) ? int256(100 - 30) : int256(-30));
		// rating can't be less than 0 and more than 1000000000
	    warrior.rating = int64((newRating >= 0) ? (newRating > 1000000000 ? 1000000000 : newRating) : 0);
        // mark warrior idle, so it can participate
		// in another actions
	    warrior.action = uint16(IDLE);
    }
    
    function _grandPVPRewards(uint256[] memory warriorsData, uint256 matchingCount) internal {
        for(uint256 id = 0; id < matchingCount; id += 2){
            //
            // winner, even ids are winners!
            _grandPVPWinnerReward(CryptoUtils._unpackIdValue(warriorsData[id]));
            //
            // loser, they are odd...
            _grandPVPLoserReward(CryptoUtils._unpackIdValue(warriorsData[id + 1]));
        }
	}

    // @dev Internal utility function to initiate pvp battle, assumes that all battle
    ///  requirements have been checked.
    function pvpFinished(uint256[] warriorsData, uint256 matchingCount) public {
        //this method can be invoked only by battleProvider contract
        require(msg.sender == address(battleProvider));
        
        _grandPVPRewards(warriorsData, matchingCount);
    }
    
    function pvpContenderRemoved(uint256 _warriorId) public {
        //this method can be invoked only by battleProvider contract
        require(msg.sender == address(battleProvider));
        //grab warrior storage reference
        DataTypes.Warrior storage warrior = warriors[_warriorId];
        //specified warrior must be in pvp state
        require(warrior.action == PVP_BATTLE);
        //all checks done
        //set warrior state to IDLE
        warrior.action = uint16(IDLE);
    }
}

contract CryptoWarriorTournament is CryptoWarriorPVP {
    
    uint256 internal constant GROUP_SIZE = 5;
    
    function _ownsAll(address _claimant, uint256[] memory _warriorIds) internal view returns (bool) {
        uint256 length = _warriorIds.length;
        for(uint256 i = 0; i < length; i++) {
            if (!_ownerApproved(_claimant, _warriorIds[i])) return false;
        }
        return true;    
    }
    
    function _isReadyToTournament(DataTypes.Warrior storage _warrior) internal view returns(bool){
        return _warrior.level >= 50 && _warrior.action == IDLE;//must not participate in any action
    }
    
    function _packTournamentData(uint256[] memory _warriorIds) internal view returns(uint256[] memory tournamentData) {
        tournamentData = new uint256[](GROUP_SIZE);
        uint256 warriorId;
        for(uint256 i = 0; i < GROUP_SIZE; i++) {
            warriorId = _warriorIds[i];
            tournamentData[i] = _packPVPData(warriorId, warriors[warriorId]);   
        }
        return tournamentData;
    }
    
    
    // @dev Internal utility function to sign up to tournament, 
    // assumes that all battle requirements have been checked.
    function _triggerTournamentSignUp(uint256[] memory _warriorIds, uint256 fee) internal {
        //pack warrior ids into into uint256
        uint256[] memory tournamentData = _packTournamentData(_warriorIds);
        
        for(uint256 i = 0; i < GROUP_SIZE; i++) {
            // Set warrior current action to tournament battle
            warriors[_warriorIds[i]].action = uint16(TOURNAMENT_BATTLE);
        }

        battleProvider.addTournamentContender.value(fee)(msg.sender, tournamentData);
    }
    
    function signUpForTournament(uint256[] _warriorIds) public payable {
        //
        //check that there is enough funds to pay entrance fee
        uint256 fee = battleProvider.getTournamentThresholdFee();
        require(msg.value >= fee);
        //
        //check that warriors group is exactly of allowed size
        require(_warriorIds.length == GROUP_SIZE);
        //
        //message sender must own all the specified warrior IDs
        require(_ownsAll(msg.sender, _warriorIds));
        //
        //check all warriors are unique
        require(areUnique(_warriorIds));
        //
        //check that all warriors are 25 lv and IDLE
        for(uint256 i = 0; i < GROUP_SIZE; i ++) {
            // Grab a reference to the warrior in storage.
            require(_isReadyToTournament(warriors[_warriorIds[i]]));
        }
        
        
        //all checks passed, trigger sign up
        _triggerTournamentSignUp(_warriorIds, fee);
        
        // Calculate any excess funds included in msg.value. If the excess
        // is anything worth worrying about, transfer it back to message owner.
        // NOTE: We checked above that the msg.value is greater than or
        // equal to the fee so this cannot underflow.
        uint256 feeExcess = msg.value - fee;

        // Return the funds. This is not susceptible 
        // to a re-entry attack because of _isReadyToTournament check
        // will fail
        msg.sender.transfer(feeExcess);
    }
    
    function _setIDLE(uint256 warriorIds) internal {
        for(uint256 i = 0; i < GROUP_SIZE; i ++) {
            warriors[CryptoUtils._unpackWarriorId(warriorIds, i)].action = uint16(IDLE);
        }
    }
    
    function _freeWarriors(uint256[] memory packedContenders) internal {
        uint256 length = packedContenders.length;
        for(uint256 i = 0; i < length; i ++) {
            //set participants action to IDLE
            _setIDLE(packedContenders[i]);
        }
    }
    
    function tournamentFinished(uint256[] packedContenders) public {
        //this method can be invoked only by battleProvider contract
        require(msg.sender == address(battleProvider));
        
        //grad rewards and set IDLE action
        _freeWarriors(packedContenders);
    }
    
}

contract CryptoWarriorAuction is CryptoWarriorTournament {

    // @notice The auction contract variables are defined in CryptoWarriorBase to allow
    //  us to refer to them in WarriorTokenImpl to prevent accidental transfers.
    // `saleAuction` refers to the auction for miner and p2p sale of warriors.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyAdmin {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }


    /// @dev Put a warrior up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _warriorId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If warrior is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_ownerApproved(msg.sender, _warriorId));
        // Ensure the warrior is not busy to prevent the auction
        // contract creation while warrior is in any kind of battle (PVE, PVP, TOURNAMENT).
        require(warriors[_warriorId].action == IDLE);
        _approve(_warriorId, address(saleAuction));
        // Sale auction throws if inputs are invalid and clears
        // transfer approval after escrowing the warrior.
        saleAuction.createAuction(
            _warriorId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

}

contract CryptoWarriorIssuer is CryptoWarriorAuction {
    
    // Limits the number of warriors the contract owner can ever create
    uint256 public constant MINER_CREATION_LIMIT = 2880;//issue every 15min for one month
    // Constants for miner auctions.
    uint256 public constant MINER_STARTING_PRICE = 100 finney;
    uint256 public constant MINER_END_PRICE = 50 finney;
    uint256 public constant MINER_AUCTION_DURATION = 1 days;

    uint256 public minerCreatedCount;

    /// @dev Generates a new miner warrior with MINER perk of COMMON rarity
    ///  creates an auction for it.
    function createMinerAuction() external onlyIssuer {
        require(minerCreatedCount < MINER_CREATION_LIMIT);
		
        minerCreatedCount++;

        uint256 identity = sanctuary.generateWarrior(minerCreatedCount, 0, block.number - 1, MINER_PERK);
        uint256 warriorId = _createWarrior(identity, bankAddress, 0, 10, 100, 0);
        _approve(warriorId, address(saleAuction));

        saleAuction.createAuction(
            warriorId,
            _computeNextMinerPrice(),
            MINER_END_PRICE,
            MINER_AUCTION_DURATION,
            bankAddress
        );
    }

    /// @dev Computes the next miner auction starting price, given
    ///  the average of the past 5 prices * 2.
    function _computeNextMinerPrice() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageMinerSalePrice();

        // Sanity check to ensure we don't overflow arithmetic
        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice * 3 / 2;//confirmed

        // We never auction for less than starting price
        if (nextPrice < MINER_STARTING_PRICE) {
            nextPrice = MINER_STARTING_PRICE;
        }

        return nextPrice;
    }

}

contract CoreRecovery is CryptoWarriorIssuer {
    
    bool public allowRecovery = true;
    
    //data model
    //0 - identity
    //1 - cooldownEndBlock
    //2 - level
    //3 - rating
    //4 - index
    function recoverWarriors(uint256[] recoveryData, address[] owners) external onlyAdmin whenPaused {
        //check that recory action is allowed
        require(allowRecovery);
        
        uint256 length = owners.length;
        
        //check that number of owners corresponds to recover data length
        require(length == recoveryData.length / 5);
        
        for(uint256 i = 0; i < length; i++) {
            _createWarrior(recoveryData[i * 5], owners[i], recoveryData[i * 5 + 1], 
                recoveryData[i * 5 + 2], recoveryData[i * 5 + 3], recoveryData[i * 5 + 4]);
        }
    }
    
    //recovery is a one time action, once it is done no more recovery actions allowed
    function recoveryDone() external onlyAdmin {
        allowRecovery = false;
    }

}

contract CryptoWarriorCore is CoreRecovery {

    /// @notice Creates the main CryptoWarrior smart contract instance.
    function CryptoWarriorCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial Admin
        adminAddress = msg.sender;

        // the creator of the contract is also the initial COO
        issuerAddress = msg.sender;
        
        // the creator of the contract is also the initial Bank
        bankAddress = msg.sender;
    }
    
    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here
    /// (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(false);
    }
    
    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyAdmin whenPaused {
        require(address(saleAuction) != address(0));
        require(address(sanctuary) != address(0));
        require(address(battleProvider) != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
    
    function getBeneficiary() external view returns(address) {
        return bankAddress;
    }
    
    function isPVPListener() public pure returns (bool) {
        return true;
    }
       
    /**
     *@param _warriorIds array of warriorIds, 
     * for those IDs warrior data will be packed into warriorsData array
     *@return warriorsData packed warrior data
     *@return stepSize number of fields in single warrior data */
    function getWarriors(uint256[] _warriorIds) external view returns (uint256[] memory warriorsData, uint256 stepSize) {
        stepSize = 6;
        warriorsData = new uint256[](_warriorIds.length * stepSize);
        for(uint256 i = 0; i < _warriorIds.length; i++) {
            _setWarriorData(warriorsData, warriors[_warriorIds[i]], i * stepSize);
        }
    }
    
    /**
     *@param indexFrom index in global warrior storage (aka warriorId), 
     * from this index(including), warriors data will be gathered
     *@param count Number of warriors to include in packed data
     *@return warriorsData packed warrior data
     *@return stepSize number of fields in single warrior data */
    function getWarriorsFromIndex(uint256 indexFrom, uint256 count) external view returns (uint256[] memory warriorsData, uint256 stepSize) {
        stepSize = 6;
        //check length
        uint256 lenght = (warriors.length - indexFrom >= count ? count : warriors.length - indexFrom);
        
        warriorsData = new uint256[](lenght * stepSize);
        for(uint256 i = 0; i < lenght; i ++) {
            _setWarriorData(warriorsData, warriors[indexFrom + i], i * stepSize);
        }
    }
    
    function getWarriorOwners(uint256[] _warriorIds) external view returns (address[] memory owners) {
        uint256 lenght = _warriorIds.length;
        owners = new address[](lenght);
        
        for(uint256 i = 0; i < lenght; i ++) {
            owners[i] = warriorToOwner[_warriorIds[i]];
        }
    }
    
    
    function _setWarriorData(uint256[] memory warriorsData, DataTypes.Warrior storage warrior, uint256 id) internal view {
        warriorsData[id] = uint256(warrior.identity);//0
        warriorsData[id + 1] = uint256(warrior.cooldownEndBlock);//1
        warriorsData[id + 2] = uint256(warrior.level);//2
        warriorsData[id + 3] = uint256(warrior.rating);//3
        warriorsData[id + 4] = uint256(warrior.action);//4
        warriorsData[id + 5] = uint256(warrior.dungeonIndex);//5
    }
    
	function getWarrior(uint256 _id) external view returns 
    (
        uint256 identity, 
        uint256 cooldownEndBlock, 
        uint256 level,
        uint256 rating, 
        uint256 action,
        uint256 dungeonIndex
    ) {
        DataTypes.Warrior storage warrior = warriors[_id];

        identity = uint256(warrior.identity);
        cooldownEndBlock = uint256(warrior.cooldownEndBlock);
        level = uint256(warrior.level);
		rating = uint256(warrior.rating);
		action = uint256(warrior.action);
		dungeonIndex = uint256(warrior.dungeonIndex);
    }
    
}

/*  @title Handles creating pvp battles every 15 min.*/
contract PVP is PausableBattle, PVPInterface {
	/* PVP BATLE */
	
    /** list of packed warrior data that will participate in next PVP session. 
     *  Fixed size arry, to evade constant remove and push operations,
     *  this approach reduces transaction costs involving queue modification. */
    uint256[100] public pvpQueue;
    //
    //queue size
    uint256 public pvpQueueSize = 0;
    
    // @dev A mapping from owner address to booty in WEI
    //  booty is acquired in PVP and Tournament battles and can be
    // withdrawn with grabBooty method by the owner of the loot
    mapping (address => uint256) public ownerToBooty;
    
    // @dev A mapping from warrior id to owners address
    mapping (uint256 => address) internal warriorToOwner;
    
    // An approximation of currently how many seconds are in between blocks.
    uint256 internal secondsPerBlock = 15;
    
    // Cut owner takes from, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public pvpOwnerCut;
    
    // Values 0-10,000 map to 0%-100%
    //this % of the total bets will be sent as 
    //a reward to address, that triggered finishPVP method
    uint256 public pvpMaxIncentiveCut;
    
    /// @notice The payment base required to use startPVP().
    // pvpBattleFee * (warrior.level / POINTS_TO_LEVEL)
    uint256 internal pvpBattleFee = 10 finney;
    
    uint256 public constant PVP_INTERVAL = 15 minutes;
    
    uint256 public nextPVPBatleBlock = 0;
    //number of WEI in hands of warrior owners
    uint256 public totalBooty = 0;
    
    /* TOURNAMENT */
    uint256 public constant FUND_GATHERING_TIME = 24 hours;
    uint256 public constant ADMISSION_TIME = 12 hours;
    uint256 public constant RATING_EXPAND_INTERVAL = 1 hours;
    uint256 internal constant SAFETY_GAP = 5;
    
    uint256 internal constant MAX_INCENTIVE_REWARD = 200 finney;
    
    //tournamentContenders size
    uint256 public tournamentQueueSize = 0;
    
    // Values 0-10,000 map to 0%-100%
    uint256 public tournamentBankCut;
    
   /** tournamentEndBlock, tournament is eligible to be finished only
    *  after block.number >= tournamentEndBlock 
    *  it depends on FUND_GATHERING_TIME and ADMISSION_TIME */
    uint256 public tournamentEndBlock;
    
    //number of WEI in tournament bank
    uint256 public currentTournamentBank = 0;
    uint256 public nextTournamentBank = 0;
    
    PVPListenerInterface internal pvpListener;
    
    /* EVENTS */
    /** @dev TournamentScheduled event. Emitted every time a tournament is scheduled 
     *  @param tournamentEndBlock when block.number > tournamentEndBlock, then tournament 
     *         is eligible to be finished or rescheduled */
    event TournamentScheduled(uint256 tournamentEndBlock);
    
    /** @dev PVPScheduled event. Emitted every time a tournament is scheduled 
     *  @param nextPVPBatleBlock when block.number > nextPVPBatleBlock, then pvp battle 
     *         is eligible to be finished or rescheduled */
    event PVPScheduled(uint256 nextPVPBatleBlock);
    
    /** @dev PVPNewContender event. Emitted every time a warrior enqueues pvp battle
     *  @param owner Warrior owner
     *  @param warriorId Warrior ID that entered PVP queue
     *  @param entranceFee fee in WEI warrior owner payed to enter PVP
     */
    event PVPNewContender(address owner, uint256 warriorId, uint256 entranceFee);

    /** @dev PVPFinished event. Emitted every time a pvp battle is finished
     *  @param warriorsData array of pairs of pvp warriors packed to uint256, even => winners, odd => losers 
     *  @param owners array of warrior owners, 1 to 1 with warriorsData, even => winners, odd => losers 
     *  @param matchingCount total number of warriors that fought in current pvp session and got rewards,
     *  if matchingCount < participants.length then all IDs that are >= matchingCount will 
     *  remain in waiting room, until they are matched.
     */
    event PVPFinished(uint256[] warriorsData, address[] owners, uint256 matchingCount);
    
    /** @dev BootySendFailed event. Emitted every time address.send() function failed to transfer Ether to recipient
     *  in this case recipient Ether is recorded to ownerToBooty mapping, so recipient can withdraw their booty manually
     *  @param recipient address for whom send failed
     *  @param amount number of WEI we failed to send
     */
    event BootySendFailed(address recipient, uint256 amount);
    
    /** @dev BootyGrabbed event
     *  @param receiver address who grabbed his booty
     *  @param amount number of WEI
     */
    event BootyGrabbed(address receiver, uint256 amount);
    
    /** @dev PVPContenderRemoved event. Emitted every time warrior is removed from pvp queue by its owner.
     *  @param warriorId id of the removed warrior
     */
    event PVPContenderRemoved(uint256 warriorId, address owner);
    
    function PVP(uint256 _pvpCut, uint256 _tournamentBankCut, uint256 _pvpMaxIncentiveCut) public {
        require((_tournamentBankCut + _pvpCut + _pvpMaxIncentiveCut) <= 10000);
		pvpOwnerCut = _pvpCut;
		tournamentBankCut = _tournamentBankCut;
		pvpMaxIncentiveCut = _pvpMaxIncentiveCut;
    }
    
    /** @dev grabBooty sends to message sender his booty in WEI
     */
    function grabBooty() external {
        uint256 booty = ownerToBooty[msg.sender];
        require(booty > 0);
        require(totalBooty >= booty);
        
        ownerToBooty[msg.sender] = 0;
        totalBooty -= booty;
        
        msg.sender.transfer(booty);
        //emit event
        BootyGrabbed(msg.sender, booty);
    }
    
    function safeSend(address _recipient, uint256 _amaunt) internal {
		uint256 failedBooty = sendBooty(_recipient, _amaunt);
        if (failedBooty > 0) {
			totalBooty += failedBooty;
        }
    }
    
    function sendBooty(address _recipient, uint256 _amaunt) internal returns(uint256) {
        bool success = _recipient.send(_amaunt);
        if (!success && _amaunt > 0) {
            ownerToBooty[_recipient] += _amaunt;
            BootySendFailed(_recipient, _amaunt);
            return _amaunt;
        }
        return 0;
    }
    
    //@returns block number, after this block tournament is opened for admission
    function getTournamentAdmissionBlock() public view returns(uint256) {
        uint256 admissionInterval = (ADMISSION_TIME / secondsPerBlock);
        return tournamentEndBlock < admissionInterval ? 0 : tournamentEndBlock - admissionInterval;
    }
    
    
    //schedules next turnament time(block)
    function _scheduleTournament() internal {
        //we can chedule only if there is nobody in tournament queue and
        //time of tournament battle have passed
		if (tournamentQueueSize == 0 && tournamentEndBlock <= block.number) {
		    tournamentEndBlock = ((FUND_GATHERING_TIME / 2 + ADMISSION_TIME) / secondsPerBlock) + block.number;
		    TournamentScheduled(tournamentEndBlock);
		}
    }
    
    /// @dev Updates the minimum payment required for calling startPVP(). Can only
    ///  be called by the COO address, and only if pvp queue is empty.
    function setPVPEntranceFee(uint256 value) external onlyOwner {
        require(pvpQueueSize == 0);
        pvpBattleFee = value;
    }
    
    //@returns PVP entrance fee for specified warrior level 
    //@param _levelPoints NB!
    function getPVPEntranceFee(uint256 _levelPoints) external view returns(uint256) {
        return pvpBattleFee * CryptoUtils._getLevel(_levelPoints);
    }
    
    //level can only be > 0 and <= 25
    function _getPVPFeeByLevel(uint256 _level) internal view returns(uint256) {
        return pvpBattleFee * _level;
    }
    
	// @dev Computes warrior pvp reward
    // @param _totalBet - total bet from both competitors.
    function _computePVPReward(uint256 _totalBet, uint256 _contendersCut) internal pure returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because
        // _totalBet max value is 1000 finney, and _contendersCut aka
        // (10000 - pvpOwnerCut - tournamentBankCut - incentiveRewardCut) <= 10000 (see the require()
        // statement in the BattleProvider constructor). The result of this
        // function is always guaranteed to be <= _totalBet.
        return _totalBet * _contendersCut / 10000;
    }
    
    function _getPVPContendersCut(uint256 _incentiveCut) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        // (pvpOwnerCut + tournamentBankCut + pvpMaxIncentiveCut) <= 10000 (see the require()
        // statement in the BattleProvider constructor). 
        // _incentiveCut is guaranteed to be >= 1 and <=  pvpMaxIncentiveCut
        return (10000 - pvpOwnerCut - tournamentBankCut - _incentiveCut);
    }
	
	// @dev Computes warrior pvp reward
    // @param _totalSessionLoot - total bets from all competitors.
    function _computeIncentiveReward(uint256 _totalSessionLoot, uint256 _incentiveCut) internal pure returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because
        // _totalSessionLoot max value is 37500 finney, and 
        // (pvpOwnerCut + tournamentBankCut + incentiveRewardCut) <= 10000 (see the require()
        // statement in the BattleProvider constructor). The result of this
        // function is always guaranteed to be <= _totalSessionLoot.
        return _totalSessionLoot * _incentiveCut / 10000;
    }
    
	///@dev computes incentive cut for specified loot, 
	/// Values 0-10,000 map to 0%-100%
	/// max incentive reward cut is 5%, if it exceeds MAX_INCENTIVE_REWARD,
	/// then cut is lowered to be equal to MAX_INCENTIVE_REWARD.
	/// minimum cut is 0.01%
    /// this % of the total bets will be sent as 
    /// a reward to address, that triggered finishPVP method
    function _computeIncentiveCut(uint256 _totalSessionLoot, uint256 maxIncentiveCut) internal pure returns(uint256) {
        uint256 result = _totalSessionLoot * maxIncentiveCut / 10000;
        result = result <= MAX_INCENTIVE_REWARD ? maxIncentiveCut : MAX_INCENTIVE_REWARD * 10000 / _totalSessionLoot;
        //min cut is 0.01%
        return result > 0 ? result : 1;
    }
    
    // @dev Computes warrior pvp reward
    // @param _totalSessionLoot - total bets from all competitors.
    function _computePVPBeneficiaryFee(uint256 _totalSessionLoot) internal view returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because
        // _totalSessionLoot max value is 37500 finney, and 
        // (pvpOwnerCut + tournamentBankCut + incentiveRewardCut) <= 10000 (see the require()
        // statement in the BattleProvider constructor). The result of this
        // function is always guaranteed to be <= _totalSessionLoot.
        return _totalSessionLoot * pvpOwnerCut / 10000;
    }
    
    // @dev Computes tournament bank cut
    // @param _totalSessionLoot - total session loot.
    function _computeTournamentCut(uint256 _totalSessionLoot) internal view returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because
        // _totalSessionLoot max value is 37500 finney, and 
        // (pvpOwnerCut + tournamentBankCut + incentiveRewardCut) <= 10000 (see the require()
        // statement in the BattleProvider constructor). The result of this
        // function is always guaranteed to be <= _totalSessionLoot.
        return _totalSessionLoot * tournamentBankCut / 10000;
    }

    function indexOf(uint256 _warriorId) internal view returns(int256) {
	    uint256 length = uint256(pvpQueueSize);
	    for(uint256 i = 0; i < length; i ++) {
	        if(CryptoUtils._unpackIdValue(pvpQueue[i]) == _warriorId) return int256(i);
	    }
	    return -1;
	}
    
    function getPVPIncentiveReward(uint256[] memory matchingIds, uint256 matchingCount) internal view returns(uint256) {
        uint256 sessionLoot = _computeTotalBooty(matchingIds, matchingCount);
        
        return _computeIncentiveReward(sessionLoot, _computeIncentiveCut(sessionLoot, pvpMaxIncentiveCut));
    }
    
    function maxPVPContenders() external view returns(uint256){
        return pvpQueue.length;
    }
    
    function getPVPState() external view returns
    (uint256 contendersCount, uint256 matchingCount, uint256 endBlock, uint256 incentiveReward)
    {
        uint256[] memory pvpData = _packPVPData();
        
    	contendersCount = pvpQueueSize;
    	matchingCount = CryptoUtils._getMatchingIds(pvpData, PVP_INTERVAL, _computeCycleSkip(), RATING_EXPAND_INTERVAL);
    	endBlock = nextPVPBatleBlock;   
    	incentiveReward = getPVPIncentiveReward(pvpData, matchingCount);
    }
    
    function canFinishPVP() external view returns(bool) {
        return nextPVPBatleBlock <= block.number &&
         CryptoUtils._getMatchingIds(_packPVPData(), PVP_INTERVAL, _computeCycleSkip(), RATING_EXPAND_INTERVAL) > 1;
    }
    
    function _clarifyPVPSchedule() internal {
        uint256 length = pvpQueueSize;
		uint256 currentBlock = block.number;
		uint256 nextBattleBlock = nextPVPBatleBlock;
		//if battle not scheduled, schedule battle
		if (nextBattleBlock <= currentBlock) {
		    //if queue not empty update cycles
		    if (length > 0) {
				uint256 packedWarrior;
				uint256 cycleSkip = _computeCycleSkip();
		        for(uint256 i = 0; i < length; i++) {
		            packedWarrior = pvpQueue[i];
		            //increase warrior iteration cycle
		            pvpQueue[i] = CryptoUtils._changeCycleValue(packedWarrior, CryptoUtils._unpackCycleValue(packedWarrior) + cycleSkip);
		        }
		    }
		    nextBattleBlock = (PVP_INTERVAL / secondsPerBlock) + currentBlock;
		    nextPVPBatleBlock = nextBattleBlock;
		    PVPScheduled(nextBattleBlock);
		//if pvp queue will be full and there is still too much time left, then let the battle begin! 
		} else if (length + 1 == pvpQueue.length && (currentBlock + SAFETY_GAP * 2) < nextBattleBlock) {
		    nextBattleBlock = currentBlock + SAFETY_GAP;
		    nextPVPBatleBlock = nextBattleBlock;
		    PVPScheduled(nextBattleBlock);
		}
    }
    
    /// @dev Internal utility function to initiate pvp battle, assumes that all battle
    ///  requirements have been checked.
    function _triggerNewPVPContender(address _owner, uint256 _packedWarrior, uint256 fee) internal {

		_clarifyPVPSchedule();
        //number of pvp cycles the warrior is waiting for suitable enemy match
        //increment every time when finishPVP is called and no suitable enemy match was found
        _packedWarrior = CryptoUtils._changeCycleValue(_packedWarrior, 0);
		
		//record contender data
		pvpQueue[pvpQueueSize++] = _packedWarrior;
		warriorToOwner[CryptoUtils._unpackIdValue(_packedWarrior)] = _owner;
		
		//Emit event
		PVPNewContender(_owner, CryptoUtils._unpackIdValue(_packedWarrior), fee);
    }
    
    function _noMatchingPairs() internal view returns(bool) {
        uint256 matchingCount = CryptoUtils._getMatchingIds(_packPVPData(), uint64(PVP_INTERVAL), _computeCycleSkip(), uint64(RATING_EXPAND_INTERVAL));
        return matchingCount == 0;
    }
    
    /*
     * @title startPVP enqueues specified warrior to PVP
     * 
     * @dev When the owner enqueues his warrior for PvP, the warrior enters the waiting room.
     * Once every 15 minutes, we check the warriors in the room and select pairs. 
     * For those warriors to whom we found couples, fighting is conducted and the results 
     * are recorded in the profile of the warrior. 
     */
    function addPVPContender(address _owner, uint256 _packedWarrior) external payable PVPNotPaused {
		// Caller must be pvpListener contract
        require(msg.sender == address(pvpListener));

        require(_owner != address(0));
        //contender can be added only while PVP is scheduled in future
        //or no matching warrior pairs found
        require(nextPVPBatleBlock > block.number || _noMatchingPairs());
        // Check that the warrior exists.
        require(_packedWarrior != 0);
        //owner must withdraw all loot before contending pvp
        require(ownerToBooty[_owner] == 0);
        //check that there is enough room for new participants
        require(pvpQueueSize < pvpQueue.length);
        // Checks for payment.
        uint256 fee = _getPVPFeeByLevel(CryptoUtils._unpackLevelValue(_packedWarrior));
        require(msg.value >= fee);
        //
        // All checks passed, put the warrior to the queue!
        _triggerNewPVPContender(_owner, _packedWarrior, fee);
    }
    
    function _packPVPData() internal view returns(uint256[] memory matchingIds) {
        uint256 length = pvpQueueSize;
        matchingIds = new uint256[](length);
        for(uint256 i = 0; i < length; i++) {
            matchingIds[i] = pvpQueue[i];
        }
        return matchingIds;
    }
    
    function _computeTotalBooty(uint256[] memory _packedWarriors, uint256 matchingCount) internal view returns(uint256) {
        //compute session booty
        uint256 sessionLoot = 0;
        for(uint256 i = 0; i < matchingCount; i++) {
            sessionLoot += _getPVPFeeByLevel(CryptoUtils._unpackLevelValue(_packedWarriors[i]));
        }
        return sessionLoot;
    }
    
    function _grandPVPRewards(uint256[] memory _packedWarriors, uint256 matchingCount) 
    internal returns(uint256)
    {
        uint256 booty = 0;
        uint256 packedWarrior;
        uint256 failedBooty = 0;
        
        uint256 sessionBooty = _computeTotalBooty(_packedWarriors, matchingCount);
        uint256 incentiveCut = _computeIncentiveCut(sessionBooty, pvpMaxIncentiveCut);
        uint256 contendersCut = _getPVPContendersCut(incentiveCut);
        
        for(uint256 id = 0; id < matchingCount; id++) {
            //give reward to warriors that fought hard
			//winner, even ids are winners!
			packedWarrior = _packedWarriors[id];
			//
			//give winner deserved booty 80% from both bets
			//must be computed before level reward!
			booty = _getPVPFeeByLevel(CryptoUtils._unpackLevelValue(packedWarrior)) + 
				_getPVPFeeByLevel(CryptoUtils._unpackLevelValue(_packedWarriors[id + 1]));
			
			//
			//send reward to warrior owner
			failedBooty += sendBooty(warriorToOwner[CryptoUtils._unpackIdValue(packedWarrior)], _computePVPReward(booty, contendersCut));
			//loser, they are odd...
			//skip them, as they deserve none!
			id ++;
        }
        failedBooty += sendBooty(pvpListener.getBeneficiary(), _computePVPBeneficiaryFee(sessionBooty));
        
        if (failedBooty > 0) {
            totalBooty += failedBooty;
        }
        //if tournament admission start time not passed
        //add tournament cut to current tournament bank,
        //otherwise to next tournament bank
        if (getTournamentAdmissionBlock() > block.number) {
            currentTournamentBank += _computeTournamentCut(sessionBooty);
        } else {
            nextTournamentBank += _computeTournamentCut(sessionBooty);
        }
        
        //compute incentive reward
        return _computeIncentiveReward(sessionBooty, incentiveCut);
    }
    
    function _increaseCycleAndTrimQueue(uint256[] memory matchingIds, uint256 matchingCount) internal {
        uint32 length = uint32(matchingIds.length - matchingCount);  
		uint256 packedWarrior;
		uint256 skipCycles = _computeCycleSkip();
        for(uint256 i = 0; i < length; i++) {
            packedWarrior = matchingIds[matchingCount + i];
            //increase warrior iteration cycle
            pvpQueue[i] = CryptoUtils._changeCycleValue(packedWarrior, CryptoUtils._unpackCycleValue(packedWarrior) + skipCycles);
        }
        //trim queue	
        pvpQueueSize = length;
    }
    
    function _computeCycleSkip() internal view returns(uint256) {
        uint256 number = block.number;
        return nextPVPBatleBlock > number ? 0 : (number - nextPVPBatleBlock) * secondsPerBlock / PVP_INTERVAL + 1;
    }
    
    function _getWarriorOwners(uint256[] memory pvpData) internal view returns (address[] memory owners){
        uint256 length = pvpData.length;
        owners = new address[](length);
        for(uint256 i = 0; i < length; i ++) {
            owners[i] = warriorToOwner[CryptoUtils._unpackIdValue(pvpData[i])];
        }
    }
    
    // @dev Internal utility function to initiate pvp battle, assumes that all battle
    ///  requirements have been checked.
    function _triggerPVPFinish(uint256[] memory pvpData, uint256 matchingCount) internal returns(uint256){
        //
		//compute battle results        
        CryptoUtils._getPVPBattleResults(pvpData, matchingCount, nextPVPBatleBlock);
        //
        //mark not fought warriors and trim queue 
        _increaseCycleAndTrimQueue(pvpData, matchingCount);
        //
        //schedule next battle time
        nextPVPBatleBlock = (PVP_INTERVAL / secondsPerBlock) + block.number;
        
        //
        //schedule tournament
        //if contendersCount is 0 and tournament not scheduled, schedule tournament
        //NB MUST be before _grandPVPRewards()
        _scheduleTournament();
        // compute and grand rewards to warriors,
        // put tournament cut to bank, not susceptible to reentry attack because of require(nextPVPBatleBlock <= block.number);
        // and require(number of pairs > 1);
        uint256 incentiveReward = _grandPVPRewards(pvpData, matchingCount);
        //
        //notify pvp listener contract
        pvpListener.pvpFinished(pvpData, matchingCount);
        
        //
        //fire event
		PVPFinished(pvpData, _getWarriorOwners(pvpData), matchingCount);
        PVPScheduled(nextPVPBatleBlock);
		
		return incentiveReward;
    }
    
    
    /**
     * @dev finishPVP this method finds matches of warrior pairs
     * in waiting room and computes result of their fights.
     * 
     * The winner gets +1 level, the loser gets +0.5 level
     * The winning player gets +130 rating
	 * The losing player gets -30 or 70 rating (if warrior levelUps after battle) .
     * can be called once in 15min.
     * NB If the warrior is not picked up in an hour, then we expand the range 
     * of selection by 25 rating each hour.
     */
    function finishPVP() public PVPNotPaused {
        // battle interval is over
        require(nextPVPBatleBlock <= block.number);
        //
	    //match warriors
        uint256[] memory pvpData = _packPVPData();
        //match ids and sort them according to matching
        uint256 matchingCount = CryptoUtils._getMatchingIds(pvpData, uint64(PVP_INTERVAL), _computeCycleSkip(), uint64(RATING_EXPAND_INTERVAL));
		// we have at least 1 matching battle pair
        require(matchingCount > 1);
        
        // When the all checks done, calculate actual battle result
        uint256 incentiveReward = _triggerPVPFinish(pvpData, matchingCount);
        
        //give reward for incentive
        safeSend(msg.sender, incentiveReward);
    }

    // @dev Removes specified warrior from PVP queue
    //  sets warrior free (IDLE) and returns pvp entrance fee to owner
    // @notice This is a state-modifying function that can
    //  be called while the contract is paused.
    // @param _warriorId - ID of warrior in PVP queue
    function removePVPContender(uint256 _warriorId) external{
        uint256 queueSize = pvpQueueSize;
        require(queueSize > 0);
        // Caller must be owner of the specified warrior
        require(warriorToOwner[_warriorId] == msg.sender);
        //warrior must be in pvp queue
        int256 warriorIndex = indexOf(_warriorId);
        require(warriorIndex >= 0);
        //grab warrior data
        uint256 warriorData = pvpQueue[uint32(warriorIndex)];
        //warrior cycle must be >= 4 (> than 1 hour)
        require((CryptoUtils._unpackCycleValue(warriorData) + _computeCycleSkip()) >= 4);
        
        //remove from queue
        if (uint256(warriorIndex) < queueSize - 1) {
	        pvpQueue[uint32(warriorIndex)] = pvpQueue[pvpQueueSize - 1];
        }
        pvpQueueSize --;
        //notify battle listener
        pvpListener.pvpContenderRemoved(_warriorId);
        //return pvp bet
        msg.sender.transfer(_getPVPFeeByLevel(CryptoUtils._unpackLevelValue(warriorData)));
        //Emit event
        PVPContenderRemoved(_warriorId, msg.sender);
    }
    
    function getPVPCycles(uint32[] warriorIds) external view returns(uint32[]){
        uint256 length = warriorIds.length;
        uint32[] memory cycles = new uint32[](length);
        int256 index;
        uint256 skipCycles = _computeCycleSkip();
	    for(uint256 i = 0; i < length; i ++) {
	        index = indexOf(warriorIds[i]);
	        cycles[i] = index >= 0 ? uint32(CryptoUtils._unpackCycleValue(pvpQueue[uint32(index)]) + skipCycles) : 0;
	    }
	    return cycles;
    }
    
    // @dev Remove all PVP contenders from PVP queue 
    //  and return all bets to warrior owners.
    //  NB: this is emergency method, used only in f%#^@up situation
    function removeAllPVPContenders() external onlyOwner PVPPaused {
        //remove all pvp contenders
        uint256 length = pvpQueueSize;
        
        uint256 warriorData;
        uint256 warriorId;
        uint256 failedBooty;
        address owner;
        
        pvpQueueSize = 0;
        
        for(uint256 i = 0; i < length; i++) {
	        //grab warrior data
	        warriorData = pvpQueue[i];
	        warriorId = CryptoUtils._unpackIdValue(warriorData);
	        //notify battle listener
	        pvpListener.pvpContenderRemoved(uint32(warriorId));
	        
	        owner = warriorToOwner[warriorId];
	        //return pvp bet
	        failedBooty += sendBooty(owner, _getPVPFeeByLevel(CryptoUtils._unpackLevelValue(warriorData)));
        }
        totalBooty += failedBooty;
    }
}


contract Tournament is PVP {

    uint256 internal constant GROUP_SIZE = 5;
    uint256 internal constant DATA_SIZE = 2;
    uint256 internal constant THRESHOLD = 300;
    
  /** list of warrior IDs that will participate in next tournament. 
    *  Fixed size arry, to evade constant remove and push operations,
    *  this approach reduces transaction costs involving array modification. */
    uint256[160] public tournamentQueue;
    
    /**The cost of participation in the tournament is 1% of its current prize fund, 
     * money is added to the prize fund. measured in basis points (1/100 of a percent).
     * Values 0-10,000 map to 0%-100% */
    uint256 internal tournamentEntranceFeeCut = 100;
    
    // Values 0-10,000 map to 0%-100% => 20%
    uint256 public tournamentOwnersCut;
    uint256 public tournamentIncentiveCut;
    
     /** @dev TournamentNewContender event. Emitted every time a warrior enters tournament
     *  @param owner Warrior owner
     *  @param warriorIds 5 Warrior IDs that entered tournament, packed into one uint256
     *  see CryptoUtils._packWarriorIds
     */
    event TournamentNewContender(address owner, uint256 warriorIds, uint256 entranceFee);
    
    /** @dev TournamentFinished event. Emitted every time a tournament is finished
     *  @param owners array of warrior group owners packed to uint256
     *  @param results number of wins for each group
     *  @param tournamentBank current tournament bank
     *  see CryptoUtils._packWarriorIds
     */
    event TournamentFinished(uint256[] owners, uint32[] results, uint256 tournamentBank);
    
    function Tournament(uint256 _pvpCut, uint256 _tournamentBankCut, 
    uint256 _pvpMaxIncentiveCut, uint256 _tournamentOwnersCut, uint256 _tournamentIncentiveCut) public
    PVP(_pvpCut, _tournamentBankCut, _pvpMaxIncentiveCut) 
    {
        require((_tournamentOwnersCut + _tournamentIncentiveCut) <= 10000);
		
		tournamentOwnersCut = _tournamentOwnersCut;
		tournamentIncentiveCut = _tournamentIncentiveCut;
    }
    
    
    
    // @dev Computes incentive reward for launching tournament finishTournament()
    // @param _tournamentBank
    function _computeTournamentIncentiveReward(uint256 _currentBank, uint256 _incentiveCut) internal pure returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because _currentBank max is equal ~ 20000000 finney,
        // and (tournamentOwnersCut + tournamentIncentiveCut) <= 10000 (see the require()
        // statement in the Tournament constructor). The result of this
        // function is always guaranteed to be <= _currentBank.
        return _currentBank * _incentiveCut / 10000;
    }
    
    function _computeTournamentContenderCut(uint256 _incentiveCut) internal view returns (uint256) {
        // NOTE: (tournamentOwnersCut + tournamentIncentiveCut) <= 10000 (see the require()
        // statement in the Tournament constructor). The result of this
        // function is always guaranteed to be <= _reward.
        return 10000 - tournamentOwnersCut - _incentiveCut;
    }
    
    function _computeTournamentBeneficiaryFee(uint256 _currentBank) internal view returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because _currentBank max is equal ~ 20000000 finney,
        // and (tournamentOwnersCut + tournamentIncentiveCut) <= 10000 (see the require()
        // statement in the Tournament constructor). The result of this
        // function is always guaranteed to be <= _currentBank.
        return _currentBank * tournamentOwnersCut / 10000;
    }
    
    // @dev set tournament entrance fee cut, can be set only if
    // tournament queue is empty
    // @param _cut range from 0 - 10000, mapped to 0-100%
    function setTournamentEntranceFeeCut(uint256 _cut) external onlyOwner {
        //cut must be less or equal 100&
        require(_cut <= 10000);
        //tournament queue must be empty
        require(tournamentQueueSize == 0);
        //checks passed, set cut
		tournamentEntranceFeeCut = _cut;
    }
    
    function getTournamentEntranceFee() external view returns(uint256) {
        return currentTournamentBank * tournamentEntranceFeeCut / 10000;
    }
    
    //@dev returns tournament entrance fee - 3% threshold
    function getTournamentThresholdFee() public view returns(uint256) {
        return currentTournamentBank * tournamentEntranceFeeCut * (10000 - THRESHOLD) / 10000 / 10000;
    }
    
    //@dev returns max allowed tournament contenders, public because of internal use
    function maxTournamentContenders() public view returns(uint256){
        return tournamentQueue.length / DATA_SIZE;
    }
    
    function canFinishTournament() external view returns(bool) {
        return tournamentEndBlock <= block.number && tournamentQueueSize > 0;
    }
    
    // @dev Internal utility function to sigin up to tournament, 
    // assumes that all battle requirements have been checked.
    function _triggerNewTournamentContender(address _owner, uint256[] memory _tournamentData, uint256 _fee) internal {
        //pack warrior ids into uint256
        
        currentTournamentBank += _fee;
        
        uint256 packedWarriorIds = CryptoUtils._packWarriorIds(_tournamentData);
        //make composite warrior out of 5 warriors 
        uint256 combinedWarrior = CryptoUtils._combineWarriors(_tournamentData);
        
        //add to queue
        //icrement tournament queue
        uint256 size = tournamentQueueSize++ * DATA_SIZE;
        //record tournament data
		tournamentQueue[size++] = packedWarriorIds;
		tournamentQueue[size++] = combinedWarrior;
		warriorToOwner[CryptoUtils._unpackWarriorId(packedWarriorIds, 0)] = _owner;
		//
		//Emit event
		TournamentNewContender(_owner, packedWarriorIds, _fee);
    }
    
    function addTournamentContender(address _owner, uint256[] _tournamentData) external payable TournamentNotPaused{
        // Caller must be pvpListener contract
        require(msg.sender == address(pvpListener));
        
        require(_owner != address(0));
        //
        //check current tournament bank > 0
        require(pvpBattleFee == 0 || currentTournamentBank > 0);
        //
        //check that there is enough funds to pay entrance fee
        uint256 fee = getTournamentThresholdFee();
        require(msg.value >= fee);
        //owner must withdraw all booty before contending pvp
        require(ownerToBooty[_owner] == 0);
        //
        //check that warriors group is exactly of allowed size
        require(_tournamentData.length == GROUP_SIZE);
        //
        //check that there is enough room for new participants
        require(tournamentQueueSize < maxTournamentContenders());
        //
        //check that admission started
        require(block.number >= getTournamentAdmissionBlock());
        //check that admission not ended
        require(block.number <= tournamentEndBlock);
        
        //all checks passed, trigger sign up
        _triggerNewTournamentContender(_owner, _tournamentData, fee);
    }
    
    //@dev collect all combined warriors data
    function getCombinedWarriors() internal view returns(uint256[] memory warriorsData) {
        uint256 length = tournamentQueueSize;
        warriorsData = new uint256[](length);
        
        for(uint256 i = 0; i < length; i ++) {
            // Grab the combined warrior data in storage.
            warriorsData[i] = tournamentQueue[i * DATA_SIZE + 1];
        }
        return warriorsData;
    }
    
    function getTournamentState() external view returns
    (uint256 contendersCount, uint256 bank, uint256 admissionStartBlock, uint256 endBlock, uint256 incentiveReward)
    {
    	contendersCount = tournamentQueueSize;
    	bank = currentTournamentBank;
    	admissionStartBlock = getTournamentAdmissionBlock();   
    	endBlock = tournamentEndBlock;
    	incentiveReward = _computeTournamentIncentiveReward(bank, _computeIncentiveCut(bank, tournamentIncentiveCut));
    }
    
    function _repackToCombinedIds(uint256[] memory _warriorsData) internal view {
        uint256 length = _warriorsData.length;
        for(uint256 i = 0; i < length; i ++) {
            _warriorsData[i] = tournamentQueue[i * DATA_SIZE];
        }
    }
    
    // @dev Computes warrior pvp reward
    // @param _totalBet - total bet from both competitors.
    function _computeTournamentBooty(uint256 _currentBank, uint256 _contenderResult, uint256 _totalBattles) internal pure returns (uint256){
        // NOTE: We don't use SafeMath (or similar) in this function because _currentBank max is equal ~ 20000000 finney,
        // _totalBattles is guaranteed to be > 0 and <= 400, and (tournamentOwnersCut + tournamentIncentiveCut) <= 10000 (see the require()
        // statement in the Tournament constructor). The result of this
        // function is always guaranteed to be <= _reward.
        // return _currentBank * (10000 - tournamentOwnersCut - _incentiveCut) * _result / 10000 / _totalBattles;
        return _currentBank * _contenderResult / _totalBattles;
        
    }
    
    function _grandTournamentBooty(uint256 _warriorIds, uint256 _currentBank, uint256 _contenderResult, uint256 _totalBattles)
    internal returns (uint256)
    {
        uint256 warriorId = CryptoUtils._unpackWarriorId(_warriorIds, 0);
        address owner = warriorToOwner[warriorId];
        uint256 booty = _computeTournamentBooty(_currentBank, _contenderResult, _totalBattles);
        return sendBooty(owner, booty);
    }
    
    function _grandTournamentRewards(uint256 _currentBank, uint256[] memory _warriorsData, uint32[] memory _results) internal returns (uint256){
        uint256 length = _warriorsData.length;
        uint256 totalBattles = CryptoUtils._getTournamentBattles(length) * 10000;//*10000 required for booty computation
        uint256 incentiveCut = _computeIncentiveCut(_currentBank, tournamentIncentiveCut);
        uint256 contenderCut = _computeTournamentContenderCut(incentiveCut);
        
        uint256 failedBooty = 0;
        for(uint256 i = 0; i < length; i ++) {
            //grand rewards
            failedBooty += _grandTournamentBooty(_warriorsData[i], _currentBank, _results[i] * contenderCut, totalBattles);
        }
        //send beneficiary fee
        failedBooty += sendBooty(pvpListener.getBeneficiary(), _computeTournamentBeneficiaryFee(_currentBank));
        if (failedBooty > 0) {
            totalBooty += failedBooty;
        }
        return _computeTournamentIncentiveReward(_currentBank, incentiveCut);
    }
    
    function _repackToWarriorOwners(uint256[] memory warriorsData) internal view {
        uint256 length = warriorsData.length;
        for (uint256 i = 0; i < length; i ++) {
            warriorsData[i] = uint256(warriorToOwner[CryptoUtils._unpackWarriorId(warriorsData[i], 0)]);
        }
    }
    
    function _triggerFinishTournament() internal returns(uint256){
        //hold 10 random battles for each composite warrior
        uint256[] memory warriorsData = getCombinedWarriors();
        uint32[] memory results = CryptoUtils.getTournamentBattleResults(warriorsData, tournamentEndBlock - 1);
        //repack combined warriors id
        _repackToCombinedIds(warriorsData);
        //notify pvp listener
        pvpListener.tournamentFinished(warriorsData);
        //reschedule
        //clear tournament
        tournamentQueueSize = 0;
        //schedule new tournament
        _scheduleTournament();
        
        uint256 currentBank = currentTournamentBank;
        currentTournamentBank = 0;//nullify before sending to users
        //grand rewards, not susceptible to reentry attack
        //because of require(tournamentEndBlock <= block.number)
        //and require(tournamentQueueSize > 0) and currentTournamentBank == 0
        uint256 incentiveReward = _grandTournamentRewards(currentBank, warriorsData, results);
        
        currentTournamentBank = nextTournamentBank;
        nextTournamentBank = 0;
        
        _repackToWarriorOwners(warriorsData);
        
        //emit event
        TournamentFinished(warriorsData, results, currentBank);

        return incentiveReward;
    }
    
    function finishTournament() external TournamentNotPaused {
        //make all the checks
        // tournament is ready to be executed
        require(tournamentEndBlock <= block.number);
        // we have participants
        require(tournamentQueueSize > 0);
        
        uint256 incentiveReward = _triggerFinishTournament();
        
        //give reward for incentive
        safeSend(msg.sender, incentiveReward);
    }
    
    
    // @dev Remove all PVP contenders from PVP queue 
    //  and return all entrance fees to warrior owners.
    //  NB: this is emergency method, used only in f%#^@up situation
    function removeAllTournamentContenders() external onlyOwner TournamentPaused {
        //remove all pvp contenders
        uint256 length = tournamentQueueSize;
        
        uint256 warriorId;
        uint256 failedBooty;
        uint256 i;

        uint256 fee;
        uint256 bank = currentTournamentBank;
        
        uint256[] memory warriorsData = new uint256[](length);
        //get tournament warriors
        for(i = 0; i < length; i ++) {
            warriorsData[i] = tournamentQueue[i * DATA_SIZE];
        }
        //notify pvp listener
        pvpListener.tournamentFinished(warriorsData);
        //return entrance fee to warrior owners
     	currentTournamentBank = 0;
        tournamentQueueSize = 0;

        for(i = length - 1; i >= 0; i --) {
            //return entrance fee
            warriorId = CryptoUtils._unpackWarriorId(warriorsData[i], 0);
            //compute contender entrance fee
			fee = bank - (bank * 10000 / (tournamentEntranceFeeCut * (10000 - THRESHOLD) / 10000 + 10000));
			//return entrance fee to owner
	        failedBooty += sendBooty(warriorToOwner[warriorId], fee);
	        //subtract fee from bank, for next use
	        bank -= fee;
        }
        currentTournamentBank = bank;
        totalBooty += failedBooty;
    }
}

contract BattleProvider is Tournament {
    
    function BattleProvider(address _pvpListener, uint256 _pvpCut, uint256 _tournamentCut, uint256 _incentiveCut, 
    uint256 _tournamentOwnersCut, uint256 _tournamentIncentiveCut) public 
    Tournament(_pvpCut, _tournamentCut, _incentiveCut, _tournamentOwnersCut, _tournamentIncentiveCut) 
    {
        PVPListenerInterface candidateContract = PVPListenerInterface(_pvpListener);
        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isPVPListener());
        // Set the new contract address
        pvpListener = candidateContract;
        
        // the creator of the contract is the initial owner
        owner = msg.sender;
    }
    
    
    // @dev Sanity check that allows us to ensure that we are pointing to the
    // right BattleProvider in our setBattleProviderAddress() call.
    function isPVPProvider() external pure returns (bool) {
        return true;
    }
    
    function setSecondsPerBlock(uint256 secs) external onlyOwner {
        secondsPerBlock = secs;
    }
}


/* warrior identity generator*/
contract WarriorGenerator is Pausable, SanctuaryInterface {
    
    CryptoWarriorCore public coreContract;
    
    /* LIMITS */
    uint32[19] public parameters;/*  = [
        uint32(10),//0_bodyColorMax3
        uint32(10),//1_eyeshMax4
        uint32(10),//2_mouthMax5
        uint32(20),//3_heirMax6
        uint32(10),//4_heirColorMax7
        uint32(3),//5_armorMax8
        uint32(3),//6_weaponMax9
        uint32(3),//7_hatMax10
        uint32(4),//8_runesMax11
        uint32(1),//9_wingsMax12
        uint32(10),//10_petMax13
        uint32(6),//11_borderMax14
        uint32(6),//12_backgroundMax15
        uint32(10),//13_unique
        uint32(900),//14_legendary
        uint32(9000),//15_mythic
        uint32(90000),//16_rare
        uint32(900000),//17_uncommon
        uint32(0)//18_uniqueTotal
    ];*/
    

    function changeParameter(uint32 _paramIndex, uint32 _value) external onlyOwner {
        CryptoUtils._changeParameter(_paramIndex, _value, parameters);
    }

    // / @dev simply a boolean to indicate this is the contract we expect to be
    function isSanctuary() public pure returns (bool){
        return true;
    }

    // / @dev generate new warrior identity
    // / @param _heroIdentity Genes of warrior that invoked resurrection, if 0 => Demigod gene that signals to generate unique warrior
    // / @param _heroLevel Level of the warrior
    // / @_targetBlock block number from which hash will be taken
    // / @_perkId special perk id, like MINER(1)
    // / @return the identity that are supposed to be passed down to newly arisen warrior
    function generateWarrior(uint256 _heroIdentity, uint256 _heroLevel, uint256 _targetBlock, uint256 _perkId) 
    public returns (uint256) 
    {
        //only core contract can call this method
        require(msg.sender == address(coreContract));
        
        return _generateIdentity(_heroIdentity, _heroLevel, _targetBlock, _perkId);
    }
    
    function _generateIdentity(uint256 _heroIdentity, uint256 _heroLevel, uint256 _targetBlock, uint256 _perkId) internal returns(uint256){
        
        //get memory copy, to reduce storage read requests
        uint32[19] memory memoryParams = parameters;
        //generate warrior identity
        uint256 identity = CryptoUtils.generateWarrior(_heroIdentity, _heroLevel, _targetBlock, _perkId, memoryParams);
        
        //validate before pushing changes to storage
        CryptoUtils._validateIdentity(identity, memoryParams);
        //push changes to storage
        CryptoUtils._recordWarriorData(identity, parameters);
        
        return identity;
    }
}

contract WarriorSanctuary is WarriorGenerator {
    uint256 internal constant SUMMONING_SICKENESS = 12 hours;
    uint256 internal constant RITUAL_DURATION = 15 minutes;
    /// @notice The payment required to use startRitual().
    uint256 public ritualFee = 10 finney;
    
    uint256 public constant RITUAL_COMPENSATION = 2 finney;
    
    mapping(address => uint256) public soulCounter;
    //
    mapping(address => uint256) public ritualTimeBlock;
    
    bool public recoveryAllowed = true;
    
    event WarriorBurned(uint256 warriorId, address owner);
    event RitualStarted(address owner, uint256 numberOfSouls);
    event RitualFinished(address owner, uint256 numberOfSouls, uint256 newWarriorId);
    
    
    function WarriorSanctuary(address _coreContract, uint32[] _settings) public {
        uint256 length = _settings.length;
        require(length == 18);
        require(_settings[8] == 4);//check runes max
        require(_settings[10] == 10);//check pets max
        require(_settings[11] == 5);//check border max
        require(_settings[12] == 6);//check background max
        //setup parameters
        for(uint256 i = 0; i < length; i ++) {
            parameters[i] = _settings[i];
        }	
        
        //set core
        CryptoWarriorCore coreCondidat = CryptoWarriorCore(_coreContract);
        require(coreCondidat.isPVPListener());
        coreContract = coreCondidat;
        
    }
    
    function recoverSouls(address[] owners, uint256[] souls, uint256[] blocks) external onlyOwner {
        require(recoveryAllowed);
        
        uint256 length = owners.length;
        require(length == souls.length && length == blocks.length);
        
        for(uint256 i = 0; i < length; i ++) {
            soulCounter[owners[i]] = souls[i];
            ritualTimeBlock[owners[i]] = blocks[i];
        }
        
        recoveryAllowed = false;
    }
    
    
    //burn warrior
    function burnWarrior(uint256 _warriorId) whenNotPaused external {
        coreContract.burnWarrior(_warriorId, msg.sender);
        
        soulCounter[msg.sender] ++;
        
        WarriorBurned(_warriorId, msg.sender);
    }
   
    
    function startRitual() whenNotPaused external payable {
        // Checks for payment.
        require(msg.value >= ritualFee);
        
        uint256 souls = soulCounter[msg.sender];
        // Check that address has at least 10 burned souls
        require(souls >= 10);
        //
        //Check that no rituals are in progress
        require(ritualTimeBlock[msg.sender] == 0);
        
        ritualTimeBlock[msg.sender] = RITUAL_DURATION / coreContract.secondsPerBlock() + block.number;
        
        // Calculate any excess funds included in msg.value. If the excess
        // is anything worth worrying about, transfer it back to message owner.
        // NOTE: We checked above that the msg.value is greater than or
        // equal to the price so this cannot underflow.
        uint256 feeExcess = msg.value - ritualFee;

        // Return the funds. This is not susceptible 
        // to a re-entry attack because of _isReadyToPVE check
        // will fail
        if (feeExcess > 0) {
            msg.sender.transfer(feeExcess);
        }
        //send battle fee to beneficiary
        coreContract.getBeneficiary().transfer(ritualFee - RITUAL_COMPENSATION);
        
        RitualStarted(msg.sender, souls);
    }
    
    
    //arise warrior
    function finishRitual(address _owner) whenNotPaused external {
        // Check ritual time is over
        uint256 timeBlock = ritualTimeBlock[_owner];
        require(timeBlock > 0 && timeBlock <= block.number);
        
        uint256 souls = soulCounter[_owner];
        
        require(souls >= 10);
        
        uint256 identity = _generateIdentity(uint256(_owner), souls, timeBlock - 1, 0);
        
        uint256 warriorId = coreContract.ariseWarrior(identity, _owner, block.number + (SUMMONING_SICKENESS / coreContract.secondsPerBlock()));
    
        soulCounter[_owner] = 0;
        ritualTimeBlock[_owner] = 0;
        //send compensation
        msg.sender.transfer(RITUAL_COMPENSATION);
        
        RitualFinished(_owner, 10, warriorId);
    }
    
    function setRitualFee(uint256 _pveRitualFee) external onlyOwner {
        require(_pveRitualFee > RITUAL_COMPENSATION);
        ritualFee = _pveRitualFee;
    }
}

contract AuctionBase {
	uint256 public constant PRICE_CHANGE_TIME_STEP = 15 minutes;
    //
    struct Auction{
        address seller;
        uint128 startingPrice;
        uint128 endingPrice;
        uint64 duration;
        uint64 startedAt;
    }
    mapping (uint256 => Auction) internal tokenIdToAuction;
    uint256 public ownerCut;
    ERC721 public nonFungibleContract;

    event AuctionCreated(uint256 tokenId, address seller, uint256 startingPrice);

    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner, address seller);

    event AuctionCancelled(uint256 tokenId, address seller);

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool){
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    function _escrow(address _owner, uint256 _tokenId) internal{
        nonFungibleContract.transferFrom(_owner, address(this), _tokenId);
    }

    function _transfer(address _receiver, uint256 _tokenId) internal{
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    function _addAuction(uint256 _tokenId, Auction _auction) internal{
        require(_auction.duration >= 1 minutes);
        
        tokenIdToAuction[_tokenId] = _auction;
        
        AuctionCreated(uint256(_tokenId), _auction.seller, _auction.startingPrice);
    }

    function _cancelAuction(uint256 _tokenId, address _seller) internal{
        _removeAuction(_tokenId);
        
        _transfer(_seller, _tokenId);
        
        AuctionCancelled(_tokenId, _seller);
    }

    function _bid(uint256 _tokenId, uint256 _bidAmount) internal returns (uint256){
        
        Auction storage auction = tokenIdToAuction[_tokenId];
        
        require(_isOnAuction(auction));
        
        uint256 price = _currentPrice(auction);
        
        require(_bidAmount >= price);
        
        address seller = auction.seller;
        
        _removeAuction(_tokenId);
        
        if (price > 0) {
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;
            seller.transfer(sellerProceeds);
            nonFungibleContract.getBeneficiary().transfer(auctioneerCut);
        }
        
        uint256 bidExcess = _bidAmount - price;
        
        msg.sender.transfer(bidExcess);
        
        AuctionSuccessful(_tokenId, price, msg.sender, seller);
        
        return price;
    }

    function _removeAuction(uint256 _tokenId) internal{
        delete tokenIdToAuction[_tokenId];
    }

    function _isOnAuction(Auction storage _auction) internal view returns (bool){
        return (_auction.startedAt > 0);
    }

    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256){
        uint256 secondsPassed = 0;
        
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }
        
        return _computeCurrentPrice(_auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed);
    }
    
    function _computeCurrentPrice(uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed)
        internal
        pure
        returns (uint256){
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed / PRICE_CHANGE_TIME_STEP * PRICE_CHANGE_TIME_STEP) / int256(_duration);
            
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            
            return uint256(currentPrice);
        }
    }

    function _computeCut(uint256 _price) internal view returns (uint256){
        
        return _price * ownerCut / 10000;
    }
}

contract SaleClockAuction is Pausable, AuctionBase {
    
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9f40b779);
    
    bool public isSaleClockAuction = true;
    uint256 public minerSaleCount;
    uint256[5] public lastMinerSalePrices;

    function SaleClockAuction(address _nftAddress, uint256 _cut) public{
        require(_cut <= 10000);
        ownerCut = _cut;
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        require(candidateContract.getBeneficiary() != address(0));
        
        nonFungibleContract = candidateContract;
    }

    function cancelAuction(uint256 _tokenId)
        external{
        
        AuctionBase.Auction storage auction = tokenIdToAuction[_tokenId];
        
        require(_isOnAuction(auction));
        
        address seller = auction.seller;
        
        require(msg.sender == seller);
        
        _cancelAuction(_tokenId, seller);
    }

    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        external{
        AuctionBase.Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256){
        
        AuctionBase.Auction storage auction = tokenIdToAuction[_tokenId];
        
        require(_isOnAuction(auction));
        
        return _currentPrice(auction);
    }
    
    function createAuction(uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller)
        whenNotPaused
        external{
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));
        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        
        AuctionBase.Auction memory auction = Auction(_seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now));
        
        _addAuction(_tokenId, auction);
    }
    
    function bid(uint256 _tokenId)
        whenNotPaused
        external
        payable{
        
        address seller = tokenIdToAuction[_tokenId].seller;
        
        uint256 price = _bid(_tokenId, msg.value);
        
        _transfer(msg.sender, _tokenId);
        
        if (seller == nonFungibleContract.getBeneficiary()) {
            lastMinerSalePrices[minerSaleCount % 5] = price;
            minerSaleCount++;
        }
    }

    function averageMinerSalePrice() external view returns (uint256){
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++){
            sum += lastMinerSalePrices[i];
        }
        return sum / 5;
    }
    
    /**getAuctionsById returns packed actions data
     * @param tokenIds ids of tokens, whose auction's must be active 
     * @return auctionData as uint256 array
     * @return stepSize number of fields describing auction 
     */
    function getAuctionsById(uint32[] tokenIds) external view returns(uint256[] memory auctionData, uint32 stepSize) {
        stepSize = 6;
        auctionData = new uint256[](tokenIds.length * stepSize);
        
        uint32 tokenId;
        for(uint32 i = 0; i < tokenIds.length; i ++) {
            tokenId = tokenIds[i];
            AuctionBase.Auction storage auction = tokenIdToAuction[tokenId];
            require(_isOnAuction(auction));
            _setTokenData(auctionData, auction, tokenId, i * stepSize);
        }
    }
    
    /**getAuctions returns packed actions data
     * @param fromIndex warrior index from global warrior storage (aka warriorId)
     * @param count Number of auction's to find, if count == 0, then exact warriorId(fromIndex) will be searched
     * @return auctionData as uint256 array
     * @return stepSize number of fields describing auction 
     */
    function getAuctions(uint32 fromIndex, uint32 count) external view returns(uint256[] memory auctionData, uint32 stepSize) {
        stepSize = 6;
        if (count == 0) {
            AuctionBase.Auction storage auction = tokenIdToAuction[fromIndex];
	        	require(_isOnAuction(auction));
	        	auctionData = new uint256[](1 * stepSize);
	        	_setTokenData(auctionData, auction, fromIndex, count);
	        	return (auctionData, stepSize);
        } else {
            uint256 totalWarriors = nonFungibleContract.totalSupply();
	        if (totalWarriors == 0) {
	            // Return an empty array
	            return (new uint256[](0), stepSize);
	        } else {
	
	            uint32 totalSize = 0;
	            uint32 tokenId;
	            uint32 size = 0;
				auctionData = new uint256[](count * stepSize);
	            for (tokenId = 0; tokenId < totalWarriors && size < count; tokenId++) {
	                AuctionBase.Auction storage auction1 = tokenIdToAuction[tokenId];
	        
		        		if (_isOnAuction(auction1)) {
		        		    totalSize ++;
		        		    if (totalSize > fromIndex) {
		        		        _setTokenData(auctionData, auction1, tokenId, size++ * stepSize);//warriorId;
		        		    }
		        		}
	            }
	            
	            if (size < count) {
	                size *= stepSize;
	                uint256[] memory repack = new uint256[](size);
	                for(tokenId = 0; tokenId < size; tokenId++) {
	                    repack[tokenId] = auctionData[tokenId];
	                }
	                return (repack, stepSize);
	            }
	
	            return (auctionData, stepSize);
	        }
        }
    }
    
    // @dev Returns auction info for an NFT on auction.
    // @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId) external view returns(
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
        ){
        
        Auction storage auction = tokenIdToAuction[_tokenId];
        
        require(_isOnAuction(auction));
        
        return (auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt);
    }
    
    //pack NFT data into specified array
    function _setTokenData(uint256[] memory auctionData, 
        AuctionBase.Auction storage auction, uint32 tokenId, uint32 index
    ) internal view {
        auctionData[index] = uint256(tokenId);//0
        auctionData[index + 1] = uint256(auction.seller);//1
        auctionData[index + 2] = uint256(auction.startingPrice);//2
        auctionData[index + 3] = uint256(auction.endingPrice);//3
        auctionData[index + 4] = uint256(auction.duration);//4
        auctionData[index + 5] = uint256(auction.startedAt);//5
    }
    
}