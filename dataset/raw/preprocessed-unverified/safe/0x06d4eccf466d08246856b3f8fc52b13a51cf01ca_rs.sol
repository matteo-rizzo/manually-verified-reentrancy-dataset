pragma solidity 0.4.24;



/// @dev `Owned` is a base level contract that assigns an `owner` that can be

///  later changed





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











contract TokenWhitelistPrecondition is Precondition {



    using strings for *;



    event Allowed(address indexed token, bool allowed);

    event Allowed(address indexed token, bool allowed, bytes32 platform, string platformId);



    //platform -> platformId -> token => _allowed

    mapping(bytes32 => mapping(string => mapping(address => bool))) tokenWhitelist;



    //token => _allowed

    mapping(address => bool) defaultWhitelist;



    //all tokens that either got allowed or disallowed

    address[] public tokens;

    mapping(address => bool) existingToken;



    constructor(string _name, uint _version, bool _active) public Precondition(_name, _version, _active) {

        //constructor

    }



    function isValid(bytes32 _platform, string _platformId, address _token, uint256 /*_value */, address /* _funder */) external view returns (bool valid) {

        return !active || (defaultWhitelist[_token] == true || tokenWhitelist[_platform][extractRepository(_platformId)][_token] == true);

    }



    function allowDefaultToken(address _token, bool _allowed) public onlyOwner {

        defaultWhitelist[_token] = _allowed;

        if (!existingToken[_token]) {

            existingToken[_token] = true;

            tokens.push(_token);

        }

        emit Allowed(_token, _allowed);

    }



    function allow(bytes32 _platform, string _platformId, address _token, bool _allowed) external onlyOwner {

        tokenWhitelist[_platform][_platformId][_token] = _allowed;

        if (!existingToken[_token]) {

            existingToken[_token] = true;

            tokens.push(_token);

        }

        emit Allowed(_token, _allowed, _platform, _platformId);

    }



    function extractRepository(string _platformId) pure internal returns (string repository) {

        var sliced = string(_platformId).toSlice();

        var platform = sliced.split("|FR|".toSlice());

        return platform.toString();

    }



    function amountOfTokens() external view returns (uint) {

        return tokens.length;

    }

}