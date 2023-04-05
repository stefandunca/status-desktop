import QtQuick 2.15

import QtQml.StateMachine 1.15 as DSM

/// Runs the networks selection logic based on model count
/// \note implementation relies on the fact that enabledNetworksModel has the same values as networksModel
DSM.StateMachine {
    id: root

    readonly property int currentState: {
        if(emptyState.active)                   return NetworkSelectionState.SelectionState.ModelEmpty
        else if(allEnabledState.active)         return NetworkSelectionState.SelectionState.AllEnabled
        else if(partiallyEnabledState.active)   return NetworkSelectionState.SelectionState.PartiallyEnabled
        else if(singleEnabledState.active)      return NetworkSelectionState.SelectionState.SingleEnabled

        return NetworkSelectionState.SelectionState.ModelEmpty
    }
    required property var networksModel
    required property var enabledNetworksModel

    enum SelectionState {
        ModelEmpty,
        AllEnabled,
        PartiallyEnabled,
        SingleEnabled
    }

    initialState: emptyState
    running: true

    component AllEnabledTransition: DSM.SignalTransition {
        targetState: allEnabledState
        guard: (enabledNetworksModel.count === 0 || enabledNetworksModel.count === networksModel.count) && networksModel.count > 0
    }

    component PartiallyEnabledTransition: DSM.SignalTransition {
        targetState: partiallyEnabledState
        guard: enabledNetworksModel.count > 1 && networksModel.count > 1 && enabledNetworksModel.count < networksModel.count
    }

    component SingleTransition: DSM.SignalTransition {
        targetState: singleEnabledState
        guard: enabledNetworksModel.count === 1 && networksModel.count > 1
    }

    DSM.State {
        id: emptyState

        onActiveChanged: {
            console.debug(`@dd emptyState: ${active}`)
        }

        AllEnabledTransition {
            signal: root.runningChanged
        }
        PartiallyEnabledTransition {
            signal: root.runningChanged
        }
        SingleTransition {
            signal: root.runningChanged
        }
    }

    DSM.State {
        id: allEnabledState

        onActiveChanged: console.debug(`@dd allEnabledState: ${active}, ${enabledNetworksModel.count} ?= ${networksModel.count} | ${root}`)

        PartiallyEnabledTransition {
            signal: enabledNetworksModel.countChanged
        }
        SingleTransition {
            signal: enabledNetworksModel.countChanged
        }
    }
    DSM.State {
        id: partiallyEnabledState

        onActiveChanged: console.debug(`@dd partiallyEnabledState: ${active}, ${enabledNetworksModel.count} ?= ${networksModel.count} | ${root}`)

        AllEnabledTransition {
            signal: enabledNetworksModel.countChanged
        }
        SingleTransition {
            signal: enabledNetworksModel.countChanged
        }
    }

    DSM.State {
        id: singleEnabledState

        onActiveChanged: console.debug(`@dd singleEnabledState: ${active}, ${enabledNetworksModel.count} ?= ${networksModel.count} | ${root}`)

        AllEnabledTransition {
            signal: enabledNetworksModel.countChanged
        }
        PartiallyEnabledTransition {
            signal: enabledNetworksModel.countChanged
        }
    }
}