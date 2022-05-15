// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {LibDiamond} from "./Diamond/libraries/LibDiamond.sol";
import {AppStorage} from "./Diamond/libraries/LibAppStorage.sol";
import {LibERC1155} from "./Diamond/libraries/LibERC1155.sol";
import {LibMeta} from "./Diamond/libraries/LibMeta.sol";
import {LibItems} from "./Diamond/libraries/LibItems.sol";

contract ItemContract  
{
    AppStorage internal s;

    function itemBalanceOf(address account, uint256 id) public view virtual returns (uint256) 
    {
        require(account != address(0), "ItemContract: address zero is not a valid owner");
        return s._Itembalances[account][id];
    }

    function itemBalanceOfBatch(address[] memory accounts, uint256[] memory ids) external view returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ItemContract: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i)
        {
            batchBalances[i] = itemBalanceOf(accounts[i], ids[i]);
        }
        return batchBalances;
    }

    function itemSetApprovalForAll(address operator, bool approved) public virtual
    {
        _itemSetApprovalForAll(LibMeta.msgSender(), operator, approved);
    }

    function itemIsApprovedForAll(address account, address operator) public view virtual returns (bool)
    {
        return s._operatorApprovalsItems[account][operator];
    }

    function _itemSetApprovalForAll(address owner, address operator, bool approved) internal virtual
    {
        require(owner != operator, "ERC1155: setting approval status for self");

        s._operatorApprovalsItems[owner][operator] = approved;
        emit LibERC1155.ItemApprovalForAll(owner, operator, approved);
    }
    
    function transferFromTokenApproved(
        address _sender,
        address _fromContract,
        uint256 _fromId
    ) internal view {
        if (_fromContract == address(this))
        {
            address owner = s._ownerOfItemId[_fromId];
            require
            (
                _sender == owner || s._operatorApprovalsItems[owner][_sender],
                "ItemsTransfer: Not owner and not approved to transfer"
            );
            //require(s.aavegotchis[_fromPlayerId].locked == false, "ItemsTransfer: Only callable on unlocked Aavegotchis");
        } else {
            address owner = s._owners[_fromId];
            require(
                owner == _sender || s._tokenApprovals[_fromId] == _sender || s._operatorApprovals[owner][_sender],
                "ItemsTransfer: Not owner and not approved to transfer asdf"
            );
        }
    }

    function transferToPlayer(
        address _from,
        address _toContract,
        uint256 _toPlayerId,
        uint256 _id,
        uint256 _value
    ) external {
        require(_toContract != address(0), "ItemsTransfer: Can't transfer to 0 address");
        address sender = LibMeta.msgSender();
        require(sender == _from, "ItemsTransfer: Not owner and not approved to transfer");
        require(s._Itembalances[sender][_id] >= _value, "something happened");

        LibItems.removeFromOwner(_from, _id, _value);
        LibItems.addToPlayer(_toContract, _toPlayerId, _id, _value);
        // event TransferToParent(address indexed _toContract, uint256 indexed _toTokenId, uint256 indexed _tokenTypeId, uint256 _value);
        emit LibERC1155.ItemTransferSingle(sender, _from, _toContract, _id, _value);
        emit LibERC1155.TransferToParent(_toContract, _toPlayerId, _id, _value);
    }

    function transferFromParent(
        address _fromContract,
        uint256 _fromId,
        address _to,
        uint256 _id,
        uint256 _value
    ) external {
        require(_to != address(0), "ItemsTransfer: Can't transfer to 0 address");

        //To do: Check if the item can be transferred.
        //require(s.itemTypes[_id].canBeTransferred, "ItemsTransfer: Item cannot be transferred");

        address sender = LibMeta.msgSender();
        transferFromTokenApproved(sender, _fromContract, _fromId);
        LibItems.removeFromPlayer(_fromContract, _fromId, _id, _value);
        LibItems.addToOwner(_to, _id, _value);
        emit LibERC1155.ItemTransferSingle(sender, _fromContract, _to, _id, _value);
        emit LibERC1155.TransferFromParent(_fromContract, _fromId, _id, _value);
    }


    function itemSafeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require
        (
            from == LibMeta.msgSender() || itemIsApprovedForAll(from, LibMeta.msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _itemSafeTransferFrom(from, to, id, amount, data);
    }

    function _itemSafeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = LibMeta.msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _itemBeforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = s._Itembalances[from][id];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            s._Itembalances[from][id] = fromBalance - amount;
        }
        s._Itembalances[to][id] += amount;

        emit LibERC1155.ItemTransferSingle(operator, from, to, id, amount);

        _itemAfterTokenTransfer(operator, from, to, ids, amounts, data);

    }
    function mintshititem(address to, uint256 id, uint256 amount, bytes memory data) public
    {
        _mint(to, id, amount, data);
    }
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = LibMeta.msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);
        _itemBeforeTokenTransfer(operator, address(0), to, ids, amounts, data);
        LibItems.addToOwner(to, id, amount);
        emit LibERC1155.ItemTransferSingle(operator, address(0), to, id, amount);
        _itemAfterTokenTransfer(operator, address(0), to, ids, amounts, data);
    }

    function _itemBeforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _itemAfterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) 
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}