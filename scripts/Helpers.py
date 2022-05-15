from brownie import network, config, accounts
import web3

facetCutAction = {"Add": 0, "Replace": 1, "Remove": 2}
zeroAddress = "0x0000000000000000000000000000000000000000"

def get_account():
    if(network.show_active() == "development"):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def get_account2():
    if(network.show_active() == "development"):
        return accounts[1]
    else:
        return accounts.add(config["wallets"]["from_key2"])

def getSelectors(contract):
    return list(contract.signatures.values())


def hashFunctionSignature(function_signature_text):
    return web3.Web3.keccak(text=function_signature_text).hex()[0:10]