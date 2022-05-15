// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import {IERC1155TokenReceiver} from "../../../interfaces/IERC1155Receiver.sol";

library LibERC1155
{
    bytes4 internal constant ERC1155_ACCEPTED = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_ACCEPTED = 0xbc197c81;
    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ItemApprovalForAll(address indexed account, address indexed operator, bool approved);
    event ItemTransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferToParent(address indexed _toContract, uint256 indexed _toTokenId, uint256 indexed _tokenTypeId, uint256 _value);
    event TransferFromParent(address indexed _fromContract, uint256 indexed _fromTokenId, uint256 indexed _tokenTypeId, uint256 _value);

    function onERC1155Received(
        address _operator,
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal {
        uint256 size;
        assembly 
        {
            size := extcodesize(_to)
        }
        if (size > 0) 
        {
            require(
                ERC1155_ACCEPTED == IERC1155TokenReceiver(_to).onERC1155Received(_operator, _from, _id, _value, _data),
                "Wearables: Transfer rejected/failed by _to"
            );
        }
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes memory _data
    ) internal 
    {
        uint256 size;
        assembly 
        {
            size := extcodesize(_to)
        }
        if (size > 0) 
        {
            require(
                ERC1155_BATCH_ACCEPTED == IERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _values, _data),
                "Wearables: Transfer rejected/failed by _to"
            );
        }
    }
}