/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.24;

pragma experimental ABIEncoderV2;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









contract TokenInfo {

    

    struct Module {

        bytes32 name;

        address module;

        address moduleFactory;

        bool isArchived;

        uint8[] moduleTypes;

    }



    struct Checkpoint {

        uint256 checkpointId;

        address[] investors;

        uint256[] balances;

        uint256 totalSupply;

        uint256 time;

    }

    

    struct Token {

        address token;

        address owner;

        address[] investors;

        uint256[] balances;

        uint256 numInvestors;

        uint256 totalSupply;

        Module[] modules;

        Checkpoint[] checkpoints;

    }

    

    function getTokens(address[] _tokens) public view returns (Token[] memory tokens) {

        tokens = new Token[](_tokens.length);

        for (uint256 i = 0; i < _tokens.length; i++) {

            tokens[i] = getToken(_tokens[i]);

        }

    }

    

    function getToken(address _token) public view returns (Token memory t) {

        

        // Token memory t;

        t.token = _token;

        t.owner = IOwnable(_token).owner();

        ISecurityToken st = ISecurityToken(_token);

        t.investors = st.getInvestors();

        t.totalSupply = st.totalSupply();

        t.numInvestors = st.getInvestorCount();

        t.balances = new uint256[](t.investors.length);

        uint256 ii;

        for (ii = 0; ii < t.investors.length; ii++) {

            t.balances[ii] = st.balanceOf(t.investors[ii]);

        }



        //Get Modules

        address[] memory modules;

        uint256 counter = 0;

        uint8 i;

        uint256 j;

        for (i = 1; i < 6; i++) {

            modules = st.getModulesByType(i);

            for (j = 0; j < modules.length; j++) {

                counter = counter + modules.length;

            }

        }

        t.modules = new Module[](counter);

        counter = 0;

        for (i = 1; i < 6; i++) {

            modules = st.getModulesByType(i);

            for (j = 0; j < modules.length; j++) {

                t.modules[counter] = (getModule(_token, modules[j]));

                counter++;

            }

        }

        

        //Get Checkpoints

        t.checkpoints = new Checkpoint[](st.currentCheckpointId());

        for (i = 0; i < st.currentCheckpointId(); i++) {

            t.checkpoints[i] = getCheckpoint(_token, i);

        }

        return t;

    }

    

    function getCheckpoint(address _token, uint256 _checkpointId) public view returns (Checkpoint memory) {

        ISecurityToken st = ISecurityToken(_token);

        uint256[] memory times = st.getCheckpointTimes();

        Checkpoint memory c;

        c.checkpointId = _checkpointId;

        c.investors = st.getInvestorsAt(_checkpointId);

        c.balances = new uint256[](c.investors.length);

        for (uint256 i = 0; i < c.investors.length; i++) {

            c.balances[i] = st.balanceOfAt(c.investors[i], _checkpointId);

        }

        c.totalSupply = st.totalSupplyAt(_checkpointId);

        c.time = times[_checkpointId];

        return c;

    }

    

    function getModule(address _token, address _module) public view returns (Module memory) {

        ISecurityToken st = ISecurityToken(_token);

        (bytes32 name, address module, address moduleFactory, bool isArchived , uint8[] memory moduleTypes) = st.getModule(_module);

        Module memory m;

        m.name = name;

        m.module = module;

        m.moduleFactory = moduleFactory;

        m.isArchived = isArchived;

        m.moduleTypes = moduleTypes;

        return m;

    }

    

}