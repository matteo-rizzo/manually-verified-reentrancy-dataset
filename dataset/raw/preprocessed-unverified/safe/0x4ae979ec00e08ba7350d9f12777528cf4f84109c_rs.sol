pragma solidity ^0.4.19;





contract Cornholio
{
    address public farmer = 0x231F702070aACdbde867B323996A96Fed8aDCA10;
    
    function sowCorn(address soil, uint8 seeds) external
    {
        for(uint8 i = 0; i < seeds; ++i)
        {
            CornFarm(soil).buyObject(this);
        }
    }
    
    function reap(address corn) external
    {
        Corn(corn).transfer(farmer, Corn(corn).balanceOf(this));
    }
}