pragma solidity 0.4.21;



// Wolf Crypto presale pooling contract

// written by @iamdefinitelyahuman

















contract PresalePool {

	

	using PresaleLib for PresaleLib.Data;

	PresaleLib.Data data;

  

  event ERC223Received (address token, uint value, bytes data);

	

	function PresalePool (uint fee, address receiver, uint contractCap, uint individualCap) public {

    data.newPool(fee, receiver, contractCap, individualCap);

	}

	

	function () public payable {

    if (msg.value > 0) {

      if (!data.poolSubmitted) {

        data.deposit();

      } else {

        data.receiveRefund();

      }

    } else {

      data.withdraw();

    }

	}

  

  function setIndividualCaps (address[] addr, uint[] cap) public {

    data.setIndividualCaps(addr, cap); 

  }

  

  function setCaps (uint32[] times, uint[] caps) public {

    data.setCaps(times,caps);

  }

  

  function setContractCap (uint amount) public {

    data.setContractCap(amount);

  }

  

  function getPoolInfo () view public returns (uint balance, uint remaining, uint cap) {

    return data.getPoolInfo();

  }

  

  function getContributorInfo (address addr) view public returns (uint balance, uint remaining, uint cap) {

    return data.getContributorInfo(addr);

  }

  

  function getCapAtTime (uint32 time) view public returns (uint) {

    return data.getCapAtTime(time);

  }

  

  function checkWithdrawalAvailable (address addr) view public returns (bool) {

    return data.checkWithdrawalAvailable(addr);

  }

  

  function getReceiverAddress () view public returns (address) {

    return data.receiver;

  }

  

  function setReceiverAddress (address receiver) public {

    data.setReceiverAddress(receiver);

  }

  

  function submitPool (uint amountInWei) public {

    data.submitPool(amountInWei);

  }

  

  function enableWithdrawals (address tokenAddress, address feeAddress) public {

    data.enableWithdrawals(tokenAddress, feeAddress);

  }

  

  function tokenFallback (address from, uint value, bytes calldata) public {

    emit ERC223Received(from, value, calldata);

  }

	

}