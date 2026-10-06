// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2026 Greg / Columbia Foundry
pragma ComponentBehavior: Bound
import QtQuick
import org.kde.kirigami as Kirigami

Row {
    id: root
    required property var windowModel
    required property int iconSize
    required property int iconLimit
    property bool showIcons: true
    spacing: 2

    Repeater {
        model: root.windowModel
        delegate: Loader {
            id: iconSlot
            required property int index
            required property var decoration
            objectName: "taskIconSlot" + index
            // Only the first N windows allocate an icon. Other rows retain
            // lightweight model-bound placeholders, without resetting the model.
            active: root.showIcons && index < root.iconLimit
            visible: active
            width: active ? root.iconSize : 0
            height: active ? root.iconSize : 0
            sourceComponent: Kirigami.Icon {
                source: iconSlot.decoration
            }
        }
    }
}
