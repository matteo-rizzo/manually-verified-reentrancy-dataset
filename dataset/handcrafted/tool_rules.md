In this document we recap for each existing analyzer tool what kind of analysis it performs for Reentrancy.

# Tools included in Smartbugs

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
- **Reentrancy types detected:** Single-function reentrancy

# Solhint  
- **Analysis target:** Solidity source code  
- **Analysis performed on:** Source code  
- **Techniques:** Linting rules that warn about potentially risky low-level calls  
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



# Tools *not* included in Smartbugs

### Aderyn

This tool seems pretty used and second to Slither only. It does not have a paper though.

Repo: https://github.com/Cyfrin/aderyn
Site: https://cyfrin.gitbook.io/cyfrin-docs/aderyn-cli/installation

Written in Rust, it analyzes a wide number of Solidity vulnerabilities and supports programmable detectors (written in Rust ofc). Detectors have access to the AST, thus it is merely syntactic in nature. 
The reentrancy-related builtin detectors seem limited to:
- State change after external call (CEI violations)
- Unchecked Low level calls
- OpenZeppelin `nonReentrant` modifier occurs *for all* functions and stands *before* any other modifier

*NOTE*: the documentation does not show all reentrancy-related detectors. In other words, running the tool detects more reentrancy-related issues than documented.

The tool is well maintained and has an excellent CLI, report format and general quality, despite it does nothing truly special about reentrancy.

*OVERALL*: already tried, consider its inclusion in the paper.



### AutoAR

Paper: https://www.ndss-symposium.org/wp-content/uploads/2025-167-paper.pdf
Repo: https://github.com/h0tak88r/AutoAR

It is a generic tool that works through a local REST API server written in Python.
It is well maintained also nowadays.

*OVERALL*: the doc on github is totally out of sync with the actual content of the repo. Cannot understand how to lauch it properly. 


### Sailfish

https://github.com/ucsb-seclab/sailfish




### TotalSol

Paper: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10990789





### Sereum

Repo: https://github.com/uni-due-syssec/eth-reentrancy-attack-patterns
Paper: https://www.ndss-symposium.org/wp-content/uploads/2019/02/ndss2019_09-3_Rodler_paper.pdf 

The tool is *unmaintained* and its last release dates back to 2018.

It is essentially a runtime monitoring system that detects SSTORE instructions (effects) and *write-locks* memory locations in such a way that, once execution returns from reentrant calls, the system detects a violation.

*OVERALL*: do not include this tool, it's too old.


### DefectChecker

Paper: https://ieeexplore.ieee.org/abstract/document/9337195

The defectChecker tool takes bytecodes as input, disassembles them into opcodes, splits the opcodes into several basic blocks and symbolically executes instructions in each block.
Then it generates the control flow graph (CFG) and records all stack events.
Using CFG and stack events information, it detects three pre-defined features: 
- money call
- loop block 
- payable function

After feature detection, it applies rules to detect eight vulnerabilities: 
- transaction state dependency
- DoS under external influence
- strict balance equality
- *reentrancy*
- nested call
- greedy contract
- *unchecked external calls*
- block info dependency.

*OVERALL*: try this.

### ContractWard

Paper: https://ieeexplore.ieee.org/abstract/document/8967006

This is the official description, but it's unclear:
"The contractWard applies supervised learning to find vulnerabilities. It extracts 1619 dimensional bigram features from opcodes using an n-gram algorithm and forms a feature space. 
Then it labels contracts in training set with six types of vulnerabilities *using Oyente*. The label is stored in a six-dimension vector (e.g., [1 0 1 0 1 1]) where each bit stands for an existing vulnerability. Based on the feature space and labels of the training set, contractWard uses five classification algorithms to detect vulnerabilities."

*OVERALL*: based on Oyente, perhaps it's worth trying.


### NPChecker

Paper: https://dl.acm.org/doi/abs/10.1145/3360615

This tool analyzes the non-determinism in the smart-contract execution context and then performs systematic modelling to expose various non-deterministic factors in the contract execution context [46]. Non-deterministic factors are factors that could impact final results to the end-user and make them unforeseeable. Possible factors discussed in NPChecker are block and transaction state, transaction execution scheduling, and external callee. The NPChecker disassembles the EVM bytecode and translates them into LLVM intermediate representation (IR) code [96], recovers the control flow structures and enhances the LLVM IR with function information, identifies state and global variables, and performs information-flow tracking to analyze their influences on the fund’s transfer.

*OVERALL*: based on Oyente, perhaps it's worth trying.



### eBurger




### Gas Gauge

Detects only gas usage. Consider it for detecting some forms reentrancy.

