/**
 *Submitted for verification at Etherscan.io on 2021-04-01
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




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    Copyright 2019 dYdX Trading Inc.
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    function pair() external view returns (address);
}

/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    enum Status { Frozen, Fluid, Locked }

    struct State {
        uint256 staged;
        uint256 balance;
        mapping(uint256 => uint256) coupons;
        mapping(address => uint256) couponAllowances;
        uint256 fluidUntil;
        uint256 lockedUntil;
    }

    struct State10 {
        uint256 depositedCDSD;
        uint256 interestMultiplierEntry;
        uint256 earnableCDSD;
        uint256 earnedCDSD;
        uint256 redeemedCDSD;
        uint256 redeemedThisExpansion;
        uint256 lastRedeemedExpansionStart;
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
        Coupons coupons;
    }
}

contract Candidate {
    enum Vote { UNDECIDED, APPROVE, REJECT }

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
        IOracle oracle;
        address pool;
    }

    struct Balance {
        uint256 supply;
        uint256 bonded;
        uint256 staged;
        uint256 redeemable;
        uint256 debt;
        uint256 coupons;
    }

    struct State {
        Epoch.Global epoch;
        Balance balance;
        Provider provider;
        mapping(address => Account.State) accounts;
        mapping(uint256 => Epoch.State) epochs;
        mapping(address => Candidate.State) candidates;
    }

    struct State13 {
        mapping(address => mapping(uint256 => uint256)) couponUnderlyingByAccount;
        uint256 couponUnderlying;
        Decimal.D256 price;
    }
    
    struct State16 {
        IOracle legacyOracle;
        uint256 epochStartForSushiswapPool;
    }

    struct State10 {
        mapping(address => Account.State10) accounts;
        
        uint256 globalInterestMultiplier;

        uint256 totalCDSDDeposited;
        uint256 totalCDSDEarnable;
        uint256 totalCDSDEarned;

        uint256 expansionStartEpoch;
        uint256 totalCDSDRedeemable;
        uint256 totalCDSDRedeemed;
    }
}

contract State {
    Storage.State _state;

    // DIP-13
    Storage.State13 _state13;

    // DIP-16
    Storage.State16 _state16;
    
    // DIP-10
    Storage.State10 _state10;
}

/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
     * ERC20 Interface
     */

    function name() public view returns (string memory) {
        return "Dynamic Set Dollar Stake";
    }

    function symbol() public view returns (string memory) {
        return "DSDS";
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _state.accounts[account].balance;
    }

    function totalSupply() public view returns (uint256) {
        return _state.balance.supply;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return 0;
    }

    /**
     * Global
     */

    function dollar() public view returns (IDollar) {
        return _state.provider.dollar;
    }

    function oracle() public view returns (IOracle) {
        if (epoch() < _state16.epochStartForSushiswapPool) {
            return _state16.legacyOracle;
        } else {
            return _state.provider.oracle;
        }
    }

    function pool() public view returns (address) {
        return Constants.getPoolAddress();
    }

    function cpool() public view returns (address) {
        return Constants.getContractionPoolAddress();
    }

    function totalBonded() public view returns (uint256) {
        return _state.balance.bonded;
    }

    function totalStaged() public view returns (uint256) {
        return _state.balance.staged;
    }

    function totalDebt() public view returns (uint256) {
        return _state.balance.debt;
    }

    function totalRedeemable() public view returns (uint256) {
        return _state.balance.redeemable;
    }

    function totalCouponUnderlying() public view returns (uint256) {
        return _state13.couponUnderlying;
    }

    function totalCoupons() public view returns (uint256) {
        return _state.balance.coupons;
    }

    function treasury() public view returns (address) {
        return Constants.getTreasuryAddress();
    }

    // DIP-10
    function totalCDSDBonded() public view returns (uint256) {
        return cdsd().balanceOf(address(this));
    }

    function globalInterestMultiplier() public view returns (uint256) {
        return _state10.globalInterestMultiplier;
    }

    function expansionStartEpoch() public view returns (uint256) {
        return _state10.expansionStartEpoch;
    }

    function totalCDSD() public view returns (uint256) {
        return cdsd().totalSupply();
    }

    function cdsd() public view returns (IDollar) {
        return IDollar(Constants.getContractionDollarAddress());
    }

    // end DIP-10

    function getPrice() public view returns (Decimal.D256 memory price) {
        return _state13.price;
    }

    /**
     * Account
     */

    function balanceOfStaged(address account) public view returns (uint256) {
        return _state.accounts[account].staged;
    }

    function balanceOfBonded(address account) public view returns (uint256) {
        uint256 totalSupplyAmount = totalSupply();
        if (totalSupplyAmount == 0) {
            return 0;
        }
        return totalBonded().mul(balanceOf(account)).div(totalSupplyAmount);
    }

    function balanceOfCoupons(address account, uint256 epoch) public view returns (uint256) {
        return _state.accounts[account].coupons[epoch];
    }

    function balanceOfCouponUnderlying(address account, uint256 epoch) public view returns (uint256) {
        return _state13.couponUnderlyingByAccount[account][epoch];
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

    // DIP-10
    function balanceOfCDSDBonded(address account) public view returns (uint256) {
        uint256 amount = depositedCDSDByAccount(account).mul(_state10.globalInterestMultiplier).div(intrestMultiplierEntryByAccount(account));

        uint256 cappedAmount = cDSDBondedCap(account);

        return amount > cappedAmount ? cappedAmount : amount;
    }

    function cDSDBondedCap(address account) public view returns (uint256) {
        return depositedCDSDByAccount(account).add(earnableCDSDByAccount(account)).sub(earnedCDSDByAccount(account));
    }

    function depositedCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].depositedCDSD;
    }

    function intrestMultiplierEntryByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].interestMultiplierEntry;
    }

    function earnableCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].earnableCDSD;
    }

    function earnedCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].earnedCDSD;
    }

    function redeemedCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].redeemedCDSD;
    }

    function getRedeemedThisExpansion(address account) public view returns (uint256) {
        uint256 currentExpansion = _state10.expansionStartEpoch;
        uint256 accountExpansion = _state10.accounts[account].lastRedeemedExpansionStart;

        if (currentExpansion != accountExpansion) {
            return 0;
        }else{
            return _state10.accounts[account].redeemedThisExpansion;
        }
    }

    function getCurrentRedeemableCDSDByAccount(address account) public view returns (uint256) {
        return totalCDSDRedeemable()
            .mul(balanceOfCDSDBonded(account))
            .div(totalCDSDBonded())
            .sub(getRedeemedThisExpansion(account));
    }


    function totalCDSDDeposited() public view returns (uint256) {
        return _state10.totalCDSDDeposited;
    }

    function totalCDSDEarnable() public view returns (uint256) {
        return _state10.totalCDSDEarnable;
    }

    function totalCDSDEarned() public view returns (uint256) {
        return _state10.totalCDSDEarned;
    }

    function totalCDSDRedeemed() public view returns (uint256) {
        return _state10.totalCDSDRedeemed;
    }

    function totalCDSDRedeemable() public view returns (uint256) {
        return _state10.totalCDSDRedeemable;
    }


    function maxCDSDOutstanding() public view returns (uint256) {
        return totalCDSDDeposited()
            .add(totalCDSDEarnable())
            .sub(totalCDSDEarned());
    }

    // end DIP-10

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
        return blockTimestamp().sub(strategy.start).div(strategy.period).add(strategy.offset);
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

    function bootstrappingAt(uint256 epoch) public view returns (bool) {
        return epoch <= Constants.getBootstrappingPeriod();
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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * ERC20 Interface
     */

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return false;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        return false;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        return false;
    }

    /**
     * Global
     */

    function incrementTotalBonded(uint256 amount) internal {
        _state.balance.bonded = _state.balance.bonded.add(amount);
    }

    function decrementTotalBonded(uint256 amount, string memory reason) internal {
        _state.balance.bonded = _state.balance.bonded.sub(amount, reason);
    }

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

    // DIP-10

    function setGlobalInterestMultiplier(uint256 multiplier) internal {
        _state10.globalInterestMultiplier = multiplier;
    }

    function setExpansionStartEpoch(uint256 epoch) internal {
        _state10.expansionStartEpoch = epoch;
    }

    function incrementTotalCDSDRedeemable(uint256 amount) internal {
        _state10.totalCDSDRedeemable = _state10.totalCDSDRedeemable.add(amount);
    }

    function decrementTotalCDSDRedeemable(uint256 amount, string memory reason) internal {
        _state10.totalCDSDRedeemable = _state10.totalCDSDRedeemable.sub(amount, reason);
    }

    function incrementTotalCDSDRedeemed(uint256 amount) internal {
        _state10.totalCDSDRedeemed = _state10.totalCDSDRedeemed.add(amount);
    }

    function decrementTotalCDSDRedeemed(uint256 amount, string memory reason) internal {
        _state10.totalCDSDRedeemed = _state10.totalCDSDRedeemed.sub(amount, reason);
    }

    function clearCDSDRedeemable() internal {
        _state10.totalCDSDRedeemable = 0;
        _state10.totalCDSDRedeemed = 0;
    }

    function incrementTotalCDSDDeposited(uint256 amount) internal {
        _state10.totalCDSDDeposited = _state10.totalCDSDDeposited.add(amount);
    }

    function decrementTotalCDSDDeposited(uint256 amount, string memory reason) internal {
        _state10.totalCDSDDeposited = _state10.totalCDSDDeposited.sub(amount, reason);
    }

    function incrementTotalCDSDEarnable(uint256 amount) internal {
        _state10.totalCDSDEarnable = _state10.totalCDSDEarnable.add(amount);
    }

    function decrementTotalCDSDEarnable(uint256 amount, string memory reason) internal {
        _state10.totalCDSDEarnable = _state10.totalCDSDEarnable.sub(amount, reason);
    }

    function incrementTotalCDSDEarned(uint256 amount) internal {
        _state10.totalCDSDEarned = _state10.totalCDSDEarned.add(amount);
    }

    function decrementTotalCDSDEarned(uint256 amount, string memory reason) internal {
        _state10.totalCDSDEarned = _state10.totalCDSDEarned.sub(amount, reason);
    }

    // end DIP-10

    /**
     * Account
     */

    function incrementBalanceOf(address account, uint256 amount) internal {
        _state.accounts[account].balance = _state.accounts[account].balance.add(amount);
        _state.balance.supply = _state.balance.supply.add(amount);

        emit Transfer(address(0), account, amount);
    }

    function decrementBalanceOf(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].balance = _state.accounts[account].balance.sub(amount, reason);
        _state.balance.supply = _state.balance.supply.sub(amount, reason);

        emit Transfer(account, address(0), amount);
    }

    function incrementBalanceOfStaged(address account, uint256 amount) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.add(amount);
        _state.balance.staged = _state.balance.staged.add(amount);
    }

    function decrementBalanceOfStaged(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.sub(amount, reason);
        _state.balance.staged = _state.balance.staged.sub(amount, reason);
    }

    function incrementBalanceOfCoupons(
        address account,
        uint256 epoch,
        uint256 amount
    ) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].add(amount);
        _state.epochs[epoch].coupons.outstanding = _state.epochs[epoch].coupons.outstanding.add(amount);
        _state.balance.coupons = _state.balance.coupons.add(amount);
    }

    function incrementBalanceOfCouponUnderlying(
        address account,
        uint256 epoch,
        uint256 amount
    ) internal {
        _state13.couponUnderlyingByAccount[account][epoch] = _state13.couponUnderlyingByAccount[account][epoch].add(
            amount
        );
        _state13.couponUnderlying = _state13.couponUnderlying.add(amount);
    }

    function decrementBalanceOfCoupons(
        address account,
        uint256 epoch,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].sub(amount, reason);
        _state.epochs[epoch].coupons.outstanding = _state.epochs[epoch].coupons.outstanding.sub(amount, reason);
        _state.balance.coupons = _state.balance.coupons.sub(amount, reason);
    }

    function decrementBalanceOfCouponUnderlying(
        address account,
        uint256 epoch,
        uint256 amount,
        string memory reason
    ) internal {
        _state13.couponUnderlyingByAccount[account][epoch] = _state13.couponUnderlyingByAccount[account][epoch].sub(
            amount,
            reason
        );
        _state13.couponUnderlying = _state13.couponUnderlying.sub(amount, reason);
    }

    function unfreeze(address account) internal {
        _state.accounts[account].fluidUntil = epoch().add(Constants.getDAOExitLockupEpochs());
    }

    function updateAllowanceCoupons(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _state.accounts[owner].couponAllowances[spender] = amount;
    }

    function decrementAllowanceCoupons(
        address owner,
        address spender,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[owner].couponAllowances[spender] = _state.accounts[owner].couponAllowances[spender].sub(
            amount,
            reason
        );
    }

    // DIP-10
    function incrementBalanceOfDepositedCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].depositedCDSD = _state10.accounts[account].depositedCDSD.add(amount);
    }

    function decrementBalanceOfDepositedCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].depositedCDSD = _state10.accounts[account].depositedCDSD.sub(amount, reason);
    }
    
    function incrementBalanceOfEarnableCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].earnableCDSD = _state10.accounts[account].earnableCDSD.add(amount);
    }

    function decrementBalanceOfEarnableCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].earnableCDSD = _state10.accounts[account].earnableCDSD.sub(amount, reason);
    }
    
    function incrementBalanceOfEarnedCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].earnedCDSD = _state10.accounts[account].earnedCDSD.add(amount);
    }

    function decrementBalanceOfEarnedCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].earnedCDSD = _state10.accounts[account].earnedCDSD.sub(amount, reason);
    }

    function incrementBalanceOfRedeemedCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].redeemedCDSD = _state10.accounts[account].redeemedCDSD.add(amount);
    }

    function decrementBalanceOfRedeemedCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].redeemedCDSD = _state10.accounts[account].redeemedCDSD.sub(amount, reason);
    }
    
    function addRedeemedThisExpansion(address account, uint256 amount) public returns (uint256) {
        uint256 currentExpansion = _state10.expansionStartEpoch;
        uint256 accountExpansion = _state10.accounts[account].lastRedeemedExpansionStart;

        if (currentExpansion != accountExpansion) {
            _state10.accounts[account].redeemedThisExpansion = amount;
            _state10.accounts[account].lastRedeemedExpansionStart = currentExpansion;
        }else{
            _state10.accounts[account].redeemedThisExpansion = _state10.accounts[account].redeemedThisExpansion.add(amount);
        }
    }

    function setCurrentInterestMultiplier(address account) public returns (uint256) {
        _state10.accounts[account].interestMultiplierEntry = _state10.globalInterestMultiplier;
    }

    function setDepositedCDSDAmount(address account, uint256 amount) public returns (uint256) {
        _state10.accounts[account].depositedCDSD = amount;
    }


    // end DIP-10

    /**
     * Epoch
     */

    function incrementEpoch() internal {
        _state.epoch.current = _state.epoch.current.add(1);
    }

    function snapshotTotalBonded() internal {
        _state.epochs[epoch()].bonded = totalSupply();
    }

    function initializeCouponsExpiration(uint256 epoch, uint256 expiration) internal {
        _state.epochs[epoch].coupons.expiration = expiration;
        _state.epochs[expiration].coupons.expiring.push(epoch);
    }

    function eliminateOutstandingCoupons(uint256 epoch) internal {
        uint256 outstandingCouponsForEpoch = outstandingCoupons(epoch);
        if (outstandingCouponsForEpoch == 0) {
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

    function recordVote(
        address account,
        address candidate,
        Candidate.Vote vote
    ) internal {
        _state.candidates[candidate].votes[account] = vote;
    }

    function incrementApproveFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.add(amount);
    }

    function decrementApproveFor(
        address candidate,
        uint256 amount,
        string memory reason
    ) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.sub(amount, reason);
    }

    function incrementRejectFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.add(amount);
    }

    function decrementRejectFor(
        address candidate,
        uint256 amount,
        string memory reason
    ) internal {
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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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

    function setPrice(Decimal.D256 memory price) internal {
        _state13.price = price;

        // track expansion cycles
        if (price.greaterThan(Decimal.one())) {
            if(_state10.expansionStartEpoch == 0){
                _state10.expansionStartEpoch = epoch();
            }
        } else {
            _state10.expansionStartEpoch = 0;
        }
    }

    function mintToAccount(address account, uint256 amount) internal {
        dollar().mint(account, amount);

        balanceCheck();
    }

    function burnFromAccount(address account, uint256 amount) internal {
        dollar().transferFrom(account, address(this), amount);
        dollar().burn(amount);

        balanceCheck();
    }

    function burnRedeemable(uint256 amount) internal {
        dollar().burn(amount);
        decrementTotalRedeemable(amount, "Comptroller: not enough redeemable balance");

        balanceCheck();
    }

    function contractionIncentives(Decimal.D256 memory price) internal returns (uint256) {
        // clear outstanding redeemables
        uint256 redeemable = totalCDSDRedeemable();
        if (redeemable != 0) {
            clearCDSDRedeemable();
        }

        // acrue interest on CDSD
        uint256 currentMultiplier = globalInterestMultiplier();
        Decimal.D256 memory interest = Constants.maxCDSDBondingRewards();
        if (price.greaterThan(Constants.maxCDSDRewardsThreshold())) {
            Decimal.D256 memory maxDelta = Decimal.one().sub(Constants.maxCDSDRewardsThreshold());
            interest = interest
                .mul(
                    maxDelta.sub(price.sub(Constants.maxCDSDRewardsThreshold()))
                )
                .div(maxDelta);
        }
        uint256 newMultiplier = Decimal.D256({value:currentMultiplier}).mul(Decimal.one().add(interest)).value;
        setGlobalInterestMultiplier(newMultiplier);

        // payout CPool rewards
        Decimal.D256 memory cPoolReward = Decimal.D256({value:cdsd().totalSupply()})
            .mul(Constants.getContractionPoolTargetSupply())
            .mul(Constants.getContractionPoolTargetReward());
        cdsd().mint(Constants.getContractionPoolAddress(), cPoolReward.value);

        // DSD bonded in the DAO receives a fixed APY
        uint256 daoBondingRewards;
        if (totalBonded() != 0) {
            daoBondingRewards = Decimal.D256(totalBonded()).mul(Constants.getContractionBondingRewards()).value;
            mintToDAO(daoBondingRewards);
        }

        balanceCheck();

        return daoBondingRewards;
    }

    function increaseSupply(uint256 newSupply) internal returns (uint256, uint256) {
        // 0-a. Pay out to Pool
        uint256 poolReward = newSupply.mul(Constants.getOraclePoolRatio()).div(100);
        mintToPool(poolReward);

        // 0-b. Pay out to Treasury
        uint256 treasuryReward = newSupply.mul(Constants.getTreasuryRatio()).div(100);
        mintToTreasury(treasuryReward);

        // cDSD redemption logic
        uint256 newCDSDRedeemable = 0;
        uint256 outstanding = maxCDSDOutstanding();
        uint256 redeemable = totalCDSDRedeemable().sub(totalCDSDRedeemed());
        if (redeemable < outstanding ) {
            uint256 newRedeemable = newSupply.mul(Constants.getCDSDRedemptionRatio()).div(100);
            uint256 newRedeemableCap = outstanding.sub(redeemable);

            newCDSDRedeemable = newRedeemableCap > newRedeemable ? newRedeemableCap : newRedeemable;

            incrementTotalCDSDRedeemable(newCDSDRedeemable);
        }

        // remaining is for DAO
        uint256 rewards = poolReward.add(treasuryReward).add(newCDSDRedeemable);
        uint256 amount = newSupply > rewards ? newSupply.sub(rewards) : 0;

        // 2. Payout to DAO
        if (totalBonded() == 0) {
            amount = 0;
        }
        if (amount > 0) {
            mintToDAO(amount);
        }

        balanceCheck();

        return (newCDSDRedeemable, amount.add(rewards));
    }

    function balanceCheck() internal view {
        Require.that(
            dollar().balanceOf(address(this)) >= totalBonded().add(totalStaged()).add(totalRedeemable()),
            FILE,
            "Inconsistent balances"
        );
    }

    function mintToDAO(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(address(this), amount);
            incrementTotalBonded(amount);
        }
    }

    function mintToTreasury(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(Constants.getTreasuryAddress(), amount);
        }
    }

    function mintToPool(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(pool(), amount);
        }
    }
}

/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
contract CDSDMarket is Comptroller {
    using SafeMath for uint256;

    event CDSDMinted(address indexed account, uint256 amount);
    event CDSDRedeemed(address indexed account, uint256 amount);
    event BondCDSD(address indexed account, uint256 start, uint256 amount);
    event UnbondCDSD(address indexed account, uint256 start, uint256 amount);

    function burnDSDForCDSD(uint256 amount) public {
        require(_state13.price.lessThan(Decimal.one()), "Market: not in contraction");

        // deposit and burn DSD
        dollar().transferFrom(msg.sender, address(this), amount);
        dollar().burn(amount);
        balanceCheck();

        // mint equivalent CDSD
        cdsd().mint(msg.sender, amount);

        // increment earnable
        uint256 earnable = Decimal.D256({value: amount}).mul(Constants.getEarnableFactor()).value;
        incrementBalanceOfEarnableCDSD(msg.sender,  earnable);
        incrementTotalCDSDEarnable(earnable);

        emit CDSDMinted(msg.sender, amount);
    }

    function migrateCouponsToCDSD(uint256 couponEpoch) public returns (uint256) {
        uint256 couponAmount = balanceOfCoupons(msg.sender, couponEpoch);
        uint256 couponUnderlyingAmount = balanceOfCouponUnderlying(msg.sender, couponEpoch);

        // decrement coupon & underlying balances
        if (couponAmount != 0) {
            decrementBalanceOfCoupons(msg.sender, couponEpoch, couponAmount, "Market: Insufficient coupon balance");
        }
        if (couponUnderlyingAmount != 0){
            decrementBalanceOfCouponUnderlying(msg.sender, couponEpoch, couponUnderlyingAmount, "Market: Insufficient coupon underlying balance");
        }

        // mint CDSD
        uint256 totalAmount = couponAmount.add(couponUnderlyingAmount);
        cdsd().mint(msg.sender, totalAmount);

        emit CDSDMinted(msg.sender, totalAmount);

        return totalAmount;
    }

    function burnDSDForCDSDAndBond(uint256 amount) external {
        burnDSDForCDSD(amount);

        bondCDSD(amount);
    }

    function migrateCouponsToCDSDAndBond(uint256 couponEpoch) external {
        uint256 amountToBond = migrateCouponsToCDSD(couponEpoch);

        bondCDSD(amountToBond);
    }

    function bondCDSD(uint256 amount) public {
        require(amount > 0, "Market: bound must be greater than 0");

        // update earned amount
        (uint256 userBonded, uint256 userDeposited,) = updateUserEarned(msg.sender);

        // deposit CDSD amount
        cdsd().transferFrom(msg.sender, address(this), amount);

        uint256 totalAmount = userBonded.add(amount);
        setDepositedCDSDAmount(msg.sender, totalAmount);

        decrementTotalCDSDDeposited(userDeposited, "Market: insufficient total deposited");
        incrementTotalCDSDDeposited(totalAmount);

        emit BondCDSD(msg.sender, epoch().add(1), amount);
    }

    function unbondCDSD(uint256 amount) external {
        // we cannot allow for CDSD unbonds during expansions, to enforce the pro-rata redemptions
        require(_state13.price.lessThan(Decimal.one()), "Market: not in contraction");

        _unbondCDSD(amount);

        // withdraw CDSD
        cdsd().transfer(msg.sender, amount);

        emit UnbondCDSD(msg.sender, epoch().add(1), amount);
    }

    function _unbondCDSD(uint256 amount) internal {
        // update earned amount
        (uint256 userBonded, uint256 userDeposited,) = updateUserEarned(msg.sender);

        require(amount > 0 && userBonded > 0, "Market: amounts > 0!");
        require(amount <= userBonded, "Market: insufficient amount to unbound");

        // update deposited amount
        uint256 userTotalAmount = userBonded.sub(amount);
        setDepositedCDSDAmount(msg.sender, userTotalAmount);

        decrementTotalCDSDDeposited(userDeposited, "Market: insufficient deposited");
        incrementTotalCDSDDeposited(userTotalAmount);
    }

    function redeemBondedCDSDForDSD(uint256 amount) external {
        require(_state13.price.greaterThan(Decimal.one()), "Market: not in expansion");
        require(amount > 0, "Market: amounts > 0!");

        // check if user is allowed to redeem this amount
        require(amount <= getCurrentRedeemableCDSDByAccount(msg.sender), "Market: not enough redeemable");

        // unbond redeemed amount
        _unbondCDSD(amount);

        // burn CDSD
        cdsd().burn(amount);
        // mint DSD
        mintToAccount(msg.sender, amount);

        addRedeemedThisExpansion(msg.sender, amount);
        incrementTotalCDSDRedeemed(amount);

        emit CDSDRedeemed(msg.sender, amount);
    }

    function updateUserEarned(address account) internal returns (uint256 userBonded, uint256 userDeposited, uint256 userEarned) {
        userBonded = balanceOfCDSDBonded(account);
        userDeposited = depositedCDSDByAccount(account);
        userEarned = userBonded.sub(userDeposited);
        
        if (userEarned > 0) {
            incrementBalanceOfEarnedCDSD(account, userEarned);
            // mint acrued interest interest to DAO
            cdsd().mint(address(this), userEarned);
            incrementTotalCDSDEarned(userEarned);
        }

        // update multiplier entry
        setCurrentInterestMultiplier(account);
    }
}

/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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

    event SupplyIncrease(uint256 indexed epoch, uint256 price, uint256 newRedeemable, uint256 newBonded);
    event ContractionIncentives(uint256 indexed epoch, uint256 price, uint256 delta);
    event SupplyNeutral(uint256 indexed epoch);

    function step() internal {
        Decimal.D256 memory price = oracleCapture();

        setPrice(price);

        if (price.greaterThan(Decimal.one())) {
            expansion(price);
            return;
        }

        if (price.lessThan(Decimal.one())) {
            contraction(price);
            return;
        }

        emit SupplyNeutral(epoch());
    }

    function expansion(Decimal.D256 memory price) private {
        Decimal.D256 memory delta = 
            limit(price.sub(Decimal.one()).div(Constants.getSupplyChangeDivisor()), price);
            
        uint256 newSupply = delta.mul(dollar().totalSupply()).asUint256();
        (uint256 newRedeemable, uint256 newBonded) = increaseSupply(newSupply);

        emit SupplyIncrease(epoch(), price.value, newRedeemable, newBonded);
    }

    function contraction(Decimal.D256 memory price) private {
        (uint256 newDSDSupply) = contractionIncentives(price);

        emit ContractionIncentives(epoch(), price.value, newDSDSupply);
    }

    function limit(Decimal.D256 memory delta, Decimal.D256 memory price) private view returns (Decimal.D256 memory) {
        Decimal.D256 memory supplyChangeLimit = Constants.getSupplyChangeLimit();

        return delta.greaterThan(supplyChangeLimit) ? supplyChangeLimit : delta;
    }

    function oracleCapture() private returns (Decimal.D256 memory) {
        (Decimal.D256 memory price, bool valid) = oracle().capture();

        if (bootstrappingAt(epoch().sub(1))) {
            return Constants.getBootstrappingPrice();
        }
        if (!valid) {
            return Decimal.one();
        }

        return price;
    }
}

/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    event Bond(address indexed account, uint256 start, uint256 value, uint256 valueUnderlying);
    event Unbond(address indexed account, uint256 start, uint256 value, uint256 valueUnderlying);

    function step() internal {
        Require.that(
            epochTime() > epoch(),
            FILE,
            "Still current epoch"
        );

        snapshotTotalBonded();
        incrementEpoch();
    }

    function deposit(uint256 value) external {
        dollar().transferFrom(msg.sender, address(this), value);
        incrementBalanceOfStaged(msg.sender, value);

        emit Deposit(msg.sender, value);
    }

    function withdraw(uint256 value) external onlyFrozenOrLocked(msg.sender) {
        dollar().transfer(msg.sender, value);
        decrementBalanceOfStaged(msg.sender, value, "Bonding: insufficient staged balance");

        emit Withdraw(msg.sender, value);
    }

    function bond(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);

        uint256 balance = totalBonded() == 0 ?
            value.mul(Constants.getInitialStakeMultiple()) :
            value.mul(totalSupply()).div(totalBonded());
        incrementBalanceOf(msg.sender, balance);
        incrementTotalBonded(value);
        decrementBalanceOfStaged(msg.sender, value, "Bonding: insufficient staged balance");

        emit Bond(msg.sender, epoch().add(1), balance, value);
    }

    function unbond(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);

        uint256 staged = value.mul(balanceOfBonded(msg.sender)).div(balanceOf(msg.sender));
        incrementBalanceOfStaged(msg.sender, staged);
        decrementTotalBonded(staged, "Bonding: insufficient total bonded");
        decrementBalanceOf(msg.sender, value, "Bonding: insufficient balance");

        emit Unbond(msg.sender, epoch().add(1), value, staged);
    }

    function unbondUnderlying(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);

        uint256 balance = value.mul(totalSupply()).div(totalBonded());
        incrementBalanceOfStaged(msg.sender, value);
        decrementTotalBonded(value, "Bonding: insufficient total bonded");
        decrementBalanceOf(msg.sender, balance, "Bonding: insufficient balance");

        emit Unbond(msg.sender, epoch().add(1), balance, value);
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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
            balanceOf(msg.sender) > 0,
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

        uint256 bonded = balanceOf(msg.sender);
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
            "Must have quorum"
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
            Decimal.ratio(approveFor(candidate), totalSupply()).greaterThan(Constants.getGovernanceSuperMajority()),
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

        Decimal.D256 memory stake = Decimal.ratio(balanceOf(account), totalSupply());
        return stake.greaterThan(Constants.getGovernanceProposalThreshold());
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/*
    Copyright 2019 ZeroEx Intl.

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
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
contract Permittable is ERC20Detailed, ERC20 {
    bytes32 constant FILE = "Permittable";

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant EIP712_PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    string private constant EIP712_VERSION = "1";

    bytes32 public EIP712_DOMAIN_SEPARATOR;

    mapping(address => uint256) nonces;

    constructor() public {
        EIP712_DOMAIN_SEPARATOR = LibEIP712.hashEIP712Domain(name(), EIP712_VERSION, Constants.getChainId(), address(this));
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = LibEIP712.hashEIP712Message(
            EIP712_DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                EIP712_PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            ))
        );

        address recovered = ecrecover(digest, v, r, s);
        Require.that(
            recovered == owner,
            FILE,
            "Invalid signature"
        );

        Require.that(
            recovered != address(0),
            FILE,
            "Zero address"
        );

        Require.that(
            now <= deadline,
            FILE,
            "Expired"
        );

        _approve(owner, spender, value);
    }
}

/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
contract ContractionDollar is IDollar, ERC20Detailed, Permittable, ERC20Burnable {

    constructor()
    ERC20Detailed("Contraction Dynamic Set Dollar", "CDSD", 18)
    Permittable()
    public
    { }

    function mint(address account, uint256 amount) public returns (bool) {
        require(_msgSender() == Constants.getDaoAddress(), "CDSD: only DAO is allowed to mint");
        _mint(account, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        if (
            _msgSender() != Constants.getDaoAddress() // always allow DAO
            && allowance(sender, _msgSender()) != uint256(-1)
        ) {
            _approve(
                sender,
                _msgSender(),
                allowance(sender, _msgSender()).sub(amount, "CDSD: transfer amount exceeds allowance"));
        }
        return true;
    }
}



/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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
contract Implementation is State, Bonding, CDSDMarket, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() public initializer {
        // committer reward:
        mintToAccount(msg.sender, 1000e18); // 1000 DSD to committer

        // Reset debt to zero dip-10
        _state.balance.debt = 0;

        // initialize interest multiplier
        _state10.globalInterestMultiplier = 1e18;

        // contributor  rewards:
        mintToAccount(0xF414CFf71eCC35320Df0BB577E3Bc9B69c9E1f07, 20000e18); // 20000 DSD to devnull
        mintToAccount(0x437cb43D08F64AF2aA64AD2525FE1074E282EC19,  8000e18); //  8000 DSD to gus
        mintToAccount(0xffc4BA093CEf9a5b9B02c9FEF8c128B2f48Eb291,  5000e18); //  5000 DSD to aurel
    }

    function advance() external incentivized {
        Bonding.step();
        Regulator.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    modifier incentivized {
        // run incentivisation after advancing, so we use the updated price
        uint256 startGas = gasleft();
        _;
        // fetch gasPrice & ETH price from Chainlink
        (, int256 ethPrice, , , ) = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).latestRoundData();
        (, int256 fastGasPrice, , , ) =
            AggregatorV3Interface(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C).latestRoundData();

        // Calculate DSD cost
        Decimal.D256 memory ethSpent =
            Decimal.D256({
                value: (startGas - gasleft() + 41000).mul(uint256(fastGasPrice)) // approximate used gas for tx
            });
        Decimal.D256 memory usdCost =
            ethSpent.mul(
                Decimal.D256({
                    value: uint256(ethPrice).mul(1e10) // chainlink ETH price has 8 decimals
                })
            );
        Decimal.D256 memory dsdCost = usdCost.div(getPrice());

        // Add incentive
        Decimal.D256 memory incentive = dsdCost.mul(Constants.getAdvanceIncentivePremium());

        // Mint advance reward to sender
        mintToAccount(msg.sender, incentive.value);
        emit Incentivization(msg.sender, incentive.value);
    }
}