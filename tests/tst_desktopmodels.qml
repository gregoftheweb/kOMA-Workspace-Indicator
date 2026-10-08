// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtTest
import "../contents/ui"

Item {
    width: 400
    height: 100

    ListModel {
        id: source
        property var closedRows: []
        function requestClose(index) {
            closedRows.push(index.row)
            remove(index.row)
        }
    }
    DesktopTasks {
        id: desktop
        desktopId: "test-desktop"
        activityId: ""
        taskSource: source
    }
    DesktopTasks {
        id: secondDesktop
        desktopId: "test-desktop"
        activityId: ""
        taskSource: source
    }
    WindowIcons {
        id: icons
        windowModel: desktop.windowModel
        iconSize: 22
        iconLimit: 2
    }
    WindowIcons {
        id: secondIcons
        y: 30
        windowModel: secondDesktop.windowModel
        iconSize: 22
        iconLimit: 2
    }

    TestCase {
        name: "DesktopModels"
        when: windowShown

        function task(title, isWindow, skipPager, icon) {
            return {
                display: title,
                IsWindow: isWindow,
                SkipPager: skipPager,
                decoration: icon || "application-x-executable"
            }
        }
        function slot(view, index) {
            return findChild(view, "taskIconSlot" + index)
        }
        function init() {
            source.clear()
            source.closedRows = []
            icons.iconLimit = 2
            icons.showIcons = true
            source.append(task("first", true, false))
            source.append(task("excluded", true, true))
            source.append(task("startup", false, false))
            source.append(task("second", true, false, "folder"))
            source.append(task("third", true, false))
            tryCompare(desktop, "count", 3)
            tryCompare(secondDesktop, "count", 3)
            tryVerify(() => slot(icons, 0) && slot(icons, 0).item !== null)
        }
        function test_titleStormKeepsDelegatesInBothViews() {
            const first = slot(icons, 0)
            const second = slot(icons, 1)
            const other = slot(secondIcons, 0)
            const icon = first.item
            for (let i = 0; i < 1000; ++i)
                source.setProperty(0, "display", "title " + i)
            wait(0)
            compare(slot(icons, 0), first)
            compare(slot(icons, 1), second)
            compare(slot(secondIcons, 0), other)
            compare(first.item, icon)
            compare(desktop.count, 3)
        }
        function test_iconChangesUpdateExistingDelegate() {
            const first = slot(icons, 0)
            const icon = first.item
            source.setProperty(0, "decoration", "folder")
            tryCompare(icon, "source", "folder")
            compare(slot(icons, 0), first)
            compare(first.item, icon)
        }
        function test_pagerEligibilityChanges() {
            source.setProperty(1, "SkipPager", false)
            tryCompare(desktop, "count", 4)
            source.setProperty(2, "IsWindow", true)
            tryCompare(desktop, "count", 5)
            source.setProperty(0, "SkipPager", true)
            tryCompare(desktop, "count", 4)
        }
        function test_insertRemoveAndMove() {
            const first = slot(icons, 0)
            source.append(task("fourth", true, false, "document-open"))
            tryCompare(desktop, "count", 4)
            compare(slot(icons, 0), first)
            source.move(5, 0, 1)
            tryCompare(slot(icons, 0), "decoration", "document-open")
            source.remove(0)
            tryCompare(desktop, "count", 3)
            tryCompare(slot(icons, 0), "decoration", "application-x-executable")
        }
        function test_iconLimitAndHiddenMode() {
            compare(slot(icons, 2).item, null)
            icons.iconLimit = 3
            tryVerify(() => slot(icons, 2).item !== null)
            icons.showIcons = false
            tryCompare(slot(icons, 0), "item", null)
            compare(desktop.count, 3)
            // counts still serve dots/accessibility
            icons.showIcons = true
            tryVerify(() => slot(icons, 0).item !== null)
        }
        function test_closeAllMapsFilteredRowsAndPreservesExcludedTasks() {
            desktop.closeAll()
            compare(JSON.stringify(source.closedRows), JSON.stringify([4, 3, 0]))
            compare(source.count, 2)
            compare(source.get(0).display, "excluded")
            compare(source.get(1).display, "startup")
            tryCompare(desktop, "count", 0)
            tryCompare(secondDesktop, "count", 0)
        }
    }
}
