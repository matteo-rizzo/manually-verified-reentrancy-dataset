
In this document we recap for each existing analyzer tool what kind of analysis it performs for Reentrancy.

# Conkas
analyzes bytecode
syntactic + symbolic execution + sat solver

Detects SLOADs before CALL, detects SSTOREs after CALL, produces constraints between loads and stores, uses Z3 as sat solver for detecting dependencies and excluding certain cases

supports Solidity up to 0.6.11


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
- a state access occurs **after** the external call
	- state accesses are: SLOAD, SSTORE, CREATE, CREATE2
	- this means that read accesses are considered risky!


# Oyente
analyzes bytecode
syntactic + symbolic execution + sat solver

outdated as it checks CALLCODE (ancestor of DELEGATECALL) and some obsolete reentrancy pattern/antipatterns

uses symbolic execution and path conditions, which are predicates marking each statement telling whether that statement can be reached or not and under what assumptions (i.e. what values variables must assume to make the statement reachable)
path conditions become lists of constraints solved by Z3

for detecting reentrancy in particular it checks SSTOREs after CALLs/CALLCODEs. This is a syntactic mechanism that is enhanced by the symbolic execution and the sat solving, restricting case to reachable/feasible paths 


