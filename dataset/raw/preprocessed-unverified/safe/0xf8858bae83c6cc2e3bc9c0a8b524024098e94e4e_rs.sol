/**

 *Submitted for verification at Etherscan.io on 2019-01-27

*/



pragma solidity 0.4.24;







































contract Registry {

    address public addressRegistry;

    modifier onlyAdmin() {

        require(

            msg.sender == getAddress("admin"),

            "Permission Denied"

        );

        _;

    }

    function getAddress(string name) internal view returns(address) {

        AddressRegistry addrReg = AddressRegistry(addressRegistry);

        return addrReg.getAddr(name);

    }

}





contract GlobalVar is Registry {



    using SafeMath for uint;

    using SafeMath for uint256;



    address public cdpAddr; // SaiTub

    bool public freezed;



    function getETHRate() public view returns (uint) {

        PriceInterface ethRate = PriceInterface(getAddress("ethfeed"));

        bytes32 ethrate;

        (ethrate, ) = ethRate.peek();

        return uint(ethrate);

    }



    function approveERC20() public {

        IERC20 wethTkn = IERC20(getAddress("weth"));

        wethTkn.approve(cdpAddr, 2**256 - 1);

        IERC20 pethTkn = IERC20(getAddress("peth"));

        pethTkn.approve(cdpAddr, 2**256 - 1);

        IERC20 mkrTkn = IERC20(getAddress("mkr"));

        mkrTkn.approve(cdpAddr, 2**256 - 1);

        IERC20 daiTkn = IERC20(getAddress("dai"));

        daiTkn.approve(cdpAddr, 2**256 - 1);

    }



}





contract LoopNewCDP is GlobalVar {



    event LevNewCDP(uint cdpNum, uint ethLocked, uint daiMinted);



    function pethPEReth(uint ethNum) public view returns (uint rPETH) {

        MakerCDP loanMaster = MakerCDP(cdpAddr);

        rPETH = (ethNum.mul(10 ** 27)).div(loanMaster.per());

    }



    // useETH = msg.sender + personal ETH used to assist the operation

    function riskNewCDP(uint eth2Lock, uint dai2Mint, bool isCDP2Sender) public payable {

        require(!freezed, "Operation Disabled");



        uint ethBal = address(this).balance;



        MakerCDP loanMaster = MakerCDP(cdpAddr);

        bytes32 cup = loanMaster.open(); // New CDP



        WETHFace wethTkn = WETHFace(getAddress("weth"));

        wethTkn.deposit.value(eth2Lock)(); // ETH to WETH

        uint pethToLock = pethPEReth(msg.value); // PETH : ETH

        loanMaster.join(pethToLock); // WETH to PETH

        loanMaster.lock(cup, pethToLock); // PETH to CDP



        loanMaster.draw(cup, dai2Mint);

        IERC20 daiTkn = IERC20(getAddress("dai"));



        address dai2ethContract = getAddress("dai2eth");

        daiTkn.transfer(dai2ethContract, dai2Mint); // DAI >>> dai2eth

        Swap resolveSwap = Swap(dai2ethContract);

        resolveSwap.dai2eth(dai2Mint); // DAI >>> ETH



        uint nowBal = address(this).balance;

        if (ethBal > nowBal) {

            msg.sender.transfer(ethBal - nowBal);

        }

        require(ethBal == nowBal, "No Refund of Contract ETH");



        if (isCDP2Sender) { // CDP >>> msg.sender

            loanMaster.give(cup, msg.sender);

        } else { // CDP >>> InstaBank

            InstaBank resolveBank = InstaBank(getAddress("bankv2"));

            resolveBank.claimCDP(uint(cup));

            resolveBank.transferCDPInternal(uint(cup), msg.sender);

        }



        emit LevNewCDP(uint(cup), eth2Lock, dai2Mint);

    }



}





contract LeverageCDP is LoopNewCDP {



    constructor(address rAddr) public {

        addressRegistry = rAddr;

        cdpAddr = getAddress("cdp");

        approveERC20();

    }



    function () public payable {}



    function freeze(bool stop) public onlyAdmin {

        freezed = stop;

    }



}