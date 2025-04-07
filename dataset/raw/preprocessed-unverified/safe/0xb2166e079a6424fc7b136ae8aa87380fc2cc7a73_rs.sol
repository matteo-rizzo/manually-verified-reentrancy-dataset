pragma solidity ^0.5.0;

//When the great leader arrives, he shall transfer $MAIZ from this contract to three LP pools.





contract MAIZkeeper {
    function transferToPool(address pool) public{
        MAIZ maizetoken = MAIZ(0x9b42c461E4397D7880dAb88c8bB3D3cfC94b353A);
        MAIZLPPool LPpool = MAIZLPPool(pool);
        require (msg.sender == maizetoken.owner());
        require (block.timestamp > 1599494400); //08/Sept/2020 00:00:00 (UTC+0) 
        require (LPpool.starttime() == 1599494400);
        require (LPpool.yam() == 0x9b42c461E4397D7880dAb88c8bB3D3cfC94b353A);
        maizetoken.transfer(pool, 5e22);
    }
}