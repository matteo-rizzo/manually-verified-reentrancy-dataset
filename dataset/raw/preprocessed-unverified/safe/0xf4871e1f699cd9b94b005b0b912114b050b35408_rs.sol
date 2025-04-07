/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract FaasYtruClaim {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public tokenValue = IERC20(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);
    address public governance;

    // 5k VALUE
    uint constant TOTAL_AMOUNT = 5000 * 10 ** 18;
    uint constant PRECISION = 10 ** 18;
    uint public totalClaimed = 0;

    mapping(address => uint) poolPercent;

    event Claimed(address indexed user, uint amount);

    constructor() public {
        poolPercent[0x3818c6d5B6c62646aEa6977ed7Ea17C9DD306a26] = uint(98762399899753053);
        poolPercent[0x921e70C38d30A5047400453DF112073386Ea17B7] = uint(88071403505285155);
        poolPercent[0x3eBf99eaB58cC56C0BbeeA39042295a0911f8C54] = uint(86925957751325004);
        poolPercent[0x5294BF14fCdC5cBDFd29C18D74432c8100A60C24] = uint(80450556864786161);
        poolPercent[0x712dEd055A6Cb663fad5B4E12aA00f76485Da181] = uint(66606339504797085);
        poolPercent[0x7D9907f35D4d77661571c7Bef5244E4E2aa460d8] = uint(45864545071870010);
        poolPercent[0xCDcBDe7fF7AC3B2b7E7375B2FEE2a58eb8cdc90c] = uint(36953036435783981);
        poolPercent[0x73b766D4AF2a30c55acf0494Df6d46c2A2CAc0F4] = uint(36479570549366388);
        poolPercent[0x5fE6e1F5E8E68B8D26c47c59A668e662d3120C49] = uint(35833575959083266);
        poolPercent[0xe2043692C3F8D14f7EE42A5A83D5278Dbd4142c5] = uint(35833575959083265);
        poolPercent[0x880E14298Dd46418806F7B5e12B92Aa9873bB5D4] = uint(22065501339072763);
        poolPercent[0xBf1980eDf790B83AAC6B81bc47De19204AbcC58f] = uint(20079066931476054);
        poolPercent[0x66Dfe8a1fe22dB26bcBC408eB4968074846dBbCd] = uint(19307473992345985);
        poolPercent[0xa26674116c72cF19e3e7855864Afe9C8F18a84B2] = uint(19020178105869630);
        poolPercent[0x3c9bB7607D02Ca116274271C066345AA74c52fC3] = uint(18179889177146981);
        poolPercent[0x976d3493dfa5cBB315209E7A579165a2422822AE] = uint(18147019474964603);
        poolPercent[0xc4F1f0424169e14BA21A5bde2d22a61adDebb264] = uint(18044984717335213);
        poolPercent[0xf8fF20Ec289d14372F17F445aAA9A31A5ebb3948] = uint(18033884006320090);
        poolPercent[0x9f57bBf1Ffd0cE7a745fD251d44C041348d4cfb2] = uint(17596684017039990);
        poolPercent[0x762b9fA09B4679b0E774a501326E09bfFfB7b4F8] = uint(17508700596954791);
        poolPercent[0x3365Fe1aFb39C2408f89a7D1e24d198CBA29d2D5] = uint(17322154953375302);
        poolPercent[0x34Be626a066E3B76CbCD2c78C098ed5CA061060c] = uint(16716849816187991);
        poolPercent[0x42FF55335c64E415a84b6CFeB2691DA57278e221] = uint(16230433179041313);
        poolPercent[0xfa47bcCe07AbE8a4e2E3d7a1116c0a508251f41F] = uint(16098956953701023);
        poolPercent[0xF8E78Bad6DD4a10f025027A13b3167AFD6CBE3E5] = uint(15973120834587238);
        poolPercent[0x188f287eE02d7Ca1fdC64B464cDac6d797A82E34] = uint(15391310494197682);
        poolPercent[0x9BCeE25fcf7512500272520e4e396ED80C3dea14] = uint(11148367590479501);
        poolPercent[0x60C1734cf1D78082E2849EC545Ce90E90781BD6f] = uint(9869260004291480);
        poolPercent[0x2fCc7e3536bFaaa458413b775761eDA44124F680] = uint(9527125567330223);
        poolPercent[0x5AD429c8fc1A9814a6799ccE2E3D7Cd2f2DBcEdd] = uint(9147226323036739);
        poolPercent[0xeEA5e57d6a3AC196a5ef302eebB6BF3D662fF5Cb] = uint(9125282443995584);
        poolPercent[0x6794471ebC084A4ca462C506AfEaBb93d9657c25] = uint(8750585235325117);
        poolPercent[0xf7700944B35C3F85A23E9d77beE065dc4F10d6F7] = uint(7686956986066208);
        poolPercent[0x5b57b83C142e3ADa7e7affB9DfC4904838EA43a7] = uint(7020009620700478);
        poolPercent[0xe14DDA9F2d244bE5aDB5Fb60653B2734a68f1097] = uint(6558284002297366);
        poolPercent[0x5691396FBad14F1663Ca2EFeFb95796ECC6848E2] = uint(4818255005695057);
        poolPercent[0xdb5aFaD5df5cd21998DDC3Ca5C98099AFad621b3] = uint(4587855604263771);
        poolPercent[0xD663354A09aB4b0e67D077a540D77c2740E30290] = uint(3425796086134470);
        poolPercent[0xdc57d303C164ed046878E0F1d79762F7Cf91A214] = uint(2751872704312200);
        poolPercent[0x0e3755d390801da61b8E22f00578E1a921d435b2] = uint(2189056311177052);
        poolPercent[0x7Be4D5A99c903C437EC77A20CB6d0688cBB73c7f] = uint(2117880013617509);
        poolPercent[0x8d61C148A41F67D3b4D19e1532b464121ef865C9] = uint(1969099585987178);
        poolPercent[0x06C2e6964ED853d6234adEAFa1dB512fdA720d8A] = uint(1167617039943122);
        poolPercent[0x49cd01D97068a50b6fad475b02E463E14aDB4033] = uint(642299784596928);

        governance = msg.sender;
    }

    function calcClaimAmount(address user) public view returns (uint) {
        return poolPercent[user].mul(TOTAL_AMOUNT).div(PRECISION);
    }

    function claim() public returns (uint) {
        uint amount = calcClaimAmount(msg.sender);
        require(amount > 0, "amount = 0");
        poolPercent[msg.sender] = 0;
        tokenValue.safeTransfer(msg.sender, amount);
        emit Claimed(msg.sender, amount);
        totalClaimed = totalClaimed.add(amount);
        return amount;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(IERC20 _token, uint amount, address to) external {
        require(msg.sender == governance, "!governance");
        _token.safeTransfer(to, amount);
    }
}