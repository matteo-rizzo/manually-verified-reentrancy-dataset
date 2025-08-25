
In this document we recap for each existing analyzer tool what kind of analysis it performs for Reentrancy.

# ConFuzzius
analyzes bytecode
syntactic + symbolic execution + sat solver + fuzzing

- detects CALLs preceeded by SLOADS and followed by SSTOREs on the same slot
- it is considered reentrant IF:
	- gas >2300 (must be non-symbolic)
	- AND: the money value > 0 OR is symbolic
	- AND: the call target is symbolic
- it is NOT reentrant when: value = 0 OR address is constant

supports EVM down to 2019 (Petersburg)

# Conkas
analyzes bytecode
syntactic + symbolic execution + sat solver

Detects SLOADs before CALL, detects SSTOREs after CALL, produces constraints between loads and stores, uses Z3 as sat solver for detecting dependencies and excluding certain cases

supports Solidity up to 0.6.11

# Ethainter
todo

# eThor
todo

# HoneyBadger
todo?

# MadMax
todo

# Maian
todo


# Manticore
analyzes bytecode
syntactic + symbolic execution + sat solver

Detector for reentrancy:
- Given an optional concrete list of attacker addresses, warn on the following conditions.
  - A successful call to an attacker address (address in attacker list), or any human account address (if no list is given). With enough gas (>2300).
  - a SSTORE after the execution of the CALL.
  - the storage slot of the SSTORE must be used in some path to control flow


# Mythril
analyzes bytecode
syntactic + symbolic execution + sat solver

if the following conditions occurs, it is considered reentrant:
- detects these external calls: CALL, DELEGATECALL, CALLCODE
- an external call is made with >2300 gas
- the call target is symbolic or dynamic
- a state access occurs after the external call
	- state accesses are: SLOAD, SSTORE, CREATE, CREATE2
	- this means that read accesses are considered risky!

# Osiris
discarded because it does not etect reentrancy

# Oyente
analyzes bytecode
syntactic + symbolic execution + sat solver

outdated as it checks CALLCODE (ancestor of DELEGATECALL) and some obsolete reentrancy pattern/antipatterns

uses symbolic execution and path conditions, which are predicates marking each statement telling whether that statement can be reached or not and under what assumptions (i.e. what values variables must assume to make the statement reachable)
path conditions become lists of constraints solved by Z3

for detecting reentrancy in particular it checks SSTOREs after CALLs/CALLCODEs. This is a syntactic mechanism that is enhanced by the symbolic execution and the sat solving, restricting case to reachable/feasible paths 

# Pakala
todo


# Securify
analyzes bytecode
syntactic + contract call dependence analysus + fact checking
Securify is a java program that parses bytecode and detects potential vulnerabilities via some advanced syntax-based analysis aided by dataflow analysis.
The program produces a .facts file that is the input of Soufflé (a Datalog variant), which completes the detection.

To detected reentrancy, the following criteria are implemented:
- CALL instructions are detected
	- CALLs whose money value is a constant equal to 0 are discarded
	- CALLs whose gas argument does NOT have some dataflow dependency with some GAS instruction above are discarded

# Securify2
	



# Semgrep -> todo: UPDATE WITH SECURITY
first of all: semgrep is a general-purpose grep-like tool detecting complex syntactic schemes and has nothing to do with Solidity and vulnerabilities.
rules for detecting vulnerabilities in Solidity have been defined for semgrep 

analyzes source code
uses semgrep for grepping known method calls and small syntactic/lexical patterns that are considered vulnerable
detects a number of ERC-related reentrant calls but does not implement any general detector for real-world reentrant code
should not even be included in smartbugs


# sFuzz
this is not a static analyzer, it's a fuzzer: it generates attacker contracts and runs them on a customized evm
supports Solidity up to 0.4.x

# Slither
todo

# Smartcheck
analyzes source code
uses ANTLR for Java and produces a XML AST, then performs queries on the tree using XPath and regexps - it is a purely syntactic tool.
in the implementation there are no rules define for detecting reentrancy, though the paper mentions them.


# Solhint
todo


# teEther
todo



# Vandal
todo