/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       EventRecorder.sol
version:    1.0
date:       2019-9-12
author:     Hamish Ivison
            Dominic Romanowski

-----------------------------------------------------------------
CONTRACT DESCRIPTION
-----------------------------------------------------------------

A contract with an owner, that can push arbitrary data to be emitted
as an event.

The intention of this contract is to post a merkle tree root hash of
a group of events, to ensure that data from an external source can
be validated as having not been altered.

-----------------------------------------------------------------
*/
pragma solidity 0.5.12;

/*
-----------------------------------------------------------------
MODULE INFORMATION
-----------------------------------------------------------------

contract:   Owned
version:    1.1
date:       2018-2-26
author:     Anton Jurisevic
            Dominic Romanowski

Auditors: Sigma Prime - https://github.com/sigp/havven-audit

A contract with an owner, to be inherited by other contracts.
Requires its owner to be explicitly set in the constructor.
Provides an onlyOwner access modifier.

To change owner, the current owner must nominate the next owner,
who then has to accept the nomination. The nomination can be
cancelled before it is accepted by the new owner by having the
previous owner change the nomination (setting it to 0).

If the ownership is to be relinquished, then it can be handed
to a smart contract whose only function is to accept that
ownership, which guarantees no owner-only functionality can
ever be invoked.

-----------------------------------------------------------------
*/

/**
 * @title A contract with an owner.
 * @notice Contract ownership is transferred by first nominating the new owner,
 * who must then accept the ownership, which prevents accidental incorrect ownership transfers.
 */


/**
 * @title A contract for recording events.
 */
contract EventRecorder is Owned {

    /**
     * @dev Owned Constructor
     * @param _owner The initial owner of the contract.
     */
    constructor(address _owner) Owned(_owner) public {}

    /**
     * @notice Post arbitrary data to the blockchain.
     */
    function publishEvent(bytes memory data) public onlyOwner {
        emit IglooEvent(data);
    }

    event IglooEvent(bytes eventData);
}

/*
-----------------------------------------------------------------------------
MIT License

Copyright Â© Havven 2018, Igloo 2019.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-----------------------------------------------------------------------------
*/