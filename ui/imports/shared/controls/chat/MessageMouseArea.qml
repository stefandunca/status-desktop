import QtQuick 2.13

import utils 1.0
import shared 1.0

MouseArea {
    id: mouseArea
    z: 50
    enabled: !placeholderMessage

//TODO remove dynamic scoping
//    property bool isHovered: false
//    property bool isSticker: false
//    property bool placeholderMessage: false
//    property var isMessageActive
    property bool isActivityCenterMessage: false
    property var messageContextMenu
    signal setMessageActive(string messageId, bool active)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage)

    cursorShape: !enabled ? Qt.PointingHandCursor : undefined

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: {
        if (isActivityCenterMessage) {
            mouseArea.clickMessage(false, isSticker, false)
            return
        }
        if (mouse.button === Qt.RightButton) {
            if (!!mouseArea.messageContextMenu) {
                // Set parent, X & Y positions for the messageContextMenu
                messageContextMenu.parent = root
                messageContextMenu.setXPosition = function() { return (mouse.x)};
                messageContextMenu.setYPosition = function() { return (mouse.y)};
            }
            mouseArea.clickMessage(false, isSticker, false)
            if (typeof isMessageActive !== "undefined") {
                setMessageActive(messageId, true)
            }
            return;
        }
        if (mouse.button === Qt.LeftButton && isSticker && stickersLoaded) {
            if (isHovered) {
                isHovered = false;
            }
            //TODO remove dynamic scoping
            Global.openPopup(statusStickerPackClickPopup, {packId: stickerPackId} )
            return;
        }
    }
}
