// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "./LibDiamond.sol";

struct Player
{
    address owner;
    string name;
}

struct AppStorage 
{
    //TODO: ADD PLAYERID => PLAYER MAPPING
    
    // ITEM CONTRACT MAPPINGS
    mapping(address => mapping(uint256 => uint256)) _Itembalances;
    mapping(uint256 => address) _ownerOfItemId;
    mapping(address => mapping(address => bool)) _operatorApprovalsItems;
    mapping(address => uint256[]) _isOwnerOfItems;

    // PLAYER CONTRACT MAPPINGS
    mapping(uint256 => address) _owners;
    // Mapping owner address to token count
    mapping(address => uint256) _balances;
    // Mapping from token ID to approved address
    mapping(uint256 => address) _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) _operatorApprovals;
    // mapping from playerid to playerstats
    mapping(uint256 => Player) _playerStatsFromID;
    
    // SHARED MAPPINGS

    // playercontract => playerid => itemid => amount
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) _playerIdItemIdAmount;
}

library LibAppStorage 
{
    function diamondStorage() internal pure returns (AppStorage storage ds) 
    {
        assembly 
        {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) 
    {
        return uint256(x >= 0 ? x : -x);
    }
}