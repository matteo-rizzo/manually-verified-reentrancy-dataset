from llama_index.core.prompts import PromptTemplate

REENTRANCY_PRINCIPLES = """
When analyzing, apply the following principles diligently:
1.  **Strict CEI Adherence**: The Checks-Effects-Interactions (CEI) pattern is paramount. If all state changes (Effects) related to an operation are *unconditionally completed before* any external call (Interaction) within that operation's logical flow, this is a strong indicator of safety for that specific interaction path.
2.  **External calls (Interactions)** belong to the following set of primitives: '.call' and any method invocation in Solidity, i.e. any method whose recipient expression (left hand of the dot operator) has a contract or interface type deriving from a type-cast from an address (including the 'this' expression).
3.  **External calls (Interactions)** do NOT belong to the following set of primitives: '.delegatecall', '.staticcall', and '.send' or '.transfer' where the left hand is an address (which is different from other occurrences of '.send' or '.transfer' method names belonging to ERC20 interfaces or other custom interfaces). Event emission (via the 'emit' keyword) are NOT considered interactions.
4.  **Effects** are state modifications, i.e. uses of the assignment operator on state variables as well as external calls (including low-level-call and method invocations) which may modify the state of other contracts whose logic is correlated. Note that the following cases are NOT considered effects: event emissions, requires, asserts, error statements.
5.  **Effective Reentrancy Guards**: Recognize correctly implemented and applied reentrancy guards (e.g., OpenZeppelin's `nonReentrant` modifier, custom mutexes). If a function is protected by such a guard, it should generally be considered safe from re-entering *itself*.
6.  **Plausible Exploit Path**: A classification of "Reentrant" requires a *plausible* scenario where re-entering leads to a tangible harmful outcome. Do not mark as "Reentrant" those code patterns implementing reentrancy guards, mutexes and other protection mechanisms. A "harmful outcome" does not necessarily lead to money theft, but also to contract state inconsistencies that may break the program logic or behaviour.
7.  **Cross-Function Reentrancy** takes place when an external call in a function A of a given contract allows re-entering into one or more functions of the same contract affecting state variables used or modified by A. If A is protected by a reentrancy guard, mutex or other protection mechanism, all other functions involved in possible reentrancy must be protected by the same mechanism.
8. **Cross-Contract Reentrancy** are complex scenarios that take place when an attacker does not re-enter directly into the caller contract or through other functions of the caller contract, but rather leverages the chain of invocations across different contracts, possibly re-entering at some point into the chain and by taking advantage of temporarily inconsistent states to manipulate the control flow or drain resources. 
9.  **Fallback/receive function**: the presence of a fallback (or receive) function in the contract does not imply a reentrancy vulenrability per sé. They have to be considered ordinary functions that has to be analyzed.
10. Consider a **Modernized Definition for Reentrancy** embracing a wider set of vulnerable scenarios, not only strictly mutual recursive calls. A malicious callee may compromise the intended logic of a contract (or of an interconnected set of contracts) not necessarily by calling back into the original caller, but by invoking alternative functions that modify the shared system state. This premature or unintended state alteration can in turn enable subsequent exploits.
"""

CLASSIFY_EXPLAIN_REQUEST = """
You must follow these steps precisely:

**Analyze and Classify the Contract**:
    * Carefully examine all functions, focusing on external calls and state management, applying the principles above.
    * Classify the contract as **Reentrant** only if you identify a pattern with a *plausible and specific exploit path* leading to a negative outcome, AND this path is not adequately mitigated by correctly implementing CEI, reentrancy guards, or other clear protective logic. This includes:
        * Clear violation of CEI where state is modified *after* an external call, and this can be exploited.
        * Absence or demonstrable flaw in a reentrancy guard on a function that can be re-entered to exploit intermediate state.
        * A credible cross-function reentrancy scenario where shared state is compromised.
    * Classify the contract as **Safe** if:
        * It strictly and demonstrably adheres to the CEI pattern for all interactions involving external calls.
        * Effective reentrancy guards are correctly applied to all relevant functions that might otherwise be vulnerable.
        * Potential cross-function reentrancy paths are blocked by guards, complete state updates, or design that prevents exploitation of shared state.
        * In essence, standard and sound security practices against reentrancy are evident and correctly implemented.
    * The classification **MUST** be one of: 'Reentrant' or 'Safe'. Avoid ambiguity. If a pattern looks suspicious but has robust, standard mitigations correctly applied, err on the side of 'Safe' for that specific pattern, clearly explaining the mitigation.

**Provide a Detailed Explanation**:
    * Your explanation **MUST** be a valid JSON string (special characters like quotes, newlines properly escaped: `\"`, `\\n`).
    * The internal structure of the JSON in the 'explanation' string can be adapted to best describe the specific findings (e.g., `mitigation_found_but_flawed`, `cross_function_scenario_details`).
    * **If classified as 'Reentrant'**:
        * Identify the vulnerable function(s).
        * Cite specific line numbers for the external call and relevant state modifications (effects).
        * **Crucially, describe the specific, plausible attack vector**, explaining *how* re-entrancy would lead to a detrimental outcome.
        * If mitigations are present but flawed or insufficient, explain why they fail.
    * **If classified as 'Safe'**:
        * Identify function(s) that handle external calls or state changes relevant to reentrancy.
        * Clearly explain the specific safeguards that prevent reentrancy.
        * Cite line numbers demonstrating such safeguards. If a pattern might look suspicious at first glance but is safe due to a specific reason, highlight this.
"""

# --- Prompt Templates ---

# Evaluate explanation quality
EVALUATE_EXPLANATION_PROMPT_TMPL = PromptTemplate("""
You are an expert Smart Contract Security Auditor and a meticulous evaluator of security analysis explanations. Your task is to critically evaluate the provided `Explanation Text` concerning reentrancy vulnerabilities (or their asserted absence) in the given `Solidity Contract Source Code`.

""" + REENTRANCY_PRINCIPLES + """

You must assess the `Explanation Text` based on the following three criteria:

1.  **Correctness**:
    * Definition: This refers to the factual accuracy of the `Explanation Text` in identifying and describing reentrancy vulnerabilities (or confirming their absence) relative to the provided `Solidity Contract Source Code`.
    * Evaluation Points:
        * Does the explanation accurately identify vulnerable functions, external calls, state variables, and their interactions related to reentrancy?
        * Are cited line numbers, function names, and variable names correct?
        * If a vulnerability is claimed, is the described attack vector plausible and technically sound given the code?
        * If safety is claimed, are the described safeguards (e.g., CEI pattern, reentrancy guards) actually present, correctly implemented, and effective as stated?
        * Are there any factual errors, misinterpretations of Solidity logic, or omissions of critical details that affect the reentrancy assessment?

2.  **Informativeness**:
    * Definition: This assesses the extent to which the `Explanation Text` furnishes meaningful, non-trivial insights that could aid a developer or auditor in comprehensively understanding the contract's security posture specifically concerning reentrancy.
    * Evaluation Points:
        * Does the explanation go beyond superficial statements (e.g., merely stating "an external call exists")?
        * Does it clarify *why* a specific pattern is vulnerable or safe in a way that builds understanding?
        * Does it highlight specific nuances of the reentrancy mechanism or protection (e.g., type of reentrancy like cross-function, specific state variables at risk, subtleties of a guard's implementation)?
        * Does it provide context or consequences of the findings that are valuable for remediation or trust?
        * Does it avoid being overly verbose with trivial information while still being comprehensive?

3.  **Pertinence**:
    * Definition: This concerns the relevance and specificity of the information provided in the `Explanation Text` directly to the analysis of reentrancy vulnerabilities (or their absence).
    * Evaluation Points:
        * Is all information presented directly relevant to assessing reentrancy?
        * Does the explanation stay focused on reentrancy, or does it digress into unrelated vulnerabilities (e.g., gas optimization, different attack vectors) unless they directly contribute to or intersect with a reentrancy concern?
        * Is the level of detail appropriate and specific to the reentrancy analysis, without being cluttered by irrelevant code aspects or overly broad statements?

### Inputs:

1.  **Solidity Contract Source Code**:
    ```solidity
    {contract_source}
    ```

2.  **Explanation Text to Evaluate**:
    ```text
    {explanation_text_to_evaluate}
    ```
""")

# Baseline (no context)
BASELINE_PROMPT_TMPL = PromptTemplate("""
    You are an expert Solidity smart contract security auditor. Your task is to perform a precise analysis for reentrancy vulnerabilities. Your primary objective is to identify actual exploitable reentrancy patterns while minimizing false positives by correctly recognizing effective mitigation techniques.
    
    ### Input Contract:
    ```solidity
    {contract_source}
    
    ### Task & Instructions
    
    """ + REENTRANCY_PRINCIPLES + CLASSIFY_EXPLAIN_REQUEST)

# RAG Chain of Thought (with context = source + audit)
RAG_COT_PROMPT_TMPL = PromptTemplate("""
    You are an expert blockchain security auditor specializing in reentrancy vulnerabilities. Your goal is to analyze the provided smart contract, compare it against audited examples, and classify its reentrancy risk.
    
    **Context**
    
    * **Input Contract:** The primary smart contract to be analyzed for vulnerabilities.
    * **Similar Contracts:** A collection of one or more contracts with existing security audits. These serve as examples of safe and unsafe patterns.
    
    **Inputs**
    
    * **Input Contract Source Code:**
        ```solidity
        {contract_source}
        ```
    
    * **Security Analysis of Similar Contracts:**
        {similar_contexts_str}
    ---
    
    ### **Task & Instructions**
    
    """ + REENTRANCY_PRINCIPLES + CLASSIFY_EXPLAIN_REQUEST)

# RAG (with context = source)
RAG_PROMPT_TMPL = PromptTemplate("""
  You are an expert blockchain security auditor specializing in reentrancy vulnerabilities. Your goal is to analyze the provided smart contract, compare it against audited examples, and classify its reentrancy risk.
  
  **Context**
  
  * **Input Contract:** The primary smart contract to be analyzed for vulnerabilities.
  * **Similar Contracts:** A collection of one or more contracts with existing security audits. These serve as examples of safe and unsafe patterns.
  
  **Inputs**
  
  * **Input Contract Source Code:**
      ```solidity
      {contract_source}
      ```
  
  * **Security Analysis of Similar Contracts:**
      {similar_contexts_str}
  ---
  
  
  ### **Task & Instructions**
  
  """ + REENTRANCY_PRINCIPLES + CLASSIFY_EXPLAIN_REQUEST)

# audit similar contract (reentrant)
ANALYZE_RAG_COT_CONTEXT_REENTRANT_TMPL = PromptTemplate("""
  You are a smart contract security auditor documenting a critical vulnerability. Your task is to generate a structured vulnerability report for the following Solidity contract, which is known to be reentrant.
  Your report should be precise and actionable, clearly explaining the flaw, the exploit, and the required fix.
  
  **Input Contract (Known Vulnerable)**
  ```solidity
  {similar_source_code}
  ```
  
  ---
  
  ### **Task & Instructions**
  
  1.  **Pinpoint the Vulnerability:** Identify the exact function and line number where the reentrancy vulnerability exists. This is typically an external call that happens before a state update.
  2.  **Describe the Attack Scenario:** Explain, step-by-step, how a malicious actor could exploit this flaw. Your explanation should detail the interaction between the attacker's contract and the vulnerable contract.
  3.  **Provide a Remediation Plan:** Explain *why* the code is insecure, specifically referencing its failure to follow the **Checks-Effects-Interactions (CEI)** pattern. Then, recommend the exact code modifications required to mitigate the vulnerability.
  """)

# audit similar contract (safe)
ANALYZE_RAG_COT_CONTEXT_SAFE_TMPL = PromptTemplate("""
  You are a smart contract security educator. Your task is to generate a structured security analysis for the following Solidity contract, which is known to be safe from reentrancy.
  Your analysis must be clear, concise, and suitable for teaching developers how to implement secure patterns.
  
  **Input Contract (Known Safe)**
  ```solidity
  {similar_source_code}
  ```
  
  ---
  
  ### **Task & Instructions**
  
  1.  **Identify Pattern:** Determine the primary security pattern that prevents reentrancy in the contract (e.g., "Checks-Effects-Interactions", "Reentrancy Guard").
  2.  **Explain Mechanism:** Provide a step-by-step analysis of the relevant function(s). Explain how the code's structure and order of operations effectively block a potential reentrancy attack.
  3.  **Pinpoint Code:** Identify the specific line numbers that are critical to the security mechanism.
  
  """)

# --- Chain-of-Thought (CoT) Prompts ---

BASELINE_COT_STEP1_TRIAGE_PROMPT_TMPL = PromptTemplate("""
You are a code analysis bot. Your only task is to identify and list all functions within the provided Solidity smart contract that contain an external call.
External calls are methods like `.call`, `.delegatecall` and any invocation of a method belonging to an external contract or interface.
Occurrences of `.staticcall`, and primitive `.send` or `.transfer` are not to be considered external calls.
Analyze the following contract and respond ONLY with a JSON object containing a single key, "functions_to_analyze", whose value is an array of strings, where each string is the name of a function that contains an external call.
### Input Contract:
```solidity
{contract_source}
```""")

BASELINE_COT_STEP2_ANALYZE_FUNC_PROMPT_TMPL = PromptTemplate("""
You are an expert Solidity smart contract security auditor. Your task is to perform a precise analysis for reentrancy vulnerabilities on a SINGLE function within a larger contract.
Apply these principles diligently:
1.  **Checks-Effects-Interactions (CEI)**: Determine if all state changes are completed *before* the external call.
2.  **Reentrancy Guards**: Identify if the function is protected by an effective guard like a `nonReentrant` modifier, custom mutex or equivalent protection mechanism.
3.  **Plausible Exploit Path**: If this was the only public/external function, would re-entering cause harm?
Analyze the function `{function_name}` within the context of the full contract source below.
### Full Contract Source:
```solidity
{contract_source}
```
### Your Task:
Provide your analysis for the function `{function_name}` as a single JSON object with the following structure:
{{
  "function_name": "{function_name}",
  "analysis": {{
    "has_external_call": true/false,
    "follows_cei_pattern": true/false,
    "has_reentrancy_guard": true/false,
    "is_vulnerable_in_isolation": true/false,
    "reasoning": "A brief explanation supporting your findings for this function. Cite line numbers for the external call and state changes."
  }}
}}""")

BASELINE_COT_STEP3_INTERACTION_PROMPT_TMPL = PromptTemplate("""
You are an expert security auditor specializing in complex, multi-step exploits. You have been provided with an analysis of individual functions from a smart contract. Your task is to determine if a cross-function reentrancy attack is possible.
A cross-function reentrancy attack occurs if: an external call in function A allows an attacker to re-enter the contract and call function B before function A has finished executing, and function B manipulates state that function A relies on, leading to an exploit.
### Full Contract Source:
```solidity
{contract_source}
```
### Individual Function Analyses:
```json
{analyses_json_str}
```
### Your Task:
Based on the full contract and the individual analyses, describe any plausible cross-function reentrancy attack paths. Respond with a single JSON object. If no paths exist, state that clearly in the "exploit_scenario".
{{
  "cross_function_analysis": {{
    "is_exploitable": true/false,
    "exploit_scenario": "Describe the step-by-step attack path, naming the entry function and the re-entered function. If no path exists, state 'No plausible cross-function reentrancy paths were identified.'"
  }}
}}""")

BASELINE_COT_STEP4_SYNTHESIS_PROMPT_TMPL = PromptTemplate("""
You are an expert Solidity smart contract security auditor preparing a final report. You have been provided with a step-by-step analysis of a contract. Your task is to synthesize this information into a final, conclusive assessment.
### Full Contract Source:
```solidity
{contract_source}
```
### Analysis Data:
- **Functions Analyzed in Isolation**:
```json
{func_analyses_str}
```
- **Cross-Function Analysis**:
```json
{inter_analysis_str}
```
### Final Report Instructions:
Based on ALL the provided analysis data, produce the final report.
- If any function was found "vulnerable_in_isolation": true OR if the cross-function analysis found "is_exploitable": true, the final classification **MUST** be 'Reentrant'.
- Otherwise, the classification is 'Safe'.
Your final output **MUST** be a single JSON object in the format below. The `explanation` must be a valid, escaped JSON string that summarizes the findings.
{{
  "classification": "Reentrant" | "Safe",
  "explanation": "{{...}}"
}}""")