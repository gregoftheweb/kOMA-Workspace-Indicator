// SPDX-License-Identifier: GPL-2.0-or-later
// Derived from Desktop Switcher by Sm1Tee.
// Modified by Greg / Columbia Foundry, 2026-10-05: English-only interface.
import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color"
        source: "config/configAppearance.qml"
    }
    ConfigCategory {
        name: "Support"
        icon: "favorite"
        source: "config/configSupport.qml"
    }
}
