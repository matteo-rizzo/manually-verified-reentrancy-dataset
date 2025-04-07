/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;





contract Staker {
  using SafeMath for uint256;

  address public owner;
  modifier ownerOnly {
    require(msg.sender == owner, "OWNER ONLY");
    _;
  }

  ERC20Basic public TEAL;
  uint256[4] public periods = [30 days, 60 days, 90 days, 180 days];
  uint256[4] public rates = [1030, 1050, 1075, 1100];
  uint256[4] public amounts = [100, 500, 1000, 5000];
  struct Stake {
    uint256 start; // when cycle started
    uint256 amount; // amount currently held
    uint256 rate; // rate for current cycle
    uint8 period; // type: 0, 1, 2, 3
    uint8 cycle; // current cycle (starts from 1)
  }
  mapping(address => Stake) public stakes;

  function stake(uint8 _period) public {
    require(stakes[msg.sender].start == 0, "Already staking");
    require(_period < 4, "Invalid period, must be from 0 to 3");

    require(TEAL.transferFrom(msg.sender, address(this), amounts[_period]), "Transfer failed, check allowance");
    stakes[msg.sender] = Stake({start: block.timestamp, amount: amounts[_period], rate: rates[_period], period: _period, cycle: 1});
  }

  function unstake() public {
    require(stakes[msg.sender].start != 0, "Not staking");
    Stake storage _s = stakes[msg.sender];
    uint8 _t = _s.period;
    require(block.timestamp >= _s.start + periods[_t], "Period not passed yet");

    uint256 amount = _s.amount.mul(_s.rate).div(1000);
    require(TEAL.transfer(msg.sender, amount), "Transfer failed, check contract balance");
    delete stakes[msg.sender];
  }

  function prolong() public {
    require(stakes[msg.sender].start != 0, "Not staking");
    Stake storage _s = stakes[msg.sender];
    uint256 _p = periods[_s.period];
    require(block.timestamp >= _s.start + _p, "Period not passed yet");
    require(_s.cycle * _p < 360 days, "Prolong limit reached. Should unstake");

    _s.start = block.timestamp;
    _s.amount = _s.amount.mul(_s.rate).div(1000);
    _s.rate = rates[_s.period];
    _s.cycle++;
  }

  function updateRate(uint8 _period, uint256 _value) public ownerOnly {
    rates[_period] = _value;
  }

  function transferOwnership(address _owner) public ownerOnly {
    owner = _owner;
  }

  constructor (ERC20Basic _token) {
    TEAL = ERC20Basic(_token);
    owner = msg.sender;
  }
}