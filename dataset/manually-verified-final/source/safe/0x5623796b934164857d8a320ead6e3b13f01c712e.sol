contract CARBONTRAIL_OPESTA {

    event OPESTA(

        bytes32 client_full, 

        bytes32 address_full,

        bytes32 pro,

        address declared_by,

        address declared_for,

        uint nature_bon,

        uint status,

        bytes32 reference_interne,

        bytes32 fiche,

        uint volumekWh,

        uint date_engagement,

        uint date_facture,

        uint timestamp,

        uint block

    );

    function newOPESTA(bytes32 client_full, bytes32 address_full, bytes32 pro, address declared_for, uint nature_bon, uint status, bytes32 reference_interne, bytes32 fiche, uint volumekWh, uint date_engagement, uint date_facture) public  {

        emit OPESTA(client_full, address_full, pro, msg.sender, declared_for, nature_bon, status, reference_interne, fiche, volumekWh, date_engagement, date_facture, block.timestamp, block.number);

    }

    event UOPESTA(

        bytes32 client_full, 

        bytes32 address_full,

        bytes32 pro,

        address declared_by,

        address declared_for,

        uint nature_bon,

        uint status,

        bytes32 reference_interne,

        bytes32 fiche,

        uint volumekWh,

        uint date_engagement,

        uint date_facture,

        uint timestamp,

        uint block

    );

    function updateOPESTA(bytes32 client_full, bytes32 address_full, bytes32 pro, address declared_for, uint nature_bon, uint status, bytes32 reference_interne, bytes32 fiche, uint volumekWh, uint date_engagement, uint date_facture) public  {

        emit UOPESTA(client_full, address_full, pro, msg.sender, declared_for, nature_bon, status, reference_interne, fiche, volumekWh, date_engagement, date_facture, block.timestamp, block.number);

    }

}
