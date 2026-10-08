// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2026 Greg / Columbia Foundry
import QtQuick
import org.kde.taskmanager as TaskManager
import org.kde.kitemmodels as KItemModels

QtObject {
    id: root

    required property var desktopId
    required property string activityId

    // Injectable for model tests. Production uses KDE's shared window source;
    // KDE handles desktop moves, sticky windows, hidden windows and activities.
    property var taskSource: kdeTasks
    readonly property var windowModel: pagerWindows
    readonly property int count: pagerWindows.count

    property TaskManager.TasksModel kdeTasks: TaskManager.TasksModel {
        virtualDesktop: root.desktopId
        filterByVirtualDesktop: true
        activity: root.activityId
        filterByActivity: true
        filterHidden: true
        groupMode: TaskManager.TasksModel.GroupDisabled
        // Icons follow the windows left to right across all screens; KDE
        // re-sorts on its own geometry updates, so moving a window reorders them.
        sortMode: TaskManager.TasksModel.SortWindowPositionHorizontal
    }

    // Native role filters preserve the existing pager eligibility rules.
    // A title change is not a filter change; delegates stay attached to rows.
    property KItemModels.KSortFilterProxyModel windows: KItemModels.KSortFilterProxyModel {
        sourceModel: root.taskSource
        filterRoleName: "IsWindow"
        filterRegularExpression: /^true$/
    }
    property KItemModels.KSortFilterProxyModel pagerWindows: KItemModels.KSortFilterProxyModel {
        sourceModel: root.windows
        filterRoleName: "SkipPager"
        filterRegularExpression: /^false$/
    }

    function closeAll() {
        // Reverse traversal tolerates synchronous removal after a close request.
        // Map through both proxies; filtered row numbers are not source rows.
        for (let row = pagerWindows.count - 1; row >= 0; --row) {
            const windowIndex = root.pagerWindows.mapToSource(root.pagerWindows.index(row, 0))
            const taskIndex = root.windows.mapToSource(windowIndex)
            root.taskSource.requestClose(taskIndex)
        }
    }
}
