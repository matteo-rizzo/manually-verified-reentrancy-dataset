contract Owner {

    address private owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
