import json, strformat
import ../../../app_service/common/types

export types.ContentType
import message_reaction_model, message_reaction_item

type 
  Item* = ref object
    id: string
    responseToMessageWithId: string
    senderId: string
    senderDisplayName: string
    senderLocalName: string
    amISender: bool
    senderIcon: string
    isSenderIconIdenticon: bool
    seen: bool
    outgoingStatus: string
    messageText: string
    messageImage: string
    stickerHash: string
    stickerPack: int     
    gapFrom: int64
    gapTo: int64
    timestamp: int64
    contentType: ContentType
    messageType: int
    reactionsModel: MessageReactionModel 
    pinned: bool

proc initItem*(id, responseToMessageWithId, senderId, senderDisplayName, senderLocalName, senderIcon: string, 
  isSenderIconIdenticon, amISender: bool, outgoingStatus, text, image: string, seen: bool, timestamp: int64, 
  contentType: ContentType, messageType: int): Item =
  result = Item()
  result.id = id
  result.responseToMessageWithId = responseToMessageWithId
  result.senderId = senderId
  result.senderDisplayName = senderDisplayName
  result.senderLocalName = senderLocalName
  result.amISender = amISender
  result.senderIcon = senderIcon
  result.isSenderIconIdenticon = isSenderIconIdenticon
  result.seen = seen
  result.outgoingStatus = outgoingStatus
  result.messageText = text
  result.messageImage = image
  result.timestamp = timestamp
  result.contentType = contentType
  result.messageType = messageType
  result.pinned = false
  result.reactionsModel = newMessageReactionModel()

proc `$`*(self: Item): string =
  result = fmt"""Item(
    id: {$self.id}, 
    responseToMessageWithId: {self.responseToMessageWithId},
    senderId: {self.senderId},
    senderDisplayName: {$self.senderDisplayName},
    senderLocalName: {self.senderLocalName},
    amISender: {$self.amISender},
    isSenderIconIdenticon: {$self.isSenderIconIdenticon},
    seen: {$self.seen},
    outgoingStatus:{$self.outgoingStatus},
    messageText:{self.messageText},
    messageImage:{self.messageImage},
    timestamp:{$self.timestamp},
    contentType:{$self.contentType.int},
    messageType:{$self.messageType},
    pinned:{$self.pinned},
    messageReactions: [{$self.reactionsModel}]
    )"""

proc id*(self: Item): string {.inline.} = 
  self.id

proc responseToMessageWithId*(self: Item): string {.inline.} = 
  self.responseToMessageWithId

proc senderId*(self: Item): string {.inline.} = 
  self.senderId

proc senderDisplayName*(self: Item): string {.inline.} = 
  self.senderDisplayName

proc senderLocalName*(self: Item): string {.inline.} = 
  self.senderLocalName

proc senderIcon*(self: Item): string {.inline.} = 
  self.senderIcon

proc isSenderIconIdenticon*(self: Item): bool {.inline.} = 
  self.isSenderIconIdenticon

proc amISender*(self: Item): bool {.inline.} = 
  self.amISender

proc outgoingStatus*(self: Item): string {.inline.} = 
  self.outgoingStatus

proc messageText*(self: Item): string {.inline.} = 
  self.messageText

proc messageImage*(self: Item): string {.inline.} = 
  self.messageImage

proc stickerPack*(self: Item): int {.inline.} = 
  self.stickerPack

proc stickerHash*(self: Item): string {.inline.} = 
  self.stickerHash

proc seen*(self: Item): bool {.inline.} = 
  self.seen

proc timestamp*(self: Item): int64 {.inline.} = 
  self.timestamp

proc contentType*(self: Item): ContentType {.inline.} = 
  self.contentType

proc messageType*(self: Item): int {.inline.} = 
  self.messageType

proc pinned*(self: Item): bool {.inline.} = 
  self.pinned

proc `pinned=`*(self: Item, value: bool) {.inline.} = 
  self.pinned = value

proc reactionsModel*(self: Item): MessageReactionModel {.inline.} = 
  self.reactionsModel

proc shouldAddReaction*(self: Item, emojiId: EmojiId, userPublicKey: string): bool = 
  return self.reactionsModel.shouldAddReaction(emojiId, userPublicKey)

proc getReactionId*(self: Item, emojiId: EmojiId, userPublicKey: string): string = 
  return self.reactionsModel.getReactionId(emojiId, userPublicKey)

proc addReaction*(self: Item, emojiId: EmojiId, didIReactWithThisEmoji: bool, userPublicKey: string, 
  userDisplayName: string, reactionId: string) = 
  self.reactionsModel.addReaction(emojiId, didIReactWithThisEmoji, userPublicKey, userDisplayName, reactionId)

proc removeReaction*(self: Item, emojiId: EmojiId, reactionId: string) = 
  self.reactionsModel.removeReaction(emojiId, reactionId)

proc toJsonNode*(self: Item): JsonNode =
  result = %* {
    "id": self.id, 
    "responseToMessageWithId": self.responseToMessageWithId,
    "senderId": self.senderId, 
    "senderDisplayName": self.senderDisplayName,
    "senderLocalName": self.senderLocalName,
    "amISender": self.amISender, 
    "senderIcon": self.senderIcon,
    "isSenderIconIdenticon": self.isSenderIconIdenticon,
    "seen": self.seen, 
    "outgoingStatus": self.outgoingStatus,
    "messageText": self.messageText,
    "messageImage": self.messageImage,
    "stickerHash": self.stickerHash,
    "stickerPack": self.stickerPack,
    "gapFrom": self.gapFrom,
    "gapTo": self.gapTo,
    "timestamp": self.timestamp,
    "contentType": self.contentType.int,
    "messageType": self.messageType,
    "pinned": self.pinned
  }