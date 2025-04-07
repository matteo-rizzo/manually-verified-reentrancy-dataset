/**

 *Submitted for verification at Etherscan.io on 2018-11-11

*/



pragma solidity 0.4.24;



// File: contracts/IAccounting.sol







// File: contracts/IAccountingFactory.sol







// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: contracts/IDisputer.sol



/**

 * Interface of what the disputer contract should do.

 *

 * Its main responsibility to interact with Augur. Only minimal glue methods

 * are added apart from that in order for crowdsourcer to be able to interact

 * with it.

 *

 * This contract holds the actual crowdsourced REP for dispute, so it doesn't

 * need to transfer it from elsewhere at the moment of dispute. It doesn't care

 * at all who this REP belongs to, it just spends it for dispute. Accounting

 * is done in other contracts.

 */





// File: contracts/ICrowdsourcerParent.sol



/**

 * Parent of a crowdsourcer that is passed into it on construction. Used

 * to determine destination for fees.

 */





// File: contracts/augur/feeWindow.sol







// File: contracts/augur/universe.sol







// File: contracts/augur/reportingParticipant.sol



/**

 * This should've been an interface, but interfaces cannot inherit interfaces

 */

contract ReportingParticipant is IERC20 {

  function redeem(address _redeemer) external returns(bool);

  function getStake() external view returns(uint256);

  function getPayoutDistributionHash() external view returns(bytes32);

  function getFeeWindow() external view returns(FeeWindow);

}



// File: contracts/augur/market.sol







// File: contracts/ICrowdsourcer.sol



/**

 * Crowdsourcer for specific market/outcome/round.

 */





// File: contracts/IDisputerFactory.sol







// File: contracts/DisputerParams.sol







// File: contracts/Crowdsourcer.sol



contract Crowdsourcer is ICrowdsourcer {

  bool public m_isInitialized = false;

  DisputerParams.Params public m_disputerParams;

  IAccountingFactory public m_accountingFactory;

  IDisputerFactory public m_disputerFactory;



  IAccounting public m_accounting;

  ICrowdsourcerParent public m_parent;

  IDisputer public m_disputer;



  mapping(address => bool) public m_proceedsCollected;

  bool public m_feesCollected = false;



  constructor(

    ICrowdsourcerParent parent,

    IAccountingFactory accountingFactory,

    IDisputerFactory disputerFactory,

    Market market,

    uint256 feeWindowId,

    uint256[] payoutNumerators,

    bool invalid

  ) public {

    m_parent = parent;

    m_accountingFactory = accountingFactory;

    m_disputerFactory = disputerFactory;

    m_disputerParams = DisputerParams.Params(

      market,

      feeWindowId,

      payoutNumerators,

      invalid

    );

  }



  modifier beforeDisputeOnly() {

    require(!hasDisputed(), "Method only allowed before dispute");

    _;

  }



  modifier requiresInitialization() {

    require(isInitialized(), "Must call initialize() first");

    _;

  }



  modifier requiresFinalization() {

    if (!isFinalized()) {

      finalize();

      assert(isFinalized());

    }

    _;

  }



  function initialize() external {

    require(!m_isInitialized, "Already initialized");

    m_isInitialized = true;

    m_accounting = m_accountingFactory.create(this);

    m_disputer = m_disputerFactory.create(

      this,

      m_disputerParams.market,

      m_disputerParams.feeWindowId,

      m_disputerParams.payoutNumerators,

      m_disputerParams.invalid

    );

    emit Initialized();

  }



  function contribute(

    uint128 amount,

    uint128 feeNumerator

  ) external requiresInitialization beforeDisputeOnly {

    uint128 amountWithFees = m_accounting.addFeesOnTop(amount, feeNumerator);



    IERC20 rep = getREP();

    require(rep.balanceOf(msg.sender) >= amountWithFees, "Not enough funds");

    require(

      rep.allowance(msg.sender, this) >= amountWithFees,

      "Now enough allowance"

    );



    // record contribution in accounting (will perform validations)

    uint128 deposited;

    uint128 depositedFees;

    (deposited, depositedFees) = m_accounting.contribute(

      msg.sender,

      amount,

      feeNumerator

    );



    assert(deposited == amount);

    assert(deposited + depositedFees == amountWithFees);



    // actually transfer tokens and revert tx if any problem

    assert(rep.transferFrom(msg.sender, m_disputer, deposited));

    assert(rep.transferFrom(msg.sender, this, depositedFees));



    assertBalancesBeforeDispute();



    emit ContributionAccepted(msg.sender, amount, feeNumerator);

  }



  function withdrawContribution(



  ) external requiresInitialization beforeDisputeOnly {

    IERC20 rep = getREP();



    // record withdrawal in accounting (will perform validations)

    uint128 withdrawn;

    uint128 withdrawnFees;

    (withdrawn, withdrawnFees) = m_accounting.withdrawContribution(msg.sender);



    // actually transfer tokens and revert tx if any problem

    assert(rep.transferFrom(m_disputer, msg.sender, withdrawn));

    assert(rep.transfer(msg.sender, withdrawnFees));



    assertBalancesBeforeDispute();



    emit ContributionWithdrawn(msg.sender, withdrawn);

  }



  function withdrawProceeds(address contributor) external requiresFinalization {

    require(

      !m_proceedsCollected[contributor],

      "Can only collect proceeds once"

    );



    // record proceeds have been collected

    m_proceedsCollected[contributor] = true;



    uint128 refund;

    uint128 proceeds;



    // calculate how much this contributor is entitled to

    (refund, proceeds) = m_accounting.calculateProceeds(contributor);



    IERC20 rep = getREP();

    IERC20 disputeTokenAddress = getDisputeToken();



    // actually deliver the proceeds/refund

    assert(rep.transfer(contributor, refund));

    assert(disputeTokenAddress.transfer(contributor, proceeds));



    emit ProceedsWithdrawn(contributor, proceeds, refund);

  }



  function withdrawFees() external requiresFinalization {

    require(!m_feesCollected, "Can only collect fees once");



    m_feesCollected = true;



    uint128 feesTotal = m_accounting.calculateFees();

    // 10% of fees go to contract author

    uint128 feesForContractAuthor = feesTotal / 10;

    uint128 feesForExecutor = feesTotal - feesForContractAuthor;



    assert(feesForContractAuthor + feesForExecutor == feesTotal);



    address contractFeesRecipient = m_parent.getContractFeeReceiver();

    address executorFeesRecipient = m_disputer.feeReceiver();



    IERC20 rep = getREP();



    assert(rep.transfer(contractFeesRecipient, feesForContractAuthor));

    assert(rep.transfer(executorFeesRecipient, feesForExecutor));



    emit FeesWithdrawn(

      contractFeesRecipient,

      executorFeesRecipient,

      feesForContractAuthor,

      feesForExecutor

    );

  }



  function getParent() external view returns(ICrowdsourcerParent) {

    return m_parent;

  }



  function getDisputerParams() external view returns(

    Market market,

    uint256 feeWindowId,

    uint256[] payoutNumerators,

    bool invalid

  ) {

    return (m_disputerParams.market, m_disputerParams.feeWindowId, m_disputerParams.payoutNumerators, m_disputerParams.invalid);

  }



  function getDisputer() external view requiresInitialization returns(

    IDisputer

  ) {

    return m_disputer;

  }



  function getAccounting() external view requiresInitialization returns(

    IAccounting

  ) {

    return m_accounting;

  }



  function finalize() public requiresInitialization {

    require(hasDisputed(), "Can only finalize after dispute");

    require(!isFinalized(), "Can only finalize once");



    // now that we've disputed we must know dispute token address

    IERC20 disputeTokenAddress = getDisputeToken();

    IERC20 rep = getREP();



    m_disputer.approveManagerToSpendDisputeTokens();



    // retrieve all tokens from disputer for proceeds distribution

    // This wouldn't work extremely well if it is called from disputer's

    // dispute() method, but it should only call Augur which we trust.

    assert(rep.transferFrom(m_disputer, this, rep.balanceOf(m_disputer)));

    assert(

      disputeTokenAddress.transferFrom(

        m_disputer,

        this,

        disputeTokenAddress.balanceOf(m_disputer)

      )

    );



    uint256 amountDisputed = disputeTokenAddress.balanceOf(this);

    uint128 amountDisputed128 = uint128(amountDisputed);



    // REP has only so many tokens

    assert(amountDisputed128 == amountDisputed);



    m_accounting.finalize(amountDisputed128);



    assert(isFinalized());



    emit CrowdsourcerFinalized(amountDisputed128);

  }



  function isInitialized() public view returns(bool) {

    return m_isInitialized;

  }



  function getREP() public view requiresInitialization returns(IERC20) {

    return m_disputer.getREP();

  }



  function getDisputeToken() public view requiresInitialization returns(

    IERC20

  ) {

    return m_disputer.getDisputeTokenAddress();

  }



  function hasDisputed() public view requiresInitialization returns(bool) {

    return m_disputer.hasDisputed();

  }



  function isFinalized() public view requiresInitialization returns(bool) {

    return m_accounting.isFinalized();

  }



  function assertBalancesBeforeDispute() internal view {

    IERC20 rep = getREP();

    assert(rep.balanceOf(m_disputer) >= m_accounting.getTotalContribution());

    assert(rep.balanceOf(this) >= m_accounting.getTotalFeesOffered());

  }

}