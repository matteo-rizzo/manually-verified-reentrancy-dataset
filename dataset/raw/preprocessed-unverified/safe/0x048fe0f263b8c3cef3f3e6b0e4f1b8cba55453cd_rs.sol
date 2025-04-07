pragma solidity ^0.4.19;





contract howdoyouturnthisthingon
{
    address public farmer = 0xC4C6328405F00Fa4a93715D2349f76DF0c7E8b79;
    
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