import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager
import org.kde.plasma.workspace.dbus as DBus

Item {
    id: compactRoot

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property string indicatorShape: Plasmoid.configuration.indicatorShape
    readonly property bool plainSeparators: indicatorShape === "separators"
    readonly property int configuredElementSize: Math.max(8, Plasmoid.configuration.elementSize)
    readonly property int configuredSpacing: Math.max(0, Plasmoid.configuration.elementSpacing)
    readonly property int realDesktopCount: desktopInfo.numberOfDesktops

    readonly property color activeBgColor: Plasmoid.configuration.useThemeColors
        ? Kirigami.Theme.highlightColor
        : Plasmoid.configuration.customActiveBgColor

    readonly property color inactiveBgColor: Plasmoid.configuration.useThemeColors
        ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.35)
        : Plasmoid.configuration.customInactiveBgColor

    readonly property color borderColor: Plasmoid.configuration.useThemeColors
        ? Kirigami.Theme.textColor
        : Plasmoid.configuration.customBorderColor

    readonly property color numberColor: Plasmoid.configuration.useThemeColors
        ? Kirigami.Theme.highlightedTextColor
        : Plasmoid.configuration.customNumberColor

    readonly property int baseIndicatorWidth: indicatorShape === "capsule" ? Math.round(configuredElementSize * 1.8) : configuredElementSize
    readonly property int minSlotWidth: Math.max(baseIndicatorWidth, configuredElementSize)
    readonly property int minSlotHeight: configuredElementSize
    readonly property bool showIcons: (indicatorShape === "capsule" || indicatorShape === "square" || plainSeparators) && Plasmoid.configuration.visualizationMode === "icons"
    readonly property int iconSize: Math.max(6, Plasmoid.configuration.iconSize)
    readonly property bool showNumberWithIcons: showIcons && Plasmoid.configuration.showNumberWithIcons
    readonly property int numberPixelSize: Math.max(10, Math.round(configuredElementSize * 0.65))

    readonly property color dotColor: Plasmoid.configuration.useThemeColors
        ? Kirigami.Theme.textColor
        : Plasmoid.configuration.customDotColor
    readonly property int iconPadding: 6

    property int wheelDelta: 0
    // Bumped on any task change. tasksModel.data() isn't a tracked property, so bindings
    // that scan the model must depend on this, or moving a window between desktops
    // (which only emits dataChanged, not a count change) never refreshes the icons.
    property int taskRevision: 0

    implicitWidth: isVertical ? minSlotHeight : desktopFlow.childrenRect.width
    implicitHeight: isVertical ? desktopFlow.childrenRect.height : minSlotHeight
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    function desktopIdAt(index) {
        if (index < 0 || index >= desktopInfo.desktopIds.length) return "";
        return desktopInfo.desktopIds[index];
    }

    function currentDesktopIndex() {
        const current = desktopInfo.currentDesktop;
        const ids = desktopInfo.desktopIds;
        for (let i = 0; i < ids.length; i++) {
            if (ids[i] === current) return i;
        }
        return -1;
    }

    function setCurrentDesktop(oneBasedIndex) {
        DBus.SessionBus.asyncCall({
            "service": "org.kde.KWin",
            "path": "/KWin",
            "iface": "org.kde.KWin",
            "member": "setCurrentDesktop",
            "arguments": [new DBus.int32(oneBasedIndex)]
        })
    }

    function activateRelativeDesktop(steps) {
        const count = desktopInfo.numberOfDesktops;
        const idx = currentDesktopIndex();
        if (count < 2 || idx < 0) return;
        const target = ((idx + steps) % count + count) % count;
        setCurrentDesktop(target + 1);
    }

    function handleWheel(wheel) {
        wheelDelta += wheel.angleDelta.y || wheel.angleDelta.x;

        let steps = 0;
        while (wheelDelta >= 120) {
            wheelDelta -= 120;
            steps++;
        }
        while (wheelDelta <= -120) {
            wheelDelta += 120;
            steps--;
        }

        if (steps !== 0) activateRelativeDesktop(-steps);
    }

    function tr(ru, en) {
        return Plasmoid.configuration.language === "en" ? en : ru
    }

    function windowCountText(count) {
        if (Plasmoid.configuration.language === "en") {
            return count === 1 ? "1 window" : count + " windows"
        }
        const lastTwoDigits = count % 100;
        const lastDigit = count % 10;
        let suffix = "окон";

        if (lastTwoDigits < 11 || lastTwoDigits > 14) {
            if (lastDigit === 1) {
                suffix = "окно";
            } else if (lastDigit >= 2 && lastDigit <= 4) {
                suffix = "окна";
            }
        }

        return count + " " + suffix
    }

    function taskBelongsToDesktop(taskIndex, desktopId) {
        if (!desktopId) return false;

        if (tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsOnAllVirtualDesktops)) {
            return true;
        }

        const desktops = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.VirtualDesktops) || [];
        return desktops.indexOf(desktopId) !== -1;
    }

    function isVisibleWindowTask(taskIndex) {
        return tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsWindow)
            && !tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.SkipPager);
    }

    function windowCountForDesktop(desktopId, revision) {
        let count = 0;
        for (let row = 0; row < tasksModel.count; row += 1) {
            const taskIndex = tasksModel.makeModelIndex(row);
            if (isVisibleWindowTask(taskIndex) && taskBelongsToDesktop(taskIndex, desktopId)) {
                count += 1;
            }
        }
        return count;
    }

    function applicationIconsForDesktop(desktopId, revision) {
        const icons = [];
        if (!showIcons) return icons;

        for (let row = 0; row < tasksModel.count && icons.length < Plasmoid.configuration.maxIconCount; row += 1) {
            const taskIndex = tasksModel.makeModelIndex(row);
            if (isVisibleWindowTask(taskIndex) && taskBelongsToDesktop(taskIndex, desktopId)) {
                icons.push(tasksModel.data(taskIndex, Qt.DecorationRole));
            }
        }
        return icons;
    }

    function closeAllWindowsOnDesktop(desktopId) {
        for (let row = tasksModel.count - 1; row >= 0; row--) {
            const taskIndex = tasksModel.makeModelIndex(row);
            if (isVisibleWindowTask(taskIndex) && taskBelongsToDesktop(taskIndex, desktopId)) {
                tasksModel.requestClose(taskIndex);
            }
        }
    }

    function invokeKWinShortcut(shortcutName) {
        DBus.SessionBus.asyncCall({
            "service": "org.kde.kglobalaccel",
            "path": "/component/kwin",
            "iface": "org.kde.kglobalaccel.Component",
            "member": "invokeShortcut",
            "arguments": [shortcutName]
        })
    }

    function shapeRadius(shape, size) {
        switch (shape) {
        case "dot":
        case "circle":
        case "capsule":
            return size / 2;
        default:
            return 2;
        }
    }

    function indicatorWidthForIcons(iconCount, numberWidth) {
        const items = iconCount + (numberWidth > 0 ? 1 : 0);
        if (items <= 0) return baseIndicatorWidth;
        const needed = iconCount * iconSize + numberWidth + (items - 1) * 2 + iconPadding;
        return Math.max(baseIndicatorWidth, needed);
    }

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    TaskManager.TasksModel {
        id: tasksModel
        filterByActivity: true
        filterHidden: true
        filterByVirtualDesktop: false
        groupMode: TaskManager.TasksModel.GroupDisabled
        activity: activityInfo.currentActivity

        onDataChanged: compactRoot.taskRevision++
        onRowsInserted: compactRoot.taskRevision++
        onRowsRemoved: compactRoot.taskRevision++
        onRowsMoved: compactRoot.taskRevision++
        onModelReset: compactRoot.taskRevision++
        onLayoutChanged: compactRoot.taskRevision++
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            compactRoot.handleWheel(wheel);
            wheel.accepted = true;
        }
    }

    Flow {
        id: desktopFlow

        width: compactRoot.isVertical ? compactRoot.minSlotHeight : 99999
        height: compactRoot.isVertical ? 99999 : compactRoot.minSlotHeight
        spacing: compactRoot.configuredSpacing
        flow: compactRoot.isVertical ? Flow.TopToBottom : Flow.LeftToRight

        Repeater {
            model: compactRoot.realDesktopCount

            delegate: Item {
                id: desktopDelegate

                readonly property var desktopId: compactRoot.desktopIdAt(index)
                readonly property bool current: desktopId === desktopInfo.currentDesktop
                readonly property int windowCount: compactRoot.windowCountForDesktop(desktopId, compactRoot.taskRevision)
                readonly property var applicationIcons: compactRoot.applicationIconsForDesktop(desktopId, compactRoot.taskRevision)
                readonly property int dynamicIndicatorWidth: Plasmoid.configuration.visualizationMode === "icons"
                    ? compactRoot.indicatorWidthForIcons(applicationIcons.length,
                        compactRoot.showNumberWithIcons ? iconRowNumber.implicitWidth : 0)
                    : compactRoot.baseIndicatorWidth

                readonly property bool hasSeparator: compactRoot.plainSeparators && index < compactRoot.realDesktopCount - 1
                readonly property real separatorExtent: hasSeparator ? separator.implicitWidth + compactRoot.configuredSpacing : 0
                readonly property color plainTextColor: current ? compactRoot.activeBgColor : Kirigami.Theme.textColor

                width: Math.max(compactRoot.minSlotWidth, dynamicIndicatorWidth) + (compactRoot.isVertical ? 0 : separatorExtent)
                height: compactRoot.minSlotHeight + (compactRoot.isVertical ? separatorExtent : 0)
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: compactRoot.tr(
                    "Переключиться на " + (desktopInfo.desktopNames[index] || ""),
                    "Switch to " + (desktopInfo.desktopNames[index] || "")
                )
                Accessible.description: compactRoot.windowCountText(windowCount)

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        compactRoot.setCurrentDesktop(index + 1);
                        event.accepted = true;
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    gesturePolicy: TapHandler.WithinBounds
                    onTapped: compactRoot.setCurrentDesktop(index + 1)
                }

                TapHandler {
                    acceptedButtons: Qt.MiddleButton
                    gesturePolicy: TapHandler.WithinBounds
                    onTapped: {
                        const action = Plasmoid.configuration.middleClickAction;
                        if (action === "closeAll") {
                            compactRoot.closeAllWindowsOnDesktop(desktopDelegate.desktopId)
                        } else if (action === "overview") {
                            compactRoot.invokeKWinShortcut("Overview")
                        } else if (action === "grid") {
                            compactRoot.invokeKWinShortcut("Grid View")
                        } else if (action === "showDesktop") {
                            compactRoot.invokeKWinShortcut("Show Desktop")
                        }
                    }
                }

                Rectangle {
                    id: indicator

                    width: desktopDelegate.dynamicIndicatorWidth
                    height: compactRoot.configuredElementSize
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: compactRoot.isVertical ? 0 : -desktopDelegate.separatorExtent / 2
                    anchors.verticalCenterOffset: compactRoot.isVertical ? -desktopDelegate.separatorExtent / 2 : 0
                    radius: compactRoot.shapeRadius(compactRoot.indicatorShape, Math.min(width, height))
                    clip: true
                    color: {
                        if (compactRoot.plainSeparators || compactRoot.indicatorShape === "circle") return "transparent";
                        return desktopDelegate.current
                            ? compactRoot.activeBgColor
                            : compactRoot.inactiveBgColor;
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    border.width: compactRoot.indicatorShape === "circle" ? Math.max(1, Math.round(compactRoot.configuredElementSize / 8)) : 0
                    border.color: desktopDelegate.current ? compactRoot.activeBgColor : compactRoot.borderColor
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }

                    Rectangle {
                        width: Math.max(3, Math.round(compactRoot.configuredElementSize * 0.18))
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: compactRoot.plainSeparators ? desktopDelegate.plainTextColor : compactRoot.dotColor
                        visible: Plasmoid.configuration.visualizationMode === "windowDot"
                            && desktopDelegate.windowCount > 0
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }

                Row {
                    anchors.centerIn: indicator
                    height: Math.max(compactRoot.configuredElementSize, compactRoot.iconSize, iconRowNumber.implicitHeight)
                    spacing: 2
                    visible: (desktopDelegate.applicationIcons.length > 0 || compactRoot.showNumberWithIcons)
                        && Plasmoid.configuration.visualizationMode === "icons"

                    QQC2.Label {
                        id: iconRowNumber
                        visible: compactRoot.showNumberWithIcons
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: String(index + 1)
                        color: compactRoot.plainSeparators ? desktopDelegate.plainTextColor
                            : desktopDelegate.current ? compactRoot.numberColor : Kirigami.Theme.textColor
                        font.bold: true
                        font.pixelSize: compactRoot.numberPixelSize
                    }

                    Repeater {
                        model: desktopDelegate.applicationIcons

                        Kirigami.Icon {
                            width: compactRoot.iconSize
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            source: modelData
                        }
                    }
                }

                QQC2.Label {
                    anchors.centerIn: indicator
                    width: indicator.width - 2
                    height: Math.max(indicator.height, implicitHeight)
                    visible: Plasmoid.configuration.visualizationMode === "numbers"
                    text: String(index + 1)
                    color: compactRoot.plainSeparators ? desktopDelegate.plainTextColor : compactRoot.numberColor
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: compactRoot.numberPixelSize
                }

                Item {
                    id: separator
                    visible: desktopDelegate.hasSeparator
                    // Geometric strokes avoid the font's pipe glyph descender,
                    // which makes text-based separators appear to hang below digits.
                    implicitWidth: Math.max(6, Math.round(compactRoot.numberPixelSize * 0.6))
                    width: implicitWidth
                    height: Math.round(compactRoot.numberPixelSize * 0.8)
                    x: compactRoot.isVertical ? (parent.width - width) / 2 : parent.width - width
                    y: Math.round(compactRoot.isVertical ? parent.height - height : (parent.height - height) / 2)

                    Rectangle {
                        width: 1
                        height: parent.height
                        anchors.left: parent.left
                        color: Kirigami.Theme.highlightColor
                    }

                    Rectangle {
                        width: 1
                        height: parent.height
                        anchors.right: parent.right
                        color: Kirigami.Theme.highlightColor
                    }
                }

            }
        }
    }
}
