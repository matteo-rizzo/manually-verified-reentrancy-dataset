pragma solidity ^0.4.11;





contract Utils {
    string constant public contract_version = "0.1._";
    /// @notice Check if a contract exists
    /// @param channel The address to check whether a contract is deployed or not
    /// @return True if a contract exists, false otherwise
    function contractExists(address channel) constant returns (bool) {
        uint size;

        assembly {
            size := extcodesize(channel)
        }

        return size > 0;
    }
}






contract NettingChannelContract {
    string constant public contract_version = "0.1._";

    using NettingChannelLibrary for NettingChannelLibrary.Data;
    NettingChannelLibrary.Data public data;

    event ChannelNewBalance(address token_address, address participant, uint balance, uint block_number);
    event ChannelClosed(address closing_address, uint block_number);
    event TransferUpdated(address node_address, uint block_number);
    event ChannelSettled(uint block_number);
    event ChannelSecretRevealed(bytes32 secret, address receiver_address);

    modifier settleTimeoutNotTooLow(uint t) {
        assert(t >= 6);
        _;
    }

    function NettingChannelContract(
        address token_address,
        address participant1,
        address participant2,
        uint timeout)
        settleTimeoutNotTooLow(timeout)
    {
        require(participant1 != participant2);

        data.participants[0].node_address = participant1;
        data.participants[1].node_address = participant2;
        data.participant_index[participant1] = 1;
        data.participant_index[participant2] = 2;

        data.token = Token(token_address);
        data.settle_timeout = timeout;
        data.opened = block.number;
    }

    /// @notice Caller makes a deposit into their channel balance.
    /// @param amount The amount caller wants to deposit.
    /// @return True if deposit is successful.
    function deposit(uint256 amount) returns (bool) {
        bool success;
        uint256 balance;

        (success, balance) = data.deposit(amount);

        if (success == true) {
            ChannelNewBalance(data.token, msg.sender, balance, block.number);
        }

        return success;
    }

    /// @notice Get the address and balance of both partners in a channel.
    /// @return The address and balance pairs.
    function addressAndBalance()
        constant
        returns (
        address participant1,
        uint balance1,
        address participant2,
        uint balance2)
    {
        NettingChannelLibrary.Participant storage node1 = data.participants[0];
        NettingChannelLibrary.Participant storage node2 = data.participants[1];

        participant1 = node1.node_address;
        balance1 = node1.balance;
        participant2 = node2.node_address;
        balance2 = node2.balance;
    }

    /// @notice Close the channel. Can only be called by a participant in the channel.
    function close(
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    ) {
        data.close(
            nonce,
            transferred_amount,
            locksroot,
            extra_hash,
            signature
        );
        ChannelClosed(msg.sender, data.closed);
    }

    /// @notice Dispute the state after closing, called by the counterparty (the
    ///         participant who did not close the channel).
    function updateTransfer(
        uint64 nonce,
        uint256 transferred_amount,
        bytes32 locksroot,
        bytes32 extra_hash,
        bytes signature
    ) {
        data.updateTransfer(
            nonce,
            transferred_amount,
            locksroot,
            extra_hash,
            signature
        );
        TransferUpdated(msg.sender, block.number);
    }

    /// @notice Unlock a locked transfer.
    /// @param locked_encoded The locked transfer to be unlocked.
    /// @param merkle_proof The merke_proof for the locked transfer.
    /// @param secret The secret to unlock the locked transfer.
    function withdraw(bytes locked_encoded, bytes merkle_proof, bytes32 secret) {
        // throws if sender is not a participant
        data.withdraw(locked_encoded, merkle_proof, secret);
        ChannelSecretRevealed(secret, msg.sender);
    }

    /// @notice Settle the transfers and balances of the channel and pay out to
    ///         each participant. Can only be called after the channel is closed
    ///         and only after the number of blocks in the settlement timeout
    ///         have passed.
    function settle() {
        data.settle();
        ChannelSettled(data.settled);
    }

    /// @notice Returns the number of blocks until the settlement timeout.
    /// @return The number of blocks until the settlement timeout.
    function settleTimeout() constant returns (uint) {
        return data.settle_timeout;
    }

    /// @notice Returns the address of the token.
    /// @return The address of the token.
    function tokenAddress() constant returns (address) {
        return data.token;
    }

    /// @notice Returns the block number for when the channel was opened.
    /// @return The block number for when the channel was opened.
    function opened() constant returns (uint) {
        return data.opened;
    }

    /// @notice Returns the block number for when the channel was closed.
    /// @return The block number for when the channel was closed.
    function closed() constant returns (uint) {
        return data.closed;
    }

    /// @notice Returns the block number for when the channel was settled.
    /// @return The block number for when the channel was settled.
    function settled() constant returns (uint) {
        return data.settled;
    }

    /// @notice Returns the address of the closing participant.
    /// @return The address of the closing participant.
    function closingAddress() constant returns (address) {
        return data.closing_address;
    }

    function () { revert(); }
}



// for each token a manager will be deployed, to reduce gas usage for manager
// deployment the logic is moved into a library and this contract will work
// only as a proxy/state container.
contract ChannelManagerContract is Utils {
    string constant public contract_version = "0.1._";

    using ChannelManagerLibrary for ChannelManagerLibrary.Data;
    ChannelManagerLibrary.Data data;

    event ChannelNew(
        address netting_channel,
        address participant1,
        address participant2,
        uint settle_timeout
    );

    event ChannelDeleted(
        address caller_address,
        address partner
    );

    function ChannelManagerContract(address token_address) {
        data.token = Token(token_address);
    }

    /// @notice Get all channels
    /// @return All the open channels
    function getChannelsAddresses() constant returns (address[]) {
        return data.all_channels;
    }

    /// @notice Get all participants of all channels
    /// @return All participants in all channels
    function getChannelsParticipants() constant returns (address[]) {
        uint i;
        uint pos;
        address[] memory result;
        NettingChannelContract channel;

        uint open_channels_num = 0;
        for (i = 0; i < data.all_channels.length; i++) {
            if (contractExists(data.all_channels[i])) {
                open_channels_num += 1;
            }
        }
        result = new address[](open_channels_num * 2);

        pos = 0;
        for (i = 0; i < data.all_channels.length; i++) {
            if (!contractExists(data.all_channels[i])) {
                continue;
            }
            channel = NettingChannelContract(data.all_channels[i]);

            var (address1, , address2, ) = channel.addressAndBalance();

            result[pos] = address1;
            pos += 1;
            result[pos] = address2;
            pos += 1;
        }

        return result;
    }

    /// @notice Get all channels that an address participates in.
    /// @param node_address The address of the node
    /// @return The channel&#39;s addresses that node_address participates in.
    function nettingContractsByAddress(address node_address) constant returns (address[]) {
        return data.nodeaddress_to_channeladdresses[node_address];
    }

    /// @notice Get the address of the channel token
    /// @return The token
    function tokenAddress() constant returns (address) {
        return data.token;
    }

    /// @notice Get the address of channel with a partner
    /// @param partner The address of the partner
    /// @return The address of the channel
    function getChannelWith(address partner) constant returns (address) {
        return data.getChannelWith(partner);
    }

    /// @notice Create a new payment channel between two parties
    /// @param partner The address of the partner
    /// @param settle_timeout The settle timeout in blocks
    /// @return The address of the newly created NettingChannelContract.
    function newChannel(address partner, uint settle_timeout) returns (address) {
        address old_channel = getChannelWith(partner);
        if (old_channel != 0) {
            ChannelDeleted(msg.sender, partner);
        }

        address new_channel = data.newChannel(partner, settle_timeout);
        ChannelNew(new_channel, msg.sender, partner, settle_timeout);
        return new_channel;
    }

    function () { revert(); }
}

contract Registry {
    string constant public contract_version = "0.1._";

    mapping(address => address) public registry;
    address[] public tokens;

    event TokenAdded(address token_address, address channel_manager_address);

    modifier addressExists(address _address) {
        require(registry[_address] != 0x0);
        _;
    }

    modifier doesNotExist(address _address) {
        // Check if it&#39;s already registered or token contract is invalid.
        // We assume if it has a valid totalSupply() function it&#39;s a valid Token contract
        require(registry[_address] == 0x0);
        Token token = Token(_address);
        token.totalSupply();
        _;
    }

    /// @notice Register a new ERC20 token
    /// @param token_address Address of the token
    /// @return The address of the channel manager
    function addToken(address token_address)
        doesNotExist(token_address)
        returns (address)
    {
        address manager_address;

        manager_address = new ChannelManagerContract(token_address);

        registry[token_address] = manager_address;
        tokens.push(token_address);

        TokenAdded(token_address, manager_address);

        return manager_address;
    }

    /// @notice Get the ChannelManager address for a specific token
    /// @param token_address The address of the given token
    /// @return Address of channel manager
    function channelManagerByToken(address token_address)
        addressExists(token_address)
        constant
        returns (address)
    {
        return registry[token_address];
    }

    /// @notice Get all registered tokens
    /// @return addresses of all registered tokens
    function tokenAddresses()
        constant
        returns (address[])
    {
        return tokens;
    }

    /// @notice Get the addresses of all channel managers for all registered tokens
    /// @return addresses of all channel managers
    function channelManagerAddresses()
        constant
        returns (address[])
    {
        uint i;
        address token_address;
        address[] memory result;

        result = new address[](tokens.length);

        for (i = 0; i < tokens.length; i++) {
            token_address = tokens[i];
            result[i] = registry[token_address];
        }

        return result;
    }

    function () { revert(); }
}