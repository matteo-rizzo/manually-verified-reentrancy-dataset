pragma solidity 0.6.6;


/**
 * Utility library of inline functions on addresses
 */






contract OracleResolver {
    using Address for address;

    Aggregator aggr;

    uint256 internal constant expiration = 3 hours;

    constructor() public {
        if (address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).isContract()) {
            // mainnet
            aggr = Aggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        } else revert();
    }

    function ethUsdPrice() public view returns (uint256) {
        require(now < aggr.latestTimestamp() + expiration, "Oracle data are outdated");
        return aggr.latestAnswer() / 1000;
    }
}