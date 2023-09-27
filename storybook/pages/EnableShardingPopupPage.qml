import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: dialog.open()
        }

        EnableShardingPopup {
            id: dialog

            anchors.centerIn: parent
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose

            communityName: "Foobar"
            publicKey: "0xdeadbeef"
            shardingInProgress: ctrlShardingInProgress.checked
            onEnableSharding: logs.logEvent("enableSharding", ["shardIndex"], arguments)
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Switch {
                id: ctrlShardingInProgress
                text: "Sharding in progress"
            }
        }
    }
}

// category: Popups
