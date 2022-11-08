import QtQuick 2.14
import QtQuick.Controls 2.14
import QtTest 1.0

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import StatusQ.TestHelpers 0.1

Item {
    id: root
    width: 300
    height: 100

    Component {
        id: testControlComponent
        StatusBaseInput {
            text: "Control under test"
            placeholderText: "Placeholder"
            focus: true
        }
    }

    Component {
        id: controlInFlickable

        Flickable {
            anchors.fill: parent

            property var controlUnderTest: baseInput

            contentWidth: root.width * 1.1
            contentHeight: root.height * 1.1

            StatusBaseInput {
                id: baseInput

                width: 100
                height: 50
            }
        }
    }

    Loader {
        id: testLoader

        anchors.fill: parent
        active: false
    }

    SystemControl {
        id: systemControl
    }

    TestCase {
        id: testCase
        name: "TestStatusBasedInput"

        when: windowShown

        //
        // Test guards

        function init() {
            qtOuput.restartCapturing()
        }

        function cleanup() {
            testLoader.active = false
        }

        //
        // Tests

        function test_initial_empty_is_valid() {
            testLoader.sourceComponent = testControlComponent
            testLoader.active = true
            const statusInput = testLoader.item
            verify(waitForRendering(statusInput))
            mouseClick(statusInput)
            // Do some editing
            TestUtils.pressKeyAndWait(testCase, statusInput, Qt.Key_B)
            TestUtils.pressKeyAndWait(testCase, statusInput, Qt.Key_Left)
            TestUtils.pressKeyAndWait(testCase, statusInput, Qt.Key_A)
            verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        }

        function test_can_scroll_when_mouse_over() {
            // Load the test setup: flicker with control
            testLoader.sourceComponent = controlInFlickable
            testLoader.active = true
            const flickable = testLoader.item
            verify(waitForRendering(flickable))

            // Move using touch and check if flicker content moved or touch events were captured by StatusBaseInput
            const initialContentX = flickable.contentX
            const initialContentY = flickable.contentY
            const input = flickable.controlUnderTest
            systemControl.startSimulateMacOSTrackpadScrollEvent(input, 10, 10)
            systemControl.simulateMacOSTrackpadScrollEvent(input, 10, 10, 1, 1)
            waitForRendering(flickable, 100)
            systemControl.endSimulateMacOSTrackpadScrollEvent(input, 10, 10)
            verify(initialContentX !== flickable.contentX, "Content move on X axis")
            verify(initialContentY !== flickable.contentY, "Content move on Y axis")
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }
}
