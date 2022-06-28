//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


error BufficornGrazin();
error BufficornNotFound();
error NotYourBufficorn();

contract BufficornPrairies is AccessControl, IERC721 {

    uint public grazingPeriod;
    address public bufficorn; 
    bytes32 public constant BLM_ROLE = keccak256("BLM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => mapping(uint => GrazinBufficorn)) public onPrairie; 
    
    struct GrazinBufficorn {
        uint id; 
        uint grazinStart;
        bool isGrazin;
    }

    event GoinGrazin(address sender, uint bufficorns);
    event GoneHome(address owner, uint bufficorn, uint whenHome);

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

    function backToRanch(uint[] calldata _tokenIds)
        external
    {
         for (uint256 index = 0; index < _tokenIds.length; index++) {
            if (IERC721(bufficorn).ownerOf(_tokenIds[index]) != address(this))
                revert BufficornNotFound();
            if (_tokenIds[index] != onPrairie[msg.sender][index].id)
                revert NotYourBufficorn();
            _backToRanch(index);
        }
    }


    /*************************************
    INTERNAL STAKING / UNSTAKING FUNCTIONS
    *************************************/

    function _goGrazin(uint256 _tokenId) internal {
        IERC721(bufficorn).approve(address(this), _tokenId);
        IERC721(bufficorn).safeTransferFrom(msg.sender, address(this), _tokenId);

        onPrairie[msg.sender][_tokenId] = GrazinBufficorn(_tokenId, block.timestamp, true);

        emit GoinGrazin(msg.sender, _tokenId);
    }

    function _backToRanch(uint256 _tokenId) internal {
        if(onPrairie[msg.sender][_tokenId].grazinStart + grazingPeriod > block.timestamp) {
            revert BufficornGrazin();
        }

        GrazinBufficorn storage myBuff = onPrairie[msg.sender][_tokenId];
            
        IERC721(bufficorn).approve(address(this), _tokenId);
        IERC721(bufficorn).safeTransferFrom(address(this), msg.sender, _tokenId);
        
        myBuff.isGrazin = false; 

        emit GoneHome(msg.sender, _tokenId, block.timestamp);
    }
}
