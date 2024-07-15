import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusModal {
    id: root

    property bool isOnboarding: false

    width: 640
    title: qsTr("Help us improve Status")
    hasCloseButton: true
    verticalPadding: 20

    closePolicy: Popup.CloseOnEscape

    component Paragraph: StatusBaseText {
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        visible: true
        wrapMode: Text.Wrap
    }

    component AgreementSection: ColumnLayout {
        property alias title: titleItem.text
        property alias body: bodyItem.text
        spacing: 8
        Paragraph {
            id: titleItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.weight: Font.Bold
        }

        Paragraph {
            id: bodyItem
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            id: layout
            width: scrollView.availableWidth
            spacing: 20

            Paragraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Collecting usage data helps us improve Status.")
            }

            AgreementSection {
                title: qsTr("What we will receive:")
                body: qsTr(" •  IP address
 •  Universally Unique Identifiers of device
 •  Logs of actions within the app, including button presses and screen visits")
            }

            AgreementSection {
                title: qsTr("What we won’t receive:")
                body: qsTr(" •  Your profile information
 •  Your addresses
 •  Information you input and send")
            }

            Paragraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Usage data will be shared from all profiles added to device. %1").arg(root.isOnboarding ? "Sharing usage data can be turned off anytime in Settings / Privacy and Security." : "")
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: qsTr("Share usage data")
            onClicked: {
                root.accept()
            }
            objectName: "shareMetricsButton"
        }
    ]

    leftButtons: [
        StatusButton {
            text: qsTr("Not now")
            onClicked: {
                root.reject()
            }
            objectName: "notShareMetricsButton"
            normalColor: "transparent"
        }
    ]
}
