import QtQuick 2.15

import AppLayouts.stores 1.0

import SortFilterProxyModel 0.2

/// Adds extra logic to the networksModel, to support the feature's specifics
///    - all enabled when none is set
///    - form all enabled transition to only one selection
/// \c userEnabledNetworksModel keeps the user enabled networks and \c enabledNetworksModel is the ground truth
///     of the "backend" that changes in response to user requests but also to external events
/// \beware enabledState uses UxState to indicate internal enabled states which are transformed in
///     Qt.Checked, Qt.Unchecked and Qt.PartiallyChecked to indicate USER enabled state
/// \note using Item to support embedded sub-components
Item {
    id: root

    /// Ground truth of "backend" network enabled state
    required property var allNetworksModel
    // TODO is it really needed?
    required property var enabledNetworksModel
    property bool areTestNetworksEnabled: false

    /// Internal state. Modified by user actions through setUserIntention and "backend" events through root.allNetworksModel
    /// \c uxStateToCheckState is used to transform this state into the user visible state
    /// Provides "enabledState" and "specialIndex" roles to be used by the view
    property alias specialNetworksModel: specialNetworksModel

    /// These filtered models have the enabledState role that uses UxState to indicate enabled state
    property alias layer1Networks: layer1Networks
    property alias layer2Networks: layer2Networks

    signal setNetworkState(var network, bool newState)

    function setUserIntention(specialIndex) {
        const modelData = specialNetworksModel.get(specialIndex)
        const oldState = modelData.enabledState
        console.debug(`@dd oldState - ${oldState}`)
        switch(oldState) {
        case Controller.UxState.Enable:
        case Controller.UxState.Disable:
            // Request enable if clearly disabled, otherwise disable
            d.requestNetworksState(modelData, specialIndex, oldState === Controller.UxState.Disable, true)
            break
        case Controller.UxState.AllEnabled:
            let networksToDisable = []
            let indices = []
            for (let i = 0; i < specialNetworksModel.count; i++) {
                if(i !== specialIndex) {
                    networksToDisable.push(specialNetworksModel.get(i))
                    indices.push(i)
                }
            }
            d.requestNetworksState(networksToDisable, indices, false, true)
            break
        case Controller.UxState.RequestedEnabled:
        case Controller.UxState.RequestedDisabled:
            // Nothing to do here, waiting for the backend changes
            break
        }
    }

    function uxStateToCheckState(roleState) {
        switch(roleState) {
        case Controller.UxState.Enable:
            return Qt.Checked
        case Controller.UxState.RequestedEnabled:
        case Controller.UxState.RequestedDisabled:
        case Controller.UxState.AllEnabled:
            return Qt.PartiallyChecked
        case Controller.UxState.Disable:
            return Qt.Unchecked
        }
    }

    enum UxState {
        // TODO: Enabled
        Enable,
        RequestedEnabled,
        RequestedDisabled,
        AllEnabled,
        // TODO: Disabled
        Disable
    }

    QtObject {
        id: d

        // \c modelDataEntry and \c specialIndices can be arrays with equivalent data
        function requestNetworksState(modelDataEntry, specialIndices, enable, async = false) {
            console.debug(`@dd requestNetworksState: (${JSON.stringify((Array.isArray(modelDataEntry) ? modelDataEntry : [modelDataEntry]).map(obj => obj.internalState))}, ${JSON.stringify(Array.isArray(specialIndices) ? specialIndices : [specialIndices])}) - ${enable}`)

            if(Array.isArray(modelDataEntry) !== Array.isArray(specialIndices)
                    || (Array.isArray(specialIndices) && modelDataEntry.length !== specialIndices.length)) {
                console.error(`requestNetworksState: modelDataEntry and specialIndices don't match`)
                return
            }

            var allChanges = Array.isArray(modelDataEntry) ? modelDataEntry : [modelDataEntry]
            const notifyChanges = () => {
                for(let entry of allChanges) {
                    root.setNetworkState(entry, enable)
                }
            }
            // Queue changes to be notified after the model is updated
            if (async) {
                Qt.callLater(notifyChanges)
            }

            let allIndices = Array.isArray(specialIndices) ? specialIndices : [specialIndices]
            // Mark internal state as requested
            for(let i of allIndices) {
                const cloneModelIndex = specialNetworksModel.mapToSource(i)
                cloneModel.setProperty(cloneModelIndex, "internalState",
                    enable ? Controller.UxState.RequestedEnabled : Controller.UxState.RequestedDisabled)
            }

            // Alternatively execute the request and notify changes
            if(!async) {
                notifyChanges()
            }
        }
    }

    NetworkSelectionState {
        id: networkSelectionState

        networksModel: specialNetworksModel
        enabledNetworksModel: userEnabledNetworksModel

        onCurrentStateChanged: {
            switch(currentState) {
                case NetworkSelectionState.SelectionState.AllEnabled: {
                    console.debug(`@dd all enabled state: Check all? ${userEnabledNetworksModel.count === 0}`)
                    // If reason is that none is enabled, request all to be enabled and match expected state
                    if(userEnabledNetworksModel.count === 0) {
                        let networksToEnable = []
                        let indices = []
                        for(let i = 0; i < specialNetworksModel.count; i++) {
                            networksToEnable.push(specialNetworksModel.get(i))
                            indices.push(i)
                        }
                        d.requestNetworksState(networksToEnable, indices, true, true)
                    }
                    break
                }
            }
        }
    }

    SortFilterProxyModel {
        id: layer1Networks

        sourceModel: specialNetworksModel

        filters: ValueFilter { roleName: "layer"; value: 1; }
    }

    SortFilterProxyModel {
        id: layer2Networks

        sourceModel: specialNetworksModel

        filters: ValueFilter { roleName: "layer"; value: 2; }
    }

    // Listen to changes in the model and update the visible model copy
    Repeater {
        model: root.allNetworksModel

        delegate: Item {
            property bool isEnabled: model.isEnabled
            onIsEnabledChanged: {
                const prevInternalState = cloneModel.get(index).internalState
                cloneModel.setProperty(index, "internalState", isEnabled ? Controller.UxState.Enable : Controller.UxState.Disable)
                console.debug(`@dd onIsEnabledChanged ${isEnabled} - ${cloneModel.get(index).internalState} ?= ${prevInternalState} [${index}]`)
            }

            property bool chainId: model.chainId

            // Workaround to refresh the model when the data changes. Call cater will dismiss the duplicate queued calls
            onChainIdChanged: Qt.callLater(root.reCloneModel)
        }
    }

    Connections {
        target: userEnabledNetworksModel
        function onCountChanged() { console.debug(`@dd userEnabledNetworksModel.count - ${userEnabledNetworksModel.count}`) }
    }
    Connections {
        target: specialNetworksModel
        function onCountChanged() { console.debug(`@dd specialNetworksModel.count - ${specialNetworksModel.count}`) }
    }
    Connections {
        target: root
        function onAreTestNetworksEnabledChanged() { console.debug(`@dd areTestNetworksEnabled - ${root.areTestNetworksEnabled}`) }
    }

    SortFilterProxyModel {
        id: specialNetworksModel

        sourceModel: cloneModel

        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled; }
        proxyRoles: [
        ExpressionRole {
            name: "enabledState"
            expression: {
                networkSelectionState.currentState === 1 // TODO: NetworkSelectionState.SelectionState.AllEnabled
                    ? 3 // TODO: Controller.UxState.AllEnabled
                    : model.internalState
            }
        },
        ExpressionRole {
            name: "specialIndex"
            expression: index
        }]
    }

    SortFilterProxyModel {
        id: userEnabledNetworksModel

        sourceModel: cloneModel

        filters: AllOf {
            AnyOf {
                ValueFilter { roleName: "internalState"; value: Controller.UxState.Enable; }
                ValueFilter { roleName: "internalState"; value: Controller.UxState.RequestedEnabled; }
                ValueFilter { roleName: "internalState"; value: Controller.UxState.AllEnabled; }
            }
            ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled; }
        }
    }

    function reCloneModel() {
        console.debug(`@dd reCloneModel`)
        cloneModel.cloneModel(cloneModel.sourceModel)
    }

    // Keep a clone so that the UX can be modified without affecting the original model
    CloneModel {
        id: cloneModel

        sourceModel: root.allNetworksModel
        roles: ["chainId", "layer", "chainName", "isTest", "isEnabled", "iconUrl", "shortName", "chainColor"]
        rolesOverride: [{ role: "internalState", transform: (mD) => mD.isEnabled ? Controller.UxState.Enable : Controller.UxState.Disable }]
    }
}