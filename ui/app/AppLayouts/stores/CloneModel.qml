import QtQuick 2.15

/// Helper item to clone a model and alter its data without affecting the original model
/// \beware this is not a proxy model. It clones the initial state
///     and every time the instance changes and doesn't adapt when the data
///     in the source model \c allNetworksModel changes
/// \beware use it with small models and in temporary views (e.g. popups)
/// \note requires `rowData` to be implemented in the model
/// \note tried to use SortFilterProxyModel with but it complicates implementation too much
ListModel {
    id: root

    required property var sourceModel

    /// Roles to clone
    required property var roles

    /// Roles to override or add of the form { role: "roleName", transform: function(modelData) { return newValue } }
    property var rolesOverride: []

    Component.onCompleted: cloneModel(sourceModel)
    onSourceModelChanged: cloneModel(sourceModel)

    function cloneModel(model) {
        clear()
        if (!model) {
            console.warning("Missing valid data model to clone. The ModelCloner is useless")
            return
        }

        for (let i = 0; i < model.count; i++) {
            const clonedItem = new Object()
            for (var propName of roles) {
                clonedItem[propName] = model.rowData(i, propName)
            }
            for (var newProp of rolesOverride) {
                clonedItem[newProp.role] = newProp.transform(clonedItem)
            }
            append(clonedItem)
        }
    }
}