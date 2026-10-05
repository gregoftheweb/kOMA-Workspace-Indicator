// SPDX-License-Identifier: GPL-2.0-or-later
// Derived from Desktop Switcher by Sm1Tee.
// Modified by Greg / Columbia Foundry for kOMA; notice added 2026-10-05.
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
    property string cfg_language: "en"

    function tr(ru, en) {
        return root.cfg_language === "en" ? en : ru
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: language
            Kirigami.FormData.label: "Язык / Language:"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: "Русский", value: "ru" },
                { text: "English", value: "en" }
            ]
            Component.onCompleted: currentIndex = indexOfValue(root.cfg_language)
            onActivated: root.cfg_language = currentValue
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: root.tr("Форма", "Shape")
        }

        QQC2.ComboBox {
            id: indicatorShape
            Kirigami.FormData.label: root.tr("Форма индикатора:", "Indicator shape:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: root.tr("Точки", "Dots"), value: "dot" },
                { text: root.tr("Круги", "Circles"), value: "circle" },
                { text: root.tr("Квадраты", "Squares"), value: "square" },
                { text: root.tr("Капсулы", "Capsules"), value: "capsule" },
                { text: root.tr("Без фона, разделители ||", "No background, || separators"), value: "separators" }
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
            Kirigami.FormData.label: root.tr("Визуализация:", "Visualization:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: root.tr("Нет", "None"), value: "none" },
                { text: root.tr("Номера", "Numbers"), value: "numbers" },
                { text: root.tr("Индикатор окон", "Window dots"), value: "windowDot" },
                { text: root.tr("Иконки приложений", "App icons"), value: "icons" }
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
            Kirigami.FormData.label: root.tr("Макс. значков:", "Max icons:")
            from: 1
            to: 10
            visible: root.cfg_visualizationMode === "icons" && (root.cfg_indicatorShape === "square" || root.cfg_indicatorShape === "capsule" || root.cfg_indicatorShape === "separators")
        }

        QQC2.CheckBox {
            id: showNumberWithIcons
            text: root.tr("Показывать номер стола", "Show workspace number")
            visible: root.cfg_visualizationMode === "icons" && (root.cfg_indicatorShape === "square" || root.cfg_indicatorShape === "capsule" || root.cfg_indicatorShape === "separators")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: root.tr("Поведение", "Behavior")
        }

        QQC2.ComboBox {
            id: middleClickAction
            Kirigami.FormData.label: root.tr("Средний клик:", "Middle click:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: root.tr("Ничего", "Nothing"), value: "none" },
                { text: root.tr("Закрыть все окна на столе", "Close all windows on desktop"), value: "closeAll" },
                { text: root.tr("Обзор рабочих столов", "Desktop overview"), value: "overview" },
                { text: root.tr("Сетка рабочих столов", "Desktop grid"), value: "grid" },
                { text: root.tr("Свернуть все окна", "Show desktop"), value: "showDesktop" }
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
            Kirigami.FormData.label: root.tr("Размеры", "Sizes")
        }

        RowLayout {
            Kirigami.FormData.label: root.tr("Размер значков:", "Icon size:")
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
            Kirigami.FormData.label: root.tr("Размер элемента:", "Element size:")

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
            Kirigami.FormData.label: root.tr("Интервал:", "Spacing:")

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
            Kirigami.FormData.label: root.tr("Цвета", "Colors")
        }

        QQC2.CheckBox {
            id: useThemeColors
            text: root.tr("Использовать цвета темы KDE", "Use KDE theme colors")
        }

        KQuickControls.ColorButton {
            id: customActiveBgColor
            Kirigami.FormData.label: root.tr("Фон активного стола:", "Active desktop bg:")
            color: root.cfg_customActiveBgColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors
            onColorChanged: root.cfg_customActiveBgColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customInactiveBgColor
            Kirigami.FormData.label: root.tr("Фон неактивных столов:", "Inactive desktop bg:")
            color: root.cfg_customInactiveBgColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors
            onColorChanged: root.cfg_customInactiveBgColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customBorderColor
            Kirigami.FormData.label: root.tr("Цвет границ:", "Border color:")
            color: root.cfg_customBorderColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors
            onColorChanged: root.cfg_customBorderColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customNumberColor
            Kirigami.FormData.label: root.tr("Цвет номеров:", "Number color:")
            color: root.cfg_customNumberColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors && root.cfg_visualizationMode === "numbers"
            onColorChanged: root.cfg_customNumberColor = color.toString()
        }

        KQuickControls.ColorButton {
            id: customDotColor
            Kirigami.FormData.label: root.tr("Цвет индикатора окон:", "Window dot color:")
            color: root.cfg_customDotColor
            showAlphaChannel: true
            visible: !root.cfg_useThemeColors && root.cfg_visualizationMode === "windowDot"
            onColorChanged: root.cfg_customDotColor = color.toString()
        }
    }
}
