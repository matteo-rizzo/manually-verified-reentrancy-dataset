pragma solidity ^0.4.17;


contract ClaimableSplitCoin {

	using CSCLib for CSCLib.CSCStorage;

	CSCLib.CSCStorage csclib;

	function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable) public {
		csclib.isClaimable = claimable;
		csclib.dev_fee = 2500;
		csclib.developer = 0xaB48Dd4b814EBcb4e358923bd719Cd5cd356eA16;
		csclib.refer_fee = 250;
		csclib.init(members, ppms, refer);
	}

	function () public payable {
		csclib.pay();
	}

	function developer() public view returns(address) {
		return csclib.developer;
	}

	function getSplitCount() public view returns (uint count) {
		return csclib.getSplitCount();
	}

	function splits(uint index) public view returns (address to, uint ppm) {
		return (csclib.splits[index].to, csclib.splits[index].ppm);
	}

	event SplitTransfer(address to, uint amount, uint balance);

	function claimFor(address user) public {
		csclib.claimFor(user);
	}

	function claim() public {
		csclib.claimFor(msg.sender);
	}

	function getClaimableBalanceFor(address user) public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(user);
	}

	function getClaimableBalance() public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(msg.sender);
	}

	function transfer(address to, uint ppm) public {
		csclib.transfer(to, ppm);
	}
}
contract SplitCoinFactory {
  mapping(address => address[]) public contracts;
  mapping(address => uint) public referralContracts;
  mapping(address => address) public referredBy;
  mapping(address => address[]) public referrals;
  address[] public deployed;
  event Deployed (
    address _deployed
  );


  function make(address[] users, uint[] ppms, address refer, bool claimable) public returns (address) {
    address referContract = referredBy[msg.sender];
    if(refer != 0x0 && referContract == 0x0 && contracts[refer].length > 0 ) {
      uint referContractIndex = referralContracts[refer] - 1;
      if(referContractIndex >= 0 && refer != msg.sender) {
        referContract = contracts[refer][referContractIndex];
        referredBy[msg.sender] = referContract;
        referrals[refer].push(msg.sender);
      }
    }
    address sc = new ClaimableSplitCoin(users, ppms, referContract, claimable);
    contracts[msg.sender].push(sc);
    deployed.push(sc);
    Deployed(sc);
    return sc;
  }

  function generateReferralAddress(address refer) public returns (address) {
    uint[] memory ppms = new uint[](1);
    address[] memory users = new address[](1);
    ppms[0] = 1000000;
    users[0] = msg.sender;

    address referralContract = make(users, ppms, refer, true);
    if(referralContract != 0x0) {
      uint index = contracts[msg.sender].length;
      referralContracts[msg.sender] = index;
    }
    return referralContract;
  }
}