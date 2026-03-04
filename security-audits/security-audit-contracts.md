# QINV Vault (QINDEX) — On-Chain Security Audit Report

**Date:** 2026-02-24  
**Auditor:** Automated On-Chain Analysis  
**Network:** Base (Chain ID 8453)  
**Scope:** Smart contract security assessment of the QINV Index Vault

---

## Contract Addresses

| Component | Address | Type |
|-----------|---------|------|
| **Proxy (Vault)** | `0xd583e488b274c3ef7f250c7bfbf8b5b0fa72424d` | ERC-1967 UUPS Proxy |
| **Implementation** | `0x53dc7d1a3796734f4ae5df06857cbb208af1b4ba` | Logic contract |
| **Owner** | `0x26fdE4B9C41F9A233c368ea589060b05071c2Da7` | EOA ⚠️ |
| **ADMIN_ROLE Holder** | `0x89825554a06b7e0de8a4325489f7ee21847e783d` | Gnosis Safe 2/4 |
| **AllowanceHolder (0x Protocol)** | `0x0000000000001fF3684f28c67538d4D072C22734` | External Protocol |

## Token Details

| Property | Value |
|----------|-------|
| Name | QINV-Index Token |
| Symbol | QINDEX |
| Decimals | 18 |
| Total Supply | ~30.227 QINDEX |
| Total Assets (NAV) | ~0.0556 ETH equivalent |
| NAV per Token | ~0.00184 ETH (~$4.16) |

## Basket Composition

| Token | Address | Target Weight | Current Balance | USD Value |
|-------|---------|--------------|-----------------|-----------|
| WBTC | `0x0555E30da8f98308EdB960aa94C0Db47230d2B9c` | 40% | 0.00011966 BTC | ~$9.11 |
| WETH | `0x4200000000000000000000000000000000000006` | 40% | 0.00405 ETH | ~$9.18 |
| SOL | `0x311935Cd80B76769bF2ecC9D8Ab7635b2139cf82` | 20% | 0.0515 SOL | ~$4.02 |
| **Total** | | **100%** | | **~$22.30** |
| USDC | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` | - | 0.000003 USDC | ~$0 |

## Contract Architecture

- **Proxy Pattern:** UUPS (Universal Upgradeable Proxy Standard) — ERC-1967 compliant
- **Access Control:** OpenZeppelin AccessControl (role-based) + Ownable2Step
- **Pausable:** Yes — Pausable pattern implemented
- **Solidity Version:** 0.8.30 (inferred from bytecode `0x081e`)
- **Implementation Size:** ~15.8 KB bytecode (substantial logic)

### Key Functions Identified

| Selector | Function | Access |
|----------|----------|--------|
| `0x4f1ef286` | `upgradeToAndCall(address,bytes)` | Owner |
| `0x8456cb59` | `pause()` | Requires role |
| `0x3f4ba83a` | `unpause()` | Requires role |
| `0x0db189b4` | `setBasket(address[],uint256[])` | Owner/Admin |
| `0x84ab57ab` | `setAllowanceHolder(address)` | Owner/Admin |
| `0x81ca52cf` | `setRebalanceCooldown(uint256)` | Owner/Admin |
| `0xdb006a75` | `redeem(uint256)` | Any holder |
| `0x913edf02` | invest (deposit+swap) | Any user |
| `0x2f2ff15d` | `grantRole(bytes32,address)` | DEFAULT_ADMIN_ROLE |
| `0x715018a6` | `renounceOwnership()` | Owner |

---

## Findings

### 🔴 FINDING #1: Owner is an EOA (Externally Owned Account)
**Severity: CRITICAL**

The contract owner (`0x26fdE4B9...`) is a single EOA wallet, **not a multisig**. This was confirmed by checking:
```
cast code 0x26fdE4B9... → 0x (empty = EOA)
```

**Impact:** A single private key controls all owner-level functions including proxy upgrades, pausing, and basket changes. If this key is compromised, leaked, or the holder acts maliciously, all user funds are at immediate risk.

**Mitigating factor:** A 2-of-4 Gnosis Safe (`0x89825554...`) has been granted the `ADMIN_ROLE`, but the contract owner (EOA) retains `DEFAULT_ADMIN_ROLE` and can revoke any role, upgrade the contract, or transfer ownership unilaterally.

**Gnosis Safe signers (ADMIN_ROLE):**
1. `0x26fdE4B9C41F9A233c368ea589060b05071c2Da7` (same as owner EOA)
2. `0xFd32F43298269502AB534b0DaB459CD278908886`
3. `0x45b4cAe9613BCA2ea37A3Bc6F80f08BAd719e25a`
4. `0x9f5f65C9dE9d711D3692d7D5450454C1aDbfd3A8`

Threshold: **2 of 4** — meaning the owner EOA + any one signer can execute admin actions.

---

### 🔴 FINDING #2: Unrestricted Proxy Upgrade — No Timelock
**Severity: CRITICAL**

The contract uses UUPS proxy pattern. The owner can call `upgradeToAndCall()` to **instantly** replace the entire implementation contract with arbitrary code.

- **No timelock contract found** (all timelock-related function calls returned empty)
- **No ProxyAdmin separation** — EIP-1967 admin slot is `0x0000...0000`
- The upgrade was already performed on **2026-02-21** (tx `0xfac822...`) — implementation changed with empty calldata

**Impact:** The owner can, at any time, deploy a new implementation that:
- Drains all vault assets to any address
- Removes withdrawal functionality
- Mints unlimited tokens
- Changes any logic without notice

**There is zero delay or governance protection for users.**

---

### 🔴 FINDING #3: Source Code NOT Verified
**Severity: CRITICAL**

Neither the proxy nor the implementation contract have verified source code on BaseScan:
- Proxy: "Are you the contract creator? Verify and Publish your contract source code today!"
- Implementation: Same message

**Impact:** Without verified source code, it is **impossible** to fully audit the contract logic. The analysis in this report is based on bytecode reverse-engineering, function selector matching, and on-chain behavior observation. Hidden backdoors, subtle vulnerabilities, or malicious logic cannot be ruled out.

---

### 🟠 FINDING #4: Pause Function Can Block Withdrawals
**Severity: HIGH**

The contract implements OpenZeppelin's Pausable pattern:
- `paused()` returns `false` (currently not paused)
- `pause()` and `unpause()` functions exist in the contract
- When paused, it is likely that `redeem()` and invest functions are blocked

**Impact:** The owner or authorized role holder can pause the contract, preventing all users from withdrawing their funds. Combined with the upgrade capability, this creates a rug-pull vector:
1. Pause contract → block withdrawals
2. Upgrade to malicious implementation
3. Drain funds

---

### 🟠 FINDING #5: Owner Can Change Basket Composition
**Severity: HIGH**

The `setBasket(address[],uint256[])` function allows changing which tokens the vault holds and their target weights. Recent transaction (Feb 21, 2026) changed weights to:
- WBTC: 40% (was previously 40%)
- WETH: 40% (was previously 40%)
- SOL: 20% (was previously 20%)

**Impact:** The owner could redirect the basket to worthless tokens or tokens they control, effectively diluting or stealing value from holders.

---

### 🟡 FINDING #6: Rebalance Mechanism Uses External DEX Swaps
**Severity: MEDIUM**

The invest function (`0x913edf02`) accepts calldata for swaps through the 0x Protocol AllowanceHolder (`0x0000000000001fF3684f28c67538d4D072C22734`). This is used for:
- Converting USDC deposits into basket tokens
- Rebalancing portfolio weights

**Risks:**
- **Sandwich attacks:** Swap calldata is visible in mempool on Base (though Base has some MEV protections)
- **Stale quotes:** If swap routes are pre-computed off-chain, slippage could cause losses
- **AllowanceHolder trust:** The vault delegates token approvals through this contract

**Mitigating factor:** The vault currently shows zero USDC allowance to the AllowanceHolder, suggesting approvals are not persistent.

---

### 🟡 FINDING #7: Rebalance Cooldown — 1 Day
**Severity: MEDIUM**

`getRebalanceCooldown()` returns 86400 seconds (1 day). Last rebalance was at timestamp 1770919917 (Feb 12, 2026).

**Impact:** While this prevents rapid rebalancing (which could be used for wash trading or manipulation), the cooldown is modifiable via `setRebalanceCooldown()` by the owner, and 1 day is a relatively short window.

---

### 🟡 FINDING #8: Ownership Transfer Uses 2-Step Pattern
**Severity: LOW (Positive)**

The contract uses OpenZeppelin's `Ownable2Step` pattern:
- `pendingOwner()` returns `0x0000...0000` (no pending transfer)
- Requires the new owner to accept the transfer
- Prevents accidental ownership transfer to wrong address

**This is a positive security feature**, reducing risk of ownership loss.

---

### 🟢 FINDING #9: Withdrawal (Redeem) Mechanism Works Correctly
**Severity: INFORMATIONAL**

The `redeem(uint256)` function burns the caller's QINDEX tokens and transfers proportional amounts of all basket tokens (WBTC, WETH, SOL) directly to the caller. Verified via on-chain transaction analysis:

**Tx `0xd9ae58e3...` (Redeem by owner):**
- Burned: 10 QINDEX tokens (10e18)
- Received: WBTC (0x1044 = 4164 sats), WETH (0x4ff82bd15807a), SOL (0x102c861)
- All transfers in a single atomic transaction
- No withdrawal delay or lock period observed

**Positive aspects:**
- Users receive underlying tokens directly (not a single token)
- No evidence of withdrawal fees in this transaction
- Burns happen before transfers (checks-effects-interactions pattern likely followed)

---

### 🟢 FINDING #10: No Unlimited Token Approvals from Vault
**Severity: INFORMATIONAL (Positive)**

Checked allowances from the vault to the AllowanceHolder:
- USDC allowance: 0
- WETH allowance: 0

The vault does not maintain standing unlimited approvals, reducing the attack surface if the AllowanceHolder contract were compromised.

---

## Key Security Questions — Answered

### 1. Can the owner steal user funds?
**🔴 YES.** The owner can upgrade the proxy to a malicious implementation that transfers all assets out. Even without upgrading, the owner controls `setBasket()` and rebalance functions that could redirect funds. The owner is a single EOA with no timelock protection.

### 2. Can the owner change the contract to a malicious version?
**🔴 YES.** UUPS proxy allows `upgradeToAndCall()` with immediate effect. Already demonstrated on Feb 21, 2026. No timelock, no governance vote, no delay.

### 3. Is there a timelock protecting users?
**🔴 NO.** No timelock contract was found. All admin actions execute immediately.

### 4. Is the owner a multisig or single key?
**🔴 SINGLE KEY (EOA).** The owner `0x26fdE4B9...` is an EOA. A 2-of-4 Gnosis Safe has `ADMIN_ROLE` but the owner retains supreme authority via `DEFAULT_ADMIN_ROLE` and ownership.

### 5. Can withdrawals be blocked?
**🟠 YES.** The `pause()` function can halt all operations. Combined with upgrade capability, this is a significant risk.

### 6. Can tokens be minted without backing?
**🟡 UNCLEAR.** Without verified source code, we cannot confirm whether arbitrary minting is possible. The invest function appears to require real token deposits, but a proxy upgrade could change this instantly.

### 7. What happens if the owner key is compromised?
**🔴 CATASTROPHIC.** An attacker with the owner key could:
- Upgrade the contract to drain all funds
- Pause and prevent withdrawals
- Change the basket to worthless tokens
- Grant themselves any role
- Transfer ownership permanently

The 2-of-4 multisig (ADMIN_ROLE) cannot prevent this since the owner holds `DEFAULT_ADMIN_ROLE`.

### 8. Is the NAV calculation manipulable?
**🟡 PARTIALLY.** NAV is calculated on-chain by summing `balanceOf()` for each basket token. This could theoretically be manipulated via:
- Flash loans to temporarily inflate token balances (though the vault appears to only count its own holdings)
- Owner changing basket composition to tokens with manipulable prices
- Reentrancy during redeem (mitigated if using Solidity 0.8.30 checks)

---

## Transaction History Summary

| Date | Action | Actor | Notes |
|------|--------|-------|-------|
| Jan 26, 2026 | Contract deployed | Owner EOA | Proxy + original implementation |
| Jan 26, 2026 | Initial investment | Owner EOA | USDC deposited, swapped to basket |
| Jan 26, 2026 | Multiple invest/redeem | 0xCEFF60e5 (EOA) | Testing or early user |
| Feb 12, 2026 | setBasket + rebalance | Owner EOA | Basket composition updated |
| Feb 18, 2026 | Redeem 10 QINDEX | Owner EOA | Withdrew proportional tokens |
| Feb 21, 2026 | New implementation deployed | Owner EOA | `0x53dc7d1a...` |
| Feb 21, 2026 | upgradeToAndCall | Owner EOA | Proxy upgraded to new impl |
| Feb 21, 2026 | grantRole(ADMIN_ROLE) | Owner EOA | Granted to Gnosis Safe 2/4 |
| Feb 21, 2026 | setBasket | Owner EOA | WBTC 40%, WETH 40%, SOL 20% |

**Notable:** Only 2 addresses have interacted with the vault — the owner and one other EOA (`0xCEFF60e5`). Very low usage/adoption.

---

## Risk Summary

| Category | Severity | Status |
|----------|----------|--------|
| Proxy Upgrade (no timelock) | 🔴 CRITICAL | Active risk |
| Owner is EOA (not multisig) | 🔴 CRITICAL | Active risk |
| Source code unverified | 🔴 CRITICAL | Active risk |
| Pause can block withdrawals | 🟠 HIGH | Capability exists |
| Basket manipulation | 🟠 HIGH | Capability exists |
| DEX swap/MEV risk | 🟡 MEDIUM | Design consideration |
| Rebalance cooldown modifiable | 🟡 MEDIUM | Low urgency |
| 2-step ownership transfer | 🟢 LOW | Positive feature |
| No standing token approvals | 🟢 LOW | Positive feature |
| Redeem works atomically | 🟢 LOW | Positive feature |

---

## Recommendations

### For Users / Investors
1. **HIGH RISK** — This vault has critical centralization risks. A single private key controls all funds.
2. The source code is not verified — you cannot independently verify what the contract does.
3. The owner can change the contract at any time with no warning period.
4. Only invest amounts you can afford to lose entirely.
5. Monitor the proxy for upgrade events — any upgrade should be treated as potentially malicious until source code is verified.

### For the Team / Owner
1. **Verify source code** on BaseScan immediately — this is table stakes for trust.
2. **Transfer ownership to the multisig** — the 2/4 Gnosis Safe should be the owner, not an EOA.
3. **Add a timelock** (48-72h minimum) on upgrades and critical admin actions.
4. **Consider renouncing** `DEFAULT_ADMIN_ROLE` from the EOA after transferring to multisig.
5. **Increase multisig threshold** from 2/4 to at least 3/4.
6. **Implement upgrade governance** — require community notice period before any upgrade.

---

## Overall Assessment

**RISK LEVEL: 🔴 HIGH**

The QINV vault is a functional crypto index product with sound basic architecture (UUPS proxy, role-based access, pausable, 2-step ownership). However, it suffers from **critical centralization risks** that make it unsuitable for holding significant user funds in its current state.

The combination of:
- Unverified source code
- EOA owner with supreme authority
- Instant proxy upgrades with no timelock
- Ability to pause and block withdrawals

...creates a trust model that is entirely dependent on the goodwill and security practices of a single private key holder. This is essentially a custodial arrangement disguised as a smart contract.

**Current TVL (~$22.30)** is very low, which limits immediate financial risk, but the architecture concerns would scale dangerously with any growth in deposits.

---

*This audit was performed via on-chain analysis, bytecode inspection, and transaction history review. It does not constitute financial advice. Without verified source code, hidden vulnerabilities may exist that are not detectable through external analysis alone.*
