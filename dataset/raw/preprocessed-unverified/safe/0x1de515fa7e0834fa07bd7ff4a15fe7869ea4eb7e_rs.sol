/**
 *Submitted for verification at Etherscan.io on 2020-12-11
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




contract ValueIOUClaim {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ValueIOUTokenInterface public valueIOU;
    address public governance;

    // 2M DAI
    uint256 public constant INITIAL_AMOUNT = 611077230995 * 10**13;
    uint256 constant PRECISION = 10**18;
    uint256 public totalClaimed = 0;

    mapping(address => uint256) poolPercent;
    mapping(address => uint256) returnedAmount;

    event Claimed(address indexed user, uint256 amount);

    constructor(address _valueIOU) public {
        valueIOU = ValueIOUTokenInterface(_valueIOU);

        poolPercent[0x812BE2983CA8057668e324D4dc69Ef9cE19F2E73] = uint256(103851909873102987);
        poolPercent[0x5229406Cbb785E7754BDD6af66b94263f1c7dAb7] = uint256(96044602856523642);
        poolPercent[0x4086E3e1e99a563989a9390faCff553A4f29b6eE] = uint256(76675395859829907);
        poolPercent[0x047B3e73043BBF7421b78893110fC30b7db6b126] = uint256(68580696923039742);
        poolPercent[0x36cc7B13029B5DEe4034745FB4F24034f3F2ffc6] = uint256(60110755262441228);
        poolPercent[0xB1AdceddB2941033a090dD166a462fe1c2029484] = uint256(43895388752146932);
        poolPercent[0x978527Ab21Fbbe1A80b2a8a24DF9a41E63C7221B] = uint256(39695818143473979);
        poolPercent[0x332aeee03111a6EB5BA9F96f9249CDc2367fd99C] = uint256(37270811570735216);
        poolPercent[0x9C42EBDf0fA6fA0274aEEBf981613Dfa9c99BFF8] = uint256(30955074267691041);
        poolPercent[0x983130D9948224262F90090a471bDF5CFF140869] = uint256(26327212980757001);
        poolPercent[0xda17e4d1Ef6eA697A22Fd8484bd2F1E1f6f53CA7] = uint256(25049901138253119);
        poolPercent[0x6aBf3F8581f88002b87699608183675b7F2972f7] = uint256(22488911556305054);
        poolPercent[0x2A097805c9bCA80925b840B5C42E482ebC8C985E] = uint256(22423173506256594);
        poolPercent[0x0F109e11B76e83f8a984C9D80D379fC806fa2B65] = uint256(20410889569877748);
        poolPercent[0xC9addb098446BBD7fc3D90b84591Da26f3dbc5eC] = uint256(18583798973904956);
        poolPercent[0xa29f9169A6Bd23864e30Ea4846a3d9b2bfAc89b8] = uint256(18384749715223722);
        poolPercent[0x42f1F47F1d5C2c61A38fD96A46EF95f24C12Eb41] = uint256(18245421006553498);
        poolPercent[0x082B687C7b6F37973ea560c2D8cd01aFbaD09a1d] = uint256(17312430420651858);
        poolPercent[0xa8d25C5A6f832a9423038c86529391aA7B7F91a0] = uint256(13162778362188577);
        poolPercent[0xdd1dF77B43653cc56e0CbF5309Edd83aFb7b681F] = uint256(12370948072238901);
        poolPercent[0x3c8c80fB3C4d3337f904cf2ea195A158E8747361] = uint256(9896894766030845);
        poolPercent[0xdbeDB1B7d359b0776E139D385c78a5ac9B27C0f9] = uint256(8796728458696510);
        poolPercent[0x0000000000000D9054F605cA65A2647c2B521422] = uint256(8778401252780423);
        poolPercent[0x1f4E3BeeA02643e4b06Ff37CA8309caaBA745874] = uint256(8774786082666731);
        poolPercent[0xA0e04247d39eBc07f38ACca38Dc10E14fa8d6C98] = uint256(8349977752220193);
        poolPercent[0x5DD596C901987A2b28C38A9C1DfBf86fFFc15d77] = uint256(7951891508320949);
        poolPercent[0x01173Bd5895Acf19c67F6170f15d503D4153CF04] = uint256(7836020295951428);
        poolPercent[0x38e481367E0c50f4166AD2A1C9fde0E3c662CFBa] = uint256(7602746774224631);
        poolPercent[0xC2326dc6e79F6750541550AF0064F829ce8312c0] = uint256(7040867777287646);
        poolPercent[0x03DcA0e82c9Fd8876245ee54997dD4aF73849FD2] = uint256(6383853016123569);
        poolPercent[0x6c856d4E74aF777b48b0af920Ef4a6e697dB7a43] = uint256(6036223878633232);
        poolPercent[0xE1025E226B741cc121ad4E4d25017785f8c83c76] = uint256(5877807315360724);
        poolPercent[0x1f0a6d7Db80E0C5Af146FDb836e04FAC0B1E8202] = uint256(5739998421257469);
        poolPercent[0x4312CAe7E407243a81Bf7aC74f8d8187252aF51a] = uint256(5627703173608491);
        poolPercent[0x2eD65Eb5888Cd73d74b9C847Ffe4B801eE818720] = uint256(5494833858185275);
        poolPercent[0x012b82C47049f9E0E35Cd3Bba6B0033c71010c08] = uint256(5266959575511045);
        poolPercent[0x3dBa662d484F73c7ec387376E0e8373f483D04CC] = uint256(5203889252170668);
        poolPercent[0x9179c2f787788E590e6Fbf79090a6B94E0d11E5f] = uint256(5084118592727006);
        poolPercent[0x77777a55576E4b03844AC5133B8e9A99057492d6] = uint256(4478552872174259);
        poolPercent[0xa29e3738F6Bf205522A02a6BC580b828dD19383f] = uint256(4433727055294351);
        poolPercent[0xb1C57869f6eacD51D1A74c558ec4C578394dAF0B] = uint256(4394904577877377);
        poolPercent[0x3e8734Ec146C981E3eD1f6b582D447DDE701d90c] = uint256(4393480093325622);
        poolPercent[0x92F59dcFB0D00dfC23972499a33Fc2adfAa1ED76] = uint256(4343801012099734);
        poolPercent[0x93c0824cdEB2675317f05D4DB08c1F90fdb1D8ea] = uint256(4337238965261326);
        poolPercent[0x2Fc9B2B376dCdbd86da622eDAac352391704A111] = uint256(4336149567548241);
        poolPercent[0xe5A8654631B3729F73ca3503bA09a5d3e11b46da] = uint256(3950292986952034);
        poolPercent[0x5D81940e60DAdda8b85d0b6fB5dC9941A3Db2C64] = uint256(3927617086019548);
        poolPercent[0x85ace660391c4Fb72581bfeE3df840EDA189e552] = uint256(3361863581059707);
        poolPercent[0x34E8dB41c4EC274429D01597Bc86AEed4d6e9B5e] = uint256(3150797129615699);
        poolPercent[0x02b31379Ba6Eac0635a6141067a14C1526c506D3] = uint256(3120151474686539);
        poolPercent[0x93C027865354e96a1e9ec69fc8253e6d49013f82] = uint256(3089425736425334);
        poolPercent[0x898eFA55Ce5cCEC7EFad8C7b77204edEB8847961] = uint256(3075349913606904);
        poolPercent[0xCebaa26C11Bdf4F239424CcC17864B2C0f03e2BD] = uint256(2464142528976263);
        poolPercent[0x4118B48813c64977CB0D1b02eD268cFB3f6195e2] = uint256(2291941690056106);
        poolPercent[0xa89C876BE69223295A0925D7A62Cb6868dEc4ac8] = uint256(2204298288047923);
        poolPercent[0xF9D594DAcDf73982fbA8e2711C8728909F8D1205] = uint256(2194209282373755);
        poolPercent[0x7421c1eD16B400e4868CE696452C3C985F8CD04D] = uint256(2064426924253778);
        poolPercent[0xdA4e42749Cb44afA7222643CA0A3218d8Df5DDb6] = uint256(1769809642819860);
        poolPercent[0x5f0B23D415B82421780AaEea6362860e76e90a2F] = uint256(1757374850762334);
        poolPercent[0xF9e6028cffB7B8d055219B97829698943B149222] = uint256(1572688966486068);
        poolPercent[0x1dA14E9cDaE510aE75972f5221200FA781FDb4C8] = uint256(1530136792889973);
        poolPercent[0x87fC1313880d579039aC48dB8B25428ed5F33C4a] = uint256(1440001871442540);
        poolPercent[0xe7bb437c0DD10Dc51fB6126990E034B5752e8165] = uint256(1220085839640999);
        poolPercent[0x03853603beeD695de2011710f8f967a6042Ed92D] = uint256(1138251949517258);
        poolPercent[0x801EFaA08e37EfEaAd37bEc444A50583362e31A3] = uint256(1053540861157456);
        poolPercent[0xD9d3dd56936F90ea4c7677F554dfEFD45eF6Df0F] = uint256(1017827032518972);
        poolPercent[0x8B553E50B2C2fabA3148aac9C40eA9971Cd25F86] = uint256(998101399560152);
        poolPercent[0xB07ac339291FdbA30D2c75355AAe22eD6f3d1c7c] = uint256(966287698200556);
        poolPercent[0x8ac7AC7361d7917Ddd06a5d763c7f324b7F5E435] = uint256(943226945475508);
        poolPercent[0x98A529e3488c2d44566881FEAB335B17B1c3b430] = uint256(928761059243697);
        poolPercent[0x3818c6d5B6c62646aEa6977ed7Ea17C9DD306a26] = uint256(895494659343807);
        poolPercent[0x3D3C3EEAc517B72670DB36cb7380cd18B929430b] = uint256(878361274921183);
        poolPercent[0x37a952DC59533852E65bd83cDE0e29c3ee02EaD0] = uint256(877695478007704);
        poolPercent[0x9eBAFf2192d2746FeC76561bdF72fd249d7a73ab] = uint256(867939996365686);
        poolPercent[0xAB0f6b8C486FeC656B270Ff2B53aE09e454E12E1] = uint256(805035272320907);
        poolPercent[0xeaE98E98CeA0577Cf78e2Efce00B3Faa9444130C] = uint256(804148207755992);
        poolPercent[0x16d1663A00d4d1a216E0baa84B0AbC69ba35C156] = uint256(789305324597927);
        poolPercent[0x4d9FD403CAD5d8E3416D022fd584d5384B39e4f0] = uint256(766249795991572);
        poolPercent[0xeD558De2E1Fb9fce685096C8D2173C4DA09bFaE6] = uint256(708165574664640);
        poolPercent[0x5D1Ec9869c70b8b6A36CdD5879A2CD9639151C76] = uint256(702483713895816);
        poolPercent[0xc126C683c2eEd8564c7141B29c75FeaDadF13069] = uint256(625268982962806);
        poolPercent[0x8C4d5F3eaC04072245654E0BA480f1a5e1d91Dd5] = uint256(614215746124866);
        poolPercent[0x012937aBA6955Bd6F7b2894c7E7079441F27e51A] = uint256(573442494052014);
        poolPercent[0xC85Ca407b61129AB62A2cdEc176035e6FECF153E] = uint256(532031943644062);
        poolPercent[0xB599A3f7c47A9Fd64fd17190F9B8E4215B7e1FE4] = uint256(526625685760329);
        poolPercent[0x6a414B51CEAf33eF465eb853B0B070512AFDD717] = uint256(492885199226109);
        poolPercent[0xe92A014E59210BAfd9302C42dc0A96f0006E1Cd1] = uint256(492080662165940);
        poolPercent[0x24403C7f45Bd16F6DfFDe0c1c45792d9825fe9a6] = uint256(490605687617664);
        poolPercent[0x6f0A3Cff9514Bae0B86Ac300E72a1B9986074B35] = uint256(469745171575446);
        poolPercent[0x5F723856AC7E6f6292473730449E79F483909867] = uint256(441912625525200);
        poolPercent[0x5D7926412Dd9Ba3F00A74AD9F8C5A50Bb80fc297] = uint256(439098392117571);
        poolPercent[0xBB2d41AcfEA24A3A2aD4A6F95C3AcE1cC98c6ed6] = uint256(438944417494991);
        poolPercent[0x2DE7040994abF7b8064B91b4CAe73e9432d84f00] = uint256(438555836007025);
        poolPercent[0xeB8cd71159f6D05962011F46B00B806df227e89a] = uint256(361370100658379);
        poolPercent[0x899Bc43d25bD7b6AbA3999d02746b0284D88778E] = uint256(330442429333844);
        poolPercent[0x7a855E3E13585368576a5A583c50451339AcC561] = uint256(301879879076863);
        poolPercent[0x3D6dAb25Cb8168615B2BF75dE4E987204468856C] = uint256(295933355653487);
        poolPercent[0x2b2411BD9Dcfb0d3F375521917e623676987dFb1] = uint256(287200595329967);
        poolPercent[0x67Ff8944fB0999dD9d7fAc4Ca0Bd79c714162538] = uint256(281259723453667);
        poolPercent[0xA5c071916Bd1DC65e4DefA553aEe4C2822bf5b30] = uint256(277142231873719);
        poolPercent[0x66c93DBa5340A9CB612aA9B27046e5f298A91c16] = uint256(262265556267139);
        poolPercent[0xed4c4aab2232319481745849f3406397BeBAEaA2] = uint256(202038915277846);
        poolPercent[0xDB611d682cb1ad72fcBACd944a8a6e2606a6d158] = uint256(201313985582635);
        poolPercent[0xF327eA8952B7Cf816821436A63235B0211FCEf69] = uint256(179258945543530);
        poolPercent[0x4070E40FC3E382437aB7BaC2249205D276Bdd15A] = uint256(176716995397034);
        poolPercent[0x8A09990601E7FF5CdccBEc6E9dd0684620a21a29] = uint256(175537741342387);
        poolPercent[0x2E973bc711e1D50508938c8B66D5aC4398Dbf29C] = uint256(175279258219656);
        poolPercent[0x9d86A7F15C668ad1511B0FAb20BC8D7448108ba8] = uint256(148146879842271);
        poolPercent[0x09A01a4cc5b0EC8d606EA3B42bBec7145173BACe] = uint256(144150186144024);
        poolPercent[0x8D1e46e92dC5B24c09bDf46F9B7D20a8e47cea70] = uint256(129344804477404);
        poolPercent[0xF25DFA49AbCc51109cAaFE9dabdA8d109804bd35] = uint256(120027890977234);
        poolPercent[0xD9f44963C2498C1B4ce4d4E93D751Bd8E54CaD85] = uint256(119295984731460);
        poolPercent[0x40534E513dF8277870B81e97B5107B3f39DE4f15] = uint256(116162445599545);
        poolPercent[0x3Ecf02FdF558B311fd9c9D55857283CD211aE9c0] = uint256(115209886483954);
        poolPercent[0xD2c3d722E9fBa408CF33A0aBE0c3903419a5bbda] = uint256(109617218919279);
        poolPercent[0x416e92F37Fb344Ee99b7Af6340025434B59F13bb] = uint256(91024223780615);
        poolPercent[0x9137a536313EdA9d57c1B5d8e645aE123Ec522ce] = uint256(90173387080437);
        poolPercent[0x8c297f1Bc4437388Ca86569607801a76756534bB] = uint256(88496855821062);
        poolPercent[0xaa73A811A4898ca0E116376BE752B3960D554021] = uint256(88484112856732);
        poolPercent[0xedf4FA418216A13E7629fED73e7448985CC8Bc82] = uint256(88416411928321);
        poolPercent[0x2Db8b93B125A1cC9337AA4AD33F8C4096803e73B] = uint256(82497996207592);
        poolPercent[0xEd60839632D9BfE3586810Ef2579620293AA5A1d] = uint256(68694397365237);
        poolPercent[0x3C1Fbe83eF0F5B04bE5fc54edaC2Bec2c25DC07c] = uint256(66616968680615);
        poolPercent[0xFAff02F1D7F9315529B64F64611fB35FFaE41c1D] = uint256(61602883361426);
        poolPercent[0x52F1F2957b7Ee88eE66B5b67cB765D6762304F30] = uint256(61588389773196);
        poolPercent[0xDa0402Ae38ec0A808134CC990B6bD28C1f64aAa8] = uint256(57299717327749);
        poolPercent[0xf83719280BA7f4b1e390bb1524ad42b427c80F4E] = uint256(51641523027210);
        poolPercent[0x5e84E8508B731e020eF0E8Ea1B0e7dBA75638881] = uint256(50164022056155);
        poolPercent[0x111cD92405B1Dfbd19882D361418F49D99d8FED8] = uint256(43894794631396);
        poolPercent[0x6c4de74f5752960e991D7bf580fDE2cFc5E2CA59] = uint256(43878511257040);
        poolPercent[0x8369E7900fF2359BB36eF1c40A60E5F76373A6ED] = uint256(43872259330882);
        poolPercent[0x34E561CEE3F22FD97F3a247Decd6565f9027c52A] = uint256(35431113003049);
        poolPercent[0xceBda014e382119795825A00147C6CaC92B06421] = uint256(33350875641359);
        poolPercent[0x602dC1d22884E333FCA32eB03105773c3b97b22B] = uint256(24852482910858);
        poolPercent[0x3A70e8C00f3bCf3eb845B6b6928AbA92b465C183] = uint256(24574341013581);
        poolPercent[0x8C862bB9F12A87Fe69703C19F561d6306e01A94D] = uint256(20847790238819);
        poolPercent[0xEB3F3F5b1Ec4430451059cB6Bddc984f723C037A] = uint256(17945891936910);
        poolPercent[0x5f0Ee5c6ff90F3F50a42d41aF4c18EBDD3D7FF1F] = uint256(17589685295619);
        poolPercent[0xf7622487765A21a907Ec4DAbb318c92c520e1a1E] = uint256(11705068777596);
        poolPercent[0x74CCe25E03841eC7C9b946D89c943EaF1BA0C6cb] = uint256(10390812388967);
        poolPercent[0xd81008065eC031e540B251E9aFa5A3f246e1C6fb] = uint256(9178900728773);
        poolPercent[0xa710a581997F31a4467E58a39D203c8414096F41] = uint256(1756952973682);
        poolPercent[0x7Be4D5A99c903C437EC77A20CB6d0688cBB73c7f] = uint256(866010669257);
        poolPercent[0xfB71f273284e52e6191B061052C298f10c2A6817] = uint256(440229288870);

        returnedAmount[0x082B687C7b6F37973ea560c2D8cd01aFbaD09a1d] = uint256(45000000000000000000000);
        returnedAmount[0xa29f9169A6Bd23864e30Ea4846a3d9b2bfAc89b8] = uint256(50000000000000000000000);

        governance = msg.sender;
    }

    function calcClaimAmount(address user) public view returns (uint256) {
        if (poolPercent[user] > 0) return poolPercent[user].mul(INITIAL_AMOUNT).div(PRECISION).sub(returnedAmount[user]);
        return 0;
    }

    function claim() public returns (uint256) {
        uint256 amount = calcClaimAmount(msg.sender);
        require(amount > 0, "amount = 0");
        poolPercent[msg.sender] = 0;
        valueIOU.transfer(msg.sender, amount);

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
    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 amount,
        address to
    ) external {
        require(msg.sender == governance, "!governance");
        _token.safeTransfer(to, amount);
    }
}