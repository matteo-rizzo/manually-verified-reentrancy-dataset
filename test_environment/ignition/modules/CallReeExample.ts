import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export default buildModule("CallReeModule", (m) => {
  const oneEther = ethers.parseEther("1.0");

  const deployer = m.getAccount(0);
  const callRee = m.contract("CallRee", [], { from: deployer });

  const victim = m.getAccount(1);
  m.call(callRee, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

  const victim2 = m.getAccount(2);
  m.call(callRee, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

  const attacker = m.getAccount(3);
  const lowLevelCallAttacker = m.contract("LowLevelCallAttacker", [callRee], { from: attacker });
  m.call(lowLevelCallAttacker, "attack", [], { value: oneEther, from: attacker });
  m.call(lowLevelCallAttacker, "collectEther", [], { from: attacker });

  return { callRee, lowLevelCallAttacker };
});
