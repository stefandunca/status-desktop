import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    required property var addAccountModule
    required property var emojiPopup

    property string userProfilePublicKey: userProfile.pubKey
    property string userProfileKeyUid: userProfile.keyUid
    property bool userProfileIsKeycardUser: userProfile.isKeycardUser
    property bool userProfileUsingBiometricLogin: userProfile.usingBiometricLogin

    // Module Properties
    property var currentState: root.addAccountModule.currentState
    property var originModel: root.addAccountModule.originModel
    property var selectedOrigin: root.addAccountModule.selectedOrigin
    property var derivedAddressModel: root.addAccountModule.derivedAddressModel
    property var selectedDerivedAddress: root.addAccountModule.selectedDerivedAddress
    property var watchOnlyAccAddress: root.addAccountModule.watchOnlyAccAddress
    property var privateKeyAccAddress: root.addAccountModule.privateKeyAccAddress
    property bool disablePopup: root.addAccountModule.disablePopup

    property bool enteredSeedPhraseIsValid: false
    property bool enteredPrivateKeyIsValid: false
    property bool addingNewMasterKeyConfirmed: false
    property bool seedPhraseRevealed: false
    property bool seedPhraseWord1Valid: false
    property int seedPhraseWord1WordNumber: -1
    property bool seedPhraseWord2Valid: false
    property int seedPhraseWord2WordNumber: -1
    property bool seedPhraseBackupConfirmed: false
    property bool derivationPathOutOfTheDefaultStatusDerivationTreeConfirmed: false
    property bool derivationPathOutOfTheDefaultStatusDerivationTree: root.addAccountModule?
                                                                         !root.addAccountModule.derivationPath.startsWith(Constants.addAccountPopup.predefinedPaths.ethereum) ||
                                                                         (root.addAccountModule.derivationPath.match(/'/g) || []).length !== 3 ||
                                                                         (root.addAccountModule.derivationPath.match(/\//g) || []).length !== 5
                                                                       : false

    readonly property var derivationPathRegEx: /^(m\/44'\/)([0-9|'|\/](?!\/'))*$/
    property string selectedRootPath: Constants.addAccountPopup.predefinedPaths.ethereum
    readonly property var roots: [Constants.addAccountPopup.predefinedPaths.custom,
        Constants.addAccountPopup.predefinedPaths.ethereum,
        Constants.addAccountPopup.predefinedPaths.ethereumRopsten,
        Constants.addAccountPopup.predefinedPaths.ethereumLedger,
        Constants.addAccountPopup.predefinedPaths.ethereumLedgerLive
    ]

    function resetStoreValues() {
        root.enteredSeedPhraseIsValid = false
        root.enteredPrivateKeyIsValid = false
        root.addingNewMasterKeyConfirmed = false
        root.seedPhraseRevealed = false
        root.seedPhraseWord1Valid = false
        root.seedPhraseWord1WordNumber = -1
        root.seedPhraseWord2Valid = false
        root.seedPhraseWord2WordNumber = -1
        root.seedPhraseBackupConfirmed = false
        root.derivationPathOutOfTheDefaultStatusDerivationTreeConfirmed = false
        root.selectedRootPath = Constants.addAccountPopup.predefinedPaths.ethereum

        root.cleanPrivateKey()
        root.cleanSeedPhrase()
    }

    function submitAddAccount(event) {
        if (!root.primaryPopupButtonEnabled) {
            return
        }

        if(!event) {
            root.currentState.doPrimaryAction()
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true
            root.currentState.doPrimaryAction()
        }
    }

    function getSeedPhrase() {
        return root.addAccountModule.getSeedPhrase()
    }

    function changeSelectedOrigin(keyUid) {
        root.addAccountModule.changeSelectedOrigin(keyUid)
    }

    readonly property var changeDerivationPathPostponed: Backpressure.debounce(root, 400, function (path) {
        root.changeDerivationPath(path)
    })

    readonly property var changeWatchOnlyAccountAddressPostponed: Backpressure.debounce(root, 400, function (address) {
        root.addAccountModule.changeWatchOnlyAccountAddress(address)
    })

    function cleanWatchOnlyAccountAddress() {
        root.addAccountModule.changeWatchOnlyAccountAddress("")
    }

    readonly property var changePrivateKeyPostponed: Backpressure.debounce(root, 400, function (privateKey) {
        root.addAccountModule.changePrivateKey(privateKey)
    })

    function cleanPrivateKey() {
        root.enteredPrivateKeyIsValid = false
        root.addAccountModule.newKeyPairName = ""
        root.addAccountModule.changePrivateKey("")
    }

    function changeDerivationPath(path) {
        root.addAccountModule.changeDerivationPath(path)
    }

    function changeRootDerivationPath(rootPath) {
        root.selectedRootPath = rootPath
        root.addAccountModule.derivationPath = "%1/".arg(rootPath)
    }

    function changeSelectedDerivedAddress(address) {
        root.addAccountModule.changeSelectedDerivedAddress(address)
    }

    function resetDerivationPath() {
        root.selectedRootPath = Constants.addAccountPopup.predefinedPaths.ethereum
        root.addAccountModule.resetDerivationPath()
    }

    function authenticateForEditingDerivationPath() {
        root.addAccountModule.authenticateForEditingDerivationPath()
    }

    function startScanningForActivity() {
        root.addAccountModule.startScanningForActivity()
    }

    function validSeedPhrase(seedPhrase) {
        return root.addAccountModule.validSeedPhrase(seedPhrase)
    }

    function changeSeedPhrase(seedPhrase) {
        root.addAccountModule.changeSeedPhrase(seedPhrase)
    }

    function cleanSeedPhrase() {
        root.enteredSeedPhraseIsValid = false
        root.addAccountModule.newKeyPairName = ""
        root.changeSeedPhrase("")
    }

    function translation(key, isTitle) {
        if (!isTitle) {
            if (key === Constants.addAccountPopup.predefinedPaths.custom)
                return qsTr("Type your own derivation path")
            return key
        }
        switch(key) {
        case Constants.addAccountPopup.predefinedPaths.custom:
            return qsTr("Custom")
        case Constants.addAccountPopup.predefinedPaths.ethereum:
            return qsTr("Ethereum")
        case Constants.addAccountPopup.predefinedPaths.ethereumRopsten:
            return qsTr("Ethereum Testnet (Ropsten)")
        case Constants.addAccountPopup.predefinedPaths.ethereumLedger:
            return qsTr("Ethereum (Ledger)")
        case Constants.addAccountPopup.predefinedPaths.ethereumLedgerLive:
            return qsTr("Ethereum (Ledger Live/KeepKey)")
        }
    }

    function getFromClipboard() {
       return globalUtils.getFromClipboard()
    }

    readonly property bool primaryPopupButtonEnabled: {
        if (!root.addAccountModule || !root.currentState || root.disablePopup) {
            return false
        }

        let valid = root.addAccountModule.accountName !== "" &&
            root.addAccountModule.selectedColor !== "" &&
            root.addAccountModule.selectedEmoji !== ""

        if (root.currentState.stateType === Constants.addAccountPopup.state.main) {
            if (root.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.profile ||
                    root.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.seedImport) {
                return valid &&
                        root.derivationPathRegEx.test(root.addAccountModule.derivationPath) &&
                        (!root.derivationPathOutOfTheDefaultStatusDerivationTree ||
                         root.derivationPathOutOfTheDefaultStatusDerivationTreeConfirmed)
            }
            if (root.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.unknown &&
                    root.selectedOrigin.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc) {
                return valid &&
                        !!root.watchOnlyAccAddress &&
                        root.watchOnlyAccAddress.loaded &&
                        !root.watchOnlyAccAddress.alreadyCreated &&
                        root.watchOnlyAccAddress.address !== ""
            }
            if (root.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.privateKeyImport) {
                return valid &&
                        root.enteredPrivateKeyIsValid &&
                        !!root.privateKeyAccAddress &&
                        root.privateKeyAccAddress.loaded &&
                        !root.privateKeyAccAddress.alreadyCreated &&
                        root.privateKeyAccAddress.address !== "" &&
                        root.addAccountModule.newKeyPairName !== ""
            }
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.enterPrivateKey) {
            return root.enteredPrivateKeyIsValid &&
                    !!root.privateKeyAccAddress &&
                    root.privateKeyAccAddress.loaded &&
                    !root.privateKeyAccAddress.alreadyCreated &&
                    root.privateKeyAccAddress.address !== "" &&
                    root.addAccountModule.newKeyPairName !== ""
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhrase) {
            return root.enteredSeedPhraseIsValid &&
                    root.addAccountModule.newKeyPairName !== ""

        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.confirmAddingNewMasterKey) {
            return root.addingNewMasterKeyConfirmed
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.displaySeedPhrase) {
            return root.seedPhraseRevealed
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1) {
            return root.seedPhraseWord1Valid
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord2) {
            return root.seedPhraseWord2Valid
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.confirmSeedPhraseBackup) {
            return root.seedPhraseBackupConfirmed
        }

        if (root.currentState.stateType === Constants.addAccountPopup.state.enterKeypairName) {
            return root.addAccountModule.newKeyPairName !== ""
        }

        return true
    }
}
