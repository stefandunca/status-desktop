import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "./stores"
import "./states"

StatusModal {
    id: root

    property AddAccountStore store: AddAccountStore { }

    width: Constants.addAccountPopup.popupWidth
    height: {
        let availableSpace = Global.applicationWindow.height - root.margins * 2
        return Math.min(implicitHeight, availableSpace)
    }

    closePolicy: root.store.disablePopup? Popup.NoAutoClose : Popup.CloseOnEscape | Popup.CloseOnPressOutside
    hasCloseButton: !root.store.disablePopup

    header.title: qsTr("Add a new account")

    onOpened: {
        root.store.resetStoreValues()
    }

    onClosed: {
        root.store.currentState.doCancelAction()
    }

    contentItem: StatusScrollView {
        id: scrollView

        implicitWidth: contentWidth + leftPadding + rightPadding
        implicitHeight: contentHeight + topPadding + bottomPadding
        padding: 0

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        width: parent.width
        height: {
            let availableSpace = Global.applicationWindow.height - (root.margins * 2 + root.topPadding + root.bottomPadding)
            return Math.min(content.height, availableSpace)
        }

        Item {
            id: content
            objectName: "AddAccountPopup-Content"

            width: scrollView.availableWidth

            Loader {
                id: loader
                width: parent.width
                sourceComponent: {
                    switch (root.store.currentState.stateType) {
                    case Constants.addAccountPopup.state.main:
                        return mainComponent
                    case Constants.addAccountPopup.state.confirmAddingNewMasterKey:
                        return confirmAddingNewMasterKeyComponent
                    case Constants.addAccountPopup.state.confirmSeedPhraseBackup:
                        return confirmSeedPhraseBackupComponent
                    case Constants.addAccountPopup.state.displaySeedPhrase:
                        return displaySeedPhraseComponent
                    case Constants.addAccountPopup.state.enterKeypairName:
                        return enterKeypairNameComponent
                    case Constants.addAccountPopup.state.enterPrivateKey:
                        return enterPrivateKeyComponent
                    case Constants.addAccountPopup.state.enterSeedPhraseWord1:
                    case Constants.addAccountPopup.state.enterSeedPhraseWord2:
                        return enterSeedPhraseWordComponent
                    case Constants.addAccountPopup.state.enterSeedPhrase:
                        return enterSeedPhraseComponent
                    case Constants.addAccountPopup.state.selectMasterKey:
                        return selectMasterKeyComponent
                    }

                    return undefined
                }

                onLoaded: {
                    content.height = Qt.binding(function(){return item.height})
                }
            }

            Component {
                id: mainComponent
                Main {
                    store: root.store
                }
            }

            Component {
                id: confirmAddingNewMasterKeyComponent
                ConfirmAddingNewMasterKey {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }

            Component {
                id: confirmSeedPhraseBackupComponent
                ConfirmSeedPhraseBackup {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }

            Component {
                id: displaySeedPhraseComponent
                DisplaySeedPhrase {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }

            Component {
                id: enterKeypairNameComponent
                EnterKeypairName {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }

            Component {
                id: enterPrivateKeyComponent
                EnterPrivateKey {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }

            Component {
                id: enterSeedPhraseComponent
                EnterSeedPhrase {
                    height: Constants.addAccountPopup.contentHeight2
                    store: root.store
                }
            }

            Component {
                id: enterSeedPhraseWordComponent
                EnterSeedPhraseWord {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }

            Component {
                id: selectMasterKeyComponent
                SelectMasterKey {
                    height: Constants.addAccountPopup.contentHeight1
                    store: root.store
                }
            }
        }
    }

    leftButtons: [
        StatusBackButton {
            id: backButton
            objectName: "AddAccountPopup-BackButton"
            visible: root.store.currentState.displayBackButton
            enabled: !root.store.disablePopup
            height: Constants.addAccountPopup.footerButtonsHeight
            width: height
            onClicked: {
                if (root.store.currentState.stateType === Constants.addAccountPopup.state.confirmAddingNewMasterKey) {
                    root.store.addingNewMasterKeyConfirmed = false
                }
                else if (root.store.currentState.stateType === Constants.addAccountPopup.state.displaySeedPhrase) {
                    root.store.seedPhraseRevealed = false
                }
                else if (root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1) {
                    root.store.seedPhraseWord1Valid = false
                    root.store.seedPhraseWord1WordNumber = -1
                    root.store.seedPhraseWord2Valid = false
                    root.store.seedPhraseWord2WordNumber = -1
                }
                else if (root.store.currentState.stateType === Constants.addAccountPopup.state.confirmSeedPhraseBackup) {
                    root.store.seedPhraseBackupConfirmed = false
                }
                else if (root.store.currentState.stateType === Constants.addAccountPopup.state.enterKeypairName) {
                    root.store.addAccountModule.newKeyPairName = ""
                }

                root.store.currentState.doBackAction()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: primaryButton
            objectName: "AddAccountPopup-PrimaryButton"
            type: root.store.currentState.stateType === Constants.addAccountPopup.state.main?
                      StatusBaseButton.Type.Primary :
                      StatusBaseButton.Type.Normal
            height: Constants.addAccountPopup.footerButtonsHeight
            text: {
                switch (root.store.currentState.stateType) {

                case Constants.addAccountPopup.state.main:
                    return qsTr("Add account")
                case Constants.addAccountPopup.state.enterPrivateKey:
                case Constants.addAccountPopup.state.enterSeedPhrase:
                case Constants.addAccountPopup.state.enterSeedPhraseWord1:
                case Constants.addAccountPopup.state.enterSeedPhraseWord2:
                case Constants.addAccountPopup.state.confirmSeedPhraseBackup:
                case Constants.addAccountPopup.state.enterKeypairName:
                    return qsTr("Continue")
                case Constants.addAccountPopup.state.confirmAddingNewMasterKey:
                    return qsTr("Reveal seed phrase")
                case Constants.addAccountPopup.state.displaySeedPhrase:
                    return qsTr("Confirm seed phrase")
                }

                return ""
            }
            visible: text !== ""
            enabled: root.store.primaryPopupButtonEnabled

            icon.name: {
                if (root.store.currentState.stateType === Constants.addAccountPopup.state.enterPrivateKey ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhrase ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.confirmAddingNewMasterKey ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.displaySeedPhrase ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1 ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord2 ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.confirmSeedPhraseBackup ||
                        root.store.currentState.stateType === Constants.addAccountPopup.state.enterKeypairName ||
                        root.store.addAccountModule.actionAuthenticated ||
                        root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.unknown &&
                        root.store.selectedOrigin.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc) {
                    return ""
                }

                if (root.store.selectedOrigin.keyUid === root.store.userProfileKeyUid &&
                        root.store.userProfileUsingBiometricLogin) {
                    return "touch-id"
                }

                if (root.store.selectedOrigin.migratedToKeycard || root.store.userProfileIsKeycardUser) {
                    return "keycard"
                }

                return "password"
            }

            onClicked: {
                root.store.submitAddAccount(null)
            }
        }
    ]
}
