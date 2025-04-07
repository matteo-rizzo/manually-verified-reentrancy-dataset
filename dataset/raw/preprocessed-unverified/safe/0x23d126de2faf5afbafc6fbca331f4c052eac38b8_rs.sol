/**

 *Submitted for verification at Etherscan.io on 2019-03-04

*/



pragma solidity ^0.5.0;



// thanks to https://github.com/willitscale/solidity-util and https://github.com/Arachnid/solidity-stringutils









/**

* @title Ownable

* @dev The Ownable contract has an owner address, and provides basic authorization control

* functions, this simplifies the implementation of "user permissions".

*/

















contract SnowflakeResolver is Ownable {

    string public snowflakeName;

    string public snowflakeDescription;



    address public snowflakeAddress;



    bool public callOnAddition;

    bool public callOnRemoval;



    constructor(

        string memory _snowflakeName, string memory _snowflakeDescription,

        address _snowflakeAddress,

        bool _callOnAddition, bool _callOnRemoval

    )

        public

    {

        snowflakeName = _snowflakeName;

        snowflakeDescription = _snowflakeDescription;



        setSnowflakeAddress(_snowflakeAddress);



        callOnAddition = _callOnAddition;

        callOnRemoval = _callOnRemoval;

    }



    modifier senderIsSnowflake() {

        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");

        _;

    }



    // this can be overriden to initialize other variables, such as e.g. an ERC20 object to wrap the HYDRO token

    function setSnowflakeAddress(address _snowflakeAddress) public onlyOwner {

        snowflakeAddress = _snowflakeAddress;

    }



    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver

    // this implementation **must** use the senderIsSnowflake modifier

    // returning false will disallow users from adding the contract as a resolver

    function onAddition(uint ein, uint allowance, bytes memory extraData) public returns (bool);



    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver

    // this function **must** use the senderIsSnowflake modifier

    // returning false soft prevents users from removing the contract as a resolver

    // however, note that they can force remove the resolver, bypassing onRemoval

    function onRemoval(uint ein, bytes memory extraData) public returns (bool);



    function transferHydroBalanceTo(uint einTo, uint amount) internal {

        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());

        require(hydro.approveAndCall(snowflakeAddress, amount, abi.encode(einTo)), "Unsuccessful approveAndCall.");

    }



    function withdrawHydroBalanceTo(address to, uint amount) internal {

        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());

        require(hydro.transfer(to, amount), "Unsuccessful transfer.");

    }



    function transferHydroBalanceToVia(address via, uint einTo, uint amount, bytes memory snowflakeCallBytes) internal {

        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());

        require(

            hydro.approveAndCall(

                snowflakeAddress, amount, abi.encode(true, address(this), via, einTo, snowflakeCallBytes)

            ),

            "Unsuccessful approveAndCall."

        );

    }



    function withdrawHydroBalanceToVia(address via, address to, uint amount, bytes memory snowflakeCallBytes) internal {

        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());

        require(

            hydro.approveAndCall(

                snowflakeAddress, amount, abi.encode(false, address(this), via, to, snowflakeCallBytes)

            ),

            "Unsuccessful approveAndCall."

        );

    }

}







contract ClientRaindrop is SnowflakeResolver {

    // attach the StringUtils library

    using StringUtils for string;

    using StringUtils for StringUtils.slice;



    // other SCs

    HydroInterface private hydroToken;

    IdentityRegistryInterface private identityRegistry;

    OldClientRaindropInterface private oldClientRaindrop;



    // staking requirements

    uint public hydroStakeUser;

    uint public hydroStakeDelegatedUser;



    // User account template

    struct User {

        uint ein;

        address _address;

        string casedHydroID;

        bool initialized;

        bool destroyed;

    }



    // Mapping from uncased hydroID hashes to users

    mapping (bytes32 => User) private userDirectory;

    // Mapping from EIN to uncased hydroID hashes

    mapping (uint => bytes32) private einDirectory;

    // Mapping from address to uncased hydroID hashes

    mapping (address => bytes32) private addressDirectory;



    constructor(

        address snowflakeAddress, address oldClientRaindropAddress, uint _hydroStakeUser, uint _hydroStakeDelegatedUser

    )

        SnowflakeResolver(

            "Client Raindrop", "A registry that links EINs to HydroIDs to power Client Raindrop MFA.",

            snowflakeAddress,

            true, true

        )

        public

    {

        setSnowflakeAddress(snowflakeAddress);

        setOldClientRaindropAddress(oldClientRaindropAddress);

        setStakes(_hydroStakeUser, _hydroStakeDelegatedUser);

    }



    // Requires an address to have a minimum number of Hydro

    modifier requireStake(address _address, uint stake) {

        require(hydroToken.balanceOf(_address) >= stake, "Insufficient staked HYDRO balance.");

        _;

    }



    // set the snowflake address, and hydro token + identity registry contract wrappers

    function setSnowflakeAddress(address snowflakeAddress) public onlyOwner() {

        super.setSnowflakeAddress(snowflakeAddress);



        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);

        hydroToken = HydroInterface(snowflake.hydroTokenAddress());

        identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());

    }



    // set the old client raindrop address

    function setOldClientRaindropAddress(address oldClientRaindropAddress) public onlyOwner() {

        oldClientRaindrop = OldClientRaindropInterface(oldClientRaindropAddress);

    }



    // set minimum hydro balances required for sign ups

    function setStakes(uint _hydroStakeUser, uint _hydroStakeDelegatedUser) public onlyOwner() {

        // <= the airdrop amount

        require(_hydroStakeUser <= 222222 * 10**18, "Stake is too high.");

        hydroStakeUser = _hydroStakeDelegatedUser;



        // <= 1% of total supply

        require(_hydroStakeDelegatedUser <= hydroToken.totalSupply() / 100, "Stake is too high.");

        hydroStakeDelegatedUser = _hydroStakeDelegatedUser;

    }



    // function for users calling signup for themselves

    function signUp(address _address, string memory casedHydroId) public requireStake(msg.sender, hydroStakeUser) {

        _signUp(identityRegistry.getEIN(msg.sender), casedHydroId, _address);

    }



    // function for users signing up through the snowflake provider

    function onAddition(uint ein, uint, bytes memory extraData)

        // solium-disable-next-line security/no-tx-origin

        public senderIsSnowflake() requireStake(tx.origin, hydroStakeDelegatedUser) returns (bool)

    {

        (address _address, string memory casedHydroID) = abi.decode(extraData, (address, string));

        require(identityRegistry.isProviderFor(ein, msg.sender), "Snowflake is not a Provider for the passed EIN.");

        _signUp(ein, casedHydroID, _address);

     

        return true;

    }



    // Common internal logic for all user signups

    function _signUp(uint ein, string memory casedHydroID, address _address) internal {

        require(bytes(casedHydroID).length > 2 && bytes(casedHydroID).length < 33, "HydroID has invalid length.");

        require(identityRegistry.isResolverFor(ein, address(this)), "The passed EIN has not set this resolver.");

        require(

            identityRegistry.isAssociatedAddressFor(ein, _address),

            "The passed address is not associated with the calling Identity."

        );

        checkForOldHydroID(casedHydroID, _address);



        bytes32 uncasedHydroIDHash = keccak256(abi.encodePacked(casedHydroID.toSlice().copy().toString().lower()));

        // check conditions specific to this resolver

        require(hydroIDAvailable(uncasedHydroIDHash), "HydroID is unavailable.");

        require(einDirectory[ein] == bytes32(0), "EIN is already mapped to a HydroID.");

        require(addressDirectory[_address] == bytes32(0), "Address is already mapped to a HydroID.");



        // update mappings

        userDirectory[uncasedHydroIDHash] = User(ein, _address, casedHydroID, true, false);

        einDirectory[ein] = uncasedHydroIDHash;

        addressDirectory[_address] = uncasedHydroIDHash;



        emit HydroIDClaimed(ein, casedHydroID, _address);

    }



    function checkForOldHydroID(string memory casedHydroID, address _address) public view {

        bool usernameTaken = oldClientRaindrop.userNameTaken(casedHydroID);

        if (usernameTaken) {

            (, address takenAddress) = oldClientRaindrop.getUserByName(casedHydroID);

            require(_address == takenAddress, "This Hydro ID is already claimed by another address.");

        }

    }



    function onRemoval(uint ein, bytes memory) public senderIsSnowflake() returns (bool) {

        bytes32 uncasedHydroIDHash = einDirectory[ein];

        assert(uncasedHydroIDHashActive(uncasedHydroIDHash));



        emit HydroIDDestroyed(

            ein, userDirectory[uncasedHydroIDHash].casedHydroID, userDirectory[uncasedHydroIDHash]._address

        );



        delete addressDirectory[userDirectory[uncasedHydroIDHash]._address];

        delete einDirectory[ein];

        delete userDirectory[uncasedHydroIDHash].casedHydroID;

        delete userDirectory[uncasedHydroIDHash]._address;

        userDirectory[uncasedHydroIDHash].destroyed = true;



        return true;

    }





    // returns whether a given hydroID is available

    function hydroIDAvailable(string memory uncasedHydroID) public view returns (bool available) {

        return hydroIDAvailable(keccak256(abi.encodePacked(uncasedHydroID.lower())));

    }



    // Returns a bool indicating whether a given uncasedHydroIDHash is available

    function hydroIDAvailable(bytes32 uncasedHydroIDHash) private view returns (bool) {

        return !userDirectory[uncasedHydroIDHash].initialized;

    }



    // returns whether a given hydroID is destroyed

    function hydroIDDestroyed(string memory uncasedHydroID) public view returns (bool destroyed) {

        return hydroIDDestroyed(keccak256(abi.encodePacked(uncasedHydroID.lower())));

    }



    // Returns a bool indicating whether a given hydroID is destroyed

    function hydroIDDestroyed(bytes32 uncasedHydroIDHash) private view returns (bool) {

        return userDirectory[uncasedHydroIDHash].destroyed;

    }



    // returns whether a given hydroID is active

    function hydroIDActive(string memory uncasedHydroID) public view returns (bool active) {

        return uncasedHydroIDHashActive(keccak256(abi.encodePacked(uncasedHydroID.lower())));

    }



    // Returns a bool indicating whether a given hydroID is active

    function uncasedHydroIDHashActive(bytes32 uncasedHydroIDHash) private view returns (bool) {

        return !hydroIDAvailable(uncasedHydroIDHash) && !hydroIDDestroyed(uncasedHydroIDHash);

    }





    // Returns details by uncased hydroID

    function getDetails(string memory uncasedHydroID) public view

        returns (uint ein, address _address, string memory casedHydroID)

    {

        User storage user = getDetails(keccak256(abi.encodePacked(uncasedHydroID.lower())));

        return (user.ein, user._address, user.casedHydroID);

    }



    // Returns details by EIN

    function getDetails(uint ein) public view returns (address _address, string memory casedHydroID) {

        User storage user = getDetails(einDirectory[ein]);

        return (user._address, user.casedHydroID);

    }



    // Returns details by address

    function getDetails(address _address) public view returns (uint ein, string memory casedHydroID) {

        User storage user = getDetails(addressDirectory[_address]);

        return (user.ein, user.casedHydroID);

    }



    // common logic for all getDetails

    function getDetails(bytes32 uncasedHydroIDHash) private view returns (User storage) {

        require(uncasedHydroIDHashActive(uncasedHydroIDHash), "HydroID is not active.");

        return userDirectory[uncasedHydroIDHash];

    }



    // Events for when a user signs up for Raindrop Client and when their account is deleted

    event HydroIDClaimed(uint indexed ein, string hydroID, address userAddress);

    event HydroIDDestroyed(uint indexed ein, string hydroID, address userAddress);

}