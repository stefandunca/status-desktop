import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

import SortFilterProxyModel 0.2

import "NetworkSelectPopup" as Internals

StatusModal {
    id: root

    modal: false
    padding: 4

    width: 360
    height: Math.min(432, scrollView.contentHeight + root.padding)

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    required property var allAvailableNetworks
    required property var enabledNetworksModel
    property alias areTestNetworksEnabled: controller.areTestNetworksEnabled

    property bool canHaveEmptySelection: false


    // TODO: remove this soon
    // If true NetworksExtraStoreProxy expected for layer1Networks and layer2Networks properties
    property bool useNetworksExtraStoreProxy: false

    property bool multiSelection: true

    // TODO: rename toggle
    signal toggleNetwork(var network, bool newState)
    signal singleNetworkSelected(int chainId, string chainName, string iconUrl)

    Internals.Controller {
        id: controller

        allNetworksModel: root.allAvailableNetworks
        enabledNetworksModel: root.enabledNetworksModel

        onSetNetworkState: (modelData, newState) => root.toggleNetwork(modelData, newState)
    }

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow{
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    contentItem: StatusScrollView {
        id: scrollView

        width: root.width
        height: root.height
        contentHeight: content.height
        contentWidth: availableWidth
        padding: 0

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: content
            width: childrenRect.width
            spacing: 4

            Repeater {
                id: chainRepeater1

                width: parent.width
                height: parent.height

                objectName: "networkSelectPopupChainRepeaterLayer1"
                model: controller.layer1Networks

                delegate: chainItem
            }

            StatusBaseText {
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.baseColor1
                text: qsTr("Layer 2")
                height: 40
                leftPadding: 16
                topPadding: 10
                verticalAlignment: Text.AlignVCenter

                visible: chainRepeater2.count > 0
            }

            Repeater {
                id: chainRepeater2

                model: controller.layer2Networks
                delegate: chainItem
            }
        }
    }

    Component {
        id: chainItem

        StatusListItem {
            objectName: model.chainName
            implicitHeight: 48
            implicitWidth: scrollView.width
            title: model.chainName
            asset.height: 24
            asset.width: 24
            asset.isImage: true
            asset.name: Style.svg(model.iconUrl)
            onClicked: {
                if(root.multiSelection)
                    toggleModelIsActive()
                else {
                    // Don't allow uncheck
                    if(!radioButton.checked) radioButton.toggle()
                }
            }

            function toggleModelIsActive() {
                model.isActive = !model.isActive
            }

            components: [
                StatusCheckBox {
                    id: checkBox
                    tristate: true
                    visible: root.multiSelection

                    // TODO: remove this soon
                    //checked: root.useNetworksExtraStoreProxy ? model.isActive : model.isEnabled

                    checkState: controller.uxStateToCheckState(model.enabledState)
                    nextCheckState: () => {
                        controller.setUserIntention(model.specialIndex)
                        return Qt.PartiallyChecked
                    }
                },
                StatusRadioButton {
                    id: radioButton
                    visible: !root.multiSelection
                    size: StatusRadioButton.Size.Large
                    ButtonGroup.group: radioBtnGroup
                    checked: model.index === 0
                    onCheckedChanged: {
                        if(checked && !root.multiSelection) {
                            root.singleNetworkSelected(model.chainId, model.chainName, model.iconUrl)
                            close()
                        }
                    }
                }
            ]
        }
    }

    ButtonGroup {
        id: radioBtnGroup
    }
}
