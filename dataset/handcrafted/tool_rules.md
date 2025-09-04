In this document we recap for each existing analyzer tool what kind of analysis it performs for Reentrancy.

# CCC  
- **Analysis target:** Solidity source code (including incomplete snippets)  
- **Analysis performed on:** Code Property Graph (CPG) generated from source code  
- **Techniques:** Pattern-based analysis expressed as queries on the CPG  
- **Reentrancy detection criterion:** Matches a pattern where the contract makes an external call before completing its state updates, with the call target or value influenced by user input, and without safeguards or mitigating conditions to prevent reentry.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function reentrancy

# ConFuzzius  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Combination of syntactic analysis, symbolic execution, SAT solving, and fuzzing  
- **Reentrancy detection criterion:** Detects CALL instructions preceded by SLOADs and followed by SSTOREs on the same storage slot. A call is considered reentrant if:  
  - The gas forwarded is greater than 2300 (must be concrete, non-symbolic)  
  - AND the transferred value is greater than zero or symbolic  
  - AND the call target address is symbolic  
  It is NOT considered reentrant if the value is zero or the address is constant.  
- **Notes:** Supported EVM versions down to 2019 (Petersburg)  
- **Reentrancy types detected:** Single-function and cross-function reentrancy (and some cross-contract cases, depending on analysis scope)

# Conkas  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving using Z3  
- **Reentrancy detection criterion:** Detects SLOAD instructions before CALL and SSTORE instructions after CALL, then produces constraints between loads and stores to detect dependencies indicating reentrancy.  
- **Notes:** Supported Solidity versions up to 0.6.11  
- **Reentrancy types detected:** Single-function reentrancy

# Ethainter  
- **Analysis target:** N/A for reentrancy detection  
- **Analysis performed on:** N/A  
- **Techniques:** N/A  
- **Reentrancy detection criterion:** Not supported (no reentrancy detection implemented)  
- **Notes:** Ethainter does not implement any reentrancy detection features.  
- **Reentrancy types detected:** Not supported

# eThor  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Abstract interpretation combined with Horn clauses and SMT reachability solving  
- **Reentrancy detection criterion:** Detects reentrancy by checking for execution traces where, after a contract has been reentered, it can still perform another external call.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function and cross-function reentrancy (and some cross-contract cases if they manifest as reentry into the same contract)

# HoneyBadger  
- **Analysis target:** N/A for reentrancy detection  
- **Analysis performed on:** N/A  
- **Techniques:** N/A  
- **Reentrancy detection criterion:** Not supported (no reentrancy detection implemented)  
- **Notes:** HoneyBadger does not provide reentrancy detection.  
- **Reentrancy types detected:** Not supported

# MadMax  
- **Analysis target:** N/A for reentrancy detection  
- **Analysis performed on:** N/A  
- **Techniques:** N/A  
- **Reentrancy detection criterion:** Not supported (no reentrancy detection implemented)  
- **Notes:** MadMax does not support reentrancy detection.  
- **Reentrancy types detected:** Not supported

# Maian  
- **Analysis target:** N/A for reentrancy detection  
- **Analysis performed on:** N/A  
- **Techniques:** N/A  
- **Reentrancy detection criterion:** Not supported (no reentrancy detection implemented)  
- **Notes:** Maian does not include reentrancy detection.  
- **Reentrancy types detected:** Not supported

# Manticore  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving  
- **Reentrancy detection criterion:** Given an optional concrete list of attacker addresses, warns when:  
  - A successful CALL is made to an attacker address (or any human account if no list is given) with gas greater than 2300  
  - A SSTORE occurs after the CALL  
  - The storage slot written by SSTORE is used in some control flow path, indicating potential vulnerability  
- **Notes:** None  
- **Reentrancy types detected:** Single-function and cross-function reentrancy (and some cross-contract cases, depending on analysis scope)

# Mythril  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving  
- **Reentrancy detection criterion:** Considered reentrant if:  
  - External calls (CALL, DELEGATECALL, CALLCODE) are made with more than 2300 gas  
  - The call target is symbolic or dynamic  
  - A state access (SLOAD, SSTORE, CREATE, CREATE2) occurs after the external call, including read accesses (SLOAD), which are considered risky  
- **Notes:** None  
- **Reentrancy types detected:** Single-function and cross-function reentrancy (and some cross-contract cases, depending on analysis scope)

# Osiris  
- **Analysis target:** N/A for reentrancy detection  
- **Analysis performed on:** N/A  
- **Techniques:** N/A  
- **Reentrancy detection criterion:** Discarded because it does not detect reentrancy  
- **Notes:** Osiris does not implement reentrancy detection.  
- **Reentrancy types detected:** Not supported

# Oyente  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving, using path conditions solved by Z3  
- **Reentrancy detection criterion:** Checks for SSTORE instructions after CALL or CALLCODE instructions on feasible paths. It is somewhat outdated as it checks CALLCODE (ancestor of DELEGATECALL) and some obsolete reentrancy patterns.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function reentrancy

# Pakala  
- **Analysis target:** N/A for reentrancy detection  
- **Analysis performed on:** N/A  
- **Techniques:** N/A  
- **Reentrancy detection criterion:** Not supported (no reentrancy detection implemented)  
- **Notes:** Pakala does not provide reentrancy detection.  
- **Reentrancy types detected:** Not supported

# Securify  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic analysis combined with contract call dependency analysis and fact checking via Datalog (Soufflé)  
- **Reentrancy detection criterion:** Detects CALL instructions with the following filters:  
  - Discards CALLs with a constant zero value transfer  
  - Discards CALLs whose gas argument does not have a dataflow dependency on a GAS instruction above in the bytecode  
  Remaining CALLs are flagged as potential reentrancy vulnerabilities.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function reentrancy

# Securify2  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Intermediate representation generated from source code  
- **Techniques:** Pattern-based declarative analysis using Datalog rules  
- **Reentrancy detection criterion:** Detects external calls that occur before state updates by matching patterns on the intermediate representation.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function and cross-function reentrancy

# Semgrep  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code  
- **Techniques:** Pattern matching using semgrep rules for known method calls and small syntactic/lexical patterns  
- **Reentrancy detection criterion:** Detects certain ERC-related reentrant calls but does not implement a general detector for real-world reentrant code. It is primarily a general-purpose grep-like tool and is not specialized for Solidity vulnerabilities.  
- **Notes:** Limited scope for reentrancy detection; mainly a general-purpose tool.  
- **Reentrancy types detected:** Single-function reentrancy

# sFuzz  
- **Analysis target:** N/A (fuzzer, not static analyzer)  
- **Analysis performed on:** Runs attacker contracts on a customized EVM  
- **Techniques:** Fuzzing by generating attacker contracts and executing them  
- **Reentrancy detection criterion:** Not a static analysis tool; supports Solidity up to version 0.4.x  
- **Notes:** Not a static analyzer; detection relies on fuzzing attacks.  
- **Reentrancy types detected:** Not specified

# Slither  
- **Analysis target:** Solidity and Vyper source code  
- **Analysis performed on:** Source code  
- **Techniques:** Pattern-based detection for reentrancy; data flow and control flow analysis for other vulnerabilities  
- **Reentrancy detection criterion:** Detects if a state variable is changed after an external call, indicating a potential reentrancy vulnerability.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function reentrancy

# Smartcheck  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code parsed into XML AST using ANTLR for Java, then queried with XPath and regexps  
- **Techniques:** Purely syntactic analysis  
- **Reentrancy detection criterion:** No rules explicitly defined for reentrancy detection, although the original paper mentions them.  
- **Notes:** No explicit reentrancy detection rules currently implemented.  
- **Reentrancy types detected:** Single-function reentrancy

# Solhint  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code  
- **Techniques:** Linting rules that warn about potentially risky low-level calls  
- **Reentrancy detection criterion:** Does not detect reentrancy but warns if low-level calls are used, which could be risky.  
- **Notes:** No direct reentrancy detection; provides warnings on risky low-level calls.  
- **Reentrancy types detected:** Single-function reentrancy

# teEther  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Symbolic execution combined with SMT solvers  
- **Reentrancy detection criterion:** Detects if an external CALL can be followed by reentering the vulnerable contract before its state is updated by symbolically executing all possible paths.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function and cross-function reentrancy (and some cross-contract cases, depending on analysis scope)

# Vandal  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Symbolic execution to compute jump destinations during bytecode decompilation, combined with pattern-based detection using Datalog queries  
- **Reentrancy detection criterion:** Flags a CALL as reentrant if it forwards sufficient gas and is not protected by a mutex, based on Datalog queries identifying external calls followed by state updates.  
- **Notes:** None  
- **Reentrancy types detected:** Single-function and cross-function reentrancy