/**

 *Submitted for verification at Etherscan.io on 2018-12-07

*/



pragma solidity ^0.4.17;





/// general helpers.

/// `internal` so they get compiled into contracts using them.







/// Library used only to test Helpers library via rpc calls







// helpers for message signing.

// `internal` so they get compiled into contracts using them.







/// Library used only to test MessageSigning library via rpc calls













/// Library used only to test Message library via rpc calls







contract MainBridge {

    /// Number of authorities signatures required to withdraw the money.

    ///

    /// Must be lesser than number of authorities.

    uint256 public requiredSignatures;



    /// The gas cost of calling `MainBridge.withdraw`.

    ///

    /// Is subtracted from `value` on withdraw.

    /// recipient pays the relaying authority for withdraw.

    /// this shuts down attacks that exhaust authorities funds on main chain.

    uint256 public estimatedGasCostOfWithdraw;



    /// reject deposits that would increase `this.balance` beyond this value.

    /// security feature:

    /// limits the total amount of mainnet ether that can be lost

    /// if the bridge is faulty or compromised in any way!

    /// set to 0 to disable.

    uint256 public maxTotalMainContractBalance;



    /// reject deposits whose `msg.value` is higher than this value.

    /// security feature.

    /// set to 0 to disable.

    uint256 public maxSingleDepositValue;



    /// Contract authorities.

    address[] public authorities;



    /// Used side transaction hashes.

    mapping (bytes32 => bool) public withdraws;



    /// Event created on money deposit.

    event Deposit (address recipient, uint256 value);



    /// Event created on money withdraw.

    event Withdraw (address recipient, uint256 value, bytes32 transactionHash);



    /// Constructor.

    function MainBridge(

        uint256 requiredSignaturesParam,

        address[] authoritiesParam,

        uint256 estimatedGasCostOfWithdrawParam,

        uint256 maxTotalMainContractBalanceParam,

        uint256 maxSingleDepositValueParam

    ) public

    {

        require(requiredSignaturesParam != 0);

        require(requiredSignaturesParam <= authoritiesParam.length);

        requiredSignatures = requiredSignaturesParam;

        authorities = authoritiesParam;

        estimatedGasCostOfWithdraw = estimatedGasCostOfWithdrawParam;

        maxTotalMainContractBalance = maxTotalMainContractBalanceParam;

        maxSingleDepositValue = maxSingleDepositValueParam;

    }



    /// Should be used to deposit money.

    function () public payable {

        require(maxSingleDepositValue == 0 || msg.value <= maxSingleDepositValue);

        // the value of `this.balance` in payable methods is increased

        // by `msg.value` before the body of the payable method executes

        require(maxTotalMainContractBalance == 0 || this.balance <= maxTotalMainContractBalance);

        Deposit(msg.sender, msg.value);

    }



    /// Called by the bridge node processes on startup

    /// to determine early whether the address pointing to the main

    /// bridge contract is misconfigured.

    /// so we can provide a helpful error message instead of the very

    /// unhelpful errors encountered otherwise.

    function isMainBridgeContract() public pure returns (bool) {

        return true;

    }



    /// final step of a withdraw.

    /// checks that `requiredSignatures` `authorities` have signed of on the `message`.

    /// then transfers `value` to `recipient` (both extracted from `message`).

    /// see message library above for a breakdown of the `message` contents.

    /// `vs`, `rs`, `ss` are the components of the signatures.



    /// anyone can call this, provided they have the message and required signatures!

    /// only the `authorities` can create these signatures.

    /// `requiredSignatures` authorities can sign arbitrary `message`s

    /// transfering any ether `value` out of this contract to `recipient`.

    /// bridge users must trust a majority of `requiredSignatures` of the `authorities`.

    function withdraw(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) public {

        require(message.length == 116);



        // check that at least `requiredSignatures` `authorities` have signed `message`

        require(Helpers.hasEnoughValidSignatures(message, vs, rs, ss, authorities, requiredSignatures));



        address recipient = Message.getRecipient(message);

        uint256 value = Message.getValue(message);

        bytes32 hash = Message.getTransactionHash(message);

        uint256 mainGasPrice = Message.getMainGasPrice(message);



        // if the recipient calls `withdraw` they can choose the gas price freely.

        // if anyone else calls `withdraw` they have to use the gas price

        // `mainGasPrice` specified by the user initiating the withdraw.

        // this is a security mechanism designed to shut down

        // malicious senders setting extremely high gas prices

        // and effectively burning recipients withdrawn value.

        // see https://github.com/paritytech/parity-bridge/issues/112

        // for further explanation.

        require((recipient == msg.sender) || (tx.gasprice == mainGasPrice));



        // The following two statements guard against reentry into this function.

        // Duplicated withdraw or reentry.

        require(!withdraws[hash]);

        // Order of operations below is critical to avoid TheDAO-like re-entry bug

        withdraws[hash] = true;



        uint256 estimatedWeiCostOfWithdraw = estimatedGasCostOfWithdraw * mainGasPrice;



        // charge recipient for relay cost

        uint256 valueRemainingAfterSubtractingCost = value - estimatedWeiCostOfWithdraw;



        // pay out recipient

        recipient.transfer(valueRemainingAfterSubtractingCost);



        // refund relay cost to relaying authority

        msg.sender.transfer(estimatedWeiCostOfWithdraw);



        Withdraw(recipient, valueRemainingAfterSubtractingCost, hash);

    }

}





contract SideBridge {

    // following is the part of SideBridge that implements an ERC20 token.

    // ERC20 spec: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md



    uint256 public totalSupply;



    string public name = "SideBridge";

    // BETH = bridged ether

    string public symbol = "BETH";

    // 1-1 mapping of ether to tokens

    uint8 public decimals = 18;



    /// maps addresses to their token balances

    mapping (address => uint256) public balances;



    // owner of account approves the transfer of an amount by another account

    mapping(address => mapping (address => uint256)) allowed;



    /// Event created on money transfer

    event Transfer(address indexed from, address indexed to, uint256 tokens);



    // returns the ERC20 token balance of the given address

    function balanceOf(address tokenOwner) public view returns (uint256) {

        return balances[tokenOwner];

    }



    /// Transfer `value` to `recipient` on this `side` chain.

    ///

    /// does not affect `main` chain. does not do a relay.

    /// as specificed in ERC20 this doesn't fail if tokens == 0.

    function transfer(address recipient, uint256 tokens) public returns (bool) {

        require(balances[msg.sender] >= tokens);

        // fails if there is an overflow

        require(balances[recipient] + tokens >= balances[recipient]);



        balances[msg.sender] -= tokens;

        balances[recipient] += tokens;

        Transfer(msg.sender, recipient, tokens);

        return true;

    }



    // following is the part of SideBridge that is concerned

    // with the part of the ERC20 standard responsible for giving others spending rights

    // and spending others tokens



    // created when `approve` is executed to mark that

    // `tokenOwner` has approved `spender` to spend `tokens` of his tokens

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);



    // allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.

    // calling this function repeatedly overwrites the current allowance.

    function approve(address spender, uint256 tokens) public returns (bool) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }



    // returns how much `spender` is allowed to spend of `owner`s tokens

    function allowance(address owner, address spender) public view returns (uint256) {

        return allowed[owner][spender];

    }



    function transferFrom(address from, address to, uint tokens) public returns (bool) {

        // `from` has enough tokens

        require(balances[from] >= tokens);

        // `sender` is allowed to move `tokens` from `from`

        require(allowed[from][msg.sender] >= tokens);

        // fails if there is an overflow

        require(balances[to] + tokens >= balances[to]);



        balances[to] += tokens;

        balances[from] -= tokens;

        allowed[from][msg.sender] -= tokens;



        Transfer(from, to, tokens);

        return true;

    }



    // following is the part of SideBridge that is

    // no longer part of ERC20 and is concerned with

    // with moving tokens from and to MainBridge



    struct SignaturesCollection {

        /// Signed message.

        bytes message;

        /// Authorities who signed the message.

        address[] authorities;

        /// Signatures

        bytes[] signatures;

    }



    /// Number of authorities signatures required to withdraw the money.

    ///

    /// Must be less than number of authorities.

    uint256 public requiredSignatures;



    uint256 public estimatedGasCostOfWithdraw;



    /// Contract authorities.

    address[] public authorities;



    /// Pending deposits and authorities who confirmed them

    mapping (bytes32 => address[]) deposits;



    /// Pending signatures and authorities who confirmed them

    mapping (bytes32 => SignaturesCollection) signatures;



    /// triggered when an authority confirms a deposit

    event DepositConfirmation(address recipient, uint256 value, bytes32 transactionHash);



    /// triggered when enough authorities have confirmed a deposit

    event Deposit(address recipient, uint256 value, bytes32 transactionHash);



    /// Event created on money withdraw.

    event Withdraw(address recipient, uint256 value, uint256 mainGasPrice);



    event WithdrawSignatureSubmitted(bytes32 messageHash);



    /// Collected signatures which should be relayed to main chain.

    event CollectedSignatures(address indexed authorityResponsibleForRelay, bytes32 messageHash);



    function SideBridge(

        uint256 _requiredSignatures,

        address[] _authorities,

        uint256 _estimatedGasCostOfWithdraw

    ) public

    {

        require(_requiredSignatures != 0);

        require(_requiredSignatures <= _authorities.length);

        requiredSignatures = _requiredSignatures;

        authorities = _authorities;

        estimatedGasCostOfWithdraw = _estimatedGasCostOfWithdraw;

    }



    // Called by the bridge node processes on startup

    // to determine early whether the address pointing to the side

    // bridge contract is misconfigured.

    // so we can provide a helpful error message instead of the

    // very unhelpful errors encountered otherwise.

    function isSideBridgeContract() public pure returns (bool) {

        return true;

    }



    /// require that sender is an authority

    modifier onlyAuthority() {

        require(Helpers.addressArrayContains(authorities, msg.sender));

        _;

    }



    /// Used to deposit money to the contract.

    ///

    /// deposit recipient (bytes20)

    /// deposit value (uint256)

    /// mainnet transaction hash (bytes32) // to avoid transaction duplication

    function deposit(address recipient, uint256 value, bytes32 transactionHash) public onlyAuthority() {

        // Protection from misbehaving authority

        var hash = keccak256(recipient, value, transactionHash);



        // don't allow authority to confirm deposit twice

        require(!Helpers.addressArrayContains(deposits[hash], msg.sender));



        deposits[hash].push(msg.sender);



        // TODO: this may cause troubles if requiredSignatures len is changed

        if (deposits[hash].length != requiredSignatures) {

            DepositConfirmation(recipient, value, transactionHash);

            return;

        }



        balances[recipient] += value;

        // mints tokens

        totalSupply += value;

        // ERC20 specifies: a token contract which creates new tokens

        // SHOULD trigger a Transfer event with the _from address

        // set to 0x0 when tokens are created.

        Transfer(0x0, recipient, value);

        Deposit(recipient, value, transactionHash);

    }



    /// Transfer `value` from `msg.sender`s local balance (on `side` chain) to `recipient` on `main` chain.

    ///

    /// immediately decreases `msg.sender`s local balance.

    /// emits a `Withdraw` event which will be picked up by the bridge authorities.

    /// bridge authorities will then sign off (by calling `submitSignature`) on a message containing `value`,

    /// `recipient` and the `hash` of the transaction on `side` containing the `Withdraw` event.

    /// once `requiredSignatures` are collected a `CollectedSignatures` event will be emitted.

    /// an authority will pick up `CollectedSignatures` an call `MainBridge.withdraw`

    /// which transfers `value - relayCost` to `recipient` completing the transfer.

    function transferToMainViaRelay(address recipient, uint256 value, uint256 mainGasPrice) public {

        require(balances[msg.sender] >= value);

        // don't allow 0 value transfers to main

        require(value > 0);



        uint256 estimatedWeiCostOfWithdraw = estimatedGasCostOfWithdraw * mainGasPrice;

        require(value > estimatedWeiCostOfWithdraw);



        balances[msg.sender] -= value;

        // burns tokens

        totalSupply -= value;

        // in line with the transfer event from `0x0` on token creation

        // recommended by ERC20 (see implementation of `deposit` above)

        // we trigger a Transfer event to `0x0` on token destruction

        Transfer(msg.sender, 0x0, value);

        Withdraw(recipient, value, mainGasPrice);

    }



    /// Should be used as sync tool

    ///

    /// Message is a message that should be relayed to main chain once authorities sign it.

    ///

    /// for withdraw message contains:

    /// withdrawal recipient (bytes20)

    /// withdrawal value (uint256)

    /// side transaction hash (bytes32) // to avoid transaction duplication

    function submitSignature(bytes signature, bytes message) public onlyAuthority() {

        // ensure that `signature` is really `message` signed by `msg.sender`

        require(msg.sender == MessageSigning.recoverAddressFromSignedMessage(signature, message));



        require(message.length == 116);

        var hash = keccak256(message);



        // each authority can only provide one signature per message

        require(!Helpers.addressArrayContains(signatures[hash].authorities, msg.sender));

        signatures[hash].message = message;

        signatures[hash].authorities.push(msg.sender);

        signatures[hash].signatures.push(signature);



        // TODO: this may cause troubles if requiredSignatures len is changed

        if (signatures[hash].authorities.length == requiredSignatures) {

            CollectedSignatures(msg.sender, hash);

        } else {

            WithdrawSignatureSubmitted(hash);

        }

    }



    function hasAuthoritySignedMainToSide(address authority, address recipient, uint256 value, bytes32 mainTxHash) public view returns (bool) {

        var hash = keccak256(recipient, value, mainTxHash);



        return Helpers.addressArrayContains(deposits[hash], authority);

    }



    function hasAuthoritySignedSideToMain(address authority, bytes message) public view returns (bool) {

        require(message.length == 116);

        var messageHash = keccak256(message);

        return Helpers.addressArrayContains(signatures[messageHash].authorities, authority);

    }



    /// Get signature

    function signature(bytes32 messageHash, uint256 index) public view returns (bytes) {

        return signatures[messageHash].signatures[index];

    }



    /// Get message

    function message(bytes32 message_hash) public view returns (bytes) {

        return signatures[message_hash].message;

    }

}