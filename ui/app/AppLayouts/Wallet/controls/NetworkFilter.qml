import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import utils 1.0

import "../popups"

Item {
    id: root
    implicitWidth: 130
    implicitHeight: parent.height

    required property var allNetworks
    required property var enabledNetworks
    property bool areTestNetworksEnabled: false

    property bool isChainVisible: true
    property bool multiSelection: true

    signal toggleNetwork(int chainId, bool newState)
    signal singleNetworkSelected(int chainId, string chainName, string chainIcon)

    QtObject {
        id: d

        property string selectedChainName: ""
        property string selectedIconUrl: ""
    }

    Item {
        id: selectRectangleItem

        width: parent.width
        height: 56

        // FIXME this should be a (styled) ComboBox
        StatusListItem {
            implicitWidth: parent.width
            implicitHeight: 40
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1
            border.color: Theme.palette.directColor7
            color: "transparent"
            objectName: "networkSelectorButton"
            leftPadding: 12
            rightPadding: 12
            statusListItemTitle.font.pixelSize: 13
            statusListItemTitle.font.weight: Font.Medium
            statusListItemTitle.color: Theme.palette.baseColor1
            title: root.multiSelection ? (root.enabledNetworks.count === root.allNetworks.count ? qsTr("All networks") : qsTr("%n network(s)", "", root.enabledNetworks.count)) :
                                         d.selectedChainName
            asset.height: 24
            asset.width: asset.height
            asset.isImage: !root.multiSelection
            asset.name: !root.multiSelection ? Style.svg(d.selectedIconUrl) : ""
            components:[
                StatusIcon {
                    width: 16
                    height: 16
                    icon: "chevron-down"
                    color: Theme.palette.baseColor1
                }
            ]

            onClicked: {
                selectPopupLoader.active = !selectPopupLoader.active
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.halfPadding
        spacing: Style.current.smallPadding
        visible: root.isChainVisible && chainRepeater.count > 0

        Repeater {
            id: chainRepeater
            model: root.enabledNetworks
            delegate: InformationTag {
                tagPrimaryLabel.text: model.shortName
                tagPrimaryLabel.color: model.chainColor
                image.source: Style.svg("tiny/" + model.iconUrl)
            }
        }
    }

    Loader {
        id: selectPopupLoader

        active: false

        sourceComponent: NetworkSelectPopup {
            id: selectPopup

            x: (parent.width - width + 5)
            y: (selectRectangleItem.height + 5)

            allAvailableNetworks: root.allNetworks
            enabledNetworksModel: root.enabledNetworks
            areTestNetworksEnabled: root.areTestNetworksEnabled

            multiSelection: root.multiSelection

            onToggleNetwork: (network, newState) => {
                root.toggleNetwork(network.chainId, newState)
            }

            onSingleNetworkSelected: {
                d.selectedChainName = chainName
                d.selectedIconUrl = iconUrl
                root.singleNetworkSelected(chainId, chainName, iconUrl)
            }

            onClosed: selectPopupLoader.active = false
        }

        onLoaded: item.open()
    }
}
