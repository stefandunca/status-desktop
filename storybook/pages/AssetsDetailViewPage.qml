import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import AppLayouts.Wallet 1.0

import shared.stores 1.0

import utils 1.0

Item {
    id: root

    Component.onCompleted: {
        RootStore.getNetworkIconUrl = function(symbol) {
            return "images/networks/" + symbol + ".svg"
        }
        RootStore.getNetworkName = function(chainId) {
            return "Storynet"
        }
        RootStore.marketHistoryIsLoading = false
    }
    property var walletSectionAllTokens: QtObject {
        // TODO
    }

    ColumnLayout {
        anchors.fill: parent

        AssetsDetailView {
            balanceStore: TokenBalanceHistoryStore {
            }
            token: QtObject {

            }
            address: "0x1234567890123456789012345678901234567890"
        }
    }
}

//category: Views
