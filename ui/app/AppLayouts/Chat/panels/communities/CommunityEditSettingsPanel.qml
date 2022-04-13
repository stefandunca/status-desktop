import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import "CommunityEditSettingsPanel"

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

Flickable {
    id: root

    property alias name: nameInput.text
    property alias description: descriptionTextInput.text
    property alias color: colorDialog.color
    property alias logoImage: addImageButton.selectedImage
    readonly property alias imageAx: imageCropperModal.aX
    readonly property alias imageAy: imageCropperModal.aY
    readonly property alias imageBx: imageCropperModal.bX
    readonly property alias imageBy: imageCropperModal.bY
    property alias bannerPath: bannerPreview.source
    property alias bannerCropRect: bannerPreview.cropRect
    property bool isCommunityHistoryArchiveSupportEnabled: false
    property alias communityHistoryArchiveSupportEnabled: historyArchiveSupportToggle.checked

    function setBannerCropRect(newRect) {
        bannerPreview.setCropRect(newRect)
    }

    contentWidth: layout.width
    contentHeight: layout.height
    clip: true
    interactive: contentHeight > height
    flickableDirection: Flickable.VerticalFlick

    ColumnLayout {
        id: layout

        width: root.width
        spacing: 12

        StatusInput {
            id: nameInput

            Layout.fillWidth: true

            leftPadding: 0
            rightPadding: 0
            label: qsTr("Community name")
            charLimit: 30
            input.placeholderText: qsTr("A catchy name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(nameInput.errors,
                                                        qsTr("community name"))
                }
            ]
            validationMode: StatusInput.ValidationMode.Always

            Component.onCompleted: nameInput.input.forceActiveFocus(Qt.MouseFocusReason)
        }

        StatusInput {
            id: descriptionTextInput

            Layout.fillWidth: true

            leftPadding: 0
            rightPadding: 0
            label: qsTr("Description")
            charLimit: 140

            input.placeholderText: qsTr("What your community is about")
            input.multiline: true
            input.implicitHeight: 88

            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(
                                      descriptionTextInput.errors,
                                      qsTr("community description"))
                }
            ]
            validationMode: StatusInput.ValidationMode.Always
        }

        ColumnLayout {
            spacing: 8

            StatusBaseText {
                text: qsTr("Community logo")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            Item {
                Layout.fillWidth: true

                implicitHeight: addImageButton.height + 32

                Rectangle {
                    id: addImageButton

                    property string selectedImage: ""

                    anchors.centerIn: parent
                    color: imagePreview.visible ? "transparent" : Style.current.inputBackground
                    width: 128
                    height: width
                    radius: width / 2

                    FileDialog {
                        id: imageDialog
                        title: qsTrId("Please choose an image")
                        folder: shortcuts.pictures
                        nameFilters: [qsTr("Image files (*.jpg *.jpeg *.png)")]
                        onAccepted: {
                            if(imageDialog.fileUrls.length > 0) {
                                addImageButton.selectedImage = imageDialog.fileUrls[0]
                                imageCropperModal.open()
                            }
                        }
                    }

                    Rectangle {
                        id: imagePreviewCropper
                        clip: true
                        width: parent.width
                        height: parent.height
                        radius: parent.width / 2
                        visible: !!addImageButton.selectedImage

                        Image {
                            id: imagePreview
                            visible: !!addImageButton.selectedImage
                            source: addImageButton.selectedImage
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            height: parent.height
                        }
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                anchors.centerIn: parent
                                width: imageCropperModal.width
                                height: imageCropperModal.height
                                radius: width / 2
                            }
                        }
                    }

                    NoImageUploadedPanel {
                        anchors.centerIn: parent

                        visible: !imagePreview.visible
                    }

                    StatusRoundButton {
                        type: StatusRoundButton.Type.Secondary
                        icon.name: "add"
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.halfPadding
                        highlighted: sensor.containsMouse
                    }

                    MouseArea {
                        id: sensor
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: imageDialog.open()
                    }

                    ImageCropperModal {
                        id: imageCropperModal
                        selectedImage: addImageButton.selectedImage
                        ratio: "1:1"
                    }
                }
            }

            // Banner
            //
            StatusBaseText {
                text: qsTr("Community banner")

                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            StatusImageCropPanel {
                id: bannerPreview

                visible: !bannerEditor.visible

                Layout.preferredWidth: 475
                Layout.preferredHeight: Layout.preferredWidth / aspectRatio
                Layout.alignment: Qt.AlignHCenter

                interactive: false
                wallColor: Theme.palette.statusAppLayout.backgroundColor
                wallTransparency: 1

                StatusRoundButton {
                    id: editButton

                    icon.name: "edit"

                    // bottom-right corner
                    x: bannerEditor.hasImage ? bannerPreview.cropWindow.x + bannerPreview.cropWindow.width - editButton.width/2 : 0
                    y: bannerEditor.hasImage ? bannerPreview.cropWindow.y + bannerPreview.cropWindow.height - Style.current.smallPadding - editButton.height/2: 0

                    highlighted: sensor.containsMouse
                    type: StatusRoundButton.Type.Secondary

                    onClicked: bannerFileDialog.open()
                }
            }

            Rectangle {
                id: bannerEditor

                Layout.preferredWidth: 475
                Layout.preferredHeight: 184
                Layout.alignment: Qt.AlignHCenter

                visible: !hasImage

                radius: 10
                color: Style.current.inputBackground

                property bool hasImage: false

                StatusRoundButton {
                    id: addButton

                    icon.name: "add"

                    // top-right corner
                    x: bannerEditor.width - Style.current.smallPadding - addButton.width/2
                    y: Style.current.smallPadding - addButton.height/2

                    highlighted: sensor.containsMouse
                    type: StatusRoundButton.Type.Secondary

                    onClicked: bannerFileDialog.open()
                    z: bannerEditor.z + 1
                }

                NoImageUploadedPanel {
                    anchors.centerIn: parent

                    visible: !bannerPreview.visible
                    showARHint: true
                }

                FileDialog {
                    id: bannerFileDialog

                    title: qsTr("Choose an image for banner")
                    folder: bannerEditor.hasImage ? bannerCropper.source.substr(0, bannerCropper.source.lastIndexOf("/")) : shortcuts.pictures
                    nameFilters: [qsTr("Image files (*.jpg *.jpeg *.png *.tiff *.heif)")]
                    onAccepted: {
                        if(bannerFileDialog.fileUrls.length > 0) {
                            bannerCropper.source = bannerFileDialog.fileUrls[0]
                            bannerCropperModal.open()
                        }
                    }
                    onRejected: {
                        if(bannerEditor.hasImage)
                            bannerCropperModal.open()
                    }
                }

                StatusModal {
                    id: bannerCropperModal

                    header.title: qsTr("Community banner")

                    anchors.centerIn: Overlay.overlay

                    Item {
                        implicitWidth: 480
                        implicitHeight: 350

                        anchors.fill: parent

                        ColumnLayout {
                            anchors.fill: parent

                            StatusImageCropPanel {
                                id: bannerCropper

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.leftMargin: Style.current.padding * 2
                                Layout.topMargin: Style.current.bigPadding
                                Layout.rightMargin: Layout.leftMargin
                                Layout.bottomMargin: Layout.topMargin

                                aspectRatio: 380/111

                                enableCheckers: true
                            }
                        }
                    }

                    rightButtons: [
                        StatusButton {
                            text: "Make this my Community banner"

                            enabled: bannerCropper.sourceSize.width > 0 && bannerCropper.sourceSize.height > 0

                            onClicked: {
                                bannerCropperModal.close()
                                bannerPreview.setCropRect(bannerCropper.cropRect)
                                bannerPreview.source = bannerCropper.source
                                bannerEditor.hasImage = true
                            }
                        }
                    ]
                }
            }

            Rectangle {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            StatusBaseText {
                text: qsTrId("Community colour")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            StatusPickerButton {
                Layout.fillWidth: true

                property string validationError: ""

                bgColor: colorDialog.colorSelected ? colorDialog.color : Theme.palette.baseColor2
                contentColor: colorDialog.colorSelected ? Theme.palette.indirectColor1 : Theme.palette.baseColor1
                text: colorDialog.colorSelected ? colorDialog.color.toString(
                                                      ).toUpperCase() : qsTr("Pick a color")

                onClicked: colorDialog.open()
                onTextChanged: {
                    if (colorDialog.colorSelected) {
                        validationError = Utils.validateAndReturnError(
                                    text,
                                    Utils.Validate.NoEmpty | Utils.Validate.TextHexColor)
                    }
                }

                ColorDialog {
                    id: colorDialog
                    property bool colorSelected: true
                    color: Theme.palette.primaryColor1
                    onAccepted: colorSelected = true
                }
            }
        }

        StatusListItem {
            Layout.fillWidth: true

            title: qsTrId("History Archive Support")

            visible: root.isCommunityHistoryArchiveSupportEnabled

            sensor.onClicked: {
                if (root.isCommunityHistoryArchiveSupportEnabled) {
                    historyArchiveSupportToggle.checked = !historyArchiveSupportToggle.checked
                }
            }

            components: [
                StatusSwitch {
                    id: historyArchiveSupportToggle
                    enabled: root.isCommunityHistoryArchiveSupportEnabled
                }
            ]
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

