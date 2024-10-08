import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

MouseArea {
    id: root
    implicitHeight: 50

    hoverEnabled: true

    required property string name
    required property string url
    required property string iconUrl

    signal disconnectDapp(string dappUrl)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32

            StatusImage {
                id: iconImage

                anchors.fill: parent

                source: root.iconUrl
                visible: !fallbackImage.visible
            }

            StatusSmartIdenticon {
                id: fallbackImage

                anchors.fill: parent

                name: dAppCaption.text ?? "dapp"
                asset.charactersLen: 2
                asset.color: Theme.palette.primaryColor1
                asset.letterIdenticonBgWithAlpha: true
                asset.useAcronymForLetterIdenticon: false

                visible: iconImage.isLoading || iconImage.isError || !root.iconUrl
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: iconImage.width
                    height: iconImage.height
                    radius: width / 2
                    visible: false
                }
            }
        }

        ColumnLayout {
            Layout.leftMargin: 12
            Layout.rightMargin: 12

            StatusBaseText {
                id: dAppCaption

                text: root.name ? root.name : SQUtils.StringUtils.extractDomainFromLink(root.url)

                Layout.fillWidth: true

                font.pixelSize: 13
                font.bold: true

                elide: Text.ElideRight

                clip: true
            }
            StatusBaseText {
                text: root.url

                Layout.fillWidth: true

                font.pixelSize: 12
                color: Theme.palette.baseColor1

                elide: Text.ElideRight

                clip: true
            }
        }

        StatusFlatButton {
            size: StatusBaseButton.Size.Large

            asset.color: root.containsMouse ? Theme.palette.directColor1
                                            : Theme.palette.baseColor1

            icon.name: "disconnect"
            tooltip.text: qsTr("Disconnect dApp")

            onClicked: {
                root.disconnectDapp(root.url)
            }
        }
    }
}
