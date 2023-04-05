pragma Singleton

import QtQuick 2.15

Item {
    id: root

    readonly property QtObject allTestNetworks: QtObject {
        readonly property ChainEntry eth: ChainEntry {
            chainId: 1
            chainName: "Ethereum Mainnet"
            shortName: "ETH"
            chainColor: "#627EEA"
        }
        readonly property ChainEntry goerli: ChainEntry {
            chainId: 5
            chainName: "Goerli"
            shortName: "goEth"
            chainColor: "#939BA1"
            isTest: true
        }
        readonly property ChainEntry optimism: ChainEntry {
            chainId: 10
            layer: 2
            chainName: "Optimism"
            shortName: "opt"
            chainColor: "#E90101"
        }
        readonly property ChainEntry goOpt: ChainEntry {
            chainId: 420
            layer: 2
            chainName: "Optimism Goerli Testnet"
            shortName: "goOpt"
            chainColor: "#939BA1"
            isTest: true
        }
        readonly property ChainEntry arbitrum: ChainEntry {
            chainId: 42161
            layer: 2
            chainName: "Arbitrum"
            shortName: "arb"
            chainColor: "#51D0F0"
        }
        readonly property ChainEntry goArb: ChainEntry {
            chainId: 421613
            layer: 2
            chainName: "Arbitrum Goerli"
            shortName: "goArb"
            chainColor: "purple"
            isTest: true
        }
    }

    component ChainEntry: QtObject {
            required property int chainId
            property int layer: 1
            required property string chainName
            property string iconUrl: "network/Network=Testnet"
            property bool isEnabled: true
            required property string shortName
            property color chainColor: "fuchsia"
            property bool isTest: false
        }

    Component {
        id: listModelComponent
        ListModel {
            // Simulate Nim's way of providing access to data
            function rowData(index, propName) {
                return get(index)[propName]
            }
        }
    }

    function generateListModel(networks) {
        var model = listModelComponent.createObject(root)
        for(var obj of networks) {
            model.append(obj)
        }
        return model
    }
}
