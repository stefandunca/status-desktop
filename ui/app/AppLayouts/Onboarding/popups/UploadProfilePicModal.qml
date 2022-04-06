import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

StatusModal {
    id: popup
    height: 510
    header.title: qsTr("Upload profile picture")

    property string selectedImage
    property string uploadError

    signal accepted()

    onOpened: {
        selectedImage = ""
    }

    contentItem: Item {
        anchors.fill: parent
        RoundedImage {
            id: profilePic
            source: selectedImage
            width: 160
            height: 160
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            border.width: 1
            border.color: Style.current.border
            onClicked: imageDialog.open();
        }

        StyledText {
            visible: !!uploadError
            text: uploadError
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: profilePic.bottom
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            anchors.topMargin: 13
            font.weight: Font.Thin
            color: Style.current.danger
        }

        ImageCropperModal {
            id: cropImageModal
            ratio: "1:1"
            onCropFinished: {
                popup.selectedImage = selectedImage
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: uploadBtn
            text: !!selectedImage ? qsTr("Done") : qsTr("Upload")
            onClicked: {
                if (!!selectedImage) {
                    popup.accepted()
                    close();
                } else {
                    imageDialog.open();
                }
            }
            FileDialog {
                id: imageDialog
                title: qsTrId("please-choose-an-image")
                folder: shortcuts.pictures
                nameFilters: [
                    qsTrId("image-files----jpg---jpeg---png-")
                ]
                onAccepted: {
                    cropImageModal.selectedImage = imageDialog.fileUrls[0];
                    cropImageModal.open()
                }
            }
        }
    ]
}

