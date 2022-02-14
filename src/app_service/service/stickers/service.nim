import NimQml, Tables, json, sequtils, chronicles, strutils, atomics, sets, strutils, tables, stint

import httpclient

import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]

import web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization

import ../../../backend/stickers as status_stickers
import ../../../backend/chat as status_chat
import ../../../backend/response_type
import ../../../backend/eth
import ./dto/stickers
import ../ens/utils as ens_utils
import ../eth/service as eth_service
import ../settings/service as settings_service
import ../wallet_account/service as wallet_account_service
import ../transaction/service as transaction_service
import ../network/service as network_service
import ../chat/service as chat_service
import ../../common/types

import ../eth/utils as status_utils

import ../eth/dto/edn_dto as edn_helper

export StickerDto
export StickerPackDto

include async_tasks

logScope:
  topics = "stickers-service"

type
  StickerPackLoadedArgs* = ref object of Args
    stickerPack*: StickerPackDto
    isInstalled*: bool
    isBought*: bool
    isPending*: bool
  StickerGasEstimatedArgs* = ref object of Args
    estimate*: int
    uuid*: string

# Signals which may be emitted by this service:
const SIGNAL_STICKER_PACK_LOADED* = "stickerPackLoaded"
const SIGNAL_ALL_STICKER_PACKS_LOADED* = "allStickerPacksLoaded"
const SIGNAL_STICKER_GAS_ESTIMATED* = "stickerGasEstimated"
const SIGNAL_INSTALLED_STICKER_PACKS_LOADED* = "installedStickerPacksLoaded"

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    marketStickerPacks*: Table[string, StickerPackDto]
    purchasedStickerPacks*: seq[int]
    recentStickers*: seq[StickerDto]
    events: EventEmitter
    ethService: eth_service.Service
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    transactionService: transaction_service.Service
    networkService: network_service.Service
    chatService: chat_service.Service

  # Forward declaration
  proc obtainMarketStickerPacks*(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      ethService: eth_service.Service,
      settingsService: settings_service.Service,
      walletAccountService: wallet_account_service.Service,
      transactionService: transaction_service.Service,
      networkService: network_service.Service,
      chatService: chat_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.ethService = ethService
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.transactionService = transactionService
    result.networkService = networkService
    result.chatService = chatService
    result.marketStickerPacks = initTable[string, StickerPackDto]()
    result.purchasedStickerPacks = @[]
    result.recentStickers = @[]

  proc getInstalledStickerPacks*(self: Service): Table[string, StickerPackDto] =
    result = initTable[string, StickerPackDto]()
    try:
      let installedResponse = status_stickers.installed()
      for (packID, stickerPackJson) in installedResponse.result.pairs():
        result[packID] = stickerPackJson.toStickerPackDto()
    except RpcException:
      error "Error obtaining installed stickers", message = getCurrentExceptionMsg()
    
  proc init*(self: Service) =
    # TODO redo the connect check when the network is refactored
    # if self.status.network.isConnected:
    self.obtainMarketStickerPacks() # TODO: rename this to obtain sticker market items

  proc buyPack*(self: Service, packId: string, address, price, gas, gasPrice: string, isEIP1559Enabled: bool, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, success: var bool): string =
    discard # TODO:
    #[var
      sntContract: Erc20ContractDto
      approveAndCall: ApproveAndCall[100]
      tx = self.buildTransaction(
        packId.u256,
        parseAddress(address),
        status_utils.eth2Wei(parseFloat(price), 18), # SNT
        approveAndCall,
        sntContract,
        gas,
        gasPrice,
        isEIP1559Enabled,
        maxPriorityFeePerGas,
        maxFeePerGas
      )

    result = sntContract.methods["approveAndCall"].send(tx, approveAndCall, password, success)
    if success:
      self.transactionService.trackPendingTransaction(
        result,
        address,
        $sntContract.address,
        $PendingTransactionTypeDto.BuyStickerPack,
        $packId
      )]#

  proc buy*(self: Service, packId: string, address: string, price: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): tuple[response: string, success: bool] =
    let eip1559Enabled = self.settingsService.isEIP1559Enabled()

    try:
      status_utils.validateTransactionInput(address, address, "", price, gas, gasPrice, "", eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, "ok")
    except Exception as e:
      error "Error buying sticker pack", msg = e.msg
      return (response: "", success: false)

    var success: bool
    let response = self.buyPack(packId, address, price, gas, gasPrice, eip1559Enabled, maxPriorityFeePerGas, maxFeePerGas, password, success)

    result = (response: $response, success: success)

  proc getPackIdFromTokenId*(self: Service, chainId: int, tokenId: Stuint[256]): RpcResponse[JsonNode] =
    let
      contract = self.eth_service.findContract(chainId, "sticker-pack")
      tokenPackId = TokenPackId(tokenId: tokenId)

    if contract == nil:
      return

    let abi = contract.methods["tokenPackId"].encodeAbi(tokenPackId)

    return status_stickers.getPackIdFromTokenId($contract.address, abi)

  proc tokenOfOwnerByIndex*(self: Service, chainId: int, address: Address, idx: Stuint[256]): RpcResponse[JsonNode] =
    let
      contract = self.eth_service.findContract(chainId, "sticker-pack")

    if contract == nil:
      return

    let
      tokenOfOwnerByIndex = TokenOfOwnerByIndex(address: address, index: idx)
      data = contract.methods["tokenOfOwnerByIndex"].encodeAbi(tokenOfOwnerByIndex)

    status_stickers.tokenOfOwnerByIndex($contract.address, data)

  proc getBalance*(self: Service, chainId: int, address: Address): RpcResponse[JsonNode] =
    let contract = self.eth_service.findContract(chainId, "sticker-pack")
    if contract == nil: return

    let balanceOf = BalanceOf(address: address)
    let data = contract.methods["balanceOf"].encodeAbi(balanceOf)

    return status_stickers.getBalance($contract.address, data)

  proc getPurchasedStickerPacks*(self: Service, address: string): seq[int] =
    try:
      let addressObj = parseAddress(address)


      let networkType = self.settingsService.getCurrentNetwork().toNetworkType()
      let network = self.networkService.getNetwork(networkType)
      let balanceRpcResponse = self.getBalance(network.chainId, addressObj)

      var balance = 0
      if $balanceRpcResponse.result != "0x":
        balance = parseHexInt(balanceRpcResponse.result.getStr)

      var tokenIds: seq[int] = @[]

      for it in toSeq[0..<balance]:
        let response = self.tokenOfOwnerByIndex(network.chainId, addressObj, it.u256)
        var tokenId = 0
        if $response.result != "0x":
          tokenId = parseHexInt(response.result.getStr)
        tokenIds.add(tokenId)

      var purchasedPackIds: seq[int] = @[]
      for tokenId in tokenIds:
        let response = self.getPackIdFromTokenId(network.chainId, tokenId.u256)
        var packId = 0
        if $response.result != "0x":
          packId = parseHexInt(response.result.getStr)
        purchasedPackIds.add(packId)

      self.purchasedStickerPacks = self.purchasedStickerPacks.concat(purchasedPackIds)
      self.purchasedStickerPacks = self.purchasedStickerPacks.deduplicate()
      result = self.purchasedStickerPacks
    except RpcException:
      error "Error getting purchased sticker packs", message = getCurrentExceptionMsg()
      result = @[]

  proc setMarketStickerPacks*(self: Service, availableStickersJSON: string) {.slot.} =
    let
      accounts = self.walletAccountService.getWalletAccounts() # TODO: make generic
    var
      purchasedStickerPacks: seq[int]
    for account in accounts:
      purchasedStickerPacks = self.getPurchasedStickerPacks(account.address)
    let availableStickers = JSON.decode($availableStickersJSON, seq[StickerPackDto])

    let pendingTransactions = self.transactionService.getPendingTransactions()
    var pendingStickerPacks = initHashSet[int]()
    if (pendingTransactions.kind == JArray and pendingTransactions.len > 0):
      for trx in pendingTransactions.getElems():
        if trx["type"].getStr == $PendingTransactionTypeDto.BuyStickerPack:
          pendingStickerPacks.incl(trx["additionalData"].getStr.parseInt)

    for stickerPack in availableStickers:
      #let isBought = purchasedStickerPacks.contains(stickerPack.id)
     # let isPending = pendingStickerPacks.contains(stickerPack.id) and not isBought
      let isBought = false
      let isPending = false
      self.marketStickerPacks[stickerPack.id] = stickerPack
      self.events.emit(SIGNAL_STICKER_PACK_LOADED, StickerPackLoadedArgs(
        stickerPack: stickerPack,
        isInstalled: false,
        isBought: isBought,
        isPending: isPending
      ))
    self.events.emit(SIGNAL_ALL_STICKER_PACKS_LOADED, Args())

  proc obtainMarketStickerPacks*(self: Service) =
    let chainId = self.settingsService.getCurrentNetworkId()

    let arg = obtainMarketStickerPacksTaskArg(
      tptr: cast[ByteAddress](obtainMarketStickerPacksTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setMarketStickerPacks",
      chainId: chainId,
      running: cast[ByteAddress](addr self.threadpool.running)
    )
    self.threadpool.start(arg)

  proc setGasEstimate*(self: Service, estimateJson: string) {.slot.} =
    let estimateResult = Json.decode(estimateJson, tuple[estimate: int, uuid: string])
    self.events.emit(SIGNAL_STICKER_GAS_ESTIMATED, StickerGasEstimatedArgs(estimate: estimateResult.estimate, uuid: estimateResult.uuid))

  # the [T] here is annoying but the QtObject template only allows for one type
  # definition so we'll need to setup the type, task, and helper outside of body
  # passed to `QtObject:`
  proc estimate*(self: Service, packId: string, address: string, price: string, uuid: string) =
    let chainId = self.settingsService.getCurrentNetworkId()

    let arg = EstimateTaskArg(
      tptr: cast[ByteAddress](estimateTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "setGasEstimate",
      packId: packId,
      uuid: uuid,
      chainId: chainId,
      fromAddress: address
    )
    self.threadpool.start(arg)

  proc addStickerToRecent*(self: Service, sticker: StickerDto, save: bool = false) =
    try:
      discard status_stickers.addRecent(sticker.packId, sticker.hash)
    except RpcException:
      error "Error adding recent sticker", message = getCurrentExceptionMsg()

  proc getPackIdForSticker*(packs: Table[string, StickerPackDto], hash: string): string =
    for packId, pack in packs.pairs:
      if pack.stickers.any(proc(sticker: StickerDto): bool = return sticker.hash == hash):
        return packId
    return "0"

  proc getRecentStickers*(self: Service): seq[StickerDto] =
    try:
      let recentResponse = status_stickers.recent()
      for stickerJson in recentResponse.result:
        result = stickerJson.toStickerDto() & result
    except RpcException:
      error "Error obtaining installed stickers", message = getCurrentExceptionMsg()

  proc getNumInstalledStickerPacks*(self: Service): int =
    try:
      let installedResponse = status_stickers.installed()
      return installedResponse.result.len
    except RpcException:
      error "Error obtaining installed stickers", message = getCurrentExceptionMsg()
    return 0

  proc installStickerPack*(self: Service, packId: string) =
    let chainId = self.settingsService.getCurrentNetworkId()
    if not self.marketStickerPacks.hasKey(packId):
      return
    let installResponse = status_stickers.install(chainId, packId)
    
  proc uninstallStickerPack*(self: Service, packId: string) =
    try:
      let installedResponse = status_stickers.uninstall(packId)
    except RpcException:
      error "Error removing installed sticker", message = getCurrentExceptionMsg()

  proc sendSticker*(
      self: Service,
      chatId: string,
      replyTo: string,
      sticker: StickerDto,
      preferredUsername: string) =
    let response = status_chat.sendChatMessage(
        chatId,
        "Update to latest version to see a nice sticker here!",
        replyTo,
        ContentType.Sticker.int,
        preferredUsername,
        communityId = "", # communityId is not ncessary when sending a sticker
        sticker.hash,
        sticker.packId)
    discard self.chatService.processMessageUpdateAfterSend(response)
    self.addStickerToRecent(sticker)

  proc removeRecentStickers*(self: Service, packId: string) =
    self.recentStickers.keepItIf(it.packId != packId)
    discard self.settingsService.saveRecentStickers(self.recentStickers)
