/**
 *Submitted for verification at Etherscan.io on 2021-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */








contract Redeem {
    address public lusd_trove_mgr = address(0xA39739EF8b0231DbFA0DcdA07d7e29faAbCf4bb2);
    address public lusd_curve_pool = address(0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA);
    address public lusd_token = address(0x5f98805A4E8be255a32880FDeC7F6728C6568bA0);
    address public usdc_token = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public stability_pool = address(0x66017D22b0f8556afDd19FC67041899Eb65a21bb);

    function fund() public payable returns(bool success) {
        return true;
    }

    function _exchange_underlying(uint256 dx, uint256 dy) internal {
        IERC20(usdc_token).transferFrom(msg.sender, address(this), dx);
        require(IERC20(usdc_token).balanceOf(address(this)) == dx);
        Curve(lusd_curve_pool).exchange_underlying(2, 0 , dx,  dy, msg.sender);
    }


    function redeem_all_lusd(
        uint256 dx, uint256 dy,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee
        ) external payable {
        _exchange_underlying(dx, dy);
        uint lusd_balance = IERC20(lusd_token).balanceOf(msg.sender);
        IERC20(lusd_token).transferFrom(msg.sender, address(this), lusd_balance);
        ITroveManager(lusd_trove_mgr).redeemCollateral(
            lusd_balance,
            _firstRedemptionHint,
            _upperPartialRedemptionHint,
            _lowerPartialRedemptionHint,
            _partialRedemptionHintNICR,
            _maxFee,
            _maxFee
        );

        msg.sender.transfer(address(this).balance);

    }
}