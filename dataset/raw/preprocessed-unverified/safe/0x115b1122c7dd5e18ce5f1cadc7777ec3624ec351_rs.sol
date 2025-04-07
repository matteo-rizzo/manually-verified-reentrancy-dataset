/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * @title FixidityLib
 * @author Gadi Guy, Alberto Cuesta Canada
 * @notice This library provides fixed point arithmetic with protection against
 * overflow. 
 * All operations are done with int256 and the operands must have been created 
 * with any of the newFrom* functions, which shift the comma digits() to the 
 * right and check for limits.
 * When using this library be sure of using maxNewFixed() as the upper limit for
 * creation of fixed point numbers. Use maxFixedMul(), maxFixedDiv() and
 * maxFixedAdd() if you want to be certain that those operations don't 
 * overflow.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




contract MeowDAO is IERC20, Context {
  using FixidityLib for int256;

  uint256 _totalSupply = 0;
  string private _name;
  string private _symbol;

  uint8 private _decimals = 13;
  uint private _contractStart;

  address public grumpyAddress;
  address public grumpyFuelTankAddress;
  uint public swapEndTime;

  bool public launched = false;

  uint256 public totalStartingSupply = 10**10 * 10**13; //10_000_000_000.0_000_000_000_000 10 billion MEOWS. 10^23

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => uint) public periodStart;
  mapping (address => bool) public currentlyStaked;
  mapping (address => uint) public unlockStartTime;
  mapping (address => address) public currentVotes;
  mapping (address => uint256) public voteWeights;

  mapping (address => uint256) public stakingCoordinatesTime;
  mapping (address => uint256) public stakingCoordinatesAmount;

  mapping(address => uint256) public voteCounts;
  address[] public voteIterator;
  mapping(address => bool) public walletWasVotedFor;
  address public currentCharityWallet;

  constructor(address _grumpyAddress, address _grumpyFuelTankAddress, string memory __name, string memory __symbol) {
    _name = __name;
    _symbol = __symbol;

    _contractStart = block.timestamp;

    grumpyAddress = _grumpyAddress;
    grumpyFuelTankAddress = _grumpyFuelTankAddress;

    swapEndTime = block.timestamp + (86400 * 5);
  }

  function _swapGrumpyInternal(address user, uint256 amount) private {
    require(block.timestamp < swapEndTime);
    require(!isStaked(user), "cannot swap into staked wallet");
    
    IERC20(grumpyAddress).transferFrom(user, grumpyFuelTankAddress, amount);
    IFuelTank(grumpyFuelTankAddress).addTokens(user, amount);

    _balances[user] += amount;

    _totalSupply += amount;

    emit Transfer(address(0), user, amount);
  }

  function swapGrumpy(uint256 amount) public {
    _swapGrumpyInternal(_msgSender(), amount);
  }

  function initializeCoinThruster() external {
    require(block.timestamp >= swapEndTime, "NotReady");
    require(launched == false, "AlreadyLaunched");

    IFuelTank(grumpyFuelTankAddress).openNozzle();

    if (totalStartingSupply > _totalSupply) {
      uint256 remainingTokens = totalStartingSupply - _totalSupply;

      _balances[grumpyFuelTankAddress] = _balances[grumpyFuelTankAddress] + remainingTokens;
      _totalSupply += remainingTokens;

      emit Transfer(address(0), grumpyFuelTankAddress, remainingTokens);
    }

    launched = true;
  }

  function getBlockTime() public view returns (uint) {
    return block.timestamp;
  }

  function isStaked(address wallet) public view returns (bool) {
    return currentlyStaked[wallet];
  }

  function isUnlocked(address wallet) private returns (bool) {
    uint unlockStarted = unlockStartTime[wallet];

    if (unlockStarted == 0) return true;

    uint unlockedAt = unlockStarted + (86400 * 5);

    if (block.timestamp > unlockedAt) {
      unlockStartTime[wallet] = 0;
      return true;
    }
    else return false;
  }

  function _stakeWalletFor(address sender) private returns (bool) {
    require(!isStaked(sender));
    require(enoughFundsToStake(sender), "InsfcntFnds");
    require(isUnlocked(sender), "WalletIsLocked");

    currentlyStaked[sender] = true;
    unlockStartTime[sender] = 0;
    currentVotes[sender] = address(0);
    periodStart[sender] = block.timestamp;

    stakingCoordinatesTime[sender] = block.timestamp;
    stakingCoordinatesAmount[sender] = _balances[sender];

    return true;
  }

  function stakeWallet() public returns (bool) {
    return _stakeWalletFor(_msgSender());
  }

  function _unstakeWalletFor(address sender, bool shouldReify) private {
    require(isStaked(sender));

    if (shouldReify) reifyYield(sender);

    if (voteWeights[sender] != 0) {
      removeVoteWeight(sender);
      updateCharityWallet();
    }

    currentlyStaked[sender] = false;
    currentVotes[sender] = address(0);
    voteWeights[sender] = 0;
    periodStart[sender] = 0;

    stakingCoordinatesTime[sender] = 0;
    stakingCoordinatesAmount[sender] = 0;

    unlockStartTime[sender] = block.timestamp;
  } 

  function unstakeWallet() public {
    _unstakeWalletFor(_msgSender(), true);
  }

  function unstakeWalletSansReify() public {
    _unstakeWalletFor(_msgSender(), false);
  }

  function voteIteratorLength() external view returns (uint) {
    return voteIterator.length;
  }

  function voteWithRebuildIfNecessary(address charityWalletVote) public {
    if (voteIterator.length == 12 && !walletWasVotedFor[charityWalletVote]) {
      rebuildVotingIterator();
    }
    _voteForAddressBy(charityWalletVote, _msgSender());
  }

  function rebuildVotingIterator() public {
    require(voteIterator.length == 12, "Voting Iterator not full");

    address[12] memory voteCopy;
    for (uint i = 0; i < 12; i++) {
      voteCopy[i] = voteIterator[i];
    }

    //insertion sort copy
    for (uint i = 1; i < 12; i++)
    {
      address keyAddress = voteCopy[i];
      uint key = voteCounts[keyAddress];

      uint j = i - 1;

      bool broke = false;
      while (j >= 0 && voteCounts[voteCopy[j]] < key) {
        voteCopy[j + 1] = voteCopy[j];

        if (j == 0) {
          broke = true;
          break;
        }
        else j--;
      }

      if (broke) voteCopy[0] = keyAddress;
      else voteCopy[j + 1] = keyAddress;
    }

    for (uint i = 11; i >= 6; i--) {
      address vote = voteCopy[i];
      walletWasVotedFor[vote] = false;
    }

    delete voteIterator;
    for (uint i = 0; i < 6; i++) {
      voteIterator.push(voteCopy[i]);
    }

  }

  function _voteForAddressBy(address charityWalletVote, address sender) private {
    require(isStaked(sender));

    trackCandidate(charityWalletVote);

    removeVoteWeight(sender);
    setVoteWeight(sender);
    addVoteWeight(sender, charityWalletVote);
    updateCharityWallet();
  }

  function trackCandidate(address charityWalletCandidate) private {
    // If wallet was never voted for before add it to voteIterator
    if (!walletWasVotedFor[charityWalletCandidate]) {
      require(voteIterator.length < 12, "Vote Iterator must be rebuilt");

      voteIterator.push(charityWalletCandidate);
      walletWasVotedFor[charityWalletCandidate] = true;
    }
  }

  function removeVoteWeight(address sender) private {
    address vote = currentVotes[sender];
    voteCounts[vote] = voteCounts[vote] - voteWeights[sender];
  }

  function setVoteWeight(address sender) private {
    uint256 newVoteWeight = _balances[sender];
    voteWeights[sender] = newVoteWeight;
  }

  function addVoteWeight(address sender, address charityWalletVote) private {
    voteCounts[charityWalletVote] = voteCounts[charityWalletVote] + voteWeights[sender];
    currentVotes[sender] = charityWalletVote;
  }

  function voteForAddress(address charityWalletVote) public {
    _voteForAddressBy(charityWalletVote, _msgSender());
  }

  event NewCharityWallet(address oldW, address newW);

  function updateCharityWallet() private {
    uint256 maxVoteValue = 0; 
    address winner = address(0);

    for (uint i = 0; i < voteIterator.length; i++) {
      address currentWallet = voteIterator[i];
      uint256 voteValue = voteCounts[currentWallet];

      if (voteValue > maxVoteValue) {
        maxVoteValue = voteValue;
        winner = currentWallet;
      }
    }

    if (currentCharityWallet == winner) return;

    emit NewCharityWallet(currentCharityWallet, winner);

    currentCharityWallet = winner;
  }

  function validCharityWallet() internal view returns (bool) {
    return currentCharityWallet != address(0) && !isStaked(currentCharityWallet);
  }

  function getCompoundingFactor(address wallet) private view returns (uint) {
    return block.timestamp - periodStart[wallet];
  }

  function calculateYield(uint256 principal, uint n) public pure returns (uint256) {
    int256 fixedPrincipal = int256(principal).newFixed();

    int256 rate = int256(2144017221509).newFixedFraction(1000000000000000000000);
    int256 fixed2 = int256(2).newFixed();

    while (n > 0) {
      if (n % 2 == 1) {
        fixedPrincipal = fixedPrincipal.add(fixedPrincipal.multiply(rate));
        n -= 1;
      }
      else {
        rate = (fixed2.multiply(rate))
          .add(rate.multiply(rate));
        n /= 2;
      }
    }
    return uint256(fixedPrincipal.fromFixed()) - principal;
  }

  function getTransactionFee(uint256 txAmt) private view returns (uint256){
    uint period = block.timestamp - _contractStart;

    if (period > 31536000) return 0;
    else if (period > 23652000) return txAmt / 400;
    else if (period > 15768000) return txAmt / 200;
    else if (period > 7884000) return (txAmt / 400) * 3;
    else return txAmt / 100;
  } 

  function reifyYield(address wallet) public {
    require(isStaked(wallet), 'MstBeStkd');

    uint compoundingFactor = getCompoundingFactor(wallet);

    if (compoundingFactor < 60) return;

    uint256 yield = calculateYield(_balances[wallet], compoundingFactor);

    _balances[wallet] += yield;

    if (validCharityWallet()) {
      uint256 charityYield = (yield / 7) * 3;
      _balances[currentCharityWallet] += charityYield;
      _totalSupply += (yield + charityYield);
    } else {
      _totalSupply += yield;
    }

    periodStart[wallet] = block.timestamp;
  }

  function enoughFundsToStake(address wallet) private view returns (bool) {
    return _balances[wallet] >= 10000000000000000;
  }

  function name() external view returns (string memory) {
    return _name;
  } 

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function contractStart() external view returns (uint) {
    return _contractStart;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    uint b = _balances[account];

    if (isStaked(account) && currentCharityWallet != account) {
      return b + calculateYield(b, getCompoundingFactor(account));
    }
    return b;
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(!isStaked(sender), "StkdWlltCnntTrnsf");
    require(isUnlocked(sender), "LockedWlltCnntTrnsfr");
    require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

    if (isStaked(recipient)) {
      reifyYield(recipient);
    }

    uint sentAmount = amount; 

    if (validCharityWallet()) {
      uint256 txFee = getTransactionFee(amount);

      if (txFee != 0) {
        sentAmount -= txFee;
        _balances[currentCharityWallet] += txFee;
      }
    }

    _balances[sender] -= amount;
    _balances[recipient] += sentAmount;

    emit Transfer(sender, recipient, amount);
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    _approve(sender, _msgSender(), currentAllowance - amount);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    return true;
  }
}