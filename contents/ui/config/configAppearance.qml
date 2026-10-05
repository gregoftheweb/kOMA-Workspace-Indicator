// SPDX-License-Identifier: GPL-2.0-or-later
// Derived from Desktop Switcher by Sm1Tee.
// Modified by Greg / Columbia Foundry for kOMA; 2026-10-05: kOMA changes and English-only interface.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQuickControls

KCM.SimpleKCM {
    id: root

    property string cfg_indicatorShape: "capsule"
    property string cfg_visualizationMode: "icons"
    property alias cfg_maxIconCount: maxIconCount.value
    property alias cfg_showNumberWithIcons: showNumberWithIcons.checked
    property int cfg_elementSize: 30
    property int cfg_elementSpacing: 10
    property alias cfg_useThemeColors: useThemeColors.checked
    property string cfg_customActiveBgColor: "#3daee9"
    property string cfg_customInactiveBgColor: "#4d4d4d"
    property string cfg_customBorderColor: "#7f8c8d"
    property string cfg_customNumberColor: "#ffffff"
    property string cfg_customDotColor: "#ffffff"
    property string cfg_middleClickAction: "none"
    property int cfg_iconSize: 30


    Kirigami.FormLayout {

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Shape"
        }

        QQC2.ComboBox {
            id: indicatorShape
            Kirigami.FormData.label: "Indicator shape:"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: "Dots", value: "dot" },
                { text: "Circles", value: "circle" },
                { text: "Squares", value: "square" },
                { text: "Capsules", value: "capsule" },
                { text: "No background, || separators", value: "separators" }
            ]

            function syncCurrentIndex() {
                currentIndex = indexOfValue(root.cfg_indicatorShape)
            }

            Component.onCompleted: syncCurrentIndex()
            onModelChanged: syncCurrentIndex()
            onActivated: root.cfg_indicatorShape = currentValue

            Connections {
                target: root
                function onCfg_indicatorShapeChanged() { indicatorShape.syncCurrentIndex() }
            }
        }

        QQC2.ComboBox {
            id: visualizationMode
            Kirigami.FormData.label: "Visualization:"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: "None", value: "none" },
                { text: "Numbers", value: "numbers" },
                { text: "Window dots", value: "windowDot" },
                { text: "App icons", value: "icons" }
            ]

            function syncCurrentIndex() {
                currentIndex = indexOfValue(root.cfg_visualizationMode)
            }

            Component.onCompleted: syncCurrentIndex()
            onModelChanged: syncCurrentIndex()
            onActivated: root.cfg_visualizationMode = currentValue

            Connections {
                target: root
                function onCfg_visualizationModeChanged() { visualizationMode.syncCurrentIndex() }
            }
        }

        QQC2.SpinBox {
            id: maxIconCount
            Kirigami.FormData.label: "Max icons:"
            from: 1
            to: 10
            visible: root.cfg_visualizationMode === "icons" && (root.cfg_indicatorShape === "square" || root.cfg_indicatorShape === "capsule" || root.cfg_indicatorShape === "separators")
        }

        QQC2.CheckBox {
            id: showNumberWithIcons
            text: "Show workspace number"
            visible: root.cfg_visualizationMode === "icons" && (root.cfg_indicatorShape === "square" || root.cfg_indicatorShape === "capsule" || root.cfg_indicatorShape === "separators")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Behavior"
        }

        QQC2.ComboBox {
            id: middleClickAction
            Kirigami.FormData.label: "Middle click:"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: "Nothing", value: "none" },
                { text: "Close all windows on desktop", value: "closeAll" },
                { text: "Desktop overview", value: "overview" },
                { text: "Desktop grid", value: "grid" },
                { text: "Show desktop", value: "showDesktop" }
            ]

            function syncCurrentIndex() {
                currentIndex = indexOfValue(root.cfg_middleClickAction)
            }

            Component.onCompleted: syncCurrentIndex()
            onModelChanged: syncCurrentIndex()
            onActivated: root.cfg_middleClickAction = currentValue

            Connections {
                target: root
                function onCfg_middleClickActionChanged() { middleClickAction.syncCurrentIndex() }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Sizes"
        }

        RowLayout {
            Kirigami.FormData.label: "Icon size:"
            visible: root.cfg_visualizationMode === "icons" && (root.cfg_indicatorShape === "square" || root.cfg_indicatorShape === "capsule" || root.cfg_indicatorShape === "separators")

            QQC2.Slider {
                id: iconSize
                Layout.fillWidth: true
                from: 6
                to: 48
                stepSize: 1
                value: root.cfg_iconSize
                onMoved: root.cfg_iconSize = Math.round(value)
            }

            QQC2.Label {
                text: root.cfg_iconSize + " px"
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Kirigami.FormData.label: "Element size:"

            QQC2.Slider {
                id: elementSize
                Layout.fillWidth: true
                from: 8
                to: 64
                stepSize: 1
                value: root.cfg_elementSize
                onMoved: root.cfg_elementSize = Math.round(value)
            }

            QQC2.Label {
                text: root.cfg_elementSize + " px"
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Kirigami.FormData.label: "Spacing:"

            QQC2.Slider {
                id: elementSpacing
                Layout.fillWidth: true
                from: 0
                to: 32
                stepSize: 1
                value: root.cfg_elementSpacing
                onMoved: root.cfg_elementSpacing = Math.round(value)
            }

            QQC2.Label {
                text: root.cfg_elementSpacing + " px"
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                horizontalAlignment: Text.AlignRight
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Colors"
        }

        QQC2.CheckBox {
            id: useThemeColors
            text: "Use KDE theme colors"
        }

        KQuickControls.ColorButton {
            id: customActiveBgColor
            Kirigami.FormData.label: "Active desktop bg:"
            color: root.cfg_customActiveBgColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors
            onColorChanged: root.cfg_customActiveBgColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customInactiveBgColor
            Kirigami.FormData.label: "Inactive desktop bg:"
            color: root.cfg_customInactiveBgColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors
            onColorChanged: root.cfg_customInactiveBgColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customBorderColor
            Kirigami.FormData.label: "Border color:"
            color: root.cfg_customBorderColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors
            onColorChanged: root.cfg_customBorderColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customNumberColor
            Kirigami.FormData.label: "Number color:"
            color: root.cfg_customNumberColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors && root.cfg_visualizationMode === "numbers"
            onColorChanged: root.cfg_customNumberColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customDotColor
            Kirigami.FormData.label: "Window dot color:"
            color: root.cfg_customDotColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors && root.cfg_visualizationMode === "windowDot"
            onColorChanged: root.cfg_customDotColor = color.toString()
        }
    }
}
