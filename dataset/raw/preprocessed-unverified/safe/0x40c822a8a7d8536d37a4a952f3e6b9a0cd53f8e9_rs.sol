/**
 *Submitted for verification at Etherscan.io on 2021-02-26
*/

pragma solidity ^0.8.0;


// It is not actually an interface regarding solidity because interfaces can only have external functions
abstract contract DepositLockerInterface {
    function slash(address _depositorToBeSlashed) public virtual;
}

/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */



/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */



/*
 * @author Hamdi Allam [emailÂ protected]
 * Please reach out with any questions or concerns
 *
 * Copyright 2018 Hamdi Allam
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/**
    Taken from https://github.com/hamdiallam/Solidity-RLP/blob/cd39a6a5d9ddc64eb3afedb3b4cda08396c5bfc5/contracts/RLPReader.sol
    with small modifications
 */



/**
 * Utilities to verify equivocating behavior of validators.
 */



contract ValidatorSlasher is Ownable {
    bool public initialized = false;
    DepositLockerInterface public depositContract;

    fallback() external {}

    function init(address _depositContractAddress) external onlyOwner {
        require(!initialized, "The contract is already initialized.");

        depositContract = DepositLockerInterface(_depositContractAddress);

        initialized = true;
    }

    /**
     * Report a malicious validator for having equivocated.
     * The reporter must provide the both blocks with their related signature.
     * By the given blocks, the equivocation will be verified.
     * In case a equivocation could been proven, the issuer of the blocks get
     * removed from the set of validators, if his address is registered. Also
     * his deposit will be slashed afterwards.
     * In case any check before removing the malicious validator fails, the
     * whole report procedure fails due to that.
     *
     * @param _rlpUnsignedHeaderOne   the RLP encoded header of the first block
     * @param _signatureOne           the signature related to the first block
     * @param _rlpUnsignedHeaderTwo   the RLP encoded header of the second block
     * @param _signatureTwo           the signature related to the second block
     */
    function reportMaliciousValidator(
        bytes calldata _rlpUnsignedHeaderOne,
        bytes calldata _signatureOne,
        bytes calldata _rlpUnsignedHeaderTwo,
        bytes calldata _signatureTwo
    ) external {
        EquivocationInspector.verifyEquivocationProof(
            _rlpUnsignedHeaderOne,
            _signatureOne,
            _rlpUnsignedHeaderTwo,
            _signatureTwo
        );

        // Since the proof has already verified, that both blocks have been
        // issued by the same validator, it doesn't matter which one is used here
        // to recover the address.
        address validator =
            EquivocationInspector.getSignerAddress(
                _rlpUnsignedHeaderOne,
                _signatureOne
            );

        depositContract.slash(validator);
    }
}

// SPDX-License-Identifier: MIT