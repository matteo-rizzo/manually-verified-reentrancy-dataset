pragma solidity 0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

  function totalSupply() constant public returns (uint);



  function balanceOf(address who) constant public returns (uint256);



  function transfer(address to, uint256 value) public returns (bool);



  function allowance(address owner, address spender) public constant returns (uint256);



  function transferFrom(address from, address to, uint256 value) public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);



  event Approval(address indexed _owner, address indexed _spender, uint256 _value);



  event Transfer(address indexed _from, address indexed _to, uint256 _value);

}



/// @dev `Owned` is a base level contract that assigns an `owner` that can be

///  later changed





contract Callable is Owned {



    //sender => _allowed

    mapping(address => bool) public callers;



    //modifiers

    modifier onlyCaller {

        require(callers[msg.sender]);

        _;

    }



    //management of the repositories

    function updateCaller(address _caller, bool allowed) public onlyOwner {

        callers[_caller] = allowed;

    }

}



contract EternalStorage is Callable {



    mapping(bytes32 => uint) uIntStorage;

    mapping(bytes32 => string) stringStorage;

    mapping(bytes32 => address) addressStorage;

    mapping(bytes32 => bytes) bytesStorage;

    mapping(bytes32 => bool) boolStorage;

    mapping(bytes32 => int) intStorage;



    // *** Getter Methods ***

    function getUint(bytes32 _key) external view returns (uint) {

        return uIntStorage[_key];

    }



    function getString(bytes32 _key) external view returns (string) {

        return stringStorage[_key];

    }



    function getAddress(bytes32 _key) external view returns (address) {

        return addressStorage[_key];

    }



    function getBytes(bytes32 _key) external view returns (bytes) {

        return bytesStorage[_key];

    }



    function getBool(bytes32 _key) external view returns (bool) {

        return boolStorage[_key];

    }



    function getInt(bytes32 _key) external view returns (int) {

        return intStorage[_key];

    }



    // *** Setter Methods ***

    function setUint(bytes32 _key, uint _value) onlyCaller external {

        uIntStorage[_key] = _value;

    }



    function setString(bytes32 _key, string _value) onlyCaller external {

        stringStorage[_key] = _value;

    }



    function setAddress(bytes32 _key, address _value) onlyCaller external {

        addressStorage[_key] = _value;

    }



    function setBytes(bytes32 _key, bytes _value) onlyCaller external {

        bytesStorage[_key] = _value;

    }



    function setBool(bytes32 _key, bool _value) onlyCaller external {

        boolStorage[_key] = _value;

    }



    function setInt(bytes32 _key, int _value) onlyCaller external {

        intStorage[_key] = _value;

    }



    // *** Delete Methods ***

    function deleteUint(bytes32 _key) onlyCaller external {

        delete uIntStorage[_key];

    }



    function deleteString(bytes32 _key) onlyCaller external {

        delete stringStorage[_key];

    }



    function deleteAddress(bytes32 _key) onlyCaller external {

        delete addressStorage[_key];

    }



    function deleteBytes(bytes32 _key) onlyCaller external {

        delete bytesStorage[_key];

    }



    function deleteBool(bytes32 _key) onlyCaller external {

        delete boolStorage[_key];

    }



    function deleteInt(bytes32 _key) onlyCaller external {

        delete intStorage[_key];

    }

}



/*

 * Database Contract

 * Davy Van Roy

 * Quinten De Swaef

 */

contract FundRepository is Callable {



    using SafeMath for uint256;



    EternalStorage public db;



    //platform -> platformId => _funding

    mapping(bytes32 => mapping(string => Funding)) funds;



    struct Funding {

        address[] funders; //funders that funded tokens

        address[] tokens; //tokens that were funded

        mapping(address => TokenFunding) tokenFunding;

    }



    struct TokenFunding {

        mapping(address => uint256) balance;

        uint256 totalTokenBalance;

    }



    constructor(address _eternalStorage) public {

        db = EternalStorage(_eternalStorage);

    }



    function updateFunders(address _from, bytes32 _platform, string _platformId) public onlyCaller {

        bool existing = db.getBool(keccak256(abi.encodePacked("funds.userHasFunded", _platform, _platformId, _from)));

        if (!existing) {

            uint funderCount = getFunderCount(_platform, _platformId);

            db.setAddress(keccak256(abi.encodePacked("funds.funders.address", _platform, _platformId, funderCount)), _from);

            db.setUint(keccak256(abi.encodePacked("funds.funderCount", _platform, _platformId)), funderCount.add(1));

        }

    }



    function updateBalances(address _from, bytes32 _platform, string _platformId, address _token, uint256 _value) public onlyCaller {

        if (db.getBool(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, _token))) == false) {

            db.setBool(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, _token)), true);

            //add to the list of tokens for this platformId

            uint tokenCount = getFundedTokenCount(_platform, _platformId);

            db.setAddress(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, tokenCount)), _token);

            db.setUint(keccak256(abi.encodePacked("funds.tokenCount", _platform, _platformId)), tokenCount.add(1));

        }



        //add to the balance of this platformId for this token

        db.setUint(keccak256(abi.encodePacked("funds.tokenBalance", _platform, _platformId, _token)), balance(_platform, _platformId, _token).add(_value));



        //add to the balance the user has funded for the request

        db.setUint(keccak256(abi.encodePacked("funds.amountFundedByUser", _platform, _platformId, _from, _token)), amountFunded(_platform, _platformId, _from, _token).add(_value));



        //add the fact that the user has now funded this platformId

        db.setBool(keccak256(abi.encodePacked("funds.userHasFunded", _platform, _platformId, _from)), true);

    }



    function claimToken(bytes32 platform, string platformId, address _token) public onlyCaller returns (uint256) {

        require(!issueResolved(platform, platformId), "Can't claim token, issue is already resolved.");

        uint256 totalTokenBalance = balance(platform, platformId, _token);

        db.deleteUint(keccak256(abi.encodePacked("funds.tokenBalance", platform, platformId, _token)));

        return totalTokenBalance;

    }



    function refundToken(bytes32 _platform, string _platformId, address _owner, address _token) public onlyCaller returns (uint256) {

        require(!issueResolved(_platform, _platformId), "Can't refund token, issue is already resolved.");



        //delete amount from user, so he can't refund again

        uint256 userTokenBalance = amountFunded(_platform, _platformId, _owner, _token);

        db.deleteUint(keccak256(abi.encodePacked("funds.amountFundedByUser", _platform, _platformId, _owner, _token)));





        uint256 oldBalance = balance(_platform, _platformId, _token);

        uint256 newBalance = oldBalance.sub(userTokenBalance);



        require(newBalance <= oldBalance);



        //subtract amount from tokenBalance

        db.setUint(keccak256(abi.encodePacked("funds.tokenBalance", _platform, _platformId, _token)), newBalance);



        return userTokenBalance;

    }



    function finishResolveFund(bytes32 platform, string platformId) public onlyCaller returns (bool) {

        db.setBool(keccak256(abi.encodePacked("funds.issueResolved", platform, platformId)), true);

        db.deleteUint(keccak256(abi.encodePacked("funds.funderCount", platform, platformId)));

        return true;

    }



    //constants

    function getFundInfo(bytes32 _platform, string _platformId, address _funder, address _token) public view returns (uint256, uint256, uint256) {

        return (

        getFunderCount(_platform, _platformId),

        balance(_platform, _platformId, _token),

        amountFunded(_platform, _platformId, _funder, _token)

        );

    }



    function issueResolved(bytes32 _platform, string _platformId) public view returns (bool) {

        return db.getBool(keccak256(abi.encodePacked("funds.issueResolved", _platform, _platformId)));

    }



    function getFundedTokenCount(bytes32 _platform, string _platformId) public view returns (uint256) {

        return db.getUint(keccak256(abi.encodePacked("funds.tokenCount", _platform, _platformId)));

    }



    function getFundedTokensByIndex(bytes32 _platform, string _platformId, uint _index) public view returns (address) {

        return db.getAddress(keccak256(abi.encodePacked("funds.token.address", _platform, _platformId, _index)));

    }



    function getFunderCount(bytes32 _platform, string _platformId) public view returns (uint) {

        return db.getUint(keccak256(abi.encodePacked("funds.funderCount", _platform, _platformId)));

    }



    function getFunderByIndex(bytes32 _platform, string _platformId, uint index) external view returns (address) {

        return db.getAddress(keccak256(abi.encodePacked("funds.funders.address", _platform, _platformId, index)));

    }



    function amountFunded(bytes32 _platform, string _platformId, address _funder, address _token) public view returns (uint256) {

        return db.getUint(keccak256(abi.encodePacked("funds.amountFundedByUser", _platform, _platformId, _funder, _token)));

    }



    function balance(bytes32 _platform, string _platformId, address _token) view public returns (uint256) {

        return db.getUint(keccak256(abi.encodePacked("funds.tokenBalance", _platform, _platformId, _token)));

    }

}



contract ClaimRepository is Callable {

    using SafeMath for uint256;



    EternalStorage public db;



    constructor(address _eternalStorage) public {

        //constructor

        require(_eternalStorage != address(0), "Eternal storage cannot be 0x0");

        db = EternalStorage(_eternalStorage);

    }



    function addClaim(address _solverAddress, bytes32 _platform, string _platformId, string _solver, address _token, uint256 _requestBalance) public onlyCaller returns (bool) {

        if (db.getAddress(keccak256(abi.encodePacked("claims.solver_address", _platform, _platformId))) != address(0)) {

            require(db.getAddress(keccak256(abi.encodePacked("claims.solver_address", _platform, _platformId))) == _solverAddress, "Adding a claim needs to happen with the same claimer as before");

        } else {

            db.setString(keccak256(abi.encodePacked("claims.solver", _platform, _platformId)), _solver);

            db.setAddress(keccak256(abi.encodePacked("claims.solver_address", _platform, _platformId)), _solverAddress);

        }



        uint tokenCount = db.getUint(keccak256(abi.encodePacked("claims.tokenCount", _platform, _platformId)));

        db.setUint(keccak256(abi.encodePacked("claims.tokenCount", _platform, _platformId)), tokenCount.add(1));

        db.setUint(keccak256(abi.encodePacked("claims.token.amount", _platform, _platformId, _token)), _requestBalance);

        db.setAddress(keccak256(abi.encodePacked("claims.token.address", _platform, _platformId, tokenCount)), _token);

        return true;

    }



    function isClaimed(bytes32 _platform, string _platformId) view external returns (bool claimed) {

        return db.getAddress(keccak256(abi.encodePacked("claims.solver_address", _platform, _platformId))) != address(0);

    }



    function getSolverAddress(bytes32 _platform, string _platformId) view external returns (address solverAddress) {

        return db.getAddress(keccak256(abi.encodePacked("claims.solver_address", _platform, _platformId)));

    }



    function getSolver(bytes32 _platform, string _platformId) view external returns (string){

        return db.getString(keccak256(abi.encodePacked("claims.solver", _platform, _platformId)));

    }



    function getTokenCount(bytes32 _platform, string _platformId) view external returns (uint count) {

        return db.getUint(keccak256(abi.encodePacked("claims.tokenCount", _platform, _platformId)));

    }



    function getTokenByIndex(bytes32 _platform, string _platformId, uint _index) view external returns (address token) {

        return db.getAddress(keccak256(abi.encodePacked("claims.token.address", _platform, _platformId, _index)));

    }



    function getAmountByToken(bytes32 _platform, string _platformId, address _token) view external returns (uint token) {

        return db.getUint(keccak256(abi.encodePacked("claims.token.amount", _platform, _platformId, _token)));

    }

}



contract ApproveAndCallFallBack {

  function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;

}



/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[emailÂ protected]>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */











contract Precondition is Owned {



    string public name;

    uint public version;

    bool public active = false;



    constructor(string _name, uint _version, bool _active) public {

        name = _name;

        version = _version;

        active = _active;

    }



    function setActive(bool _active) external onlyOwner {

        active = _active;

    }



    function isValid(bytes32 _platform, string _platformId, address _token, uint256 _value, address _funder) external view returns (bool valid);

}



/*

 * Main FundRequest Contract. The entrypoint for every claim/refund

 * Davy Van Roy

 * Quinten De Swaef

 */

contract FundRequestContract is Callable, ApproveAndCallFallBack {



    using SafeMath for uint256;

    using strings for *;



    event Funded(address indexed from, bytes32 platform, string platformId, address token, uint256 value);



    event Claimed(address indexed solverAddress, bytes32 platform, string platformId, string solver, address token, uint256 value);



    event Refund(address indexed owner, bytes32 platform, string platformId, address token, uint256 value);



    address constant public ETHER_ADDRESS = 0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;



    //repositories

    FundRepository public fundRepository;



    ClaimRepository public claimRepository;



    address public claimSignerAddress;



    Precondition[] public preconditions;



    constructor(address _fundRepository, address _claimRepository) public {

        setFundRepository(_fundRepository);

        setClaimRepository(_claimRepository);

    }



    //ENTRYPOINTS



    /*

     * Public function, can only be called from the outside.

     * Fund an issue, providing a token and value.

     * Requires an allowance > _value of the token.

     */

    function fund(bytes32 _platform, string _platformId, address _token, uint256 _value) external returns (bool success) {

        require(doFunding(_platform, _platformId, _token, _value, msg.sender), "funding with token failed");

        return true;

    }



    /*

     * Public function, can only be called from the outside.

     * Fund an issue, ether as value of the transaction.

     * Requires ether to be whitelisted in a precondition.

     */

    function etherFund(bytes32 _platform, string _platformId) payable external returns (bool success) {

        require(doFunding(_platform, _platformId, ETHER_ADDRESS, msg.value, msg.sender), "funding with ether failed");

        return true;

    }



    /*

     * Public function, supposed to be called from another contract, after receiving approval

     * Funds an issue, expects platform, platformid to be concatted with |AAC| as delimiter and provided as _data

     * Only used with the FundRequest approveAndCall function at the moment. Might be removed later in favor of 2 calls.

     */

    function receiveApproval(address _from, uint _amount, address _token, bytes _data) public {

        var sliced = string(_data).toSlice();

        var platform = sliced.split("|AAC|".toSlice());

        var platformId = sliced.split("|AAC|".toSlice());

        require(doFunding(platform.toBytes32(), platformId.toString(), _token, _amount, _from));

    }



    /*

     * Claim: Public function, only supposed to be called from the outside

     * Anyone can call this function, but a valid signature from FundRequest is required

     */

    function claim(bytes32 platform, string platformId, string solver, address solverAddress, bytes32 r, bytes32 s, uint8 v) public returns (bool) {

        require(validClaim(platform, platformId, solver, solverAddress, r, s, v), "Claimsignature was not valid");

        uint256 tokenCount = fundRepository.getFundedTokenCount(platform, platformId);

        for (uint i = 0; i < tokenCount; i++) {

            address token = fundRepository.getFundedTokensByIndex(platform, platformId, i);

            uint256 tokenAmount = fundRepository.claimToken(platform, platformId, token);

            if (token == ETHER_ADDRESS) {

                solverAddress.transfer(tokenAmount);

            } else {

                require(ERC20(token).transfer(solverAddress, tokenAmount), "transfer of tokens from contract failed");

            }

            require(claimRepository.addClaim(solverAddress, platform, platformId, solver, token, tokenAmount), "adding claim to repository failed");

            emit Claimed(solverAddress, platform, platformId, solver, token, tokenAmount);

        }

        require(fundRepository.finishResolveFund(platform, platformId), "Resolving the fund failed");

        return true;

    }



    /*

     * Claim: Public function, only supposed to be called from the outside

     * Only FundRequest can call this function for now, which will refund a user for a specific issue.

     */

    function refund(bytes32 _platform, string _platformId, address _funder) external onlyCaller returns (bool) {

        uint256 tokenCount = fundRepository.getFundedTokenCount(_platform, _platformId);

        for (uint i = 0; i < tokenCount; i++) {

            address token = fundRepository.getFundedTokensByIndex(_platform, _platformId, i);

            uint256 tokenAmount = fundRepository.refundToken(_platform, _platformId, _funder, token);

            if (tokenAmount > 0) {

                if (token == ETHER_ADDRESS) {

                    _funder.transfer(tokenAmount);

                } else {

                    require(ERC20(token).transfer(_funder, tokenAmount), "transfer of tokens from contract failed");

                }

            }

            emit Refund(_funder, _platform, _platformId, token, tokenAmount);

        }

    }



    /*

     * only called from within the this contract itself, will actually do the funding

     */

    function doFunding(bytes32 _platform, string _platformId, address _token, uint256 _value, address _funder) internal returns (bool success) {

        if (_token == ETHER_ADDRESS) {

            //must check this, so we don't have people foefeling with the amounts

            require(msg.value == _value);

        }

        require(!fundRepository.issueResolved(_platform, _platformId), "Can't fund tokens, platformId already claimed");

        for (uint idx = 0; idx < preconditions.length; idx++) {

            if (address(preconditions[idx]) != address(0)) {

                require(preconditions[idx].isValid(_platform, _platformId, _token, _value, _funder));

            }

        }

        require(_value > 0, "amount of tokens needs to be more than 0");



        if (_token != ETHER_ADDRESS) {

            require(ERC20(_token).transferFrom(_funder, address(this), _value), "Transfer of tokens to contract failed");

        }



        fundRepository.updateFunders(_funder, _platform, _platformId);

        fundRepository.updateBalances(_funder, _platform, _platformId, _token, _value);

        emit Funded(_funder, _platform, _platformId, _token, _value);

        return true;

    }



    /*

     * checks if a claim is valid, by checking the signature

     */

    function validClaim(bytes32 platform, string platformId, string solver, address solverAddress, bytes32 r, bytes32 s, uint8 v) internal view returns (bool) {

        bytes32 h = keccak256(abi.encodePacked(createClaimMsg(platform, platformId, solver, solverAddress)));

        address signerAddress = ecrecover(h, v, r, s);

        return claimSignerAddress == signerAddress;

    }



    function createClaimMsg(bytes32 platform, string platformId, string solver, address solverAddress) internal pure returns (string) {

        return strings.bytes32ToString(platform)

        .strConcat(prependUnderscore(platformId))

        .strConcat(prependUnderscore(solver))

        .strConcat(prependUnderscore(strings.addressToString(solverAddress)));

    }



    function addPrecondition(address _precondition) external onlyOwner {

        preconditions.push(Precondition(_precondition));

    }



    function removePrecondition(uint _index) external onlyOwner {

        if (_index >= preconditions.length) return;



        for (uint i = _index; i < preconditions.length - 1; i++) {

            preconditions[i] = preconditions[i + 1];

        }



        delete preconditions[preconditions.length - 1];

        preconditions.length--;

    }



    function setFundRepository(address _repositoryAddress) public onlyOwner {

        fundRepository = FundRepository(_repositoryAddress);

    }



    function setClaimRepository(address _claimRepository) public onlyOwner {

        claimRepository = ClaimRepository(_claimRepository);

    }



    function setClaimSignerAddress(address _claimSignerAddress) addressNotNull(_claimSignerAddress) public onlyOwner {

        claimSignerAddress = _claimSignerAddress;

    }



    function prependUnderscore(string str) internal pure returns (string) {

        return "_".strConcat(str);

    }



    //required to be able to migrate to a new FundRequestContract

    function migrateTokens(address _token, address newContract) external onlyOwner {

        require(newContract != address(0));

        if (_token == ETHER_ADDRESS) {

            newContract.transfer(address(this).balance);

        } else {

            ERC20 token = ERC20(_token);

            token.transfer(newContract, token.balanceOf(address(this)));

        }

    }



    modifier addressNotNull(address target) {

        require(target != address(0), "target address can not be 0x0");

        _;

    }



    //required should there be an issue with available ether

    function deposit() external onlyOwner payable {

        require(msg.value > 0, "Should at least be 1 wei deposited");

    }

}