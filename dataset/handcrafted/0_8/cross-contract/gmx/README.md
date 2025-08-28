About GMX

GMX is a decentralized spot and perpetuals exchange best known on Arbitrum and Avalanche. Liquidity comes from a multi‑asset index called GLP, whose price is derived from the pool’s Assets Under Management (AUM). This folder contains a minimal “GMX‑like” toy suite to study an AUM inflation + reentrancy vector.

Acronyms

- GMX: decentralized exchange protocol for spot and perpetuals
- GLP: GMX Liquidity Provider index token (basket backing trades)
- AUM: Assets Under Management (total USD value of the GLP pool)
- USDC: USD Coin, a USD‑pegged stablecoin (ERC‑20)
- WBTC: Wrapped Bitcoin (ERC‑20 representation of BTC)
- PM: Position Manager (here `ToyPositionManager`)
- Keeper: off‑chain actor authorized to execute maintenance calls
- tGLP: “toy GLP” token used in this suite

GMX toy suite demonstrating a cross‑contract AUM inflation vector.

This folder contains simplified, GMX‑like contracts that reproduce an attack scenario where an inflated AUM is used during GLP redemption, combined with reentrancy on a refund path to grow a short position while keeping a stale average price.

How to reproduce

- Deploy in order:
  - DummyUSDC
  - Oracle, then set a price for a dummy index token
    - Example: `WBTC = 0x000000000000000000000000000000000000BEEF`
    - Call `setPrice(WBTC, 100_000e18)`
  - ToyVault
  - ToyShortsTracker
  - ToyGlpManager with `(USDC, Vault, ShortsTracker, Oracle, WBTC)`
  - ToyPositionManager with `(Vault, ShortsTracker)`
  - Wire the position manager
    - `Vault.setPositionManager(PM)`
    - `ShortsTracker.setPositionManager(PM)`
  - Keeper with `(PM)`, then `PM.setKeeper(Keeper)`
  - Attacker with `(Vault, PM, GlpManager, USDC, WBTC)`

- Prime the attacker
  - From `Attacker`, call `prime()` to mint 10,000 USDC, deposit, and receive tGLP.

- Push a stale/low avg price via keeper
  - From `Keeper.exec(...)`, use:
    - `account = Attacker`
    - `indexToken = WBTC`
    - `newAvgPriceE18 = 60_000e18` (intentionally stale/low)
    - `feeWei = 1 ether` and send 1 ether with the call

- Cash out using inflated AUM
  - From `Attacker`, call `cashOut()`.
  - Observe the attacker’s USDC balance exceeds 10,000 because `GlpManager.redeemGlp()` reads an inflated AUM.

What’s happening

- During the refund triggered by `cashOut()`, `Attacker.receive()` executes and reenters to call `Vault.increasePosition(...)`, inflating short size while the average price remains at `60_000e18`.
- The combination of a stale/low avg price and the inflated AUM on redemption creates a profitable imbalance for the attacker.

Notes

- Ensure the dummy `WBTC` address used in `Oracle.setPrice` matches the `WBTC` address passed to `ToyGlpManager`.
- The example values (e.g., `100_000e18`, `60_000e18`, `1 ether`) are chosen to clearly surface the imbalance; they can be adjusted to explore different dynamics.
- This setup is for educational purposes to illustrate cross‑contract interactions and reentrancy‑assisted state manipulation.
