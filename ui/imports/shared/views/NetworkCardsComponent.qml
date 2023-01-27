﻿import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../controls"

Item {
    id: root

    property var store
    property var bestRoutes
    property var selectedAccount
    property var selectedAsset
    property var allNetworks
    property bool customMode: false
    property var amountToSend
    property var requiredGasInEth
    property bool errorMode: !root.amountToSend || d.customAmountToSend > root.amountToSend.amount
    property bool interactive: true
    property bool showPreferredChains: false
    property var weiToEth: function(wei) {}
    property var reCalculateSuggestedRoute: function() {}
    property var getCryptoCurrencyAmount: function(cryptoValue) {}
    property int errorType: Constants.NoError
    property bool isLoading

    QtObject {
        id: d
        property double customAmountToSend: 0
        property bool thereIsApossibleRoute: false

        function resetAllSetValues() {
            for(var i = 0; i<fromNetworksRepeater.count; i++) {
                fromNetworksRepeater.itemAt(i).amountToSend = 0
                fromNetworksRepeater.itemAt(i).routeOnNetwork = 0
                toNetworksRepeater.itemAt(i).amountToReceive = 0
                toNetworksRepeater.itemAt(i).routeOnNetwork = 0
                toNetworksRepeater.itemAt(i).bentLine = 0
            }
        }

        function calculateCustomAmounts() {
            d.customAmountToSend = 0
            for(var i = 0; i<fromNetworksRepeater.count; i++) {
                if(fromNetworksRepeater.itemAt(i).locked) {
                    let amountEntered = fromNetworksRepeater.itemAt(i).advancedInputCurrencyAmount.amount
                    d.customAmountToSend += isNaN(amountEntered) ? 0 : amountEntered
                }
            }
        }

        function draw() {
            canvas.clear()
            canvas.requestPaint()
        }
    }

    onVisibleChanged: if(visible) d.draw()
    onBestRoutesChanged: d.draw()
    onErrorModeChanged: if(errorMode) d.draw()

    width: 410
    height: visible ? networkCardsLayout.height : 0

    RowLayout {
        id: networkCardsLayout
        width: parent.width
        ColumnLayout {
            id: fromNetworksLayout
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            spacing: 12
            StatusBaseText {
                Layout.maximumWidth: 100
                elide: Text.ElideRight
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: qsTr("Your Balances").toUpperCase()
            }
            Repeater {
                id: fromNetworksRepeater
                model: root.allNetworks
                StatusCard {
                    id: fromNetwork
                    objectName: model.chainId
                    property double amountToSend: 0
                    property int routeOnNetwork: 0
                    property bool selectedAssetValid: selectedAccount && selectedAccount !== undefined && selectedAsset !== undefined
                    property var tokenBalanceOnChain: selectedAssetValid ? root.store.getTokenBalanceOnChain(selectedAccount, model.chainId, selectedAsset.symbol) : undefined
                    property bool hasGas: selectedAssetValid && requiredGasInEth ? selectedAccount.hasGas(model.chainId, model.nativeCurrencySymbol, requiredGasInEth.amount) : false
                    property var advancedInputCurrencyAmount: selectedAssetValid ? root.getCryptoCurrencyAmount(LocaleUtils.numberFromLocaleString(advancedInputText)) : undefined

                    primaryText: model.chainName
                    secondaryText: !tokenBalanceOnChain || (tokenBalanceOnChain.amount === 0 && root.amountToSend && root.amountToSend.amount !== 0) ?
                                       qsTr("No Balance") : !hasGas ? qsTr("No Gas") : advancedInputCurrencyAmount ? LocaleUtils.currencyAmountToLocaleString(advancedInputCurrencyAmount) : "N/A"
                    tertiaryText: root.errorMode && advancedInputCurrencyAmount && advancedInputCurrencyAmount.amount !== 0 && advancedInput.valid ? qsTr("EXCEEDS SEND AMOUNT"): qsTr("BALANCE: ") + LocaleUtils.currencyAmountToLocaleString(tokenBalanceOnChain)
                    locked: store.lockedInAmounts.findIndex(lockedItem => lockedItem !== undefined && lockedItem.chainID ===  model.chainId) !== -1
                    preCalculatedAdvancedText: {
                        let index  = store.lockedInAmounts.findIndex(lockedItem => lockedItem!== undefined && lockedItem.chainID === model.chainId)
                        if(locked && index !== -1) {
                            let amount = root.weiToEth(parseInt(store.lockedInAmounts[index].value, 16))
                            return LocaleUtils.numberToLocaleString(amount.amount)
                        }
                        else return LocaleUtils.numberToLocaleString(fromNetwork.amountToSend)
                    }
                    maxAdvancedValue: tokenBalanceOnChain ? tokenBalanceOnChain.amount : 0.0
                    state: !tokenBalanceOnChain || tokenBalanceOnChain.amount === 0 || !hasGas ?
                               "unavailable" :
                               (root.errorMode || !advancedInput.valid) && (advancedInputCurrencyAmount.amount !== 0) ? "error" : "default"
                    cardIcon.source: Style.svg(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    disableText:  qsTr("Disable")
                    enableText: qsTr("Enable")
                    advancedMode: root.customMode
                    disabled: store.disabledChainIdsFromList.includes(model.chainId)
                    clickable: root.interactive
                    onClicked: {
                        store.addRemoveDisabledFromChain(model.chainId, disabled)
                        // only recalculate if the a best route was disabled
                        if(root.bestRoutes.length === 0 || routeOnNetwork !== 0 || !disabled)
                            root.reCalculateSuggestedRoute()
                    }
                    onVisibleChanged: {
                        if(visible)
                            disabled = store.disabledChainIdsFromList.includes(model.chainId)
                    }
                    onCardLocked: {

                        store.addLockedInAmount(model.chainId, advancedInputCurrencyAmount.amount, root.selectedAsset.decimals, isLocked)
                        d.calculateCustomAmounts()
                        if(!locked || (d.customAmountToSend <= root.amountToSend.amount && advancedInput.valid))
                            root.reCalculateSuggestedRoute()
                    }
                }
            }
        }
        BalanceExceeded {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            amountToSend: root.amountToSend ? root.amountToSend.amount : 0.0
            errorType: root.errorType
            visible: root.errorType === Constants.NoRoute
        }
        ColumnLayout {
            id: toNetworksLayout
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            spacing: 12
            StatusBaseText {
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                Layout.maximumWidth: 100
                font.pixelSize: 10
                color: Theme.palette.baseColor1
                text: !!selectedAccount ? StatusQUtils.Utils.elideText(selectedAccount.address, 6, 4).toUpperCase() :  ""
                elide: Text.ElideMiddle
            }
            Repeater {
                id: toNetworksRepeater
                model: root.allNetworks
                StatusCard {
                    id: toCard
                    objectName: model.chainId
                    property int routeOnNetwork: 0
                    property int bentLine: 0
                    property double amountToReceive: 0
                    property var currencyAmountToReceive: root.getCryptoCurrencyAmount(amountToReceive)
                    property bool preferred: store.preferredChainIds.includes(model.chainId)
                    primaryText: model.chainName
                    secondaryText: LocaleUtils.currencyAmountToLocaleString(currencyAmountToReceive)
                    tertiaryText: state === "unpreferred"  ? qsTr("UNPREFERRED") : ""
                    state: !preferred ? "unpreferred" : "default"
                    opacity: preferred || showPreferredChains ? 1 : 0
                    cardIcon.source: Style.svg(model.iconUrl)
                    disabledText: qsTr("Disabled")
                    disableText:  qsTr("Disable")
                    enableText: qsTr("Enable")
                    disabled: store.disabledChainIdsToList.includes(model.chainId)
                    clickable: root.interactive
                    loading: root.isLoading
                    onClicked: {
                        store.addRemoveDisabledToChain(model.chainId, disabled)
                        // only recalculate if the a best route was disabled
                        if((root.bestRoutes !== undefined && root.bestRoutes.length === 0) || routeOnNetwork !== 0 || !disabled)
                            root.reCalculateSuggestedRoute()
                    }
                    onVisibleChanged: {
                        if(visible) {
                            disabled = store.disabledChainIdsToList.includes(model.chainId)
                            preferred = store.preferredChainIds.includes(model.chainId)
                        }
                    }
                    onOpacityChanged: {
                        if(opacity === 1) {
                            disabled = store.disabledChainIdsToList.includes(model.chainId)
                        } else {
                            if(opacity === 0 && routeOnNetwork > 0)
                                root.reCalculateSuggestedRoute()
                        }
                    }
                }
            }
        }
    }

    Canvas {
        id: canvas
        x: networkCardsLayout.x + fromNetworksLayout.x
        y: networkCardsLayout.y
        width: networkCardsLayout.width
        height: networkCardsLayout.height

        function clear() {
            if(available) {
                var ctx = getContext("2d");
                if(ctx)
                    ctx.reset()
            }
        }

        onPaint: {
            d.resetAllSetValues()
            d.thereIsApossibleRoute = false

            if(bestRoutes === undefined)
                return

            // in case you are drawing multiple routes we need an offset so that the lines dont overlap
            let yOffsetFrom = 0
            let yOffsetTo = 0
            let xOffset = 0

            // Get the canvas context
            var ctx = getContext("2d");
            for(var i = 0; i< bestRoutes.length; i++) {
                var fromN, toN = null
                for(var j = 0; j<fromNetworksRepeater.count; j++) {
                    if(bestRoutes[i].fromNetwork.chainId === parseInt(fromNetworksRepeater.itemAt(j).objectName) &&
                            !store.disabledChainIdsFromList.includes(bestRoutes[i].fromNetwork.chainId)) {
                        fromN = fromNetworksRepeater.itemAt(j)
                    }
                }
                for(var k = 0; k<toNetworksRepeater.count; k++) {
                    if(bestRoutes[i].toNetwork.chainId === parseInt(toNetworksRepeater.itemAt(k).objectName) &&
                            !store.disabledChainIdsToList.includes(bestRoutes[i].toNetwork.chainId)) {
                        toN = toNetworksRepeater.itemAt(k)
                    }
                }
                if(toN !== null && fromN !== null) {
                    yOffsetFrom = toN.objectName === fromN.objectName  && toN.routeOnNetwork !== 0 ? toN.routeOnNetwork * 16 : 0
                    yOffsetTo = toN.routeOnNetwork * 16
                    xOffset = (fromN.y - toN.y > 0 ? -1 : 1) * toN.bentLine * 16
                    let amountToSend = weiToEth(bestRoutes[i].amountIn)
                    let amountToReceive = weiToEth(bestRoutes[i].amountOut)
                    fromN.amountToSend = amountToSend.amount
                    toN.amountToReceive += amountToReceive.amount
                    fromN.routeOnNetwork += 1
                    toN.routeOnNetwork += 1
                    toN.bentLine = toN.objectName !== fromN.objectName
                    d.thereIsApossibleRoute = true
                    let routeColor = root.errorMode ? Theme.palette.dangerColor1 : toN.preferred ? '#627EEA' : Theme.palette.pinColor1
                    StatusQUtils.Utils.drawArrow(ctx, fromN.x + fromN.width,
                                                 fromN.y + fromN.cardIconPosition + yOffsetFrom,
                                                 toNetworksLayout.x + toN.x,
                                                 toNetworksLayout.y + toN.y + toN.cardIconPosition + yOffsetTo,
                                                 routeColor, xOffset)
                }
            }
            d.calculateCustomAmounts()
        }
    }
}
