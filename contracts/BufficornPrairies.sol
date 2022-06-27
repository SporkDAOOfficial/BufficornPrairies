//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


error BufficornGrazin();
error BufficornNotFound();
error NotYourBufficorn();

contract BufficornPrairies is AccessControl, IERC721, IERC721Receiver {

    uint public grazingPeriod;
    address public bufficorn; 
    bytes32 public constant BLM_ROLE = keccak256("BLM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => GrazinBufficorns) public onPrairie; 
    
    struct GrazinBufficorn {
        uint id; 
        uint grazinStart;
    }

    event GoinGrazin(address sender, uint bufficorns);

    constructor(
        uint _grazingPeriod,
        address _blmAgent,
        address _admin,
        address _bufficorn
    ) {
        grazingPeriod = _grazingPeriod;
        bufficorn = _bufficorn;
        _setupRole(BLM_ROLE, _blmAgent);
        _setupRole(ADMIN_ROLE, _admin);
    }


    /*************************************
    EXTERNAL STAKING & UNSTAKING FUNCTIONS
    **************************************/

    function goGrazin(uint[] calldata _tokenIds) 
        external
    {
        for (uint256 index = 0; index < _tokenIds.length; index++) {
            if (IERC721(bufficorn).ownerOf(_tokenIds[index]) != msg.sender)
                revert NotYourBufficorn();
            _goGrazin(index);
        }

    }


    /*****************
    INTERNAL STAKING FUNCTIONS
    *****************/

    function _goGrazin(uint256 _tokenId) internal {
        IERC721(bufficorn).approve(address(this), _tokenId);
        IERC721(bufficorn).safeTransferFrom(msg.sender, address(this), _tokenId);
        
        onPrairie[msg.sender].push(GrazinBufficorn(_tokenId, now.timestamp));

        emit GoinGrazin(msg.sender, _tokenId);
    }







}
