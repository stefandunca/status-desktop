import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.controls 1.0

import Models 1.0

import SortFilterProxyModel 0.2

SplitView {
    id: root

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            id: controlLayout

            anchors.fill: parent

            NetworkFilter {
                id: networkFilter

                Layout.fillWidth: true
                Layout.preferredHeight: 40

                allNetworks: simulatedNetworks
                enabledNetworks: SortFilterProxyModel {
                    sourceModel: simulatedNetworks
                    filters: ValueFilter { roleName: "isEnabled";  value: true; }
                }
                areTestNetworksEnabled: testModeCheckbox.checked

                onToggleNetwork: (chainId, newState) => root.setNetworkState(chainId, newState)
            }

            // Dummy item to make space for popup
            Item {
                id: popupPlaceholder

                Layout.preferredWidth: networkSelectPopup.width
                Layout.preferredHeight: networkSelectPopup.height

                NetworkSelectPopup {
                    id: networkSelectPopup

                    readonly property point relPos: popupPlaceholder.mapToItem(Overlay.overlay, 0, 0)

                    x: relPos.x
                    y: relPos.y

                    allAvailableNetworks: simulatedNetworks
                    enabledNetworksModel: networkFilter.enabledNetworks
                    areTestNetworksEnabled: testModeCheckbox.checked

                    visible: true
                    closePolicy: Popup.NoAutoClose

                    // Simulates a network toggle
                    onToggleNetwork: (network, newState) => root.setNetworkState(network.chainId, newState)
                }
            }

            // Vertical separator
            ColumnLayout {}


            RowLayout {
                Label {
                    text: "TODOInfo??"
                }
            }
        }

        // Simulate composing of networks
        SortFilterProxyModel {
            id: simulatedNetworks

            sourceModel: NetworksModel.allNetworks

            // Simulate Nim's way of providing access to data
            function rowData(index, propName) {
                return get(index)[propName]
            }

            filters: ValueFilter { roleName: "isTest"; value: testModeCheckbox.checked; }
        }
    }
    Pane {
        SplitView.minimumWidth: 300
        SplitView.fillWidth: true
        SplitView.minimumHeight: 300

        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: allNetworksListView

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: simulatedNetworks

                delegate: ItemDelegate {
                    width: allNetworksListView.width
                    implicitHeight: delegateRowLayout.implicitHeight

                    highlighted: ListView.isCurrentItem

                    RowLayout {
                        id: delegateRowLayout
                        anchors.fill: parent

                        Column {
                            Layout.margins: 5

                            spacing: 3

                            Label { text: model.chainName }

                            Row {
                                spacing: 5
                                Label { text: `<b>${model.shortName}</b>` }
                                Label { text: `ID <b>${model.chainId}</b>` }
                                CheckBox {
                                    checkState: model.isEnabled ? Qt.Checked : Qt.Unchecked
                                    tristate: true
                                    nextCheckState: () => {
                                        model.isEnabled = (checkState !== Qt.Checked)
                                        return model.isEnabled ? Qt.Checked : Qt.Unchecked
                                    }
                                }
                            }
                        }
                    }

                    onClicked: allNetworksListView.currentIndex = index
                }
            }
            CheckBox {
                id: testModeCheckbox

                Layout.margins: 5

                text: "Test Networks Mode"
                checked: false
            }
        }
    }

    function setNetworkState(chainId, newState) {
        for (let i = 0; i < simulatedNetworks.count; i++) {
            if (chainId === simulatedNetworks.get(i).chainId) {
                NetworksModel.allNetworks.setProperty(simulatedNetworks.mapToSource(i), "isEnabled", newState)
                break
            }
        }
    }

}
