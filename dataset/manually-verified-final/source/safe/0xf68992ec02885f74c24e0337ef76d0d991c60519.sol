contract Uint256HashTable {

    mapping(uint256 => uint256) public hashTableValues;

    constructor() public {

    }

    function set(uint256 key, uint256 value) public  {

        hashTableValues[key] = value;

    }

    function get(uint256 key) public view returns (uint256 retVal) {

        return hashTableValues[key];

    }

}
