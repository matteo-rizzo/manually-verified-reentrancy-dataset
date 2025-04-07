/**

 *Submitted for verification at Etherscan.io on 2018-12-10

*/



pragma solidity ^0.4.25;



/*  

     ==================================================================

    ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||

    ||  + Digital Multi Level Marketing in Ethereum smart-contract +  ||

    ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||

     ==================================================================

     

    https://ethmlm.com

    https://t.me/ethmlm

    

    

         ``..................``  ``....................``  ``..``             ``.``          

        `..,,,,,,,,,,,,,,,,,,.` ``.,,,,,,,,,,,,,,,,,,,,.`  `.,,.`            `..,.``         

        `.:::::,,,,,,,,,,,,,,.```.,,,,,,,:::::::,,,,,,,.`  `,::,.            `.,:,.`         

        `,:;:,,...............`  `.......,,:;::,,.......`  .,::,.`           `.:;,.`         

        `,:;:,.```````````````   ````````.,:::,.````````   .,::,.`           `.:;,.`         

     ++++++++++++++++++++    ++++++++++++++++++++++,   ,+++.,::,.`        ++++.:;,.`         

     ####################    ######################:   ,###.,::,.`        ####.:;,.`         

     ###';'';;:::::::::::````:::::::::+###;;'';::::.   ,###.,::,.`````````####,:;,.`         

     ###;,:;:,,.............``        +###.,::,`       ,###.,:;:,,........####::;,.`         

     ###;,:;:::,,,,,,,,,,,,,.`        +###.,::,`       ,###.,:;::,,,,,,,,,####::;,.`         

     ###;,:;::,,,,,,,,,,,,,,.`        +###.,::,`       ,###.,:;::,,,,,,,,,####::;,.`         

     ###;,:;:,..............``        +###.,::,`       ,###.,:::,.````````####,:;,.`         

     ###;,:;:.``````````````          +###.,::,`       ,###.,::,.`        ####,:;,.`         

     ###################              +###.,::,`       ,######################.:;,.`         

     ###################              +###.,::,`       ,######################.:;,.`         

     ###;,:;:.````````````````        +###.,::,`       ,###.,::,.`        ####.:;,.`         

     ###;,:;:,................``      +###.,::,`       ,###.,::,.`        ####.:;,.`         

     ###;,:;:::,,,,,,,,,,,,,,,.`      +###.,::,`       ,###.,::,.`        ####.:;,.`         

     ###:.,,,,,,,,,,,,,,,,,,,,.`      +###`.,,.`       ,###`.,,.`         ####.,,,.`         

     ###:`....................``      +###``..``       ,###``..``         ####`...`          

     ###: `````````````````````       +### ````        ,### ````          #### ```           

     #####################            +###             ,###               ####               

     #####################            +###             ,###               ####               

     ,,,,,,,,,,,,,,,,,,,,,     `````` .,,,`````        `,,,     ```````   ,,,,        `````` 

        `..,,,.``             `..,,.``   ``.,.`                `..,,,.``             `..,,.``

        `.::::,.`            `.,:::,.`   `.,:,.`               `.,:::,.`            `.,:::,.`

        .,:;;;:,.`           .,:;;;:.`   `,:;,.`               .,:;;;:,.`           .,:;;;:,`

        .,:;::::,`          `.,:;;;:.`   `,:;,.`               .,:;::::,`          `.,:::;:,`

        .,::::::,.`        `.,::::;:.`   `,:;,.`               .,:;::::,.`        `.,::::;:,`

    .#####+::,,::,`       ######::;:.,###`,:;,.`            ######::::::,`       +#####::;:,`

    .######:,,,::,.`      ######,:;:.,###`,:;,.`            ######:,,,::,.`      ######,,;:,`

    .######+,..,::,`     #######,:;:.,###`,:;,.`            ###'###,..,::,`     #######.,;:,`

    .###.###,.`.,:,.`   .##+####.:;:.,###`,:;,.`            ###.###,.`.,:,.`    #######.,;:,`

    .###.+###.``,::,`   ###:####.:;:.,###`,:;,.`            ###.'###.`.,::,`   ###:####.,;:,`

    .###.,###. `.,:,.` :##':####.:;:.,###`,:;,.`            ###.,###,``.,:,.` `##+:####.,;:,`

    .###.,+###  `,::,.`###:,####.:;:.,###`,:;,.`            ###.,'###` `,::,. ###:,####.,;:,`

    .###.,:###` `.,::.'##;:,####.:;:.,###`,:;,.`            ###.,:###, `.,::.,##':,####.,;:,`

    .###.,:'###  `,::,###:,.####.:;:.,###`,:;,.`            ###.,:;###  `,::,###:,.####.,;:,`

    .###.,::###` `.,:+##::,`####.:;:.,###`,:;,.`            ###.,::###: `.,:'##;:,`####.,;:,`

    .###.,::;###  `,:###:,.`####.:;:.,###`,:;:,............`###.,::,###  `,:###:,.`####.,;:,`

    .###.,::,###. `.###::,` ####.:;:.,###`,:;::,,,,,,,,,,,,.###.,::,###; `.+##;:,` ####.,;:,`

    .###`.::.,###  `##+:,.` ####.,:,.,###`.,:::,,,,,,,,,,,,.###`.,:,.###  `###:,.` ####.,:,.`

    .###`....`###, ###,..`  ####`.,.`,###``.,,,,,,,,,,,,,,..###`....`###' +##,..`  ####`.,.``

    .### ```` `###`##'```   ####`````,### ``````````````````### ````  ### ##+```   ####````` 

    .###       ######       ####     .###                   ###       +#####       ####      

    .###        ####,       ####     .#################     ###        ####'       ####      

    .###        ####        ####     .#################     ###        '###        ####     

    



*/



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



/**

 * Utility library of inline functions on addresses

 */



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev counter to allow mutex lock with only one SSTORE operation

  uint256 private _guardCounter;



  constructor() internal {

    // The counter starts at one to prevent changing it from zero to a non-zero

    // value, which is a more expensive operation.

    _guardCounter = 1;

  }



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * Calling a `nonReentrant` function from another `nonReentrant`

   * function is not supported. It is possible to prevent this from happening

   * by making the `nonReentrant` function external, and make it call a

   * `private` function that does the actual work.

   */

  modifier nonReentrant() {

    _guardCounter += 1;

    uint256 localCounter = _guardCounter;

    _;

    require(localCounter == _guardCounter);

  }



}







contract MLM_FOMO_BANK is Ownable {

    using SafeMath for uint256;

    

    //  time to win FOMO bank

    uint public fomo_period = 3600;     // 1 hour

    

    //  FOMO bank balance

    uint public balance;

    //  next winner address

    address public winner;

    //  win time

    uint public finish_time;

    

    //  MLM contract

    address _mlm;

    

    //  only MLM contract can call method

    modifier onlyMLM() {

        require(msg.sender == _mlm);

        _;

    }



    

    event Win(address indexed user, uint amount);

    

    

    function SetMLM(address mlm) public onlyOwner {

        _mlm = mlm;

    }

    

    //  fill the bank

    function AddToBank(address user) public payable onlyMLM {

        //  check for winner

        CheckWinner();

        

        // save last payment info

        balance = balance.add(msg.value);

        winner = user;

        finish_time = now + fomo_period;

    }

    

    // check winner

    function CheckWinner() internal {

        if(now > finish_time && winner != address(0)){

            emit Win(winner, balance);

            

            //  it should not be reentrancy, but just in case

            uint prev_balance = balance;

            balance = 0;

            //  send ethers to winner

            winner.transfer(prev_balance);

            winner = address(0);

        }

    }

    

    //  get cuurent FOMO info {balance, finish_time, winner }

    function GetInfo() public view returns (uint, uint, address) {

        return (

            balance,

            finish_time,

            winner

        );

    }

}



contract MLM is Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    using Address for address;

    

    // FOMO bank contract

    MLM_FOMO_BANK _fomo;

    

    struct userStruct {

        address[] referrers;    //  array with 3 level referrers

        address[] referrals;    //  array with referrals

        uint next_payment;      //  time to next payments, seconds

        bool isRegitered;       //  is user registered

        bytes32 ref_link;       //  referral link

    }

    

    // mapping with users

    mapping(address=>userStruct) users;

    //  mapping with referral links

    mapping(bytes32=>address) ref_to_users;

    

    uint public min_paymnet = 100 finney;               //  minimum payment amount 0,1ETH

    uint public min_time_to_add = 604800;               //  Time need to add after miimum payment, seconds | 1 week

    uint[] public reward_parts = [35, 25, 15, 15, 10];  //  how much need to send to referrers, %



    event RegisterEvent(address indexed user, address indexed referrer);

    event PayEvent(address indexed payer, uint amount, bool[3] levels);

    

    

    constructor(MLM_FOMO_BANK fomo) public {

        //  set FOMO contract

        _fomo = fomo;

    }

    





    function() public payable {

        //  sender should not be a contract

        require(!address(msg.sender).isContract());

        //  user should be registered

        require(users[msg.sender].isRegitered);

        //  referrer address is 0x00 because user is already registered and referrer is stored on the first payment

        Pay(0x00);

    }

    

    

    /*

    Make a payment

    --------------

    [bytes32 referrer_addr] - referrer's address. it is used only on first payment to save sender as a referral

    */

    function Pay(bytes32 referrer_addr) public payable nonReentrant {

        //  sender should not be a contract

        require(!address(msg.sender).isContract());

        //  check minimum amount

        require(msg.value >= min_paymnet);

        

        //  if it is a first payment need to register sender

        if(!users[msg.sender].isRegitered){

            _register(referrer_addr);

        }

        

        uint amount = msg.value;

        //  what referrer levels will received a payments, need on UI

        bool[3] memory levels = [false,false,false];

        //  iterate of sender's referrers

        for(uint i = 0; i < users[msg.sender].referrers.length; i++){

            //  referrer address at level i

            address ref = users[msg.sender].referrers[i];

            //  if referrer is active need to pay him

            if(users[ref].next_payment > now){

                //  calculate reward part, i.e. 0.1 * 35 / 100  = 0.035

                uint reward = amount.mul(reward_parts[i]).div(100);

                //  send reward to referrer

                ref.transfer(reward);

                //  set referrer's level ad payment

                levels[i] = true;

            }

        }

        

        //  what address will be saved to FOMO bank, referrer or current sender

        address fomo_user = msg.sender;

        if(users[msg.sender].referrers.length>0 && users[users[msg.sender].referrers[0]].next_payment > now)

            fomo_user = users[msg.sender].referrers[0];

            

        //  send 15% to FOMO bank and store selceted user

        _fomo.AddToBank.value(amount.mul(reward_parts[3]).div(100)).gas(gasleft())(fomo_user);

        

        // prolong referral link life

        if(now > users[msg.sender].next_payment)

            users[msg.sender].next_payment = now.add(amount.mul(min_time_to_add).div(min_paymnet));

        else 

            users[msg.sender].next_payment = users[msg.sender].next_payment.add(amount.mul(min_time_to_add).div(min_paymnet));

        

        emit PayEvent(msg.sender, amount, levels);

    }

    

    

    

    function _register(bytes32 referrer_addr) internal {

        // sender should not be registered

        require(!users[msg.sender].isRegitered);

        

        // get referrer address

        address referrer = ref_to_users[referrer_addr];

        // users could not be a referrer

        require(referrer!=msg.sender);

        

        //  if there is referrer

        if(referrer != address(0)){

            //  set refferers for currnet user

            _setReferrers(referrer, 0);

        }

        //  mark user as registered

        users[msg.sender].isRegitered = true;

        //  calculate referral link

        _getReferralLink(referrer);

        



        emit RegisterEvent(msg.sender, referrer);

    }

    

    //  generate a referral link

    function _getReferralLink(address referrer) internal {

        do{

            users[msg.sender].ref_link = keccak256(abi.encodePacked(uint(msg.sender) ^  uint(referrer) ^ now));

        } while(ref_to_users[users[msg.sender].ref_link] != address(0));

        ref_to_users[users[msg.sender].ref_link] = msg.sender;

    }

    

    // set referrers

    function _setReferrers(address referrer, uint level) internal {

        //  set referrer only for active user other case use his referrer

        if(users[referrer].next_payment > now){

            users[msg.sender].referrers.push(referrer);

            if(level == 0){

                //  add current user to referrer's referrals list

                users[referrer].referrals.push(msg.sender);

            }

            level++;

        }

        //  set referrers for 3 levels

        if(level<3 && users[referrer].referrers.length>0)

            _setReferrers(users[referrer].referrers[0], level);

    }

    

    /*  Get user info

    

        uint next_payment

        bool isRegitered

        bytes32 ref_link

    */

    function GetUser() public view returns(uint, bool, bytes32) {

        return (

            users[msg.sender].next_payment,

            users[msg.sender].isRegitered,

            users[msg.sender].ref_link

        );

    }

    

    // Get sender's referrers

    function GetReferrers() public view returns(address[] memory) {

        return users[msg.sender].referrers;

    }

    

    //  Get sender's referrals

    function GetReferrals() public view returns(address[] memory) {

        return users[msg.sender].referrals;

    }

    

    //  Project's owner can widthdraw contract's balance

    function widthdraw(address to, uint amount) public onlyOwner {

        to.transfer(amount);

    }

}