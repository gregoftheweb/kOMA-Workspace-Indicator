import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property string cfg_language: "ru"
    function tr(ru, en) { return root.cfg_language === "en" ? en : ru; }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit

        Item {
            Layout.fillHeight: true
        }

        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: Kirigami.Units.gridUnit * 28
            Layout.fillWidth: true

            Kirigami.Icon {
                source: "favorite"
                implicitWidth: Kirigami.Units.iconSizes.huge
                implicitHeight: Kirigami.Units.iconSizes.huge
                Layout.alignment: Qt.AlignHCenter
            }

            Kirigami.Heading {
                text: root.tr("Поддержка автора", "Support the author")
                level: 2
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            QQC2.Label {
                text: root.tr("Если виджет оказался полезен, можно поддержать развитие проекта через CloudTips.", "If this widget is useful to you, you can support the project through CloudTips.")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            QQC2.Frame {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        text: root.tr("Автор: Sm1Tee", "Author: Sm1Tee")
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    QQC2.Label {
                        text: root.tr("Лицензия: GPL-2.0-or-later", "License: GPL-2.0-or-later")
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            QQC2.Button {
                text: root.tr("Поддержать через CloudTips", "Support via CloudTips")
                icon.name: "favorite"
                Layout.alignment: Qt.AlignHCenter
                onClicked: Qt.openUrlExternally("https://pay.cloudtips.ru/p/fc80e27c")
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
