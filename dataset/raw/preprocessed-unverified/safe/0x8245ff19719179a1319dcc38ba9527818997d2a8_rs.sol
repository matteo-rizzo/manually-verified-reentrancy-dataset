pragma solidity ^0.4.24;





contract TokenTransferTest {

    uint public GOOD_ERC20 = 1;
    uint public BAD_ERC20 = 2;

    function ()
        payable
        external
    {
        revert();
    }

    function testBadWithGoodInterface(address token,
                                      uint ercType,
                                      address to,
                                      uint value)
        external
    {
        if (ercType == 1) {
            GoodERC20 goodErc20 = GoodERC20(token);
            require(goodErc20.transfer(to, value));
        } else {
            BadERC20 badErc20 = BadERC20(token);
            badErc20.transfer(to, value);
        }
    }

}