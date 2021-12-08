import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"
import "../stores"

ColumnLayout {
    id: chatContentRoot
    spacing: 0

    // Important:
    // Each chat/channel has its own ChatContentModule
    property var chatContentModule
    property var rootStore
    property var contactsStore

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    property bool stickersLoaded: false

    StatusChatToolBar {
        id: topBar
        Layout.fillWidth: true

        chatInfoButton.title: chatContentModule? chatContentModule.chatDetails.name : ""
        chatInfoButton.subTitle: {
            if(!chatContentModule)
                return ""

            // In some moment in future this should be part of the backend logic.
            // (once we add transaltion on the backend side)
            switch (chatContentModule.chatDetails.type) {
            case Constants.chatType.oneToOne:
                return (chatContentModule.isMyContact(chatContentModule.chatDetails.id) ?
                            //% "Contact"
                            qsTrId("chat-is-a-contact") :
                            //% "Not a contact"
                            qsTrId("chat-is-not-a-contact"))
            case Constants.chatType.publicChat:
                //% "Public chat"
                return qsTrId("public-chat")
            case Constants.chatType.privateGroupChat:
                let cnt = chatContentModule.usersModule.model.count
                //% "%1 members"
                if(cnt > 1) return qsTrId("-1-members").arg(cnt);
                //% "1 member"
                return qsTrId("1-member");
            case Constants.chatType.communityChat:
                return Utils.linkifyAndXSS(chatContentModule.chatDetails.description).trim()
            default:
                return ""
            }
        }
        chatInfoButton.image.source: chatContentModule? chatContentModule.chatDetails.icon : ""
        chatInfoButton.image.isIdenticon: chatContentModule? chatContentModule.chatDetails.isIdenticon : false
        chatInfoButton.icon.color: chatContentModule? chatContentModule.chatDetails.color : ""
        chatInfoButton.type: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown
        chatInfoButton.pinnedMessagesCount: chatContentModule? chatContentModule.pinnedMessagesModel.count : 0
        chatInfoButton.muted: chatContentModule? chatContentModule.chatDetails.muted : false

        chatInfoButton.onPinnedMessagesCountClicked: {
            if(!chatContentModule) {
                console.debug("error on open pinned messages - chat content module is not set")
                return
            }
            Global.openPopup(pinnedMessagesPopupComponent, {
                                 store: rootStore,
                                 messageStore: messageStore,
                                 pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                 messageToPin: ""
                             })
        }
        chatInfoButton.onUnmute: {
            if(!chatContentModule) {
                console.debug("error on unmute chat - chat content module is not set")
                return
            }
            chatContentModule.unmuteChat()
        }

        chatInfoButton.sensor.enabled: {
            if(!chatContentModule)
                return false

            return chatContentModule.chatDetails.type !== Constants.chatType.publicChat &&
                    chatContentModule.chatDetails.type !== Constants.chatType.communityChat
        }
        chatInfoButton.onClicked: {
            switch (chatContentModule.chatDetails.type) {
            case Constants.chatType.privateGroupChat:
                Global.openPopup(groupInfoPopupComponent, {
                              channelType: GroupInfoPopup.ChannelType.ActiveChannel,
                              channel: chatContentModule.chatDetails
                          })
                break;
            case Constants.chatType.oneToOne:
                Global.openProfilePopup(chatContentModule.chatDetails.id)
                break;
            }
        }

        membersButton.visible: {
            if(!chatContentModule)
                return false

            return localAccountSensitiveSettings.showOnlineUsers &&
                    chatContentModule.chatDetails.isUsersListAvailable
        }
        membersButton.highlighted: localAccountSensitiveSettings.expandUsersList
        notificationButton.visible: localAccountSensitiveSettings.isActivityCenterEnabled
        notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList ? 0 : 14

        notificationCount: {
            if(!chatContentModule)
                return 0

            return chatContentModule.chatDetails.notificationCount
        }

        onSearchButtonClicked: root.openAppSearch()

        onMembersButtonClicked: localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList
        onNotificationButtonClicked: activityCenter.open()

        popupMenu: ChatContextMenuView {
            openHandler: function () {
                if(!chatContentModule) {
                    console.debug("error on open chat context menu handler - chat content module is not set")
                    return
                }
                currentFleet = chatContentModule.getCurrentFleet()
                isCommunityChat = chatContentModule.chatDetails.belongsToCommunity
                amIChatAdmin = chatContentModule.amIChatAdmin()
                chatId = chatContentModule.chatDetails.id
                chatName = chatContentModule.chatDetails.name
                chatDescription = chatContentModule.chatDetails.description
                chatType = chatContentModule.chatDetails.type
                chatMuted = chatContentModule.chatDetails.muted
            }

            onMuteChat: {
                if(!chatContentModule) {
                    console.debug("error on mute chat from context menu - chat content module is not set")
                    return
                }
                chatContentModule.muteChat()
            }

            onUnmuteChat: {
                if(!chatContentModule) {
                    console.debug("error on unmute chat from context menu - chat content module is not set")
                    return
                }
                chatContentModule.unmuteChat()
            }

            onMarkAllMessagesRead: {
                if(!chatContentModule) {
                    console.debug("error on mark all messages read from context menu - chat content module is not set")
                    return
                }
                chatContentModule.markAllMessagesRead()
            }

            onClearChatHistory: {
                if(!chatContentModule) {
                    console.debug("error on clear chat history from context menu - chat content module is not set")
                    return
                }
                chatContentModule.clearChatHistory()
            }

            onRequestAllHistoricMessages: {
                // Not Refactored Yet - Check in the `master` branch if this is applicable here.
            }

            onLeaveChat: {
                if(!chatContentModule) {
                    console.debug("error on leave chat from context menu - chat content module is not set")
                    return
                }
                chatContentModule.leaveChat()
            }

            onDeleteChat: root.rootStore.removeChat(chatId)

            onDownloadMessages: {
                // Not Refactored Yet
            }

            onDisplayProfilePopup: {
                Global.openProfilePopup(publicKey)
            }

            onDisplayGroupInfoPopup: {
                Global.openPopup(groupInfoPopupComponent, {
                              channelType: GroupInfoPopup.ChannelType.ActiveChannel,
                              channel: chatContentModule.chatDetails
                          })
            }

            onEditCommunityChannel: {
                // Not Refactored Yet
            }

            onOpenPinnedMessagesList: {
                if(!chatContentModule) {
                    console.debug("error on open pinned messages from context menu - chat content module is not set")
                    return
                }
                Global.openPopup(pinnedMessagesPopupComponent, {
                                     store: rootStore,
                                     messageStore: messageStore,
                                     pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                     messageToPin: ""
                                 })
            }
        }
    }

    Rectangle {
        id: connectedStatusRect
        Layout.fillWidth: true
        height: 40
        Layout.alignment: Qt.AlignHCenter
        z: 60
        visible: false
        color: isConnected ? Style.current.green : Style.current.darkGrey
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
            id: connectedStatusLbl
            text: isConnected ?
                      //% "Connected"
                      qsTrId("connected") :
                      //% "Disconnected"
                      qsTrId("disconnected")
        }

        // Not Refactored Yet
        //        Connections {
        //            target: chatContentRoot.rootStore.chatsModelInst
        //            onOnlineStatusChanged: {
        //                if (connected == isConnected) return;
        //                isConnected = connected;
        //                if(isConnected){
        //                    timer.setTimeout(function(){
        //                        connectedStatusRect.visible = false;
        //                    }, 5000);
        //                } else {
        //                    connectedStatusRect.visible = true;
        //                }
        //            }
        //        }
        //        Component.onCompleted: {
        //            isConnected = chatContentRoot.rootStore.chatsModelInst.isOnline
        //            if(!isConnected){
        //                connectedStatusRect.visible = true
        //            }
        //        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignHCenter
        visible: isBlocked

        Rectangle {
            id: blockedBanner
            anchors.fill: parent
            color: Style.current.red
            opacity: 0.1
        }

        Text {
            id: blockedText
            anchors.centerIn: blockedBanner
            color: Style.current.red
            text: qsTr("Blocked")
        }
    }

    MessageStore{
        id: messageStore
        messageModule: chatContentModule? chatContentModule.messagesModule : null
    }

    MessageContextMenuView {
        id: contextmenu
        store: chatContentRoot.rootStore
        reactionModel: chatContentRoot.rootStore.emojiReactionsModel
        onPinMessage: {
            messageStore.pinMessage(messageId)
        }

        onUnpinMessage: {
            messageStore.unpinMessage(messageId)
        }

        onPinnedMessagesLimitReached: {
            if(!chatContentModule) {
                console.debug("error on open pinned messages limit reached from message context menu - chat content module is not set")
                return
            }
            Global.openPopup(pinnedMessagesPopupComponent, {
                                 store: rootStore,
                                 messageStore: messageStore,
                                 pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                 messageToPin: messageId
                             })
        }

        onToggleReaction: {
            messageStore.toggleReaction(messageId, emojiId)
        }

        onOpenProfileClicked: {
            Global.openProfilePopup(publicKey)
        }

        onDeleteMessage: {
            messageStore.deleteMessage(messageId)
        }

        onEditClicked: messageStore.setEditModeOn(messageId)
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ChatMessagesView {
            id: chatMessages
            Layout.fillWidth: true
            Layout.fillHeight: true
            store: chatContentRoot.rootStore
            contactsStore: chatContentRoot.contactsStore
            messageContextMenuInst: contextmenu
            messageStore: messageStore
            stickersLoaded: chatContentRoot.stickersLoaded
            onShowReplyArea: {
                let obj = messageStore.getMessageByIdAsJson(messageId)
                if (!obj) {
                    return
                }
                chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.senderIcon, obj.contentType, obj.messageImage, obj.sticker)

            }
        }

        Item {
            id: inputArea
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: chatInput.height
            Layout.preferredHeight: height

            // Not Refactored Yet
            //            Connections {
            //                target: chatContentRoot.rootStore.chatsModelInst.messageView
            //                onLoadingMessagesChanged:
            //                    if(value){
            //                        loadingMessagesIndicator.active = true
            //                    } else {
            //                        timer.setTimeout(function(){
            //                            loadingMessagesIndicator.active = false;
            //                        }, 5000);
            //                    }
            //            }

            // Not Refactored Yet
            //            Loader {
            //                id: loadingMessagesIndicator
            //                active: chatContentRoot.rootStore.chatsModelInst.messageView.loadingMessages
            //                sourceComponent: loadingIndicator
            //                anchors.right: parent.right
            //                anchors.bottom: chatInput.top
            //                anchors.rightMargin: Style.current.padding
            //                anchors.bottomMargin: Style.current.padding
            //            }

            //            Component {
            //                id: loadingIndicator
            //                LoadingAnimation { }
            //            }

            StatusChatInput {
                id: chatInput
                visible: {
                    // Not Refactored Yet
                    return true
                    //                if (chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.privateGroupChat) {
                    //                    return chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.isMember
                    //                }
                    //                if (chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.oneToOne) {
                    //                    return isContact
                    //                }
                    //                const community = chatContentRoot.rootStore.chatsModelInst.communities.activeCommunity
                    //                return !community.active ||
                    //                        community.access === Constants.communityChatPublicAccess ||
                    //                        community.admin ||
                    //                        chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.canPost
                }
                isContactBlocked: isBlocked
                chatInputPlaceholder: isBlocked ?
                                          //% "This user has been blocked."
                                          qsTrId("this-user-has-been-blocked-") :
                                          //% "Type a message."
                                          qsTrId("type-a-message-")
                anchors.bottom: parent.bottom
                recentStickers: chatContentRoot.rootStore.stickersModuleInst.recent
                stickerPackList: chatContentRoot.rootStore.stickersModuleInst.stickerPacks
                chatType: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown
                onSendTransactionCommandButtonClicked: {
                    if(!chatContentModule) {
                        console.debug("error on sending transaction command - chat content module is not set")
                        return
                    }

                    if (Utils.getContactDetailsAsJson(chatContentModule.getMyChatId()).ensVerified) {
                        Global.openPopup(chatContentRoot.sendTransactionWithEnsModal)
                    } else {
                        Global.openPopup(chatContentRoot.sendTransactionNoEnsModal)
                    }
                }
                onReceiveTransactionCommandButtonClicked: {
                    Global.openPopup(chatContentRoot.receiveTransactionModal)
                }
                onStickerSelected: {
                    chatContentRoot.rootStore.sendSticker(chatContentModule.getMyChatId(),
                                                          hashId,
                                                          chatInput.isReply ? SelectedMessage.messageId : "",
                                                          packId)
                }
                onSendMessage: {
                    if(!chatContentModule) {
                        console.debug("error on sending message - chat content module is not set")
                        return
                    }

                    if (chatInput.fileUrls.length > 0){
                        chatContentModule.inputAreaModule.sendImages(JSON.stringify(fileUrls));
                    }
                    let msg = globalUtils.plainText(Emoji.deparse(chatInput.textInput.text))
                    if (msg.length > 0) {
                        msg = chatInput.interpretMessage(msg)

                        chatContentModule.inputAreaModule.sendMessage(
                                    msg,
                                    chatInput.isReply ? chatInput.replyMessageId : "",
                                    Utils.isOnlyEmoji(msg) ? Constants.messageContentType.emojiType : Constants.messageContentType.messageType,
                                    false)

                        if (event) event.accepted = true
                        sendMessageSound.stop();
                        Qt.callLater(sendMessageSound.play);

                        chatInput.textInput.clear();
                        chatInput.textInput.textFormat = TextEdit.PlainText;
                        chatInput.textInput.textFormat = TextEdit.RichText;
                    }
                }
            }
        }
    }
}
