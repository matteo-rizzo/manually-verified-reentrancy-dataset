/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;



contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}







/* 

 Very low risk COMP farming strategy

*/





contract ConverterDAItoYCRV {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public governance;
    address public controller;
    IERC20 constant public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    yERC20 constant public ydai = yERC20(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
    IERC20 constant public ycrv = IERC20(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    ICurveFi constant public swap = ICurveFi(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    
    constructor() public {
        governance = msg.sender;
        controller = msg.sender;
    }
    
    function convert(address _strategy) external {
        require(msg.sender == controller, "!controller");
        uint _dai = dai.balanceOf(address(this));
        dai.safeApprove(address(ydai), 0);
        dai.safeApprove(address(ydai), _dai);
        ydai.deposit(_dai);
        uint _ydai = ydai.balanceOf(address(this));
        IERC20(address(ydai)).safeApprove(address(swap), 0);
        IERC20(address(ydai)).safeApprove(address(swap), _ydai);
        swap.add_liquidity([_ydai,0,0,0],0);
        ycrv.safeTransfer(_strategy, ycrv.balanceOf(address(this)));
    }
    
    function seize(IERC20 _token) external {
        require(msg.sender == governance, "!governance");
        _token.safeTransfer(governance, _token.balanceOf(address(this)));
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
        
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}