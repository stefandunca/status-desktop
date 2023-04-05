import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import QtTest 1.2

import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.popups.NetworkSelectPopup 1.0

import SortFilterProxyModel 0.2

import "./testdata"

Item {
    id: root

    width: 600
    height: 400

    property var mdlSrc: NetworkModels.allTestNetworks

    // Used to simulate backend state changes
    function updateEnabledNetworksModel(model, enabledIndexes) {
        for(let i = 0; i < model.count; i++) {
            model.setProperty(i, "isEnabled", enabledIndexes.includes(i))
        }
    }

    TestCase {
        name: "NetworkSelectionStateTests"

        when: windowShown

        Component {
            id: networkSelectionStateComponent

            // Support item for object under test that doesn't have a visual representation
            // to be state-managed by the test framework
            Item {
                readonly property alias currentState: testObject.currentState
                property alias networksModel: testObject.networksModel
                property alias enabledNetworksModel: testObject.enabledNetworksModel

                readonly property alias testObject: testObject

                NetworkSelectionState {
                    id: testObject
                }
            }
        }

        property NetworkSelectionState testSm: null

        function init() {
        }

        function test_initNetworkSelectionState_data() {
            return [
                {tag: "Empty", networks: [], enabledNetworks: [], expectState: NetworkSelectionState.SelectionState.ModelEmpty},
                {tag: "All Enabled One Entry",
                    networks: [mdlSrc.eth],
                    enabledNetworks: [mdlSrc.eth],
                    expectState: NetworkSelectionState.SelectionState.AllEnabled},
                {tag: "All Enabled Multiple Entries",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    expectState: NetworkSelectionState.SelectionState.AllEnabled},
                {tag: "None enabled",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworks: [],
                    expectState: NetworkSelectionState.SelectionState.AllEnabled},
                {tag: "Single enabled",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworks: [mdlSrc.optimism],
                    expectState: NetworkSelectionState.SelectionState.SingleEnabled},
                {tag: "Multiple enabled",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworks: [mdlSrc.optimism, mdlSrc.arbitrum],
                    expectState: NetworkSelectionState.SelectionState.PartiallyEnabled},
            ]
        }

        function test_initNetworkSelectionState(data) {
            const testModel = NetworkModels.generateListModel(data.networks)
            const enabledNetworksModel = NetworkModels.generateListModel(data.enabledNetworks)
            const supportItem = createTemporaryObject(networkSelectionStateComponent, root,
                                                    {networksModel: testModel,
                                                        enabledNetworksModel: enabledNetworksModel})
            testSm = supportItem.testObject
            waitForRendering(supportItem)
            compare(testSm.currentState, data.expectState, `expected state ${data.expectState}; got ${testSm.currentState}`)
        }

        function test_networkSelectionStateTransitions_data() {
            return [
                {tag: "All to Partially",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[0, 1, 2],
                                            [0, 2]],
                    expectStateStages: [NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.PartiallyEnabled]},
                {tag: "All to Single",
                    networks: [mdlSrc.eth, mdlSrc.optimism],
                    enabledNetworksStages: [[0, 1],
                                            [1]],
                    expectStateStages: [NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.SingleEnabled]},
                {tag: "None to Partially",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[],
                                            [0, 2]],
                    expectStateStages: [NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.PartiallyEnabled]},
                {tag: "None to Single",
                    networks: [mdlSrc.eth, mdlSrc.optimism],
                    enabledNetworksStages: [[],
                                            [1]],
                    expectStateStages: [NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.SingleEnabled]},
                {tag: "Partially to All",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[0, 1],
                                            [0, 1, 2]],
                    expectStateStages: [NetworkSelectionState.SelectionState.PartiallyEnabled,
                                        NetworkSelectionState.SelectionState.AllEnabled]},
                {tag: "Partially to Single",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[0, 1],
                                            [2]],
                    expectStateStages: [NetworkSelectionState.SelectionState.PartiallyEnabled,
                                        NetworkSelectionState.SelectionState.SingleEnabled]},
                {tag: "Single to All",
                    networks: [mdlSrc.eth, mdlSrc.optimism],
                    enabledNetworksStages: [[0],
                                            [0, 1]],
                    expectStateStages: [NetworkSelectionState.SelectionState.SingleEnabled,
                                        NetworkSelectionState.SelectionState.AllEnabled]},
                {tag: "Single to Partially",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[1],
                                            [1, 2]],
                    expectStateStages: [NetworkSelectionState.SelectionState.SingleEnabled,
                                        NetworkSelectionState.SelectionState.PartiallyEnabled]},
                {tag: "All to Single through Partially",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[0, 1, 2],
                                            [1]],
                    expectStateStages: [NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.SingleEnabled]},
                {tag: "Roundtrip",
                    networks: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum],
                    enabledNetworksStages: [[0, 1, 2],
                                            [1, 2],
                                            [2],
                                            [],
                                            [1],
                                            [0, 1],
                                            [0, 1, 2]],
                    expectStateStages: [NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.PartiallyEnabled,
                                        NetworkSelectionState.SelectionState.SingleEnabled,
                                        NetworkSelectionState.SelectionState.AllEnabled,
                                        NetworkSelectionState.SelectionState.SingleEnabled,
                                        NetworkSelectionState.SelectionState.PartiallyEnabled,
                                        NetworkSelectionState.SelectionState.AllEnabled]},
            ]
        }

        SortFilterProxyModel {
            id: filterTestModel
            filters: ValueFilter { roleName: "isEnabled";  value: true; }
        }

        function test_networkSelectionStateTransitions(data) {
            verify(data.enabledNetworksStages.length > 1
                   && data.enabledNetworksStages.length === data.expectStateStages.length, `test stages are well configured`)

            const testModel = NetworkModels.generateListModel(data.networks)
            filterTestModel.sourceModel = testModel
            updateEnabledNetworksModel(testModel, data.enabledNetworksStages[0])
            const supportItem = createTemporaryObject(networkSelectionStateComponent, root,
                                                      {networksModel: testModel,
                                                       enabledNetworksModel: filterTestModel})
            testSm = supportItem.testObject
            waitForRendering(supportItem)
            for(let i = 0; i < data.enabledNetworksStages.length; i++) {
                if (i > 0) {
                    updateEnabledNetworksModel(testModel, data.enabledNetworksStages[i])
                }
                compare(testSm.currentState, data.expectStateStages[i], `expected state ${data.expectStateStages[i]} for stage ${i}; got ${testSm.currentState}`)
            }
        }

        Item {
            id: dummyModel

            property int count: 3
            function triggerCountChanged() {
                countChanged()
            }
        }

        function test_specialCaseOfCountChangedTriggeredWithSameValue() {
            const testModel = NetworkModels.generateListModel([mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum])
            filterTestModel.sourceModel = testModel
            const supportItem = createTemporaryObject(networkSelectionStateComponent, root,
                                                      {networksModel: testModel,
                                                       enabledNetworksModel: dummyModel})
            testSm = supportItem.testObject
            waitForRendering(supportItem)
            compare(testSm.currentState, NetworkSelectionState.SelectionState.AllEnabled, `expected state ${NetworkSelectionState.SelectionState.AllEnabled} for stage 0; got ${testSm.currentState}`)
            dummyModel.triggerCountChanged()
            compare(testSm.currentState, NetworkSelectionState.SelectionState.AllEnabled, `expected state ${NetworkSelectionState.SelectionState.AllEnabled} for stage 1; got ${testSm.currentState}`)
        }
    }

    TestCase {
        name: "ControllerTests"

        when: windowShown

        Component {
            id: controllerComponent

            Controller {
                onSetNetworkState: (model, newState) => {
                    // Propagate new state to the model
                    for(let i = 0; i < allNetworksModel.count; i++) {
                        const item = allNetworksModel.get(i)
                        if (item.chainId === model.chainId) {
                            item.isEnabled = newState
                            break
                        }
                    }
                }

                property var networkStateEvents: []
            }
        }

        property Controller testController: null

        function init() {
        }

        readonly property int stEnabled: Controller.UxState.Enable
        readonly property int stReqEnabled: Controller.UxState.RequestedEnabled
        readonly property int stReqDisabled: Controller.UxState.RequestedDisabled
        readonly property int stAllEnabled: Controller.UxState.AllEnabled
        readonly property int stDisabled: Controller.UxState.Disable

        readonly property var allNetworksEntries: [mdlSrc.eth, mdlSrc.optimism, mdlSrc.arbitrum, mdlSrc.goerli, mdlSrc.goOpt, mdlSrc.goArb]

        function test_controllerBehaviorOnBackendChanges_data() {
            return [
                //
                // Initial stage
                //
                {tag: "Empty", networks: [],
                    enabledNetworksStages: [[]],
                    expectSpecialModelStages: [[]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "All Enabled - One Entry", networks: [mdlSrc.eth],
                    enabledNetworksStages: [[0]],
                    expectSpecialModelStages: [[stAllEnabled]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "Single Enabled - Test Mode", networks: allNetworksEntries,
                    enabledNetworksStages: [[4]],
                    expectSpecialModelStages: [[stDisabled, stEnabled, stDisabled]],
                    expectedEvents: [],
                    testMode: true},
                //
                // Multiple states
                //
                {tag: "All to Partially", networks: allNetworksEntries,
                    enabledNetworksStages: [[0, 1, 2], [1, 2]],
                    expectSpecialModelStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stDisabled, stEnabled, stEnabled]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "All to Partially - Test Mode", networks: allNetworksEntries,
                    enabledNetworksStages: [[3, 4, 5], [3, 5]],
                    expectSpecialModelStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stEnabled, stDisabled, stEnabled]],
                    expectedEvents: [],
                    testMode: true},
                {tag: "All to Single", networks: allNetworksEntries,
                    enabledNetworksStages: [[0, 1, 2], [2]],
                    expectSpecialModelStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stDisabled, stDisabled, stEnabled]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "None to Partially", networks: allNetworksEntries,
                    enabledNetworksStages: [[], [0, 1]],
                    expectSpecialModelStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stEnabled, stEnabled, stDisabled]],
                    expectedEvents: [[mdlSrc.eth, true], [mdlSrc.optimism, true], [mdlSrc.arbitrum, true]],
                    testMode: false},
                {tag: "None to Single", networks: allNetworksEntries,
                    enabledNetworksStages: [[], [0]],
                    expectSpecialModelStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stEnabled, stDisabled, stDisabled]],
                    expectedEvents: [[mdlSrc.eth, true], [mdlSrc.optimism, true], [mdlSrc.arbitrum, true]],
                    testMode: false},
                {tag: "Partially to All", networks: allNetworksEntries,
                    enabledNetworksStages: [[0, 2], [0, 1, 2]],
                    expectSpecialModelStages: [[stEnabled, stDisabled, stEnabled],
                                               [stAllEnabled, stAllEnabled, stAllEnabled]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "Partially to Single - Test Mode", networks: allNetworksEntries,
                    enabledNetworksStages: [[4, 5], [3]],
                    expectSpecialModelStages: [[stDisabled, stEnabled, stEnabled],
                                               [stEnabled, stDisabled, stDisabled]],
                    expectedEvents: [],
                    testMode: true},
                {tag: "Single to All", networks: allNetworksEntries,
                    enabledNetworksStages: [[2], [0, 1, 2]],
                    expectSpecialModelStages: [[stDisabled, stDisabled, stEnabled],
                                               [stAllEnabled, stAllEnabled, stAllEnabled]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "Single to None", networks: allNetworksEntries,
                    enabledNetworksStages: [[2], []],
                    expectSpecialModelStages: [[stDisabled, stDisabled, stEnabled],
                                               [stAllEnabled, stAllEnabled, stAllEnabled]],
                    expectedEvents: [[mdlSrc.eth, true], [mdlSrc.optimism, true], [mdlSrc.arbitrum, true]],
                    testMode: false},
                {tag: "Single to Partially", networks: allNetworksEntries,
                    enabledNetworksStages: [[2], [1, 2]],
                    expectSpecialModelStages: [[stDisabled, stDisabled, stEnabled],
                                               [stDisabled, stEnabled, stEnabled]],
                    expectedEvents: [],
                    testMode: false},
                {tag: "Round Trip", networks: allNetworksEntries,
                    enabledNetworksStages: [[0, 1, 2], [0, 2], [1], [], [0], [0, 1], [0, 1, 2]],
                    expectSpecialModelStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stEnabled, stDisabled, stEnabled],
                                               [stDisabled, stEnabled, stDisabled],
                                               [stAllEnabled, stAllEnabled, stAllEnabled],
                                               [stEnabled, stDisabled, stDisabled],
                                               [stEnabled, stEnabled, stDisabled],
                                               [stAllEnabled, stAllEnabled, stAllEnabled]],
                    expectedEvents: [[mdlSrc.eth, true], [mdlSrc.optimism, true], [mdlSrc.arbitrum, true]],
                    testMode: false},

            ]
        }


        function test_controllerBehaviorOnBackendChanges(data) {
            verify(data.enabledNetworksStages.length >= 1
                   && data.enabledNetworksStages.length === data.expectSpecialModelStages.length, `test stages are well configured`)

            const testModel = NetworkModels.generateListModel(data.networks)
            filterTestModel.sourceModel = testModel
            updateEnabledNetworksModel(testModel, data.enabledNetworksStages[0])
            testController = createTemporaryObject(controllerComponent, root,
                                                   {allNetworksModel: testModel,
                                                    enabledNetworksModel: filterTestModel,
                                                    areTestNetworksEnabled: data.testMode})
            waitForRendering(testController)
            for(let i = 0; i < data.enabledNetworksStages.length; i++) {
                if (i > 0) {
                    updateEnabledNetworksModel(testModel, data.enabledNetworksStages[i])
                    wait(1)  // to process internal async events
                }
                compare(testController.specialNetworksModel.count, data.expectSpecialModelStages[i].length,
                    `expect specialNetworksModel has length ${data.expectSpecialModelStages[i].length}; got ${testController.specialNetworksModel.count}`)
                for(let j = 0; j < data.expectSpecialModelStages[i].length; j++) {
                    compare(testController.specialNetworksModel.get(j).enabledState,
                            data.expectSpecialModelStages[i][j],
                            `expected specialNetworksModel's entry ${j}, for stage ${i} to have enabledState ${data.expectSpecialModelStages[i][j]}; got ${testController.specialNetworksModel.get(j).enabledState}`)
                }
            }

            compare(testController.networkStateEvents.length, data.expectedEvents.length,
                `expected ${data.expectedEvents.length} "setNetworkState" events; got ${testController.networkStateEvents.length}`)
            for(let i = 0; i < data.expectedEvents.length; i++) {
                compare(testController.networkStateEvents[i].chainId, data.expectedEvents[i][0].chainId,
                    `expected "setNetworkState" event ${i} with chainId ${data.expectedEvents[i].chainId}; got ${testController.networkStateEvents[i].chainId}`)
                compare(data.expectedEvents[i][1], testController.networkStateEvents[i].enable,
                    `expected "setNetworkState" event ${i} to have enable state ${data.expectedEvents[i][1]}; got ${testController.networkStateEvents[i].enable}`)
            }
        }

        function test_controllerBehaviorOnUserChanges_data() {
            return [
                {tag: "Seven Stages Of Expectation", networks: allNetworksEntries,
                    initialEnabledNetworks: [0, 1, 2],
                    specialModelActionStages: [0, 1, 2, 1, 2, 1, 2],
                    specialModelPreEventStages: [[stAllEnabled, stAllEnabled, stAllEnabled],
                                                 [stEnabled, stDisabled, stDisabled],
                                                 [stEnabled, stEnabled, stDisabled],
                                                 [stAllEnabled, stAllEnabled, stAllEnabled],
                                                 [stDisabled, stEnabled, stDisabled],
                                                 [stDisabled, stEnabled, stEnabled],
                                                 [stDisabled, stDisabled, stEnabled],
                                                 [stAllEnabled, stAllEnabled, stAllEnabled]],
                    expectedEventsStages: [[],
                                           [[mdlSrc.optimism, false], [mdlSrc.arbitrum, false]],
                                           [[mdlSrc.optimism, true]],
                                           [[mdlSrc.arbitrum, true]],
                                           [[mdlSrc.eth, false], [mdlSrc.arbitrum, false]],
                                           [[mdlSrc.arbitrum, true]],
                                           [[mdlSrc.optimism, false]],
                                           [[mdlSrc.arbitrum, false], [mdlSrc.eth, true], [mdlSrc.optimism, true], [mdlSrc.arbitrum, true]]],
                    testMode: false},

            ]
        }


        function test_controllerBehaviorOnUserChanges(data) {
            verify(data.initialEnabledNetworks.length <= data.networks.length
                   && (data.specialModelActionStages.length + 1) === data.specialModelPreEventStages.length
                   && data.specialModelPreEventStages.length === data.expectedEventsStages.length, `test stages are well configured`)

            const testModel = NetworkModels.generateListModel(data.networks)
            filterTestModel.sourceModel = testModel
            updateEnabledNetworksModel(testModel, data.initialEnabledNetworks)
            testController = createTemporaryObject(controllerComponent, root,
                                                   {allNetworksModel: testModel,
                                                    enabledNetworksModel: filterTestModel,
                                                    areTestNetworksEnabled: data.testMode})
            waitForRendering(testController)
            let processedEvents = 0
            for(let i = 0; i < data.specialModelPreEventStages.length; i++) {
                // The first stage checks the initial state of the model
                if(i > 0) {
                    const userActionItemIndex = data.specialModelActionStages[i - 1]
                    verify(userActionItemIndex < testController.specialNetworksModel.count, "userAction index is valid")

                    testController.setUserIntention(userActionItemIndex)
                    wait(1) // to process user triggered async events
                }
                // Check output model
                compare(testController.specialNetworksModel.count, data.specialModelPreEventStages[i].length,
                    `expect specialNetworksModel, of stage ${i}, has length ${data.specialModelPreEventStages[i].length}; got ${testController.specialNetworksModel.count}`)
                for(let j = 0; j < data.specialModelPreEventStages[i].length; j++) {
                    compare(testController.specialNetworksModel.get(j).enabledState,
                            data.specialModelPreEventStages[i][j],
                            `expected specialNetworksModel's entry ${j}, for stage ${i}, to have enabledState ${data.specialModelPreEventStages[i][j]}; got ${testController.specialNetworksModel.get(j).enabledState}`)
                }
                // Check emitted events
                let newEvents = testController.networkStateEvents.slice(processedEvents)
                compare(newEvents.length, data.expectedEventsStages[i].length,
                    `expected ${data.expectedEventsStages[i].length} "setNetworkState" events for stage ${i}; got ${newEvents.length}`)
                for(let j = 0; j < data.expectedEventsStages[i].length; j++) {
                    const expEvt = {chainId: data.expectedEventsStages[i][j][0].chainId,
                                    enable: data.expectedEventsStages[i][j][1]}
                    const eventIndex = newEvents.findIndex(obj => obj.chainId === expEvt.chainId
                                                                  && obj.enable === expEvt.enable);
                    verify(eventIndex !== -1, `${JSON.stringify(newEvents)} don't include expected ${JSON.stringify(expEvt)}`)
                    newEvents.splice(eventIndex, 1)
                    processedEvents++
                }
            }
        }
    }
}
