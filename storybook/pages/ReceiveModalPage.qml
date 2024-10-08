import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import SortFilterProxyModel 0.2

import StatusQ.Core.Utils 0.1

import Storybook 1.0
import Models 1.0
import AppLayouts.Wallet.popups 1.0

SplitView {
    orientation: Qt.Horizontal

    PopupBackground {
        id: popupBg

        property var popupIntance: null

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !dialog.visible

            onClicked: dialog.open()
        }

        ReceiveModal {
            id: dialog

            visible: true
            accounts: WalletAccountsModel {
                id: accountsModel
            }
            selectedAccount: {
                "name": "Hot wallet (generated)",
                "emoji": "🚗",
                "color": "#216266",
                "address": "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                "preferredSharingChainIds": "5:420:421613",
            }
            switchingAccounsEnabled: true
            changingPreferredChainsEnabled: true
            hasFloatingButtons: true
            qrImageSource: "https://upload.wikimedia.org/wikipedia/commons/4/41/QR_Code_Example.svg"
            getNetworkShortNames: function (chainIDsString) {
                let chainArray = chainIDsString.split(":")
                let chainNameString = ""
                for (let i =0; i<chainArray.length; i++) {
                    chainNameString += NetworksModel.getShortChainName(Number(chainArray[i])) + ":"
                }
                return chainNameString
            }

            property string networksNames: "oeth:arb1:eth:"

            store: QtObject {
                property var filteredFlatModel: SortFilterProxyModel {
                    sourceModel: NetworksModel.flatNetworks
                    filters: ValueFilter { roleName: "isTest"; value: false }
                }

                function getAllNetworksChainIds() {
                    let result = []
                    let chainIdsArray = ModelUtils.modelToFlatArray(filteredFlatModel, "chainId")
                    for(let i = 0; i< chainIdsArray.length; i++) {
                        result.push(chainIdsArray[i].toString())
                    }
                    return result
                }

                function getNetworkIds(chainShortNames) {
                    let result = ""
                    if (!chainShortNames) return result

                    let shortNames = chainShortNames.split(":").filter((shortName) => shortName.length > 0)
                    for(let i = 0; i< shortNames.length; i++) {
                        let chainId = ModelUtils.getByKey(NetworksModel.flatNetworks, "shortName", shortNames[i]).chainId
                        result += ":" + chainId.toString()
                    }
                    return result
                }

                function addressWasShown(account) {
                    return true
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Column {
            spacing: 12

            Label {
                text: "Test extended footer"
                font.bold: true
            }

            Column {
                RadioButton {
                    text: "Medium length address"
                    onCheckedChanged: {
                        dialog.networksNames = "oeth:arb1:eth:arb1:solana:status:other:"
                    }
                }

                RadioButton {
                    text: "Super long address"
                    onCheckedChanged: {
                        dialog.networksNames = "oeth:arb1:eth:arb1:solana:status:other:something:hey:whatsapp:tele:viber:do:it:now:blackjack:some:black:number:check:it:out:heyeey:dosay:what:are:you:going:to:do:with:me:forever:young:michael:jackson:super:long:string:crasy:daisy:this:is:amazing:whatever:you:do:whenever:you:go:"
                    }
                }

                RadioButton {
                    checked: true
                    text: "Short address"
                    onCheckedChanged: {
                        dialog.networksNames = "oeth:arb1:eth:"
                    }
                }
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=20734-337595&mode=design&t=2O68lxNGG9g1b1tx-4
