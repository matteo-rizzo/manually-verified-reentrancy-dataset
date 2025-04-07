/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.24;



contract Time {

  using DateTime for uint;



  function getDate(uint time) public view returns(string) {

    uint year = time.getYear();

    uint month = time.getMonth();

    uint day = time.getDay();



    if(month < 10) {

      string memory _month = Utils.strConcat(Utils.uint2str(0), Utils.uint2str(month));

    } else {

      _month = Utils.uint2str(month);

    }



    if(day < 10) {

      string memory _day = Utils.strConcat("0", Utils.uint2str(day));

    }else{

      _day = Utils.uint2str(day);

    }



    return Utils.strConcat(Utils.uint2str(year), _month, _day);

  }



  function getTime(uint time) public view returns(string) {

    uint hour = time.parseTimestamp().hour;

    uint minute = time.parseTimestamp().minute;

    uint second = time.parseTimestamp().second;



    if(hour < 10) {

      string memory _hour = Utils.strConcat(Utils.uint2str(0), Utils.uint2str(hour));

    } else {

      _hour = Utils.uint2str(hour);

    }



    if(minute < 10) {

      string memory _minute = Utils.strConcat("0", Utils.uint2str(minute));

    }else{

      _minute = Utils.uint2str(minute);

    }



    if(second < 10) {

      string memory _second = Utils.strConcat("0", Utils.uint2str(second));

    }else{

      _second = Utils.uint2str(second);

    }



    return Utils.strConcat(_hour, _minute,_second);

  }



}



//////////////////////////////////////////////////







//////////////////////////////////////////////////











//////////////////////////////////////////////////