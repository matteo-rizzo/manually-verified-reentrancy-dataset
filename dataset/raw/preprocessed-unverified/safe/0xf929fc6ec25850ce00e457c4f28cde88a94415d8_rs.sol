/**
 *Submitted for verification at Etherscan.io on 2021-03-28
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
contract IDAO {
    function epoch() external view returns (uint256);
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
contract IUSDC {
    function isBlacklisted(address _account) external view returns (bool);
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
contract PoolAccount {
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
        uint256 fluidUntil;
    }
}

contract PoolStorage {
    struct Provider {
        IDAO dao;
        IDollar dollar;
        IERC20 univ2;
    }
    
    struct Balance {
        uint256 staged;
        uint256 claimable;
        uint256 bonded;
        uint256 phantom;
    }

    struct State {
        Balance balance;
        Provider provider;

        bool paused;

        mapping(address => PoolAccount.State) accounts;
    }
}

contract PoolState {
    PoolStorage.State _state;
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
contract PoolGetters is PoolState {
    using SafeMath for uint256;

    /**
     * Global
     */

    function usdc() public view returns (address) {
        return Constants.getUsdcAddress();
    }

    function dao() public view returns (IDAO) {
        return IDAO(Constants.getDaoAddress());
    }

    function dollar() public view returns (IDollar) {
        return IDollar(Constants.getDollarAddress());
    }

    function univ2() public view returns (IERC20) {
        return IERC20(Constants.getPairAddress());
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

    function totalRewarded() public view returns (uint256) {
        return dollar().balanceOf(address(this)).sub(totalClaimable());
    }

    function paused() public view returns (bool) {
        return _state.paused;
    }

    /**
     * Account
     */

    function balanceOfStaged(address account) public view returns (uint256) {
        return _state.accounts[account].staged;
    }

    function balanceOfClaimable(address account) public view returns (uint256) {
        return _state.accounts[account].claimable;
    }

    function balanceOfBonded(address account) public view returns (uint256) {
        return _state.accounts[account].bonded;
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

    function fluidUntil(address account) public view returns (uint256) {
        return _state.accounts[account].fluidUntil;
    }

    function statusOf(address account) public view returns (PoolAccount.Status) {
        return epoch() >= _state.accounts[account].fluidUntil ?
            PoolAccount.Status.Frozen :
            PoolAccount.Status.Fluid;
    }

    /**
     * Epoch
     */

    function epoch() internal view returns (uint256) {
        return dao().epoch();
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
contract PoolSetters is PoolState, PoolGetters {
    using SafeMath for uint256;

    /**
     * Global
     */

    function pause() internal {
        _state.paused = true;
    }

    /**
     * Account
     */

    function incrementBalanceOfBonded(address account, uint256 amount) internal {
        _state.accounts[account].bonded = _state.accounts[account].bonded.add(amount);
        _state.balance.bonded = _state.balance.bonded.add(amount);
    }

    function decrementBalanceOfBonded(address account, uint256 amount, string memory reason) internal {
        _state.accounts[account].bonded = _state.accounts[account].bonded.sub(amount, reason);
        _state.balance.bonded = _state.balance.bonded.sub(amount, reason);
    }

    function incrementBalanceOfStaged(address account, uint256 amount) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.add(amount);
        _state.balance.staged = _state.balance.staged.add(amount);
    }

    function decrementBalanceOfStaged(address account, uint256 amount, string memory reason) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.sub(amount, reason);
        _state.balance.staged = _state.balance.staged.sub(amount, reason);
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

    function unfreeze(address account) internal {
        _state.accounts[account].fluidUntil = epoch().add(Constants.getPoolExitLockupEpochs());
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
contract Liquidity is PoolGetters {
    address private constant UNISWAP_FACTORY = address(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac); // Sushi Factory Address

    function addLiquidity(uint256 dollarAmount) internal returns (uint256, uint256) {
        (address dollar, address usdc) = (address(dollar()), usdc());
        (uint reserveA, uint reserveB) = getReserves(dollar, usdc);

        uint256 usdcAmount = (reserveA == 0 && reserveB == 0) ?
             dollarAmount :
             UniswapV2Library.quote(dollarAmount, reserveA, reserveB);

        address pair = address(univ2());
        IERC20(dollar).transfer(pair, dollarAmount);
        IERC20(usdc).transferFrom(msg.sender, pair, usdcAmount);
        return (usdcAmount, IUniswapV2Pair(pair).mint(address(this)));
    }

    // overridable for testing
    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(UniswapV2Library.pairFor(UNISWAP_FACTORY, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
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
contract Pool is PoolSetters, Liquidity {
    using SafeMath for uint256;

    constructor() public { }

    bytes32 private constant FILE = "Pool";

    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, uint256 value);
    event Claim(address indexed account, uint256 value);
    event Bond(address indexed account, uint256 start, uint256 value);
    event Unbond(address indexed account, uint256 start, uint256 value, uint256 newClaimable);
    event Provide(address indexed account, uint256 value, uint256 lessUsdc, uint256 newUniv2);

    function deposit(uint256 value) external onlyFrozen(msg.sender) notPaused {
        univ2().transferFrom(msg.sender, address(this), value);
        incrementBalanceOfStaged(msg.sender, value);

        balanceCheck();

        emit Deposit(msg.sender, value);
    }

    function withdraw(uint256 value) external onlyFrozen(msg.sender) {
        univ2().transfer(msg.sender, value);
        decrementBalanceOfStaged(msg.sender, value, "Pool: insufficient staged balance");

        balanceCheck();

        emit Withdraw(msg.sender, value);
    }

    function claim(uint256 value) external onlyFrozen(msg.sender) {
        dollar().transfer(msg.sender, value);
        decrementBalanceOfClaimable(msg.sender, value, "Pool: insufficient claimable balance");

        balanceCheck();

        emit Claim(msg.sender, value);
    }

    function bond(uint256 value) external notPaused {
        unfreeze(msg.sender);

        uint256 totalRewardedWithPhantom = totalRewarded().add(totalPhantom());
        uint256 newPhantom = totalBonded() == 0 ?
            totalRewarded() == 0 ? Constants.getInitialStakeMultiple().mul(value) : 0 :
            totalRewardedWithPhantom.mul(value).div(totalBonded());

        incrementBalanceOfBonded(msg.sender, value);
        incrementBalanceOfPhantom(msg.sender, newPhantom);
        decrementBalanceOfStaged(msg.sender, value, "Pool: insufficient staged balance");

        balanceCheck();

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
        decrementBalanceOfBonded(msg.sender, value, "Pool: insufficient bonded balance");
        decrementBalanceOfPhantom(msg.sender, lessPhantom, "Pool: insufficient phantom balance");

        balanceCheck();

        emit Unbond(msg.sender, epoch().add(1), value, newClaimable);
    }

    function provide(uint256 value) external notPaused {
        Require.that(
            totalBonded() > 0,
            FILE,
            "insufficient total bonded"
        );

        Require.that(
            totalRewarded() > 0,
            FILE,
            "insufficient total rewarded"
        );

        Require.that(
            balanceOfRewarded(msg.sender) >= value,
            FILE,
            "insufficient rewarded balance"
        );

        (uint256 lessUsdc, uint256 newUniv2) = addLiquidity(value);

        uint256 totalRewardedWithPhantom = totalRewarded().add(totalPhantom()).add(value);
        uint256 newPhantomFromBonded = totalRewardedWithPhantom.mul(newUniv2).div(totalBonded());

        incrementBalanceOfBonded(msg.sender, newUniv2);
        incrementBalanceOfPhantom(msg.sender, value.add(newPhantomFromBonded));


        balanceCheck();

        emit Provide(msg.sender, value, lessUsdc, newUniv2);
    }

    function emergencyWithdraw(address token, uint256 value) external onlyDao {
        IERC20(token).transfer(address(dao()), value);
    }

    function emergencyPause() external onlyDao {
        pause();
    }

    function balanceCheck() private {
        Require.that(
            univ2().balanceOf(address(this)) >= totalStaged().add(totalBonded()),
            FILE,
            "Inconsistent UNI-V2 balances"
        );
    }

    modifier onlyFrozen(address account) {
        Require.that(
            statusOf(account) == PoolAccount.Status.Frozen,
            FILE,
            "Not frozen"
        );

        _;
    }

    modifier onlyDao() {
        Require.that(
            msg.sender == address(dao()),
            FILE,
            "Not dao"
        );

        _;
    }

    modifier notPaused() {
        Require.that(
            !paused(),
            FILE,
            "Paused"
        );

        _;
    }
}