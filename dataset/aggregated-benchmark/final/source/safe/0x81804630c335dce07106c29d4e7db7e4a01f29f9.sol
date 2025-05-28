contract Lobster {

    address private owner;
    string private flag;

    constructor () public {
        owner = msg.sender;
    }

    function getFlag() public view returns (string memory) {
        require(msg.sender == owner);
        return flag;
    }

}
