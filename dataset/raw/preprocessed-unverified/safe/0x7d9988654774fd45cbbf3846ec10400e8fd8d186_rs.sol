/**

 *Submitted for verification at Etherscan.io on 2018-08-31

*/



pragma solidity ^0.4.24;



/** @title -MSFun- v0.2.4

 * ┌┬┐┌─┐┌─┐┌┬┐   ╦╦ ╦╔═╗╔╦╗  ┌─┐┬─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐

 *  │ ├┤ ├─┤│││   ║║ ║╚═╗ ║   ├─┘├┬┘├┤ └─┐├┤ │││ │ └─┐

 *  ┴ └─┘┴ ┴┴ ┴  ╚╝╚═╝╚═╝ ╩   ┴  ┴└─└─┘└─┘└─┘┘└┘ ┴ └─┘

 *                                  _____                      _____

 *                                 (, /     /)       /) /)    (, /      /)          /)

 *          ┌─┐                      /   _ (/_      // //       /  _   // _   __  _(/

 *          ├─┤                  ___/___(/_/(__(_/_(/_(/_   ___/__/_)_(/_(_(_/ (_(_(_

 *          ┴ ┴                /   /          .-/ _____   (__ /                               

 *                            (__ /          (_/ (, /                                      /)™ 

 *                                                 /  __  __ __ __  _   __ __  _  _/_ _  _(/

 * ┌─┐┬─┐┌─┐┌┬┐┬ ┬┌─┐┌┬┐                          /__/ (_(__(_)/ (_/_)_(_)/ (_(_(_(__(/_(_(_

 * ├─┘├┬┘│ │ │││ ││   │                      (__ /              .-/  © Jekyll Island Inc. 2018

 * ┴  ┴└─└─┘─┴┘└─┘└─┘ ┴                                        (_/

 *  _           _             _  _  _  _             _  _  _  _  _                                      

 *=(_) _     _ (_)==========_(_)(_)(_)(_)_==========(_)(_)(_)(_)(_)================================*

 * (_)(_)   (_)(_)         (_)          (_)         (_)       _         _    _  _  _  _                 

 * (_) (_)_(_) (_)         (_)_  _  _  _            (_) _  _ (_)       (_)  (_)(_)(_)(_)_               

 * (_)   (_)   (_)           (_)(_)(_)(_)_          (_)(_)(_)(_)       (_)  (_)        (_)              

 * (_)         (_)  _  _    _           (_)  _  _   (_)      (_)       (_)  (_)        (_)  _  _        

 *=(_)=========(_)=(_)(_)==(_)_  _  _  _(_)=(_)(_)==(_)======(_)_  _  _(_)_ (_)========(_)=(_)(_)==*

 * (_)         (_) (_)(_)    (_)(_)(_)(_)   (_)(_)  (_)        (_)(_)(_) (_)(_)        (_) (_)(_)

 *

 * ╔═╗┌─┐┌┐┌┌┬┐┬─┐┌─┐┌─┐┌┬┐  ╔═╗┌─┐┌┬┐┌─┐ ┌──────────┐

 * ║  │ ││││ │ ├┬┘├─┤│   │   ║  │ │ ││├┤  │ Inventor │

 * ╚═╝└─┘┘└┘ ┴ ┴└─┴ ┴└─┘ ┴   ╚═╝└─┘─┴┘└─┘ └──────────┘

 *  

 *         ┌──────────────────────────────────────────────────────────────────────┐

 *         │ MSFun, is an importable library that gives your contract the ability │

 *         │ add multiSig requirement to functions.                               │

 *         └──────────────────────────────────────────────────────────────────────┘

 *                                ┌────────────────────┐

 *                                │ Setup Instructions │

 *                                └────────────────────┘

 * (Step 1) import the library into your contract

 * 

 *    import "./MSFun.sol";

 *

 * (Step 2) set up the signature data for msFun

 * 

 *     MSFun.Data private msData;

 *                                ┌────────────────────┐

 *                                │ Usage Instructions │

 *                                └────────────────────┘

 * at the beginning of a function

 * 

 *     function functionName() 

 *     {

 *         if (MSFun.multiSig(msData, required signatures, "functionName") == true)

 *         {

 *             MSFun.deleteProposal(msData, "functionName");

 * 

 *             // put function body here 

 *         }

 *     }

 *                           ┌────────────────────────────────┐

 *                           │ Optional Wrappers For TeamJust │

 *                           └────────────────────────────────┘

 * multiSig wrapper function (cuts down on inputs, improves readability)

 * this wrapper is HIGHLY recommended

 * 

 *     function multiSig(bytes32 _whatFunction) private returns (bool) {return(MSFun.multiSig(msData, TeamJust.requiredSignatures(), _whatFunction));}

 *     function multiSigDev(bytes32 _whatFunction) private returns (bool) {return(MSFun.multiSig(msData, TeamJust.requiredDevSignatures(), _whatFunction));}

 *

 * wrapper for delete proposal (makes code cleaner)

 *     

 *     function deleteProposal(bytes32 _whatFunction) private {MSFun.deleteProposal(msData, _whatFunction);}

 *                             ┌────────────────────────────┐

 *                             │ Utility & Vanity Functions │

 *                             └────────────────────────────┘

 * delete any proposal is highly recommended.  without it, if an admin calls a multiSig

 * function, with argument inputs that the other admins do not agree upon, the function

 * can never be executed until the undesirable arguments are approved.

 * 

 *     function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}

 * 

 * for viewing who has signed a proposal & proposal data

 *     

 *     function checkData(bytes32 _whatFunction) onlyAdmins() public view returns(bytes32, uint256) {return(MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}

 *

 * lets you check address of up to 3 signers (address)

 * 

 *     function checkSignersByAddress(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(address, address, address) {return(MSFun.checkSigner(msData, _whatFunction, _signerA), MSFun.checkSigner(msData, _whatFunction, _signerB), MSFun.checkSigner(msData, _whatFunction, _signerC));}

 *

 * same as above but will return names in string format.

 *

 *     function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(bytes32, bytes32, bytes32) {return(TeamJust.adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), TeamJust.adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), TeamJust.adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}

 *                             ┌──────────────────────────┐

 *                             │ Functions In Depth Guide │

 *                             └──────────────────────────┘

 * In the following examples, the Data is the proposal set for this library.  And

 * the bytes32 is the name of the function.

 *

 * MSFun.multiSig(Data, uint256, bytes32) - Manages creating/updating multiSig 

 *      proposal for the function being called.  The uint256 is the required 

 *      number of signatures needed before the multiSig will return true.  

 *      Upon first call, multiSig will create a proposal and store the arguments 

 *      passed with the function call as msgData.  Any admins trying to sign the 

 *      function call will need to send the same argument values. Once required

 *      number of signatures is reached this will return a bool of true.

 * 

 * MSFun.deleteProposal(Data, bytes32) - once multiSig unlocks the function body,

 *      you will want to delete the proposal data.  This does that.

 *

 * MSFun.checkMsgData(Data, bytes32) - checks the message data for any given proposal 

 * 

 * MSFun.checkCount(Data, bytes32) - checks the number of admins that have signed

 *      the proposal 

 * 

 * MSFun.checkSigners(data, bytes32, uint256) - checks the address of a given signer.

 *      the uint256, is the log number of the signer (ie 1st signer, 2nd signer)

 */



