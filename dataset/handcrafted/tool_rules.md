
In this document we recap for each existing analyzer tool what kind of analysis it performs for Reentrancy.

# Tools included in Smartbugs

### CCC
analyzes Solidity source code (incomplete snippets as well)
pattern based analysis over a Code Property Graph (CPG)

pattern are expressed as queries, specifically the reentrancy pattern is matched if the contract makes an external call before completing its state updates, with the call target or value influenced by user input, and without safeguards or mitigating conditions to prevent reentry.

### ConFuzzius
analyzes bytecode
syntactic + symbolic execution + sat solver + fuzzing

- detects CALLs preceeded by SLOADS and followed by SSTOREs on the same slot
- it is considered reentrant IF:
	- gas >2300 (must be non-symbolic)
	- AND: the money value > 0 OR is symbolic
	- AND: the call target is symbolic
- it is NOT reentrant when: value = 0 OR address is constant

supports EVM down to 2019 (Petersburg)

### Conkas
analyzes bytecode
syntactic + symbolic execution + sat solver

Detects SLOADs before CALL, detects SSTOREs after CALL, produces constraints between loads and stores, uses Z3 as sat solver for detecting dependencies and excluding certain cases

supports Solidity up to 0.6.11

### Ethainter
NO reentrancy

### eThor
analyzes bytecode
abstract interpretation + horn clauses + smt reachability solver

eThor detects reentrancy by checking whether there exists an execution trace in which, after a contract has been reentered, it can still perform another external call.

### HoneyBadger
NO reentrancy

### MadMax
NO reentrancy

### Maian
No reentrancy


### Manticore
analyzes bytecode
syntactic + symbolic execution + sat solver

Detector for reentrancy:
- Given an optional concrete list of attacker addresses, warn on the following conditions.
  - A successful call to an attacker address (address in attacker list), or any human account address (if no list is given). With enough gas (>2300).
  - a SSTORE after the execution of the CALL.
  - the storage slot of the SSTORE must be used in some path to control flow


### Mythril
analyzes bytecode
syntactic + symbolic execution + sat solver

if the following conditions occurs, it is considered reentrant:
- detects these external calls: CALL, DELEGATECALL, CALLCODE
- an external call is made with >2300 gas
- the call target is symbolic or dynamic
- a state access occurs after the external call
	- state accesses are: SLOAD, SSTORE, CREATE, CREATE2
	- this means that read accesses are considered risky!

### Osiris
discarded because it does not etect reentrancy

### Oyente
analyzes bytecode
syntactic + symbolic execution + sat solver

outdated as it checks CALLCODE (ancestor of DELEGATECALL) and some obsolete reentrancy pattern/antipatterns

uses symbolic execution and path conditions, which are predicates marking each statement telling whether that statement can be reached or not and under what assumptions (i.e. what values variables must assume to make the statement reachable)
path conditions become lists of constraints solved by Z3

for detecting reentrancy in particular it checks SSTOREs after CALLs/CALLCODEs. This is a syntactic mechanism that is enhanced by the symbolic execution and the sat solving, restricting case to reachable/feasible paths 

### Pakala
NO reentrancy

### Securify
analyzes bytecode
syntactic + contract call dependence analysis + fact checking
Securify is a java program that parses bytecode and detects potential vulnerabilities via some advanced syntax-based analysis aided by dataflow analysis.
The program produces a .facts file that is the input of Soufflé (a Datalog variant), which completes the detection.

To detected reentrancy, the following criteria are implemented:
- CALL instructions are detected
	- CALLs whose money value is a constant equal to 0 are discarded
	- CALLs whose gas argument does NOT have some dataflow dependency with some GAS instruction above are discarded

### Securify2
analyzes bytecode

pattern-based declarative analysis using Datalog 

Securify2 is a static analysis tool that translates Solidity code into an intermediate representation and then applies Datalog rules to it. Reentrancy is detected when external calls before state updates are matched.


### Semgrep -> todo: UPDATE WITH SECURITY
first of all: semgrep is a general-purpose grep-like tool detecting complex syntactic schemes and has nothing to do with Solidity and vulnerabilities.
rules for detecting vulnerabilities in Solidity have been defined for semgrep 

analyzes source code
uses semgrep for grepping known method calls and small syntactic/lexical patterns that are considered vulnerable
detects a number of ERC-related reentrant calls but does not implement any general detector for real-world reentrant code
should not even be included in smartbugs


### sFuzz
this is not a static analyzer, it's a fuzzer: it generates attacker contracts and runs them on a customized evm
supports Solidity up to 0.4.x

### Slither
analyzes source code, both solidity and vyper

for reentrancy detection it uses a pattern based detector, for other vulnerabilities uses data flow analysis or control flow analysis
the pattern checks if is state variable changes after a call

### Smartcheck
analyzes source code
uses ANTLR for Java and produces a XML AST, then performs queries on the tree using XPath and regexps - it is a purely syntactic tool.
in the implementation there are no rules define for detecting reentrancy, though the paper mentions them.


### Solhint
NO reentrancy, it only warns the programmer if it is using a low level call as a potential risk.

### teEther
analyzes bytecode

symbolic execution + SMT solvers

TeEther symbolically executes EVM bytecode to search for execution paths that leak Ether, and then automatically generates concrete exploit transactions.
In case of reentrancy, it uses symbolic execution to detect if an external CALL can be followed by reentering the vulnerable contract before its state is updated.

### Vandal
analyzes bytecode

symbolic execution to comupte jump destinations when decompiling bytecode + pattern based reentrancy detection

Vandal detects reentrancy by running Datalog queries over a model of EVM bytecode to identify external calls followed by state updates.
From their paper: a CALL is flagged as reentrant if it forwards sufficient gas and is not protected by a mutex.



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

