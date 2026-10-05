import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "Внешний вид / Appearance"
        icon: "preferences-desktop-color"
        source: "config/configAppearance.qml"
    }
    ConfigCategory {
        name: "Поддержка автора / Support"
        icon: "favorite"
        source: "config/configSupport.qml"
    }
}
