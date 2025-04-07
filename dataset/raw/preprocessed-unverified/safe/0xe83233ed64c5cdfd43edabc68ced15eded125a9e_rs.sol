/**

 *Submitted for verification at Etherscan.io on 2019-02-13

*/



pragma solidity ^0.4.24;



//

//                       .#########'

//                    .###############+

//                  ,####################

//                `#######################+

//               ;##########################

//              #############################.

//             ###############################,

//           +##################,    ###########`

//          .###################     .###########

//         ##############,          .###########+

//         #############`            .############`

//         ###########+                ############

//        ###########;                  ###########

//        ##########'                    ###########                                                                                      

//       '##########    '#.        `,     ##########                                                                                    

//       ##########    ####'      ####.   :#########;                                                                                   

//      `#########'   :#####;    ######    ##########                                                                                 

//      :#########    #######:  #######    :#########         

//      +#########    :#######.########     #########`       

//      #########;     ###############'     #########:       

//      #########       #############+      '########'        

//      #########        ############       :#########        

//      #########         ##########        ,#########        

//      #########         :########         ,#########        

//      #########        ,##########        ,#########        

//      #########       ,############       :########+        

//      #########      .#############+      '########'        

//      #########:    `###############'     #########,        

//      +########+    ;#######`;#######     #########         

//      ,#########    '######`  '######    :#########         

//       #########;   .#####`    '#####    ##########         

//       ##########    '###`      +###    :#########:         

//       ;#########+     `                ##########          

//        ##########,                    ###########          

//         ###########;                ############

//         +############             .############`

//          ###########+           ,#############;

//          `###########     ;++#################

//           :##########,    ###################

//            '###########.'###################

//             +##############################

//              '############################`

//               .##########################

//                 #######################:

//                   ###################+

//                     +##############:

//                        :#######+`

//

//

//

// Play0x.com (The ONLY gaming platform for all ERC20 Tokens)

// -------------------------------------------------------------------------------------------------------

// * Multiple types of game platforms

// * Build your own game zone - Not only playing games, but also allowing other players to join your game.

// * Support all ERC20 tokens.

//

//

//

// 0xC Token (Contract address : 0x60d8234a662651e586173c17eb45ca9833a7aa6c)

// -------------------------------------------------------------------------------------------------------

// * 0xC Token is an ERC20 Token specifically for digital entertainment.

// * No ICO and private sales,fair access.

// * There will be hundreds of games using 0xC as a game token.

// * Token holders can permanently get ETH's profit sharing.

//



/**

* @title SafeMath

* @dev Math operations with safety checks that throw on error

*/





/**

* @title Ownable

* @dev The Ownable contract has an owner address, and provides basic authorization control 

* functions, this simplifies the implementation of "user permissions". 

*/ 





//Main contract

contract ShareholderDividend is Ownable{

    using SafeMath for uint256;

    bool public IsWithdrawActive = true;

    

    //for Shareholder banlance record

    mapping(address => uint256) EtherBook;



    event withdrawLog(address userAddress, uint256 amount);



    function() public payable{}



    //Add profits for accounts

    function ProfitDividend (address[] addressArray, uint256[] profitArray) public onlyOwner

    {

        for( uint256 i = 0; i < addressArray.length;i++)

        {

            EtherBook[addressArray[i]] = EtherBook[addressArray[i]].add(profitArray[i]);

        }

    }

    

    // Adjust balance of accounts in the vault

    function AdjustEtherBook(address[] addressArray, uint256[] profitArray) public onlyOwner

    {

        for( uint256 i = 0; i < addressArray.length;i++)

        {

            EtherBook[addressArray[i]] = profitArray[i];

        }

    }

    

    //Check balance in the vault

    function CheckBalance(address theAddress) public view returns(uint256 profit)

    {

        return EtherBook[theAddress];

    }

    

    //User withdraw balance from the vault

    function withdraw() public payable

    {

        //if withdraw actived;

        require(IsWithdrawActive == true, "Vault is not ready.");

        require(EtherBook[msg.sender]>0, "Your vault is empty.");



        uint share = EtherBook[msg.sender];

        EtherBook[msg.sender] = 0;

        msg.sender.transfer(share);

        

        emit withdrawLog(msg.sender, share);

    }

    

    //Set withdraw status.

    function UpdateActive(bool _IsWithdrawActive) public onlyOwner

    {

        IsWithdrawActive = _IsWithdrawActive;

    }

}