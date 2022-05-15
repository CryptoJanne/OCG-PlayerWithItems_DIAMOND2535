// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {LibDiamond} from "./Diamond/libraries/LibDiamond.sol";
import {AppStorage, Player} from "./Diamond/libraries/LibAppStorage.sol";
import {LibERC721} from "./Diamond/libraries/LibERC721.sol";
import {LibMeta} from "./Diamond/libraries/LibMeta.sol";

contract PlayerContract  
{
    AppStorage internal s;
    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) external view returns (uint256) 
    {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return s._balances[owner];
    }
    function getsigner() public view virtual returns(address)
    {
        address bajs = LibMeta.msgSender();
        return bajs;
    }
    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns(address) 
    {
        address owner = s._owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function GetPlayerIdItemIdAmount(address playerContract, uint256 playerId, uint256 itemId) public view virtual returns(uint256)
    {
        uint256 amount = s._playerIdItemIdAmount[playerContract][playerId][itemId];
        return amount;
    }
    function GetPlayerStatsFromId(uint256 playerId) public view virtual returns(Player memory)
    {
        return s._playerStatsFromID[playerId];
    }
    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            LibMeta.msgSender() == owner || isApprovedForAll(owner, LibMeta.msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return s._operatorApprovals[owner][operator];
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        s._tokenApprovals[tokenId] = to;
        emit LibERC721.Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return s._tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(LibMeta.msgSender(), operator, approved);
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return s._owners[tokenId] != address(0);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(LibMeta.msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function mintit(address to, uint256 tokenid) public
    {
        _safeMint(to, tokenid);
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        s._balances[to] += 1;
        s._owners[tokenId] = to;
        s._playerStatsFromID[tokenId].owner = to;
        s._playerStatsFromID[tokenId].name = "jesus";

        emit LibERC721.Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }
    function transfershit(address from, address to, uint256 id) public
    {
        safeTransferFrom(from, to, id);
    }
    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        require(_isApprovedOrOwner(LibMeta.msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        //require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        s._operatorApprovals[owner][operator] = approved;
        emit LibERC721.ApprovalForAll(owner, operator, approved);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        s._balances[from] -= 1;
        s._balances[to] += 1;
        s._owners[tokenId] = to;
        s._playerStatsFromID[tokenId].owner = to;

        emit LibERC721.Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function addInterfaces() external 
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // NEED TO FIGURE OUT WAT DIS IS
        //ds.supportedInterfaces[0xd9b67a26] = true; //erc1155
        //ds.supportedInterfaces[0x80ac58cd] = true; //erc721
    }
}