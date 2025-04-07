// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;













contract VestingVault {
    using SafeERC20 for IERC20;
    
    VestingEscrow public constant escrow = VestingEscrow(0x575CCD8e2D300e2377B43478339E364000318E2c);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant crvVault = address(0xF147b8125d2ef93FB6965Db97D6746952a133934);
    address[] public vaults = [0x8816B2Fb982281c36E6c535B9e56B7a4417e68cF,
                                0xBE197E668D13746BB92E675dEa2868FF14dA0b73,
                                0x2De055fec2b826ed4A7478CeDDBefF82C1EdFA70];
    
    function claim() public {
        for(uint i = 0; i < vaults.length; i++) {
            escrow.claim(vaults[i]);
            VestingStrategy(vaults[i]).withdraw(crv);
        }
        uint _balance = IERC20(crv).balanceOf(address(this));
        IERC20(crv).safeTransfer(crvVault, _balance);
    }
    
    constructor() public {}
}