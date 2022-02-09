{.used.}

import json

type
  NotificationType* {.pure.} = enum
    NewContactRequest = 1,
    AcceptedContactRequest,
    JoinCommunityRequest,
    MyRequestToJoinCommunityAccepted,
    MyRequestToJoinCommunityRejected,
    NewMessage,
    NewMention

  NotificationDetails* = object
    notificationType*: NotificationType
    sectionId*: string
    chatId*: string
    messageId*: string

proc toNotificationDetails*(json: JsonNode): NotificationDetails =
  if (not (json.contains("notificationType") and
    json.contains("communityId") and
    json.contains("channelId") and
    json.contains("messageId"))):
    return NotificationDetails()

  return NotificationDetails(
    notificationType: json{"notificationType"}.getInt.NotificationType,
    sectionId: json{"communityId"}.getStr,
    chatId: json{"channelId"}.getStr,
    messageId: json{"messageId"}.getStr
  )

proc toJsonNode*(self: NotificationDetails): JsonNode =
  result = %* {
    "notificationType": self.notificationType.int,
    "communityId": self.sectionId,
    "channelId": self.chatId,
    "messageId": self.messageId
  }
