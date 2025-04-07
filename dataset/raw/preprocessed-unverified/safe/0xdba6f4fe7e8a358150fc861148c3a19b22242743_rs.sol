/**

 *Submitted for verification at Etherscan.io on 2018-09-19

*/



pragma solidity ^0.4.24;



contract CompanyShare {

    using SafeMath for *;



    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address

    mapping (uint256 => CompanySharedatasets.Player) public team_;          // (team => fees) fee distribution by team



    /**

     * @dev prevents contracts from interacting with fomo3d

     */

    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



    constructor()

        public

    {

        address first = 0x7ce07aa2fc356fa52f622c1f4df1e8eaad7febf0;

        address second = 0x6b5d2ba1691e30376a394c13e38f48e25634724f;

        address third = 0x459b5286e28d0dd452af4f38ffed4d302fc833c8;

        address fourth = 0xd775c5063bef4eda77a21646a6880494d9a1156b;



        //creatTeam

        team_[1] = CompanySharedatasets.Player(first,0, 500);

        pIDxAddr_[first] = 1;

        team_[2] = CompanySharedatasets.Player(second,0, 250);

        pIDxAddr_[second] = 2;

        team_[3] = CompanySharedatasets.Player(third,0, 125);

        pIDxAddr_[third] = 3;

        team_[4] = CompanySharedatasets.Player(fourth,0, 125);

        pIDxAddr_[fourth] = 4;

	}



    /**

     * @dev emergency buy uses last stored affiliate ID and team snek

     */

    function()

        public

        payable

    {

        uint256 _eth = msg.value;

        //giveTeam Gen

        giveGen(_eth);

    }



    function deposit()

        public

        payable

        returns(bool)

    {

        uint256 _eth = msg.value;

        //giveTeam Gen

        giveGen(_eth);

        return true;

    }



	function giveGen(uint256 _eth)

		private

		returns(uint256)

    {

        uint256 _genFirst = _eth.mul(team_[1].percent) /1000;

        uint256 _genSecond = _eth.mul(team_[2].percent) /1000;

        uint256 _genThird = _eth.mul(team_[3].percent) /1000;

        uint256 _genFourth = _eth.sub(_genFirst).sub(_genSecond).sub(_genThird);

        //give gen

        team_[1].gen = _genFirst.add(team_[1].gen);

        team_[2].gen = _genSecond.add(team_[2].gen);

        team_[3].gen = _genThird.add(team_[3].gen);

        team_[4].gen = _genFourth.add(team_[4].gen);

    }



        /**

     * @dev withdraws all of your earnings.

     * -functionhash- 0x3ccfd60b

     */

    function withdraw()

        isHuman()

        public

    {

        // fetch player ID

        uint256 _pID = pIDxAddr_[msg.sender];

        require(_pID != 0, "sorry not team");

        // setup temp var for player eth

        uint256 _eth;

        // get their earnings

        _eth = withdrawEarnings(_pID);

        team_[_pID].addr.transfer(_eth);

    }



        /**

     * @dev adds up unmasked earnings, & vault earnings, sets them all to 0

     * @return earnings in wei format

     */

    function withdrawEarnings(uint256 _pID)

        private

        returns(uint256)

    {



        // from vaults

        uint256 _earnings = team_[_pID].gen;

        if (_earnings > 0)

        {

            team_[_pID].gen = 0;

        }



        return(_earnings);

    }



    function getGen()

		public

		view

		returns(uint256)

    {

        uint256 _pID = pIDxAddr_[msg.sender];

        require(_pID != 0, "sorry not in team");

        uint256 _earnings = team_[_pID].gen;

        return _earnings;

    } 

    

    function destory(){

        uint256 _pID = pIDxAddr_[msg.sender];

        require(_pID != 0, "sorry not in team");

        selfdestruct(0x7ce07aa2fc356fa52f622c1f4df1e8eaad7febf0);

    }

}





//==============================================================================

//   __|_ _    __|_ _  .

//  _\ | | |_|(_ | _\  .

//==============================================================================





/**

 * @title SafeMath v0.1.9

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */

