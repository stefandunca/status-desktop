import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    spacing: Style.current.halfPadding

    QtObject {
        id: d

        property int iconSize: 20
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusIcon {
            Layout.preferredWidth: d.iconSize
            Layout.preferredHeight: d.iconSize
            Layout.alignment: Qt.AlignTop

            color: Theme.palette.dangerColor1
            icon: "warning"
        }
        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.dangerColor1
            text: qsTr("Permission with same properties is already active, edit properties to create a new permission.")
        }
    }
}
