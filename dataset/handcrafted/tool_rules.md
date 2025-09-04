In this document we recap for each existing analyzer tool what kind of analysis it performs for Reentrancy.

# CCC  
- **Analysis target:** Solidity source code (including incomplete snippets)  
- **Analysis performed on:** Code Property Graph (CPG) generated from source code  
- **Techniques:** Pattern-based analysis expressed as queries on the CPG  
- **Reentrancy detection criterion:** Matches a pattern where the contract makes an external call before completing its state updates, with the call target or value influenced by user input, and without safeguards or mitigating conditions to prevent reentry.

# ConFuzzius  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Combination of syntactic analysis, symbolic execution, SAT solving, and fuzzing  
- **Reentrancy detection criterion:** Detects CALL instructions preceded by SLOADs and followed by SSTOREs on the same storage slot. A call is considered reentrant if:  
  - The gas forwarded is greater than 2300 (must be concrete, non-symbolic)  
  - AND the transferred value is greater than zero or symbolic  
  - AND the call target address is symbolic  
  It is NOT considered reentrant if the value is zero or the address is constant.  
- **Supported EVM versions:** Down to 2019 (Petersburg)

# Conkas  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving using Z3  
- **Reentrancy detection criterion:** Detects SLOAD instructions before CALL and SSTORE instructions after CALL, then produces constraints between loads and stores to detect dependencies indicating reentrancy.

- **Supported Solidity versions:** Up to 0.6.11

# Ethainter  
- **Analysis target:** N/A for reentrancy detection  
- **Reentrancy detection:** Not supported (no reentrancy detection implemented)

# eThor  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Abstract interpretation combined with Horn clauses and SMT reachability solving  
- **Reentrancy detection criterion:** Detects reentrancy by checking for execution traces where, after a contract has been reentered, it can still perform another external call.

# HoneyBadger  
- **Analysis target:** N/A for reentrancy detection  
- **Reentrancy detection:** Not supported (no reentrancy detection implemented)

# MadMax  
- **Analysis target:** N/A for reentrancy detection  
- **Reentrancy detection:** Not supported (no reentrancy detection implemented)

# Maian  
- **Analysis target:** N/A for reentrancy detection  
- **Reentrancy detection:** Not supported (no reentrancy detection implemented)

# Manticore  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving  
- **Reentrancy detection criterion:** Given an optional concrete list of attacker addresses, warns when:  
  - A successful CALL is made to an attacker address (or any human account if no list is given) with gas greater than 2300  
  - A SSTORE occurs after the CALL  
  - The storage slot written by SSTORE is used in some control flow path, indicating potential vulnerability

# Mythril  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving  
- **Reentrancy detection criterion:** Considered reentrant if:  
  - External calls (CALL, DELEGATECALL, CALLCODE) are made with more than 2300 gas  
  - The call target is symbolic or dynamic  
  - A state access (SLOAD, SSTORE, CREATE, CREATE2) occurs after the external call, including read accesses (SLOAD), which are considered risky

# Osiris  
- **Analysis target:** N/A for reentrancy detection  
- **Reentrancy detection:** Discarded because it does not detect reentrancy

# Oyente  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic and symbolic execution combined with SAT solving, using path conditions solved by Z3  
- **Reentrancy detection criterion:** Checks for SSTORE instructions after CALL or CALLCODE instructions on feasible paths. It is somewhat outdated as it checks CALLCODE (ancestor of DELEGATECALL) and some obsolete reentrancy patterns.

# Pakala  
- **Analysis target:** N/A for reentrancy detection  
- **Reentrancy detection:** Not supported (no reentrancy detection implemented)

# Securify  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Syntactic analysis combined with contract call dependency analysis and fact checking via Datalog (Soufflé)  
- **Reentrancy detection criterion:** Detects CALL instructions with the following filters:  
  - Discards CALLs with a constant zero value transfer  
  - Discards CALLs whose gas argument does not have a dataflow dependency on a GAS instruction above in the bytecode  
  Remaining CALLs are flagged as potential reentrancy vulnerabilities.

# Securify2  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Intermediate representation generated from source code  
- **Techniques:** Pattern-based declarative analysis using Datalog rules  
- **Reentrancy detection criterion:** Detects external calls that occur before state updates by matching patterns on the intermediate representation.

# Semgrep  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code  
- **Techniques:** Pattern matching using semgrep rules for known method calls and small syntactic/lexical patterns  
- **Reentrancy detection criterion:** Detects certain ERC-related reentrant calls but does not implement a general detector for real-world reentrant code. It is primarily a general-purpose grep-like tool and is not specialized for Solidity vulnerabilities.

# sFuzz  
- **Analysis target:** N/A (fuzzer, not static analyzer)  
- **Analysis performed on:** Runs attacker contracts on a customized EVM  
- **Techniques:** Fuzzing by generating attacker contracts and executing them  
- **Reentrancy detection:** Not a static analysis tool; supports Solidity up to version 0.4.x

# Slither  
- **Analysis target:** Solidity and Vyper source code  
- **Analysis performed on:** Source code  
- **Techniques:** Pattern-based detection for reentrancy; data flow and control flow analysis for other vulnerabilities  
- **Reentrancy detection criterion:** Detects if a state variable is changed after an external call, indicating a potential reentrancy vulnerability.

# Smartcheck  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code parsed into XML AST using ANTLR for Java, then queried with XPath and regexps  
- **Techniques:** Purely syntactic analysis  
- **Reentrancy detection:** No rules explicitly defined for reentrancy detection, although the original paper mentions them.

# Solhint  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code  
- **Techniques:** Linting rules that warn about potentially risky low-level calls  
- **Reentrancy detection:** Does not detect reentrancy but warns if low-level calls are used, which could be risky.

# teEther  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Symbolic execution combined with SMT solvers  
- **Reentrancy detection criterion:** Detects if an external CALL can be followed by reentering the vulnerable contract before its state is updated by symbolically executing all possible paths.

# Vandal  
- **Analysis target:** EVM bytecode  
- **Analysis performed on:** Bytecode  
- **Techniques:** Symbolic execution to compute jump destinations during bytecode decompilation, combined with pattern-based detection using Datalog queries  
- **Reentrancy detection criterion:** Flags a CALL as reentrant if it forwards sufficient gas and is not protected by a mutex, based on Datalog queries identifying external calls followed by state updates.