contract Storage {
    uint256 public counter = 1;

    function increment() public {
        require(counter < 3, "Expired counter contract");
        counter++;
    }
}
