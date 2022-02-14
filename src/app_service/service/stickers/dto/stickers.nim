{.used.}

import json, strformat, strutils, stint, json_serialization

include ../../../common/json_utils
include ../../../common/utils

type StickerDto* = object
  hash*: string
  packId*: string
  url*: string

type StickerPackDto* = object
  id*: string
  name*: string
  author*: string
  price*: Stuint[256]
  preview*: string
  stickers*: seq[StickerDto]
  thumbnail*: string


proc `$`(self: StickerDto): string =
  result = fmt"""StickerDto(
    hash: {self.hash},
    packId: {$self.packId},
    ]"""

proc `$`*(self: StickerPackDto): string =
  result = fmt"""StickerPackDto(
    id: {$self.id},
    name: {self.name},
    author: {self.author},
    price: {$self.price},
    preview: {self.preview},
    stickersLen: {$self.stickers.len},
    thumbnail:{self.thumbnail}
    )"""


proc `%`*(stuint256: Stuint[256]): JsonNode =
  newJString($stuint256)

proc readValue*(reader: var JsonReader, value: var Stuint[256])
               {.raises: [IOError, SerializationError, Defect].} =
  try:
    let strVal = reader.readValue(string)
    value = strVal.parse(Stuint[256])
  except:
    try:
      let intVal = reader.readValue(int)
      value = intVal.stuint(256)
    except:
      raise newException(SerializationError, "Expected string or int representation of Stuint[256]")

proc toStickerDto*(jsonObj: JsonNode): StickerDto =
  result = StickerDto()
  discard jsonObj.getProp("hash", result.hash)
  discard jsonObj.getProp("packID", result.packId)
  discard jsonObj.getProp("url", result.url)

proc toStickerPackDto*(jsonObj: JsonNode): StickerPackDto =
  result = StickerPackDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("author", result.author)
  discard jsonObj.getProp("preview", result.preview)
  discard jsonObj.getProp("thumbnail", result.thumbnail)

  result.price = jsonObj["price"].getStr().parse(Stuint[256])
  result.stickers = @[]
  for sticker in jsonObj["stickers"]:
    result.stickers.add(sticker.toStickerDto)
