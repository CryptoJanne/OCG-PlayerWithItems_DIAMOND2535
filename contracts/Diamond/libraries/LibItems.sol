// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";


library LibItems 
{
    function addToOwner(address _to, uint256 _id, uint256 _amount) internal
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s._Itembalances[_to][_id] += _amount;
        s._ownerOfItemId[_id] = _to;
    }

    function removeFromOwner(address _from, uint256 _id, uint256 _value) internal 
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 bal = s._Itembalances[_from][_id];
        require(_value <= bal, "LibItems: Doesn't have that many to transfer");
        bal -= _value;
        s._Itembalances[_from][_id] = bal;
        if (bal == 0) 
        {
            delete s._Itembalances[_from][_id];
        }
    }

    function addToPlayer(address _toContract, uint256 _toPlayerId, uint256 _itemId, uint256 _amount) internal 
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s._playerIdItemIdAmount[_toContract][_toPlayerId][_itemId] += _amount;
    }

    function removeFromPlayer(address _fromContract, uint256 _fromTokenId, uint256 _id, uint256 _value) internal
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 balance = s._playerIdItemIdAmount[_fromContract][_fromTokenId][_id];
        require(balance >= _value, "LibItems: player doesn't have that many to transfer");
        balance -= _value;
        s._playerIdItemIdAmount[_fromContract][_fromTokenId][_id] = balance;
    }
}
