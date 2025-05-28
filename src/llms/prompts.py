from llama_index.core.prompts import PromptTemplate

# For analyze_contract without context
ANALYZE_CONTRACT_NO_CONTEXT_TMPL_STR = """
You are an expert Solidity smart contract security auditor. Your task is to perform a precise analysis for reentrancy vulnerabilities. Your primary objective is to identify actual exploitable reentrancy patterns while minimizing false positives by correctly recognizing effective mitigation techniques.

When analyzing, apply the following principles diligently:
1.  **Strict CEI Adherence**: The Checks-Effects-Interactions (CEI) pattern is paramount. If all state changes (Effects) related to an operation are *unconditionally completed before* any external call (Interaction) within that operation's logical flow, this is a strong indicator of safety for that specific interaction path.
2.  **Effective Reentrancy Guards**: Recognize correctly implemented and applied reentrancy guards (e.g., OpenZeppelin's `nonReentrant` modifier, custom mutexes). If a function is protected by such a guard, it should generally be considered safe from re-entering *itself*.
3.  **Plausible Exploit Path**: A classification of "Reentrant" requires a *plausible* scenario where re-entry leads to a tangible negative outcome (e.g., fund theft, critical state corruption, broken logic). Do not flag theoretical patterns if standard mitigations are correctly in place or if the re-entry doesn't lead to a harmful consequence.
4.  **Cross-Function Reentrancy - Concrete Risk**: For cross-function reentrancy (external call in `funcA` allows re-entry into `funcB` affecting shared state), assess if `funcB` can indeed be called in a way that exploits an inconsistent state left by `funcA`. Consider if `funcB` also has protections or if the shared state is managed safely across both.
5.  **`delegatecall` Scrutiny**: `delegatecall` to untrusted or externally controlled contracts remains high risk. However, analyze the *specific context* and what state could be affected upon re-entry.

You must follow these steps precisely:

1.  **Analyze and Classify the Contract**:
    * Carefully examine all functions, focusing on external calls and state management, applying the principles above.
    * Classify the contract as **Reentrant** only if you identify a pattern with a *plausible and specific exploit path* leading to a negative outcome, AND this path is not adequately mitigated by correctly implemented CEI, reentrancy guards, or other clear protective logic. This includes:
        * Clear violation of CEI where state is modified *after* an external call, and this can be exploited.
        * Absence or demonstrable flaw in a reentrancy guard on a function that can be re-entered to exploit intermediate state.
        * A credible cross-function reentrancy scenario where shared state is compromised.
        * Exploitable reentrancy through `delegatecall` to a potentially malicious contract.
    * Classify the contract as **Safe** if:
        * It strictly and demonstrably adheres to the CEI pattern for all interactions involving external calls.
        * Effective reentrancy guards are correctly applied to all relevant functions that might otherwise be vulnerable.
        * Potential cross-function reentrancy paths are blocked by guards, complete state updates, or design that prevents exploitation of shared state.
        * Any `delegatecall` usage is either to trusted/verified contracts or its context of use does not open reentrancy vectors.
        * In essence, standard and sound security practices against reentrancy are evident and correctly implemented.
    * The classification **MUST** be one of: 'Reentrant' or 'Safe'. Avoid ambiguity. If a pattern looks suspicious but has robust, standard mitigations correctly applied, err on the side of 'Safe' for that specific pattern, clearly explaining the mitigation.

2.  **Provide a Detailed Explanation**:
    * Your explanation **MUST** be a valid JSON string (special characters like quotes, newlines properly escaped: `\"`, `\\n`).
    * The internal structure of the JSON in the 'explanation' string can be adapted to best describe the specific findings (e.g., `mitigation_found_but_flawed`, `cross_function_scenario_details`).
    * **If classified as 'Reentrant'**:
        * Identify the vulnerable function(s).
        * Cite specific line numbers for the external call and relevant state modifications.
        * **Crucially, describe the specific, plausible attack vector**, explaining *how* re-entrancy would lead to a detrimental outcome.
        * If mitigations are present but flawed or insufficient, explain why they fail.
    * **If classified as 'Safe'**:
        * Identify function(s) that handle external calls or state changes relevant to reentrancy.
        * **Clearly explain the specific safeguards that prevent reentrancy** (e.g., "Strict CEI: State variable `userLock[msg.sender]` on line X set *before* external call on line Y.", "Function `criticalOp` protected by `nonReentrant` modifier inherited from OpenZeppelin contracts.", "Cross-function path from `A` to `B` is safe because `B` also uses a reentrancy guard / `A` finalizes all shared state updates before calling out.").
        * Cite line numbers demonstrating these safeguards. If a pattern might look suspicious at first glance but is safe due to a specific reason, highlight this.

### Input Contract:
```solidity
{contract_source}
"""

ANALYZE_CONTRACT_NO_CONTEXT_TMPL = PromptTemplate(ANALYZE_CONTRACT_NO_CONTEXT_TMPL_STR)

# For analyze_contract WITH context
ANALYZE_CONTRACT_WITH_CONTEXT_TMPL_STR = """
You are a highly experienced blockchain security expert. Your goal is to classify the following input contract
based on its source code and the provided similar contracts with groundtruth attached.

Input Contract Source Code:
```solidity
{contract_source}
--------------------------------------------------------
Security Analysis of Similar Contracts:
{similar_contexts_str}

Task:
Classify the Contract: Determine whether the input contract is 'Safe' or 'Reentrant' based primarily on its code, using the labelled similar contract for context and pattern identification. Be precise: the classification must be either 'Reentrant' or 'Safe'.
Explain the Classification: Provide a structured and extensive explanation, referencing specific lines/functions in the input contract and potentially drawing parallels or contrasts with patterns identified in the similar contracts. Ensure your explanation is valid JSON string content (e.g., escape necessary characters like quotes).
Respond with a well-structured security assessment and a clear decision in the requested format.
"""

ANALYZE_CONTRACT_WITH_CONTEXT_TMPL = PromptTemplate(ANALYZE_CONTRACT_WITH_CONTEXT_TMPL_STR)

# For analyze_similar_contract (Reentrant)
ANALYZE_REENTRANT_TMPL_STR = """
You are an expert in smart contract security. Analyze the following Solidity contract,
which is known to be reentrant. Your task is to:

Identify the specific lines or code patterns where the reentrancy vulnerability occurs.
Explain concisely how an attacker could exploit this vulnerability.
Briefly suggest secure coding practices or specific changes to mitigate this issue.
```solidity
{similar_source_code}
"""

ANALYZE_REENTRANT_TMPL = PromptTemplate(ANALYZE_REENTRANT_TMPL_STR)

# For analyze_similar_contract (Safe)
ANALYZE_SAFE_TMPL_STR = """
You are an expert in smart contract security. Analyze the following Solidity contract,
which is known to be safe (not reentrant). Your task is to:

Confirm why this contract is not vulnerable to reentrancy.
Highlight the specific security mechanisms, patterns, or code structures (e.g., Checks-Effects-Interactions, Reentrancy Guard) that protect it from reentrancy attacks.
```solidity
{similar_source_code}
"""

ANALYZE_SAFE_TMPL = PromptTemplate(ANALYZE_SAFE_TMPL_STR)

# For analyze_similar_contract (General/Unknown)
ANALYZE_GENERAL_TMPL_STR = """
You are an expert in smart contract security. Analyze the following Solidity contract
for any potential vulnerabilities, focusing primarily on reentrancy.

If vulnerabilities (especially reentrancy) exist:

Identify the affected lines or code patterns.
Explain the attack vector and how it could be exploited.
If the contract appears secure against reentrancy:

Justify why it is safe regarding reentrancy.
Highlight implemented security best practices relevant to reentrancy prevention.
Source Code:
```solidity
{similar_source_code}
"""

ANALYZE_GENERAL_TMPL = PromptTemplate(ANALYZE_GENERAL_TMPL_STR)
