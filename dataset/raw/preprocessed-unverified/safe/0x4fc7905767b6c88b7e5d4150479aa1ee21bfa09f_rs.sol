/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/*
    Copyright 2019 dYdX Trading Inc.
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/**
 * @title Decimal
 * @author dYdX
 *
 * Library that defines a fixed-point number with 18 decimal places.
 */


/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/


/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Curve {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    function calculateCouponPremium(
        uint256 totalSupply,
        uint256 totalDebt,
        uint256 amount
    ) internal pure returns (uint256) {
        return effectivePremium(totalSupply, totalDebt, amount).mul(amount).asUint256();
    }

    function effectivePremium(
        uint256 totalSupply,
        uint256 totalDebt,
        uint256 amount
    ) private pure returns (Decimal.D256 memory) {
        Decimal.D256 memory debtRatio = Decimal.ratio(totalDebt, totalSupply);
        Decimal.D256 memory debtRatioUpperBound = Constants.getDebtRatioCap();

        uint256 totalSupplyEnd = totalSupply.sub(amount);
        uint256 totalDebtEnd = totalDebt.sub(amount);
        Decimal.D256 memory debtRatioEnd = Decimal.ratio(totalDebtEnd, totalSupplyEnd);

        if (debtRatio.greaterThan(debtRatioUpperBound)) {
            if (debtRatioEnd.greaterThan(debtRatioUpperBound)) {
                return curve(debtRatioUpperBound);
            }

            Decimal.D256 memory premiumCurve = curveMean(debtRatioEnd, debtRatioUpperBound);
            Decimal.D256 memory premiumCurveDelta = debtRatioUpperBound.sub(debtRatioEnd);
            Decimal.D256 memory premiumFlat = curve(debtRatioUpperBound);
            Decimal.D256 memory premiumFlatDelta = debtRatio.sub(debtRatioUpperBound);
            return (premiumCurve.mul(premiumCurveDelta)).add(premiumFlat.mul(premiumFlatDelta))
                .div(premiumCurveDelta.add(premiumFlatDelta));
        }

        return curveMean(debtRatioEnd, debtRatio);
    }

    // 1/(3(1-R)^2)-1/3
    function curve(Decimal.D256 memory debtRatio) private pure returns (Decimal.D256 memory) {
        return Decimal.one().div(
            Decimal.from(3).mul((Decimal.one().sub(debtRatio)).pow(2))
        ).sub(Decimal.ratio(1, 3));
    }

    // 1/(3(1-R)(1-R'))-1/3
    function curveMean(
        Decimal.D256 memory lower,
        Decimal.D256 memory upper
    ) private pure returns (Decimal.D256 memory) {
        if (lower.equals(upper)) {
            return curve(lower);
        }

        return Decimal.one().div(
            Decimal.from(3).mul(Decimal.one().sub(upper)).mul(Decimal.one().sub(lower))
        ).sub(Decimal.ratio(1, 3));
    }
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract IDollar is IERC20 {
    function burn(uint256 amount) public;
    function burnFrom(address account, uint256 amount) public;
    function mint(address account, uint256 amount) public returns (bool);
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract IShare is IERC20 {
    function burn(uint256 amount) public;
    function burnFrom(address account, uint256 amount) public;
    function mint(address account, uint256 amount) public returns (bool);
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract IOracle {
    function setup() public;
    function capture() public returns (Decimal.D256 memory, bool);
    function readPrice() public view returns (Decimal.D256 memory);
    function pair() external view returns (address);
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Account {
    enum Status {
        Frozen,
        Fluid,
        Locked
    }


    struct State {
        uint256 staged;
        uint256 claimable;
        uint256 bonded;
        uint256 phantom;
        mapping(uint256 => uint256) coupons;
        mapping(address => uint256) couponAllowances;
        uint256 fluidUntil;
        uint256 lockedUntil;
    }
}

contract Epoch {
    struct Global {
        uint256 start;
        uint256 period;
        uint256 current;
    }

    struct Coupons {
        uint256 outstanding;
        uint256 expiration;
        uint256[] expiring;
    }

    struct State {
        uint256 bonded;
        Decimal.D256 peg;
        Coupons coupons;
    }
}

contract Candidate {
    enum Vote {
        UNDECIDED,
        APPROVE,
        REJECT
    }

    struct State {
        uint256 start;
        uint256 period;
        uint256 approve;
        uint256 reject;
        mapping(address => Vote) votes;
        bool initialized;
    }
}

contract Storage {
    struct Provider {
        IDollar dollar;
        IShare share;
        IOracle oracle;
        address pool;
        address locker;
        address staker;
    }

    struct Balance {
        uint256 bonded;
        uint256 staged;
        uint256 claimable;
        uint256 phantom;
        uint256 redeemable;
        uint256 debt;
        uint256 coupons;
    }

    struct State {
        Epoch.Global epoch;
        Balance balance;
        Provider provider;
        Decimal.D256 peg;

        mapping(address => Account.State) accounts;
        mapping(uint256 => Epoch.State) epochs;
        mapping(address => Candidate.State) candidates;
    }
}

contract State {
    Storage.State _state;
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Getters is State {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * Global
     */

    function dollar() public view returns (IDollar) {
        return _state.provider.dollar;
    }

    function share() public view returns (IShare) {
        return _state.provider.share;
    }

    function oracle() public view returns (IOracle) {
        return _state.provider.oracle;
    }

    function pool() public view returns (address) {
        return _state.provider.pool;
    }

    function locker() public view returns (address) {
        return _state.provider.locker;
    }

    function staker() public view returns (address) {
        return _state.provider.staker;
    }

    function totalBonded() public view returns (uint256) {
        return _state.balance.bonded;
    }

    function totalStaged() public view returns (uint256) {
        return _state.balance.staged;
    }

    function totalClaimable() public view returns (uint256) {
        return _state.balance.claimable;
    }

    function totalPhantom() public view returns (uint256) {
        return _state.balance.phantom;
    }

    function totalDebt() public view returns (uint256) {
        return _state.balance.debt;
    }

    function totalRedeemable() public view returns (uint256) {
        return _state.balance.redeemable;
    }

    function totalRewarded() public view returns (uint256) {
        return dollar().balanceOf(address(this)).sub(totalClaimable()).sub(totalRedeemable());
    }

    function totalCoupons() public view returns (uint256) {
        return _state.balance.coupons;
    }

    function totalNet() public view returns (uint256) {
        return dollar().totalSupply().sub(totalDebt());
    }

    function getCurrentPeg() public view returns (uint256) {
        return _state.peg.value;
    }

    function stakingRegulator() public view returns (address) {
        return Constants.getStakingRegulator();
    }

    /**
     * Account
     */

    function balanceOfStaged(address account) public view returns (uint256) {
        return _state.accounts[account].staged;
    }

    function balanceOfBonded(address account) public view returns (uint256) {
        return _state.accounts[account].bonded;
    }

    function balanceOfClaimable(address account) public view returns (uint256) {
        return _state.accounts[account].claimable;
    }

    function balanceOfPhantom(address account) public view returns (uint256) {
        return _state.accounts[account].phantom;
    }

    function balanceOfRewarded(address account) public view returns (uint256) {
        uint256 totalBonded = totalBonded();
        if (totalBonded == 0) {
            return 0;
        }

        uint256 totalRewardedWithPhantom = totalRewarded().add(totalPhantom());
        uint256 balanceOfRewardedWithPhantom = totalRewardedWithPhantom
            .mul(balanceOfBonded(account))
            .div(totalBonded);

        uint256 balanceOfPhantom = balanceOfPhantom(account);
        if (balanceOfRewardedWithPhantom > balanceOfPhantom) {
            return balanceOfRewardedWithPhantom.sub(balanceOfPhantom);
        }
        return 0;
    }
    
    function balanceOfCoupons(address account, uint256 epoch) public view returns (uint256) {
        if (outstandingCoupons(epoch) == 0) {
            return 0;
        }
        return _state.accounts[account].coupons[epoch];
    }

    function statusOf(address account) public view returns (Account.Status) {
        if (_state.accounts[account].lockedUntil > epoch()) {
            return Account.Status.Locked;
        }

        return epoch() >= _state.accounts[account].fluidUntil ? Account.Status.Frozen : Account.Status.Fluid;
    }

    function fluidUntil(address account) public view returns (uint256) {
        return _state.accounts[account].fluidUntil;
    }

    function lockedUntil(address account) public view returns (uint256) {
        return _state.accounts[account].lockedUntil;
    }

    function allowanceCoupons(address owner, address spender) public view returns (uint256) {
        return _state.accounts[owner].couponAllowances[spender];
    }

    /**
     * Epoch
     */

    function epoch() public view returns (uint256) {
        return _state.epoch.current;
    }

    function epochTime() public view returns (uint256) {
        Constants.EpochStrategy memory current = Constants.getEpochStrategy();

        return epochTimeWithStrategy(current);
    }

    function epochTimeWithStrategy(Constants.EpochStrategy memory strategy) private view returns (uint256) {
        return blockTimestamp()
            .sub(strategy.start)
            .div(strategy.period)
            .add(strategy.offset);
    }

    // Overridable for testing
    function blockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    function outstandingCoupons(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].coupons.outstanding;
    }

    function couponsExpiration(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].coupons.expiration;
    }

    function expiringCoupons(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].coupons.expiring.length;
    }

    function expiringCouponsAtIndex(uint256 epoch, uint256 i) public view returns (uint256) {
        return _state.epochs[epoch].coupons.expiring[i];
    }

    function totalBondedAt(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].bonded;
    }

    function pegAt(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].peg.value;
    }

    /**
     * Governance
     */

    function recordedVote(address account, address candidate) public view returns (Candidate.Vote) {
        return _state.candidates[candidate].votes[account];
    }

    function startFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].start;
    }

    function periodFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].period;
    }

    function approveFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].approve;
    }

    function rejectFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].reject;
    }

    function votesFor(address candidate) public view returns (uint256) {
        return approveFor(candidate).add(rejectFor(candidate));
    }

    function isNominated(address candidate) public view returns (bool) {
        return _state.candidates[candidate].start > 0;
    }

    function isInitialized(address candidate) public view returns (bool) {
        return _state.candidates[candidate].initialized;
    }

    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Setters is State, Getters {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    /**
     * Global
     */

    function incrementTotalDebt(uint256 amount) internal {
        _state.balance.debt = _state.balance.debt.add(amount);
    }

    function decrementTotalDebt(uint256 amount, string memory reason) internal {
        _state.balance.debt = _state.balance.debt.sub(amount, reason);
    }

    function setDebtToZero() internal {
        _state.balance.debt = 0;
    }

    function incrementTotalRedeemable(uint256 amount) internal {
        _state.balance.redeemable = _state.balance.redeemable.add(amount);
    }

    function decrementTotalRedeemable(uint256 amount, string memory reason) internal {
        _state.balance.redeemable = _state.balance.redeemable.sub(amount, reason);
    }

    function setPeg(uint256 price) internal {
        _state.peg = Decimal.D256({value: price});
    }

    function capturePeg(uint256 epoch) internal {
        _state.epochs[epoch].peg = Decimal.D256({value: getCurrentPeg()});
    }

    /**
     * Account
     */

    function incrementBalanceOfStaged(address account, uint256 amount) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.add(amount);
        _state.balance.staged = _state.balance.staged.add(amount);
    }

    function decrementBalanceOfStaged(address account, uint256 amount, string memory reason) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.sub(amount, reason);
        _state.balance.staged = _state.balance.staged.sub(amount, reason);
    }

    function incrementBalanceOfBonded(address account, uint256 amount) internal {
        _state.accounts[account].bonded = _state.accounts[account].bonded.add(amount);
        _state.balance.bonded = _state.balance.bonded.add(amount);
    }

    function decrementBalanceOfBonded(address account, uint256 amount, string memory reason) internal {
        _state.accounts[account].bonded = _state.accounts[account].bonded.sub(amount, reason);
        _state.balance.bonded = _state.balance.bonded.sub(amount, reason);
    }

    function incrementBalanceOfClaimable(address account, uint256 amount) internal {
        _state.accounts[account].claimable = _state.accounts[account].claimable.add(amount);
        _state.balance.claimable = _state.balance.claimable.add(amount);
    }

    function decrementBalanceOfClaimable(address account, uint256 amount, string memory reason) internal {
        _state.accounts[account].claimable = _state.accounts[account].claimable.sub(amount, reason);
        _state.balance.claimable = _state.balance.claimable.sub(amount, reason);
    }

    function incrementBalanceOfPhantom(address account, uint256 amount) internal {
        _state.accounts[account].phantom = _state.accounts[account].phantom.add(amount);
        _state.balance.phantom = _state.balance.phantom.add(amount);
    }

    function decrementBalanceOfPhantom(address account, uint256 amount, string memory reason) internal {
        _state.accounts[account].phantom = _state.accounts[account].phantom.sub(amount, reason);
        _state.balance.phantom = _state.balance.phantom.sub(amount, reason);
    }

    function incrementBalanceOfCoupons(address account, uint256 epoch, uint256 amount) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].add(amount);
        _state.epochs[epoch].coupons.outstanding = _state.epochs[epoch].coupons.outstanding.add(amount);
        _state.balance.coupons = _state.balance.coupons.add(amount);
    }

    function decrementBalanceOfCoupons(address account, uint256 epoch, uint256 amount, string memory reason) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].sub(amount, reason);
        _state.epochs[epoch].coupons.outstanding = _state.epochs[epoch].coupons.outstanding.sub(amount, reason);
        _state.balance.coupons = _state.balance.coupons.sub(amount, reason);
    }

    function unfreeze(address account) internal {
        _state.accounts[account].fluidUntil = epoch().add(Constants.getDAOExitLockupEpochs());
    }

    function updateAllowanceCoupons(address owner, address spender, uint256 amount) internal {
        _state.accounts[owner].couponAllowances[spender] = amount;
    }

    function decrementAllowanceCoupons(address owner, address spender, uint256 amount, string memory reason) internal {
        _state.accounts[owner].couponAllowances[spender] =
            _state.accounts[owner].couponAllowances[spender].sub(amount, reason);
    }

    /**
     * Epoch
     */

    function incrementEpoch() internal {
        _state.epoch.current = _state.epoch.current.add(1);
    }

    function snapshotTotalBonded() internal {
        _state.epochs[epoch()].bonded = totalBonded();
    }

    function snapshotCurrentPeg() internal {
        _state.epochs[epoch()].peg = Decimal.D256({value: getCurrentPeg()});
    }

    function initializeCouponsExpiration(uint256 epoch, uint256 expiration) internal {
        _state.epochs[epoch].coupons.expiration = expiration;
        _state.epochs[expiration].coupons.expiring.push(epoch);
    }

    function eliminateOutstandingCoupons(uint256 epoch) internal {
        uint256 outstandingCouponsForEpoch = outstandingCoupons(epoch);
        if(outstandingCouponsForEpoch == 0) {
            return;
        }
        _state.balance.coupons = _state.balance.coupons.sub(outstandingCouponsForEpoch);
        _state.epochs[epoch].coupons.outstanding = 0;
    }

    /**
     * Governance
     */

    function createCandidate(address candidate, uint256 period) internal {
        _state.candidates[candidate].start = epoch();
        _state.candidates[candidate].period = period;
    }

    function recordVote(address account, address candidate, Candidate.Vote vote) internal {
        _state.candidates[candidate].votes[account] = vote;
    }

    function incrementApproveFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.add(amount);
    }

    function decrementApproveFor(address candidate, uint256 amount, string memory reason) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.sub(amount, reason);
    }

    function incrementRejectFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.add(amount);
    }

    function decrementRejectFor(address candidate, uint256 amount, string memory reason) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.sub(amount, reason);
    }

    function placeLock(address account, address candidate) internal {
        uint256 currentLock = _state.accounts[account].lockedUntil;
        uint256 newLock = startFor(candidate).add(periodFor(candidate));
        if (newLock > currentLock) {
            _state.accounts[account].lockedUntil = newLock;
        }
    }

    function initialized(address candidate) internal {
        _state.candidates[candidate].initialized = true;
    }
}

/*
    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/**
 * @title Require
 * @author dYdX
 *
 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()
 */


/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Comptroller is Setters {
    using SafeMath for uint256;

    bytes32 private constant FILE = "Comptroller";

    function mintToAccount(address account, uint256 amount) internal {
        dollar().mint(account, amount);        
        increaseDebt(amount);
        balanceCheck();
    }

    function mintInitXToAccount(address account, uint256 amount) internal {
        dollar().mint(account, amount);
    }

    function mintInitZToAccount(address account, uint256 amount) internal {
        share().mint(account, amount);
    }

    function burnFromAccount(address account, uint256 amount) internal {
        dollar().transferFrom(account, address(this), amount);
        dollar().burn(amount);
        decrementTotalDebt(amount, "Comptroller: not enough outstanding debt");

        balanceCheck();
    }

    function redeemToAccount(address account, uint256 amount) internal {
        dollar().transfer(account, amount);
        decrementTotalRedeemable(amount, "Comptroller: not enough redeemable balance");

        balanceCheck();
    }

    function burnRedeemable(uint256 amount) internal {
        dollar().burn(amount);
        decrementTotalRedeemable(amount, "Comptroller: not enough redeemable balance");

        balanceCheck();
    }

    function increaseDebt(uint256 amount) internal {
        incrementTotalDebt(amount);
        resetDebt(Constants.getDebtRatioCap());

        balanceCheck();
    }

    function decreaseDebt(uint256 amount) internal {
        decrementTotalDebt(amount, "Comptroller: not enough debt");

        balanceCheck();
    }

    function increaseSupply(uint256 newSupply) internal returns (uint256, uint256, uint256) {
        (uint256 newRedeemable, uint256 lessDebt, uint256 daoReward, uint256 poolReward) = (0, 0, 0, 0);

        // 1. True up redeemable pool
        uint256 totalRedeemable = totalRedeemable();
        uint256 totalCoupons = totalCoupons();
        if (totalRedeemable < totalCoupons) {

            // Get new redeemable coupons
            newRedeemable = totalCoupons.sub(totalRedeemable);
            // Pad with Pool's potential cut
            newRedeemable = newRedeemable.mul(100).div(SafeMath.sub(100, Constants.getDAORatio()).sub(Constants.getOraclePoolRatio()));
            // Cap at newSupply
            newRedeemable = newRedeemable > newSupply ? newSupply : newRedeemable;
            // Determine dao's final cut
            daoReward = newRedeemable.mul(Constants.getDAORatio()).div(100);
            // Determine Pool's final cut
            poolReward = newRedeemable.mul(Constants.getOraclePoolRatio()).div(100);
            // Determine Redeemable's final cut
            newRedeemable = newRedeemable.sub(daoReward).sub(poolReward);

            mintToDAO(daoReward);
            mintToPool(poolReward);
            mintToRedeemable(newRedeemable);
            
            newSupply = newSupply.sub(daoReward).sub(poolReward);
            newSupply = newSupply.sub(newRedeemable);
        }
        // 2. Eliminate debt
        uint256 totalDebt = totalDebt();
        if (newSupply > 0 && totalDebt > 0) {
            lessDebt = totalDebt > newSupply ? newSupply : totalDebt;
            decreaseDebt(lessDebt);

            newSupply = newSupply.sub(lessDebt);
        }

        // 3. Payout to bonded
        if (totalBonded() == 0) {
            newSupply = 0;
        }
        if (newSupply > 0) {
            mintToBonded(newSupply);
        }
        uint256 newReward = newSupply.add(daoReward).add(poolReward);
        return (newRedeemable, lessDebt, newReward);
    }

    function resetDebt(Decimal.D256 memory targetDebtRatio) internal {
        uint256 targetDebt = targetDebtRatio.mul(dollar().totalSupply()).asUint256();
        uint256 currentDebt = totalDebt();

        if (currentDebt > targetDebt) {
            uint256 lessDebt = currentDebt.sub(targetDebt);
            decreaseDebt(lessDebt);
        }
    }

    function balanceCheck() private {
        Require.that(
            dollar().balanceOf(address(this)) >= totalRedeemable().add(totalClaimable()),
            FILE,
            "Inconsistent balances"
        );
    }

    function mintToBonded(uint256 amount) private {
        Require.that(
            totalBonded() > 0,
            FILE,
            "Cant mint to empty pool"
        );

        uint256 daoAmount = amount.mul(Constants.getDAORatio()).div(100);
        uint256 poolAmount = amount.mul(Constants.getOraclePoolRatio()).div(100);
        uint256 treasuryAmount = amount.mul(Constants.getTreasuryRatio()).div(100);
        uint256 lockerAmount = amount > daoAmount.add(poolAmount).add(treasuryAmount) ? amount.sub(daoAmount).sub(poolAmount).sub(treasuryAmount) : 0;

        mintToDAO(daoAmount);
        mintToPool(poolAmount);
        mintToTreasury(treasuryAmount);
        mintToLocker(lockerAmount);

        balanceCheck();
    }

    function mintToDAO(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(address(this), amount);
        }
    }

    function mintToPool(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(pool(), amount);
        }
    }

    function mintToLocker(uint256 amount) private {
        if (amount >0) {
            dollar().mint(locker(), amount);
        }
    }

    function mintToTreasury(uint256 amount) private {
        if (amount >0) {
            dollar().mint(Constants.getTreasuryAddress(), amount);
        }
    }

    function mintToRedeemable(uint256 amount) private {
        dollar().mint(address(this), amount);
        incrementTotalRedeemable(amount);

        balanceCheck();
    }

    function updatePegPrice(uint256 price) external onlyPegRegulator {
        setPeg(price);
    }

    function increaseShareSupply(uint256 amount) internal {
        if (amount >0) {
            share().mint(staker(),amount);
        }
    }

    modifier onlyPegRegulator() {
        Require.that(
            msg.sender == Constants.getPegRegulator(),
            FILE,
            "Only regulator can update"
        );
        _;
    } 
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Market is Comptroller, Curve {
    using SafeMath for uint256;

    bytes32 private constant FILE = "Market";

    event CouponExpiration(uint256 indexed epoch, uint256 couponsExpired, uint256 lessRedeemable, uint256 lessDebt, uint256 newRewarded);
    event CouponPurchase(address indexed account, uint256 indexed epoch, uint256 dollarAmount, uint256 couponAmount);
    event CouponRedemption(address indexed account, uint256 indexed epoch, uint256 couponAmount);
    event CouponBurn(address indexed account, uint256 indexed epoch, uint256 couponAmount);
    event CouponTransfer(address indexed from, address indexed to, uint256 indexed epoch, uint256 value);
    event CouponApproval(address indexed owner, address indexed spender, uint256 value);

    function step() internal {
        // Expire prior coupons
        for (uint256 i = 0; i < expiringCoupons(epoch()); i++) {
            expireCouponsForEpoch(expiringCouponsAtIndex(epoch(), i));
        }

        // Record expiry for current epoch's coupons
        uint256 expirationEpoch = epoch().add(Constants.getCouponExpiration());
        initializeCouponsExpiration(epoch(), expirationEpoch);
    }

    function expireCouponsForEpoch(uint256 epoch) private {
        uint256 couponsForEpoch = outstandingCoupons(epoch);
        (uint256 lessRedeemable, uint256 lessDebt, uint256 newRewarded) = (0, 0, 0);

        eliminateOutstandingCoupons(epoch);

        uint256 totalRedeemable = totalRedeemable();
        uint256 totalCoupons = totalCoupons();
        if (totalRedeemable > totalCoupons) {
            lessRedeemable = totalRedeemable.sub(totalCoupons);
            burnRedeemable(lessRedeemable);
            (, lessDebt, newRewarded) = increaseSupply(lessRedeemable);
        }

        emit CouponExpiration(epoch, couponsForEpoch, lessRedeemable, lessDebt, newRewarded);
    }

    function couponPremium(uint256 amount) public view returns (uint256) {
        return calculateCouponPremium(dollar().totalSupply(), totalDebt(), amount);
    }

    function couponRedemptionPenalty(uint256 couponEpoch, uint256 couponAmount) public view returns (uint256) {
        uint timeIntoEpoch = block.timestamp % Constants.getEpochStrategy().period;
        uint couponAge = epoch() - couponEpoch;

        uint couponEpochDecay = Constants.getCouponRedemptionPenaltyDecay() * (Constants.getCouponExpiration() - couponAge) / Constants.getCouponExpiration();

        if(timeIntoEpoch > couponEpochDecay) {
            return 0;
        }

        Decimal.D256 memory couponEpochInitialPenalty = Constants.getInitialCouponRedemptionPenalty().div(Decimal.D256({value: Constants.getCouponExpiration() })).mul(Decimal.D256({value: Constants.getCouponExpiration() - couponAge}));

        Decimal.D256 memory couponEpochDecayedPenalty = couponEpochInitialPenalty.div(Decimal.D256({value: couponEpochDecay})).mul(Decimal.D256({value: couponEpochDecay - timeIntoEpoch}));

        return Decimal.D256({value: couponAmount}).mul(couponEpochDecayedPenalty).value;
    }

    function purchaseCoupons(uint256 dollarAmount) external returns (uint256) {
        Require.that(
            dollarAmount > 0,
            FILE,
            "Must purchase non-zero amount"
        );

        Require.that(
            totalDebt() >= dollarAmount,
            FILE,
            "Not enough debt"
        );

        uint256 epoch = epoch();
        uint256 couponAmount = dollarAmount.add(couponPremium(dollarAmount));
        burnFromAccount(msg.sender, dollarAmount);
        incrementBalanceOfCoupons(msg.sender, epoch, couponAmount);

        emit CouponPurchase(msg.sender, epoch, dollarAmount, couponAmount);

        return couponAmount;
    }

    function redeemCoupons(uint256 couponEpoch, uint256 couponAmount) external {
        require(epoch().sub(couponEpoch) >= 2, "Market: Too early to redeem");
        decrementBalanceOfCoupons(msg.sender, couponEpoch, couponAmount, "Market: Insufficient coupon balance");
        
        uint burnAmount = couponRedemptionPenalty(couponEpoch, couponAmount);
        uint256 redeemAmount = couponAmount - burnAmount;
        
        redeemToAccount(msg.sender, redeemAmount);

        if(burnAmount > 0){
            emit CouponBurn(msg.sender, couponEpoch, burnAmount);
        }

        emit CouponRedemption(msg.sender, couponEpoch, redeemAmount);
    }

    function redeemCouponsMin(uint256 couponEpoch, uint256 couponAmount, uint256 minOutput) external {
        require(epoch().sub(couponEpoch) >= 2, "Market: Too early to redeem");
        decrementBalanceOfCoupons(msg.sender, couponEpoch, couponAmount, "Market: Insufficient coupon balance");
        
        uint burnAmount = couponRedemptionPenalty(couponEpoch, couponAmount);
        uint256 redeemAmount = couponAmount - burnAmount;

        Require.that(
            redeemAmount >= minOutput,
            FILE,
            "Insufficient output amount"
        );
        
        redeemToAccount(msg.sender, redeemAmount);

        if(burnAmount > 0){
            emit CouponBurn(msg.sender, couponEpoch, burnAmount);
        }

        emit CouponRedemption(msg.sender, couponEpoch, redeemAmount);
    }

    function approveCoupons(address spender, uint256 amount) external {
        require(spender != address(0), "Market: Coupon approve to the zero address");

        updateAllowanceCoupons(msg.sender, spender, amount);

        emit CouponApproval(msg.sender, spender, amount);
    }

    function transferCoupons(address sender, address recipient, uint256 epoch, uint256 amount) external {
        require(sender != address(0), "Market: Coupon transfer from the zero address");
        require(recipient != address(0), "Market: Coupon transfer to the zero address");

        decrementBalanceOfCoupons(sender, epoch, amount, "Market: Insufficient coupon balance");
        incrementBalanceOfCoupons(recipient, epoch, amount);

        if (msg.sender != sender && allowanceCoupons(sender, msg.sender) != uint256(-1)) {
            decrementAllowanceCoupons(sender, msg.sender, amount, "Market: Insufficient coupon approval");
        }

        emit CouponTransfer(sender, recipient, epoch, amount);
    }
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Regulator is Comptroller {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event SupplyIncrease(uint256 indexed epoch, uint256 price, uint256 newRedeemable, uint256 lessDebt, uint256 newRewarded);
    event SupplyDecrease(uint256 indexed epoch, uint256 price, uint256 newDebt);
    event SupplyNeutral(uint256 indexed epoch);
    event ShareSupplyIncrease(uint256 indexed epoch, uint256 amount);

    function step() internal {
        Decimal.D256 memory price = oracleCapture();
        capturePeg(epoch());

        growShareSupply();
        if (price.greaterThan(currentPeg())) {
            growSupply(price);
            return;
        }

        if (price.lessThan(currentPeg())) {
            shrinkSupply(price);
            return;
        }

        emit SupplyNeutral(epoch());
    }

    function growShareSupply() private {
        uint256 newSupply = Constants.getShareSupplyPerEpoch();
            increaseShareSupply(newSupply);
        emit ShareSupplyIncrease(epoch(),newSupply);
        return;
    }

    function shrinkSupply(Decimal.D256 memory price) private {
        Decimal.D256 memory delta = limit((currentPeg().sub(price)).div(currentPeg()));
        uint256 newDebt = delta.mul(totalNet()).asUint256();
        increaseDebt(newDebt);

        emit SupplyDecrease(epoch(), price.value, newDebt);
        return;
    }

    function growSupply(Decimal.D256 memory price) private {
        uint256 totalRedeemable = totalRedeemable();
        uint256 totalCoupons = totalCoupons();

        Decimal.D256 memory delta = limit((price.sub(currentPeg())).div(currentPeg()));
        uint256 newSupply = delta.mul(totalNet()).asUint256();
        (uint256 newRedeemable, uint256 lessDebt, uint256 newRewarded) = increaseSupply(newSupply);
        emit SupplyIncrease(epoch(), price.value, newRedeemable, lessDebt, newRewarded);
    }

    function limit(Decimal.D256 memory delta) private returns (Decimal.D256 memory) {
        Decimal.D256 memory supplyChangeLimit = Constants.getSupplyChangeLimit();
        return delta.greaterThan(supplyChangeLimit) ? supplyChangeLimit : delta;
    }

    function oracleCapture() private returns (Decimal.D256 memory) {
        (Decimal.D256 memory price, bool valid) = oracle().capture();

        if (!valid) {
            return currentPeg();
        }

        return price;
    }

    function currentPeg() private view returns (Decimal.D256 memory) {
        return Decimal.D256({value:getCurrentPeg()});
    }
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Permission is Setters {

    bytes32 private constant FILE = "Permission";

    // Can modify account state
    modifier onlyFrozenOrFluid(address account) {
        Require.that(
            statusOf(account) != Account.Status.Locked,
            FILE,
            "Not frozen or fluid"
        );

        _;
    }

    // Can participate in balance-dependant activities
    modifier onlyFrozenOrLocked(address account) {
        Require.that(
            statusOf(account) != Account.Status.Fluid,
            FILE,
            "Not frozen or locked"
        );

        _;
    }

    modifier initializer() {
        Require.that(
            !isInitialized(implementation()),
            FILE,
            "Already initialized"
        );

        initialized(implementation());

        _;
    }
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Bonding is Setters, Permission {
    using SafeMath for uint256;

    bytes32 private constant FILE = "Bonding";

    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, uint256 value);
    event Claim(address indexed account, uint256 value);
    event Bond(address indexed account, uint256 start, uint256 value);
    event Unbond(address indexed account, uint256 start, uint256 value, uint256 newClaimable);

    function step() internal {
        Require.that(
            epochTime() > epoch(),
            FILE,
            "Still current epoch"
        );

        snapshotTotalBonded();
        snapshotCurrentPeg();
        incrementEpoch();
    }

    function deposit(uint256 value) external {
        share().transferFrom(msg.sender, address(this), value);
        incrementBalanceOfStaged(msg.sender, value);

        shareBalanceCheck();

        emit Deposit(msg.sender, value);
    }

    function withdraw(uint256 value) external onlyFrozenOrLocked(msg.sender) {
        share().transfer(msg.sender, value);
        decrementBalanceOfStaged(msg.sender, value, "Bonding: insufficient staged balance");

        shareBalanceCheck();

        emit Withdraw(msg.sender, value);
    }

    function claim(uint256 value) external onlyFrozenOrLocked(msg.sender) {
        dollar().transfer(msg.sender, value);
        decrementBalanceOfClaimable(msg.sender, value, "Bonding: insufficient claimable balance");

        shareBalanceCheck();

        emit Claim(msg.sender, value);
    }

    function bond(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);
        uint256 totalRewardedWithPhantom = totalRewarded().add(totalPhantom());
        uint256 newPhantom = totalBonded() == 0 ?
            totalRewarded() == 0 ? Constants.getInitialStakeMultiple().mul(value) : 0 :
            totalRewardedWithPhantom.mul(value).div(totalBonded());

        incrementBalanceOfBonded(msg.sender, value);
        incrementBalanceOfPhantom(msg.sender, newPhantom);
        decrementBalanceOfStaged(msg.sender, value, "Bonding: insufficient staged balance");

        shareBalanceCheck();

        emit Bond(msg.sender, epoch().add(1), value);
    }

    function unbond(uint256 value) external {
        unfreeze(msg.sender);

        uint256 balanceOfBonded = balanceOfBonded(msg.sender);
        Require.that(
            balanceOfBonded > 0,
            FILE,
            "insufficient bonded balance"
        );

        uint256 newClaimable = balanceOfRewarded(msg.sender).mul(value).div(balanceOfBonded);
        uint256 lessPhantom = balanceOfPhantom(msg.sender).mul(value).div(balanceOfBonded);

        incrementBalanceOfStaged(msg.sender, value);
        incrementBalanceOfClaimable(msg.sender, newClaimable);
        decrementBalanceOfBonded(msg.sender, value, "Bonding: insufficient bonded balance");
        decrementBalanceOfPhantom(msg.sender, lessPhantom, "Bonding: insufficient phantom balance");

        shareBalanceCheck();

        emit Unbond(msg.sender, epoch().add(1), value, newClaimable);
    }

    function shareBalanceCheck() private {
        Require.that(
            share().balanceOf(address(this)) >= totalBonded().add(totalStaged()),
            FILE,
            "Inconsistent Dollar balances"
        );
    }
}

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */


/*
    Copyright 2018-2019 zOS Global Limited
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/**
 * Based off of, and designed to interface with, openzeppelin/upgrades package
 */
contract Upgradeable is State {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     * @param implementation Address of the new implementation.
     */
    event Upgraded(address indexed implementation);

    function initialize() public;

    /**
     * @dev Upgrades the proxy to a new implementation.
     * @param newImplementation Address of the new implementation.
     */
    function upgradeTo(address newImplementation) internal {
        setImplementation(newImplementation);

        (bool success, bytes memory reason) = newImplementation.delegatecall(abi.encodeWithSignature("initialize()"));
        require(success, string(reason));

        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation address of the proxy.
     * @param newImplementation Address of the new implementation.
     */
    function setImplementation(address newImplementation) private {
        require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Govern is Setters, Permission, Upgradeable {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    bytes32 private constant FILE = "Govern";

    event Proposal(address indexed candidate, address indexed account, uint256 indexed start, uint256 period);
    event Vote(address indexed account, address indexed candidate, Candidate.Vote vote, uint256 bonded);
    event Commit(address indexed account, address indexed candidate);

    function vote(address candidate, Candidate.Vote vote) external onlyFrozenOrLocked(msg.sender) {
        Require.that(
            balanceOfBonded(msg.sender) > 0,
            FILE,
            "Must have stake"
        );

        if (!isNominated(candidate)) {
            Require.that(
                canPropose(msg.sender),
                FILE,
                "Not enough stake to propose"
            );

            createCandidate(candidate, Constants.getGovernancePeriod());
            emit Proposal(candidate, msg.sender, epoch(), Constants.getGovernancePeriod());
        }

        Require.that(
            epoch() < startFor(candidate).add(periodFor(candidate)),
            FILE,
            "Ended"
        );

        uint256 bonded = balanceOfBonded(msg.sender);
        Candidate.Vote recordedVote = recordedVote(msg.sender, candidate);
        if (vote == recordedVote) {
            return;
        }

        if (recordedVote == Candidate.Vote.REJECT) {
            decrementRejectFor(candidate, bonded, "Govern: Insufficient reject");
        }
        if (recordedVote == Candidate.Vote.APPROVE) {
            decrementApproveFor(candidate, bonded, "Govern: Insufficient approve");
        }
        if (vote == Candidate.Vote.REJECT) {
            incrementRejectFor(candidate, bonded);
        }
        if (vote == Candidate.Vote.APPROVE) {
            incrementApproveFor(candidate, bonded);
        }

        recordVote(msg.sender, candidate, vote);
        placeLock(msg.sender, candidate);

        emit Vote(msg.sender, candidate, vote, bonded);
    }

    function commit(address candidate) external {
        Require.that(
            isNominated(candidate),
            FILE,
            "Not nominated"
        );

        uint256 endsAfter = startFor(candidate).add(periodFor(candidate)).sub(1);

        Require.that(
            epoch() > endsAfter,
            FILE,
            "Not ended"
        );

        Require.that(
            Decimal.ratio(votesFor(candidate), totalBondedAt(endsAfter)).greaterThan(Constants.getGovernanceQuorum()),
            FILE,
            "Must have quorom"
        );

        Require.that(
            approveFor(candidate) > rejectFor(candidate),
            FILE,
            "Not approved"
        );

        upgradeTo(candidate);

        emit Commit(msg.sender, candidate);
    }

    function emergencyCommit(address candidate) external {
        Require.that(
            isNominated(candidate),
            FILE,
            "Not nominated"
        );

        Require.that(
            epochTime() > epoch().add(Constants.getGovernanceEmergencyDelay()),
            FILE,
            "Epoch synced"
        );

        Require.that(
            Decimal.ratio(approveFor(candidate), totalBonded()).greaterThan(Constants.getGovernanceSuperMajority()),
            FILE,
            "Must have super majority"
        );

        Require.that(
            approveFor(candidate) > rejectFor(candidate),
            FILE,
            "Not approved"
        );

        upgradeTo(candidate);

        emit Commit(msg.sender, candidate);
    }

    function canPropose(address account) private view returns (bool) {
        if (totalBonded() == 0) {
            return false;
        }

        Decimal.D256 memory stake = Decimal.ratio(balanceOfBonded(account), totalBonded());
        return stake.greaterThan(Constants.getGovernanceProposalThreshold());
    }
}

/*
    Copyright 2020 Apollo Dev, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract Implementation is State, Bonding, Market, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() initializer public {
        // intital distribution:
        mintInitXToAccount(0x9518Ef6b3320725d60f63e0eF775551d16f68c2c, 900000e18); // 900k AOX to address
        mintInitZToAccount(0x9518Ef6b3320725d60f63e0eF775551d16f68c2c, 900000e18); // 900k AOZ to address
    }

    function advance() external incentivized {
        Bonding.step();
        Regulator.step();
        Market.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    modifier incentivized {
        // Mint advance reward to sender
        uint256 incentive = Constants.getAdvanceIncentive();
        mintToAccount(msg.sender, incentive);
        emit Incentivization(msg.sender, incentive);
        _;
    }
}