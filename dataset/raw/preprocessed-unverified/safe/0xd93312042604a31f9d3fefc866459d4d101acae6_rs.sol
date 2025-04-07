/**

 *Submitted for verification at Etherscan.io on 2018-08-18

*/



/**

 * Copyright (C) 2017-2018 Hashfuture Inc. All rights reserved.

 */



pragma solidity ^0.4.22;



/**

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[emailÂ protected]>

 */





contract owned {

    address public holder;



    constructor() public {

        holder = msg.sender;

    }



    modifier onlyHolder {

        require(msg.sender == holder, "This function can only be called by holder");

        _;

    }

}



contract asset is owned {

    using strings for *;



    /**

    * Asset Struct

    */

    struct data {

        //link URL of the original information for storing data

        //     null means undisclosed

        string link;

        //The encryption method of the original data, such as SHA-256

        string encryptionType;

        //Hash value

        string hashValue;

    }



    data[] dataArray;

    uint dataNum;



    //The validity of the contract

    bool public isValid;

    

    //The init status

    bool public isInit;

    

    //The tradeable status of asset

    bool public isTradeable;

    uint public price;



    //Some notes

    string public remark1;



    //Other notes, holder can be written

    //Reservations for validation functions

    string public remark2;



    /** constructor */

    constructor() public {

        isValid = true;

        isInit = false;

        isTradeable = false;

        price = 0;

        dataNum = 0;

    }



    /**

     * Initialize a new asset

     * @param dataNumber The number of data array

     * @param linkSet The set of URL of the original information for storing data, empty means undisclosed

     *          needle is " "

     * @param encryptionTypeSet The set of encryption method of the original data, such as SHA-256

     *          needle is " "

     * @param hashValueSet The set of hashvalue

     *          needle is " "

     */

    function initAsset(

        uint dataNumber,

        string linkSet,

        string encryptionTypeSet,

        string hashValueSet) public onlyHolder {

        // split string to array

        var links = linkSet.toSlice();

        var encryptionTypes = encryptionTypeSet.toSlice();

        var hashValues = hashValueSet.toSlice();

        var delim = " ".toSlice();

        

        dataNum = dataNumber;

        

        // after init, the initAsset function cannot be called

        require(isInit == false, "The contract has been initialized");



        //check data

        require(dataNumber >= 1, "Param dataNumber smaller than 1");

        require(dataNumber - 1 == links.count(delim), "Param linkSet invalid");

        require(dataNumber - 1 == encryptionTypes.count(delim), "Param encryptionTypeSet invalid");

        require(dataNumber - 1 == hashValues.count(delim), "Param hashValueSet invalid");

        

        isInit = true;

        

        var empty = "".toSlice();

        

        for (uint i = 0; i < dataNumber; i++) {

            var link = links.split(delim);

            var encryptionType = encryptionTypes.split(delim);

            var hashValue = hashValues.split(delim);

            

            //require data not null

            // link can be empty

            require(!encryptionType.empty(), "Param encryptionTypeSet data error");

            require(!hashValue.empty(), "Param hashValueSet data error");

            

            dataArray.push(

                data(link.toString(), encryptionType.toString(), hashValue.toString())

                );

        }

    }

    

     /**

     * Get base asset info

     */

    function getAssetBaseInfo() public view returns (uint _price,

                                                 bool _isTradeable,

                                                 uint _dataNum,

                                                 string _remark1,

                                                 string _remark2) {

        require(isValid == true, "contract invaild");

        _price = price;

        _isTradeable = isTradeable;

        _dataNum = dataNum;

        _remark1 = remark1;

        _remark2 = remark2;

    }

    

    /**

     * Get data info by index

     * @param index index of dataArray

     */

    function getDataByIndex(uint index) public view returns (string link, string encryptionType, string hashValue) {

        require(isValid == true, "contract invaild");

        require(index >= 0, "Param index smaller than 0");

        require(index < dataNum, "Param index not smaller than dataNum");

        link = dataArray[index].link;

        encryptionType = dataArray[index].encryptionType;

        hashValue = dataArray[index].hashValue;

    }



    /**

     * set the price of asset

     * @param newPrice price of asset

     * Only can be called by holder

     */

    function setPrice(uint newPrice) public onlyHolder {

        require(isValid == true, "contract invaild");

        price = newPrice;

    }



    /**

     * set the tradeable status of asset

     * @param status status of isTradeable

     * Only can be called by holder

     */

    function setTradeable(bool status) public onlyHolder {

        require(isValid == true, "contract invaild");

        isTradeable = status;

    }



    /**

     * set the remark1

     * @param content new content of remark1

     * Only can be called by holder

     */

    function setRemark1(string content) public onlyHolder {

        require(isValid == true, "contract invaild");

        remark1 = content;

    }



    /**

     * set the remark2

     * @param content new content of remark2

     * Only can be called by holder

     */

    function setRemark2(string content) public onlyHolder {

        require(isValid == true, "contract invaild");

        remark2 = content;

    }



    /**

     * Modify the link of the indexth data to be url

     * @param index index of assetInfo

     * @param url new link

     * Only can be called by holder

     */

    function setDataLink(uint index, string url) public onlyHolder {

        require(isValid == true, "contract invaild");

        require(index >= 0, "Param index smaller than 0");

        require(index < dataNum, "Param index not smaller than dataNum");

        dataArray[index].link = url;

    }



    /**

     * cancel contract

     * Only can be called by holder

     */

    function cancelContract() public onlyHolder {

        isValid = false;

    }

    

    /**

     * Get the number of assetInfo

     */

    function getDataNum() public view returns (uint num) {

        num = dataNum;

    }



    /**

     * Transfer holder

     */

    function transferOwnership(address newHolder, bool status) public onlyHolder {

        holder = newHolder;

        isTradeable = status;

    }

}