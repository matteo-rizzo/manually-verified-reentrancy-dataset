pragma solidity ^0.4.21;







contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract ERC20Compatible {
    function transferFrom(address from, address to, uint256 value) public;
    function transfer(address to, uint256 value) public;
}

contract Mixer {
    using LinkableRing for LinkableRing.Data;

    struct Data {
        bytes32 guid;
        uint256 denomination;
        address token;
        LinkableRing.Data ring;
    }

    mapping(bytes32 => Data) internal m_rings;
    mapping(uint256 => bytes32) internal m_pubx_to_ring;
    mapping(bytes32 => bytes32) internal m_filling;
    
    uint256 internal m_ring_ctr;

    event LogMixerDeposit(bytes32 indexed ring_id,uint256 indexed pub_x,address token,uint256 value);
    event LogMixerWithdraw(bytes32 indexed ring_id,uint256 tag_x,address token,uint256 value);
    event LogMixerReady(bytes32 indexed ring_id, bytes32 message);
    event LogMixerDead(bytes32 indexed ring_id);

    function () public {
        revert();
    }

    function message(bytes32 ring_guid) public view returns (bytes32)
    {
        Data storage entry = m_rings[ring_guid];
        LinkableRing.Data storage ring = entry.ring;
        require(0 != entry.denomination);
        return ring.message();
    }

    function depositEther(address token, uint256 denomination, uint256 pub_x, uint256 pub_y) public payable returns (bytes32)
    {
        require(token == 0);
        require(denomination == msg.value);
        bytes32 ring_guid = depositLogic(token, denomination, pub_x, pub_y);
        return ring_guid;
    }

    function depositERC20Compatible(address token, uint256 denomination, uint256 pub_x, uint256 pub_y) public returns (bytes32)
    {
        uint256 codeLength;
        assembly {
            codeLength := extcodesize(token)
        }

        require(token != 0 && codeLength > 0);
        bytes32 ring_guid = depositLogic(token, denomination, pub_x, pub_y);
        ERC20Compatible untrustedErc20Token = ERC20Compatible(token);
        untrustedErc20Token.transferFrom(msg.sender, this, denomination);
        return ring_guid;
    }

    function withdrawEther(bytes32 ring_id, uint256 tag_x, uint256 tag_y, uint256[] ctlist) public returns (bool)
    {
        Data memory entry = withdrawLogic(ring_id, tag_x, tag_y, ctlist);
        msg.sender.transfer(entry.denomination);
        return true;
    }

    function withdrawERC20Compatible(bytes32 ring_id, uint256 tag_x, uint256 tag_y, uint256[] ctlist) public returns (bool)
    {
        Data memory entry = withdrawLogic(ring_id, tag_x, tag_y, ctlist);
        ERC20Compatible untrustedErc20Token = ERC20Compatible(entry.token);
        untrustedErc20Token.transfer(msg.sender, entry.denomination);
        return true;
    }

    function lookupFillingRing(address token, uint256 denomination) internal returns (bytes32, Data storage)
    {
        bytes32 filling_id = sha256(token, denomination);
        bytes32 ring_guid = m_filling[filling_id];
        if(ring_guid != 0) {
            return (filling_id, m_rings[ring_guid]);
        }
        ring_guid = sha256(address(this), m_ring_ctr, filling_id);
        Data storage entry = m_rings[ring_guid];
        require(0 == entry.denomination);
        require(entry.ring.initialize(ring_guid));
        entry.guid = ring_guid;
        entry.token = token;
        entry.denomination = denomination;
        m_ring_ctr += 1;
        m_filling[filling_id] = ring_guid;
        return (filling_id, entry);
    }

    function depositLogic(address token, uint256 denomination, uint256 pub_x, uint256 pub_y)
        internal returns (bytes32)
    {
        require(denomination != 0 && 0 == (denomination & (denomination - 1)));
        require(0 == uint256(m_pubx_to_ring[pub_x]));
        bytes32 filling_id;
        Data storage entry;
        (filling_id, entry) = lookupFillingRing(token, denomination);
        LinkableRing.Data storage ring = entry.ring;
        require(ring.addParticipant(pub_x, pub_y));
        bytes32 ring_guid = entry.guid;
        m_pubx_to_ring[pub_x] = ring_guid;
        emit LogMixerDeposit(ring_guid, pub_x, token, denomination);
        if(ring.isFull()) {
            delete m_filling[filling_id];
            emit LogMixerReady(ring_guid, ring.message());
        }
        return ring_guid;
    }

    function withdrawLogic(bytes32 ring_id, uint256 tag_x, uint256 tag_y, uint256[] ctlist)
        internal returns (Data)
    {
        Data storage entry = m_rings[ring_id];
        LinkableRing.Data storage ring = entry.ring;
        require(0 != entry.denomination);
        require(ring.isFull());
        require(ring.isSignatureValid(tag_x, tag_y, ctlist));
        ring.tagAdd(tag_x);
        emit LogMixerWithdraw(ring_id, tag_x, entry.token, entry.denomination);
        Data memory entrySaved = entry;
        if(ring.isDead()) {
            for(uint i = 0; i < ring.pubkeys.length; i++) {
                delete m_pubx_to_ring[ring.pubkeys[i].X];
            }
            delete m_rings[ring_id];
            emit LogMixerDead(ring_id);
        }
        return entrySaved;
    }
}
//This project was developed by Apolo Blockchain Technologies LLC - HA08-07C23-10V26-02 - CD10-05A29-09F10-08