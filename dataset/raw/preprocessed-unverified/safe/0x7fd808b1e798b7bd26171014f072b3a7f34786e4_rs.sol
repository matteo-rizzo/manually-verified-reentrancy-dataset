/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;
















contract ISoloMargin {
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) public;

    function getAccountBalances(
        Account.Info memory account
    ) public view returns (
        address[] memory,
        Types.Par[] memory,
        Types.Wei[] memory
    );

    function setOperators(
        OperatorArg[] memory args
    ) public;
}





contract ICallee {
    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    )
    public;
}

contract ReceiverCaller is ICallee {

    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    ) public {
        address(this).call(data);

    }
}

contract TestLoan is ReceiverCaller {

    event LoanReceived(uint _amount);

    address public constant FLASH_LOAN_TOKEN = 0xC4f41917A1Fc864aB576f47d5f718e72f2633B12;

    function takeLoan(address _tokenAddr, uint _borrowAmount) public {
        FlashTokenDyDx(FLASH_LOAN_TOKEN).flashBorrow(
            _tokenAddr,
            _borrowAmount,
            address(this),
            abi.encodeWithSignature("loanReceiver(address,uint256)", _borrowAmount)
        );
    }

    function loanReceiver(address _tokenAddr, uint _amount) public {

        // do sumting

        ERC20(_tokenAddr).transfer(FLASH_LOAN_TOKEN, _amount);

        emit LoanReceived(_amount);


    }
}

contract FlashTokenDyDx {

    ISoloMargin public constant soloMargin = ISoloMargin(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    uint daiMarketId = 3;

    function flashBorrow(
        address _tokenAddr,
        uint _borrowAmount,
        address _receiver,
        bytes calldata _funcData
    ) external {
        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = getAccount(address(this), 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](3);

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Withdraw,
            accountId: 0,
            amount: getAssetAmount(_borrowAmount),
            primaryMarketId: daiMarketId,
            otherAddress: _receiver,
            secondaryMarketId: 0,
            otherAccountId: 0,
            data: ""
        });

        actions[1] = Actions.ActionArgs({
            actionType: Actions.ActionType.Call,
            accountId: 0,
            amount: getAssetAmount(0),
            primaryMarketId: 0,
            otherAddress: _receiver,
            secondaryMarketId: 0,
            otherAccountId: 0,
            data: _funcData
        });

        actions[2] = Actions.ActionArgs({
            actionType: Actions.ActionType.Deposit,
            accountId: 0,
            amount: getAssetAmount(_borrowAmount),
            primaryMarketId: daiMarketId,
            otherAddress: _receiver,
            secondaryMarketId: 0,
            otherAccountId: 0,
            data: ""
        });

        soloMargin.operate(accounts, actions);
    }


    function getAssetAmount(uint _amount) internal returns (Types.AssetAmount memory amount) {
        amount = Types.AssetAmount({
            sign: false,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: _amount
        });
    }

    function getAccount(address _user, uint _index) public view returns(Account.Info memory) {
        Account.Info memory account = Account.Info({
            owner: _user,
            number: _index
        });

        return account;
    }
}