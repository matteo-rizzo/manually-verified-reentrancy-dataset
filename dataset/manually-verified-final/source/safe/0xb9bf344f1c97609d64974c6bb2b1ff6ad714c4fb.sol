contract Broadcaster {

    event Broadcast(

        string _value

    );

    function broadcast(string memory message) public {

        emit Broadcast(message);

    }

}
