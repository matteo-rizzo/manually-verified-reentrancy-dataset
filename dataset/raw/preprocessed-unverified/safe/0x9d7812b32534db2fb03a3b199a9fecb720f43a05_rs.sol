/**
 *Submitted for verification at Etherscan.io on 2019-10-14
*/

pragma solidity 0.5.12;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract StaticCheckCheezeWizards is Ownable {

    // Currently on Rinkeby at: 0x108FC97479Ec5E0ab8e68584b3Ea9518BE78BeB4
    // Currently on Mainnet at: (Not deployed yet)
    address cheezeWizardTournamentAddress;

    // Currently on Rinkeby at: 0x9B814233894Cd227f561B78Cc65891AA55C62Ad2 (OpenSeaAdmin address)
    // Currently on Mainnet at: 0x9B814233894Cd227f561B78Cc65891AA55C62Ad2 (OpenSeaAdmin address)
    address openSeaAdminAddress;

    constructor (address _cheezeWizardTournamentAddress, address _openSeaAdminAddress) public {
        cheezeWizardTournamentAddress = _cheezeWizardTournamentAddress;
        openSeaAdminAddress = _openSeaAdminAddress;
    }

    function succeedIfCurrentWizardFingerprintMatchesProvidedWizardFingerprint(uint256 _wizardId, bytes32 _fingerprint, bool checkTxOrigin) public view {
        require(_fingerprint == IBasicTournament(cheezeWizardTournamentAddress).wizardFingerprint(_wizardId));
        if(checkTxOrigin){
            require(openSeaAdminAddress == tx.origin);
        }
    }

    function changeTournamentAddress(address _newTournamentAddress) external onlyOwner {
        cheezeWizardTournamentAddress = _newTournamentAddress;
    }

    function changeOpenSeaAdminAddress(address _newOpenSeaAdminAddress) external onlyOwner {
        openSeaAdminAddress = _newOpenSeaAdminAddress;
    }
}

contract IBasicTournament {
    function wizardFingerprint(uint256 wizardId) external view returns (bytes32);
}