/*
 * Written by Jesse Busman (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dbb2b5bdb49bb1bea8b9aea8f5b8b4b6">[email&#160;protected]</a>) on 2017-11-30.
 * This software is provided as-is without warranty of any kind, express or implied.
 * This software is provided without any limitation to use, copy modify or distribute.
 * The user takes sole and complete responsibility for the consequences of this software&#39;s use.
 * Github repository: https://github.com/JesseBusman/SoliditySet
 */

pragma solidity ^0.4.18;



contract SetUsageExample
{
    using SetLibrary for SetLibrary.Set;
    
    SetLibrary.Set private numberCollection;
    
    function addNumber(uint256 number) external
    {
        numberCollection.add(number);
    }
    
    function removeNumber(uint256 number) external
    {
        numberCollection.remove(number);
    }
    
    function getSize() external view returns (uint256 size)
    {
        return numberCollection.size();
    }
    
    function containsNumber(uint256 number) external view returns (bool contained)
    {
        return numberCollection.contains(number);
    }
    
    function getNumberAtIndex(uint256 index) external view returns (uint256 number)
    {
        return numberCollection.values[index];
    }
}