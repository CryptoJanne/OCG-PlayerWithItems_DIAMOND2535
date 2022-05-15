from brownie import Contract, accounts
from brownie import (
    Diamond,
    DiamondCutFacet,
    DiamondLoupeFacet,
    OwnershipFacet,
    DiamondInit,
    PlayerContract,
    ItemContract,
)

# from brownie import Test1Facet, Test2Facet
from scripts.Helpers import facetCutAction, hashFunctionSignature, getSelectors, get_account, get_account2, zeroAddress
import time


def main():
    owner = get_account()
    acc2 = get_account2()
    diamondCutFacet = DiamondCutFacet.deploy({"from": owner})
    diamondLoupeFacet = DiamondLoupeFacet.deploy({"from": owner})
    ownershipFacet = OwnershipFacet.deploy({"from": owner})
    playercontract = PlayerContract.deploy({"from": owner})
    itemcontract = ItemContract.deploy({"from": owner})
    diamondInit = DiamondInit.deploy({"from": owner})
    diamond = Diamond.deploy(owner, diamondCutFacet.address, {"from": owner})
    cut = [
        [
            diamondLoupeFacet.address,
            facetCutAction["Add"],
            getSelectors(DiamondLoupeFacet),
        ],
        [
            ownershipFacet.address,
            facetCutAction["Add"],
            getSelectors(OwnershipFacet),
        ],
        [
            playercontract.address,
            facetCutAction["Add"],
            getSelectors(PlayerContract),
        ],
        [
            itemcontract.address,
            facetCutAction["Add"],
            getSelectors(ItemContract),
        ]
    ]

    # DiamondCutFacet at diamond.address
    diamondCut = Contract.from_abi("DiamondCut", diamond.address, diamondCutFacet.abi)
    initSelector = getSelectors(DiamondInit)

    diamondCut.diamondCut(cut, diamondInit.address, initSelector[0], {"from": owner})
    itemContractInDiamond = Contract.from_abi("ItemContract", diamond.address, itemcontract.abi)
    playerContractInDiamond = Contract.from_abi("PlayerContract", diamond.address, playercontract.abi)
    playerContractInDiamond.mintit(owner, 1,{"from": owner})
    print(playerContractInDiamond.balanceOf(owner))
    playerContractInDiamond.transfershit(owner, acc2, 1, {"from": owner})
    print(playerContractInDiamond.balanceOf(owner))
    print(playerContractInDiamond.balanceOf(acc2))
    playerContractInDiamond.transfershit(acc2, owner, 1, {"from": acc2})
    itemContractInDiamond.mintshititem(acc2, 1, 1, "", {"from": owner})
    print(itemContractInDiamond.itemBalanceOf(acc2, 1))
    itemContractInDiamond.itemSafeTransferFrom(acc2, owner, 1, 1, "", {"from": acc2})
    print(itemContractInDiamond.itemBalanceOf(owner, 1))
    print(playerContractInDiamond.balanceOf(owner))
    # TEST TRANSFER FROM ADDRESS TO PLAYERCONTRACT
    # transferToPlayer(address owner, address toContractAddress, uint256 toPlayerId, uint256 itemIdToBeTransfered, uint256 amountToBeTransfered)
    itemContractInDiamond.transferToPlayer(owner, playercontract.address, 1, 1, 1, {"from": owner})
    # CHECK THAT PLAYERCONTRACT INDEED RECIEVED AND LOGGED PLAYERID AND TOKENID
    # GetPlayerIdItemIdAmount(address contractAddress, uint256 playerId, uint256 tokenId)
    print(playerContractInDiamond.GetPlayerIdItemIdAmount(playercontract.address, 1,1))
    print(playerContractInDiamond.ownerOf(1))
    print(owner.address)
    #print(playerContractInDiamond.getsigner({"from": owner}))
    # TEST TRANSFER FROM PLAYER WITH ID TO ADDRESS
    # transferFromParent(address _fromContract,uint256 _fromId,address _to,uint256 _id,uint256 _value)
    print(itemContractInDiamond.itemBalanceOf(owner, 1))
    itemContractInDiamond.transferFromParent(playercontract.address, 1, owner.address, 1, 1, {"from": owner})
    print(itemContractInDiamond.itemBalanceOf(owner, 1))
    print(playerContractInDiamond.GetPlayerStatsFromId(1))
    time.sleep(1)