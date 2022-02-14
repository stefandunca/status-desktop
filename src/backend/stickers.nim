import json
import ./eth
import ./utils
import ./core, ./response_type
import web3/[ethtypes, conversions]

proc market*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  return core.callPrivateRPC("stickers_market", payload)

proc installed*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("stickers_installed", payload)

proc install*(chainId: int, packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, packId]
  return core.callPrivateRPC("stickers_install", payload)

proc uninstall*(packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [packId]
  return core.callPrivateRPC("stickers_uninstall", payload)

proc recent*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("stickers_recent", payload)

proc addRecent*(packId: string, hash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{"packID": packId, "hash": hash}]
  return core.callPrivateRPC("stickers_addRecent", payload)

proc buyEstimate*(chainId: int, fromAccount: Address, packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, $fromAccount, packId]
  return core.callPrivateRPC("stickers_buyEstimate", payload)

proc buy*(chainId: int, txData: JsonNode, packId: string, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, packID, utils.hashPassword(password)]
  return core.callPrivateRPC("stickers_buy", payload)

#[TODO:
stickers_pending(): returns the list of sticker packs pending transaction confirmation
stickers_removePending(packID): removes a pending stickerpack
]#

# Retrieves number of sticker packs owned by user
# See https://notes.status.im/Q-sQmQbpTOOWCQcYiXtf5g#Read-Sticker-Packs-owned-by-a-user
# for more details
proc getBalance*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)

  if not response.error.isNil:
    raise newException(RpcException, "Error getting stickers balance: " & response.error.message)

  return response

proc tokenOfOwnerByIndex*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting owned tokens: " & response.error.message)

  return response

proc getPackIdFromTokenId*(address: string, data: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "to": address,
      "data": data
    }, "latest"]

  let response = eth.doEthCall(payload)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting pack id from token id: " & response.error.message)

  return response
